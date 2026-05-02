import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class PredictionResult {
  final String classification;
  final double confidence;
  final String riskLevel;
  final String recommendation;
  final Map<String, double> classScores;
  final String filename;

  PredictionResult({
    required this.classification,
    required this.confidence,
    required this.riskLevel,
    required this.recommendation,
    required this.classScores,
    required this.filename,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      classification: json['classification'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'] ?? 'Unknown',
      recommendation: json['recommendation'] ?? 'No recommendation',
      classScores: Map<String, double>.from(json['class_scores'] ?? {}),
      filename: json['filename'] ?? 'Unknown',
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Adjust if needed

  static Future<PredictionResult?> predictImageBytes(
    Uint8List imageBytes,
    String filename,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/predict');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
        ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return PredictionResult.fromJson(jsonResponse);
      } else {
        throw Exception('Server error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
