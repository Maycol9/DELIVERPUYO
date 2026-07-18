import "dotenv/config";
import fs from 'node:fs';
import path from 'node:path';
import PDFDocument from 'pdfkit';
import { Worker } from 'bullmq';
import { prisma } from '@/database/client';
import { env } from '@/lib/config/env';
import type { ReceiptJob } from '@/lib/queues';

const url = new URL(env.REDIS_URL);
const connection = { host: url.hostname, port: Number(url.port || 6379), password: url.password || undefined };

async function generateReceipt({ orderId, userId }: ReceiptJob): Promise<string> {
  const order = await prisma.order.findFirst({
    relationLoadStrategy: 'join',
    where: { id: orderId, userId },
    select: {
      id: true, createdAt: true, subtotal: true, deliveryFee: true, total: true,
      user: { select: { name: true, email: true } },
      items: { select: { quantity: true, unitPrice: true, subtotal: true, product: { select: { name: true } } } },
    },
  });
  if (!order) throw new Error('Pedido no encontrado');
  const dir = path.join(process.cwd(), 'storage', 'receipts');
  fs.mkdirSync(dir, { recursive: true });
  const output = path.join(dir, `pedido-${order.id}.pdf`);
  await new Promise<void>((resolve, reject) => {
    const doc = new PDFDocument({ margin: 50 });
    doc.pipe(fs.createWriteStream(output).on('finish', resolve).on('error', reject));
    doc.fontSize(20).text('DeliverPuyo - Comprobante de pedido', { align: 'center' });
    doc.moveDown().fontSize(11).text(`Pedido: ${order.id}`);
    doc.text(`Cliente: ${order.user.name} (${order.user.email})`);
    doc.text(`Fecha: ${order.createdAt.toISOString()}`);
    doc.moveDown();
    for (const item of order.items) doc.text(`${item.quantity} x ${item.product.name} - $${item.subtotal}`);
    doc.moveDown().text(`Subtotal: $${order.subtotal}`).text(`Envío: $${order.deliveryFee}`).fontSize(14).text(`Total: $${order.total}`);
    doc.end();
  });
  return output;
}

const worker = new Worker<ReceiptJob>('order-receipts', async (job) => generateReceipt(job.data), { connection, concurrency: 2 });
worker.on('completed', (job, result) => console.log(`Comprobante ${job.id} generado: ${result}`));
worker.on('failed', (job, error) => console.error(`Trabajo ${job?.id} falló`, error));
console.log('Worker de comprobantes activo');

