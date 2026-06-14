/// Custom warranty category with icon.
library;

/// A warranty product category with an associated HugeIcon.
class WCategory {
  const WCategory({
    required this.name,
    required this.iconName,
  });

  final String name;
  final String iconName; // HugeIcons enum name as string

  Map<String, dynamic> toMap() => {
    'name': name,
    'iconName': iconName,
  };

  static WCategory fromMap(Map<String, dynamic> map) => WCategory(
    name: map['name'] as String? ?? 'Others',
    iconName: map['iconName'] as String? ?? 'strokeRoundedShoppingBag01',
  );
}
