import 'package:flutter/material.dart';

import 'login_page.dart';
import 'stats_page.dart';
import 'upload_page.dart';
import 'results_page.dart';
import 'services/firebase_service.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String role;

  const HomePage({super.key, required this.username, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalInspections = 0;
  int _passCount = 0;
  int _failCount = 0;
  bool _statsLoading = true;
  List<Map<String, dynamic>> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final results = await Future.wait([
        FirebaseService.countPass(),
        FirebaseService.countFail(),
        FirebaseService.fetchRecentPredictions(limit: 3),
      ]).timeout(const Duration(seconds: 25));

      final pass = results[0] as int;
      final fail = results[1] as int;
      final recent = results[2] as List<Map<String, dynamic>>;
      if (!mounted) return;
      setState(() {
        _passCount = pass;
        _failCount = fail;
        _totalInspections = pass + fail;
        _recentActivity = recent;
        _statsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _statsLoading = false);
    }
  }

  String get _passRate {
    if (_totalInspections == 0) return '—';
    return '${(_passCount / _totalInspections * 100).toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final isEngineer = widget.role == 'engineer';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: const Color(0xFF0D1B2A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C2A8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.developer_board,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PCB Inspect Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            'Automated Optical Inspection',
                            style: TextStyle(
                              color: Color(0xFF4A7A9B),
                              fontSize: 10,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout,
                            color: Color(0xFF00C2A8), size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: Color(0xFF00C2A8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadDashboardStats,
                color: const Color(0xFF00C2A8),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Greeting Card ────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B2A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$greeting,',
                                    style: const TextStyle(
                                      color: Color(0xFF00C2A8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isEngineer
                                          ? const Color(0xFF3B7DDD)
                                              .withOpacity(0.2)
                                          : const Color(0xFF00C2A8)
                                              .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isEngineer
                                              ? Icons.engineering
                                              : Icons.person_outline,
                                          color: isEngineer
                                              ? const Color(0xFF3B7DDD)
                                              : const Color(0xFF00C2A8),
                                          size: 13,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isEngineer
                                              ? 'AOI Engineer'
                                              : 'Quality Control Operator',
                                          style: TextStyle(
                                            color: isEngineer
                                                ? const Color(0xFF3B7DDD)
                                                : const Color(0xFF00C2A8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // System status
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF00C2A8).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFF00C2A8)
                                            .withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF00C2A8),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'System Ready',
                                        style: TextStyle(
                                          color: Color(0xFF00C2A8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'AOI Engine Online',
                                  style: TextStyle(
                                    color: Color(0xFF4A6A8A),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Stats Row ────────────────────────────
                      _statsLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00C2A8),
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    label: 'Total',
                                    value: '$_totalInspections',
                                    icon: Icons.list_alt_rounded,
                                    iconColor: const Color(0xFF3B7DDD),
                                    bgColor: const Color(0xFFEAF1FB),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    label: 'Passed',
                                    value: '$_passCount',
                                    icon: Icons.check_circle_outline,
                                    iconColor: const Color(0xFF1E9E6B),
                                    bgColor: const Color(0xFFE6F7F1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    label: 'Failed',
                                    value: '$_failCount',
                                    icon: Icons.cancel_outlined,
                                    iconColor: const Color(0xFFD94040),
                                    bgColor: const Color(0xFFFBEAEA),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    label: 'Pass Rate',
                                    value: _passRate,
                                    icon: Icons.percent_rounded,
                                    iconColor: const Color(0xFFB07D00),
                                    bgColor: const Color(0xFFFFF4DC),
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: 24),

                      // ── Section Label ────────────────────────
                      const _SectionLabel(text: 'INSPECTION TOOLS'),
                      const SizedBox(height: 12),

                      // Upload card
                      _ActionCard(
                        icon: Icons.upload_file_rounded,
                        iconColor: const Color(0xFF00C2A8),
                        iconBg: const Color(0xFFDEF7F3),
                        title: 'Upload & Inspect',
                        subtitle:
                            'Select a PCB image and run AI defect analysis.',
                        badgeText: 'AI Powered',
                        badgeColor: const Color(0xFF00C2A8),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const UploadPage()),
                        ),
                      ),

                    if (isEngineer) ...[
                        const SizedBox(height: 12),
                        _ActionCard(
                          icon: Icons.bar_chart_rounded,
                          iconColor: const Color(0xFF3B7DDD),
                          iconBg: const Color(0xFFE6EFFA),
                          title: 'Prediction Summary',
                          subtitle:
                              'View inspection history, defect trends and statistics.',
                          badgeText: 'Analytics',
                          badgeColor: const Color(0xFF3B7DDD),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const StatsPage()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ActionCard(
                          icon: Icons.table_rows_rounded,
                          iconColor: const Color(0xFF7B5EA7),
                          iconBg: const Color(0xFFF0EBF8),
                          title: 'Inspection Results',
                          subtitle:
                              'View full table of all PCB inspection records.',
                          badgeText: 'Engineer',
                          badgeColor: const Color(0xFF7B5EA7),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ResultsPage()),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      const SizedBox(height: 24),

                      // ── Recent Activity — Engineers only ─────
                      if (isEngineer) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const _SectionLabel(text: 'RECENT ACTIVITY'),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const StatsPage()),
                              ),
                              child: const Text(
                                'View all →',
                                style: TextStyle(
                                  color: Color(0xFF3B7DDD),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _statsLoading
                            ? const SizedBox()
                            : _recentActivity.isEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(Icons.inbox_outlined,
                                            color: Color(0xFFB0BEC5), size: 36),
                                        SizedBox(height: 8),
                                        Text(
                                          'No inspections yet.\nUpload your first PCB image to begin.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFFB0BEC5),
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: _recentActivity
                                        .map((r) => _RecentActivityTile(
                                              record: r,
                                            ))
                                        .toList(),
                                  ),
                      ],

                      const SizedBox(height: 24),

                      // ── Info Banner ──────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E6),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: const Color(0xFFFFD66B)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.tips_and_updates_outlined,
                                color: Color(0xFFB98900), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Before You Begin',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF7A5C00),
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Ensure the PCB image is clear, well-lit, and captured at the correct angle for accurate defect detection results.',
                                    style: TextStyle(
                                      color: Color(0xFF9A7200),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          'PCB Inspect Pro  •  v1.0.0',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8A9BB0),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8A9BB0),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8A9BB0),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF8A9BB0), size: 22),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityTile extends StatelessWidget {
  final Map<String, dynamic> record;

  const _RecentActivityTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isPass = (record['result']?.toString().toLowerCase() == 'pass');
    final imageName =
        record['imageName']?.toString() ?? 'Unknown';
    final defectType = record['defectType']?.toString();
    final timestamp = record['timestamp']?.toString() ?? '';

    String shortTime = '';
    try {
      final dt = DateTime.parse(timestamp);
      shortTime =
          '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      shortTime = timestamp;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPass
                  ? const Color(0xFFE6F7F1)
                  : const Color(0xFFFBEAEA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPass
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              color: isPass
                  ? const Color(0xFF1E9E6B)
                  : const Color(0xFFD94040),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imageName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF0D1B2A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isPass
                      ? 'No defects found'
                      : defectType != null
                          ? defectType.replaceAll('_', ' ').toUpperCase()
                          : 'Defect detected',
                  style: TextStyle(
                    fontSize: 11,
                    color: isPass
                        ? const Color(0xFF1E9E6B)
                        : const Color(0xFFD94040),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Badge + time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              const SizedBox(height: 4),
              Text(
                shortTime,
                style: const TextStyle(
                  color: Color(0xFFB0BEC5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}