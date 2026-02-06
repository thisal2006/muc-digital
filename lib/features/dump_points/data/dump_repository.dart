import 'package:firebase_database/firebase_database.dart';
import '../domain/dump_point.dart';

class DumpRepository {

  final DatabaseReference _dumpRef =
  FirebaseDatabase.instance.ref('dump_points');

  Stream<List<DumpPoint>> watchDumpPoints() {

    return _dumpRef.onValue.map((event) {

      final data = event.snapshot.value;

      if (data == null) return [];

      final map = Map<String, dynamic>.from(data as Map);

      return map.entries.map((entry) {

        return DumpPoint.fromMap(
          entry.key,
          Map<String, dynamic>.from(entry.value),
        );

      }).toList();
    });
  }
}
