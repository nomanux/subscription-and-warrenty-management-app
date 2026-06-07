import { StyleSheet } from 'react-native';
import { Card, Chip, IconButton } from 'react-native-paper';
import type { Product } from '@/features/products/types';
import { daysRemaining } from '@/features/products/utils';
import { STATUS_COLORS } from '@/theme';

interface ProductCardProps {
  product: Product;
  /** When provided, shows a delete button. */
  onDelete?: (id: string) => void;
}

/** A single warranty card with name, category, and a live status chip. */
export function ProductCard({ product, onDelete }: ProductCardProps) {
  const days = daysRemaining(product.expiryDate);
  const color = STATUS_COLORS[product.status];
  const label =
    product.status === 'expired' ? 'Expired' : `${days} day${days === 1 ? '' : 's'} left`;

  return (
    <Card style={styles.card} mode="elevated">
      <Card.Title
        title={product.productName}
        subtitle={product.brand ? `${product.brand} · ${product.category}` : product.category}
        right={
          onDelete
            ? () => <IconButton icon="delete-outline" onPress={() => onDelete(product.id)} />
            : undefined
        }
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
});
