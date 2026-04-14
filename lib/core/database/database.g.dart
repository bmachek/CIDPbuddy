// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pznMeta = const VerificationMeta('pzn');
  @override
  late final GeneratedColumn<String> pzn = GeneratedColumn<String>(
    'pzn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<double> stock = GeneratedColumn<double>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _minStockMeta = const VerificationMeta(
    'minStock',
  );
  @override
  late final GeneratedColumn<double> minStock = GeneratedColumn<double>(
    'min_stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, pzn, stock, minStock, unit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pzn')) {
      context.handle(
        _pznMeta,
        pzn.isAcceptableOrUnknown(data['pzn']!, _pznMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('min_stock')) {
      context.handle(
        _minStockMeta,
        minStock.isAcceptableOrUnknown(data['min_stock']!, _minStockMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pzn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pzn'],
      ),
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock'],
      )!,
      minStock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_stock'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final String name;
  final String? pzn;
  final double stock;
  final double minStock;
  final String unit;
  const Medication({
    required this.id,
    required this.name,
    this.pzn,
    required this.stock,
    required this.minStock,
    required this.unit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || pzn != null) {
      map['pzn'] = Variable<String>(pzn);
    }
    map['stock'] = Variable<double>(stock);
    map['min_stock'] = Variable<double>(minStock);
    map['unit'] = Variable<String>(unit);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      pzn: pzn == null && nullToAbsent ? const Value.absent() : Value(pzn),
      stock: Value(stock),
      minStock: Value(minStock),
      unit: Value(unit),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      pzn: serializer.fromJson<String?>(json['pzn']),
      stock: serializer.fromJson<double>(json['stock']),
      minStock: serializer.fromJson<double>(json['minStock']),
      unit: serializer.fromJson<String>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'pzn': serializer.toJson<String?>(pzn),
      'stock': serializer.toJson<double>(stock),
      'minStock': serializer.toJson<double>(minStock),
      'unit': serializer.toJson<String>(unit),
    };
  }

  Medication copyWith({
    int? id,
    String? name,
    Value<String?> pzn = const Value.absent(),
    double? stock,
    double? minStock,
    String? unit,
  }) => Medication(
    id: id ?? this.id,
    name: name ?? this.name,
    pzn: pzn.present ? pzn.value : this.pzn,
    stock: stock ?? this.stock,
    minStock: minStock ?? this.minStock,
    unit: unit ?? this.unit,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      pzn: data.pzn.present ? data.pzn.value : this.pzn,
      stock: data.stock.present ? data.stock.value : this.stock,
      minStock: data.minStock.present ? data.minStock.value : this.minStock,
      unit: data.unit.present ? data.unit.value : this.unit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pzn: $pzn, ')
          ..write('stock: $stock, ')
          ..write('minStock: $minStock, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, pzn, stock, minStock, unit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.name == this.name &&
          other.pzn == this.pzn &&
          other.stock == this.stock &&
          other.minStock == this.minStock &&
          other.unit == this.unit);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> pzn;
  final Value<double> stock;
  final Value<double> minStock;
  final Value<String> unit;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.pzn = const Value.absent(),
    this.stock = const Value.absent(),
    this.minStock = const Value.absent(),
    this.unit = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.pzn = const Value.absent(),
    this.stock = const Value.absent(),
    this.minStock = const Value.absent(),
    required String unit,
  }) : name = Value(name),
       unit = Value(unit);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? pzn,
    Expression<double>? stock,
    Expression<double>? minStock,
    Expression<String>? unit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (pzn != null) 'pzn': pzn,
      if (stock != null) 'stock': stock,
      if (minStock != null) 'min_stock': minStock,
      if (unit != null) 'unit': unit,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? pzn,
    Value<double>? stock,
    Value<double>? minStock,
    Value<String>? unit,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      pzn: pzn ?? this.pzn,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pzn.present) {
      map['pzn'] = Variable<String>(pzn.value);
    }
    if (stock.present) {
      map['stock'] = Variable<double>(stock.value);
    }
    if (minStock.present) {
      map['min_stock'] = Variable<double>(minStock.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pzn: $pzn, ')
          ..write('stock: $stock, ')
          ..write('minStock: $minStock, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }
}

class $AccessoriesTable extends Accessories
    with TableInfo<$AccessoriesTable, Accessory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccessoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<double> stock = GeneratedColumn<double>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, stock, unit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accessories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Accessory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Accessory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Accessory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
    );
  }

  @override
  $AccessoriesTable createAlias(String alias) {
    return $AccessoriesTable(attachedDatabase, alias);
  }
}

class Accessory extends DataClass implements Insertable<Accessory> {
  final int id;
  final String name;
  final double stock;
  final String unit;
  const Accessory({
    required this.id,
    required this.name,
    required this.stock,
    required this.unit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['stock'] = Variable<double>(stock);
    map['unit'] = Variable<String>(unit);
    return map;
  }

  AccessoriesCompanion toCompanion(bool nullToAbsent) {
    return AccessoriesCompanion(
      id: Value(id),
      name: Value(name),
      stock: Value(stock),
      unit: Value(unit),
    );
  }

  factory Accessory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Accessory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stock: serializer.fromJson<double>(json['stock']),
      unit: serializer.fromJson<String>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'stock': serializer.toJson<double>(stock),
      'unit': serializer.toJson<String>(unit),
    };
  }

  Accessory copyWith({int? id, String? name, double? stock, String? unit}) =>
      Accessory(
        id: id ?? this.id,
        name: name ?? this.name,
        stock: stock ?? this.stock,
        unit: unit ?? this.unit,
      );
  Accessory copyWithCompanion(AccessoriesCompanion data) {
    return Accessory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stock: data.stock.present ? data.stock.value : this.stock,
      unit: data.unit.present ? data.unit.value : this.unit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Accessory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stock: $stock, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, stock, unit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Accessory &&
          other.id == this.id &&
          other.name == this.name &&
          other.stock == this.stock &&
          other.unit == this.unit);
}

class AccessoriesCompanion extends UpdateCompanion<Accessory> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> stock;
  final Value<String> unit;
  const AccessoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stock = const Value.absent(),
    this.unit = const Value.absent(),
  });
  AccessoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.stock = const Value.absent(),
    required String unit,
  }) : name = Value(name),
       unit = Value(unit);
  static Insertable<Accessory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? stock,
    Expression<String>? unit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stock != null) 'stock': stock,
      if (unit != null) 'unit': unit,
    });
  }

  AccessoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? stock,
    Value<String>? unit,
  }) {
    return AccessoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stock.present) {
      map['stock'] = Variable<double>(stock.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccessoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stock: $stock, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }
}

class $InfusionLogTable extends InfusionLog
    with TableInfo<$InfusionLogTable, InfusionLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InfusionLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<double> dosage = GeneratedColumn<double>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    medicationId,
    dosage,
    batchNumber,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'infusion_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<InfusionLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InfusionLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InfusionLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dosage'],
      )!,
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $InfusionLogTable createAlias(String alias) {
    return $InfusionLogTable(attachedDatabase, alias);
  }
}

class InfusionLogData extends DataClass implements Insertable<InfusionLogData> {
  final int id;
  final DateTime date;
  final int medicationId;
  final double dosage;
  final String? batchNumber;
  final String? notes;
  const InfusionLogData({
    required this.id,
    required this.date,
    required this.medicationId,
    required this.dosage,
    this.batchNumber,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['medication_id'] = Variable<int>(medicationId);
    map['dosage'] = Variable<double>(dosage);
    if (!nullToAbsent || batchNumber != null) {
      map['batch_number'] = Variable<String>(batchNumber);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  InfusionLogCompanion toCompanion(bool nullToAbsent) {
    return InfusionLogCompanion(
      id: Value(id),
      date: Value(date),
      medicationId: Value(medicationId),
      dosage: Value(dosage),
      batchNumber: batchNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(batchNumber),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory InfusionLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InfusionLogData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      dosage: serializer.fromJson<double>(json['dosage']),
      batchNumber: serializer.fromJson<String?>(json['batchNumber']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'medicationId': serializer.toJson<int>(medicationId),
      'dosage': serializer.toJson<double>(dosage),
      'batchNumber': serializer.toJson<String?>(batchNumber),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  InfusionLogData copyWith({
    int? id,
    DateTime? date,
    int? medicationId,
    double? dosage,
    Value<String?> batchNumber = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => InfusionLogData(
    id: id ?? this.id,
    date: date ?? this.date,
    medicationId: medicationId ?? this.medicationId,
    dosage: dosage ?? this.dosage,
    batchNumber: batchNumber.present ? batchNumber.value : this.batchNumber,
    notes: notes.present ? notes.value : this.notes,
  );
  InfusionLogData copyWithCompanion(InfusionLogCompanion data) {
    return InfusionLogData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InfusionLogData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('medicationId: $medicationId, ')
          ..write('dosage: $dosage, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, medicationId, dosage, batchNumber, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InfusionLogData &&
          other.id == this.id &&
          other.date == this.date &&
          other.medicationId == this.medicationId &&
          other.dosage == this.dosage &&
          other.batchNumber == this.batchNumber &&
          other.notes == this.notes);
}

class InfusionLogCompanion extends UpdateCompanion<InfusionLogData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> medicationId;
  final Value<double> dosage;
  final Value<String?> batchNumber;
  final Value<String?> notes;
  const InfusionLogCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.dosage = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.notes = const Value.absent(),
  });
  InfusionLogCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int medicationId,
    required double dosage,
    this.batchNumber = const Value.absent(),
    this.notes = const Value.absent(),
  }) : date = Value(date),
       medicationId = Value(medicationId),
       dosage = Value(dosage);
  static Insertable<InfusionLogData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? medicationId,
    Expression<double>? dosage,
    Expression<String>? batchNumber,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (medicationId != null) 'medication_id': medicationId,
      if (dosage != null) 'dosage': dosage,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (notes != null) 'notes': notes,
    });
  }

  InfusionLogCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? medicationId,
    Value<double>? dosage,
    Value<String?>? batchNumber,
    Value<String?>? notes,
  }) {
    return InfusionLogCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      medicationId: medicationId ?? this.medicationId,
      dosage: dosage ?? this.dosage,
      batchNumber: batchNumber ?? this.batchNumber,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<double>(dosage.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InfusionLogCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('medicationId: $medicationId, ')
          ..write('dosage: $dosage, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $MedicationAccessoriesTable extends MedicationAccessories
    with TableInfo<$MedicationAccessoriesTable, MedicationAccessory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationAccessoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _accessoryIdMeta = const VerificationMeta(
    'accessoryId',
  );
  @override
  late final GeneratedColumn<int> accessoryId = GeneratedColumn<int>(
    'accessory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accessories (id)',
    ),
  );
  static const VerificationMeta _defaultQuantityMeta = const VerificationMeta(
    'defaultQuantity',
  );
  @override
  late final GeneratedColumn<double> defaultQuantity = GeneratedColumn<double>(
    'default_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    accessoryId,
    defaultQuantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_accessories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationAccessory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('accessory_id')) {
      context.handle(
        _accessoryIdMeta,
        accessoryId.isAcceptableOrUnknown(
          data['accessory_id']!,
          _accessoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessoryIdMeta);
    }
    if (data.containsKey('default_quantity')) {
      context.handle(
        _defaultQuantityMeta,
        defaultQuantity.isAcceptableOrUnknown(
          data['default_quantity']!,
          _defaultQuantityMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationAccessory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationAccessory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      accessoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accessory_id'],
      )!,
      defaultQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_quantity'],
      )!,
    );
  }

  @override
  $MedicationAccessoriesTable createAlias(String alias) {
    return $MedicationAccessoriesTable(attachedDatabase, alias);
  }
}

class MedicationAccessory extends DataClass
    implements Insertable<MedicationAccessory> {
  final int id;
  final int medicationId;
  final int accessoryId;
  final double defaultQuantity;
  const MedicationAccessory({
    required this.id,
    required this.medicationId,
    required this.accessoryId,
    required this.defaultQuantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['accessory_id'] = Variable<int>(accessoryId);
    map['default_quantity'] = Variable<double>(defaultQuantity);
    return map;
  }

  MedicationAccessoriesCompanion toCompanion(bool nullToAbsent) {
    return MedicationAccessoriesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      accessoryId: Value(accessoryId),
      defaultQuantity: Value(defaultQuantity),
    );
  }

  factory MedicationAccessory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationAccessory(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      accessoryId: serializer.fromJson<int>(json['accessoryId']),
      defaultQuantity: serializer.fromJson<double>(json['defaultQuantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'accessoryId': serializer.toJson<int>(accessoryId),
      'defaultQuantity': serializer.toJson<double>(defaultQuantity),
    };
  }

  MedicationAccessory copyWith({
    int? id,
    int? medicationId,
    int? accessoryId,
    double? defaultQuantity,
  }) => MedicationAccessory(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    accessoryId: accessoryId ?? this.accessoryId,
    defaultQuantity: defaultQuantity ?? this.defaultQuantity,
  );
  MedicationAccessory copyWithCompanion(MedicationAccessoriesCompanion data) {
    return MedicationAccessory(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      accessoryId: data.accessoryId.present
          ? data.accessoryId.value
          : this.accessoryId,
      defaultQuantity: data.defaultQuantity.present
          ? data.defaultQuantity.value
          : this.defaultQuantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationAccessory(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('accessoryId: $accessoryId, ')
          ..write('defaultQuantity: $defaultQuantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, medicationId, accessoryId, defaultQuantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationAccessory &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.accessoryId == this.accessoryId &&
          other.defaultQuantity == this.defaultQuantity);
}

class MedicationAccessoriesCompanion
    extends UpdateCompanion<MedicationAccessory> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<int> accessoryId;
  final Value<double> defaultQuantity;
  const MedicationAccessoriesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.accessoryId = const Value.absent(),
    this.defaultQuantity = const Value.absent(),
  });
  MedicationAccessoriesCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required int accessoryId,
    this.defaultQuantity = const Value.absent(),
  }) : medicationId = Value(medicationId),
       accessoryId = Value(accessoryId);
  static Insertable<MedicationAccessory> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<int>? accessoryId,
    Expression<double>? defaultQuantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (accessoryId != null) 'accessory_id': accessoryId,
      if (defaultQuantity != null) 'default_quantity': defaultQuantity,
    });
  }

  MedicationAccessoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<int>? accessoryId,
    Value<double>? defaultQuantity,
  }) {
    return MedicationAccessoriesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      accessoryId: accessoryId ?? this.accessoryId,
      defaultQuantity: defaultQuantity ?? this.defaultQuantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (accessoryId.present) {
      map['accessory_id'] = Variable<int>(accessoryId.value);
    }
    if (defaultQuantity.present) {
      map['default_quantity'] = Variable<double>(defaultQuantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationAccessoriesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('accessoryId: $accessoryId, ')
          ..write('defaultQuantity: $defaultQuantity')
          ..write(')'))
        .toString();
  }
}

class $InfusionSchedulesTable extends InfusionSchedules
    with TableInfo<$InfusionSchedulesTable, InfusionSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InfusionSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<double> dosage = GeneratedColumn<double>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyTypeMeta = const VerificationMeta(
    'frequencyType',
  );
  @override
  late final GeneratedColumn<String> frequencyType = GeneratedColumn<String>(
    'frequency_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalValueMeta = const VerificationMeta(
    'intervalValue',
  );
  @override
  late final GeneratedColumn<int> intervalValue = GeneratedColumn<int>(
    'interval_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedWeekdaysMeta = const VerificationMeta(
    'selectedWeekdays',
  );
  @override
  late final GeneratedColumn<String> selectedWeekdays = GeneratedColumn<String>(
    'selected_weekdays',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    dosage,
    frequencyType,
    intervalValue,
    selectedWeekdays,
    startDate,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'infusion_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<InfusionSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('frequency_type')) {
      context.handle(
        _frequencyTypeMeta,
        frequencyType.isAcceptableOrUnknown(
          data['frequency_type']!,
          _frequencyTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_frequencyTypeMeta);
    }
    if (data.containsKey('interval_value')) {
      context.handle(
        _intervalValueMeta,
        intervalValue.isAcceptableOrUnknown(
          data['interval_value']!,
          _intervalValueMeta,
        ),
      );
    }
    if (data.containsKey('selected_weekdays')) {
      context.handle(
        _selectedWeekdaysMeta,
        selectedWeekdays.isAcceptableOrUnknown(
          data['selected_weekdays']!,
          _selectedWeekdaysMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InfusionSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InfusionSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dosage'],
      )!,
      frequencyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency_type'],
      )!,
      intervalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_value'],
      ),
      selectedWeekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_weekdays'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $InfusionSchedulesTable createAlias(String alias) {
    return $InfusionSchedulesTable(attachedDatabase, alias);
  }
}

class InfusionSchedule extends DataClass
    implements Insertable<InfusionSchedule> {
  final int id;
  final int medicationId;
  final double dosage;
  final String frequencyType;
  final int? intervalValue;
  final String? selectedWeekdays;
  final DateTime startDate;
  final bool isActive;
  const InfusionSchedule({
    required this.id,
    required this.medicationId,
    required this.dosage,
    required this.frequencyType,
    this.intervalValue,
    this.selectedWeekdays,
    required this.startDate,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['dosage'] = Variable<double>(dosage);
    map['frequency_type'] = Variable<String>(frequencyType);
    if (!nullToAbsent || intervalValue != null) {
      map['interval_value'] = Variable<int>(intervalValue);
    }
    if (!nullToAbsent || selectedWeekdays != null) {
      map['selected_weekdays'] = Variable<String>(selectedWeekdays);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  InfusionSchedulesCompanion toCompanion(bool nullToAbsent) {
    return InfusionSchedulesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      dosage: Value(dosage),
      frequencyType: Value(frequencyType),
      intervalValue: intervalValue == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalValue),
      selectedWeekdays: selectedWeekdays == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedWeekdays),
      startDate: Value(startDate),
      isActive: Value(isActive),
    );
  }

  factory InfusionSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InfusionSchedule(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      dosage: serializer.fromJson<double>(json['dosage']),
      frequencyType: serializer.fromJson<String>(json['frequencyType']),
      intervalValue: serializer.fromJson<int?>(json['intervalValue']),
      selectedWeekdays: serializer.fromJson<String?>(json['selectedWeekdays']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'dosage': serializer.toJson<double>(dosage),
      'frequencyType': serializer.toJson<String>(frequencyType),
      'intervalValue': serializer.toJson<int?>(intervalValue),
      'selectedWeekdays': serializer.toJson<String?>(selectedWeekdays),
      'startDate': serializer.toJson<DateTime>(startDate),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  InfusionSchedule copyWith({
    int? id,
    int? medicationId,
    double? dosage,
    String? frequencyType,
    Value<int?> intervalValue = const Value.absent(),
    Value<String?> selectedWeekdays = const Value.absent(),
    DateTime? startDate,
    bool? isActive,
  }) => InfusionSchedule(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    dosage: dosage ?? this.dosage,
    frequencyType: frequencyType ?? this.frequencyType,
    intervalValue: intervalValue.present
        ? intervalValue.value
        : this.intervalValue,
    selectedWeekdays: selectedWeekdays.present
        ? selectedWeekdays.value
        : this.selectedWeekdays,
    startDate: startDate ?? this.startDate,
    isActive: isActive ?? this.isActive,
  );
  InfusionSchedule copyWithCompanion(InfusionSchedulesCompanion data) {
    return InfusionSchedule(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      frequencyType: data.frequencyType.present
          ? data.frequencyType.value
          : this.frequencyType,
      intervalValue: data.intervalValue.present
          ? data.intervalValue.value
          : this.intervalValue,
      selectedWeekdays: data.selectedWeekdays.present
          ? data.selectedWeekdays.value
          : this.selectedWeekdays,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InfusionSchedule(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('dosage: $dosage, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('intervalValue: $intervalValue, ')
          ..write('selectedWeekdays: $selectedWeekdays, ')
          ..write('startDate: $startDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    dosage,
    frequencyType,
    intervalValue,
    selectedWeekdays,
    startDate,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InfusionSchedule &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.dosage == this.dosage &&
          other.frequencyType == this.frequencyType &&
          other.intervalValue == this.intervalValue &&
          other.selectedWeekdays == this.selectedWeekdays &&
          other.startDate == this.startDate &&
          other.isActive == this.isActive);
}

class InfusionSchedulesCompanion extends UpdateCompanion<InfusionSchedule> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<double> dosage;
  final Value<String> frequencyType;
  final Value<int?> intervalValue;
  final Value<String?> selectedWeekdays;
  final Value<DateTime> startDate;
  final Value<bool> isActive;
  const InfusionSchedulesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.dosage = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.intervalValue = const Value.absent(),
    this.selectedWeekdays = const Value.absent(),
    this.startDate = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  InfusionSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required double dosage,
    required String frequencyType,
    this.intervalValue = const Value.absent(),
    this.selectedWeekdays = const Value.absent(),
    required DateTime startDate,
    this.isActive = const Value.absent(),
  }) : medicationId = Value(medicationId),
       dosage = Value(dosage),
       frequencyType = Value(frequencyType),
       startDate = Value(startDate);
  static Insertable<InfusionSchedule> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<double>? dosage,
    Expression<String>? frequencyType,
    Expression<int>? intervalValue,
    Expression<String>? selectedWeekdays,
    Expression<DateTime>? startDate,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (dosage != null) 'dosage': dosage,
      if (frequencyType != null) 'frequency_type': frequencyType,
      if (intervalValue != null) 'interval_value': intervalValue,
      if (selectedWeekdays != null) 'selected_weekdays': selectedWeekdays,
      if (startDate != null) 'start_date': startDate,
      if (isActive != null) 'is_active': isActive,
    });
  }

  InfusionSchedulesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<double>? dosage,
    Value<String>? frequencyType,
    Value<int?>? intervalValue,
    Value<String?>? selectedWeekdays,
    Value<DateTime>? startDate,
    Value<bool>? isActive,
  }) {
    return InfusionSchedulesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      dosage: dosage ?? this.dosage,
      frequencyType: frequencyType ?? this.frequencyType,
      intervalValue: intervalValue ?? this.intervalValue,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<double>(dosage.value);
    }
    if (frequencyType.present) {
      map['frequency_type'] = Variable<String>(frequencyType.value);
    }
    if (intervalValue.present) {
      map['interval_value'] = Variable<int>(intervalValue.value);
    }
    if (selectedWeekdays.present) {
      map['selected_weekdays'] = Variable<String>(selectedWeekdays.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InfusionSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('dosage: $dosage, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('intervalValue: $intervalValue, ')
          ..write('selectedWeekdays: $selectedWeekdays, ')
          ..write('startDate: $startDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $PlannedInfusionsTable extends PlannedInfusions
    with TableInfo<$PlannedInfusionsTable, PlannedInfusion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedInfusionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<double> dosage = GeneratedColumn<double>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES infusion_schedules (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    medicationId,
    dosage,
    notes,
    isCompleted,
    scheduleId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_infusions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedInfusion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedInfusion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedInfusion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dosage'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      ),
    );
  }

  @override
  $PlannedInfusionsTable createAlias(String alias) {
    return $PlannedInfusionsTable(attachedDatabase, alias);
  }
}

class PlannedInfusion extends DataClass implements Insertable<PlannedInfusion> {
  final int id;
  final DateTime date;
  final int medicationId;
  final double dosage;
  final String? notes;
  final bool isCompleted;
  final int? scheduleId;
  const PlannedInfusion({
    required this.id,
    required this.date,
    required this.medicationId,
    required this.dosage,
    this.notes,
    required this.isCompleted,
    this.scheduleId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['medication_id'] = Variable<int>(medicationId);
    map['dosage'] = Variable<double>(dosage);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<int>(scheduleId);
    }
    return map;
  }

  PlannedInfusionsCompanion toCompanion(bool nullToAbsent) {
    return PlannedInfusionsCompanion(
      id: Value(id),
      date: Value(date),
      medicationId: Value(medicationId),
      dosage: Value(dosage),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isCompleted: Value(isCompleted),
      scheduleId: scheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleId),
    );
  }

  factory PlannedInfusion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedInfusion(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      dosage: serializer.fromJson<double>(json['dosage']),
      notes: serializer.fromJson<String?>(json['notes']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      scheduleId: serializer.fromJson<int?>(json['scheduleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'medicationId': serializer.toJson<int>(medicationId),
      'dosage': serializer.toJson<double>(dosage),
      'notes': serializer.toJson<String?>(notes),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'scheduleId': serializer.toJson<int?>(scheduleId),
    };
  }

  PlannedInfusion copyWith({
    int? id,
    DateTime? date,
    int? medicationId,
    double? dosage,
    Value<String?> notes = const Value.absent(),
    bool? isCompleted,
    Value<int?> scheduleId = const Value.absent(),
  }) => PlannedInfusion(
    id: id ?? this.id,
    date: date ?? this.date,
    medicationId: medicationId ?? this.medicationId,
    dosage: dosage ?? this.dosage,
    notes: notes.present ? notes.value : this.notes,
    isCompleted: isCompleted ?? this.isCompleted,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
  );
  PlannedInfusion copyWithCompanion(PlannedInfusionsCompanion data) {
    return PlannedInfusion(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      notes: data.notes.present ? data.notes.value : this.notes,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedInfusion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('medicationId: $medicationId, ')
          ..write('dosage: $dosage, ')
          ..write('notes: $notes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('scheduleId: $scheduleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    medicationId,
    dosage,
    notes,
    isCompleted,
    scheduleId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedInfusion &&
          other.id == this.id &&
          other.date == this.date &&
          other.medicationId == this.medicationId &&
          other.dosage == this.dosage &&
          other.notes == this.notes &&
          other.isCompleted == this.isCompleted &&
          other.scheduleId == this.scheduleId);
}

class PlannedInfusionsCompanion extends UpdateCompanion<PlannedInfusion> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> medicationId;
  final Value<double> dosage;
  final Value<String?> notes;
  final Value<bool> isCompleted;
  final Value<int?> scheduleId;
  const PlannedInfusionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.dosage = const Value.absent(),
    this.notes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.scheduleId = const Value.absent(),
  });
  PlannedInfusionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int medicationId,
    required double dosage,
    this.notes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.scheduleId = const Value.absent(),
  }) : date = Value(date),
       medicationId = Value(medicationId),
       dosage = Value(dosage);
  static Insertable<PlannedInfusion> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? medicationId,
    Expression<double>? dosage,
    Expression<String>? notes,
    Expression<bool>? isCompleted,
    Expression<int>? scheduleId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (medicationId != null) 'medication_id': medicationId,
      if (dosage != null) 'dosage': dosage,
      if (notes != null) 'notes': notes,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (scheduleId != null) 'schedule_id': scheduleId,
    });
  }

  PlannedInfusionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? medicationId,
    Value<double>? dosage,
    Value<String?>? notes,
    Value<bool>? isCompleted,
    Value<int?>? scheduleId,
  }) {
    return PlannedInfusionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      medicationId: medicationId ?? this.medicationId,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduleId: scheduleId ?? this.scheduleId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<double>(dosage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedInfusionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('medicationId: $medicationId, ')
          ..write('dosage: $dosage, ')
          ..write('notes: $notes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('scheduleId: $scheduleId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $AccessoriesTable accessories = $AccessoriesTable(this);
  late final $InfusionLogTable infusionLog = $InfusionLogTable(this);
  late final $MedicationAccessoriesTable medicationAccessories =
      $MedicationAccessoriesTable(this);
  late final $InfusionSchedulesTable infusionSchedules =
      $InfusionSchedulesTable(this);
  late final $PlannedInfusionsTable plannedInfusions = $PlannedInfusionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medications,
    accessories,
    infusionLog,
    medicationAccessories,
    infusionSchedules,
    plannedInfusions,
  ];
}

typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> pzn,
      Value<double> stock,
      Value<double> minStock,
      required String unit,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> pzn,
      Value<double> stock,
      Value<double> minStock,
      Value<String> unit,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InfusionLogTable, List<InfusionLogData>>
  _infusionLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.infusionLog,
    aliasName: $_aliasNameGenerator(
      db.medications.id,
      db.infusionLog.medicationId,
    ),
  );

  $$InfusionLogTableProcessedTableManager get infusionLogRefs {
    final manager = $$InfusionLogTableTableManager(
      $_db,
      $_db.infusionLog,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_infusionLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MedicationAccessoriesTable,
    List<MedicationAccessory>
  >
  _medicationAccessoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.medicationAccessories,
        aliasName: $_aliasNameGenerator(
          db.medications.id,
          db.medicationAccessories.medicationId,
        ),
      );

  $$MedicationAccessoriesTableProcessedTableManager
  get medicationAccessoriesRefs {
    final manager = $$MedicationAccessoriesTableTableManager(
      $_db,
      $_db.medicationAccessories,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicationAccessoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InfusionSchedulesTable, List<InfusionSchedule>>
  _infusionSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.infusionSchedules,
        aliasName: $_aliasNameGenerator(
          db.medications.id,
          db.infusionSchedules.medicationId,
        ),
      );

  $$InfusionSchedulesTableProcessedTableManager get infusionSchedulesRefs {
    final manager = $$InfusionSchedulesTableTableManager(
      $_db,
      $_db.infusionSchedules,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _infusionSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlannedInfusionsTable, List<PlannedInfusion>>
  _plannedInfusionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.plannedInfusions,
    aliasName: $_aliasNameGenerator(
      db.medications.id,
      db.plannedInfusions.medicationId,
    ),
  );

  $$PlannedInfusionsTableProcessedTableManager get plannedInfusionsRefs {
    final manager = $$PlannedInfusionsTableTableManager(
      $_db,
      $_db.plannedInfusions,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plannedInfusionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pzn => $composableBuilder(
    column: $table.pzn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minStock => $composableBuilder(
    column: $table.minStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> infusionLogRefs(
    Expression<bool> Function($$InfusionLogTableFilterComposer f) f,
  ) {
    final $$InfusionLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.infusionLog,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InfusionLogTableFilterComposer(
            $db: $db,
            $table: $db.infusionLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> medicationAccessoriesRefs(
    Expression<bool> Function($$MedicationAccessoriesTableFilterComposer f) f,
  ) {
    final $$MedicationAccessoriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.medicationAccessories,
          getReferencedColumn: (t) => t.medicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationAccessoriesTableFilterComposer(
                $db: $db,
                $table: $db.medicationAccessories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> infusionSchedulesRefs(
    Expression<bool> Function($$InfusionSchedulesTableFilterComposer f) f,
  ) {
    final $$InfusionSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.infusionSchedules,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InfusionSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.infusionSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> plannedInfusionsRefs(
    Expression<bool> Function($$PlannedInfusionsTableFilterComposer f) f,
  ) {
    final $$PlannedInfusionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plannedInfusions,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedInfusionsTableFilterComposer(
            $db: $db,
            $table: $db.plannedInfusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pzn => $composableBuilder(
    column: $table.pzn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minStock => $composableBuilder(
    column: $table.minStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get pzn =>
      $composableBuilder(column: $table.pzn, builder: (column) => column);

  GeneratedColumn<double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<double> get minStock =>
      $composableBuilder(column: $table.minStock, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  Expression<T> infusionLogRefs<T extends Object>(
    Expression<T> Function($$InfusionLogTableAnnotationComposer a) f,
  ) {
    final $$InfusionLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.infusionLog,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InfusionLogTableAnnotationComposer(
            $db: $db,
            $table: $db.infusionLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> medicationAccessoriesRefs<T extends Object>(
    Expression<T> Function($$MedicationAccessoriesTableAnnotationComposer a) f,
  ) {
    final $$MedicationAccessoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.medicationAccessories,
          getReferencedColumn: (t) => t.medicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationAccessoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.medicationAccessories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> infusionSchedulesRefs<T extends Object>(
    Expression<T> Function($$InfusionSchedulesTableAnnotationComposer a) f,
  ) {
    final $$InfusionSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.infusionSchedules,
          getReferencedColumn: (t) => t.medicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InfusionSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.infusionSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> plannedInfusionsRefs<T extends Object>(
    Expression<T> Function($$PlannedInfusionsTableAnnotationComposer a) f,
  ) {
    final $$PlannedInfusionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plannedInfusions,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedInfusionsTableAnnotationComposer(
            $db: $db,
            $table: $db.plannedInfusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, $$MedicationsTableReferences),
          Medication,
          PrefetchHooks Function({
            bool infusionLogRefs,
            bool medicationAccessoriesRefs,
            bool infusionSchedulesRefs,
            bool plannedInfusionsRefs,
          })
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> pzn = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<double> minStock = const Value.absent(),
                Value<String> unit = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                pzn: pzn,
                stock: stock,
                minStock: minStock,
                unit: unit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> pzn = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<double> minStock = const Value.absent(),
                required String unit,
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                pzn: pzn,
                stock: stock,
                minStock: minStock,
                unit: unit,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                infusionLogRefs = false,
                medicationAccessoriesRefs = false,
                infusionSchedulesRefs = false,
                plannedInfusionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (infusionLogRefs) db.infusionLog,
                    if (medicationAccessoriesRefs) db.medicationAccessories,
                    if (infusionSchedulesRefs) db.infusionSchedules,
                    if (plannedInfusionsRefs) db.plannedInfusions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (infusionLogRefs)
                        await $_getPrefetchedData<
                          Medication,
                          $MedicationsTable,
                          InfusionLogData
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._infusionLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).infusionLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (medicationAccessoriesRefs)
                        await $_getPrefetchedData<
                          Medication,
                          $MedicationsTable,
                          MedicationAccessory
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._medicationAccessoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationAccessoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (infusionSchedulesRefs)
                        await $_getPrefetchedData<
                          Medication,
                          $MedicationsTable,
                          InfusionSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._infusionSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).infusionSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plannedInfusionsRefs)
                        await $_getPrefetchedData<
                          Medication,
                          $MedicationsTable,
                          PlannedInfusion
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._plannedInfusionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).plannedInfusionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
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

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, $$MedicationsTableReferences),
      Medication,
      PrefetchHooks Function({
        bool infusionLogRefs,
        bool medicationAccessoriesRefs,
        bool infusionSchedulesRefs,
        bool plannedInfusionsRefs,
      })
    >;
typedef $$AccessoriesTableCreateCompanionBuilder =
    AccessoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<double> stock,
      required String unit,
    });
typedef $$AccessoriesTableUpdateCompanionBuilder =
    AccessoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> stock,
      Value<String> unit,
    });

final class $$AccessoriesTableReferences
    extends BaseReferences<_$AppDatabase, $AccessoriesTable, Accessory> {
  $$AccessoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $MedicationAccessoriesTable,
    List<MedicationAccessory>
  >
  _medicationAccessoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.medicationAccessories,
        aliasName: $_aliasNameGenerator(
          db.accessories.id,
          db.medicationAccessories.accessoryId,
        ),
      );

  $$MedicationAccessoriesTableProcessedTableManager
  get medicationAccessoriesRefs {
    final manager = $$MedicationAccessoriesTableTableManager(
      $_db,
      $_db.medicationAccessories,
    ).filter((f) => f.accessoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicationAccessoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccessoriesTableFilterComposer
    extends Composer<_$AppDatabase, $AccessoriesTable> {
  $$AccessoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicationAccessoriesRefs(
    Expression<bool> Function($$MedicationAccessoriesTableFilterComposer f) f,
  ) {
    final $$MedicationAccessoriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.medicationAccessories,
          getReferencedColumn: (t) => t.accessoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationAccessoriesTableFilterComposer(
                $db: $db,
                $table: $db.medicationAccessories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AccessoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AccessoriesTable> {
  $$AccessoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccessoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccessoriesTable> {
  $$AccessoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  Expression<T> medicationAccessoriesRefs<T extends Object>(
    Expression<T> Function($$MedicationAccessoriesTableAnnotationComposer a) f,
  ) {
    final $$MedicationAccessoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.medicationAccessories,
          getReferencedColumn: (t) => t.accessoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationAccessoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.medicationAccessories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AccessoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccessoriesTable,
          Accessory,
          $$AccessoriesTableFilterComposer,
          $$AccessoriesTableOrderingComposer,
          $$AccessoriesTableAnnotationComposer,
          $$AccessoriesTableCreateCompanionBuilder,
          $$AccessoriesTableUpdateCompanionBuilder,
          (Accessory, $$AccessoriesTableReferences),
          Accessory,
          PrefetchHooks Function({bool medicationAccessoriesRefs})
        > {
  $$AccessoriesTableTableManager(_$AppDatabase db, $AccessoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccessoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccessoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccessoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<String> unit = const Value.absent(),
              }) => AccessoriesCompanion(
                id: id,
                name: name,
                stock: stock,
                unit: unit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<double> stock = const Value.absent(),
                required String unit,
              }) => AccessoriesCompanion.insert(
                id: id,
                name: name,
                stock: stock,
                unit: unit,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccessoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationAccessoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (medicationAccessoriesRefs) db.medicationAccessories,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (medicationAccessoriesRefs)
                    await $_getPrefetchedData<
                      Accessory,
                      $AccessoriesTable,
                      MedicationAccessory
                    >(
                      currentTable: table,
                      referencedTable: $$AccessoriesTableReferences
                          ._medicationAccessoriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AccessoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).medicationAccessoriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.accessoryId == item.id,
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

typedef $$AccessoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccessoriesTable,
      Accessory,
      $$AccessoriesTableFilterComposer,
      $$AccessoriesTableOrderingComposer,
      $$AccessoriesTableAnnotationComposer,
      $$AccessoriesTableCreateCompanionBuilder,
      $$AccessoriesTableUpdateCompanionBuilder,
      (Accessory, $$AccessoriesTableReferences),
      Accessory,
      PrefetchHooks Function({bool medicationAccessoriesRefs})
    >;
typedef $$InfusionLogTableCreateCompanionBuilder =
    InfusionLogCompanion Function({
      Value<int> id,
      required DateTime date,
      required int medicationId,
      required double dosage,
      Value<String?> batchNumber,
      Value<String?> notes,
    });
typedef $$InfusionLogTableUpdateCompanionBuilder =
    InfusionLogCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> medicationId,
      Value<double> dosage,
      Value<String?> batchNumber,
      Value<String?> notes,
    });

final class $$InfusionLogTableReferences
    extends BaseReferences<_$AppDatabase, $InfusionLogTable, InfusionLogData> {
  $$InfusionLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(db.infusionLog.medicationId, db.medications.id),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InfusionLogTableFilterComposer
    extends Composer<_$AppDatabase, $InfusionLogTable> {
  $$InfusionLogTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InfusionLogTableOrderingComposer
    extends Composer<_$AppDatabase, $InfusionLogTable> {
  $$InfusionLogTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InfusionLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $InfusionLogTable> {
  $$InfusionLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InfusionLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InfusionLogTable,
          InfusionLogData,
          $$InfusionLogTableFilterComposer,
          $$InfusionLogTableOrderingComposer,
          $$InfusionLogTableAnnotationComposer,
          $$InfusionLogTableCreateCompanionBuilder,
          $$InfusionLogTableUpdateCompanionBuilder,
          (InfusionLogData, $$InfusionLogTableReferences),
          InfusionLogData,
          PrefetchHooks Function({bool medicationId})
        > {
  $$InfusionLogTableTableManager(_$AppDatabase db, $InfusionLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InfusionLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InfusionLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InfusionLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<double> dosage = const Value.absent(),
                Value<String?> batchNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => InfusionLogCompanion(
                id: id,
                date: date,
                medicationId: medicationId,
                dosage: dosage,
                batchNumber: batchNumber,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int medicationId,
                required double dosage,
                Value<String?> batchNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => InfusionLogCompanion.insert(
                id: id,
                date: date,
                medicationId: medicationId,
                dosage: dosage,
                batchNumber: batchNumber,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InfusionLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
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
                    if (medicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationId,
                                referencedTable: $$InfusionLogTableReferences
                                    ._medicationIdTable(db),
                                referencedColumn: $$InfusionLogTableReferences
                                    ._medicationIdTable(db)
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

typedef $$InfusionLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InfusionLogTable,
      InfusionLogData,
      $$InfusionLogTableFilterComposer,
      $$InfusionLogTableOrderingComposer,
      $$InfusionLogTableAnnotationComposer,
      $$InfusionLogTableCreateCompanionBuilder,
      $$InfusionLogTableUpdateCompanionBuilder,
      (InfusionLogData, $$InfusionLogTableReferences),
      InfusionLogData,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$MedicationAccessoriesTableCreateCompanionBuilder =
    MedicationAccessoriesCompanion Function({
      Value<int> id,
      required int medicationId,
      required int accessoryId,
      Value<double> defaultQuantity,
    });
typedef $$MedicationAccessoriesTableUpdateCompanionBuilder =
    MedicationAccessoriesCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<int> accessoryId,
      Value<double> defaultQuantity,
    });

final class $$MedicationAccessoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MedicationAccessoriesTable,
          MedicationAccessory
        > {
  $$MedicationAccessoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(
          db.medicationAccessories.medicationId,
          db.medications.id,
        ),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccessoriesTable _accessoryIdTable(_$AppDatabase db) =>
      db.accessories.createAlias(
        $_aliasNameGenerator(
          db.medicationAccessories.accessoryId,
          db.accessories.id,
        ),
      );

  $$AccessoriesTableProcessedTableManager get accessoryId {
    final $_column = $_itemColumn<int>('accessory_id')!;

    final manager = $$AccessoriesTableTableManager(
      $_db,
      $_db.accessories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accessoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationAccessoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationAccessoriesTable> {
  $$MedicationAccessoriesTableFilterComposer({
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

  ColumnFilters<double> get defaultQuantity => $composableBuilder(
    column: $table.defaultQuantity,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccessoriesTableFilterComposer get accessoryId {
    final $$AccessoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accessoryId,
      referencedTable: $db.accessories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccessoriesTableFilterComposer(
            $db: $db,
            $table: $db.accessories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationAccessoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationAccessoriesTable> {
  $$MedicationAccessoriesTableOrderingComposer({
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

  ColumnOrderings<double> get defaultQuantity => $composableBuilder(
    column: $table.defaultQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccessoriesTableOrderingComposer get accessoryId {
    final $$AccessoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accessoryId,
      referencedTable: $db.accessories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccessoriesTableOrderingComposer(
            $db: $db,
            $table: $db.accessories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationAccessoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationAccessoriesTable> {
  $$MedicationAccessoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get defaultQuantity => $composableBuilder(
    column: $table.defaultQuantity,
    builder: (column) => column,
  );

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccessoriesTableAnnotationComposer get accessoryId {
    final $$AccessoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accessoryId,
      referencedTable: $db.accessories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccessoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.accessories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationAccessoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationAccessoriesTable,
          MedicationAccessory,
          $$MedicationAccessoriesTableFilterComposer,
          $$MedicationAccessoriesTableOrderingComposer,
          $$MedicationAccessoriesTableAnnotationComposer,
          $$MedicationAccessoriesTableCreateCompanionBuilder,
          $$MedicationAccessoriesTableUpdateCompanionBuilder,
          (MedicationAccessory, $$MedicationAccessoriesTableReferences),
          MedicationAccessory,
          PrefetchHooks Function({bool medicationId, bool accessoryId})
        > {
  $$MedicationAccessoriesTableTableManager(
    _$AppDatabase db,
    $MedicationAccessoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationAccessoriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MedicationAccessoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MedicationAccessoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<int> accessoryId = const Value.absent(),
                Value<double> defaultQuantity = const Value.absent(),
              }) => MedicationAccessoriesCompanion(
                id: id,
                medicationId: medicationId,
                accessoryId: accessoryId,
                defaultQuantity: defaultQuantity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required int accessoryId,
                Value<double> defaultQuantity = const Value.absent(),
              }) => MedicationAccessoriesCompanion.insert(
                id: id,
                medicationId: medicationId,
                accessoryId: accessoryId,
                defaultQuantity: defaultQuantity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationAccessoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false, accessoryId = false}) {
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
                    if (medicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationId,
                                referencedTable:
                                    $$MedicationAccessoriesTableReferences
                                        ._medicationIdTable(db),
                                referencedColumn:
                                    $$MedicationAccessoriesTableReferences
                                        ._medicationIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (accessoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accessoryId,
                                referencedTable:
                                    $$MedicationAccessoriesTableReferences
                                        ._accessoryIdTable(db),
                                referencedColumn:
                                    $$MedicationAccessoriesTableReferences
                                        ._accessoryIdTable(db)
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

typedef $$MedicationAccessoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationAccessoriesTable,
      MedicationAccessory,
      $$MedicationAccessoriesTableFilterComposer,
      $$MedicationAccessoriesTableOrderingComposer,
      $$MedicationAccessoriesTableAnnotationComposer,
      $$MedicationAccessoriesTableCreateCompanionBuilder,
      $$MedicationAccessoriesTableUpdateCompanionBuilder,
      (MedicationAccessory, $$MedicationAccessoriesTableReferences),
      MedicationAccessory,
      PrefetchHooks Function({bool medicationId, bool accessoryId})
    >;
typedef $$InfusionSchedulesTableCreateCompanionBuilder =
    InfusionSchedulesCompanion Function({
      Value<int> id,
      required int medicationId,
      required double dosage,
      required String frequencyType,
      Value<int?> intervalValue,
      Value<String?> selectedWeekdays,
      required DateTime startDate,
      Value<bool> isActive,
    });
typedef $$InfusionSchedulesTableUpdateCompanionBuilder =
    InfusionSchedulesCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<double> dosage,
      Value<String> frequencyType,
      Value<int?> intervalValue,
      Value<String?> selectedWeekdays,
      Value<DateTime> startDate,
      Value<bool> isActive,
    });

final class $$InfusionSchedulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InfusionSchedulesTable,
          InfusionSchedule
        > {
  $$InfusionSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(
          db.infusionSchedules.medicationId,
          db.medications.id,
        ),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlannedInfusionsTable, List<PlannedInfusion>>
  _plannedInfusionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.plannedInfusions,
    aliasName: $_aliasNameGenerator(
      db.infusionSchedules.id,
      db.plannedInfusions.scheduleId,
    ),
  );

  $$PlannedInfusionsTableProcessedTableManager get plannedInfusionsRefs {
    final manager = $$PlannedInfusionsTableTableManager(
      $_db,
      $_db.plannedInfusions,
    ).filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plannedInfusionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InfusionSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $InfusionSchedulesTable> {
  $$InfusionSchedulesTableFilterComposer({
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

  ColumnFilters<double> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedWeekdays => $composableBuilder(
    column: $table.selectedWeekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> plannedInfusionsRefs(
    Expression<bool> Function($$PlannedInfusionsTableFilterComposer f) f,
  ) {
    final $$PlannedInfusionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plannedInfusions,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedInfusionsTableFilterComposer(
            $db: $db,
            $table: $db.plannedInfusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InfusionSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $InfusionSchedulesTable> {
  $$InfusionSchedulesTableOrderingComposer({
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

  ColumnOrderings<double> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedWeekdays => $composableBuilder(
    column: $table.selectedWeekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InfusionSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InfusionSchedulesTable> {
  $$InfusionSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedWeekdays => $composableBuilder(
    column: $table.selectedWeekdays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> plannedInfusionsRefs<T extends Object>(
    Expression<T> Function($$PlannedInfusionsTableAnnotationComposer a) f,
  ) {
    final $$PlannedInfusionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plannedInfusions,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedInfusionsTableAnnotationComposer(
            $db: $db,
            $table: $db.plannedInfusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InfusionSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InfusionSchedulesTable,
          InfusionSchedule,
          $$InfusionSchedulesTableFilterComposer,
          $$InfusionSchedulesTableOrderingComposer,
          $$InfusionSchedulesTableAnnotationComposer,
          $$InfusionSchedulesTableCreateCompanionBuilder,
          $$InfusionSchedulesTableUpdateCompanionBuilder,
          (InfusionSchedule, $$InfusionSchedulesTableReferences),
          InfusionSchedule,
          PrefetchHooks Function({bool medicationId, bool plannedInfusionsRefs})
        > {
  $$InfusionSchedulesTableTableManager(
    _$AppDatabase db,
    $InfusionSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InfusionSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InfusionSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InfusionSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<double> dosage = const Value.absent(),
                Value<String> frequencyType = const Value.absent(),
                Value<int?> intervalValue = const Value.absent(),
                Value<String?> selectedWeekdays = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => InfusionSchedulesCompanion(
                id: id,
                medicationId: medicationId,
                dosage: dosage,
                frequencyType: frequencyType,
                intervalValue: intervalValue,
                selectedWeekdays: selectedWeekdays,
                startDate: startDate,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required double dosage,
                required String frequencyType,
                Value<int?> intervalValue = const Value.absent(),
                Value<String?> selectedWeekdays = const Value.absent(),
                required DateTime startDate,
                Value<bool> isActive = const Value.absent(),
              }) => InfusionSchedulesCompanion.insert(
                id: id,
                medicationId: medicationId,
                dosage: dosage,
                frequencyType: frequencyType,
                intervalValue: intervalValue,
                selectedWeekdays: selectedWeekdays,
                startDate: startDate,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InfusionSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({medicationId = false, plannedInfusionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (plannedInfusionsRefs) db.plannedInfusions,
                  ],
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
                        if (medicationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.medicationId,
                                    referencedTable:
                                        $$InfusionSchedulesTableReferences
                                            ._medicationIdTable(db),
                                    referencedColumn:
                                        $$InfusionSchedulesTableReferences
                                            ._medicationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (plannedInfusionsRefs)
                        await $_getPrefetchedData<
                          InfusionSchedule,
                          $InfusionSchedulesTable,
                          PlannedInfusion
                        >(
                          currentTable: table,
                          referencedTable: $$InfusionSchedulesTableReferences
                              ._plannedInfusionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InfusionSchedulesTableReferences(
                                db,
                                table,
                                p0,
                              ).plannedInfusionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleId == item.id,
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

typedef $$InfusionSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InfusionSchedulesTable,
      InfusionSchedule,
      $$InfusionSchedulesTableFilterComposer,
      $$InfusionSchedulesTableOrderingComposer,
      $$InfusionSchedulesTableAnnotationComposer,
      $$InfusionSchedulesTableCreateCompanionBuilder,
      $$InfusionSchedulesTableUpdateCompanionBuilder,
      (InfusionSchedule, $$InfusionSchedulesTableReferences),
      InfusionSchedule,
      PrefetchHooks Function({bool medicationId, bool plannedInfusionsRefs})
    >;
typedef $$PlannedInfusionsTableCreateCompanionBuilder =
    PlannedInfusionsCompanion Function({
      Value<int> id,
      required DateTime date,
      required int medicationId,
      required double dosage,
      Value<String?> notes,
      Value<bool> isCompleted,
      Value<int?> scheduleId,
    });
typedef $$PlannedInfusionsTableUpdateCompanionBuilder =
    PlannedInfusionsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> medicationId,
      Value<double> dosage,
      Value<String?> notes,
      Value<bool> isCompleted,
      Value<int?> scheduleId,
    });

final class $$PlannedInfusionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlannedInfusionsTable, PlannedInfusion> {
  $$PlannedInfusionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(
          db.plannedInfusions.medicationId,
          db.medications.id,
        ),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InfusionSchedulesTable _scheduleIdTable(_$AppDatabase db) =>
      db.infusionSchedules.createAlias(
        $_aliasNameGenerator(
          db.plannedInfusions.scheduleId,
          db.infusionSchedules.id,
        ),
      );

  $$InfusionSchedulesTableProcessedTableManager? get scheduleId {
    final $_column = $_itemColumn<int>('schedule_id');
    if ($_column == null) return null;
    final manager = $$InfusionSchedulesTableTableManager(
      $_db,
      $_db.infusionSchedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlannedInfusionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedInfusionsTable> {
  $$PlannedInfusionsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InfusionSchedulesTableFilterComposer get scheduleId {
    final $$InfusionSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.infusionSchedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InfusionSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.infusionSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlannedInfusionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedInfusionsTable> {
  $$PlannedInfusionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InfusionSchedulesTableOrderingComposer get scheduleId {
    final $$InfusionSchedulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.infusionSchedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InfusionSchedulesTableOrderingComposer(
            $db: $db,
            $table: $db.infusionSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlannedInfusionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedInfusionsTable> {
  $$PlannedInfusionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InfusionSchedulesTableAnnotationComposer get scheduleId {
    final $$InfusionSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleId,
          referencedTable: $db.infusionSchedules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InfusionSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.infusionSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PlannedInfusionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlannedInfusionsTable,
          PlannedInfusion,
          $$PlannedInfusionsTableFilterComposer,
          $$PlannedInfusionsTableOrderingComposer,
          $$PlannedInfusionsTableAnnotationComposer,
          $$PlannedInfusionsTableCreateCompanionBuilder,
          $$PlannedInfusionsTableUpdateCompanionBuilder,
          (PlannedInfusion, $$PlannedInfusionsTableReferences),
          PlannedInfusion,
          PrefetchHooks Function({bool medicationId, bool scheduleId})
        > {
  $$PlannedInfusionsTableTableManager(
    _$AppDatabase db,
    $PlannedInfusionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedInfusionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedInfusionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedInfusionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<double> dosage = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int?> scheduleId = const Value.absent(),
              }) => PlannedInfusionsCompanion(
                id: id,
                date: date,
                medicationId: medicationId,
                dosage: dosage,
                notes: notes,
                isCompleted: isCompleted,
                scheduleId: scheduleId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int medicationId,
                required double dosage,
                Value<String?> notes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int?> scheduleId = const Value.absent(),
              }) => PlannedInfusionsCompanion.insert(
                id: id,
                date: date,
                medicationId: medicationId,
                dosage: dosage,
                notes: notes,
                isCompleted: isCompleted,
                scheduleId: scheduleId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlannedInfusionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false, scheduleId = false}) {
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
                    if (medicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationId,
                                referencedTable:
                                    $$PlannedInfusionsTableReferences
                                        ._medicationIdTable(db),
                                referencedColumn:
                                    $$PlannedInfusionsTableReferences
                                        ._medicationIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (scheduleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scheduleId,
                                referencedTable:
                                    $$PlannedInfusionsTableReferences
                                        ._scheduleIdTable(db),
                                referencedColumn:
                                    $$PlannedInfusionsTableReferences
                                        ._scheduleIdTable(db)
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

typedef $$PlannedInfusionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlannedInfusionsTable,
      PlannedInfusion,
      $$PlannedInfusionsTableFilterComposer,
      $$PlannedInfusionsTableOrderingComposer,
      $$PlannedInfusionsTableAnnotationComposer,
      $$PlannedInfusionsTableCreateCompanionBuilder,
      $$PlannedInfusionsTableUpdateCompanionBuilder,
      (PlannedInfusion, $$PlannedInfusionsTableReferences),
      PlannedInfusion,
      PrefetchHooks Function({bool medicationId, bool scheduleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$AccessoriesTableTableManager get accessories =>
      $$AccessoriesTableTableManager(_db, _db.accessories);
  $$InfusionLogTableTableManager get infusionLog =>
      $$InfusionLogTableTableManager(_db, _db.infusionLog);
  $$MedicationAccessoriesTableTableManager get medicationAccessories =>
      $$MedicationAccessoriesTableTableManager(_db, _db.medicationAccessories);
  $$InfusionSchedulesTableTableManager get infusionSchedules =>
      $$InfusionSchedulesTableTableManager(_db, _db.infusionSchedules);
  $$PlannedInfusionsTableTableManager get plannedInfusions =>
      $$PlannedInfusionsTableTableManager(_db, _db.plannedInfusions);
}
