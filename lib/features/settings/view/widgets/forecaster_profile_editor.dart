import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/mock/fake_ids.dart';
import '../../../../shared/widgets/nojoum_toast.dart';
import '../../../../shared/widgets/photo_lightbox.dart';
import '../../../../shared/widgets/remote_avatar.dart';
import '../../../forecaster/domain/forecaster_me_profile.dart';
import '../../../forecaster/domain/forecaster_profile_update.dart';
import '../../../forecaster/viewmodel/forecaster_viewmodels.dart';

class ForecasterProfileEditor extends StatefulWidget {
  const ForecasterProfileEditor({
    super.key,
    required this.profile,
    required this.viewModel,
  });

  final ForecasterMeProfile profile;
  final ForecasterMeViewModel viewModel;

  @override
  State<ForecasterProfileEditor> createState() => _ForecasterProfileEditorState();
}

class _ForecasterProfileEditorState extends State<ForecasterProfileEditor> {
  static const _currencies = ['USD', 'EUR', 'GBP', 'AED', 'SAR', 'SYP'];
  static final _timeZones = _availableTimeZones();
  static const _types = [0, 1, 2, 4, 8, 16, 32, 64, 128];

  static List<String> _availableTimeZones() {
    tz_data.initializeTimeZones();
    final zones = tz.timeZoneDatabase.locations.keys
        .where((zone) => zone != 'Etc/UTC')
        .toList()
      ..sort();
    return List.unmodifiable(['UTC', ...zones.where((zone) => zone != 'UTC')]);
  }

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _bufferCtrl;
  late final TextEditingController _noticeCtrl;

  late String _currency;
  late int _type;
  late String _timeZone;
  String? _localImagePath;
  bool _editing = false;
  int _formEpoch = 0;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _durationCtrl = TextEditingController();
    _bufferCtrl = TextEditingController();
    _noticeCtrl = TextEditingController();
    _hydrate(widget.profile);
  }

  @override
  void didUpdateWidget(covariant ForecasterProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.profile != widget.profile) {
      _hydrate(widget.profile);
    }
  }

  void _hydrate(ForecasterMeProfile profile) {
    _nameCtrl.text = profile.fullName;
    _priceCtrl.text = profile.sessionPrice.toStringAsFixed(
      profile.sessionPrice.truncateToDouble() == profile.sessionPrice ? 0 : 2,
    );
    _durationCtrl.text =
        '${profile.availabilitySettings.sessionDurationInMinutes}';
    _bufferCtrl.text =
        '${profile.availabilitySettings.bufferMinutesBetweenSessions}';
    _noticeCtrl.text =
        '${profile.availabilitySettings.minimumNoticeInMinutes}';
    _currency = profile.currency;
    _type = profile.type;
    _timeZone = profile.timeZoneId.isEmpty ? 'UTC' : profile.timeZoneId;
    _localImagePath = null;
    _formEpoch++;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _bufferCtrl.dispose();
    _noticeCtrl.dispose();
    super.dispose();
  }

  void _previewPhoto() {
    PhotoLightbox.open(
      context,
      networkUrl: AppConfig.mediaUrl(widget.profile.imagePath),
      filePath: _localImagePath,
    );
  }

  Future<void> _pickImage() async {
    if (!_editing || kIsWeb) return;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _localImagePath = file.path);
  }

  void _startEditing() => setState(() => _editing = true);

  void _cancel() {
    setState(() {
      _editing = false;
      _hydrate(widget.profile);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final t = AppLocalizations.of(context);
    final ok = await widget.viewModel.save(
      ForecasterProfileUpdate(
        fullName: _nameCtrl.text.trim(),
        sessionPrice: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        currency: _currency,
        type: _type,
        sessionDurationInMinutes: int.tryParse(_durationCtrl.text.trim()) ?? 0,
        bufferMinutesBetweenSessions:
            int.tryParse(_bufferCtrl.text.trim()) ?? 0,
        minimumNoticeInMinutes: int.tryParse(_noticeCtrl.text.trim()) ?? 0,
        timeZoneId: _timeZone,
        imageFilePath: _localImagePath,
      ),
    );
    if (!mounted) return;
    if (ok) setState(() => _editing = false);
    NojoumToast.show(
      context,
      message: ok ? t.profileSaved : (widget.viewModel.error ?? t.comingSoon),
      kind: ok ? NojoumToastKind.success : NojoumToastKind.error,
    );
  }

  TextStyle _valueStyle(ColorScheme scheme) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w600,
    );
  }

  InputDecoration _fieldDecoration(
    ColorScheme scheme, {
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.55)),
    );
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: scheme.onSurface.withValues(alpha: 0.82),
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: _FieldIcon(icon: icon, color: color),
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.85),
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
    );
  }

  String _typeLabel(AppLocalizations t, int value) {
    switch (value) {
      case ForecastingType.palm:
        return t.typePalm;
      case ForecastingType.coffeeCup:
        return t.typeCoffee;
      case ForecastingType.astrology:
        return t.typeAstrology;
      default:
        return t.forecastingTypeCode(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final profile = widget.profile;
    final saving = widget.viewModel.saving;
    final currencies = {
      ..._currencies,
      if (!_currencies.contains(_currency)) _currency,
    }.toList();
    final types = {..._types, _type}.toList()..sort();
    final timeZones = {
      ..._timeZones,
      if (!_timeZones.contains(_timeZone)) _timeZone,
    }.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _FieldIcon(
                  icon: Icons.auto_awesome,
                  color: scheme.primary,
                ),
                title: Text(
                  t.forecastingProfile,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                subtitle: profile.email.isEmpty
                    ? null
                    : Text(
                        profile.email,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                trailing: _editing
                    ? null
                    : OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          foregroundColor: scheme.primary,
                          backgroundColor: scheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          side: BorderSide(color: scheme.primary, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _startEditing,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(
                          t.edit,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              _AvatarEditor(
                networkUrl: AppConfig.mediaUrl(profile.imagePath),
                localPath: _localImagePath,
                onTap: _editing ? _pickImage : _previewPhoto,
                onLongPress: _previewPhoto,
                label: t.changePhoto,
                editing: _editing,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const _FieldIcon(
                        icon: Icons.star_rounded,
                        color: Color(0xFFE0A100),
                      ),
                      title: Text(
                        profile.averageRate.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        t.rating,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const _FieldIcon(
                        icon: Icons.reviews_rounded,
                        color: Color(0xFF4C8DFF),
                      ),
                      title: Text(
                        '${profile.reviewCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        t.reviews,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Theme(
                data: Theme.of(context).copyWith(
                  disabledColor: scheme.onSurface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      enabled: _editing,
                      style: _valueStyle(scheme),
                      textCapitalization: TextCapitalization.words,
                      decoration: _fieldDecoration(
                        scheme,
                        label: t.fullName,
                        icon: Icons.person_rounded,
                        color: scheme.primary,
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? t.fullName
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _priceCtrl,
                            enabled: _editing,
                            style: _valueStyle(scheme),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _fieldDecoration(
                              scheme,
                              label: t.sessionPrice,
                              icon: Icons.payments_rounded,
                              color: const Color(0xFFE0A100),
                            ),
                            validator: (value) =>
                                double.tryParse(value ?? '') == null
                                ? t.sessionPrice
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('currency-$_formEpoch-$_editing'),
                            initialValue: currencies.contains(_currency)
                                ? _currency
                                : currencies.first,
                            style: _valueStyle(scheme),
                            decoration: _fieldDecoration(
                              scheme,
                              label: t.currency,
                              icon: Icons.attach_money_rounded,
                              color: const Color(0xFF2BB673),
                            ),
                            items: [
                              for (final item in currencies)
                                DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                            ],
                            onChanged: _editing
                                ? (value) {
                                    if (value == null) return;
                                    setState(() => _currency = value);
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      key: ValueKey('type-$_formEpoch-$_editing'),
                      initialValue: types.contains(_type)
                          ? _type
                          : types.first,
                      style: _valueStyle(scheme),
                      decoration: _fieldDecoration(
                        scheme,
                        label: t.forecastingType,
                        icon: Icons.auto_awesome,
                        color: const Color(0xFFB56BFF),
                      ),
                      items: [
                        for (final item in types)
                          DropdownMenuItem(
                            value: item,
                            child: Text(_typeLabel(t, item)),
                          ),
                      ],
                      onChanged: _editing
                          ? (value) {
                              if (value == null) return;
                              setState(() => _type = value);
                            }
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _durationCtrl,
                            enabled: _editing,
                            style: _valueStyle(scheme),
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration(
                              scheme,
                              label: t.sessionDuration,
                              icon: Icons.schedule_rounded,
                              color: const Color(0xFF4C8DFF),
                            ).copyWith(suffixText: t.minutes),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _bufferCtrl,
                            enabled: _editing,
                            style: _valueStyle(scheme),
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration(
                              scheme,
                              label: t.bufferMinutes,
                              icon: Icons.hourglass_bottom_rounded,
                              color: const Color(0xFFFF8A3D),
                            ).copyWith(suffixText: t.minutes),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noticeCtrl,
                      enabled: _editing,
                      style: _valueStyle(scheme),
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(
                        scheme,
                        label: t.minimumNotice,
                        icon: Icons.notifications_active_rounded,
                        color: const Color(0xFFFF5C7A),
                      ).copyWith(suffixText: t.days),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('tz-$_formEpoch-$_editing'),
                      initialValue: timeZones.contains(_timeZone)
                          ? _timeZone
                          : timeZones.first,
                      style: _valueStyle(scheme),
                      decoration: _fieldDecoration(
                        scheme,
                        label: t.timeZone,
                        icon: Icons.public_rounded,
                        color: const Color(0xFF2EC4B6),
                      ),
                      items: [
                        for (final item in timeZones)
                          DropdownMenuItem(value: item, child: Text(item)),
                      ],
                      onChanged: _editing
                          ? (value) {
                              if (value == null) return;
                              setState(() => _timeZone = value);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              if (_editing) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: saving ? null : _cancel,
                        child: Text(t.cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                        ),
                        onPressed: saving ? null : _save,
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(t.saveChanges),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldIcon extends StatelessWidget {
  const _FieldIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({
    required this.networkUrl,
    required this.localPath,
    required this.onTap,
    required this.onLongPress,
    required this.label,
    required this.editing,
  });

  final String networkUrl;
  final String? localPath;
  final VoidCallback? onTap;
  final VoidCallback onLongPress;
  final String label;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final photo = Hero(
      tag: 'profile-photo',
      child: localPath != null
          ? ClipOval(
              child: Image.file(
                File(localPath!),
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            )
          : RemoteAvatar(url: networkUrl, radius: 48),
    );

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              photo,
              if (editing)
                CircleAvatar(
                  radius: 14,
                  backgroundColor: scheme.primary,
                  child: Icon(
                    Icons.photo_camera,
                    size: 14,
                    color: scheme.onPrimary,
                  ),
                ),
            ],
          ),
        ),
        if (editing) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: onTap, child: Text(label)),
        ],
      ],
    );
  }
}

