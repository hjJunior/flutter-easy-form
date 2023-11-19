import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter/material.dart';

class WithInitialValues extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyForm(
      initialValues: {"name": "Initial Name"},
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
        EasyFormField(
          attribute: 'name',
          builder: (field, formState) {
            return TextField(
              decoration: InputDecoration(hintText: "Your name"),
              controller: field.textEditingController,
            );
          },
        ),
        ElevatedButton(
          onPressed: context.easyForm.resetForm,
          child: Text("Reset form"),
        ),
      ],
    );
  }
}
