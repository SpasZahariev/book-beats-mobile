import 'dart:convert';

import 'package:book_beats_flutter/ProggressState.dart';
import 'package:book_beats_flutter/prompts.dart';
import 'package:book_beats_flutter/success_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_helper.dart';

//We are going to use the google client for this example...
import 'package:oauth2_client/spotify_oauth2_client.dart';

import 'do_everything_command.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Book-beats'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController playlistNameController =
      TextEditingController(text: 'SpasFlutterPlaylist');
  final TextEditingController vibeController =
      TextEditingController(text: 'Relaxing classical music');
  ProgressState currentState = ProgressState.initialState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (currentState == ProgressState.initialState) ...[
              Text(
                'Choose your playlist name:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: playlistNameController,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
              ),
              Text(
                'Describe the vibe you are going for:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: vibeController,
                ),
              ),
            ] else if (currentState == ProgressState.loadingState)
              Center(child: CircularProgressIndicator())
            else if (currentState == ProgressState.completedState) ...[
                const SuccessBanner(),
              ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final command = DoEverythingCommand();
          setState(() {
            currentState = ProgressState.loadingState;
          });
          await command.doEverything(playlistNameController.text, vibeController.text);
          setState(() {
            currentState = ProgressState.completedState;
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
