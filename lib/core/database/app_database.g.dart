// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WarrantiesTable extends Warranties
    with TableInfo<$WarrantiesTable, WarrantyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarrantiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warrantyMonthsMeta = const VerificationMeta(
    'warrantyMonths',
  );
  @override
  late final GeneratedColumn<int> warrantyMonths = GeneratedColumn<int>(
    'warranty_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeNameMeta = const VerificationMeta(
    'storeName',
  );
  @override
  late final GeneratedColumn<String> storeName = GeneratedColumn<String>(
    'store_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productName,
    category,
    purchaseDate,
    warrantyMonths,
    expiryDate,
    storeName,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warranties';
  @override
  VerificationContext validateIntegrity(
    Insertable<WarrantyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('warranty_months')) {
      context.handle(
        _warrantyMonthsMeta,
        warrantyMonths.isAcceptableOrUnknown(
          data['warranty_months']!,
          _warrantyMonthsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warrantyMonthsMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('store_name')) {
      context.handle(
        _storeNameMeta,
        storeName.isAcceptableOrUnknown(data['store_name']!, _storeNameMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WarrantyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WarrantyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      warrantyMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warranty_months'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      storeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WarrantiesTable createAlias(String alias) {
    return $WarrantiesTable(attachedDatabase, alias);
  }
}

class WarrantyRow extends DataClass implements Insertable<WarrantyRow> {
  final String id;
  final String productName;
  final String category;
  final DateTime purchaseDate;
  final int warrantyMonths;
  final DateTime expiryDate;
  final String? storeName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WarrantyRow({
    required this.id,
    required this.productName,
    required this.category,
    required this.purchaseDate,
    required this.warrantyMonths,
    required this.expiryDate,
    this.storeName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_name'] = Variable<String>(productName);
    map['category'] = Variable<String>(category);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['warranty_months'] = Variable<int>(warrantyMonths);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    if (!nullToAbsent || storeName != null) {
      map['store_name'] = Variable<String>(storeName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WarrantiesCompanion toCompanion(bool nullToAbsent) {
    return WarrantiesCompanion(
      id: Value(id),
      productName: Value(productName),
      category: Value(category),
      purchaseDate: Value(purchaseDate),
      warrantyMonths: Value(warrantyMonths),
      expiryDate: Value(expiryDate),
      storeName: storeName == null && nullToAbsent
          ? const Value.absent()
          : Value(storeName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WarrantyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WarrantyRow(
      id: serializer.fromJson<String>(json['id']),
      productName: serializer.fromJson<String>(json['productName']),
      category: serializer.fromJson<String>(json['category']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      warrantyMonths: serializer.fromJson<int>(json['warrantyMonths']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      storeName: serializer.fromJson<String?>(json['storeName']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productName': serializer.toJson<String>(productName),
      'category': serializer.toJson<String>(category),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'warrantyMonths': serializer.toJson<int>(warrantyMonths),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'storeName': serializer.toJson<String?>(storeName),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WarrantyRow copyWith({
    String? id,
    String? productName,
    String? category,
    DateTime? purchaseDate,
    int? warrantyMonths,
    DateTime? expiryDate,
    Value<String?> storeName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WarrantyRow(
    id: id ?? this.id,
    productName: productName ?? this.productName,
    category: category ?? this.category,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    warrantyMonths: warrantyMonths ?? this.warrantyMonths,
    expiryDate: expiryDate ?? this.expiryDate,
    storeName: storeName.present ? storeName.value : this.storeName,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WarrantyRow copyWithCompanion(WarrantiesCompanion data) {
    return WarrantyRow(
      id: data.id.present ? data.id.value : this.id,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      category: data.category.present ? data.category.value : this.category,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      warrantyMonths: data.warrantyMonths.present
          ? data.warrantyMonths.value
          : this.warrantyMonths,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      storeName: data.storeName.present ? data.storeName.value : this.storeName,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WarrantyRow(')
          ..write('id: $id, ')
          ..write('productName: $productName, ')
          ..write('category: $category, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('warrantyMonths: $warrantyMonths, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('storeName: $storeName, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productName,
    category,
    purchaseDate,
    warrantyMonths,
    expiryDate,
    storeName,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WarrantyRow &&
          other.id == this.id &&
          other.productName == this.productName &&
          other.category == this.category &&
          other.purchaseDate == this.purchaseDate &&
          other.warrantyMonths == this.warrantyMonths &&
          other.expiryDate == this.expiryDate &&
          other.storeName == this.storeName &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WarrantiesCompanion extends UpdateCompanion<WarrantyRow> {
  final Value<String> id;
  final Value<String> productName;
  final Value<String> category;
  final Value<DateTime> purchaseDate;
  final Value<int> warrantyMonths;
  final Value<DateTime> expiryDate;
  final Value<String?> storeName;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WarrantiesCompanion({
    this.id = const Value.absent(),
    this.productName = const Value.absent(),
    this.category = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.warrantyMonths = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.storeName = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WarrantiesCompanion.insert({
    required String id,
    required String productName,
    required String category,
    required DateTime purchaseDate,
    required int warrantyMonths,
    required DateTime expiryDate,
    this.storeName = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productName = Value(productName),
       category = Value(category),
       purchaseDate = Value(purchaseDate),
       warrantyMonths = Value(warrantyMonths),
       expiryDate = Value(expiryDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WarrantyRow> custom({
    Expression<String>? id,
    Expression<String>? productName,
    Expression<String>? category,
    Expression<DateTime>? purchaseDate,
    Expression<int>? warrantyMonths,
    Expression<DateTime>? expiryDate,
    Expression<String>? storeName,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productName != null) 'product_name': productName,
      if (category != null) 'category': category,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (storeName != null) 'store_name': storeName,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WarrantiesCompanion copyWith({
    Value<String>? id,
    Value<String>? productName,
    Value<String>? category,
    Value<DateTime>? purchaseDate,
    Value<int>? warrantyMonths,
    Value<DateTime>? expiryDate,
    Value<String?>? storeName,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WarrantiesCompanion(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      expiryDate: expiryDate ?? this.expiryDate,
      storeName: storeName ?? this.storeName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (warrantyMonths.present) {
      map['warranty_months'] = Variable<int>(warrantyMonths.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (storeName.present) {
      map['store_name'] = Variable<String>(storeName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarrantiesCompanion(')
          ..write('id: $id, ')
          ..write('productName: $productName, ')
          ..write('category: $category, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('warrantyMonths: $warrantyMonths, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('storeName: $storeName, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTable extends Receipts
    with TableInfo<$ReceiptsTable, ReceiptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warrantyIdMeta = const VerificationMeta(
    'warrantyId',
  );
  @override
  late final GeneratedColumn<String> warrantyId = GeneratedColumn<String>(
    'warranty_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES warranties (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, warrantyId, filePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('warranty_id')) {
      context.handle(
        _warrantyIdMeta,
        warrantyId.isAcceptableOrUnknown(data['warranty_id']!, _warrantyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_warrantyIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      warrantyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warranty_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }
}

class ReceiptRow extends DataClass implements Insertable<ReceiptRow> {
  final String id;
  final String warrantyId;
  final String filePath;
  final DateTime createdAt;
  const ReceiptRow({
    required this.id,
    required this.warrantyId,
    required this.filePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['warranty_id'] = Variable<String>(warrantyId);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsCompanion(
      id: Value(id),
      warrantyId: Value(warrantyId),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
    );
  }

  factory ReceiptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptRow(
      id: serializer.fromJson<String>(json['id']),
      warrantyId: serializer.fromJson<String>(json['warrantyId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'warrantyId': serializer.toJson<String>(warrantyId),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReceiptRow copyWith({
    String? id,
    String? warrantyId,
    String? filePath,
    DateTime? createdAt,
  }) => ReceiptRow(
    id: id ?? this.id,
    warrantyId: warrantyId ?? this.warrantyId,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
  );
  ReceiptRow copyWithCompanion(ReceiptsCompanion data) {
    return ReceiptRow(
      id: data.id.present ? data.id.value : this.id,
      warrantyId: data.warrantyId.present
          ? data.warrantyId.value
          : this.warrantyId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptRow(')
          ..write('id: $id, ')
          ..write('warrantyId: $warrantyId, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, warrantyId, filePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptRow &&
          other.id == this.id &&
          other.warrantyId == this.warrantyId &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt);
}

class ReceiptsCompanion extends UpdateCompanion<ReceiptRow> {
  final Value<String> id;
  final Value<String> warrantyId;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReceiptsCompanion({
    this.id = const Value.absent(),
    this.warrantyId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    required String id,
    required String warrantyId,
    required String filePath,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       warrantyId = Value(warrantyId),
       filePath = Value(filePath),
       createdAt = Value(createdAt);
  static Insertable<ReceiptRow> custom({
    Expression<String>? id,
    Expression<String>? warrantyId,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (warrantyId != null) 'warranty_id': warrantyId,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceiptsCompanion copyWith({
    Value<String>? id,
    Value<String>? warrantyId,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReceiptsCompanion(
      id: id ?? this.id,
      warrantyId: warrantyId ?? this.warrantyId,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (warrantyId.present) {
      map['warranty_id'] = Variable<String>(warrantyId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('warrantyId: $warrantyId, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledNotificationsTable extends ScheduledNotifications
    with TableInfo<$ScheduledNotificationsTable, ScheduledNotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warrantyIdMeta = const VerificationMeta(
    'warrantyId',
  );
  @override
  late final GeneratedColumn<String> warrantyId = GeneratedColumn<String>(
    'warranty_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES warranties (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<DateTime> fireAt = GeneratedColumn<DateTime>(
    'fire_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, warrantyId, fireAt, kind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduledNotificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('warranty_id')) {
      context.handle(
        _warrantyIdMeta,
        warrantyId.isAcceptableOrUnknown(data['warranty_id']!, _warrantyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_warrantyIdMeta);
    }
    if (data.containsKey('fire_at')) {
      context.handle(
        _fireAtMeta,
        fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledNotificationRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledNotificationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      warrantyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warranty_id'],
      )!,
      fireAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fire_at'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $ScheduledNotificationsTable createAlias(String alias) {
    return $ScheduledNotificationsTable(attachedDatabase, alias);
  }
}

class ScheduledNotificationRow extends DataClass
    implements Insertable<ScheduledNotificationRow> {
  /// The OS notification id (also the primary key).
  final int id;
  final String warrantyId;
  final DateTime fireAt;

  /// Which reminder this is: 'd30' | 'd7' | 'expiry'.
  final String kind;
  const ScheduledNotificationRow({
    required this.id,
    required this.warrantyId,
    required this.fireAt,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['warranty_id'] = Variable<String>(warrantyId);
    map['fire_at'] = Variable<DateTime>(fireAt);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  ScheduledNotificationsCompanion toCompanion(bool nullToAbsent) {
    return ScheduledNotificationsCompanion(
      id: Value(id),
      warrantyId: Value(warrantyId),
      fireAt: Value(fireAt),
      kind: Value(kind),
    );
  }

  factory ScheduledNotificationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledNotificationRow(
      id: serializer.fromJson<int>(json['id']),
      warrantyId: serializer.fromJson<String>(json['warrantyId']),
      fireAt: serializer.fromJson<DateTime>(json['fireAt']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'warrantyId': serializer.toJson<String>(warrantyId),
      'fireAt': serializer.toJson<DateTime>(fireAt),
      'kind': serializer.toJson<String>(kind),
    };
  }

  ScheduledNotificationRow copyWith({
    int? id,
    String? warrantyId,
    DateTime? fireAt,
    String? kind,
  }) => ScheduledNotificationRow(
    id: id ?? this.id,
    warrantyId: warrantyId ?? this.warrantyId,
    fireAt: fireAt ?? this.fireAt,
    kind: kind ?? this.kind,
  );
  ScheduledNotificationRow copyWithCompanion(
    ScheduledNotificationsCompanion data,
  ) {
    return ScheduledNotificationRow(
      id: data.id.present ? data.id.value : this.id,
      warrantyId: data.warrantyId.present
          ? data.warrantyId.value
          : this.warrantyId,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledNotificationRow(')
          ..write('id: $id, ')
          ..write('warrantyId: $warrantyId, ')
          ..write('fireAt: $fireAt, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, warrantyId, fireAt, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledNotificationRow &&
          other.id == this.id &&
          other.warrantyId == this.warrantyId &&
          other.fireAt == this.fireAt &&
          other.kind == this.kind);
}

class ScheduledNotificationsCompanion
    extends UpdateCompanion<ScheduledNotificationRow> {
  final Value<int> id;
  final Value<String> warrantyId;
  final Value<DateTime> fireAt;
  final Value<String> kind;
  const ScheduledNotificationsCompanion({
    this.id = const Value.absent(),
    this.warrantyId = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.kind = const Value.absent(),
  });
  ScheduledNotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String warrantyId,
    required DateTime fireAt,
    required String kind,
  }) : warrantyId = Value(warrantyId),
       fireAt = Value(fireAt),
       kind = Value(kind);
  static Insertable<ScheduledNotificationRow> custom({
    Expression<int>? id,
    Expression<String>? warrantyId,
    Expression<DateTime>? fireAt,
    Expression<String>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (warrantyId != null) 'warranty_id': warrantyId,
      if (fireAt != null) 'fire_at': fireAt,
      if (kind != null) 'kind': kind,
    });
  }

  ScheduledNotificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? warrantyId,
    Value<DateTime>? fireAt,
    Value<String>? kind,
  }) {
    return ScheduledNotificationsCompanion(
      id: id ?? this.id,
      warrantyId: warrantyId ?? this.warrantyId,
      fireAt: fireAt ?? this.fireAt,
      kind: kind ?? this.kind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (warrantyId.present) {
      map['warranty_id'] = Variable<String>(warrantyId.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<DateTime>(fireAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('warrantyId: $warrantyId, ')
          ..write('fireAt: $fireAt, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WarrantiesTable warranties = $WarrantiesTable(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final $ScheduledNotificationsTable scheduledNotifications =
      $ScheduledNotificationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    warranties,
    receipts,
    scheduledNotifications,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'warranties',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('receipts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'warranties',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scheduled_notifications', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WarrantiesTableCreateCompanionBuilder =
    WarrantiesCompanion Function({
      required String id,
      required String productName,
      required String category,
      required DateTime purchaseDate,
      required int warrantyMonths,
      required DateTime expiryDate,
      Value<String?> storeName,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WarrantiesTableUpdateCompanionBuilder =
    WarrantiesCompanion Function({
      Value<String> id,
      Value<String> productName,
      Value<String> category,
      Value<DateTime> purchaseDate,
      Value<int> warrantyMonths,
      Value<DateTime> expiryDate,
      Value<String?> storeName,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WarrantiesTableReferences
    extends BaseReferences<_$AppDatabase, $WarrantiesTable, WarrantyRow> {
  $$WarrantiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReceiptsTable, List<ReceiptRow>>
  _receiptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.receipts,
    aliasName: $_aliasNameGenerator(db.warranties.id, db.receipts.warrantyId),
  );

  $$ReceiptsTableProcessedTableManager get receiptsRefs {
    final manager = $$ReceiptsTableTableManager(
      $_db,
      $_db.receipts,
    ).filter((f) => f.warrantyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ScheduledNotificationsTable,
    List<ScheduledNotificationRow>
  >
  _scheduledNotificationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduledNotifications,
        aliasName: $_aliasNameGenerator(
          db.warranties.id,
          db.scheduledNotifications.warrantyId,
        ),
      );

  $$ScheduledNotificationsTableProcessedTableManager
  get scheduledNotificationsRefs {
    final manager = $$ScheduledNotificationsTableTableManager(
      $_db,
      $_db.scheduledNotifications,
    ).filter((f) => f.warrantyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduledNotificationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WarrantiesTableFilterComposer
    extends Composer<_$AppDatabase, $WarrantiesTable> {
  $$WarrantiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warrantyMonths => $composableBuilder(
    column: $table.warrantyMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeName => $composableBuilder(
    column: $table.storeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> receiptsRefs(
    Expression<bool> Function($$ReceiptsTableFilterComposer f) f,
  ) {
    final $$ReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.warrantyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scheduledNotificationsRefs(
    Expression<bool> Function($$ScheduledNotificationsTableFilterComposer f) f,
  ) {
    final $$ScheduledNotificationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduledNotifications,
          getReferencedColumn: (t) => t.warrantyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduledNotificationsTableFilterComposer(
                $db: $db,
                $table: $db.scheduledNotifications,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WarrantiesTableOrderingComposer
    extends Composer<_$AppDatabase, $WarrantiesTable> {
  $$WarrantiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warrantyMonths => $composableBuilder(
    column: $table.warrantyMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeName => $composableBuilder(
    column: $table.storeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WarrantiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarrantiesTable> {
  $$WarrantiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warrantyMonths => $composableBuilder(
    column: $table.warrantyMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storeName =>
      $composableBuilder(column: $table.storeName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> receiptsRefs<T extends Object>(
    Expression<T> Function($$ReceiptsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.warrantyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scheduledNotificationsRefs<T extends Object>(
    Expression<T> Function($$ScheduledNotificationsTableAnnotationComposer a) f,
  ) {
    final $$ScheduledNotificationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduledNotifications,
          getReferencedColumn: (t) => t.warrantyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduledNotificationsTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduledNotifications,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WarrantiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WarrantiesTable,
          WarrantyRow,
          $$WarrantiesTableFilterComposer,
          $$WarrantiesTableOrderingComposer,
          $$WarrantiesTableAnnotationComposer,
          $$WarrantiesTableCreateCompanionBuilder,
          $$WarrantiesTableUpdateCompanionBuilder,
          (WarrantyRow, $$WarrantiesTableReferences),
          WarrantyRow,
          PrefetchHooks Function({
            bool receiptsRefs,
            bool scheduledNotificationsRefs,
          })
        > {
  $$WarrantiesTableTableManager(_$AppDatabase db, $WarrantiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarrantiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarrantiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarrantiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<int> warrantyMonths = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<String?> storeName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WarrantiesCompanion(
                id: id,
                productName: productName,
                category: category,
                purchaseDate: purchaseDate,
                warrantyMonths: warrantyMonths,
                expiryDate: expiryDate,
                storeName: storeName,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productName,
                required String category,
                required DateTime purchaseDate,
                required int warrantyMonths,
                required DateTime expiryDate,
                Value<String?> storeName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WarrantiesCompanion.insert(
                id: id,
                productName: productName,
                category: category,
                purchaseDate: purchaseDate,
                warrantyMonths: warrantyMonths,
                expiryDate: expiryDate,
                storeName: storeName,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WarrantiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({receiptsRefs = false, scheduledNotificationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (receiptsRefs) db.receipts,
                    if (scheduledNotificationsRefs) db.scheduledNotifications,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (receiptsRefs)
                        await $_getPrefetchedData<
                          WarrantyRow,
                          $WarrantiesTable,
                          ReceiptRow
                        >(
                          currentTable: table,
                          referencedTable: $$WarrantiesTableReferences
                              ._receiptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WarrantiesTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.warrantyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scheduledNotificationsRefs)
                        await $_getPrefetchedData<
                          WarrantyRow,
                          $WarrantiesTable,
                          ScheduledNotificationRow
                        >(
                          currentTable: table,
                          referencedTable: $$WarrantiesTableReferences
                              ._scheduledNotificationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WarrantiesTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduledNotificationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.warrantyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WarrantiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WarrantiesTable,
      WarrantyRow,
      $$WarrantiesTableFilterComposer,
      $$WarrantiesTableOrderingComposer,
      $$WarrantiesTableAnnotationComposer,
      $$WarrantiesTableCreateCompanionBuilder,
      $$WarrantiesTableUpdateCompanionBuilder,
      (WarrantyRow, $$WarrantiesTableReferences),
      WarrantyRow,
      PrefetchHooks Function({
        bool receiptsRefs,
        bool scheduledNotificationsRefs,
      })
    >;
typedef $$ReceiptsTableCreateCompanionBuilder =
    ReceiptsCompanion Function({
      required String id,
      required String warrantyId,
      required String filePath,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ReceiptsTableUpdateCompanionBuilder =
    ReceiptsCompanion Function({
      Value<String> id,
      Value<String> warrantyId,
      Value<String> filePath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ReceiptsTableReferences
    extends BaseReferences<_$AppDatabase, $ReceiptsTable, ReceiptRow> {
  $$ReceiptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WarrantiesTable _warrantyIdTable(_$AppDatabase db) =>
      db.warranties.createAlias(
        $_aliasNameGenerator(db.receipts.warrantyId, db.warranties.id),
      );

  $$WarrantiesTableProcessedTableManager get warrantyId {
    final $_column = $_itemColumn<String>('warranty_id')!;

    final manager = $$WarrantiesTableTableManager(
      $_db,
      $_db.warranties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_warrantyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WarrantiesTableFilterComposer get warrantyId {
    final $$WarrantiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.warrantyId,
      referencedTable: $db.warranties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantiesTableFilterComposer(
            $db: $db,
            $table: $db.warranties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WarrantiesTableOrderingComposer get warrantyId {
    final $$WarrantiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.warrantyId,
      referencedTable: $db.warranties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantiesTableOrderingComposer(
            $db: $db,
            $table: $db.warranties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WarrantiesTableAnnotationComposer get warrantyId {
    final $$WarrantiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.warrantyId,
      referencedTable: $db.warranties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantiesTableAnnotationComposer(
            $db: $db,
            $table: $db.warranties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptsTable,
          ReceiptRow,
          $$ReceiptsTableFilterComposer,
          $$ReceiptsTableOrderingComposer,
          $$ReceiptsTableAnnotationComposer,
          $$ReceiptsTableCreateCompanionBuilder,
          $$ReceiptsTableUpdateCompanionBuilder,
          (ReceiptRow, $$ReceiptsTableReferences),
          ReceiptRow,
          PrefetchHooks Function({bool warrantyId})
        > {
  $$ReceiptsTableTableManager(_$AppDatabase db, $ReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> warrantyId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsCompanion(
                id: id,
                warrantyId: warrantyId,
                filePath: filePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String warrantyId,
                required String filePath,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsCompanion.insert(
                id: id,
                warrantyId: warrantyId,
                filePath: filePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReceiptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({warrantyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (warrantyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.warrantyId,
                                referencedTable: $$ReceiptsTableReferences
                                    ._warrantyIdTable(db),
                                referencedColumn: $$ReceiptsTableReferences
                                    ._warrantyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptsTable,
      ReceiptRow,
      $$ReceiptsTableFilterComposer,
      $$ReceiptsTableOrderingComposer,
      $$ReceiptsTableAnnotationComposer,
      $$ReceiptsTableCreateCompanionBuilder,
      $$ReceiptsTableUpdateCompanionBuilder,
      (ReceiptRow, $$ReceiptsTableReferences),
      ReceiptRow,
      PrefetchHooks Function({bool warrantyId})
    >;
typedef $$ScheduledNotificationsTableCreateCompanionBuilder =
    ScheduledNotificationsCompanion Function({
      Value<int> id,
      required String warrantyId,
      required DateTime fireAt,
      required String kind,
    });
typedef $$ScheduledNotificationsTableUpdateCompanionBuilder =
    ScheduledNotificationsCompanion Function({
      Value<int> id,
      Value<String> warrantyId,
      Value<DateTime> fireAt,
      Value<String> kind,
    });

final class $$ScheduledNotificationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScheduledNotificationsTable,
          ScheduledNotificationRow
        > {
  $$ScheduledNotificationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WarrantiesTable _warrantyIdTable(_$AppDatabase db) =>
      db.warranties.createAlias(
        $_aliasNameGenerator(
          db.scheduledNotifications.warrantyId,
          db.warranties.id,
        ),
      );

  $$WarrantiesTableProcessedTableManager get warrantyId {
    final $_column = $_itemColumn<String>('warranty_id')!;

    final manager = $$WarrantiesTableTableManager(
      $_db,
      $_db.warranties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_warrantyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduledNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledNotificationsTable> {
  $$ScheduledNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  $$WarrantiesTableFilterComposer get warrantyId {
    final $$WarrantiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.warrantyId,
      referencedTable: $db.warranties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantiesTableFilterComposer(
            $db: $db,
            $table: $db.warranties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledNotificationsTable> {
  $$ScheduledNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$WarrantiesTableOrderingComposer get warrantyId {
    final $$WarrantiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.warrantyId,
      referencedTable: $db.warranties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantiesTableOrderingComposer(
            $db: $db,
            $table: $db.warranties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledNotificationsTable> {
  $$ScheduledNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$WarrantiesTableAnnotationComposer get warrantyId {
    final $$WarrantiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.warrantyId,
      referencedTable: $db.warranties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantiesTableAnnotationComposer(
            $db: $db,
            $table: $db.warranties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduledNotificationsTable,
          ScheduledNotificationRow,
          $$ScheduledNotificationsTableFilterComposer,
          $$ScheduledNotificationsTableOrderingComposer,
          $$ScheduledNotificationsTableAnnotationComposer,
          $$ScheduledNotificationsTableCreateCompanionBuilder,
          $$ScheduledNotificationsTableUpdateCompanionBuilder,
          (ScheduledNotificationRow, $$ScheduledNotificationsTableReferences),
          ScheduledNotificationRow,
          PrefetchHooks Function({bool warrantyId})
        > {
  $$ScheduledNotificationsTableTableManager(
    _$AppDatabase db,
    $ScheduledNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledNotificationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScheduledNotificationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduledNotificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> warrantyId = const Value.absent(),
                Value<DateTime> fireAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => ScheduledNotificationsCompanion(
                id: id,
                warrantyId: warrantyId,
                fireAt: fireAt,
                kind: kind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String warrantyId,
                required DateTime fireAt,
                required String kind,
              }) => ScheduledNotificationsCompanion.insert(
                id: id,
                warrantyId: warrantyId,
                fireAt: fireAt,
                kind: kind,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduledNotificationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({warrantyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (warrantyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.warrantyId,
                                referencedTable:
                                    $$ScheduledNotificationsTableReferences
                                        ._warrantyIdTable(db),
                                referencedColumn:
                                    $$ScheduledNotificationsTableReferences
                                        ._warrantyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScheduledNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduledNotificationsTable,
      ScheduledNotificationRow,
      $$ScheduledNotificationsTableFilterComposer,
      $$ScheduledNotificationsTableOrderingComposer,
      $$ScheduledNotificationsTableAnnotationComposer,
      $$ScheduledNotificationsTableCreateCompanionBuilder,
      $$ScheduledNotificationsTableUpdateCompanionBuilder,
      (ScheduledNotificationRow, $$ScheduledNotificationsTableReferences),
      ScheduledNotificationRow,
      PrefetchHooks Function({bool warrantyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WarrantiesTableTableManager get warranties =>
      $$WarrantiesTableTableManager(_db, _db.warranties);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
  $$ScheduledNotificationsTableTableManager get scheduledNotifications =>
      $$ScheduledNotificationsTableTableManager(
        _db,
        _db.scheduledNotifications,
      );
}
