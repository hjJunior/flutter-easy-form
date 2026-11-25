import 'package:flutter/widgets.dart';

import '../core/form_control.dart';

/// Base class for a widget bound to a single [FormControl].
///
/// Handles listening to the control and rebuilding whenever it notifies
/// (value, touched, errors, enabled/disabled, ...), including switching
/// listeners if a different [control] is passed in later — a concrete
/// field widget only has to implement [build]:
///
/// ```dart
/// class SwitchFormControl extends FormControlWidget<bool> {
///   const SwitchFormControl({super.key, required super.control, required this.label});
///
///   final String label;
///
///   @override
///   Widget build(BuildContext context, FormControl<bool> control) {
///     return SwitchListTile(
///       title: Text(label),
///       value: control.value,
///       onChanged: control.disabled ? null : (value) => control.value = value,
///     );
///   }
/// }
/// ```
abstract class FormControlWidget<T> extends StatefulWidget {
  const FormControlWidget({super.key, required this.control});

  /// The control this widget renders and edits.
  final FormControl<T> control;

  /// Builds the widget for the current state of [control]. Called again
  /// automatically whenever the control notifies, so reading
  /// `control.value`, `control.errors`, etc. here always reflects the
  /// latest state — no separate rebuild wiring needed in the subclass.
  Widget build(BuildContext context, FormControl<T> control);

  @override
  State<FormControlWidget<T>> createState() => _FormControlWidgetState<T>();
}

class _FormControlWidgetState<T> extends State<FormControlWidget<T>> {
  @override
  void initState() {
    super.initState();
    widget.control.addListener(_onControlChanged);
  }

  @override
  void didUpdateWidget(FormControlWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.control != widget.control) {
      oldWidget.control.removeListener(_onControlChanged);
      widget.control.addListener(_onControlChanged);
    }
  }

  @override
  void dispose() {
    widget.control.removeListener(_onControlChanged);
    super.dispose();
  }

  void _onControlChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.build(context, widget.control);
}
