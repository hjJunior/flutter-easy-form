import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter/material.dart';

class DynamicControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyForm(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Dynamic field value control"),
        ),
        body: DynamicControlFormContent(),
      ),
    );
  }
}

class DynamicControlFormContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final easyForm = context.easyForm;

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                easyForm.setFieldValue("email", easyForm.getFieldValue("name"));
              },
              child: Icon(Icons.arrow_downward),
            ),
            Text('Copy text from to'),
            TextButton(
              onPressed: () {
                easyForm.setFieldValue("name", easyForm.getFieldValue("email"));
              },
              child: Icon(Icons.arrow_upward),
            ),
          ],
        ),
        EasyFormField(
          attribute: 'email',
          builder: (field, formState) {
            return TextField(
              decoration: InputDecoration(hintText: "Your email"),
              controller: field.textEditingController,
            );
          },
        ),
      ],
    );
  }
}
