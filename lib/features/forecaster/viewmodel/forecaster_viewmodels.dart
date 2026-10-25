import 'package:flutter/foundation.dart';

import '../../predictions/data/prediction_repository.dart';
import '../../predictions/domain/prediction.dart';
import '../data/forecaster_repository.dart';
import '../domain/availability.dart';
import '../domain/forecaster.dart';
import '../domain/forecaster_me_profile.dart';
import '../domain/forecaster_profile_update.dart';

class ExploreViewModel extends ChangeNotifier {
  ExploreViewModel(this._repo);

  final ForecasterRepository _repo;

  List<ForecasterPublicProfile> _items = const [];
  bool _loading = false;
  String? _error;

  List<ForecasterPublicProfile> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({bool force = false}) async {
    if (!force && _items.isNotEmpty) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.listPublicProfiles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

class ForecasterMeViewModel extends ChangeNotifier {
  ForecasterMeViewModel(this._repo);

  final ForecasterRepository _repo;

  ForecasterMeProfile? _profile;
  ForecasterAvailability? _availability;
  bool _loading = false;
  bool _saving = false;
  bool _savingAvailability = false;
  String? _error;
  String? _availabilityError;

  ForecasterMeProfile? get profile => _profile;
  ForecasterAvailability? get availability => _availability;
  bool get loading => _loading;
  bool get saving => _saving;
  bool get savingAvailability => _savingAvailability;
  String? get error => _error;
  String? get availabilityError => _availabilityError;

  Future<void> load({bool force = false}) async {
    if (!force && _profile != null) return;
    _loading = true;
    _error = null;
    _availabilityError = null;
    notifyListeners();
    try {
      _profile = await _repo.getMe();
    } catch (e) {
      _error = e.toString();
    }
    try {
      _availability = await _repo.getAvailability();
    } catch (e) {
      _availabilityError = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> save(ForecasterProfileUpdate update) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repo.updateMe(update);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<bool> saveAvailability(ForecasterAvailability update) async {
    _savingAvailability = true;
    _availabilityError = null;
    notifyListeners();
    try {
      _availability = await _repo.updateAvailability(update);
      return true;
    } catch (e) {
      _availabilityError = e.toString();
      return false;
    } finally {
      _savingAvailability = false;
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    _availability = null;
    _error = null;
    _availabilityError = null;
    _loading = false;
    _saving = false;
    _savingAvailability = false;
    notifyListeners();
  }
}

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._forecasters, this._predictions);

  final ForecasterRepository _forecasters;
  final PredictionRepository _predictions;

  ForecasterDashboard? _dashboard;
  List<Prediction> _myPredictions = const [];
  bool _loading = false;
  String? _error;
  String? _forecasterId;
  String? _languageCode;

  ForecasterDashboard? get dashboard => _dashboard;
  List<Prediction> get myPredictions => _myPredictions;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({
    required String forecasterId,
    required String languageCode,
    bool force = false,
  }) async {
    if (!force &&
        _forecasterId == forecasterId &&
        _languageCode == languageCode &&
        _dashboard != null) {
      return;
    }
    _forecasterId = forecasterId;
    _languageCode = languageCode;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _forecasters.getMyDashboard(forecasterId),
        _predictions.list(
          forecasterId: forecasterId,
          languageCode: languageCode,
        ),
      ]);
      _dashboard = results[0] as ForecasterDashboard;
      _myPredictions = results[1] as List<Prediction>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
