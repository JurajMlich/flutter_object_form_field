import 'package:example/emotions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_object_form_field/flutter_object_form_field.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                //
                // USAGE WITH CUSTOM OBJECT
                //
                ObjectFormField<Emotion>(
                  objectToString: (emotion) => emotion?.name,
                  pickValue: (oldEmotion) async {
                    // returns an emotion object
                    return await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmotionsPage()));
                  },
                  decoration: InputDecoration(labelText: 'Emotion'),
                  validator: (value) {
                    if (value == null) {
                      return 'You have to pick an emotion';
                    }

                    if (value.name == 'Sadness') {
                      return 'Show me your smile!';
                    }
                  },
                ),
                //
                // USAGE WITH DATE TIME
                //
                ObjectFormField<DateTime>(
                  // can use some kind of formatter
                  objectToString: (dateTime) => dateTime?.toString(),
                  pickValue: (oldDate) async {
                    return await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                  },
                  decoration: InputDecoration(labelText: 'Date'),
                  validator: (value) {
                    if (value == null) {
                      return 'You have to select date';
                    }

                  },
                ),
              ],
            )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _validateForm,
        tooltip: 'Validate',
        child: Icon(Icons.done),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _validateForm() {
    _formKey.currentState.validate();
  }
}
