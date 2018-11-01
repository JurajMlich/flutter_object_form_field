import 'package:flutter/material.dart';

class EmotionsPage extends StatefulWidget {
  @override
  _EmotionsPageState createState() {
    return _EmotionsPageState();
  }
}

class Emotion {
  final String name;

  Emotion(this.name);
}

class _EmotionsPageState extends State<EmotionsPage> {
  List<Emotion> emotions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick emotion'),
        actions: <Widget>[],
      ),
      body: _buildBody(context),
    );
  }

  @override
  void initState() {
    super.initState();

    emotions = [
      Emotion('Sadness'),
      Emotion('Hapiness'),
    ];
  }

  Widget _buildBody(BuildContext context) {
    return ListView.builder(
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        return InkWell(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(emotions[index].name),
            ),
            onTap: () {
              Navigator.pop(context, emotions[index]);
            });
      },
    );
  }
}
