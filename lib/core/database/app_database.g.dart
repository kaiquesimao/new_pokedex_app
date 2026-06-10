// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedPokemonEntriesTable extends CachedPokemonEntries
    with TableInfo<$CachedPokemonEntriesTable, CachedPokemonEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPokemonEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typesJsonMeta = const VerificationMeta(
    'typesJson',
  );
  @override
  late final GeneratedColumn<String> typesJson = GeneratedColumn<String>(
    'types_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spriteUrlMeta = const VerificationMeta(
    'spriteUrl',
  );
  @override
  late final GeneratedColumn<String> spriteUrl = GeneratedColumn<String>(
    'sprite_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailJsonMeta = const VerificationMeta(
    'detailJson',
  );
  @override
  late final GeneratedColumn<String> detailJson = GeneratedColumn<String>(
    'detail_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    typesJson,
    spriteUrl,
    detailJson,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_pokemon_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPokemonEntry> instance, {
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
    if (data.containsKey('types_json')) {
      context.handle(
        _typesJsonMeta,
        typesJson.isAcceptableOrUnknown(data['types_json']!, _typesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_typesJsonMeta);
    }
    if (data.containsKey('sprite_url')) {
      context.handle(
        _spriteUrlMeta,
        spriteUrl.isAcceptableOrUnknown(data['sprite_url']!, _spriteUrlMeta),
      );
    }
    if (data.containsKey('detail_json')) {
      context.handle(
        _detailJsonMeta,
        detailJson.isAcceptableOrUnknown(data['detail_json']!, _detailJsonMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPokemonEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPokemonEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      typesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}types_json'],
      )!,
      spriteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sprite_url'],
      ),
      detailJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail_json'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedPokemonEntriesTable createAlias(String alias) {
    return $CachedPokemonEntriesTable(attachedDatabase, alias);
  }
}

class CachedPokemonEntry extends DataClass
    implements Insertable<CachedPokemonEntry> {
  final int id;
  final String name;
  final String typesJson;
  final String? spriteUrl;
  final String? detailJson;
  final DateTime cachedAt;
  const CachedPokemonEntry({
    required this.id,
    required this.name,
    required this.typesJson,
    this.spriteUrl,
    this.detailJson,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['types_json'] = Variable<String>(typesJson);
    if (!nullToAbsent || spriteUrl != null) {
      map['sprite_url'] = Variable<String>(spriteUrl);
    }
    if (!nullToAbsent || detailJson != null) {
      map['detail_json'] = Variable<String>(detailJson);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedPokemonEntriesCompanion toCompanion(bool nullToAbsent) {
    return CachedPokemonEntriesCompanion(
      id: Value(id),
      name: Value(name),
      typesJson: Value(typesJson),
      spriteUrl: spriteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(spriteUrl),
      detailJson: detailJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedPokemonEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPokemonEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      typesJson: serializer.fromJson<String>(json['typesJson']),
      spriteUrl: serializer.fromJson<String?>(json['spriteUrl']),
      detailJson: serializer.fromJson<String?>(json['detailJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'typesJson': serializer.toJson<String>(typesJson),
      'spriteUrl': serializer.toJson<String?>(spriteUrl),
      'detailJson': serializer.toJson<String?>(detailJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedPokemonEntry copyWith({
    int? id,
    String? name,
    String? typesJson,
    Value<String?> spriteUrl = const Value.absent(),
    Value<String?> detailJson = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedPokemonEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    typesJson: typesJson ?? this.typesJson,
    spriteUrl: spriteUrl.present ? spriteUrl.value : this.spriteUrl,
    detailJson: detailJson.present ? detailJson.value : this.detailJson,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedPokemonEntry copyWithCompanion(CachedPokemonEntriesCompanion data) {
    return CachedPokemonEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      typesJson: data.typesJson.present ? data.typesJson.value : this.typesJson,
      spriteUrl: data.spriteUrl.present ? data.spriteUrl.value : this.spriteUrl,
      detailJson: data.detailJson.present
          ? data.detailJson.value
          : this.detailJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPokemonEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typesJson: $typesJson, ')
          ..write('spriteUrl: $spriteUrl, ')
          ..write('detailJson: $detailJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, typesJson, spriteUrl, detailJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPokemonEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.typesJson == this.typesJson &&
          other.spriteUrl == this.spriteUrl &&
          other.detailJson == this.detailJson &&
          other.cachedAt == this.cachedAt);
}

class CachedPokemonEntriesCompanion
    extends UpdateCompanion<CachedPokemonEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> typesJson;
  final Value<String?> spriteUrl;
  final Value<String?> detailJson;
  final Value<DateTime> cachedAt;
  const CachedPokemonEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.typesJson = const Value.absent(),
    this.spriteUrl = const Value.absent(),
    this.detailJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedPokemonEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String typesJson,
    this.spriteUrl = const Value.absent(),
    this.detailJson = const Value.absent(),
    required DateTime cachedAt,
  }) : name = Value(name),
       typesJson = Value(typesJson),
       cachedAt = Value(cachedAt);
  static Insertable<CachedPokemonEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? typesJson,
    Expression<String>? spriteUrl,
    Expression<String>? detailJson,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (typesJson != null) 'types_json': typesJson,
      if (spriteUrl != null) 'sprite_url': spriteUrl,
      if (detailJson != null) 'detail_json': detailJson,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedPokemonEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? typesJson,
    Value<String?>? spriteUrl,
    Value<String?>? detailJson,
    Value<DateTime>? cachedAt,
  }) {
    return CachedPokemonEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      typesJson: typesJson ?? this.typesJson,
      spriteUrl: spriteUrl ?? this.spriteUrl,
      detailJson: detailJson ?? this.detailJson,
      cachedAt: cachedAt ?? this.cachedAt,
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
    if (typesJson.present) {
      map['types_json'] = Variable<String>(typesJson.value);
    }
    if (spriteUrl.present) {
      map['sprite_url'] = Variable<String>(spriteUrl.value);
    }
    if (detailJson.present) {
      map['detail_json'] = Variable<String>(detailJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPokemonEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typesJson: $typesJson, ')
          ..write('spriteUrl: $spriteUrl, ')
          ..write('detailJson: $detailJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $PokemonNameIndexTable extends PokemonNameIndex
    with TableInfo<$PokemonNameIndexTable, PokemonNameIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonNameIndexTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_name_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonNameIndexData> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokemonNameIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonNameIndexData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $PokemonNameIndexTable createAlias(String alias) {
    return $PokemonNameIndexTable(attachedDatabase, alias);
  }
}

class PokemonNameIndexData extends DataClass
    implements Insertable<PokemonNameIndexData> {
  final int id;
  final String name;
  const PokemonNameIndexData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  PokemonNameIndexCompanion toCompanion(bool nullToAbsent) {
    return PokemonNameIndexCompanion(id: Value(id), name: Value(name));
  }

  factory PokemonNameIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonNameIndexData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  PokemonNameIndexData copyWith({int? id, String? name}) =>
      PokemonNameIndexData(id: id ?? this.id, name: name ?? this.name);
  PokemonNameIndexData copyWithCompanion(PokemonNameIndexCompanion data) {
    return PokemonNameIndexData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonNameIndexData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonNameIndexData &&
          other.id == this.id &&
          other.name == this.name);
}

class PokemonNameIndexCompanion extends UpdateCompanion<PokemonNameIndexData> {
  final Value<int> id;
  final Value<String> name;
  const PokemonNameIndexCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  PokemonNameIndexCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<PokemonNameIndexData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  PokemonNameIndexCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return PokemonNameIndexCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonNameIndexCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedPokemonEntriesTable cachedPokemonEntries =
      $CachedPokemonEntriesTable(this);
  late final $PokemonNameIndexTable pokemonNameIndex = $PokemonNameIndexTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedPokemonEntries,
    pokemonNameIndex,
  ];
}

typedef $$CachedPokemonEntriesTableCreateCompanionBuilder =
    CachedPokemonEntriesCompanion Function({
      Value<int> id,
      required String name,
      required String typesJson,
      Value<String?> spriteUrl,
      Value<String?> detailJson,
      required DateTime cachedAt,
    });
typedef $$CachedPokemonEntriesTableUpdateCompanionBuilder =
    CachedPokemonEntriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> typesJson,
      Value<String?> spriteUrl,
      Value<String?> detailJson,
      Value<DateTime> cachedAt,
    });

class $$CachedPokemonEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPokemonEntriesTable> {
  $$CachedPokemonEntriesTableFilterComposer({
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

  ColumnFilters<String> get typesJson => $composableBuilder(
    column: $table.typesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spriteUrl => $composableBuilder(
    column: $table.spriteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPokemonEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPokemonEntriesTable> {
  $$CachedPokemonEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get typesJson => $composableBuilder(
    column: $table.typesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spriteUrl => $composableBuilder(
    column: $table.spriteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPokemonEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPokemonEntriesTable> {
  $$CachedPokemonEntriesTableAnnotationComposer({
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

  GeneratedColumn<String> get typesJson =>
      $composableBuilder(column: $table.typesJson, builder: (column) => column);

  GeneratedColumn<String> get spriteUrl =>
      $composableBuilder(column: $table.spriteUrl, builder: (column) => column);

  GeneratedColumn<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedPokemonEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPokemonEntriesTable,
          CachedPokemonEntry,
          $$CachedPokemonEntriesTableFilterComposer,
          $$CachedPokemonEntriesTableOrderingComposer,
          $$CachedPokemonEntriesTableAnnotationComposer,
          $$CachedPokemonEntriesTableCreateCompanionBuilder,
          $$CachedPokemonEntriesTableUpdateCompanionBuilder,
          (
            CachedPokemonEntry,
            BaseReferences<
              _$AppDatabase,
              $CachedPokemonEntriesTable,
              CachedPokemonEntry
            >,
          ),
          CachedPokemonEntry,
          PrefetchHooks Function()
        > {
  $$CachedPokemonEntriesTableTableManager(
    _$AppDatabase db,
    $CachedPokemonEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPokemonEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPokemonEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedPokemonEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> typesJson = const Value.absent(),
                Value<String?> spriteUrl = const Value.absent(),
                Value<String?> detailJson = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => CachedPokemonEntriesCompanion(
                id: id,
                name: name,
                typesJson: typesJson,
                spriteUrl: spriteUrl,
                detailJson: detailJson,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String typesJson,
                Value<String?> spriteUrl = const Value.absent(),
                Value<String?> detailJson = const Value.absent(),
                required DateTime cachedAt,
              }) => CachedPokemonEntriesCompanion.insert(
                id: id,
                name: name,
                typesJson: typesJson,
                spriteUrl: spriteUrl,
                detailJson: detailJson,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPokemonEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPokemonEntriesTable,
      CachedPokemonEntry,
      $$CachedPokemonEntriesTableFilterComposer,
      $$CachedPokemonEntriesTableOrderingComposer,
      $$CachedPokemonEntriesTableAnnotationComposer,
      $$CachedPokemonEntriesTableCreateCompanionBuilder,
      $$CachedPokemonEntriesTableUpdateCompanionBuilder,
      (
        CachedPokemonEntry,
        BaseReferences<
          _$AppDatabase,
          $CachedPokemonEntriesTable,
          CachedPokemonEntry
        >,
      ),
      CachedPokemonEntry,
      PrefetchHooks Function()
    >;
typedef $$PokemonNameIndexTableCreateCompanionBuilder =
    PokemonNameIndexCompanion Function({Value<int> id, required String name});
typedef $$PokemonNameIndexTableUpdateCompanionBuilder =
    PokemonNameIndexCompanion Function({Value<int> id, Value<String> name});

class $$PokemonNameIndexTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonNameIndexTable> {
  $$PokemonNameIndexTableFilterComposer({
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
}

class $$PokemonNameIndexTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonNameIndexTable> {
  $$PokemonNameIndexTableOrderingComposer({
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
}

class $$PokemonNameIndexTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonNameIndexTable> {
  $$PokemonNameIndexTableAnnotationComposer({
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
}

class $$PokemonNameIndexTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonNameIndexTable,
          PokemonNameIndexData,
          $$PokemonNameIndexTableFilterComposer,
          $$PokemonNameIndexTableOrderingComposer,
          $$PokemonNameIndexTableAnnotationComposer,
          $$PokemonNameIndexTableCreateCompanionBuilder,
          $$PokemonNameIndexTableUpdateCompanionBuilder,
          (
            PokemonNameIndexData,
            BaseReferences<
              _$AppDatabase,
              $PokemonNameIndexTable,
              PokemonNameIndexData
            >,
          ),
          PokemonNameIndexData,
          PrefetchHooks Function()
        > {
  $$PokemonNameIndexTableTableManager(
    _$AppDatabase db,
    $PokemonNameIndexTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonNameIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonNameIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonNameIndexTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => PokemonNameIndexCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  PokemonNameIndexCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PokemonNameIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonNameIndexTable,
      PokemonNameIndexData,
      $$PokemonNameIndexTableFilterComposer,
      $$PokemonNameIndexTableOrderingComposer,
      $$PokemonNameIndexTableAnnotationComposer,
      $$PokemonNameIndexTableCreateCompanionBuilder,
      $$PokemonNameIndexTableUpdateCompanionBuilder,
      (
        PokemonNameIndexData,
        BaseReferences<
          _$AppDatabase,
          $PokemonNameIndexTable,
          PokemonNameIndexData
        >,
      ),
      PokemonNameIndexData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedPokemonEntriesTableTableManager get cachedPokemonEntries =>
      $$CachedPokemonEntriesTableTableManager(_db, _db.cachedPokemonEntries);
  $$PokemonNameIndexTableTableManager get pokemonNameIndex =>
      $$PokemonNameIndexTableTableManager(_db, _db.pokemonNameIndex);
}
