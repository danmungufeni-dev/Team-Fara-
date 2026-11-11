import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../errors/app_exceptions.dart';

/// Reusable robust HTTP client for PadCare.
class ApiClient {
  final http.Client _client;
  final Duration timeout;
  final int maxRetries;

  ApiClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 2,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> postJson(
    Uri uri, {
    Map<String, String>? headers,
    required Map<String, dynamic> body,
  }) async {
    final mergedHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      ...?headers,
    };

    final encodedBody = jsonEncode(body);
    int attempts = 0;

    while (attempts <= maxRetries) {
      attempts++;
      try {
        if (kDebugMode) {
          debugPrint('🌐 [ApiClient] POST ${uri.toString()} (Attempt $attempts)');
        }

        final response = await _client
            .post(uri, headers: mergedHeaders, body: encodedBody)
            .timeout(timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
          return {'data': decoded, 'status': true};
        } else {
          throw NetworkException(
            'Server responded with status ${response.statusCode}',
            statusCode: response.statusCode,
            details: response.body,
          );
        }
      } on SocketException catch (e) {
        if (attempts > maxRetries) {
          throw NetworkException('Network connection unavailable: ${e.message}');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      } on TimeoutException {
        if (attempts > maxRetries) {
          throw const NetworkException('Request timed out. Please check connectivity.');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      } catch (e) {
        if (e is NetworkException) rethrow;
        throw NetworkException('Unexpected network error: $e');
      }
    }

    throw const NetworkException('Exceeded maximum request retries.');
  }

  void close() {
    _client.close();
  }
}
