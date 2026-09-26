import '../../../core/mock/fake_ids.dart';
import '../domain/prediction.dart';
import 'prediction_repository.dart';

class _Localized {
  const _Localized({required this.ar, required this.en});
  final String ar;
  final String en;
  String of(String languageCode) => languageCode.startsWith('ar') ? ar : en;
}

class _Seed {
  _Seed({
    required this.id,
    required this.forecasterId,
    required this.forecasterName,
    required this.rate,
    required this.date,
    required this.summary,
    required this.details,
    required this.views,
    required this.likes,
    required this.shares,
  });

  final String id;
  final String forecasterId;
  final String forecasterName;
  final double rate;
  final DateTime date;
  final _Localized summary;
  final _Localized details;
  int views;
  int likes;
  int shares;
}

class PredictionRepositoryMock implements PredictionRepository {
  PredictionRepositoryMock()
      : _items = [
          _Seed(
            id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
            forecasterId: FakeIds.layla,
            forecasterName: 'ليلى النجمي',
            rate: 4.8,
            date: DateTime(2026, 9, 28),
            summary: const _Localized(
              ar: 'هذا الأسبوع يحمل خبراً لطيفاً من شخص بعيد.',
              en: 'This week brings gentle news from someone far away.',
            ),
            details: const _Localized(
              ar: 'القمر في بيت التواصل. انتبه لرسائل المساء، واترك باب المصالحة موارباً.',
              en: 'The moon sits in the house of messages. Watch evening notes, and leave the door ajar for peace.',
            ),
            views: 1280,
            likes: 214,
            shares: 41,
          ),
          _Seed(
            id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2',
            forecasterId: FakeIds.nader,
            forecasterName: 'نادر الفنجان',
            rate: 4.6,
            date: DateTime(2026, 9, 27),
            summary: const _Localized(
              ar: 'الفنجان يظهر سفراً قصيراً ثم قراراً مالياً حكيماً.',
              en: 'The cup shows a short trip, then a wise money decision.',
            ),
            details: const _Localized(
              ar: 'الخطوط تميل يميناً: لا تستعجل العقد قبل يوم الأربعاء.',
              en: 'The grounds lean right: do not rush the contract before Wednesday.',
            ),
            views: 860,
            likes: 151,
            shares: 22,
          ),
          _Seed(
            id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3',
            forecasterId: FakeIds.rania,
            forecasterName: 'رانيا الكف',
            rate: 4.9,
            date: DateTime(2026, 9, 26),
            summary: const _Localized(
              ar: 'خط القلب يتوهج: علاقة قديمة تعود بلطف لا بضجة.',
              en: 'The heart line glows: an old bond returns softly, not loudly.',
            ),
            details: const _Localized(
              ar: 'تجنّب الجدال بعد الغروب، واختر كلمة واحدة صادقة بدل عشر كلمات.',
              en: 'Skip arguments after sunset. One honest word beats ten.',
            ),
            views: 2104,
            likes: 390,
            shares: 73,
          ),
          _Seed(
            id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4',
            forecasterId: FakeIds.layla,
            forecasterName: 'ليلى النجمي',
            rate: 4.8,
            date: DateTime(2026, 10, 3),
            summary: const _Localized(
              ar: 'زحل يبطئ العمل: راجع خطتك ولا تلغِ حلمك.',
              en: 'Saturn slows the work: revise the plan, do not cancel the dream.',
            ),
            details: const _Localized(
              ar: 'أيام 2–4 تشرين الأول مناسبة للصمت المنتج أكثر من الاجتماعات.',
              en: 'October 2–4 favor quiet production more than meetings.',
            ),
            views: 540,
            likes: 97,
            shares: 11,
          ),
          _Seed(
            id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5',
            forecasterId: FakeIds.nader,
            forecasterName: 'نادر الفنجان',
            rate: 4.6,
            date: DateTime(2026, 9, 30),
            summary: const _Localized(
              ar: 'القهوة تكشف ضيفاً غير متوقع يوم الجمعة.',
              en: 'The coffee reveals an unexpected guest on Friday.',
            ),
            details: const _Localized(
              ar: 'جهز مكاناً بسيطاً في البيت. الضيف يحمل سؤالاً لا هدية.',
              en: 'Keep a simple place at home. The guest carries a question, not a gift.',
            ),
            views: 412,
            likes: 66,
            shares: 9,
          ),
          _Seed(
            id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6',
            forecasterId: FakeIds.layla,
            forecasterName: 'ليلى النجمي',
            rate: 4.8,
            date: DateTime(2026, 10, 8),
            summary: const _Localized(
              ar: 'نجمة الصباح تميل لصالحك إن صبرت حتى منتصف الشهر.',
              en: 'The morning star leans your way if you wait until mid-month.',
            ),
            details: const _Localized(
              ar: 'لا تبدأ مشروعاً جديداً قبل أن تغلق الباب القديم بلطف.',
              en: 'Do not open a new project until you close the old door kindly.',
            ),
            views: 305,
            likes: 58,
            shares: 7,
          ),
        ];

  final List<_Seed> _items;

  Prediction _toPrediction(_Seed seed, String languageCode) {
    return Prediction(
      id: seed.id,
      forecasterId: seed.forecasterId,
      forecasterName: seed.forecasterName,
      forecasterAverageRate: seed.rate,
      date: seed.date,
      summary: seed.summary.of(languageCode),
      details: seed.details.of(languageCode),
      viewCount: seed.views,
      likeCount: seed.likes,
      dislikeCount: 0,
      sharingCount: seed.shares,
    );
  }

  _Seed _find(String id) => _items.firstWhere((item) => item.id == id);

  @override
  Future<List<Prediction>> list({
    String? forecasterId,
    required String languageCode,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    final filtered = _items
        .where(
          (item) => forecasterId == null || item.forecasterId == forecasterId,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return const [];
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered
        .sublist(start, end)
        .map((item) => _toPrediction(item, languageCode))
        .toList();
  }

  @override
  Future<Prediction> getById(String id, {required String languageCode}) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _toPrediction(_find(id), languageCode);
  }

  @override
  Future<void> like(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _find(id).likes += 1;
  }

  @override
  Future<void> view(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _find(id).views += 1;
  }

  @override
  Future<void> share(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _find(id).shares += 1;
  }
}
