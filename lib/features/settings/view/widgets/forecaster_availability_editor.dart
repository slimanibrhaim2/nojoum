import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/nojoum_toast.dart';
import '../../../forecaster/domain/availability.dart';
import '../../../forecaster/viewmodel/forecaster_viewmodels.dart';

class ForecasterAvailabilityEditor extends StatefulWidget {
  const ForecasterAvailabilityEditor({
    super.key,
    required this.availability,
    required this.viewModel,
  });

  final ForecasterAvailability availability;
  final ForecasterMeViewModel viewModel;

  @override
  State<ForecasterAvailabilityEditor> createState() =>
      _ForecasterAvailabilityEditorState();
}

class _ForecasterAvailabilityEditorState
    extends State<ForecasterAvailabilityEditor> {
  static const _defaultStart = '10:00:00';
  static const _defaultEnd = '17:00:00';

  late List<AvailabilityRule> _days;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _days = _fromAvailability(widget.availability);
  }

  @override
  void didUpdateWidget(covariant ForecasterAvailabilityEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.availability != widget.availability) {
      _days = _fromAvailability(widget.availability);
    }
  }

  List<AvailabilityRule> _fromAvailability(ForecasterAvailability data) {
    return [
      for (var day = 0; day < 7; day++)
        data.rules.firstWhere(
          (rule) => rule.dayOfWeek == day,
          orElse: () => AvailabilityRule(
            dayOfWeek: day,
            startTime: _defaultStart,
            endTime: _defaultEnd,
            isActive: false,
          ),
        ),
    ];
  }

  void _startEditing() => setState(() => _editing = true);

  void _cancel() {
    setState(() {
      _editing = false;
      _days = _fromAvailability(widget.availability);
    });
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final rules = _days
        .where((day) => day.isActive || (day.id != null && day.id!.isNotEmpty))
        .toList();
    final ok = await widget.viewModel.saveAvailability(
      ForecasterAvailability(
        forecasterId: widget.availability.forecasterId,
        rules: rules,
        overrides: widget.availability.overrides,
      ),
    );
    if (!mounted) return;
    if (ok) setState(() => _editing = false);
    NojoumToast.show(
      context,
      message: ok
          ? t.availabilitySaved
          : (widget.viewModel.availabilityError ?? t.comingSoon),
      kind: ok ? NojoumToastKind.success : NojoumToastKind.error,
    );
  }

  Future<void> _pickTime(int index, {required bool start}) async {
    if (!_editing) return;
    final day = _days[index];
    final current = _parseTime(start ? day.startTime : day.endTime);
    final picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => _AvailabilityTimeDialog(initial: current),
    );
    if (picked == null) return;
    setState(() {
      final value = _formatTime(picked);
      _days[index] = start
          ? day.copyWith(startTime: value)
          : day.copyWith(endTime: value);
    });
  }

  void _toggle(int index, bool active) {
    setState(() {
      final day = _days[index];
      var start = day.startTime;
      var end = day.endTime;
      if (active) {
        final template = _days.firstWhere(
          (item) => item.isActive,
          orElse: () => const AvailabilityRule(
            dayOfWeek: 0,
            startTime: _defaultStart,
            endTime: _defaultEnd,
          ),
        );
        if (!day.isActive) {
          start = template.startTime;
          end = template.endTime;
        }
      }
      _days[index] = day.copyWith(
        isActive: active,
        startTime: start,
        endTime: end,
      );
    });
  }

  void _applyHoursToSelected() {
    final first = _days.firstWhere(
      (day) => day.isActive,
      orElse: () => const AvailabilityRule(
        dayOfWeek: 0,
        startTime: _defaultStart,
        endTime: _defaultEnd,
      ),
    );
    setState(() {
      _days = [
        for (final day in _days)
          day.isActive
              ? day.copyWith(startTime: first.startTime, endTime: first.endTime)
              : day,
      ];
    });
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 10,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  String _dayName(BuildContext context, int dayOfWeek) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.EEEE(locale).format(DateTime.utc(2024, 1, 7 + dayOfWeek));
  }

  String _labelFor(BuildContext context, String value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(_parseTime(value));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final saving = widget.viewModel.savingAvailability;
    final activeDays = _days.where((day) => day.isActive).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_month_rounded, color: scheme.accent),
              title: Text(
                t.availabilityHint,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
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
                        backgroundColor: scheme.primary.withValues(alpha: 0.12),
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
            if (!_editing && activeDays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  t.noAvailability,
                  style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.8)),
                ),
              ),
            if (_editing) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: _applyHoursToSelected,
                  child: Text(t.applyHours),
                ),
              ),
            ],
            for (var i = 0; i < _days.length; i++)
              _DayRow(
                name: _dayName(context, _days[i].dayOfWeek),
                rule: _days[i],
                editing: _editing,
                startLabel: _labelFor(context, _days[i].startTime),
                endLabel: _labelFor(context, _days[i].endTime),
                onToggle: (value) => _toggle(i, value),
                onStart: () => _pickTime(i, start: true),
                onEnd: () => _pickTime(i, start: false),
                fromLabel: t.startTime,
                toLabel: t.endTime,
              ),
            if (_editing) ...[
              const SizedBox(height: 16),
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
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.name,
    required this.rule,
    required this.editing,
    required this.startLabel,
    required this.endLabel,
    required this.onToggle,
    required this.onStart,
    required this.onEnd,
    required this.fromLabel,
    required this.toLabel,
  });

  final String name;
  final AvailabilityRule rule;
  final bool editing;
  final String startLabel;
  final String endLabel;
  final ValueChanged<bool> onToggle;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final String fromLabel;
  final String toLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = rule.isActive;
    if (!editing && !active) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (editing)
            Switch.adaptive(value: active, onChanged: onToggle)
          else
            Icon(
              Icons.check_circle,
              size: 20,
              color: const Color(0xFF2BB673),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          if (active) ...[
            _TimeChip(
              label: '$fromLabel $startLabel',
              onTap: editing ? onStart : null,
            ),
            const SizedBox(width: 6),
            _TimeChip(
              label: '$toLabel $endLabel',
              onTap: editing ? onEnd : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _AvailabilityTimeDialog extends StatefulWidget {
  const _AvailabilityTimeDialog({required this.initial});

  final TimeOfDay initial;

  @override
  State<_AvailabilityTimeDialog> createState() => _AvailabilityTimeDialogState();
}

class _AvailabilityTimeDialogState extends State<_AvailabilityTimeDialog> {
  late final TextEditingController _hourCtrl;
  late final TextEditingController _minuteCtrl;
  late final FocusNode _hourFocus;
  late final FocusNode _minuteFocus;
  late bool _pm;
  late bool _use24h;

  @override
  void initState() {
    super.initState();
    _hourCtrl = TextEditingController();
    _minuteCtrl = TextEditingController(
      text: widget.initial.minute.toString().padLeft(2, '0'),
    );
    _hourFocus = FocusNode()..addListener(() => setState(() {}));
    _minuteFocus = FocusNode()..addListener(() => setState(() {}));
    _hourCtrl.addListener(() => setState(() {}));
    _minuteCtrl.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    if (_hourCtrl.text.isEmpty) {
      _pm = widget.initial.period == DayPeriod.pm;
      final hour = _use24h
          ? widget.initial.hour
          : widget.initial.hourOfPeriod == 0
          ? 12
          : widget.initial.hourOfPeriod;
      _hourCtrl.text = hour.toString().padLeft(2, '0');
    }
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _hourFocus.dispose();
    _minuteFocus.dispose();
    super.dispose();
  }

  TimeOfDay? _parsed() {
    var hour = int.tryParse(_hourCtrl.text.trim());
    final minute = int.tryParse(_minuteCtrl.text.trim());
    if (hour == null || minute == null) return null;
    if (minute < 0 || minute > 59) return null;
    if (_use24h) {
      if (hour < 0 || hour > 23) return null;
    } else {
      if (hour < 1 || hour > 12) return null;
      hour %= 12;
      if (_pm) hour += 12;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _submit() {
    final value = _parsed();
    if (value == null) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final parsed = _parsed();
    final preview = parsed == null
        ? '--:--'
        : localizations.formatTimeOfDay(parsed);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withValues(alpha: 0.18),
                scheme.surface,
                scheme.secondaryContainer.withValues(alpha: 0.45),
              ],
            ),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  preview,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizations.timePickerInputHelpText,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _TimeDigitField(
                        controller: _hourCtrl,
                        focusNode: _hourFocus,
                        label: t.hourLabel,
                        max: _use24h ? 23 : 12,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18, left: 8, right: 8),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _TimeDigitField(
                        controller: _minuteCtrl,
                        focusNode: _minuteFocus,
                        label: t.minuteLabel,
                        max: 59,
                      ),
                    ),
                  ],
                ),
                if (!_use24h) ...[
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('AM')),
                      ButtonSegment(value: true, label: Text('PM')),
                    ],
                    selected: {_pm},
                    onSelectionChanged: (value) {
                      setState(() => _pm = value.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        return states.contains(WidgetState.selected)
                            ? scheme.onPrimary
                            : scheme.onSurface;
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        return states.contains(WidgetState.selected)
                            ? scheme.primary
                            : scheme.surface.withValues(alpha: 0.5);
                      }),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(t.cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: parsed == null ? null : _submit,
                        child: Text(localizations.okButtonLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeDigitField extends StatelessWidget {
  const _TimeDigitField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.max,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final int max;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final focused = focusNode.hasFocus;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: focused
                ? scheme.primary.withValues(alpha: 0.16)
                : scheme.surface.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: focused ? scheme.primary : scheme.outlineVariant,
              width: focused ? 1.8 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 2,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
              height: 1.1,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (value) {
              final number = int.tryParse(value);
              if (number == null || number <= max) return;
              final next = max.toString().padLeft(2, '0');
              controller.value = TextEditingValue(
                text: next,
                selection: TextSelection.collapsed(offset: next.length),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
