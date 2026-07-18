import { Prisma } from '@/generated/prisma/client';
import { prisma } from '@/database/client';
import { ApiError } from '@/errors/api-error';
import { enqueueReceipt } from '@/lib/queues';

const DELIVERY_FEE = new Prisma.Decimal(1.50);

export const orderService = {
  async create(userId: string, input: { addressId: string; items: Array<{ productId: string; quantity: number }> }) {
    const address = await prisma.address.findFirst({ where: { id: input.addressId, userId }, select: { id: true } });
    if (!address) throw new ApiError(404, 'Dirección no encontrada');
    const uniqueProductIds = [...new Set(input.items.map((i) => i.productId))];
    if (uniqueProductIds.length !== input.items.length) throw new ApiError(422, 'No repita productos dentro del mismo pedido');

    const products = await prisma.product.findMany({
      where: { id: { in: uniqueProductIds }, status: 'ACTIVE' },
      select: { id: true, name: true, price: true, stock: true },
    });
    if (products.length !== uniqueProductIds.length) throw new ApiError(422, 'Uno o más productos no existen o están inactivos');
    const productMap = new Map(products.map((p) => [p.id, p]));
    let subtotal = new Prisma.Decimal(0);
    const items = input.items.map((item) => {
      const product = productMap.get(item.productId)!;
      if (product.stock < item.quantity) throw new ApiError(409, `Stock insuficiente para ${product.name}`);
      const lineSubtotal = product.price.mul(item.quantity);
      subtotal = subtotal.add(lineSubtotal);
      return { productId: product.id, quantity: item.quantity, unitPrice: product.price, subtotal: lineSubtotal };
    });

    const order = await prisma.$transaction(async (tx) => {
      for (const item of input.items) {
        const updated = await tx.product.updateMany({ where: { id: item.productId, stock: { gte: item.quantity } }, data: { stock: { decrement: item.quantity } } });
        if (updated.count !== 1) throw new ApiError(409, 'El stock cambió durante el procesamiento; intente nuevamente');
      }
      return tx.order.create({
        data: { userId, addressId: input.addressId, subtotal, deliveryFee: DELIVERY_FEE, total: subtotal.add(DELIVERY_FEE), items: { create: items } },
        select: { id: true, status: true, subtotal: true, deliveryFee: true, total: true, createdAt: true },
      });
    });

    // Tarea pesada desacoplada: el endpoint responde sin esperar la generación del PDF.
    await enqueueReceipt({ orderId: order.id, userId }).catch((error) => console.error('No se pudo encolar el comprobante', error));
    return order;
  },

  async listOptimized(userId: string, role: 'CLIENT' | 'ADMIN', take = 20) {
    // Eager loading controlado + selección de campos. relationLoadStrategy=join evita N+1.
    return prisma.order.findMany({
      relationLoadStrategy: 'join',
      where: role === 'ADMIN' ? {} : { userId },
      take,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true, status: true, total: true, createdAt: true,
        user: role === 'ADMIN' ? { select: { id: true, name: true, email: true } } : false,
        items: { select: { quantity: true, unitPrice: true, product: { select: { id: true, name: true, imageUrl: true } } } },
      },
    });
  },

  async detail(userId: string, role: 'CLIENT' | 'ADMIN', id: string, includeAddress = false) {
    // Relación opcional: se carga solo cuando la pantalla la solicita (equivalente a lazy controlado).
    const order = await prisma.order.findFirst({
      relationLoadStrategy: 'join',
      where: { id, ...(role === 'ADMIN' ? {} : { userId }) },
      select: {
        id: true, status: true, subtotal: true, deliveryFee: true, total: true, createdAt: true,
        items: { select: { quantity: true, unitPrice: true, subtotal: true, product: { select: { id: true, name: true } } } },
        address: includeAddress ? { select: { label: true, address: true, reference: true } } : false,
      },
    });
    if (!order) throw new ApiError(404, 'Pedido no encontrado');
    return order;
  },

  async benchmarkNPlusOne(limit = 20) {
    const start = performance.now();
    let databaseCalls = 1;
    const orders = await prisma.order.findMany({ take: limit, orderBy: { createdAt: 'desc' }, select: { id: true, status: true } });
    const data = [];
    for (const order of orders) {
      const items = await prisma.orderItem.findMany({ where: { orderId: order.id }, select: { productId: true, quantity: true } });
      databaseCalls += 1;
      const expanded = [];
      for (const item of items) {
        const product = await prisma.product.findUnique({ where: { id: item.productId }, select: { id: true, name: true } });
        databaseCalls += 1;
        expanded.push({ ...item, product });
      }
      data.push({ ...order, items: expanded });
    }
    return { mode: 'N+1', databaseCalls, durationMs: Number((performance.now() - start).toFixed(2)), records: data.length };
  },

  async benchmarkOptimized(limit = 20) {
    const start = performance.now();
    const data = await prisma.order.findMany({
      relationLoadStrategy: 'join',
      take: limit,
      orderBy: { createdAt: 'desc' },
      select: { id: true, status: true, items: { select: { quantity: true, product: { select: { id: true, name: true } } } } },
    });
    return { mode: 'EAGER_JOIN', databaseCalls: 1, durationMs: Number((performance.now() - start).toFixed(2)), records: data.length };
  },
};
