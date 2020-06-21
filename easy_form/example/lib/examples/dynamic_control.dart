import 'package:easy_form/easy_form.dart';
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
        EasyTextField(
          attribute: 'name',
          textField: TextField(
            decoration: InputDecoration(hintText: "Your name"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                easyForm.setFieldValue("email", easyForm.getFieldValue("name"));
              },
              child: Icon(Icons.arrow_downward),
            ),
            Text('Copy text from to'),
            FlatButton(
              onPressed: () {
                easyForm.setFieldValue("name", easyForm.getFieldValue("email"));
              },
              child: Icon(Icons.arrow_upward),
            ),
          ],
        ),
        EasyTextField(
          attribute: 'email',
          textField: TextField(
            decoration: InputDecoration(hintText: "Your email"),
          ),
        ),
      ],
    );
  }
}
