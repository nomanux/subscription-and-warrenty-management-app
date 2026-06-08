/**
 * Product feature types — the core data model of Warranty Vault.
 *
 * Storage note: in local-only mode these objects are persisted as JSON in
 * AsyncStorage, so dates are ISO strings (e.g. "2026-06-07T00:00:00.000Z").
 * When we migrate to Firestore, the service layer converts these to/from
 * Timestamps — consumers of these types do not change.
 */

/** The six product categories, as a readonly tuple we can also iterate in UI. */
export const CATEGORIES = [
  'Electronics',
  'Home Appliances',
  'Kitchen Appliances',
  'Furniture',
  'Vehicle',
  'Others',
] as const;

/** A single category value, derived from the CATEGORIES tuple. */
export type Category = (typeof CATEGORIES)[number];

/** Warranty lifecycle status, derived from the expiry date. */
export type WarrantyStatus = 'active' | 'expiring' | 'expired';

/** How a product record was created. */
export type ProductSource = 'manual' | 'ai';

/**
 * A receipt attached to a product.
 * `uri` is local-only: a file URI on native or a data URI/blob URI on web.
 */
export interface ReceiptFile {
  uri: string;
  fileType: 'image' | 'pdf';
  /** Optional smaller preview used in list rows; same shape works for cloud. */
  thumbnailUri?: string | null;
}

/**
 * Fields the user actually supplies in the Add/Edit form.
 * Computed fields (expiryDate, status) and lifecycle fields (id, timestamps)
 * are NOT here — the service derives/assigns them.
 */
export interface ProductInput {
  productName: string;
  brand: string | null;
  category: Category;
  /** ISO date string of purchase. */
  purchaseDate: string;
  warrantyDurationMonths: number;
  serialNumber: string | null;
  modelNumber: string | null;
  notes: string | null;
  receipt: ReceiptFile | null;
}

/**
 * A full product record as stored in the database.
 * Extends the user-supplied input with derived + lifecycle fields.
 */
export interface Product extends ProductInput {
  id: string;
  /** ISO date string, computed = purchaseDate + warrantyDurationMonths. */
  expiryDate: string;
  /** Derived from expiryDate vs. now; recomputed when read. */
  status: WarrantyStatus;
  /** How the record was created (manual entry vs. AI extraction). */
  source: ProductSource;
  createdAt: string;
  updatedAt: string;
}
