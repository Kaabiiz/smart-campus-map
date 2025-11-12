import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Your EmailJS credentials
  static const String _serviceId = 'service_lw48aad';
  static const String _templateId = 'template_wknpi5b';
  static const String _publicKey = 'mp4opsuYaJa1NMSqU';
  static const String _privateKey = 'qus3YnWyNnveUuIWQ3xCv';  // Get this from Account → API Keys
  static const String _apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  Future<bool> sendReservationConfirmation({
    required String userEmail,
    required String userName,
    required String roomName,
    required String buildingName,
    required String date,
    required String timeSlot,
    required String purpose,
    required String reservationId,
  }) async {
    try {
      print('');
      print('🔍 ========== EMAIL DEBUG INFO (HTTP + AUTH) ==========');
      print('📧 Attempting to send email with private key authentication');
      print('');
      
      final requestBody = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'accessToken': _privateKey,  // ✅ Added for non-browser authentication
        'template_params': {
          'to_name': userName,
          'room_name': roomName,
          'building_name': buildingName,
          'date': date,
          'time_slot': timeSlot,
          'purpose': purpose,
          'reservation_id': reservationId,
        }
      };
      
      print('📦 REQUEST BODY (with auth):');
      print(JsonEncoder.withIndent('  ').convert(requestBody));
      print('');
      
      print('⏳ Sending POST request to EmailJS API...');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📨 Response Status Code: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');
      print('');
      
      if (response.statusCode == 200) {
        print('✅ EMAIL SENT SUCCESSFULLY!');
        print('========================================');
        print('');
        return true;
      } else {
        print('❌ EMAIL FAILED!');
        print('Status Code: ${response.statusCode}');
        print('Error Response: ${response.body}');
        print('========================================');
        print('');
        return false;
      }
      
    } catch (e, stackTrace) {
      print('');
      print('❌ ========== UNEXPECTED ERROR ==========');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Stack Trace: $stackTrace');
      print('========================================');
      print('');
      return false;
    }
  }

  Future<bool> sendCancellationEmail({
    required String userEmail,
    required String userName,
    required String roomName,
    required String date,
    required String timeSlot,
  }) async {
    try {
      print('📧 Sending cancellation email via HTTP');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'accessToken': _privateKey,  // ✅ Added
          'template_params': {
            'to_name': userName,
            'room_name': roomName,
            'building_name': 'Campus',
            'date': date,
            'time_slot': timeSlot,
            'purpose': 'RÉSERVATION ANNULÉE',
            'reservation_id': 'CANCELLED',
          }
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Cancellation email sent!');
        return true;
      } else {
        print('❌ Failed: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error sending cancellation email: $e');
      return false;
    }
  }

  Future<bool> sendTestEmail(String testEmail) async {
    try {
      print('🧪 Sending test email via HTTP');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'accessToken': _privateKey,  // ✅ Added
          'template_params': {
            'to_name': 'Test User',
            'room_name': 'Test Room 101',
            'building_name': 'Test Building',
            'date': '12 novembre 2024',
            'time_slot': '10:00 - 12:00',
            'purpose': 'Test de fonctionnement du système',
            'reservation_id': 'TEST-${DateTime.now().millisecondsSinceEpoch}',
          }
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Test email sent successfully!');
        return true;
      } else {
        print('❌ Test failed: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Test email failed: $e');
      return false;
    }
  }
}