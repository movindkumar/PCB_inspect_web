import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart'; // already there

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage, returns download URL
 // ✅ REPLACE WITH THIS
static Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
  try {
    final ref = _storage.ref().child('pcb_images/$fileName');
    final uploadTask = await ref.putData(imageBytes)
        .timeout(const Duration(seconds: 10));
    return await uploadTask.ref.getDownloadURL();
  } catch (e) {
    return null;
  }
}

  static Future<void> savePrediction({
    required String imageName,
    required String result,
    String? defectType,
    String? imageUrl,
    required DateTime timestamp,
  }) async {
    final record = {
      'imageName': imageName,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': ?imageUrl,
    };

    if (result == 'pass') {
      final ref = _database.ref('predictions/pass').push();
      await ref.set(record);
    } else {
      final formattedType = defectType
          ?.toLowerCase()
          .replaceAll(' ', '_') ?? 'other';

      const validCategories = ['open_circuit', 'missing_hole', 'mouse_bite'];
      final category = validCategories.contains(formattedType)
          ? formattedType
          : 'other';

      final ref = _database.ref('predictions/fail/$category').push();
      await ref.set({
        ...record,
        'defectType': formattedType,
      });
    }

    // Update counters
    final countRef = _database.ref('counts/${result == 'pass' ? 'pass' : 'fail'}');
    final countSnap = await countRef.get();
    final current = (countSnap.value as int?) ?? 0;
    await countRef.set(current + 1);
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

  static Future<List<Map<String, dynamic>>> fetchAllFailPredictions() async {
    final snapshot = await _database.ref('predictions/fail').get();
    if (!snapshot.exists) return [];

    final List<Map<String, dynamic>> records = [];
    for (final categorySnapshot in snapshot.children) {
      final categoryName = categorySnapshot.key;
      for (final child in categorySnapshot.children) {
        final value = child.value;
        if (value is Map<Object?, dynamic>) {
          final map = value.map((key, val) => MapEntry(key.toString(), val));
          records.add({
            'id': child.key,
            'dbPath': 'predictions/fail/$categoryName/${child.key}',
            'defectType': categoryName,
            ...map,
          });
        }
      }
    }
    return records;
  }

  static Future<List<Map<String, dynamic>>> fetchRecentPredictions({int limit = 3}) async {
    try {
      final categories = ['open_circuit', 'missing_hole', 'mouse_bite', 'other'];

      final snapshots = await Future.wait([
        _database.ref('predictions/pass')
            .orderByChild('timestamp')
            .limitToLast(limit)
            .get(),
        ...categories.map((cat) => _database
            .ref('predictions/fail/$cat')
            .orderByChild('timestamp')
            .limitToLast(limit)
            .get()),
      ]);

      final List<Map<String, dynamic>> all = [];

      if (snapshots[0].exists) {
        for (final child in snapshots[0].children) {
          final value = child.value;
          if (value is Map<Object?, dynamic>) {
            all.add({
              'id': child.key,
              'result': 'pass',
              ...value.map((k, v) => MapEntry(k.toString(), v)),
            });
          }
        }
      }

      for (int i = 0; i < categories.length; i++) {
        final snap = snapshots[i + 1];
        if (snap.exists) {
          for (final child in snap.children) {
            final value = child.value;
            if (value is Map<Object?, dynamic>) {
              all.add({
                'id': child.key,
                'result': 'fail',
                'defectType': categories[i],
                ...value.map((k, v) => MapEntry(k.toString(), v)),
              });
            }
          }
        }
      }

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
    final snap = await _database.ref('counts/pass').get();
    return (snap.value as int?) ?? 0;
  }

  static Future<int> countFail() async {
    final snap = await _database.ref('counts/fail').get();
    return (snap.value as int?) ?? 0;
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