import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

// ---------------------------------------------------------------------------
// CampusController — Tracks the currently selected campus.
//
// When a student picks a campus in the top dropdown:
//   1. This controller updates [campusId] and notifies listeners.
//   2. Home and Menu screens listen and reload food items for that campus.
// ---------------------------------------------------------------------------

class CampusController extends ChangeNotifier {
  String _campusId;

  CampusController({String? initialCampusId})
      : _campusId = initialCampusId ?? AppConstants.defaultCampusId;

  /// The active campus ID (e.g. 'pimr_ug').
  String get campusId => _campusId;

  /// The human-readable display name for the active campus (e.g. 'PIMR UG').
  String get campusName {
    final campus = AppConstants.campuses.firstWhere(
      (c) => c.id == _campusId,
      orElse: () => AppConstants.campuses.first,
    );
    return campus.displayName;
  }

  /// Change the selected campus and notify all listeners.
  void setCampus(String newCampusId) {
    if (_campusId == newCampusId) return;
    _campusId = newCampusId;
    notifyListeners();
  }

  /// Syncs campus with the logged-in user profile if set.
  void syncWithUser(String? userCampusId) {
    if (userCampusId != null &&
        userCampusId.isNotEmpty &&
        _campusId != userCampusId) {
      _campusId = userCampusId;
      notifyListeners();
    }
  }
}
