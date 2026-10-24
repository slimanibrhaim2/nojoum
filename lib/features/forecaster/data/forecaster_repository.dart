import '../domain/forecaster.dart';
import '../domain/forecaster_me_profile.dart';
import '../domain/forecaster_profile_update.dart';

abstract class ForecasterRepository {
  Future<ForecasterPublicProfile> getPublicProfile(String id);
  Future<List<ForecasterPublicProfile>> listPublicProfiles();
  Future<ForecasterDashboard> getMyDashboard(String forecasterId);
  Future<ForecasterMeProfile> getMe();
  Future<ForecasterMeProfile> updateMe(ForecasterProfileUpdate update);
}
