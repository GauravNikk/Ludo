import 'dart:convert';
import 'package:aag_user/model/score_model.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class ApiService extends GetxService {
  
  final String baseUrl =
      'https://your-backend-api.com'; 

  Future<bool> submitResult(ScoreModel scoreModel) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit-result'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(scoreModel.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to submit result: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting result: $e');
      return false;
    }
  }
}
