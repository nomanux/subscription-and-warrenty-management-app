import { useEffect } from 'react';
import { Stack } from 'expo-router';
import * as Updates from 'expo-updates';
import { PaperProvider } from 'react-native-paper';
import { QueryClientProvider } from '@tanstack/react-query';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';
import { queryClient } from '@/lib/queryClient';
import { theme } from '@/theme';

// Provide a Material icon component so Paper (FAB, IconButton, etc.) renders
// icons reliably on web and native via @expo/vector-icons.
const paperSettings = {
  icon: (props: any) => <MaterialCommunityIcons {...props} />,
};

/**
 * Root layout — wraps the whole app in its providers:
 *  - QueryClientProvider: data fetching/caching
 *  - SafeAreaProvider: notch/insets handling
 *  - PaperProvider: Material theme + components
 */
export default function RootLayout() {
  // On every launch, silently fetch the latest over-the-air update and reload
  // if one is available — so the user just opens the app and it's up to date.
  useEffect(() => {
    async function checkForUpdates() {
      try {
        if (!Updates.isEnabled) return;
        const result = await Updates.checkForUpdateAsync();
        if (result.isAvailable) {
          await Updates.fetchUpdateAsync();
          await Updates.reloadAsync();
        }
      } catch {
        // Ignore update errors — the app keeps working with its current version.
      }
    }
    checkForUpdates();
  }, []);

  return (
    <QueryClientProvider client={queryClient}>
      <SafeAreaProvider>
        <PaperProvider theme={theme} settings={paperSettings}>
          <StatusBar style="auto" />
          <Stack screenOptions={{ headerShown: false }} />
        </PaperProvider>
      </SafeAreaProvider>
    </QueryClientProvider>
  );
}
