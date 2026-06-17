/// Add/Edit warranty form — a full-screen page (not a modal).
///
/// Opened as a fullscreen route; cancel with the ✕ in the app bar. The picked
/// image is encoded as a base64 data URI and stored in the receipt (matching
/// the old app), so it works on web and Android alike.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';
import 'receipt_image.dart';

/// Opens the add/edit form as a full page. Pass [initial] to edit; omit to add.
Future<void> showProductForm(BuildContext context, {Product? initial}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ProductFormScreen(initial: initial),
    ),
  );
}

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.initial});

  final Product? initial;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _location;
  late final TextEditingController _shopName;
  late final TextEditingController _shopPhoneNumber;
  late final TextEditingController _purchaseDate;
  late final TextEditingController _months;
  late final TextEditingController _notes;
  late String _category;

  ReceiptFile? _receipt;
  String? _localImageUri;
  String? _visitingCardUri;
  String? _warrantyCardUri;
  String? _productImageUri;
  bool _saving = false;
  String? _error;
  List<String> _locations = ['Home', 'Office'];

  bool get _isEdit => widget.initial != null;

  String _todayIso() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p?.productName ?? '');
    _brand = TextEditingController(text: p?.brand ?? '');
    _location = TextEditingController(text: p?.location ?? '');
    _shopName = TextEditingController(text: p?.shopName ?? '');
    _shopPhoneNumber = TextEditingController(text: p?.shopPhoneNumber ?? '');
    _notes = TextEditingController(text: p?.notes ?? '');
    final purchase = (p?.purchaseDate ?? '');
    _purchaseDate = TextEditingController(
      text: purchase.isNotEmpty ? purchase.substring(0, 10) : _todayIso(),
    );
    _months = TextEditingController(
      text: (p?.warrantyDurationMonths ?? 12).toString(),
    );
    _category = p?.category ?? kCategories.first;
    _receipt = p?.receipt;
    _productImageUri = p?.productImage?.uri;
    _loadLocations(p?.location);
  }

  Future<void> _loadLocations([String? existingLocation]) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('locations');
    final locations = saved ?? ['Home', 'Office'];
    // Add existing location if editing and not already in list
    if (existingLocation != null && existingLocation.isNotEmpty && !locations.contains(existingLocation)) {
      locations.add(existingLocation);
    }
    if (mounted) {
      setState(() => _locations = locations);
    }
  }

  Future<void> _saveLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('locations', _locations);
  }

  Future<void> _addNewLocation(String location) async {
    if (location.trim().isEmpty || _locations.contains(location.trim())) return;
    setState(() => _locations.add(location.trim()));
    _location.text = location.trim();
    await _saveLocations();
  }

  void _showAddLocationDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Bedroom, Living Room',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _addNewLocation(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _location.dispose();
    _shopName.dispose();
    _shopPhoneNumber.dispose();
    _purchaseDate.dispose();
    _months.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required String type, ImageSource source = ImageSource.gallery}) async {
    setState(() => _error = null);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: type == 'product' ? 80 : 70,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final mime = file.mimeType ?? _guessMime(file.name);
      final uri = 'data:$mime;base64,${base64Encode(bytes)}';
      setState(() {
        if (type == 'receipt') {
          _localImageUri = uri;
        } else if (type == 'visiting') {
          _visitingCardUri = uri;
        } else if (type == 'warranty') {
          _warrantyCardUri = uri;
        } else if (type == 'product') {
          _productImageUri = uri;
        }
      });
    } catch (e) {
      setState(() => _error = 'Could not load image: $e');
    }
  }

  String _guessMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a product name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var finalReceipt = _receipt;
      if (_localImageUri != null) {
        finalReceipt = ReceiptFile(
          uri: _localImageUri!,
          fileType: 'image',
          thumbnailUri: _localImageUri,
        );
      }

      var finalVisitingCard = widget.initial?.visitingCard;
      if (_visitingCardUri != null) {
        finalVisitingCard = ReceiptFile(
          uri: _visitingCardUri!,
          fileType: 'image',
          thumbnailUri: _visitingCardUri,
        );
      }

      var finalWarrantyCard = widget.initial?.warrantyCard;
      if (_warrantyCardUri != null) {
        finalWarrantyCard = ReceiptFile(
          uri: _warrantyCardUri!,
          fileType: 'image',
          thumbnailUri: _warrantyCardUri,
        );
      }

      var finalProductImage = widget.initial?.productImage;
      if (_productImageUri != null) {
        finalProductImage = ReceiptFile(
          uri: _productImageUri!,
          fileType: 'image',
          thumbnailUri: _productImageUri,
        );
      }

      final purchaseIso = DateTime.parse(
        _purchaseDate.text.trim(),
      ).toUtc().toIso8601String();

      final input = ProductInput(
        productName: name,
        brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        category: _category,
        purchaseDate: purchaseIso,
        warrantyDurationMonths: int.tryParse(_months.text.trim()) ?? 12,
        serialNumber: widget.initial?.serialNumber,
        modelNumber: widget.initial?.modelNumber,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        receipt: finalReceipt,
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        shopName: _shopName.text.trim().isEmpty ? null : _shopName.text.trim(),
        shopPhoneNumber: _shopPhoneNumber.text.trim().isEmpty ? null : _shopPhoneNumber.text.trim(),
        visitingCard: finalVisitingCard,
        warrantyCard: finalWarrantyCard,
        productImage: finalProductImage,
      );

      if (_isEdit) {
        await productService.updateProduct(widget.initial!.id, input);
      } else {
        await productService.createProduct(input);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete warranty?'),
        content: Text(
          'Permanently delete "${widget.initial!.productName}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await productService.deleteProduct(widget.initial!.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewUri = _localImageUri ?? _receipt?.uri;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: kInk,
            size: 22,
          ),
        ),
        title: Text(_isEdit ? 'Edit Warranty' : 'Add Warranty'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Delete',
              onPressed: _saving ? null : _delete,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: const Color(0xFFDC2626),
                size: 22,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Receipt Section at the top
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFile01,
                      color: const Color(0xFFB0B9C8),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload Receipt',
                      style: TextStyle(
                        color: kInk,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Scan or upload receipt for automatic extraction',
                      style: TextStyle(color: kMuted, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    if (previewUri != null && previewUri.isNotEmpty) ...[
                      ReceiptImage(
                        uri: previewUri,
                        width: 120,
                        height: 120,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton(
                      onPressed: () => _pickImage(type: 'receipt'),
                      child: const Text('Upload Receipt'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Extracted Information
              const Text(
                'Extracted Information',
                style: TextStyle(
                  color: kInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _FormField(
                label: 'Product Name',
                controller: _name,
                hint: 'Samsung Smart TV',
              ),
              _FormField(label: 'Brand', controller: _brand, hint: 'Samsung'),
              // Purchase Date and Warranty in a row
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Purchase Date',
                      controller: _purchaseDate,
                      hint: '2025-06-10',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      label: 'Warranty',
                      controller: _months,
                      hint: '12 Months',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              // Category with icon buttons
              const SizedBox(height: 12),
              const Text(
                'Category',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final cat = kCategories[i];
                    final selected = _category == cat;
                    return _CategoryButton(
                      label: cat,
                      icon: kCategoryIcons[cat]!,
                      selected: selected,
                      onTap: () => setState(() => _category = cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Location Dropdown
              const Text(
                'Location',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  value: _location.text.isEmpty
                      ? _locations.first
                      : _location.text,
                  items: [
                    ..._locations.map(
                      (e) => DropdownMenuItem(value: e, child: Text(e)),
                    ),
                    DropdownMenuItem(
                      value: '__add__',
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedAdd01,
                            color: kPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Add new location',
                            style: TextStyle(color: kPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == '__add__') {
                      _showAddLocationDialog();
                    } else if (v != null) {
                      setState(() => _location.text = v);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Shop Information
              const Text(
                'Shop Information',
                style: TextStyle(
                  color: kInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _FormField(
                label: 'Shop Name',
                controller: _shopName,
                hint: 'Electronics Store',
              ),
              _FormField(
                label: 'Shop Phone',
                controller: _shopPhoneNumber,
                hint: '+1 234 567 8900',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              // Product Photo Section
              const Text(
                'Product Photo',
                style: TextStyle(
                  color: kInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _ProductPhotoSection(
                imageUri: _productImageUri,
                onCamera: () => _pickImage(type: 'product', source: ImageSource.camera),
                onGallery: () => _pickImage(type: 'product', source: ImageSource.gallery),
              ),
              const SizedBox(height: 24),
              // Additional Documents
              const Text(
                'Additional Documents',
                style: TextStyle(
                  color: kInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _ExpandableDocumentItem(
                title: 'Warranty Card',
                onAdd: () => _pickImage(type: 'warranty'),
                hasImage: _warrantyCardUri != null,
                imageUri: _warrantyCardUri,
              ),
              const SizedBox(height: 8),
              _ExpandableDocumentItem(
                title: 'Visiting Card',
                onAdd: () => _pickImage(type: 'visiting'),
                hasImage: _visitingCardUri != null,
                imageUri: _visitingCardUri,
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedAlertCircle,
                      color: const Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFFDC2626)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Save Changes' : 'Save Warranty',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label shown above a form field.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: kInk,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A labelled, comfortably-sized text field.
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: kInk),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Category button with icon.
class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final List<List<dynamic>> icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? kPrimary : const Color(0xFFE2E8F0),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? kPrimary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon,
              color: selected ? kPrimary : kMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label.split(' ').first,
              style: TextStyle(
                fontSize: 10,
                color: selected ? kPrimary : kMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Expandable document item (e.g., Warranty Card, Visiting Card).
class _ExpandableDocumentItem extends StatelessWidget {
  const _ExpandableDocumentItem({
    required this.title,
    required this.onAdd,
    required this.hasImage,
    this.imageUri,
  });

  final String title;
  final VoidCallback onAdd;
  final bool hasImage;
  final String? imageUri;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style:
                            const TextStyle(color: kInk, fontSize: 14)),
                    const Spacer(),
                    if (hasImage)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '✓ Added',
                          style: TextStyle(
                            color: kPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedAdd01,
                        color: kPrimary,
                        size: 20,
                      ),
                  ],
                ),
                if (hasImage && imageUri != null && imageUri!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ReceiptImage(
                    uri: imageUri!,
                    width: 100,
                    height: 100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Product photo section with camera and gallery options.
class _ProductPhotoSection extends StatelessWidget {
  const _ProductPhotoSection({
    required this.imageUri,
    required this.onCamera,
    required this.onGallery,
  });

  final String? imageUri;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUri != null && imageUri!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (hasImage) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: ReceiptImage(
                uri: imageUri!,
                width: double.infinity,
                height: 200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCamera,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCamera01,
                        color: kPrimary,
                        size: 18,
                      ),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side: const BorderSide(color: kPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onGallery,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedImage02,
                        color: kPrimary,
                        size: 18,
                      ),
                      label: const Text('Change'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side: const BorderSide(color: kPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedImage01,
                    color: const Color(0xFFB0B9C8),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add Product Photo',
                    style: TextStyle(
                      color: kInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Take a photo or select from gallery',
                    style: TextStyle(color: kMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onCamera,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedCamera01,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onGallery,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedImage02,
                            color: kPrimary,
                            size: 18,
                          ),
                          label: const Text('Gallery'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimary,
                            side: const BorderSide(color: kPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
