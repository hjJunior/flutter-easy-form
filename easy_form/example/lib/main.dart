import 'package:example/examples/live_update.dart';
import 'package:example/examples/simple_form.dart';
import 'package:example/examples/dynamic_control.dart';
import 'package:flutter/material.dart';

import 'examples/validations.dart';
import 'examples/with_initial_values.dart';

void main() {
  runApp(MyApp());
}

final _routes = {
  "/": (BuildContext _) => Examples(),
  "Simple Form": (BuildContext _) => SimpleForm(),
  "Live Update": (BuildContext _) => LiveUpdate(),
  "Dynamic field value control": (BuildContext _) => DynamicControl(),
  "Initial values and reset button": (BuildContext _) => WithInitialValues(),
  "Using Validations": (BuildContext _) => UsingValidations(),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: _routes,
    );
  }
}

class Examples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EasyForm - Examples"),
      ),
      body: ListView.builder(
        itemCount: _routes.values.length - 1,
        itemBuilder: (context, index) {
          final page = _routes.keys.elementAt(index + 1);

          return ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(page);
            },
            title: Text(page),
            trailing: Icon(Icons.arrow_forward_ios),
          );
        },
      ),
    );
  }
}
