import { useEffect, useState } from 'react';
import { Image, ScrollView, StyleSheet, View } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { Button, Chip, Dialog, Portal, Text, TextInput } from 'react-native-paper';
import { useCreateProduct, useUpdateProduct } from '@/features/products/hooks/useProducts';
import { saveReceiptImageLocally } from '@/features/receipts/services/localReceiptService';
import {
  CATEGORIES,
  type Category,
  type Product,
  type ReceiptFile,
} from '@/features/products/types';

function todayISO(): string {
  return new Date().toISOString().slice(0, 10);
}

interface ProductFormProps {
  visible: boolean;
  /** Pass a product to edit it; omit/null to add a new one. */
  initial?: Product | null;
  onDismiss: () => void;
}

/** Add/Edit warranty form in a dialog, with optional receipt image upload. */
export function ProductForm({ visible, initial, onDismiss }: ProductFormProps) {
  const createProduct = useCreateProduct();
  const updateProduct = useUpdateProduct();
  const isEdit = Boolean(initial);

  const [name, setName] = useState('');
  const [brand, setBrand] = useState('');
  const [category, setCategory] = useState<Category>('Electronics');
  const [purchaseDate, setPurchaseDate] = useState(todayISO());
  const [months, setMonths] = useState('12');
  const [receipt, setReceipt] = useState<ReceiptFile | null>(null);
  const [localImageUri, setLocalImageUri] = useState<string | null>(null);
  const [savingReceipt, setSavingReceipt] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Reset/prefill fields whenever the dialog opens.
  useEffect(() => {
    if (!visible) return;
    setName(initial?.productName ?? '');
    setBrand(initial?.brand ?? '');
    setCategory(initial?.category ?? 'Electronics');
    setPurchaseDate((initial?.purchaseDate ?? '').slice(0, 10) || todayISO());
    setMonths(String(initial?.warrantyDurationMonths ?? 12));
    setReceipt(initial?.receipt ?? null);
    setLocalImageUri(null);
    setError(null);
  }, [visible, initial]);

  async function pickImage() {
    setError(null);
    const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!perm.granted) {
      setError('Permission to access photos was denied.');
      return;
    }
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      quality: 0.7,
      base64: true,
    });
    if (!result.canceled && result.assets[0]) {
      const asset = result.assets[0];
      if (asset.base64 && asset.mimeType) {
        setLocalImageUri(`data:${asset.mimeType};base64,${asset.base64}`);
      } else {
        setLocalImageUri(asset.uri);
      }
    }
  }

  async function handleSave() {
    if (!name.trim()) return;
    setError(null);
    try {
      let finalReceipt = receipt;
      if (localImageUri) {
        setSavingReceipt(true);
        const savedReceipt = await saveReceiptImageLocally(localImageUri);
        finalReceipt = {
          uri: savedReceipt.uri,
          fileType: 'image',
          thumbnailUri: savedReceipt.uri,
        };
        setSavingReceipt(false);
      }

      const input = {
        productName: name.trim(),
        brand: brand.trim() || null,
        category,
        purchaseDate: new Date(purchaseDate).toISOString(),
        warrantyDurationMonths: Number(months) || 12,
        serialNumber: initial?.serialNumber ?? null,
        modelNumber: initial?.modelNumber ?? null,
        notes: initial?.notes ?? null,
        receipt: finalReceipt,
      };

      if (isEdit && initial) {
        await updateProduct.mutateAsync({ id: initial.id, changes: input });
      } else {
        await createProduct.mutateAsync({ input });
      }
      onDismiss();
    } catch (e) {
      setSavingReceipt(false);
      setError(e instanceof Error ? e.message : 'Something went wrong.');
    }
  }

  const previewUri = localImageUri ?? receipt?.uri ?? null;
  const saving = createProduct.isPending || updateProduct.isPending || savingReceipt;

  return (
    <Portal>
      <Dialog visible={visible} onDismiss={onDismiss}>
        <Dialog.Title>{isEdit ? 'Edit Warranty' : 'Add Warranty'}</Dialog.Title>
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
            <Text variant="labelLarge" style={styles.label}>
              Category
            </Text>
            <View style={styles.chips}>
              {CATEGORIES.map((cat) => (
                <Chip
                  key={cat}
                  selected={category === cat}
                  showSelectedCheck
                  onPress={() => setCategory(cat)}
                  style={styles.chip}
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

            <Text variant="labelLarge" style={styles.label}>
              Receipt image
            </Text>
            {previewUri ? (
              <Image source={{ uri: previewUri }} style={styles.preview} resizeMode="cover" />
            ) : null}
            <Button icon="camera" mode="outlined" onPress={pickImage} style={styles.imageBtn}>
              {previewUri ? 'Change image' : 'Add receipt image'}
            </Button>

            {error ? (
              <Text style={styles.error}>{error}</Text>
            ) : null}
          </ScrollView>
        </Dialog.ScrollArea>
        <Dialog.Actions>
          <Button onPress={onDismiss} disabled={saving}>
            Cancel
          </Button>
          <Button
            mode="contained"
            onPress={handleSave}
            loading={saving}
            disabled={!name.trim() || saving}
          >
            {savingReceipt ? 'Saving image…' : 'Save'}
          </Button>
        </Dialog.Actions>
      </Dialog>
    </Portal>
  );
}

const styles = StyleSheet.create({
  form: { paddingBottom: 8, gap: 8 },
  input: { marginBottom: 4 },
  label: { marginTop: 8, marginBottom: 4 },
  chips: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginBottom: 8 },
  chip: { marginBottom: 4 },
  preview: { width: '100%', height: 160, borderRadius: 8, marginBottom: 8 },
  imageBtn: { marginTop: 4 },
  error: { color: '#DC2626', marginTop: 8 },
});
