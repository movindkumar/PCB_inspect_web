import 'package:flutter/material.dart';
import 'services/firebase_service.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Pass',
    'Fail',
    'Open Circuit',
    'Missing Hole',
    'Mouse Bite',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final all = await FirebaseService.fetchRecentPredictions(limit: 999)
          .timeout(const Duration(seconds: 25));
      setState(() {
        _allRecords = all;
        _filteredRecords = all;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load results: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredRecords = _allRecords;
      } else if (filter == 'Pass') {
        _filteredRecords = _allRecords
            .where((r) => r['result']?.toString().toLowerCase() == 'pass')
            .toList();
      } else if (filter == 'Fail') {
        _filteredRecords = _allRecords
            .where((r) => r['result']?.toString().toLowerCase() == 'fail')
            .toList();
      } else {
        final key = filter.toLowerCase().replaceAll(' ', '_');
        _filteredRecords = _allRecords
            .where((r) =>
                r['defectType']?.toString().toLowerCase() == key)
            .toList();
      }
    });
  }

  String _formatTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inspection Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Full prediction history',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF4A7A9B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF00C2A8)),
            onPressed: _loadResults,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C2A8)),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFD94040), size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFFD94040)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadResults,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C2A8),
                        ),
                        child: const Text('Retry',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // ── Summary Bar ───────────────────────────
                    Container(
                      color: const Color(0xFF0D1B2A),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          _SummaryPill(
                            label: 'Total',
                            value: '${_allRecords.length}',
                            color: const Color(0xFF3B7DDD),
                          ),
                          const SizedBox(width: 10),
                          _SummaryPill(
                            label: 'Pass',
                            value:
                                '${_allRecords.where((r) => r['result'] == 'pass').length}',
                            color: const Color(0xFF1E9E6B),
                          ),
                          const SizedBox(width: 10),
                          _SummaryPill(
                            label: 'Fail',
                            value:
                                '${_allRecords.where((r) => r['result'] == 'fail').length}',
                            color: const Color(0xFFD94040),
                          ),
                        ],
                      ),
                    ),

                    // ── Filter Chips ──────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((f) {
                            final isSelected = _selectedFilter == f;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => _applyFilter(f),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0D1B2A)
                                        : const Color(0xFFF0F3F8),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF0D1B2A)
                                          : const Color(0xFFDDE3ED),
                                    ),
                                  ),
                                  child: Text(
                                    f,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF5A7A9A),
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // ── Table ─────────────────────────────────
                    Expanded(
                      child: _filteredRecords.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search_off_rounded,
                                      color: Color(0xFFB0BEC5), size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No records found for "$_selectedFilter"',
                                    style: const TextStyle(
                                      color: Color(0xFFB0BEC5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                // Table header
                                Container(
                                  color: const Color(0xFFE8EDF5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: const Row(
                                    children: [
                                      SizedBox(
                                        width: 36,
                                        child: Text(
                                          '#',
                                          style: _headerStyle,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'IMAGE FILE',
                                          style: _headerStyle,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'RESULT',
                                          style: _headerStyle,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'DEFECT TYPE',
                                          style: _headerStyle,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'TIMESTAMP',
                                          style: _headerStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Table rows
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _filteredRecords.length,
                                    itemBuilder: (context, index) {
                                      final record =
                                          _filteredRecords[index];
                                      final isPass = record['result']
                                              ?.toString()
                                              .toLowerCase() ==
                                          'pass';
                                      final defectType = isPass
                                          ? '—'
                                          : (record['defectType']
                                                      ?.toString()
                                                      .replaceAll('_', ' ')
                                                      .toUpperCase() ??
                                                  '—');
                                      final isEven = index % 2 == 0;

                                      return Container(
                                        color: isEven
                                            ? Colors.white
                                            : const Color(0xFFF7F9FC),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            // Row number
                                            SizedBox(
                                              width: 36,
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Color(0xFFB0BEC5),
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            // Image name
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.image_outlined,
                                                    size: 14,
                                                    color: Color(0xFF8A9BB0),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      record['imageName']
                                                              ?.toString() ??
                                                          '—',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF0D1B2A),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Result badge
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isPass
                                                        ? const Color(
                                                            0xFFE6F7F1)
                                                        : const Color(
                                                            0xFFFBEAEA),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    isPass ? 'PASS' : 'FAIL',
                                                    style: TextStyle(
                                                      color: isPass
                                                          ? const Color(
                                                              0xFF1E9E6B)
                                                          : const Color(
                                                              0xFFD94040),
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Defect type
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                defectType,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isPass
                                                      ? const Color(
                                                          0xFFB0BEC5)
                                                      : const Color(
                                                          0xFFD94040),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Timestamp
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                _formatTimestamp(record[
                                                        'timestamp']
                                                    ?.toString()),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF8A9BB0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

const _headerStyle = TextStyle(
  color: Color(0xFF5A7A9A),
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.8,
);