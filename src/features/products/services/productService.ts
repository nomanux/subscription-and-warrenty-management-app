import { getItem, setItem } from '@/lib/storage';
import { generateId } from '@/lib/id';
import { calculateExpiryDate, computeStatus } from '@/features/products/utils';
import type { Product, ProductInput, ProductSource } from '@/features/products/types';

/**
 * Product service — local-only implementation (AsyncStorage).
 *
 * This is the app's data layer for products. Screens and hooks call ONLY these
 * functions and never touch storage directly. The async signatures intentionally
 * match a future Firestore implementation, so swapping to the cloud later means
 * rewriting just this file.
 */

const PRODUCTS_KEY = 'wv:products';

/** Read all products, recomputing status so it reflects the current date. */
async function readAll(): Promise<Product[]> {
  const products = (await getItem<Product[]>(PRODUCTS_KEY)) ?? [];
  return products.map((product) => ({
    ...product,
    status: computeStatus(product.expiryDate),
  }));
}

async function writeAll(products: Product[]): Promise<void> {
  await setItem(PRODUCTS_KEY, products);
}

/** All products, newest first. */
export async function getProducts(): Promise<Product[]> {
  const products = await readAll();
  return products.sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

/** A single product by id, or null if not found. */
export async function getProduct(id: string): Promise<Product | null> {
  const products = await readAll();
  return products.find((product) => product.id === id) ?? null;
}

/** Create a product from form input; derives id, expiry, status, timestamps. */
export async function createProduct(
  input: ProductInput,
  source: ProductSource = 'manual',
): Promise<Product> {
  const products = await readAll();
  const now = new Date().toISOString();
  const expiryDate = calculateExpiryDate(input.purchaseDate, input.warrantyDurationMonths);

  const product: Product = {
    ...input,
    id: generateId(),
    expiryDate,
    status: computeStatus(expiryDate),
    source,
    createdAt: now,
    updatedAt: now,
  };

  await writeAll([product, ...products]);
  return product;
}

/** Update an existing product; recomputes expiry/status from merged values. */
export async function updateProduct(
  id: string,
  changes: Partial<ProductInput>,
): Promise<Product> {
  const products = await readAll();
  const index = products.findIndex((product) => product.id === id);
  if (index === -1) {
    throw new Error(`Product "${id}" not found`);
  }

  const merged = { ...products[index], ...changes };
  const expiryDate = calculateExpiryDate(merged.purchaseDate, merged.warrantyDurationMonths);

  const updated: Product = {
    ...merged,
    expiryDate,
    status: computeStatus(expiryDate),
    updatedAt: new Date().toISOString(),
  };

  products[index] = updated;
  await writeAll(products);
  return updated;
}

/** Permanently remove a product. */
export async function deleteProduct(id: string): Promise<void> {
  const products = await readAll();
  await writeAll(products.filter((product) => product.id !== id));
}
