import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import this

class CloudinaryService {
  // Replace with YOUR values from Phase 1
  // Read from .env
  final String? cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
  final String? uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

  Future<String?> uploadImage(File imageFile) async {
    // Safety check
    if (cloudName == null || uploadPreset == null) {
      print("❌ Cloudinary config missing in .env file");
      return null;
    }

    try {
      var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");

      var request = http.MultipartRequest("POST", uri);

      // Add the file
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(multipartFile);

      // Add the upload preset (Security key for unsigned uploads)
      request.fields['upload_preset'] = uploadPreset!;

      // Send request
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonMap = jsonDecode(responseString);

        // Return the secure URL of the uploaded image
        return jsonMap['secure_url'];
      } else {
        print("Upload Failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
  }
}