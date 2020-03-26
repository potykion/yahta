import 'dart:io';

import 'package:moor/backends.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection() {
  /// Скопировано из туториала по moor
  /// https://moor.simonbinder.eu/docs/getting-started/#generating-the-code

  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}