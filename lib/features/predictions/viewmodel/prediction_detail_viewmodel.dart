import 'package:flutter/foundation.dart';

import '../../forecaster/data/forecaster_repository.dart';
import '../../forecaster/domain/forecaster.dart';
import '../data/prediction_repository.dart';
import '../domain/prediction.dart';

class PredictionDetailViewModel extends ChangeNotifier {
  PredictionDetailViewModel(this._predictions, this._forecasters);

  final PredictionRepository _predictions;
  final ForecasterRepository _forecasters;

  Prediction? _prediction;
  ForecasterPublicProfile? _forecaster;
  bool _loading = false;
  bool _busy = false;
  String? _error;
  String? _loadedKey;

  Prediction? get prediction => _prediction;
  ForecasterPublicProfile? get forecaster => _forecaster;
  bool get loading => _loading;
  bool get busy => _busy;
  String? get error => _error;

  Future<void> load({
    required String id,
    required String languageCode,
    bool force = false,
  }) async {
    final key = '$id:$languageCode';
    if (!force && _loadedKey == key && _prediction != null) return;

    _loadedKey = key;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _prediction = await _predictions.getById(id, languageCode: languageCode);
      _forecaster = null;
      final forecasterId = _prediction!.forecasterId;
      if (forecasterId.isNotEmpty) {
        try {
          _forecaster = await _forecasters.getPublicProfile(forecasterId);
        } catch (_) {
          _forecaster = null;
        }
      }
    } catch (e) {
      _error = e.toString();
      _prediction = null;
      _forecaster = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> like() async {
    final current = _prediction;
    if (current == null || _busy) return;
    _busy = true;
    notifyListeners();
    try {
      final newLikeCount = await _predictions.like(current.id);
      final nextLiked = !current.isLikedByCurrentUser;
      final nextDislikeCount = current.isDislikedByCurrentUser
          ? (current.dislikeCount > 0 ? current.dislikeCount - 1 : 0)
          : current.dislikeCount;
      _prediction = current.copyWith(
        likeCount: newLikeCount,
        dislikeCount: nextDislikeCount,
        isLikedByCurrentUser: nextLiked,
        isDislikedByCurrentUser: false,
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> dislike() async {
    final current = _prediction;
    if (current == null || _busy) return;
    _busy = true;
    notifyListeners();
    try {
      final newDislikeCount = await _predictions.dislike(current.id);
      final nextDisliked = !current.isDislikedByCurrentUser;
      final nextLikeCount = current.isLikedByCurrentUser
          ? (current.likeCount > 0 ? current.likeCount - 1 : 0)
          : current.likeCount;
      _prediction = current.copyWith(
        dislikeCount: newDislikeCount,
        likeCount: nextLikeCount,
        isDislikedByCurrentUser: nextDisliked,
        isLikedByCurrentUser: false,
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> recordShare() async {
    final current = _prediction;
    if (current == null || _busy) return;
    _busy = true;
    notifyListeners();
    try {
      final newShareCount = await _predictions.share(current.id);
      _prediction = current.copyWith(sharingCount: newShareCount);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
