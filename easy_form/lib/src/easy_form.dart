import 'package:flutter/material.dart';

import 'easy_form_field.dart';

class EasyForm extends StatefulWidget {
  final Widget child;

  const EasyForm({Key key, this.child}) : super(key: key);

  @override
  EasyFormState createState() => EasyFormState();

  static EasyFormState of(BuildContext context) {
    return context.findAncestorStateOfType<EasyFormState>();
  }
}

class EasyFormState extends State<EasyForm> {
  Map<String, EasyFormField> _fields = {};

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void registerField(EasyFormField field) {
    _fields[field.attributeName] = field;
  }

  void unregisterField(EasyFormField field) {
    _fields.remove(field.attributeName);
  }

  void setFieldValue<T>(String attributeName, T value) {
    _fields[attributeName].value = value;
  }

  T getFieldValue<T>(String attributeName) {
    return _fields[attributeName].value;
  }

  Map<String, dynamic> get values {
    return _fields.map((key, field) {
      return MapEntry(key, field.value);
    });
  }
}
