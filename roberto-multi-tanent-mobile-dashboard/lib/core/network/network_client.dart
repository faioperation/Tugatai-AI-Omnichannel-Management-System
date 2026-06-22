import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';

part 'network_response.dart';

class NetworkClient {
  final Logger _logger = Logger();
  final String _defaultErrorMassage = 'Something went wrong';

  final VoidCallback onUnAuthorize;
  final Map<String, String> Function() commonHeaders;

  NetworkClient({required this.onUnAuthorize, required this.commonHeaders});

  Future<NetworkResponse> getRequest(String url) async {
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders());
      final Response response = await get(uri, headers: commonHeaders());
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<NetworkResponse> getBinaryRequest(String url) async {
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders());
      final Response response = await get(uri, headers: commonHeaders());
      _logResponse(response, isBinary: true);
      return _handleResponse(response, isBinary: true);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<NetworkResponse> postRequest(String url,
      {Map<String, dynamic>? body, bool skipAuth = false}) async {
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders(), body: body);
      final Response response = await post(
        uri,
        headers: commonHeaders(),
        body: jsonEncode(body),
      );
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<NetworkResponse> patchRequest(String url,
      {Map<String, dynamic>? body}) async {
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders(), body: body);
      final Response response = await patch(
        uri,
        headers: commonHeaders(),
        body: jsonEncode(body),
      );
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<NetworkResponse> postMultipartRequest(String url,
      {required Map<String, String> body, Map<String, String>? files, Map<String, List<int>>? fileBytes, Map<String, String>? fileNames}) async {
    return _multipartRequest('POST', url, body: body, files: files, fileBytes: fileBytes, fileNames: fileNames);
  }

  Future<NetworkResponse> patchMultipartRequest(String url,
      {required Map<String, String> body, Map<String, String>? files, Map<String, List<int>>? fileBytes, Map<String, String>? fileNames}) async {
    return _multipartRequest('PATCH', url, body: body, files: files, fileBytes: fileBytes, fileNames: fileNames);
  }

  Future<NetworkResponse> _multipartRequest(String method, String url,
      {required Map<String, String> body, Map<String, String>? files, Map<String, List<int>>? fileBytes, Map<String, String>? fileNames}) async {
    try {
      Uri uri = Uri.parse(url);
      final request = MultipartRequest(method, uri);
      request.headers.addAll(commonHeaders());
      request.fields.addAll(body);

      if (files != null) {
        for (var entry in files.entries) {
          final mimeType = lookupMimeType(entry.value);
          final contentType = mimeType != null ? MediaType.parse(mimeType) : null;
          request.files.add(await MultipartFile.fromPath(entry.key, entry.value, contentType: contentType));
        }
      }

      if (fileBytes != null) {
        for (var entry in fileBytes.entries) {
          final filename = fileNames?[entry.key] ?? 'upload.jpg';
          request.files.add(MultipartFile.fromBytes(entry.key, entry.value, filename: filename));
        }
      }

      _logRequest(url, headers: request.headers, body: body); 
      final streamedResponse = await request.send();
      final response = await Response.fromStream(streamedResponse);
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<NetworkResponse> deleteRequest(String url) async {
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders());
      final Response response = await delete(uri, headers: commonHeaders());
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  NetworkResponse _handleResponse(Response response, {bool isBinary = false}) {
    dynamic responseBody;
    final contentType = response.headers['content-type'] ?? '';

    try {
      if (isBinary && !contentType.contains('application/json')) {
        responseBody = response.bodyBytes;
      } else if (response.body.isNotEmpty) {
        responseBody = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('❌ JSON Decode Error: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMassage: "Server error (${response.statusCode}). Response format is invalid.",
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      // If we expected binary but got JSON instead (even with 200), it's likely a structured error or empty success
      if (isBinary && contentType.contains('application/json') && responseBody is Map) {
        final bool success = responseBody['success'] ?? true;
        if (!success) {
          return NetworkResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMassage: responseBody['message'] ?? responseBody['msg'] ?? "Operation failed",
            responseData: responseBody,
          );
        }
      }

      return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: responseBody);
    } else if (response.statusCode == 401) {
      onUnAuthorize();
      return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMassage: "Un-authorized");
    } else {
      String? msg;
      if (responseBody is Map) {
        msg = responseBody['msg'] ?? responseBody['message'];
      }
      return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMassage: msg ?? _defaultErrorMassage);
    }
  }

  NetworkResponse _handleError(Object e) {
    debugPrint('❌ Network Request Error: $e');
    return NetworkResponse(
      isSuccess: false,
      statusCode: -1,
      errorMassage: e.toString(),
    );
  }

  void _logRequest(String url,
      {Map<String, String>? headers, Map<String, dynamic>? body}) {
    final String message = '''
    URL -> $url
    HEADERS -> $headers
    BODY -> $body
     ''';

    _logger.i(message);
  }

  void _logResponse(Response response, {bool isBinary = false}) {
    final String message = '''
    URL -> ${response.request?.url}
    STATUS CODE -> ${response.statusCode}
    HEADERS -> ${response.request?.headers}
    BODY -> ${isBinary ? "[BINARY DATA]" : response.body}
     ''';
    _logger.i(message);
  }
}
