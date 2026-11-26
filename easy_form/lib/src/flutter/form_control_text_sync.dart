import 'package:flutter/widgets.dart';

import '../core/form_control.dart';

/// Mixes the sync between a `FormControl<String>` and a
/// [TextEditingController] into your own [State] — deliberately not a
/// replacement for [TextField] itself: you keep writing (and fully
/// customizing) that widget, this just removes the controller plumbing
/// around it.
///
/// Implement [control] (typically `=> widget.control`); the mixin takes
/// care of the rest on its own — [initState], [didUpdateWidget] and
/// [dispose] are all handled here, including switching listeners if a
/// later build passes a different control. It also owns [focusNode] and
/// calls `control.handleUnfocus()` when the field loses focus, which is
/// what the `onUnfocus`/`afterFirstUnfocus` validation modes need —
/// pass it to your `TextField`'s `focusNode`:
///
/// ```dart
/// class _NameFieldState extends State<NameField> with FormControlTextSync<NameField> {
///   @override
///   FormControl<String> get control => widget.control;
///
///   @override
///   Widget build(BuildContext context) {
///     return TextField(
///       controller: textController,
///       focusNode: focusNode,
///       decoration: InputDecoration(labelText: 'Name', errorText: control.displayError),
///       enabled: control.enabled,
///       onChanged: (value) => control.value = value,
///     );
///   }
/// }
/// ```
mixin FormControlTextSync<T extends StatefulWidget> on State<T> {
  /// The control to keep [textController] in sync with.
  FormControl<String> get control;

  /// The controller to pass to your [TextField] (or any widget that takes
  /// a [TextEditingController]). Seeded with [control]'s value, and kept
  /// matching it for the lifetime of this state.
  late final TextEditingController textController = TextEditingController(text: control.value);

  /// Wired to call `control.handleUnfocus()` on blur, which the
  /// `onUnfocus`/`afterFirstUnfocus` validation modes need to know about.
  /// Pass it to your `TextField`'s `focusNode`. A custom field that
  /// manages its own focus (a picker, say) doesn't need this at all —
  /// it can call `control.handleUnfocus()` itself instead.
  late final FocusNode focusNode = FocusNode()..addListener(_handleFocusChange);

  FormControl<String>? _syncedControl;

  @override
  void initState() {
    super.initState();
    _resync();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resync();
  }

  void _resync() {
    if (_syncedControl == control) return;

    _syncedControl?.removeListener(_onControlChanged);
    _syncedControl = control;
    control.addListener(_onControlChanged);
    if (textController.text != control.value) {
      textController.text = control.value;
    }
  }

  void _onControlChanged() {
    final control = _syncedControl;
    if (control == null) return;

    // Only an external change (not the user's own typing, which already
    // set this) needs to be copied into the controller — otherwise every
    // keystroke would reset the cursor to the end of the field.
    if (textController.text != control.value) {
      textController.text = control.value;
    }
    if (mounted) setState(() {});
  }

  void _handleFocusChange() {
    if (!focusNode.hasFocus) {
      control.handleUnfocus();
    }
  }

  @override
  void dispose() {
    _syncedControl?.removeListener(_onControlChanged);
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
