import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter_easy_form/src/easy_form_field_state.dart';

class EasyForm extends StatefulWidget {
  final Widget child;
  final Map<String, dynamic> initialValues;

  const EasyForm({
    Key? key,
    required this.child,
    this.initialValues = const {},
  }) : super(key: key);

  @override
  EasyFormState createState() => EasyFormState();
}

class EasyFormState extends State<EasyForm> {
  final _changesCtrl = StreamController<Map<String, dynamic>>();
  final Map<String, EasyFormFieldState> _fields = {};

  EasyFormFieldState<T> field<T>(String attr) {
    final foundField = _fields[attr];

    if (foundField != null) return foundField as EasyFormFieldState<T>;
    throw ("The $attr field is not registered");
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _changesCtrl.close();
    super.dispose();
  }

  Stream<Map<String, dynamic>> get onChange => _changesCtrl.stream;

  void registerField(EasyFormFieldState field) {
    _fields[field.attribute] = field;
  }

  void removeField(String attribute) {
    _fields.remove(attribute);
  }

  void unregisterField(String attribute) {
    _fields.remove(attribute);
  }

  void setFieldValue<T>(String attributeName, T value) {
    _fields[attributeName]?.value = value;
    notifyChange();
  }

  void notifyChange() {
    _changesCtrl.sink.add(values);
  }

  void resetForm() {
    _fields.forEach((_, state) => state.reset());
  }

  T initialValueFor<T>(String attributeName) {
    return widget.initialValues[attributeName];
  }

  T getFieldValue<T>(String attributeName) {
    return field(attributeName).value ?? initialValueFor(attributeName);
  }

  Map<String, dynamic> get values {
    return _fields.map((key, field) {
      return MapEntry(key, field.value ?? widget.initialValues[key]);
    });
  }

  Future<bool> validate({bool stopOnFirstError = false}) async {
    bool allValid = true;

    for (final fieldName in _fields.keys) {
      final valid = await field(fieldName).runValidations();

      if (!valid) {
        allValid = valid;
      }

      if (!valid && stopOnFirstError) {
        return false;
      }
    }
    return allValid;
  }
}
