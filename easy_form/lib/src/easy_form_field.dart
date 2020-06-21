import 'package:flutter/widgets.dart';

import 'easy_form.dart';
import 'easy_form_validation.dart';

abstract class EasyFormField<T> {
  BuildContext get context;
  String get attributeName;
  List<EasyFormValidation> get validations => [];

  set value(T value);
  T get value;

  EasyFormState get easyForm =>
      context.findAncestorStateOfType<EasyFormState>();

  void registerThisField() {
    easyForm.registerField(this);
  }

  void unregisterThisField() {
    easyForm.unregisterField(this);
  }

  void notifyChange() {
    easyForm.notifyChange();
  }

  T get initialValue => easyForm.initialValueFor(this.attributeName);

  Future<bool> runValidations() async {
    return validations.fold(true, (previousValidation, validation) async {
      final validationResult = await validation.run(value, context);
      onValidation(validationResult);

      return previousValidation && (validationResult == null);
    });
  }

  void onValidation([String error]) {
    throw UnimplementedError(
      "Please override this method to allow the usage of validations on custom fields",
    );
  }
}
