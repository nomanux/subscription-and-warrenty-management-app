import type { WarrantyStatus } from './types';

/**
 * Warranty date math — pure functions, no storage/UI.
 * Dates are passed/returned as ISO strings to match how we persist them.
 */

/** A warranty within this many days of expiry counts as "expiring soon". */
export const EXPIRING_SOON_THRESHOLD_DAYS = 30;

const MS_PER_DAY = 1000 * 60 * 60 * 24;

/** Normalize a date to local midnight so day math ignores the time-of-day. */
function startOfDay(date: Date): Date {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
}

/**
 * Add whole months to a date, clamping the day if the target month is shorter
 * (e.g. Jan 31 + 1 month → Feb 28, not Mar 3).
 */
function addMonths(date: Date, months: number): Date {
  const d = new Date(date);
  const targetDay = d.getDate();
  d.setDate(1); // avoid rollover while changing month
  d.setMonth(d.getMonth() + months);
  const lastDayOfTargetMonth = new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate();
  d.setDate(Math.min(targetDay, lastDayOfTargetMonth));
  return d;
}

/**
 * Compute the warranty expiry date.
 * @param purchaseDate ISO date string of purchase
 * @param months warranty duration in months
 * @returns ISO date string of expiry
 */
export function calculateExpiryDate(purchaseDate: string, months: number): string {
  const expiry = addMonths(new Date(purchaseDate), months);
  return expiry.toISOString();
}

/**
 * Whole days remaining until expiry (based on calendar days).
 * Returns a negative number if the warranty has already expired.
 */
export function daysRemaining(expiryDate: string, now: Date = new Date()): number {
  const diff = startOfDay(new Date(expiryDate)).getTime() - startOfDay(now).getTime();
  return Math.round(diff / MS_PER_DAY);
}

/**
 * Derive the warranty status from its expiry date.
 *  - expired:  past the expiry date
 *  - expiring: within EXPIRING_SOON_THRESHOLD_DAYS
 *  - active:   more time than that remaining
 */
export function computeStatus(expiryDate: string, now: Date = new Date()): WarrantyStatus {
  const days = daysRemaining(expiryDate, now);
  if (days < 0) return 'expired';
  if (days <= EXPIRING_SOON_THRESHOLD_DAYS) return 'expiring';
  return 'active';
}
