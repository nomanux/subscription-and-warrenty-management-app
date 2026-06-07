import { useState } from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ActivityIndicator, Appbar, FAB, Text } from 'react-native-paper';
import { useDeleteProduct, useProducts } from '@/features/products/hooks/useProducts';
import { ProductCard } from '@/features/products/components/ProductCard';
import { ProductForm } from '@/features/products/components/ProductForm';
import type { Product } from '@/features/products/types';

export default function ProductsScreen() {
  const { data: products = [], isLoading } = useProducts();
  const deleteProduct = useDeleteProduct();

  const [formVisible, setFormVisible] = useState(false);
  const [editing, setEditing] = useState<Product | null>(null);

  function openAdd() {
    setEditing(null);
    setFormVisible(true);
  }

  function openEdit(product: Product) {
    setEditing(product);
    setFormVisible(true);
  }

  return (
    <SafeAreaView style={styles.flex} edges={['top']}>
      <Appbar.Header elevated>
        <Appbar.Content title="My Warranties" />
      </Appbar.Header>

      {isLoading ? (
        <View style={styles.center}>
          <ActivityIndicator size="large" />
        </View>
      ) : products.length === 0 ? (
        <View style={styles.center}>
          <Text style={styles.emptyEmoji}>🗂️</Text>
          <Text variant="titleLarge" style={styles.emptyTitle}>
            Your vault is empty
          </Text>
          <Text variant="bodyMedium" style={styles.emptySub}>
            Tap “Add” to track your first warranty.
          </Text>
        </View>
      ) : (
        <ScrollView contentContainerStyle={styles.list}>
          {products.map((product: Product) => (
            <ProductCard
              key={product.id}
              product={product}
              onEdit={openEdit}
              onDelete={deleteProduct.mutate}
            />
          ))}
        </ScrollView>
      )}

      <FAB icon="plus" label="Add" style={styles.fab} onPress={openAdd} />

      <ProductForm
        visible={formVisible}
        initial={editing}
        onDismiss={() => setFormVisible(false)}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1, backgroundColor: '#F3F4F6' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 },
  emptyEmoji: { fontSize: 48, marginBottom: 8 },
  emptyTitle: { marginBottom: 4 },
  emptySub: { color: '#6B7280', textAlign: 'center' },
  list: { padding: 16, paddingBottom: 96, gap: 12 },
  fab: { position: 'absolute', right: 16, bottom: 24 },
});
