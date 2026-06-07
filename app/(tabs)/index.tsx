import { ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { ActivityIndicator, Appbar, Button, Card, Text } from 'react-native-paper';
import { useDashboardStats, type DashboardStats } from '@/features/dashboard/hooks/useDashboardStats';
import { ProductCard } from '@/features/products/components/ProductCard';
import { STATUS_COLORS } from '@/theme';

const STAT_CARDS: { key: keyof DashboardStats; label: string; color: string }[] = [
  { key: 'total', label: 'Total', color: '#2563EB' },
  { key: 'active', label: 'Active', color: STATUS_COLORS.active },
  { key: 'expiring', label: 'Expiring Soon', color: STATUS_COLORS.expiring },
  { key: 'expired', label: 'Expired', color: STATUS_COLORS.expired },
];

export default function DashboardScreen() {
  const { stats, expiringSoon, isLoading } = useDashboardStats();
  const router = useRouter();

  return (
    <SafeAreaView style={styles.flex} edges={['top']}>
      <Appbar.Header elevated>
        <Appbar.Content title="Dashboard" />
      </Appbar.Header>

      {isLoading ? (
        <View style={styles.center}>
          <ActivityIndicator size="large" />
        </View>
      ) : (
        <ScrollView contentContainerStyle={styles.content}>
          <View style={styles.statsGrid}>
            {STAT_CARDS.map((stat) => (
              <Card key={stat.key} style={styles.statCard} mode="elevated">
                <Card.Content>
                  <Text variant="displaySmall" style={{ color: stat.color, fontWeight: '700' }}>
                    {stats[stat.key]}
                  </Text>
                  <Text variant="labelLarge" style={styles.statLabel}>
                    {stat.label}
                  </Text>
                </Card.Content>
              </Card>
            ))}
          </View>

          <Text variant="titleMedium" style={styles.sectionTitle}>
            Expiring Soon
          </Text>

          {expiringSoon.length === 0 ? (
            <Text variant="bodyMedium" style={styles.muted}>
              Nothing expiring in the next 30 days. 👍
            </Text>
          ) : (
            <View style={styles.list}>
              {expiringSoon.map((product) => (
                <ProductCard key={product.id} product={product} />
              ))}
            </View>
          )}

          <Button
            mode="outlined"
            style={styles.viewAll}
            onPress={() => router.push('/products')}
          >
            View all warranties
          </Button>
        </ScrollView>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1, backgroundColor: '#F3F4F6' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  content: { padding: 16, paddingBottom: 32 },
  statsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12 },
  statCard: { flexGrow: 1, flexBasis: '46%', backgroundColor: '#FFFFFF' },
  statLabel: { color: '#6B7280', marginTop: 2 },
  sectionTitle: { marginTop: 24, marginBottom: 8 },
  muted: { color: '#6B7280' },
  list: { gap: 12 },
  viewAll: { marginTop: 24 },
});
