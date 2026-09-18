// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CachedReviewsTable extends CachedReviews
    with TableInfo<$CachedReviewsTable, CachedReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
      'student_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _surahNumberMeta =
      const VerificationMeta('surahNumber');
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
      'surah_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ayahFromMeta =
      const VerificationMeta('ayahFrom');
  @override
  late final GeneratedColumn<int> ayahFrom = GeneratedColumn<int>(
      'ayah_from', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ayahToMeta = const VerificationMeta('ayahTo');
  @override
  late final GeneratedColumn<int> ayahTo = GeneratedColumn<int>(
      'ayah_to', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _qualityMeta =
      const VerificationMeta('quality');
  @override
  late final GeneratedColumn<String> quality = GeneratedColumn<String>(
      'quality', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _loggedAtMeta =
      const VerificationMeta('loggedAt');
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
      'logged_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pendingSyncMeta =
      const VerificationMeta('pendingSync');
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
      'pending_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pending_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        studentId,
        surahNumber,
        ayahFrom,
        ayahTo,
        quality,
        loggedAt,
        pendingSync
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_reviews';
  @override
  VerificationContext validateIntegrity(Insertable<CachedReview> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('surah_number')) {
      context.handle(
          _surahNumberMeta,
          surahNumber.isAcceptableOrUnknown(
              data['surah_number']!, _surahNumberMeta));
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_from')) {
      context.handle(_ayahFromMeta,
          ayahFrom.isAcceptableOrUnknown(data['ayah_from']!, _ayahFromMeta));
    } else if (isInserting) {
      context.missing(_ayahFromMeta);
    }
    if (data.containsKey('ayah_to')) {
      context.handle(_ayahToMeta,
          ayahTo.isAcceptableOrUnknown(data['ayah_to']!, _ayahToMeta));
    } else if (isInserting) {
      context.missing(_ayahToMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(_qualityMeta,
          quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta));
    } else if (isInserting) {
      context.missing(_qualityMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(_loggedAtMeta,
          loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta));
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
          _pendingSyncMeta,
          pendingSync.isAcceptableOrUnknown(
              data['pending_sync']!, _pendingSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedReview(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      surahNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah_number'])!,
      ayahFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_from'])!,
      ayahTo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_to'])!,
      quality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quality'])!,
      loggedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}logged_at'])!,
      pendingSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending_sync'])!,
    );
  }

  @override
  $CachedReviewsTable createAlias(String alias) {
    return $CachedReviewsTable(attachedDatabase, alias);
  }
}

class CachedReview extends DataClass implements Insertable<CachedReview> {
  final String id;
  final String studentId;
  final int surahNumber;
  final int ayahFrom;
  final int ayahTo;
  final String quality;
  final DateTime loggedAt;
  final bool pendingSync;
  const CachedReview(
      {required this.id,
      required this.studentId,
      required this.surahNumber,
      required this.ayahFrom,
      required this.ayahTo,
      required this.quality,
      required this.loggedAt,
      required this.pendingSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_from'] = Variable<int>(ayahFrom);
    map['ayah_to'] = Variable<int>(ayahTo);
    map['quality'] = Variable<String>(quality);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  CachedReviewsCompanion toCompanion(bool nullToAbsent) {
    return CachedReviewsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      surahNumber: Value(surahNumber),
      ayahFrom: Value(ayahFrom),
      ayahTo: Value(ayahTo),
      quality: Value(quality),
      loggedAt: Value(loggedAt),
      pendingSync: Value(pendingSync),
    );
  }

  factory CachedReview.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedReview(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahFrom: serializer.fromJson<int>(json['ayahFrom']),
      ayahTo: serializer.fromJson<int>(json['ayahTo']),
      quality: serializer.fromJson<String>(json['quality']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahFrom': serializer.toJson<int>(ayahFrom),
      'ayahTo': serializer.toJson<int>(ayahTo),
      'quality': serializer.toJson<String>(quality),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  CachedReview copyWith(
          {String? id,
          String? studentId,
          int? surahNumber,
          int? ayahFrom,
          int? ayahTo,
          String? quality,
          DateTime? loggedAt,
          bool? pendingSync}) =>
      CachedReview(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        surahNumber: surahNumber ?? this.surahNumber,
        ayahFrom: ayahFrom ?? this.ayahFrom,
        ayahTo: ayahTo ?? this.ayahTo,
        quality: quality ?? this.quality,
        loggedAt: loggedAt ?? this.loggedAt,
        pendingSync: pendingSync ?? this.pendingSync,
      );
  CachedReview copyWithCompanion(CachedReviewsCompanion data) {
    return CachedReview(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      surahNumber:
          data.surahNumber.present ? data.surahNumber.value : this.surahNumber,
      ayahFrom: data.ayahFrom.present ? data.ayahFrom.value : this.ayahFrom,
      ayahTo: data.ayahTo.present ? data.ayahTo.value : this.ayahTo,
      quality: data.quality.present ? data.quality.value : this.quality,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      pendingSync:
          data.pendingSync.present ? data.pendingSync.value : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedReview(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahFrom: $ayahFrom, ')
          ..write('ayahTo: $ayahTo, ')
          ..write('quality: $quality, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, surahNumber, ayahFrom, ayahTo,
      quality, loggedAt, pendingSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedReview &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.surahNumber == this.surahNumber &&
          other.ayahFrom == this.ayahFrom &&
          other.ayahTo == this.ayahTo &&
          other.quality == this.quality &&
          other.loggedAt == this.loggedAt &&
          other.pendingSync == this.pendingSync);
}

class CachedReviewsCompanion extends UpdateCompanion<CachedReview> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<int> surahNumber;
  final Value<int> ayahFrom;
  final Value<int> ayahTo;
  final Value<String> quality;
  final Value<DateTime> loggedAt;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const CachedReviewsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahFrom = const Value.absent(),
    this.ayahTo = const Value.absent(),
    this.quality = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedReviewsCompanion.insert({
    required String id,
    required String studentId,
    required int surahNumber,
    required int ayahFrom,
    required int ayahTo,
    required String quality,
    required DateTime loggedAt,
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        studentId = Value(studentId),
        surahNumber = Value(surahNumber),
        ayahFrom = Value(ayahFrom),
        ayahTo = Value(ayahTo),
        quality = Value(quality),
        loggedAt = Value(loggedAt);
  static Insertable<CachedReview> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<int>? surahNumber,
    Expression<int>? ayahFrom,
    Expression<int>? ayahTo,
    Expression<String>? quality,
    Expression<DateTime>? loggedAt,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahFrom != null) 'ayah_from': ayahFrom,
      if (ayahTo != null) 'ayah_to': ayahTo,
      if (quality != null) 'quality': quality,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedReviewsCompanion copyWith(
      {Value<String>? id,
      Value<String>? studentId,
      Value<int>? surahNumber,
      Value<int>? ayahFrom,
      Value<int>? ayahTo,
      Value<String>? quality,
      Value<DateTime>? loggedAt,
      Value<bool>? pendingSync,
      Value<int>? rowid}) {
    return CachedReviewsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahFrom: ayahFrom ?? this.ayahFrom,
      ayahTo: ayahTo ?? this.ayahTo,
      quality: quality ?? this.quality,
      loggedAt: loggedAt ?? this.loggedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahFrom.present) {
      map['ayah_from'] = Variable<int>(ayahFrom.value);
    }
    if (ayahTo.present) {
      map['ayah_to'] = Variable<int>(ayahTo.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(quality.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedReviewsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahFrom: $ayahFrom, ')
          ..write('ayahTo: $ayahTo, ')
          ..write('quality: $quality, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxItemsTable extends OutboxItems
    with TableInfo<$OutboxItemsTable, OutboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, idempotencyKey, payloadJson, attempts, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_items';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxItemsTable createAlias(String alias) {
    return $OutboxItemsTable(attachedDatabase, alias);
  }
}

class OutboxItem extends DataClass implements Insertable<OutboxItem> {
  final int id;
  final String idempotencyKey;
  final String payloadJson;
  final int attempts;
  final DateTime createdAt;
  const OutboxItem(
      {required this.id,
      required this.idempotencyKey,
      required this.payloadJson,
      required this.attempts,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxItemsCompanion toCompanion(bool nullToAbsent) {
    return OutboxItemsCompanion(
      id: Value(id),
      idempotencyKey: Value(idempotencyKey),
      payloadJson: Value(payloadJson),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxItem(
      id: serializer.fromJson<int>(json['id']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxItem copyWith(
          {int? id,
          String? idempotencyKey,
          String? payloadJson,
          int? attempts,
          DateTime? createdAt}) =>
      OutboxItem(
        id: id ?? this.id,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        payloadJson: payloadJson ?? this.payloadJson,
        attempts: attempts ?? this.attempts,
        createdAt: createdAt ?? this.createdAt,
      );
  OutboxItem copyWithCompanion(OutboxItemsCompanion data) {
    return OutboxItem(
      id: data.id.present ? data.id.value : this.id,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItem(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, idempotencyKey, payloadJson, attempts, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxItem &&
          other.id == this.id &&
          other.idempotencyKey == this.idempotencyKey &&
          other.payloadJson == this.payloadJson &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt);
}

class OutboxItemsCompanion extends UpdateCompanion<OutboxItem> {
  final Value<int> id;
  final Value<String> idempotencyKey;
  final Value<String> payloadJson;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  const OutboxItemsCompanion({
    this.id = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxItemsCompanion.insert({
    this.id = const Value.absent(),
    required String idempotencyKey,
    required String payloadJson,
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : idempotencyKey = Value(idempotencyKey),
        payloadJson = Value(payloadJson);
  static Insertable<OutboxItem> custom({
    Expression<int>? id,
    Expression<String>? idempotencyKey,
    Expression<String>? payloadJson,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? idempotencyKey,
      Value<String>? payloadJson,
      Value<int>? attempts,
      Value<DateTime>? createdAt}) {
    return OutboxItemsCompanion(
      id: id ?? this.id,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      payloadJson: payloadJson ?? this.payloadJson,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedReviewsTable cachedReviews = $CachedReviewsTable(this);
  late final $OutboxItemsTable outboxItems = $OutboxItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cachedReviews, outboxItems];
}

typedef $$CachedReviewsTableCreateCompanionBuilder = CachedReviewsCompanion
    Function({
  required String id,
  required String studentId,
  required int surahNumber,
  required int ayahFrom,
  required int ayahTo,
  required String quality,
  required DateTime loggedAt,
  Value<bool> pendingSync,
  Value<int> rowid,
});
typedef $$CachedReviewsTableUpdateCompanionBuilder = CachedReviewsCompanion
    Function({
  Value<String> id,
  Value<String> studentId,
  Value<int> surahNumber,
  Value<int> ayahFrom,
  Value<int> ayahTo,
  Value<String> quality,
  Value<DateTime> loggedAt,
  Value<bool> pendingSync,
  Value<int> rowid,
});

class $$CachedReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedReviewsTable> {
  $$CachedReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahFrom => $composableBuilder(
      column: $table.ayahFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahTo => $composableBuilder(
      column: $table.ayahTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
      column: $table.loggedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnFilters(column));
}

class $$CachedReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedReviewsTable> {
  $$CachedReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahFrom => $composableBuilder(
      column: $table.ayahFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahTo => $composableBuilder(
      column: $table.ayahTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
      column: $table.loggedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnOrderings(column));
}

class $$CachedReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedReviewsTable> {
  $$CachedReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => column);

  GeneratedColumn<int> get ayahFrom =>
      $composableBuilder(column: $table.ayahFrom, builder: (column) => column);

  GeneratedColumn<int> get ayahTo =>
      $composableBuilder(column: $table.ayahTo, builder: (column) => column);

  GeneratedColumn<String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => column);
}

class $$CachedReviewsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedReviewsTable,
    CachedReview,
    $$CachedReviewsTableFilterComposer,
    $$CachedReviewsTableOrderingComposer,
    $$CachedReviewsTableAnnotationComposer,
    $$CachedReviewsTableCreateCompanionBuilder,
    $$CachedReviewsTableUpdateCompanionBuilder,
    (
      CachedReview,
      BaseReferences<_$AppDatabase, $CachedReviewsTable, CachedReview>
    ),
    CachedReview,
    PrefetchHooks Function()> {
  $$CachedReviewsTableTableManager(_$AppDatabase db, $CachedReviewsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<int> surahNumber = const Value.absent(),
            Value<int> ayahFrom = const Value.absent(),
            Value<int> ayahTo = const Value.absent(),
            Value<String> quality = const Value.absent(),
            Value<DateTime> loggedAt = const Value.absent(),
            Value<bool> pendingSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedReviewsCompanion(
            id: id,
            studentId: studentId,
            surahNumber: surahNumber,
            ayahFrom: ayahFrom,
            ayahTo: ayahTo,
            quality: quality,
            loggedAt: loggedAt,
            pendingSync: pendingSync,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String studentId,
            required int surahNumber,
            required int ayahFrom,
            required int ayahTo,
            required String quality,
            required DateTime loggedAt,
            Value<bool> pendingSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedReviewsCompanion.insert(
            id: id,
            studentId: studentId,
            surahNumber: surahNumber,
            ayahFrom: ayahFrom,
            ayahTo: ayahTo,
            quality: quality,
            loggedAt: loggedAt,
            pendingSync: pendingSync,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CachedReviewsTable, CachedReview>(table),
                    BaseReferences<_$AppDatabase, $CachedReviewsTable,
                        CachedReview>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedReviewsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedReviewsTable,
    CachedReview,
    $$CachedReviewsTableFilterComposer,
    $$CachedReviewsTableOrderingComposer,
    $$CachedReviewsTableAnnotationComposer,
    $$CachedReviewsTableCreateCompanionBuilder,
    $$CachedReviewsTableUpdateCompanionBuilder,
    (
      CachedReview,
      BaseReferences<_$AppDatabase, $CachedReviewsTable, CachedReview>
    ),
    CachedReview,
    PrefetchHooks Function()>;
typedef $$OutboxItemsTableCreateCompanionBuilder = OutboxItemsCompanion
    Function({
  Value<int> id,
  required String idempotencyKey,
  required String payloadJson,
  Value<int> attempts,
  Value<DateTime> createdAt,
});
typedef $$OutboxItemsTableUpdateCompanionBuilder = OutboxItemsCompanion
    Function({
  Value<int> id,
  Value<String> idempotencyKey,
  Value<String> payloadJson,
  Value<int> attempts,
  Value<DateTime> createdAt,
});

class $$OutboxItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxItemsTable> {
  $$OutboxItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxItemsTable> {
  $$OutboxItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxItemsTable> {
  $$OutboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxItemsTable,
    OutboxItem,
    $$OutboxItemsTableFilterComposer,
    $$OutboxItemsTableOrderingComposer,
    $$OutboxItemsTableAnnotationComposer,
    $$OutboxItemsTableCreateCompanionBuilder,
    $$OutboxItemsTableUpdateCompanionBuilder,
    (OutboxItem, BaseReferences<_$AppDatabase, $OutboxItemsTable, OutboxItem>),
    OutboxItem,
    PrefetchHooks Function()> {
  $$OutboxItemsTableTableManager(_$AppDatabase db, $OutboxItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxItemsCompanion(
            id: id,
            idempotencyKey: idempotencyKey,
            payloadJson: payloadJson,
            attempts: attempts,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String idempotencyKey,
            required String payloadJson,
            Value<int> attempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxItemsCompanion.insert(
            id: id,
            idempotencyKey: idempotencyKey,
            payloadJson: payloadJson,
            attempts: attempts,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OutboxItemsTable, OutboxItem>(table),
                    BaseReferences<_$AppDatabase, $OutboxItemsTable,
                        OutboxItem>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxItemsTable,
    OutboxItem,
    $$OutboxItemsTableFilterComposer,
    $$OutboxItemsTableOrderingComposer,
    $$OutboxItemsTableAnnotationComposer,
    $$OutboxItemsTableCreateCompanionBuilder,
    $$OutboxItemsTableUpdateCompanionBuilder,
    (OutboxItem, BaseReferences<_$AppDatabase, $OutboxItemsTable, OutboxItem>),
    OutboxItem,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedReviewsTableTableManager get cachedReviews =>
      $$CachedReviewsTableTableManager(_db, _db.cachedReviews);
  $$OutboxItemsTableTableManager get outboxItems =>
      $$OutboxItemsTableTableManager(_db, _db.outboxItems);
}
