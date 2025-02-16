import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfileApiService {
  static const String baseUrl = 'http://localhost/api/profile.php';

  /// Fetch profile data.
  /// [id] is the profile ID, and [module] is the module type (e.g., 'member', 'coach', or 'equipment').
  /// This sends a GET request to: /get_profile/{id}/{module}
  static Future<Map<String, dynamic>> fetchProfile(int id, String module) async {
    final url = Uri.parse('$baseUrl/get_profile/$id/$module');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(response.body);
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch profile: ${response.body}');
    }
  }

  /// Update profile data.
  /// [profileData] should be a Map containing:
  /// - 'id': the profile ID,
  /// - 'module': the module type (e.g., 'member', 'coach', or 'equipment'),
  /// - 'data': a Map of the fields to update.
  /// This sends a POST request to: /update_profile
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    final url = Uri.parse('$baseUrl/update_profile');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(profileData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  /// Upload a profile picture.
  /// [id] is the profile ID, [module] is the module type, and [pictureFile] is the image file.
  /// This sends a POST request to: /upload_profile_picture with multipart/form-data.
  static Future<Map<String, dynamic>> uploadProfilePicture({
    required int id,
    required String module,
    required File pictureFile,
  }) async {
    final url = Uri.parse('$baseUrl/upload_profile_picture');
    final request = http.MultipartRequest('POST', url);

    request.fields['id'] = id.toString();
    request.fields['module'] = module;
    request.files.add(await http.MultipartFile.fromPath('picture', pictureFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to upload profile picture: ${response.body}');
    }
  }

  /// Fetch documents associated with a profile.
  /// This sends a GET request to: /get_documents/{id}/{module}
  static Future<List<dynamic>> fetchDocuments(int id, String module) async {
    final url = Uri.parse('$baseUrl/get_documents/$id/$module');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch documents: ${response.body}');
    }
  }

  /// Upload documents for a profile.
  /// [files] is a list of File objects representing the documents to upload.
  /// This sends a POST request to: /upload_documents with multipart/form-data.
  static Future<Map<String, dynamic>> uploadDocuments({
    required int id,
    required String module,
    required List<File> files,
  }) async {
    final url = Uri.parse('$baseUrl/upload_documents');
    final request = http.MultipartRequest('POST', url);

    request.fields['id'] = id.toString();
    request.fields['module'] = module;

    // Assuming your PHP expects a field named "files" containing multiple files.
    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to upload documents: ${response.body}');
    }
  }

  /// Delete a document.
  /// This sends a DELETE request to: /delete_document/{id}/{module}/{documentId}
  static Future<Map<String, dynamic>> deleteDocument({
    required int id,
    required String module,
    required int documentId,
  }) async {
    final url = Uri.parse('$baseUrl/delete_document/$id/$module/$documentId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to delete document: ${response.body}');
    }
  }
}
