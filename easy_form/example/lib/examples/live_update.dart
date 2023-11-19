import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter/material.dart';

class LiveUpdate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyForm(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Live Update"),
        ),
        body: LiveUpdateFormContent(),
      ),
    );
  }
}

class LiveUpdateFormContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: <Widget>[
        EasyFormField(
          attribute: 'first_name',
          builder: (field, formState) {
            return TextField(
              decoration: InputDecoration(hintText: "First name"),
              controller: field.textEditingController,
            );
          },
        ),
        EasyFormField(
          attribute: 'last_name',
          builder: (field, formState) {
            return TextField(
              decoration: InputDecoration(hintText: "Last name"),
              controller: field.textEditingController,
            );
          },
        ),
        Divider(),
        StreamBuilder<Map<String, dynamic>>(
          stream: context.easyForm.onChange,
          builder: (context, snapshot) {
            return Text(snapshot.data?.toString() ?? "No interactions yet");
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
