import fs from 'node:fs';
import path from 'node:path';

const baseUrl = process.env.BASE_URL ?? 'http://localhost:3000';
const adminEmail = process.env.BENCHMARK_EMAIL ?? 'admin@deliverpuyo.local';
const adminPassword = process.env.BENCHMARK_PASSWORD ?? 'Admin1234';

async function timed(url: string, init?: RequestInit) {
  const start = performance.now();
  const response = await fetch(url, init);
  const body = await response.json();
  return { status: response.status, ms: Number((performance.now() - start).toFixed(2)), cache: response.headers.get('x-cache'), body };
}

async function main() {
  const login = await fetch(`${baseUrl}/api/auth/login`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ email: adminEmail, password: adminPassword }) });
  if (!login.ok) throw new Error(`Login falló: ${login.status}`);
  const token = (await login.json()).data.accessToken;
  const auth = { authorization: `Bearer ${token}` };

  const productMiss = await timed(`${baseUrl}/api/products?page=1&limit=20&fields=id,name,price`, { headers: { 'x-bypass-cache': '1' } });
  const productWarm = await timed(`${baseUrl}/api/products?page=1&limit=20&fields=id,name,price`);
  const productHit = await timed(`${baseUrl}/api/products?page=1&limit=20&fields=id,name,price`);
  const nplus1 = await timed(`${baseUrl}/api/debug/orders-benchmark?mode=nplus1&limit=20`, { headers: auth });
  const optimized = await timed(`${baseUrl}/api/debug/orders-benchmark?mode=optimized&limit=20`, { headers: auth });

  const result = { generatedAt: new Date().toISOString(), productCache: { bypass: productMiss, warm: productWarm, hit: productHit }, queryOptimization: { before: nplus1, after: optimized } };
  const dir = path.join(process.cwd(), 'evidence');
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, 'benchmark-results.json'), JSON.stringify(result, null, 2));
  console.log(JSON.stringify(result, null, 2));
}
main().catch((error) => { console.error(error); process.exit(1); });
