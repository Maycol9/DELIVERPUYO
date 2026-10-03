import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import { PrismaClient } from '../generated/prisma/client';

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) throw new Error('DATABASE_URL is required');

const parsedDatabaseUrl = new URL(databaseUrl);
const databaseHost = parsedDatabaseUrl.hostname.replace(/^\[|\]$/g, '').toLowerCase();
if (
  !['postgres:', 'postgresql:'].includes(parsedDatabaseUrl.protocol) ||
  ['localhost', '127.0.0.1', '::1'].includes(databaseHost)
) {
  throw new Error('Catalog seed requires a remote PostgreSQL URL');
}

const pool = new Pool({
  connectionString: databaseUrl,
  ssl: { rejectUnauthorized: true },
});
const prisma = new PrismaClient({
  adapter: new PrismaPg(pool, { disposeExternalPool: true }),
});

const categoryNames = ['Comida rápida', 'Bebidas', 'Postres'] as const;

const catalogProducts = [
  { name: 'Hamburguesa clásica', category: 'Comida rápida', description: 'Carne, queso, lechuga y tomate.', price: 4.5 },
  { name: 'Hamburguesa completa', category: 'Comida rápida', description: 'Carne, queso, huevo, tocino y vegetales.', price: 5.75 },
  { name: 'Hot dog', category: 'Comida rápida', description: 'Salchicha con salsas y vegetales.', price: 3.0 },
  { name: 'Salchipapa', category: 'Comida rápida', description: 'Papas fritas con salchicha y salsas.', price: 4.0 },
  { name: 'Papas fritas', category: 'Comida rápida', description: 'Porción de papas doradas y crujientes.', price: 2.5 },
  { name: 'Pizza personal', category: 'Comida rápida', description: 'Pizza individual de queso y tomate.', price: 6.5 },
  { name: 'Pollo broaster', category: 'Comida rápida', description: 'Pieza de pollo crocante con papas.', price: 5.5 },
  { name: 'Coca-Cola', category: 'Bebidas', description: 'Gaseosa fría de 500 ml.', price: 1.5 },
  { name: 'Sprite', category: 'Bebidas', description: 'Gaseosa lima-limón de 500 ml.', price: 1.5 },
  { name: 'Agua', category: 'Bebidas', description: 'Agua sin gas de 500 ml.', price: 1.0 },
  { name: 'Jugo natural', category: 'Bebidas', description: 'Jugo de fruta preparado al momento.', price: 2.5 },
  { name: 'Helado de vainilla', category: 'Postres', description: 'Porción cremosa de helado de vainilla.', price: 2.0 },
  { name: 'Brownie', category: 'Postres', description: 'Brownie de chocolate suave y húmedo.', price: 2.5 },
  { name: 'Torta de chocolate', category: 'Postres', description: 'Porción de torta con cubierta de chocolate.', price: 3.5 },
  { name: 'Cheesecake', category: 'Postres', description: 'Porción de cheesecake con base de galleta.', price: 3.75 },
] as const;

async function main(): Promise<void> {
  const categoryIds = new Map<string, string>();

  for (const name of categoryNames) {
    const category = await prisma.category.upsert({
      where: { name },
      update: {},
      create: { name },
      select: { id: true },
    });
    categoryIds.set(name, category.id);
  }

  for (const product of catalogProducts) {
    const categoryId = categoryIds.get(product.category);
    if (!categoryId) throw new Error('Catalog product references an unknown category');

    await prisma.product.upsert({
      where: { categoryId_name: { categoryId, name: product.name } },
      update: {},
      create: {
        categoryId,
        name: product.name,
        description: product.description,
        price: product.price,
        stock: 100,
        status: 'ACTIVE',
      },
    });
  }

  console.log('Catalog seed completed: 3 categories and 15 products checked.');
}

main()
  .catch((error: unknown) => {
    const errorCode =
      typeof error === 'object' && error !== null && 'code' in error && typeof error.code === 'string'
        ? error.code
        : 'UNKNOWN';
    console.error(`Catalog seed failed (${errorCode}).`);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });