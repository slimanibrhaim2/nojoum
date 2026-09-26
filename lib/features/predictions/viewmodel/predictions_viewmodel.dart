import 'package:flutter/foundation.dart';

import '../data/prediction_repository.dart';
import '../domain/prediction.dart';

class PredictionsViewModel extends ChangeNotifier {
  PredictionsViewModel(this._repo);

  final PredictionRepository _repo;

  List<Prediction> _items = const [];
  bool _loading = false;
  String? _error;
  String? _languageCode;
  String? _forecasterId;

  List<Prediction> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({
    required String languageCode,
    String? forecasterId,
    bool force = false,
  }) async {
    if (!force &&
        _languageCode == languageCode &&
        _forecasterId == forecasterId &&
        _items.isNotEmpty) {
      return;
    }
    _languageCode = languageCode;
    _forecasterId = forecasterId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.list(
        languageCode: languageCode,
        forecasterId: forecasterId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> like(String id) async {
    await _repo.like(id);
    _items = [
      for (final item in _items)
        if (item.id == id)
          item.copyWith(likeCount: item.likeCount + 1)
        else
          item,
    ];
    notifyListeners();
  }
}
