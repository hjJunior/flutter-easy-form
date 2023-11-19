import 'package:flutter/widgets.dart';
import 'package:flutter_easy_form/flutter_easy_form.dart';

class EasyFormFieldState<T> with ChangeNotifier {
  final T initialValue;
  final String attribute;
  final EasyFormState formState;
  final List<EasyFormValidation> validations;
  late TextEditingController? textEditingController;

  late T _value;
  String? _error;

  FocusNode focusNode = FocusNode();

  EasyFormFieldState({
    required this.attribute,
    required this.initialValue,
    required this.formState,
    this.textEditingController,
    this.validations = const <EasyFormValidation>[],
  }) {
    _value = initialValue;
    _registerController();
  }

  T get value => _value;
  String? get error => _error;
  bool get hasError => error != null;

  bool get _isStringField => initialValue is String || initialValue is String?;

  set value(T newValue) {
    _value = newValue;

    if (_isStringField && textEditingController!.text != newValue) {
      textEditingController!.text = (newValue ?? '') as String;
    }

    notifyListeners();
  }

  set error(String? newError) {
    _error = newError;
    notifyListeners();
  }

  void reset() {
    value = initialValue;
    error = null;
  }

  void requestFocus() {
    focusNode.requestFocus();
  }

  Future<bool> runValidations() async {
    for (final validation in validations) {
      final result = await validation.run(value, formState);

      if (result != null && result.isNotEmpty) {
        error = result;
        break;
      }
    }

    return hasError;
  }

  void _registerController() {
    String? text = _isStringField ? initialValue as String? : '';

    textEditingController ??= TextEditingController(text: text);

    textEditingController!.addListener(() {
      value = textEditingController!.text as T;
    });
  }

  void notifyListeners() {
    super.notifyListeners();
    formState.notifyChange();
  }
}
