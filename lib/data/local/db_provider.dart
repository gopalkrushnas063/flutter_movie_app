import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/data/local/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});