import 'package:flutter/material.dart';
import 'package:flutter_easy_form/flutter_easy_form.dart';

import 'arena_form.dart';

void main() {
  runApp(const MyApp());
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
/// ([_BoundTextField]).
class ArenaFormScreen extends StatefulWidget {
  const ArenaFormScreen({super.key});

  @override
  State<ArenaFormScreen> createState() => _ArenaFormScreenState();
}

class _ArenaFormScreenState extends State<ArenaFormScreen> {
  final form = ArenaForm();

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
              if (form.errors.isNotEmpty)
                ...form.errors.map(
                  (error) => Text(error.message, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  form.validate();
                  if (form.valid) {
                    final Arena arena = form.toValue();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Arena "${arena.name}" criada com sucesso')),
                    );
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
    final error = control.touched && control.invalid ? control.errors.first.message : null;

    return TextField(
      controller: textController,
      decoration: InputDecoration(labelText: widget.label, errorText: error),
      onChanged: (value) => control.value = value,
      onTapOutside: (_) => control.markAsTouched(),
    );
  }
}
