const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { test } = require('node:test');
const ts = require('typescript');

// Execute the actual middleware with only JWT verification replaced.
// No .env, signing keys, database, session, or real token is used.
function load(relative, imports = {}) {
  const filename = path.join(__dirname, '..', relative);
  const code = ts.transpileModule(readFileSync(filename, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
  }).outputText;
  const exports = {};
  vm.runInNewContext(code, {
    exports,
    require: (name) => {
      if (!(name in imports)) throw new Error('Unexpected test dependency');
      return imports[name];
    },
  }, { filename });
  return exports;
}
const { ApiError } = load('errors/api-error.ts');
function middleware(verifyAccessToken) {
  return load('middleware/auth.ts', {
    '@/errors/api-error': { ApiError },
    '@/lib/jwt': { verifyAccessToken },
  }).auth;
}
const claims = { sub: 'test-user', email: 'test@example.invalid', role: 'CLIENT' };
const request = () => ({ headers: { authorization: 'Bearer test-fixture-only' } });

test('valid verification proceeds and attaches claims', async () => {
  const req = request();
  let calls = 0;
  await middleware(async () => claims)(req, {}, async () => { calls++; });
  assert.equal(req.user, claims);
  assert.equal(calls, 1);
});
test('missing authentication never invokes route', async () => {
  await assert.rejects(
    middleware(async () => claims)({ headers: {} }, {}, async () => assert.fail()),
    (e) => e.status === 401,
  );
});
test('failed verification never invokes route', async () => {
  await assert.rejects(
    middleware(async () => { throw new Error('invalid fixture'); })(
      request(), {}, async () => assert.fail(),
    ),
    (e) => e.status === 401,
  );
});
for (const status of [422, 403, 409, 500]) {
  test(`downstream ${status} preserves original status and field details`, async () => {
    const error = new ApiError(status, 'Route error', { items: ['Quantity must be positive'] });
    await assert.rejects(
      middleware(async () => claims)(request(), {}, async () => { throw error; }),
      (actual) => actual === error && actual.status === status,
    );
  });
}
