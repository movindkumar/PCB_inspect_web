// ✅ REPLACE WITH THIS (removed dart:convert, added foundation)
import 'dart:io' show File;
import 'package:flutter/foundation.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'services/api_service.dart';
import 'services/firebase_service.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  Uint8List? _imageBytes;
  String? _fileName;
  String? _message;
  bool _isPicking = false;
  bool _isPredicting = false;
  PredictionResult? _predictionResult;
  String? _resultStatus; // 'pass' or 'fail'

  Future<void> _browseImage() async {
    setState(() {
      _isPicking = true;
      _message = null;
      _predictionResult = null;
      _resultStatus = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _message = 'No image selected.';
          _imageBytes = null;
          _fileName = null;
        });
        return;
      }

      final file = result.files.single;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null && !kIsWeb) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes == null) {
        setState(() {
          _message = 'Unable to read the selected file.';
          _imageBytes = null;
          _fileName = null;
        });
        return;
      }

      setState(() {
        _imageBytes = bytes;
        _fileName = file.name;
        _message = 'Image loaded successfully. Ready to predict.';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to select image: $e';
        _imageBytes = null;
        _fileName = null;
      });
    } finally {
      setState(() {
        _isPicking = false;
      });
    }
  }

  Future<void> _predictImage() async {
    if (_imageBytes == null || _fileName == null) {
      setState(() {
        _message = 'Please select an image first.';
      });
      return;
    }

    setState(() {
      _isPredicting = true;
      _message = 'Analyzing image...';
      _predictionResult = null;
      _resultStatus = null;
    });

    try {
      final result = await ApiService.predictImageBytes(_imageBytes!, _fileName!);

      if (result != null) {
        // Determine pass/fail based on classification only
        final isPass = result.classification.toLowerCase() == 'good' ||
                       result.classification.toLowerCase() == 'pass';

        setState(() {
          _predictionResult = result;
          _resultStatus = isPass ? 'pass' : 'fail';
          _message = isPass ? '✓ PCB passed inspection!' : '✗ Defect detected!';
        });

        // Save to Firebase
        // ✅ upload_page.dart — in _predictImage()
// ✅ REPLACE WITH THIS
// ✅ REPLACE WITH THIS
setState(() => _message = 'Saving to database...');

String? imageUrl;
if (!kIsWeb) {
  imageUrl = await FirebaseService.uploadImage(_imageBytes!, _fileName!);
}

await FirebaseService.savePrediction(
  imageName: _fileName!,
  result: _resultStatus!,
  defectType: isPass ? null : result.classification,
  imageUrl: imageUrl,
  timestamp: DateTime.now(),
).timeout(
  const Duration(seconds: 15),
  onTimeout: () {},
);

setState(() => _message = '${isPass ? '✓ PCB passed!' : '✗ Defect detected!'} Saved.');

        await _showResultDialog(isPass, result);
      } else {
        setState(() {
          _message = 'Prediction returned no result. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Prediction error: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isPredicting = false;
      });
    }
  }

  void _resetForNextUpload() {
    setState(() {
      _imageBytes = null;
      _fileName = null;
      _message = null;
      _predictionResult = null;
      _resultStatus = null;
    });
  }

  Future<void> _showResultDialog(bool isPass, PredictionResult result) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Result',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isPass ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isPass ? Colors.green.shade700 : Colors.red.shade700,
                    width: 2,
                  ),
                ),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isPass ? 'PASS' : 'FAIL',
                      style: TextStyle(
                        color: isPass ? Colors.green.shade800 : Colors.red.shade800,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      isPass ? Icons.check_circle_outline : Icons.error_outline,
                      size: 100,
                      color: isPass ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isPass
                          ? 'Your PCB image passed inspection.'
                          : 'Defect detected: ${result.classification.replaceAll('_', ' ')}',
                      style: TextStyle(
                        color: isPass ? Colors.green.shade900 : Colors.red.shade900,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (!isPass) ...[
                      Text('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16)),
                      Text('Risk level: ${result.riskLevel}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      Text('Recommendation: ${result.recommendation}', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPass ? Colors.green.shade700 : Colors.red.shade700,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        _resetForNextUpload();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Upload another image'),
                    ),
                    const SizedBox(height: 10),
                    // ✅ Pop both the dialog AND the UploadPage so HomePage refreshes
TextButton(
  onPressed: () {
    Navigator.of(context).pop(); // close dialog
    Navigator.of(context).pop(); // return to home so it can refresh
  },
  child: const Text('Close', style: TextStyle(fontSize: 16)),
),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload & Predict'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select an image file from your PC and analyze it for PCB defects.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text('Browse from PC'),
              onPressed: _isPicking || _isPredicting ? null : _browseImage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),
            if (_imageBytes != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text('Predict Defects'),
                onPressed: _isPredicting ? null : _predictImage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _resultStatus == 'pass'
                      ? Colors.green
                      : _resultStatus == 'fail'
                          ? Colors.red
                          : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (_fileName != null) ...[
              const SizedBox(height: 16),
              Text(
                'File: $_fileName',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
            if (_predictionResult != null && _resultStatus == 'fail') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Defect Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Type: ${_predictionResult!.classification}'),
                    Text('Confidence: ${(_predictionResult!.confidence * 100).toStringAsFixed(1)}%'),
                    Text('Risk Level: ${_predictionResult!.riskLevel}'),
                    Text('Recommendation: ${_predictionResult!.recommendation}'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
  child: _imageBytes != null
      ? GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.black,
                insetPadding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.memory(
                  _imageBytes!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.black38,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Tap to enlarge',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
                  : Center(
                      child: Text(
                        _isPicking
                            ? 'Opening file picker...'
                            : _isPredicting
                                ? 'Analyzing image...'
                                : 'No image selected yet.',
                        style: const TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
