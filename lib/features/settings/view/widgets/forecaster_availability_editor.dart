import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/nojoum_confirm_dialog.dart';
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

class _DaySchedule {
  _DaySchedule({
    required this.dayOfWeek,
    required this.enabled,
    required this.periods,
  });

  final int dayOfWeek;
  bool enabled;
  List<AvailabilityRule> periods;
}

class _ForecasterAvailabilityEditorState
    extends State<ForecasterAvailabilityEditor> {
  static const _defaultStart = '10:00:00';
  static const _defaultEnd = '17:00:00';

  late List<_DaySchedule> _days;
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

  List<_DaySchedule> _fromAvailability(ForecasterAvailability data) {
    final days = <_DaySchedule>[];
    for (var day = 0; day < 7; day++) {
      final periods = data.rules
          .where((rule) => rule.dayOfWeek == day && rule.isActive)
          .map((rule) => rule.copyWith(isActive: true))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      days.add(
        _DaySchedule(
          dayOfWeek: day,
          enabled: periods.isNotEmpty,
          periods: periods.isEmpty
              ? [
                  AvailabilityRule(
                    dayOfWeek: day,
                    startTime: _defaultStart,
                    endTime: _defaultEnd,
                  ),
                ]
              : periods,
        ),
      );
    }
    return days;
  }

  AvailabilityRule _defaultPeriod(int dayOfWeek) {
    AvailabilityRule? template;
    for (final day in _days) {
      if (day.enabled && day.periods.isNotEmpty) {
        template = day.periods.first;
        break;
      }
    }
    return AvailabilityRule(
      dayOfWeek: dayOfWeek,
      startTime: template?.startTime ?? _defaultStart,
      endTime: template?.endTime ?? _defaultEnd,
    );
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
    final rules = <AvailabilityRule>[
      for (final day in _days)
        if (day.enabled)
          for (final period in day.periods)
            period.copyWith(dayOfWeek: day.dayOfWeek, isActive: true),
    ];
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

  Future<void> _pickTime(
    int dayIndex,
    int periodIndex, {
    required bool start,
  }) async {
    if (!_editing) return;
    final period = _days[dayIndex].periods[periodIndex];
    final current = _parseTime(start ? period.startTime : period.endTime);
    final picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => _AvailabilityTimeDialog(initial: current),
    );
    if (picked == null) return;
    setState(() {
      final value = _formatTime(picked);
      _days[dayIndex].periods[periodIndex] = start
          ? period.copyWith(startTime: value)
          : period.copyWith(endTime: value);
    });
  }

  void _toggle(int index, bool enabled) {
    setState(() {
      final day = _days[index];
      day.enabled = enabled;
      if (enabled && day.periods.isEmpty) {
        day.periods = [_defaultPeriod(day.dayOfWeek)];
      }
    });
  }

  void _addPeriod(int dayIndex) {
    setState(() {
      final day = _days[dayIndex];
      final last = day.periods.isEmpty ? null : day.periods.last;
      day.periods = [
        ...day.periods,
        AvailabilityRule(
          dayOfWeek: day.dayOfWeek,
          startTime: last?.endTime ?? _defaultStart,
          endTime: last == null ? _defaultEnd : _shiftHour(last.endTime, 2),
        ),
      ];
    });
  }

  Future<void> _removePeriod(int dayIndex, int periodIndex) async {
    final day = _days[dayIndex];
    if (day.periods.length <= 1) return;
    final t = AppLocalizations.of(context);
    final confirmed = await NojoumConfirmDialog.show(
      context,
      title: t.deletePeriodTitle,
      message: t.deletePeriodMessage,
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      kind: NojoumConfirmKind.danger,
      icon: Icons.schedule_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      day.periods = [
        for (var i = 0; i < day.periods.length; i++)
          if (i != periodIndex) day.periods[i],
      ];
    });
  }

  String _shiftHour(String time, int hours) {
    final parts = time.split(':');
    final hour = ((int.tryParse(parts.first) ?? 10) + hours).clamp(0, 23);
    final minute = parts.length > 1 ? parts[1] : '00';
    final second = parts.length > 2 ? parts[2] : '00';
    return '${hour.toString().padLeft(2, '0')}:$minute:$second';
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
    final activeDays = _days.where((day) => day.enabled).toList();

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
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            for (var i = 0; i < _days.length; i++)
              _DayCard(
                name: _dayName(context, _days[i].dayOfWeek),
                day: _days[i],
                editing: _editing,
                addPeriodLabel: t.addPeriod,
                labelFor: (value) => _labelFor(context, value),
                onToggle: (value) => _toggle(i, value),
                onAddPeriod: () => _addPeriod(i),
                onRemovePeriod: (periodIndex) => _removePeriod(i, periodIndex),
                onPickStart: (periodIndex) =>
                    _pickTime(i, periodIndex, start: true),
                onPickEnd: (periodIndex) =>
                    _pickTime(i, periodIndex, start: false),
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

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.name,
    required this.day,
    required this.editing,
    required this.addPeriodLabel,
    required this.labelFor,
    required this.onToggle,
    required this.onAddPeriod,
    required this.onRemovePeriod,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final String name;
  final _DaySchedule day;
  final bool editing;
  final String addPeriodLabel;
  final String Function(String value) labelFor;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAddPeriod;
  final ValueChanged<int> onRemovePeriod;
  final ValueChanged<int> onPickStart;
  final ValueChanged<int> onPickEnd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!editing && !day.enabled) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (editing)
                Switch.adaptive(value: day.enabled, onChanged: onToggle)
              else
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Color(0xFF2BB673),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (day.enabled) ...[
            const SizedBox(height: 10),
            for (var i = 0; i < day.periods.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PeriodTile(
                  startLabel: labelFor(day.periods[i].startTime),
                  endLabel: labelFor(day.periods[i].endTime),
                  editing: editing,
                  canRemove: editing && day.periods.length > 1,
                  onStart: () => onPickStart(i),
                  onEnd: () => onPickEnd(i),
                  onRemove: () => onRemovePeriod(i),
                ),
              ),
            if (editing)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: onAddPeriod,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(addPeriodLabel),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PeriodTile extends StatelessWidget {
  const _PeriodTile({
    required this.startLabel,
    required this.endLabel,
    required this.editing,
    required this.canRemove,
    required this.onStart,
    required this.onEnd,
    required this.onRemove,
  });

  final String startLabel;
  final String endLabel;
  final bool editing;
  final bool canRemove;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PeriodTimeButton(
              value: startLabel,
              enabled: editing,
              onTap: onStart,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: scheme.primary,
            ),
          ),
          Expanded(
            child: _PeriodTimeButton(
              value: endLabel,
              enabled: editing,
              onTap: onEnd,
            ),
          ),
          if (canRemove) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.close_rounded, color: scheme.error),
              tooltip:
                  MaterialLocalizations.of(context).deleteButtonTooltip,
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodTimeButton extends StatelessWidget {
  const _PeriodTimeButton({
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
    );

    return Material(
      color: scheme.primary.withValues(alpha: enabled ? 0.14 : 0.08),
      borderRadius: BorderRadius.circular(12),
      child: enabled
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: child,
            )
          : child,
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

