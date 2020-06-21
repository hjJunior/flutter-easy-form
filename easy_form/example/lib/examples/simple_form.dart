import 'package:easy_form/easy_form.dart';
import 'package:flutter/material.dart';

class SimpleForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyForm(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Simple Form"),
        ),
        body: SimpleFormFormContent(),
      ),
    );
  }
}

class SimpleFormFormContent extends StatelessWidget {
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
        FlatButton(
          child: Text('View values'),
          onPressed: () {
            showDialog(context: context, builder: (_) => AlertDialog(
              title: Text("Form Values"),
              content: Text(easyForm.values.toString()),
            ));
          },
        ),
      ],
    );
  }
}
