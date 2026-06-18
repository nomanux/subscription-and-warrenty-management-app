/// Add/Edit warranty form — a full-screen page (not a modal).
///
/// Opened as a fullscreen route; cancel with the ✕ in the app bar. The picked
/// image is encoded as a base64 data URI and stored in the receipt (matching
/// the old app), so it works on web and Android alike.
library;

import 'dart:convert';

import 'package:flutter/material.dart' hide FormField;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/index.dart';
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
  late final TextEditingController _duration;
  late final TextEditingController _notes;
  late String _category;
  late String _durationUnit;

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
    _duration = TextEditingController(
      text: (p?.warrantyDurationMonths ?? 12).toString(),
    );
    _durationUnit = 'months';
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
    if (existingLocation != null &&
        existingLocation.isNotEmpty &&
        !locations.contains(existingLocation)) {
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
          decoration: InputDecoration(
            hintText: 'e.g., Bedroom, Living Room',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFCBD5E1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: kPrimary,
                width: 1.5,
              ),
            ),
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
    _duration.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickImage({
    required String type,
    ImageSource source = ImageSource.gallery,
  }) async {
    setState(() => _error = null);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (file == null) return;

      var bytes = await file.readAsBytes();

      // Attempt to compress on mobile platforms
      try {
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.path,
          '${file.path}_compressed.jpg',
          quality: 60,
          minWidth: 800,
          minHeight: 800,
        );
        if (compressedFile != null) {
          bytes = await compressedFile.readAsBytes();
        }
      } catch (e) {
        // Compression failed or on web - use original with lower quality
        // ImagePicker already applied 70% quality
      }

      // Image compressed and ready for upload

      final mime = _guessMime(file.name);
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
      setState(() => _error = 'Could not process image: $e');
    }
  }

  String _guessMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String _calculateExpiryDate() {
    try {
      final purchase = DateTime.parse(_purchaseDate.text.trim());
      final duration = int.tryParse(_duration.text.trim()) ?? 12;
      final months = _durationUnit == 'years' ? duration * 12 : duration;
      final expiry = purchase.add(Duration(days: months * 30));
      return DateFormat('d MMM, yyyy').format(expiry);
    } catch (_) {
      return 'Invalid date';
    }
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

      final durationValue = int.tryParse(_duration.text.trim()) ?? 12;
      final durationInMonths = _durationUnit == 'years'
          ? durationValue * 12
          : durationValue;

      final input = ProductInput(
        productName: name,
        brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        category: _category,
        purchaseDate: purchaseIso,
        warrantyDurationMonths: durationInMonths,
        serialNumber: widget.initial?.serialNumber,
        modelNumber: widget.initial?.modelNumber,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        receipt: finalReceipt,
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        shopName: _shopName.text.trim().isEmpty ? null : _shopName.text.trim(),
        shopPhoneNumber: _shopPhoneNumber.text.trim().isEmpty
            ? null
            : _shopPhoneNumber.text.trim(),
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
              // SECTION 1: Essential Details (Always Open)
              SectionHeader(
                icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                title: 'Essential Details',
                subtitle: 'Basic warranty information',
              ),
              const SizedBox(height: 16),
              FormField(
                label: 'What are you insuring? *',
                controller: _name,
                hint: 'e.g., Samsung Smart TV',
              ),
              FormField(
                label: 'Brand (optional)',
                controller: _brand,
                hint: 'e.g., Samsung',
              ),
              // Category with pill/chip design
              const Text(
                'Category *',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...List.generate(kCategories.length, (i) {
                      final cat = kCategories[i];
                      final selected = _category == cat;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: i == kCategories.length - 1 ? 0 : 8,
                        ),
                        child: CategoryPill(
                          label: cat,
                          icon: kCategoryIcons[cat]!,
                          selected: selected,
                          onTap: () => setState(() => _category = cat),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Location in main section
              const Text(
                'Where is it stored?',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              StandardDropdown<String>(
                value: _location.text.isEmpty ? _locations.first : _location.text,
                items: [
                  ..._locations.map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(e),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: '__add__',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
              const SizedBox(height: 16),
              // Purchase Date
              const Text(
                'When did you buy it? *',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DatePickerField(
                label: 'Purchase Date',
                controller: _purchaseDate,
              ),
              const SizedBox(height: 16),
              // Warranty Duration with Unit
              const Text(
                'How long is the warranty? *',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _duration,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14, color: kInk),
                      decoration: InputDecoration(
                        hintText: '12',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: kPrimary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: StandardDropdown<String>(
                      value: _durationUnit,
                      items: [
                        DropdownMenuItem(
                          value: 'months',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text('Months'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'years',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text('Years'),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _durationUnit = v);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Expiry Date Display (Auto-calculated)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kPrimary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedShield01,
                      color: kPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Warranty expires on',
                            style: TextStyle(
                              fontSize: 12,
                              color: kMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateExpiryDate(),
                            style: const TextStyle(
                              fontSize: 15,
                              color: kInk,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // SECTION 2: Shop & Location Info
              const SizedBox(height: 28),
              SectionHeader(
                icon: HugeIcons.strokeRoundedBuilding03,
                title: 'Shop & Location Info',
              ),
              const SizedBox(height: 16),
              FormField(
                label: 'Location (optional)',
                controller: _location,
                hint: 'e.g., Bedroom, Living Room',
              ),
              FormField(
                label: 'Shop name (optional)',
                controller: _shopName,
                hint: 'e.g., Electronics World',
              ),
              FormField(
                label: 'Shop phone (optional)',
                controller: _shopPhoneNumber,
                hint: '+1 234 567 8900',
                keyboardType: TextInputType.phone,
              ),
              FormField(
                label: 'Notes (optional)',
                controller: _notes,
                hint: 'Serial #, model, or other details...',
              ),
              const SizedBox(height: 32),
              // SECTION 3: Photos & Documents (Always Open)
              SectionHeader(
                icon: HugeIcons.strokeRoundedImage01,
                title: 'Photos & Documents',
              ),
              const SizedBox(height: 16),
              const Text(
                'Product Photo',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ProductPhotoSection(
                imageUri: _productImageUri,
                onCamera: () => _pickImage(
                  type: 'product',
                  source: ImageSource.camera,
                ),
                onGallery: () => _pickImage(
                  type: 'product',
                  source: ImageSource.gallery,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Warranty Card',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ExpandableDocumentItem(
                title: 'Warranty Card',
                onAdd: () => _pickImage(type: 'warranty'),
                hasImage: _warrantyCardUri != null,
                imageUri: _warrantyCardUri,
              ),
              const SizedBox(height: 20),
              const Text(
                'Receipt',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ExpandableDocumentItem(
                title: 'Receipt',
                onAdd: () => _pickImage(type: 'receipt'),
                hasImage: _localImageUri != null,
                imageUri: _localImageUri,
              ),
              const SizedBox(height: 20),
              const Text(
                'Other Documents',
                style: TextStyle(
                  color: kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ExpandableDocumentItem(
                title: 'Visiting Card / User Manual',
                onAdd: () => _pickImage(type: 'visiting'),
                hasImage: _visitingCardUri != null,
                imageUri: _visitingCardUri,
              ),
              const SizedBox(height: 28),
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
              // Save Button (Sticky at bottom)
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
