import '../domain/forecaster.dart';

abstract class ForecasterRepository {
  Future<ForecasterPublicProfile> getPublicProfile(String id);
  Future<List<ForecasterPublicProfile>> listPublicProfiles();
  Future<ForecasterDashboard> getMyDashboard(String forecasterId);
}
