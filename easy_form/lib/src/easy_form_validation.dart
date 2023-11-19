import 'package:flutter_easy_form/flutter_easy_form.dart';

abstract class EasyFormValidation<T> {
  Future<String?> run(T value, EasyFormState formState);
}
