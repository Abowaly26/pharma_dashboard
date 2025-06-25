import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class RemoveBgService {
  final String _apiKey =
      'KX9e44LDxHSfkC9xZoz6noxA'; // <-- Important: Add your remove.bg API key here
  final String _removeBgUrl = 'https://api.remove.bg/v1.0/removebg';

  bool get isApiConfigured =>
      _apiKey.isNotEmpty && _apiKey != 'INSERT_YOUR_API_KEY_HERE';

  Future<Either<String, Uint8List>> removeBackgroundFromUrl(
    String imageUrl,
  ) async {
    if (!isApiConfigured) {
      return left(
        'API key is not configured. Please contact the administrator.',
      );
    }
    try {
      final response = await http.post(
        Uri.parse(_removeBgUrl),
        headers: {'X-Api-Key': _apiKey},
        body: {'image_url': imageUrl, 'size': 'auto'},
      );

      if (response.statusCode == 200) {
        return right(response.bodyBytes);
      } else {
        print('Failed to remove background: ${response.statusCode}');
        print('Response body: ${response.body}');
        return left('Failed to process image. Please try another image.');
      }
    } catch (e) {
      print('Error calling Remove.bg API: $e');
      return left(
        'An unexpected error occurred. Please check your connection.',
      );
    }
  }

  Future<Either<String, String>> uploadProcessedImage(
    Uint8List imageBytes,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final String imagePath = 'processed_images/${const Uuid().v4()}.png';

      await supabase.storage
          .from('Medicines_images')
          .uploadBinary(imagePath, imageBytes);

      final String publicUrl = supabase.storage
          .from('Medicines_images')
          .getPublicUrl(imagePath);

      return right(publicUrl);
    } catch (e) {
      print('Error uploading processed image to Supabase: $e');
      return left('Failed to save the processed image.');
    }
  }
}
