import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/data/local/db_provider.dart';

final unsyncedCountProvider = StreamProvider<int>((ref) {
  final database = ref.watch(databaseProvider);
  return database.watchUnsyncedUsersCount();
});