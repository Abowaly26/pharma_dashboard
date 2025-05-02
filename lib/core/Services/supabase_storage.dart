import 'dart:io';

import 'package:path/path.dart';
import 'package:pharma_dashboard/core/Services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as b;

class SupabaseStorageService implements StorageService {
  static late Supabase _supabase;

  static createBuckets(String bucketName) async {
    var buckets = await _supabase.client.storage.listBuckets();
    bool isBucketExists = false;

    for (var bucket in buckets) {
      if (bucket.id == bucketName) {
        isBucketExists = true;
        break;
      }
    }

    if (!isBucketExists) {
      await _supabase.client.storage.createBucket(bucketName);
    }
  }

  static initSupabase() async {
    _supabase = await Supabase.initialize(
      url: 'https://jzvdrawjkkqbxvhpefhd.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6dmRyYXdqa2txYnh2aHBlZmhkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjExMzg1MSwiZXhwIjoyMDYxNjg5ODUxfQ.vCmtvSQIVykYWODNbcxZD9JJENCd6_t65St1ptTuPCM',
    );
  }

  @override
  Future<String> uploadFile(File file, String path) async {
    String fileName = b.basename(file.path);
    String extensionName = b.extension(file.path);
    var result = await _supabase.client.storage
        .from('Medicines_images')
        .upload('$path/$fileName.$extensionName', file);

    final String publiUrl = _supabase.client.storage
        .from('Medicines_images')
        .getPublicUrl('$path/$fileName.$extensionName');
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    return publiUrl;
  }
}
