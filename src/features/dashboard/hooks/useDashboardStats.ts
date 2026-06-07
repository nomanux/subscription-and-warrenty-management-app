import { useMemo } from 'react';
import { useProducts } from '@/features/products/hooks/useProducts';
import { daysRemaining } from '@/features/products/utils';
import type { Product } from '@/features/products/types';

export interface DashboardStats {
  total: number;
  active: number;
  expiring: number;
  expired: number;
}

/**
 * Derives dashboard data from the products query:
 *  - counts by status
 *  - the "expiring soon" list, soonest first
 */
export function useDashboardStats() {
  const { data, isLoading } = useProducts();
  const products: Product[] = data ?? [];

  const stats = useMemo<DashboardStats>(() => {
    return products.reduce<DashboardStats>(
      (acc, product) => {
        acc.total += 1;
        acc[product.status] += 1;
        return acc;
      },
      { total: 0, active: 0, expiring: 0, expired: 0 },
    );
  }, [products]);

  const expiringSoon = useMemo<Product[]>(() => {
    return products
      .filter((product) => product.status === 'expiring')
      .sort((a, b) => daysRemaining(a.expiryDate) - daysRemaining(b.expiryDate));
  }, [products]);

  return { stats, expiringSoon, isLoading };
}
