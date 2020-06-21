import 'package:example/examples/live_update.dart';
import 'package:example/examples/simple_form.dart';
import 'package:example/examples/dynamic_control.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

final _routes = {
  "/": (BuildContext context) => Examples(),
  "Simple Form": (BuildContext context) => SimpleForm(),
  "Live Update": (BuildContext context) => LiveUpdate(),
  "Dynamic field value control": (BuildContext context) => DynamicControl(),
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
