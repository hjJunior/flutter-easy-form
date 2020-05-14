import 'package:flutter/widgets.dart';

import 'easy_form.dart';

abstract class EasyFormField<T> {
  BuildContext get context;
  String get attributeName;
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
}
