import 'package:flutter/widgets.dart';

import '../core/form_control.dart';

/// Mixes focus tracking into your own [State], for a field that has no
/// [TextEditingController] of its own (a picker, a dropdown, a button) —
/// see `FormControlTextSync` for one that does.
///
/// Owns [focusNode] and exposes [isFocused]. Registers with the control
/// so `control.handleUnfocus()` fires on blur (what `onUnfocus`/
/// `afterFirstUnfocus` need), `control.requestFocus()` focuses the
/// field, and `control.ensureVisible()` scrolls it into view when it
/// has a scrollable ancestor — [initState], [didChangeDependencies],
/// [didUpdateWidget] and [dispose] are all handled here, including
/// switching if a later build passes a different control.
///
/// ```dart
/// class _DateFieldState extends State<DateField> with FormControlFocusSync<DateField> {
///   @override
///   FormControl<DateTime?> get control => widget.control;
///
///   @override
///   Widget build(BuildContext context) {
///     return OutlinedButton(
///       focusNode: focusNode,
///       onPressed: () async {
///         final picked = await showDatePicker(/* ... */);
///         if (picked != null) control.value = picked;
///         control.handleUnfocus(); // the picker handled its own focus
///       },
///       style: OutlinedButton.styleFrom(
///         side: isFocused ? const BorderSide(width: 2) : null,
///       ),
///       child: Text(control.value?.toString() ?? 'Pick a date'),
///     );
///   }
/// }
/// ```
mixin FormControlFocusSync<T extends StatefulWidget> on State<T> {
  /// The control this field is bound to.
  FormControl<Object?> get control;

  /// Pass this to whatever focusable widget you're building. Owned here
  /// and disposed automatically.
  late final FocusNode focusNode = FocusNode()..addListener(_handleFocusChange);

  /// Whether [focusNode] currently has focus — handy for styling (e.g. a
  /// highlighted border) without re-deriving it yourself.
  bool get isFocused => focusNode.hasFocus;

  FormControl<Object?>? _syncedControl;

  void _handleFocusChange() {
    if (!focusNode.hasFocus) {
      control.handleUnfocus();
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _resync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registerEnsureVisible();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resync();
    _registerEnsureVisible(); // control may have just changed
  }

  void _resync() {
    if (_syncedControl == control) return;

    _syncedControl?.attachRequestFocusCallback(null);
    _syncedControl = control;
    control.attachRequestFocusCallback(focusNode.requestFocus);
  }

  void _registerEnsureVisible() {
    control.attachEnsureVisibleCallback(
      Scrollable.maybeOf(context) != null ? () => Scrollable.ensureVisible(context) : null,
    );
  }

  @override
  void dispose() {
    control.attachRequestFocusCallback(null);
    control.attachEnsureVisibleCallback(null);
    focusNode.dispose();
    super.dispose();
  }
}
