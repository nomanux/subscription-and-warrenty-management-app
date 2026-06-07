import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import * as productService from '@/features/products/services/productService';
import type { ProductInput, ProductSource } from '@/features/products/types';

/**
 * React Query hooks — the application layer between screens and the service.
 * Screens call these; they never call productService directly. Mutations
 * invalidate the products query so the UI refreshes automatically.
 */

const PRODUCTS_KEY = ['products'] as const;

/** List all products (with loading/error state + caching). */
export function useProducts() {
  return useQuery({
    queryKey: PRODUCTS_KEY,
    queryFn: productService.getProducts,
  });
}

/** Fetch a single product by id. */
export function useProduct(id: string) {
  return useQuery({
    queryKey: ['product', id],
    queryFn: () => productService.getProduct(id),
    enabled: !!id,
  });
}

/** Create a product, then refresh the list. */
export function useCreateProduct() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (vars: { input: ProductInput; source?: ProductSource }) =>
      productService.createProduct(vars.input, vars.source),
    onSuccess: () => qc.invalidateQueries({ queryKey: PRODUCTS_KEY }),
  });
}

/** Update a product, then refresh the list. */
export function useUpdateProduct() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (vars: { id: string; changes: Partial<ProductInput> }) =>
      productService.updateProduct(vars.id, vars.changes),
    onSuccess: () => qc.invalidateQueries({ queryKey: PRODUCTS_KEY }),
  });
}

/** Delete a product, then refresh the list. */
export function useDeleteProduct() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => productService.deleteProduct(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: PRODUCTS_KEY }),
  });
}
