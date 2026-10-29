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
  final Set<String> _busyIds = {};

  List<Prediction> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  bool isBusy(String id) => _busyIds.contains(id);

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

  Prediction? _find(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _replace(Prediction updated) {
    _items = [
      for (final item in _items)
        if (item.id == updated.id) updated else item,
    ];
  }

  Future<void> like(String id) async {
    final current = _find(id);
    if (current == null || _busyIds.contains(id)) return;

    _busyIds.add(id);
    notifyListeners();
    try {
      final newLikeCount = await _repo.like(id);
      final nextLiked = !current.isLikedByCurrentUser;
      final nextDislikeCount = current.isDislikedByCurrentUser
          ? (current.dislikeCount > 0 ? current.dislikeCount - 1 : 0)
          : current.dislikeCount;
      _replace(
        current.copyWith(
          likeCount: newLikeCount,
          dislikeCount: nextDislikeCount,
          isLikedByCurrentUser: nextLiked,
          isDislikedByCurrentUser: false,
        ),
      );
    } finally {
      _busyIds.remove(id);
      notifyListeners();
    }
  }

  Future<void> dislike(String id) async {
    final current = _find(id);
    if (current == null || _busyIds.contains(id)) return;

    _busyIds.add(id);
    notifyListeners();
    try {
      final newDislikeCount = await _repo.dislike(id);
      final nextDisliked = !current.isDislikedByCurrentUser;
      final nextLikeCount = current.isLikedByCurrentUser
          ? (current.likeCount > 0 ? current.likeCount - 1 : 0)
          : current.likeCount;
      _replace(
        current.copyWith(
          dislikeCount: newDislikeCount,
          likeCount: nextLikeCount,
          isDislikedByCurrentUser: nextDisliked,
          isLikedByCurrentUser: false,
        ),
      );
    } finally {
      _busyIds.remove(id);
      notifyListeners();
    }
  }
}
