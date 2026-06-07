import { Image, StyleSheet, View } from 'react-native';
import { Card, Chip, IconButton } from 'react-native-paper';
import type { Product } from '@/features/products/types';
import { daysRemaining } from '@/features/products/utils';
import { STATUS_COLORS } from '@/theme';

interface ProductCardProps {
  product: Product;
  /** When provided, shows an edit button. */
  onEdit?: (product: Product) => void;
  /** When provided, shows a delete button. */
  onDelete?: (id: string) => void;
}

/** A single warranty card with name, category, status chip, and receipt thumb. */
export function ProductCard({ product, onEdit, onDelete }: ProductCardProps) {
  const days = daysRemaining(product.expiryDate);
  const color = STATUS_COLORS[product.status];
  const label =
    product.status === 'expired' ? 'Expired' : `${days} day${days === 1 ? '' : 's'} left`;
  const thumb = product.receipt?.thumbnailUri ?? product.receipt?.uri ?? null;

  return (
    <Card style={styles.card} mode="elevated">
      <Card.Title
        title={product.productName}
        subtitle={product.brand ? `${product.brand} · ${product.category}` : product.category}
        left={
          thumb ? () => <Image source={{ uri: thumb }} style={styles.thumb} /> : undefined
        }
        right={() => (
          <View style={styles.actions}>
            {onEdit ? (
              <IconButton icon="pencil-outline" onPress={() => onEdit(product)} />
            ) : null}
            {onDelete ? (
              <IconButton icon="delete-outline" onPress={() => onDelete(product.id)} />
            ) : null}
          </View>
        )}
      />
      <Card.Content style={styles.content}>
        <Chip
          mode="outlined"
          style={[styles.chip, { borderColor: color }]}
          textStyle={{ color }}
        >
          {label}
        </Chip>
      </Card.Content>
    </Card>
  );
}

const styles = StyleSheet.create({
  card: { backgroundColor: '#FFFFFF' },
  content: { flexDirection: 'row', paddingBottom: 16 },
  chip: { backgroundColor: 'transparent' },
  actions: { flexDirection: 'row' },
  thumb: { width: 44, height: 44, borderRadius: 6 },
});
