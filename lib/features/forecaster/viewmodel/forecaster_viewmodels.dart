import 'package:flutter/foundation.dart';

import '../../predictions/data/prediction_repository.dart';
import '../../predictions/domain/prediction.dart';
import '../data/forecaster_repository.dart';
import '../domain/forecaster.dart';

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
