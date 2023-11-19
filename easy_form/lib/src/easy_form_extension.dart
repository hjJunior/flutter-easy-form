import 'package:flutter/material.dart';
import 'package:flutter_easy_form/flutter_easy_form.dart';

extension EasyFormContextExtension on BuildContext {
  EasyFormState get easyForm {
    final state = this.findAncestorStateOfType<EasyFormState>();

    if (state != null) return state;
    throw 'No EasyForm root elements found';
  }
}
