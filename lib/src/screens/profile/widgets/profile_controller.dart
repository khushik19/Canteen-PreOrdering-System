import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart'; // Person A's repo — for updating profile fields
import '../../services/storage_service.dart';

class ProfileController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  ProfileController({
    AuthRepository? authRepository,
    StorageService? storageService,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _storageService = storageService ?? StorageService();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_user == null) return false;
    _isSaving = true;
    notifyListeners();

    try {
      await _authRepository.updateUserProfile(
        userId: _user!.id,
        name: name,
        phone: phone,
      );
      _user = _user!.copyWith(name: name, phone: phone);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfilePicture() async {
    if (_user == null) return false;

    final picked = await _storageService.pickImage(source: ImageSource.gallery);
    if (picked == null) return false; // user cancelled

    _isSaving = true;
    notifyListeners();

    try {
      final url = await _storageService.uploadProfilePicture(
        userId: _user!.id,
        file: picked,
      );
      await _authRepository.updateUserProfile(
        userId: _user!.id,
        photoUrl: url,
      );
      _user = _user!.copyWith(photoUrl: url);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}