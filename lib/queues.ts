import { Queue } from 'bullmq';
import { env } from '@/lib/config/env';

function connection() {
  const url = new URL(env.REDIS_URL);
  return { host: url.hostname, port: Number(url.port || 6379), password: url.password || undefined };
}

export type ReceiptJob = { orderId: string; userId: string };
export const receiptQueue = new Queue<ReceiptJob>('order-receipts', { connection: connection() });

export async function enqueueReceipt(job: ReceiptJob): Promise<void> {
  if (!env.QUEUE_ENABLED) return;
  await receiptQueue.add('generate-receipt', job, {
    attempts: 5,
    backoff: { type: 'exponential', delay: 2000 },
    removeOnComplete: 100,
    removeOnFail: 500,
    jobId: `receipt-${job.orderId}`, // idempotencia: evita duplicar el mismo comprobante
  });
}

