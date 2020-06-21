import 'package:flutter/material.dart';

import '../flutter_easy_form.dart';

extension EasyFormExtension on BuildContext {
  EasyFormState get easyForm => this.findAncestorStateOfType<EasyFormState>();
}
