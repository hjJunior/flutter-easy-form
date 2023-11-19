import 'package:flutter_easy_form/flutter_easy_form.dart';
import 'package:flutter/material.dart';

class DynamicFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyForm(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Dynamic fields (array)"),
        ),
        body: DynamicControlFormContent(),
      ),
    );
  }
}

class DynamicControlFormContent extends StatefulWidget {
  @override
  State<DynamicControlFormContent> createState() =>
      _DynamicControlFormContentState();
}

class _DynamicControlFormContentState extends State<DynamicControlFormContent> {
  List<String> _fields = [];

  void addNewField() {
    final fieldName = "field_${_fields.length + 1}";

    setState(() {
      _fields.add(fieldName);
    });
  }

  void removeField(String field) {
    setState(() {
      _fields.remove(field);
    });
  }

  @override
  Widget build(BuildContext context) {
    final easyForm = context.easyForm;

    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: _fields.length + 1,
      itemBuilder: (context, index) {
        if (index == _fields.length) {
          return Column(
            children: [
              TextButton(onPressed: addNewField, child: Text("New")),
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

        return Row(
          children: [
            Expanded(
              child: EasyFormField(
                attribute: _fields[index],
                builder: (field, formState) {
                  return TextField(
                    decoration: InputDecoration(hintText: _fields[index]),
                    controller: field.textEditingController,
                  );
                },
              ),
            ),
            IconButton(
              onPressed: () => removeField(_fields[index]),
              icon: Icon(Icons.remove_circle),
            )
          ],
        );
      },
    );
  }
}
