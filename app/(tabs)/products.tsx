import { useState } from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import {
  ActivityIndicator,
  Appbar,
  Button,
  Chip,
  Dialog,
  FAB,
  Portal,
  Text,
  TextInput,
} from 'react-native-paper';
import {
  useCreateProduct,
  useDeleteProduct,
  useProducts,
} from '@/features/products/hooks/useProducts';
import { ProductCard } from '@/features/products/components/ProductCard';
import { CATEGORIES, type Category, type Product } from '@/features/products/types';

function todayISO(): string {
  return new Date().toISOString().slice(0, 10);
}

export default function ProductsScreen() {
  const { data: products = [], isLoading } = useProducts();
  const createProduct = useCreateProduct();
  const deleteProduct = useDeleteProduct();

  const [visible, setVisible] = useState(false);
  const [name, setName] = useState('');
  const [brand, setBrand] = useState('');
  const [category, setCategory] = useState<Category>('Electronics');
  const [purchaseDate, setPurchaseDate] = useState(todayISO());
  const [months, setMonths] = useState('12');

  function resetForm() {
    setName('');
    setBrand('');
    setCategory('Electronics');
    setPurchaseDate(todayISO());
    setMonths('12');
  }

  async function handleSave() {
    if (!name.trim()) return;
    await createProduct.mutateAsync({
      input: {
        productName: name.trim(),
        brand: brand.trim() || null,
        category,
        purchaseDate: new Date(purchaseDate).toISOString(),
        warrantyDurationMonths: Number(months) || 12,
        serialNumber: null,
        modelNumber: null,
        notes: null,
        receipt: null,
      },
    });
    resetForm();
    setVisible(false);
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
            <ProductCard key={product.id} product={product} onDelete={deleteProduct.mutate} />
          ))}
        </ScrollView>
      )}

      <FAB icon="plus" label="Add" style={styles.fab} onPress={() => setVisible(true)} />

      <Portal>
        <Dialog visible={visible} onDismiss={() => setVisible(false)}>
          <Dialog.Title>Add Warranty</Dialog.Title>
          <Dialog.ScrollArea>
            <ScrollView contentContainerStyle={styles.form}>
              <TextInput
                label="Product name"
                value={name}
                onChangeText={setName}
                mode="outlined"
                style={styles.input}
              />
              <TextInput
                label="Brand (optional)"
                value={brand}
                onChangeText={setBrand}
                mode="outlined"
                style={styles.input}
              />
              <Text variant="labelLarge" style={styles.formLabel}>
                Category
              </Text>
              <View style={styles.chips}>
                {CATEGORIES.map((cat) => (
                  <Chip
                    key={cat}
                    selected={category === cat}
                    showSelectedCheck
                    onPress={() => setCategory(cat)}
                    style={styles.catChip}
                  >
                    {cat}
                  </Chip>
                ))}
              </View>
              <TextInput
                label="Purchase date (YYYY-MM-DD)"
                value={purchaseDate}
                onChangeText={setPurchaseDate}
                mode="outlined"
                style={styles.input}
              />
              <TextInput
                label="Warranty (months)"
                value={months}
                onChangeText={setMonths}
                keyboardType="numeric"
                mode="outlined"
                style={styles.input}
              />
            </ScrollView>
          </Dialog.ScrollArea>
          <Dialog.Actions>
            <Button onPress={() => setVisible(false)}>Cancel</Button>
            <Button
              mode="contained"
              onPress={handleSave}
              loading={createProduct.isPending}
              disabled={!name.trim()}
            >
              Save
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
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
  form: { paddingBottom: 8, gap: 8 },
  input: { marginBottom: 4 },
  formLabel: { marginTop: 8, marginBottom: 4 },
  chips: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginBottom: 8 },
  catChip: { marginBottom: 4 },
});
