import 'package:flutter/material.dart';

import '../factories/text_field.dart';
import '../easy_form_field.dart';

class EasyTextField extends StatefulWidget {
  final String attribute;
  final TextField textField;

  const EasyTextField({
    Key key,
    @required this.attribute,
    @required this.textField,
  })  : assert(attribute != null),
        assert(textField != null),
        super(key: key);

  @override
  _EasyTextFieldState createState() => _EasyTextFieldState();
}

class _EasyTextFieldState extends State<EasyTextField>
    with EasyFormField<String> {
  TextField _renderElement;
  final _controller = TextEditingController();

  @override
  void initState() {
    registerThisField();
    _configureRenderElement();
    _configureListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _renderElement;
  }

  TextEditingController get textController {
    return widget.textField.controller ?? _controller;
  }

  void _configureRenderElement() {
    _renderElement = TextFieldFactory.copyFromWith(
      widget.textField,
      controller: textController,
    );
  }

  void _configureListeners() {
    textController.addListener(notifyChange);
  }

  void _disposeTextController() {
    textController.removeListener(notifyChange);
    textController.dispose();
  }

  @override
  void dispose() {
    _disposeTextController();
    super.dispose();
  }

  @override
  set value(String value) {
    setState(() {
      textController.text = value;
    });
  }

  @override
  String get value => textController.text;

  @override
  String get attributeName => widget.attribute;
}
