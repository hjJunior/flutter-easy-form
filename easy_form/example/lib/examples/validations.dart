import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter/material.dart';

class UsingValidations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyForm(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Validations"),
        ),
        body: UsingValidationsFormContent(),
      ),
    );
  }
}

class CustomFormValidation extends EasyFormValidation<String?> {
  @override
  Future<String?> run(String? value, EasyFormState formState) async {
    if (value == null || value.isEmpty) {
      return "The Value is empty";
    }
    return null;
  }
}

class UsingValidationsFormContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final easyForm = context.easyForm;

    return ListView(
      padding: EdgeInsets.all(10),
      children: <Widget>[
        EasyFormField(
          attribute: 'name',
          validations: [
            CustomFormValidation(),
          ],
          builder: (field, formState) {
            return TextField(
              decoration: InputDecoration(
                hintText: "Your name",
                errorText: field.error,
              ),
              controller: field.textEditingController,
            );
          },
        ),
        Wrap(
          children: [
            ElevatedButton(
              onPressed: () {
                easyForm.field("name").error = "Custom error";
              },
              child: Text("Force error"),
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: () {
                easyForm.field("name").error = null;
              },
              child: Text("Reset error"),
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                if (await easyForm.validate()) {
                  print("Valid!");
                }
              },
              child: Text("Run validation"),
            ),
            ElevatedButton(
              onPressed: easyForm.resetForm,
              child: Text("Reset form"),
            ),
          ],
        ),
      ],
    );
  }
}
