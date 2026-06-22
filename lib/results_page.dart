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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalRoute.of(context)?.addScopedWillPopCallback(() async => true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent && !_isLoading) {
      _loadResults();
    }
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        FirebaseService.fetchPassPredictions(),
        FirebaseService.fetchAllFailPredictions(),
      ]).timeout(const Duration(seconds: 30));

      final passList = results[0];
      final failList = results[1];

      final tagged = [
        ...passList.map((r) => {...r, 'result': 'pass'}),
        ...failList,
      ];

      tagged.sort((a, b) =>
          (b['timestamp']?.toString() ?? '')
              .compareTo(a['timestamp']?.toString() ?? ''));

      final all = tagged;
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

  // Pop-up details view showing the remote Cloud Storage URL
  void _showRecordDetails(Map<String, dynamic> record) {
    final isPass = record['result']?.toString().toLowerCase() == 'pass';
    final defectType = isPass
        ? 'NONE'
        : (record['defectType']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'UNKNOWN');
    final riskLevel = record['riskLevel']?.toString() ?? (isPass ? 'Low' : 'Unknown');
    final recommendation = record['recommendation']?.toString() ?? 'No recommendation available.';
    
    // Extract the Cloud Storage URL from your Realtime DB record
    final imageUrl = record['image_url']?.toString() ?? ''; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        record['imageName']?.toString() ?? 'Prediction Details',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                
                Text(
                  'Defect Type: $defectType',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Risk Level: $riskLevel',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: riskLevel == 'High' ? Colors.red : (isPass ? Colors.green : Colors.orange),
                  ),
                ),
                Text('Recommendation: $recommendation'),
                
                const SizedBox(height: 20),
                
                // Cloud Storage Network Image logic
                if (imageUrl.isNotEmpty)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'Failed to load remote evaluation image asset.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 48),
                        SizedBox(height: 10),
                        Text('No image asset stored in cloud database.', 
                          style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
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
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00C2A8)),
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
                                Container(
                                  color: const Color(0xFFE8EDF5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: const Row(
                                    children: [
                                      SizedBox(
                                        width: 36,
                                        child: Text('#', style: _headerStyle),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text('IMAGE FILE',
                                            style: _headerStyle),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text('RESULT',
                                            style: _headerStyle,
                                            textAlign: TextAlign.center),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text('DEFECT TYPE',
                                            style: _headerStyle),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text('TIMESTAMP',
                                            style: _headerStyle),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _filteredRecords.length,
                                    itemBuilder: (context, index) {
                                      final record = _filteredRecords[index];
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

                                      return Material(
                                        color: isEven
                                            ? Colors.white
                                            : const Color(0xFFF7F9FC),
                                        child: InkWell(
                                          onTap: () => _showRecordDetails(record),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 36,
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: const TextStyle(
                                                      color: Color(0xFFB0BEC5),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
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
                                                            color: Color(0xFF0D1B2A),
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Center(
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: isPass
                                                            ? const Color(0xFFE6F7F1)
                                                            : const Color(0xFFFBEAEA),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        isPass ? 'PASS' : 'FAIL',
                                                        style: TextStyle(
                                                          color: isPass
                                                              ? const Color(0xFF1E9E6B)
                                                              : const Color(0xFFD94040),
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    defectType,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isPass
                                                          ? const Color(0xFFB0BEC5)
                                                          : const Color(0xFFD94040),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    _formatTimestamp(record['timestamp']?.toString()),
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF8A9BB0),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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