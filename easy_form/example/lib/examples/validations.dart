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

class CustomFormValidation extends EasyFormValidation<String> {
  @override
  Future<String> run(String value, BuildContext context) async {
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
        EasyTextField(
          attribute: 'name',
          textField: TextField(
            decoration: InputDecoration(hintText: "Your name"),
          ),
          validations: [
            CustomFormValidation(),
          ],
        ),
        Wrap(
          children: [
            RaisedButton(
              onPressed: () {
                easyForm.field("name").onValidation("Custom error");
              },
              child: Text("Force error"),
            ),
            SizedBox(width: 10,),
            RaisedButton(
              onPressed: () {
                easyForm.field("name").onValidation(null);
              },
              child: Text("Reset error"),
            ),
            SizedBox(width: 10,),
            RaisedButton(
              onPressed: () async {
                if (await easyForm.validate()) {
                  print("Valid!");
                }
              },
              child: Text("Run validation"),
            ),
            RaisedButton(
              onPressed: easyForm.resetForm,
              child: Text("Reset form"),
            ),
          ],
        ),
      ],
    );
  }
}
