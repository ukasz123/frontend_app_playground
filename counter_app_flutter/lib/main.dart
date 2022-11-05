import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Counter app',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const CounterPage(title: 'Flutter Counter app'),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key, required this.title});

  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _decrementCounter() => setState(() {
        _counter--;
      });

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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
                'https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png'),
            Text(
              'Welcome to Flutter',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            const Text.rich(
              TextSpan(text: 'To get started, edit ', children: [
                TextSpan(
                  text: 'lib/main.dart',
                  style: TextStyle(
                    backgroundColor: Colors.black38,
                    color: Colors.white70,
                    height: 1.1,
                  ),
                ),
                TextSpan(text: ' and save to reload'),
              ]),
            ),
            const Divider(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _decrementCounter,
                  child: const Text('Decrease'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent.shade200,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('Increase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade200,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
