import { MD3LightTheme, type MD3Theme } from 'react-native-paper';

/**
 * App theme (Material 3) — central place for brand colors.
 * Tweak `primary` etc. here and it flows through every Paper component.
 */
export const theme: MD3Theme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    primary: '#2563EB',
    secondary: '#0EA5E9',
  },
};

/** Status colors used for warranty badges. */
export const STATUS_COLORS = {
  active: '#16A34A',
  expiring: '#D97706',
  expired: '#DC2626',
} as const;
