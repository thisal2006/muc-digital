import 'package:firebase_database/firebase_database.dart';
import '../domain/dump_point.dart';

class DumpRepository {
  final _db = FirebaseDatabase.instance.ref("dump_points");

  Stream<List<DumpPoint>> watchDumpPoints() {
    return _db.onValue.map((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      return data.entries.map((entry) {
        return DumpPoint.fromMap(
          entry.key,
          Map<String, dynamic>.from(entry.value),
        );
      }).toList();
    });
  }
}
