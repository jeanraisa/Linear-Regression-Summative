import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insurance Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _childrenController = TextEditingController();
  String _sex = 'female';
  String _smoker = 'no';

  Future<void> _predictInsuranceCharges() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'age': int.parse(_ageController.text),
        'sex': _sex,
        'bmi': double.parse(_bmiController.text),
        'children': int.parse(_childrenController.text),
        'smoker': _smoker,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final double prediction = responseData['prediction'];
      _showDialog('Prediction',
          'The predicted insurance charges are \$${prediction.toStringAsFixed(2)}');
    } else {
      _showDialog('Error', 'Failed to get prediction.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insurance Prediction'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: _bmiController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'BMI'),
            ),
            TextField(
              controller: _childrenController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Number of Children'),
            ),
            DropdownButton<String>(
              value: _sex,
              onChanged: (String? newValue) {
                setState(() {
                  _sex = newValue!;
                });
              },
              items: <String>['female', 'male']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _smoker,
              onChanged: (String? newValue) {
                setState(() {
                  _smoker = newValue!;
                });
              },
              items: <String>['no', 'yes']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _predictInsuranceCharges,
              child: Text('Predict'),
            ),
          ],
        ),
      ),
    );
  }
}
