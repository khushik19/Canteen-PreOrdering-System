import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Opens the gallery picker and returns the picked file, or null if cancelled.
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    return _picker.pickImage(source: source, imageQuality: 80);
  }

  /// Uploads a profile picture and returns its public download URL.
  Future<String> uploadProfilePicture({
    required String userId,
    required XFile file,
  }) async {
    final ref = _storage.ref().child('profile_pictures/$userId.jpg');

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      await ref.putFile(File(file.path));
    }

    return ref.getDownloadURL();
  }

  /// Generic upload used by menu item images (vendor side) —
  /// exposed here since Person C may need this too; coordinate ownership.
  Future<String> uploadImage({
    required String path, // e.g. 'menu_items/{itemId}.jpg'
    required XFile file,
  }) async {
    final ref = _storage.ref().child(path);

    if (kIsWeb) {
      final Uint8List bytes = await file.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      await ref.putFile(File(file.path));
    }

    return ref.getDownloadURL();
  }

  Future<void> deleteImage(String downloadUrl) async {
    final ref = _storage.refFromURL(downloadUrl);
    await ref.delete();
  }
}