import 'package:flutter/cupertino.dart';

abstract class EasyFormValidation<T> {
  Future<String> run(T value, BuildContext context);
}
