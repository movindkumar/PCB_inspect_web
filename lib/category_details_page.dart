import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'stats_page.dart';
import 'services/firebase_service.dart';

class CategoryDetailsPage extends StatefulWidget {
  final String title;
  final List<PredictionRecord> records;

  const CategoryDetailsPage({super.key, required this.title, required this.records});

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  late List<PredictionRecord> _records;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _records = List.from(widget.records);
  }

  Future<void> _deleteRecord(int index) async {
    final record = _records[index];
    
    // First confirmation
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete record?'),
          content: Text('Delete record for ${record.imageName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!firstConfirm!) return;

    // Second confirmation (double-check)
    if (!mounted) return;
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm deletion'),
          content: const Text('This action cannot be undone. Are you absolutely sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes, delete'),
            ),
          ],
        );
      },
    );

    if (!secondConfirm!) return;

    if (!mounted) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      await FirebaseService.deletePrediction(_records[index].dbPath);
      if (mounted) {
        setState(() {
          _records.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted successfully. Go back and refresh to see updates.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete record: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _showUpdateDialog(int index) async {
    final record = _records[index];
    final timestampController = TextEditingController(text: record.timestamp);
    final defectController = TextEditingController(text: record.defectType ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timestampController,
                decoration: const InputDecoration(
                  labelText: 'Timestamp',
                  hintText: 'YYYY-MM-DDTHH:MM:SS.mmm',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: defectController,
                decoration: const InputDecoration(
                  labelText: 'Defect type',
                  hintText: 'open_circuit / missing_hole / mouse_bite',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTimestamp = timestampController.text.trim();
                final newDefect = defectController.text.trim().isEmpty
                    ? null
                    : defectController.text.trim();
                final newResult = newDefect != null ? 'fail' : record.result;

                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                setState(() {
                  _isProcessing = true;
                });

                try {
                  final updatedDbPath = await FirebaseService.updatePrediction(
                    dbPath: record.dbPath,
                    timestamp: newTimestamp.isEmpty ? null : newTimestamp,
                    defectType: newDefect,
                    result: newResult,
                  );

                  if (!mounted) return;
                  final updatedRecord = PredictionRecord(
                    id: record.id,
                    dbPath: updatedDbPath,
                    imageName: record.imageName,
                    result: newResult,
                    timestamp: newTimestamp.isEmpty ? record.timestamp : newTimestamp,
                    defectType: newDefect,
                    imageData: record.imageData,
                  );

                  if (mounted) {
                    setState(() {
                      if (updatedDbPath != record.dbPath) {
                        _records.removeAt(index);
                      } else {
                        _records[index] = updatedRecord;
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Record updated successfully. Go back and refresh to see updates.')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update failed: $e')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isProcessing = false;
                    });
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPredictionCard(BuildContext context, PredictionRecord record, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.imageName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Result: ${record.result.toUpperCase()}'),
            if (record.defectType != null) ...[
              const SizedBox(height: 4),
              Text('Type: ${record.defectType!.replaceAll('_', ' ')}'),
            ],
            const SizedBox(height: 4),
            Text('Time: ${record.timestamp}'),
            if (record.imageData != null && record.imageData!.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showImageFullscreen(record.imageData!),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _base64ToUint8List(record.imageData!),
                      fit: BoxFit.cover,
                      height: 350,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 350,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Text('Failed to load image'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => _showUpdateDialog(index),
                    child: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: _isProcessing ? null : () => _deleteRecord(index),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Uint8List _base64ToUint8List(String base64String) {
    return base64Decode(base64String);
  }

  Future<void> _showImageFullscreen(String imageData) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.memory(
                    _base64ToUint8List(imageData),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _records.isEmpty
          ? const Center(child: Text('No records found for this category.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildPredictionCard(context, _records[index], index);
              },
            ),
    );
  }
}
