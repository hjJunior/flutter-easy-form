import 'package:easy_form/easy_form.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyForm(
      child: Scaffold(
        appBar: AppBar(
          title: Text("EasyForm"),
        ),
        body: YourForm(),
      ),
    );
  }
}

class YourForm extends StatelessWidget {
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
        FlatButton(
          child: Text('View values'),
          onPressed: () {
            showDialog(context: context, builder: (_) => AlertDialog(
              title: Text("Form Values"),
              content: Text(easyForm.values.toString()),
            ));
          },
        )
      ],
    );
  }
}
