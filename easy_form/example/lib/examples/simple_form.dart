import 'package:flutter_easy_form/flutter_easy_form.dart';
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
        EasyFormField(
          attribute: 'name',
          builder: (field, formState) {
            return TextField(
              decoration: InputDecoration(hintText: "Your name"),
              controller: field.textEditingController,
            );
          },
        ),
        TextButton(
          child: Text('View values'),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text("Form Values"),
                      content: Text(easyForm.values.toString()),
                    ));
          },
        ),
      ],
    );
  }
}
