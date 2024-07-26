import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InsuranceForm(),
    );
  }
}

class InsuranceForm extends StatefulWidget {
  @override
  _InsuranceFormState createState() => _InsuranceFormState();
}

class _InsuranceFormState extends State<InsuranceForm> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _sexController = TextEditingController();
  final _bmiController = TextEditingController();
  final _childrenController = TextEditingController();
  final _smokerController = TextEditingController();

  Future<void> _submitData() async {
    final url = 'http://127.0.0.1:8000/predict';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'age': int.parse(_ageController.text),
        'sex': _sexController.text == 'male' ? 1 : 0,
        'bmi': double.parse(_bmiController.text),
        'children': int.parse(_childrenController.text),
        'smoker': _smokerController.text == 'yes' ? 1 : 0,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final prediction = responseData['prediction'];

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Prediction'),
          content: Text('The predicted charges are \$${prediction}'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _sexController.dispose();
    _bmiController.dispose();
    _childrenController.dispose();
    _smokerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insurance Charges Prediction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sexController,
                decoration: InputDecoration(labelText: 'Sex (male/female)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sex';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bmiController,
                decoration: InputDecoration(labelText: 'BMI'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter BMI';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _childrenController,
                decoration: InputDecoration(labelText: 'Children'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of children';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _smokerController,
                decoration: InputDecoration(labelText: 'Smoker (yes/no)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter smoker status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitData();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
