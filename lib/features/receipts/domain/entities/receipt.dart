/// A receipt image attached to a warranty.
///
/// The image bytes live as a file on disk; [filePath] points to it. Pure Dart.
library;

class Receipt {
  const Receipt({
    required this.id,
    required this.warrantyId,
    required this.filePath,
    required this.createdAt,
  });

  final String id;
  final String warrantyId;
  final String filePath;
  final DateTime createdAt;

  Receipt copyWith({String? filePath}) => Receipt(
        id: id,
        warrantyId: warrantyId,
        filePath: filePath ?? this.filePath,
        createdAt: createdAt,
      );
}
