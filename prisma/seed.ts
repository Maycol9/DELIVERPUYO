import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../generated/prisma/client';

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! });
const prisma = new PrismaClient({ adapter });

async function main() {
  const admin = await prisma.user.upsert({
    where: { email: 'admin@deliverpuyo.local' },
    update: {},
    create: { name: 'Administrador DeliverPuyo', email: 'admin@deliverpuyo.local', passwordHash: await bcrypt.hash('Admin1234', 12), role: 'ADMIN' },
  });
  const client = await prisma.user.upsert({
    where: { email: 'cliente@deliverpuyo.local' },
    update: {},
    create: { name: 'Cliente de Prueba', email: 'cliente@deliverpuyo.local', passwordHash: await bcrypt.hash('Cliente1234', 12), role: 'CLIENT' },
  });
  const categories = [];
  for (const name of ['Comida rápida', 'Bebidas', 'Postres']) {
    categories.push(await prisma.category.upsert({ where: { name }, update: {}, create: { name } }));
  }
  const products = [];
  for (let i = 1; i <= 15; i++) {
    products.push(await prisma.product.upsert({
      where: { categoryId_name: { categoryId: categories[i % categories.length].id, name: `Producto ${i}` } },
      update: { stock: 100 },
      create: { categoryId: categories[i % categories.length].id, name: `Producto ${i}`, description: 'Producto de prueba para el Avance 8', price: 2 + i / 2, stock: 100 },
    }));
  }
  const address = await prisma.address.findFirst({ where: { userId: client.id } }) ?? await prisma.address.create({ data: { userId: client.id, label: 'Casa', address: 'Puyo, Pastaza', reference: 'Dirección de prueba' } });
  const existingOrders = await prisma.order.count({ where: { userId: client.id } });
  for (let n = existingOrders; n < 20; n++) {
    const chosen = products.slice((n % 10), (n % 10) + 3);
    const subtotal = chosen.reduce((sum, p) => sum + Number(p.price), 0);
    await prisma.order.create({
      data: {
        userId: client.id, addressId: address.id, subtotal, deliveryFee: 1.5, total: subtotal + 1.5,
        items: { create: chosen.map((p) => ({ productId: p.id, quantity: 1, unitPrice: p.price, subtotal: p.price })) },
      },
    });
  }
  console.log({ admin: admin.email, client: client.email, orders: await prisma.order.count() });
}
main().finally(() => prisma.$disconnect());

