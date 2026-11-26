import 'package:material_ui/material_ui.dart';
import 'package:flutter_easy_form/flutter_easy_form.dart';

import 'arena_form.dart';

void main() {
  runApp(const MyApp());
}

/// Focuses, scrolls into view and highlights whichever field [node] is —
/// `requestFocus`/`ensureVisible` only exist on [FormControl] (a group or
/// array isn't a single focusable, scrollable thing), so a group-level
/// error (e.g. `ArenaForm.validateSelf()`) just highlights itself instead.
void _bringToAttention(FormNode<Object?> node) {
  if (node is FormControl) {
    node.requestAttention();
  } else {
    node.highlight();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_easy_form — typed core',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const ArenaFormScreen(),
    );
  }
}

/// Demonstrates the typed core (FormNode/FormControl/FormGroup/FormArray)
/// together with the two Flutter-facing helpers: [FormControlWidget] for a
/// field with no extra resources to manage ([_InternationalSwitch]), and
/// [FormControlTextSync] for one that owns a [TextEditingController]
/// ([_BoundTextField]). The form's `validationMode` is set to `onUnfocus`,
/// so a field's error only shows up after you leave it, not on every
/// keystroke — try it.
class ArenaFormScreen extends StatefulWidget {
  const ArenaFormScreen({super.key});

  @override
  State<ArenaFormScreen> createState() => _ArenaFormScreenState();
}

class _ArenaFormScreenState extends State<ArenaFormScreen> {
  final form = ArenaForm()..setValidationMode(ValidationMode.onUnfocus);

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova arena')),
      body: ListenableBuilder(
        listenable: form,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BoundTextField(control: form.name, label: 'Nome da arena'),
              const SizedBox(height: 8),
              _InternationalSwitch(control: form.international),
              const Divider(height: 32),
              Text('Contatos (${form.contacts.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              for (var i = 0; i < form.contacts.length; i++)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _BoundTextField(
                          control: form.contacts[i].name,
                          label: 'Nome do contato',
                        ),
                        const SizedBox(height: 8),
                        _BoundTextField(
                          control: form.contacts[i].email,
                          label: 'E-mail do contato',
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => form.contacts.removeAt(i)),
                            child: const Text('Remover contato'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              OutlinedButton(
                onPressed: () => setState(form.contacts.add),
                child: const Text('Adicionar contato'),
              ),
              const Divider(height: 32),
              // Tap an error to jump to the field that reported it —
              // validationErrors keeps each one tied to its exact node,
              // unlike the flat list `form.errors` already gives you.
              for (final entry in form.validationErrors.entries)
                for (final error in entry.value)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.error_outline, color: Colors.red),
                    title: Text(error.message),
                    onTap: () => _bringToAttention(entry.key),
                  ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await form.validate(); // awaits any async validator in the tree
                  if (!context.mounted) return;
                  if (form.canSubmit) {
                    final Arena arena = form.toValue();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Arena "${arena.name}" criada com sucesso')),
                    );
                  } else {
                    // Jumps to the first invalid field — handy when it's
                    // buried in a long list of contacts, or (in a real
                    // multi-step form) on a step that isn't visible yet.
                    final invalid = form.validationErrors.keys;
                    if (invalid.isNotEmpty) _bringToAttention(invalid.first);
                  }
                },
                child: const Text('Salvar'),
              ),
              TextButton(
                onPressed: () => setState(form.reset),
                child: const Text('Limpar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A field with no extra resources to manage can extend [FormControlWidget]
/// directly: the base class handles listening to the control and
/// rebuilding, so this only has to describe what the field looks like for
/// its current value.
class _InternationalSwitch extends FormControlWidget<bool> {
  const _InternationalSwitch({required super.control});

  @override
  Widget build(BuildContext context, FormControl<bool> control) {
    return SwitchListTile(
      title: const Text('Arena internacional'),
      value: control.value,
      onChanged: control.disabled ? null : (value) => control.value = value,
    );
  }
}

/// A text field still needs its own [State] to own a [TextEditingController]
/// across rebuilds. [FormControlTextSync] removes the boilerplate of
/// keeping that controller synced with the control — this widget is free
/// to build whatever [TextField] it wants around `textController`.
class _BoundTextField extends StatefulWidget {
  const _BoundTextField({required this.control, required this.label});

  final FormControl<String> control;
  final String label;

  @override
  State<_BoundTextField> createState() => _BoundTextFieldState();
}

class _BoundTextFieldState extends State<_BoundTextField>
    with FormControlTextSync<_BoundTextField> {
  @override
  FormControl<String> get control => widget.control;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: control.displayError,
        filled: control.isHighlighted,
        fillColor: Colors.amber.withValues(alpha: 0.3),
      ),
      onChanged: (value) => control.value = value,
    );
  }
}
