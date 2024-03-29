import 'package:flutter/material.dart';

import '../flutter_easy_form.dart';

extension EasyFormExtension on BuildContext {
  EasyFormState get easyForm {
    final state = this.findAncestorStateOfType<EasyFormState>();
    if (state != null) return state;
    throw 'No EasyFormState found in root elements';
  }
}
