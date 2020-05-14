import 'package:flutter/material.dart';

import '../easy_form.dart';

extension EasyFormExtension on BuildContext {
  EasyFormState get easyForm => this.findAncestorStateOfType<EasyFormState>();
}
