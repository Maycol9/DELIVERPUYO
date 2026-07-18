import "dotenv/config";
import { Queue } from "bullmq";

async function main() {
  const redisUrl = process.env.REDIS_URL;

  if (!redisUrl) {
    throw new Error("REDIS_URL no está configurada en .env");
  }

  const url = new URL(redisUrl);

  const connection = {
    host: url.hostname,
    port: Number(url.port || 6379),
    username: url.username || undefined,
    password: url.password || undefined,
  };

  const queue = new Queue("order-receipts", { connection });

  const counts = await queue.getJobCounts(
    "wait",
    "active",
    "completed",
    "failed",
    "delayed",
    "paused"
  );

  console.log("\n=== ESTADO DE LA COLA ===");
  console.log(counts);

  const failedJobs = await queue.getFailed(0, 10);

  if (failedJobs.length > 0) {
    console.log("\n=== TRABAJOS FALLIDOS ===");

    for (const job of failedJobs) {
      console.log({
        id: job.id,
        name: job.name,
        data: job.data,
        failedReason: job.failedReason,
      });

      if (job.stacktrace?.length) {
        console.log(job.stacktrace.join("\n"));
      }
    }
  }

  const waitingJobs = await queue.getWaiting(0, 10);

  if (waitingJobs.length > 0) {
    console.log("\n=== TRABAJOS EN ESPERA ===");

    for (const job of waitingJobs) {
      console.log({
        id: job.id,
        name: job.name,
        data: job.data,
      });
    }
  }

  await queue.close();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
