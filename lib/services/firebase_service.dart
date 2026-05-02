import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  static Future<void> savePrediction({
    required String imageName,
    required String result, // 'pass' or 'fail'
    String? defectType, // null if pass, else defect type
    String? imageData,
    required DateTime timestamp,
  }) async {
    final record = {
      'imageName': imageName,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
      'imageData': imageData,
    };

    if (result == 'pass') {
      final ref = _database.ref('predictions/pass').push();
      await ref.set(record);
    } else {
      final formattedType = defectType?.toLowerCase().replaceAll(' ', '_') ?? 'unknown';
      final category = ['open_circuit', 'missing_hole', 'mouse_bite'].contains(formattedType)
          ? formattedType
          : 'other';
      final ref = _database.ref('predictions/fail/$category').push();
      await ref.set({
        ...record,
        'defectType': defectType,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPredictions(String path) async {
    final snapshot = await _database.ref(path).get();
    if (!snapshot.exists) {
      return [];
    }

    final List<Map<String, dynamic>> records = [];
    for (final child in snapshot.children) {
      final value = child.value;
      if (value is Map<Object?, dynamic>) {
        final map = value.map((key, value) => MapEntry(key.toString(), value));
        records.add({
          'id': child.key,
          'dbPath': '$path/${child.key}',
          ...map,
        });
      }
    }
    return records;
  }

  static Future<List<Map<String, dynamic>>> fetchPassPredictions() async {
    return fetchPredictions('predictions/pass');
  }

 static Future<List<Map<String, dynamic>>> fetchFailPredictions(
      String category) async {
    return fetchPredictions('predictions/fail/$category');
  }

  // ── NEW: Fetch recent predictions for home page dashboard ──
 // Replace your existing fetchRecentPredictions with this one!
  static Future<List<Map<String, dynamic>>> fetchRecentPredictions({int limit = 3}) async {
    try {
      final List<Map<String, dynamic>> all = [];

      // 1. Tell Firebase to ONLY send the last few records
      final passSnap = await _database.ref('predictions/pass')
          .orderByChild('timestamp')
          .limitToLast(limit) // <-- THIS IS THE MAGIC FIX
          .get();
          
      if (passSnap.exists) {
        for (final child in passSnap.children) {
          final value = child.value;
          if (value is Map<Object?, dynamic>) {
            final map = value.map((key, val) => MapEntry(key.toString(), val));
            all.add({'id': child.key, 'result': 'pass', ...map});
          }
        }
      }

      // 2. Do the exact same for fails
      final categories = ['open_circuit', 'missing_hole', 'mouse_bite', 'other'];
      for (final category in categories) {
        final failSnap = await _database.ref('predictions/fail/$category')
            .orderByChild('timestamp')
            .limitToLast(limit) // <-- MAGIC FIX AGAIN
            .get();
            
        if (failSnap.exists) {
          for (final child in failSnap.children) {
            final value = child.value;
            if (value is Map<Object?, dynamic>) {
              final map = value.map((key, val) => MapEntry(key.toString(), val));
              all.add({'id': child.key, 'result': 'fail', 'defectType': category, ...map});
            }
          }
        }
      }

      // Sort and return
      all.sort((a, b) {
        final tA = a['timestamp']?.toString() ?? '';
        final tB = b['timestamp']?.toString() ?? '';
        return tB.compareTo(tA);
      });

      return all.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<int> countPass() async {
    final snapshot = await _database.ref('predictions/pass').get();
    if (!snapshot.exists) {
      return 0;
    }
    return snapshot.children.length;
  }

  static Future<int> countFail() async {
    final snapshot = await _database.ref('predictions/fail').get();
    if (!snapshot.exists) {
      return 0;
    }
    int count = 0;
    for (final child in snapshot.children) {
      count += child.children.length;
    }
    return count;
  }

  static Future<void> deletePrediction(String dbPath) async {
    await _database.ref(dbPath).remove();
  }

  static Future<String> updatePrediction({
    required String dbPath,
    String? timestamp,
    String? defectType,
    String? result,
  }) async {
    final ref = _database.ref(dbPath);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      throw Exception('Record not found');
    }

    final currentValue = snapshot.value;
    if (currentValue is! Map<Object?, dynamic>) {
      throw Exception('Invalid record format');
    }

    final current = currentValue.map((key, value) => MapEntry(key.toString(), value));
    final updated = Map<String, dynamic>.from(current);

    if (timestamp != null) {
      updated['timestamp'] = timestamp;
    }
    if (defectType != null) {
      updated['defectType'] = defectType;
    }
    if (result != null) {
      updated['result'] = result;
    }

    final pathParts = dbPath.split('/');
    if (pathParts.length >= 4 && pathParts[0] == 'predictions' && pathParts[1] == 'fail') {
      final currentCategory = pathParts[2];
      final newCategory = defectType?.toLowerCase().replaceAll(' ', '_');
      if (newCategory != null && newCategory != currentCategory && ['open_circuit', 'missing_hole', 'mouse_bite'].contains(newCategory)) {
        final newPath = 'predictions/fail/$newCategory/${pathParts.last}';
        final newRef = _database.ref(newPath);
        await newRef.set(updated);
        await ref.remove();
        return newPath;
      }
    }

    if (pathParts.length >= 3 && pathParts[0] == 'predictions' && pathParts[1] == 'pass' && defectType != null) {
      final newCategory = defectType.toLowerCase().replaceAll(' ', '_');
      if (['open_circuit', 'missing_hole', 'mouse_bite'].contains(newCategory)) {
        updated['result'] = 'fail';
        updated['defectType'] = defectType;
        final newPath = 'predictions/fail/$newCategory/${pathParts.last}';
        final newRef = _database.ref(newPath);
        await newRef.set(updated);
        await ref.remove();
        return newPath;
      }
    }

    await ref.update(updated);
    return dbPath;
  }

  static Future<Map<String, int>> countFailCategories() async {
    final snapshot = await _database.ref('predictions/fail').get();
    final Map<String, int> counts = {
      'open_circuit': 0,
      'missing_hole': 0,
      'mouse_bite': 0,
      'other': 0,
    };

    if (!snapshot.exists) {
      return counts;
    }

    for (final child in snapshot.children) {
      final key = child.key;
      if (key != null) {
        counts[key] = child.children.length;
      }
    }

    return counts;
  }
}
