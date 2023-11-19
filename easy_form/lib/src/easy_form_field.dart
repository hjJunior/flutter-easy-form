import 'package:flutter/material.dart';
import 'package:flutter_easy_form/flutter_easy_form.dart';

typedef EasyFormFieldBuilder<T> = Widget Function(
  EasyFormFieldState<T> fieldState,
  EasyFormState formState,
);

class EasyFormField<T> extends StatefulWidget {
  final String attribute;
  final List<EasyFormValidation> validations;
  final EasyFormFieldBuilder<T> builder;
  final TextEditingController? textEditingController;

  const EasyFormField({
    super.key,
    required this.attribute,
    required this.builder,
    this.validations = const <EasyFormValidation>[],
    this.textEditingController,
  });

  @override
  State<EasyFormField> createState() => _EasyFormFieldState<T>();
}

class _EasyFormFieldState<T> extends State<EasyFormField> {
  late EasyFormState easyForm = context.easyForm;
  EasyFormFieldState<T> get fieldState => easyForm.field<T>(widget.attribute);

  void _registerThisField() {
    easyForm.registerField(EasyFormFieldState(
      attribute: widget.attribute,
      initialValue: easyForm.initialValueFor(widget.attribute),
      validations: widget.validations,
      textEditingController: widget.textEditingController,
      formState: easyForm,
    ));
  }

  @override
  void initState() {
    _registerThisField();
    super.initState();
  }

  @override
  void dispose() {
    easyForm.removeField(widget.attribute);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      easyForm = context.easyForm;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: fieldState,
      builder: (context, _widget) {
        return widget.builder(fieldState, easyForm);
      },
    );
  }
}
