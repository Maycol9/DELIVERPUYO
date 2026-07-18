export function pagination(pageRaw: unknown, limitRaw: unknown) {
  const page = Math.max(1, Number(pageRaw ?? 1) || 1);
  const limit = Math.min(50, Math.max(1, Number(limitRaw ?? 20) || 20));
  return {
    page,
    limit,
    skip: (page - 1) * limit,
    meta: (total: number) => ({ page, limit, total, pages: Math.ceil(total / limit) }),
  };
}
