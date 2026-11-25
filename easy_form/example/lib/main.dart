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

/// Demonstrates the new typed core (FormNode/FormControl/FormGroup/FormArray)
/// directly, without dedicated field widgets yet — those are planned for a
/// later phase. Each text field below manually syncs a [TextEditingController]
/// with a [FormControl], the same way a future `TextFormControl` widget would.
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
              SwitchListTile(
                title: const Text('Arena internacional'),
                value: form.international.value,
                onChanged: (value) =>
                    setState(() => form.international.value = value),
              ),
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

class _BoundTextField extends StatefulWidget {
  const _BoundTextField({required this.control, required this.label});

  final FormControl<String> control;
  final String label;

  @override
  State<_BoundTextField> createState() => _BoundTextFieldState();
}

class _BoundTextFieldState extends State<_BoundTextField> {
  late final controller = TextEditingController(text: widget.control.value);

  @override
  void initState() {
    super.initState();
    widget.control.addListener(_syncFromControl);
  }

  void _syncFromControl() {
    if (controller.text != widget.control.value) {
      controller.text = widget.control.value;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.control.removeListener(_syncFromControl);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.control.touched && widget.control.invalid
        ? widget.control.errors.first.message
        : null;

    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: widget.label, errorText: error),
      onChanged: (value) => widget.control.value = value,
      onTapOutside: (_) => widget.control.markAsTouched(),
    );
  }
}
