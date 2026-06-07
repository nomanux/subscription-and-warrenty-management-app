import { QueryClient } from '@tanstack/react-query';

/** Shared React Query client: caches data, manages loading/error, refetching. */
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      staleTime: 1000 * 30,
      refetchOnWindowFocus: false,
    },
  },
});
