import 'package:drift/drift.dart';

class CachedReviews extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahFrom => integer()();
  IntColumn get ayahTo => integer()();
  TextColumn get quality => text()();
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class OutboxItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idempotencyKey => text()();
  TextColumn get payloadJson => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
