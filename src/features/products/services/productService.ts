import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  setDoc,
} from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { calculateExpiryDate, computeStatus } from '@/features/products/utils';
import type { Product, ProductInput, ProductSource } from '@/features/products/types';

/**
 * Product service — Cloud Firestore implementation.
 *
 * Data lives in the `products` collection and syncs across devices. Dates are
 * stored as ISO strings (matching the Product type), so no Timestamp mapping
 * is needed. Status is recomputed on read so it stays current.
 *
 * Note: there is no per-user scoping yet (auth comes later) — every device
 * shares the same `products` collection. We'll add `userId` filtering when we
 * wire authentication.
 */

const COLLECTION = 'products';

/** Recompute status from expiry so it reflects the current date. */
function withFreshStatus(product: Product): Product {
  return { ...product, status: computeStatus(product.expiryDate) };
}

/** All products, newest first. */
export async function getProducts(): Promise<Product[]> {
  const q = query(collection(db, COLLECTION), orderBy('createdAt', 'desc'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map((d) =>
    withFreshStatus({ ...(d.data() as Product), id: d.id }),
  );
}

/** A single product by id, or null if not found. */
export async function getProduct(id: string): Promise<Product | null> {
  const snapshot = await getDoc(doc(db, COLLECTION, id));
  if (!snapshot.exists()) return null;
  return withFreshStatus({ ...(snapshot.data() as Product), id: snapshot.id });
}

/** Create a product; derives id, expiry, status, timestamps. */
export async function createProduct(
  input: ProductInput,
  source: ProductSource = 'manual',
): Promise<Product> {
  const ref = doc(collection(db, COLLECTION));
  const now = new Date().toISOString();
  const expiryDate = calculateExpiryDate(input.purchaseDate, input.warrantyDurationMonths);

  const product: Product = {
    ...input,
    id: ref.id,
    expiryDate,
    status: computeStatus(expiryDate),
    source,
    createdAt: now,
    updatedAt: now,
  };

  await setDoc(ref, product);
  return product;
}

/** Update a product; recomputes expiry/status from merged values. */
export async function updateProduct(
  id: string,
  changes: Partial<ProductInput>,
): Promise<Product> {
  const existing = await getProduct(id);
  if (!existing) {
    throw new Error(`Product "${id}" not found`);
  }

  const merged = { ...existing, ...changes };
  const expiryDate = calculateExpiryDate(merged.purchaseDate, merged.warrantyDurationMonths);

  const updated: Product = {
    ...merged,
    expiryDate,
    status: computeStatus(expiryDate),
    updatedAt: new Date().toISOString(),
  };

  await setDoc(doc(db, COLLECTION, id), updated);
  return updated;
}

/** Permanently remove a product. */
export async function deleteProduct(id: string): Promise<void> {
  await deleteDoc(doc(db, COLLECTION, id));
}
