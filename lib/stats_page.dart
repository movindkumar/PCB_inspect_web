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
      // 1. We ONLY make 2 network calls now instead of 8!
      // We also give it 45 seconds to be safe on slow web connections.
      final results = await Future.wait([
        FirebaseService.fetchPassPredictions(),
        FirebaseService.fetchAllFailPredictions(), 
      ]).timeout(const Duration(seconds: 45));

      final passData = results[0];
      final failData = results[1];

      // 2. Convert raw data to your PredictionRecord objects
      final passRecords = passData.map(PredictionRecord.fromMap).toList();
      final failRecords = failData.map(PredictionRecord.fromMap).toList();

      if (!mounted) return;

      // 3. Do all the counting and sorting instantly on the device!
      setState(() {
        _passCount = passRecords.length;
        _failCount = failRecords.length;
        _passPredictions = passRecords;

        // Sort fails into their category lists
        _failPredictions = {
          'open_circuit': failRecords.where((r) => r.defectType == 'open_circuit').toList(),
          'missing_hole': failRecords.where((r) => r.defectType == 'missing_hole').toList(),
          'mouse_bite': failRecords.where((r) => r.defectType == 'mouse_bite').toList(),
          'other': failRecords.where((r) => 
              r.defectType != 'open_circuit' && 
              r.defectType != 'missing_hole' && 
              r.defectType != 'mouse_bite'
          ).toList(),
        };

        // Count the categories based on the lists above
        _categoryCounts = {
          'open_circuit': _failPredictions['open_circuit']!.length,
          'missing_hole': _failPredictions['missing_hole']!.length,
          'mouse_bite': _failPredictions['mouse_bite']!.length,
          'other': _failPredictions['other']!.length,
        };
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Wi-Fi connection is too slow. Please try again.\n($e)';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
