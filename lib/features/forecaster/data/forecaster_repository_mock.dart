import '../../../core/mock/fake_ids.dart';
import '../domain/forecaster.dart';
import '../domain/money.dart';
import 'forecaster_repository.dart';

class ForecasterRepositoryMock implements ForecasterRepository {
  ForecasterRepositoryMock();

  static final profiles = <ForecasterPublicProfile>[
    ForecasterPublicProfile(
      id: FakeIds.layla,
      name: 'ليلى النجمي',
      imagePath: null,
      averageRate: 4.8,
      reviewCount: 126,
      money: const Money(amount: 25, currency: 'USD'),
      type: ForecastingType.astrology | ForecastingType.palm,
      availabilitySettings: const AvailabilitySettings(
        sessionDurationInMinutes: 45,
        bufferMinutesBetweenSessions: 15,
        minimumNoticeInMinutes: 120,
      ),
    ),
    ForecasterPublicProfile(
      id: FakeIds.nader,
      name: 'نادر الفنجان',
      imagePath: null,
      averageRate: 4.6,
      reviewCount: 89,
      money: const Money(amount: 18, currency: 'USD'),
      type: ForecastingType.coffeeCup,
      availabilitySettings: const AvailabilitySettings(
        sessionDurationInMinutes: 30,
        bufferMinutesBetweenSessions: 10,
        minimumNoticeInMinutes: 60,
      ),
    ),
    ForecasterPublicProfile(
      id: FakeIds.rania,
      name: 'رانيا الكف',
      imagePath: null,
      averageRate: 4.9,
      reviewCount: 204,
      money: const Money(amount: 30, currency: 'USD'),
      type: ForecastingType.palm | ForecastingType.coffeeCup,
      availabilitySettings: const AvailabilitySettings(
        sessionDurationInMinutes: 60,
        bufferMinutesBetweenSessions: 20,
        minimumNoticeInMinutes: 180,
      ),
    ),
  ];

  @override
  Future<List<ForecasterPublicProfile>> listPublicProfiles() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(profiles);
  }

  @override
  Future<ForecasterPublicProfile> getPublicProfile(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return profiles.firstWhere(
      (profile) => profile.id == id,
      orElse: () => throw Exception('Forecaster not found'),
    );
  }

  @override
  Future<ForecasterDashboard> getMyDashboard(String forecasterId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final profile = await getPublicProfile(forecasterId);
    final predictionCount = switch (forecasterId) {
      FakeIds.layla => 3,
      FakeIds.nader => 2,
      FakeIds.rania => 1,
      _ => 0,
    };
    return ForecasterDashboard(
      id: profile.id,
      totalPredictions: predictionCount,
      averageRate: profile.averageRate.round(),
      reviewCount: profile.reviewCount,
      bookings: const [],
      email: 'fore@test.com',
      fullName: profile.name,
    );
  }
}
