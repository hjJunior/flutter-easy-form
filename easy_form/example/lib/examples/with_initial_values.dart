import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter/material.dart';

class WithInitialValues extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyForm(
      initialValues: {
        "name": "Initial Name"
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("With initial values and reset button"),
        ),
        body: WithInitialValuesFormContent(),
      ),
    );
  }
}

class WithInitialValuesFormContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: <Widget>[
        EasyTextField(
          attribute: 'name',
          textField: TextField(
            decoration: InputDecoration(hintText: "Your name"),
          ),
        ),
        RaisedButton(
          onPressed: context.easyForm.resetForm,
          child: Text("Reset form"),
        ),
      ],
    );
  }
}
