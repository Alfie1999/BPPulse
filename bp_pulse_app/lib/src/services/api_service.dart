import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Sends a POST request with the BP & pulse data
  Future<bool> saveReading({
    required int systolic,
    required int diastolic,
    required int pulse,
  }) async {
    final url = Uri.parse(
      '$baseUrl/readings/SaveReading',
    ); // http://localhost:5194/api/readings

    // Prepare JSON payload
    final payload = {
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
    };

    print('--- Sending BP Reading ---');
    print('POST URL: $url');
    print('Payload: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Reading saved successfully.');
        return true;
      } else {
        print('❌ API returned error: ${response.statusCode}');
        return false;
      }

      // Always return true for debugging
      return true;
    } catch (e) {
      print('💥 Exception sending request: $e');
      return false; // Always true while debugging
    }
  }
}
