import 'package:flutter/material.dart';

import 'category_details_page.dart';
import 'services/firebase_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class PredictionRecord {
  final String id;
  final String dbPath;
  final String imageName;
  final String result;
  final String timestamp;
  final String? defectType;
  final String? imageData;

  PredictionRecord({
    required this.id,
    required this.dbPath,
    required this.imageName,
    required this.result,
    required this.timestamp,
    this.defectType,
    this.imageData,
  });

  factory PredictionRecord.fromMap(Map<String, dynamic> map) {
    return PredictionRecord(
      id: map['id']?.toString() ?? '',
      dbPath: map['dbPath']?.toString() ?? '',
      imageName: map['imageName']?.toString() ?? 'unknown',
      result: map['result']?.toString() ?? 'unknown',
      timestamp: map['timestamp']?.toString() ?? '',
      defectType: map['defectType']?.toString(),
      imageData: map['imageData']?.toString(),
    );
  }
}

class _StatsPageState extends State<StatsPage> {
  bool _isLoading = true;
  String? _error;
  int _passCount = 0;
  int _failCount = 0;
  Map<String, int> _categoryCounts = {
    'open_circuit': 0,
    'missing_hole': 0,
    'mouse_bite': 0,
    'other': 0,
  };
  List<PredictionRecord> _passPredictions = [];
  Map<String, List<PredictionRecord>> _failPredictions = {
    'open_circuit': [],
    'missing_hole': [],
    'mouse_bite': [],
    'other': [],
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        FirebaseService.countPass(),
        FirebaseService.countFail(),
        FirebaseService.countFailCategories(),
        FirebaseService.fetchPassPredictions(),
        FirebaseService.fetchFailPredictions('open_circuit'),
        FirebaseService.fetchFailPredictions('missing_hole'),
        FirebaseService.fetchFailPredictions('mouse_bite'),
        FirebaseService.fetchFailPredictions('other'),
      ]).timeout(const Duration(seconds: 25));

      final passCount = results[0] as int;
      final failCount = results[1] as int;
      final categoryCounts = results[2] as Map<String, int>;
      final passPredictions = results[3] as List<Map<String, dynamic>>;
      final openCircuit = results[4] as List<Map<String, dynamic>>;
      final missingHole = results[5] as List<Map<String, dynamic>>;
      final mouseBite = results[6] as List<Map<String, dynamic>>;
      final other = results[7] as List<Map<String, dynamic>>;

      setState(() {
        _passCount = passCount;
        _failCount = failCount;
        _categoryCounts = {
          'open_circuit': categoryCounts['open_circuit'] ?? 0,
          'missing_hole': categoryCounts['missing_hole'] ?? 0,
          'mouse_bite': categoryCounts['mouse_bite'] ?? 0,
          'other': categoryCounts['other'] ?? 0,
        };
        _passPredictions = passPredictions.map(PredictionRecord.fromMap).toList();
        _failPredictions = {
          'open_circuit': openCircuit.map(PredictionRecord.fromMap).toList(),
          'missing_hole': missingHole.map(PredictionRecord.fromMap).toList(),
          'mouse_bite': mouseBite.map(PredictionRecord.fromMap).toList(),
          'other': other.map(PredictionRecord.fromMap).toList(),
        };
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to load stats: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard('Total Pass', '$_passCount', Colors.green.shade700),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard('Total Fail', '$_failCount', Colors.red.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: const Text('PASS'),
                            trailing: Text(
                              _passCount.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CategoryDetailsPage(
                                    title: 'PASS',
                                    records: _passPredictions,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Fail categories',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ..._categoryCounts.entries.map(
                          (entry) {
                            final displayName = entry.key.replaceAll('_', ' ').toUpperCase();
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(displayName),
                                trailing: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  final records = _failPredictions[entry.key] ?? [];
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CategoryDetailsPage(
                                        title: displayName,
                                        records: records,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadStats,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh stats'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
