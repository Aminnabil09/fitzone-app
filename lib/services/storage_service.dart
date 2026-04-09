import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a test file to verify the storage connection.
  Future<String?> uploadTestFile() async {
    try {
      debugPrint('Starting test upload to Firebase Storage...');
      
      // Create a simple dummy byte array (representative of a tiny file)
      final Uint8List testData = Uint8List.fromList('FitZone Connection Test'.codeUnits);
      
      // Reference to the destination in your bucket
      final Reference ref = _storage.ref().child('test/connection_test.txt');
      
      // Metadata for the file
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'text/plain',
        customMetadata: {'uploaded_by': 'Antigravity_AI'},
      );

      // Perform the upload
      final UploadTask uploadTask = ref.putData(testData, metadata);
      
      // Monitor progress (optional)
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL once complete
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Test upload successful!');
      debugPrint('Download URL: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase Storage Test Error: $e');
      return null;
    }
  }

  /// Uploads actual image data to a specific path.
  Future<String?> uploadImage(Uint8List imageData, String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image to $path: $e');
      return null;
    }
  }
}
