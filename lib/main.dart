import 'dart:convert';

import 'package:book_beats_flutter/prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_helper.dart';

//We are going to use the google client for this example...
import 'package:oauth2_client/spotify_oauth2_client.dart';


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

  Future<void> doEverything(String playlistName, String vibe) async {
    // Auth Configuration
    SpotifyOAuth2Client client = SpotifyOAuth2Client(
      customUriScheme: 'my.test.app',
      redirectUri: 'my.test.app:/callback',
    );

    final clientId = dotenv.env['CLIENT_ID'];
    final clientSecret = dotenv.env['CLIENT_SECRET'];


    print('Step 1 and 2, get the authorization code and auth token');

    OAuth2Helper oauth2Helper = OAuth2Helper(client,
      grantType: OAuth2Helper.authorizationCode,
      clientId: clientId ?? "OR NOPE",
      clientSecret: clientSecret,
      webAuthOpts: {'preferEphemeral': true},
      scopes: [
        'playlist-modify-public,playlist-modify-private,user-read-private,user-read-email'
      ],
    );

    AccessTokenResponse? accessTokenResponse = await oauth2Helper.getToken();
    final String accessToken = accessTokenResponse!.accessToken!;
    print("show me the access token: ${accessToken}");


    try {
      // Perform OAuth2 authentication
      await makeApiRequests(accessToken, playlistName, vibe);
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Map<String, String> getStandardHeaders(String accessToken) {
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<void> makeApiRequests(String accessToken, String playlistName,
      String vibe) async {
    print('Step 3: Get the user ID');

    http.Response euserIdResponse = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: getStandardHeaders(accessToken)
    );

    var userId = jsonDecode(euserIdResponse.body)['id'];
    print('here is the userId: $userId');


    print('Step 4: Create a Playlist for $userId');
    var playlistDetails = jsonEncode({
    "name": playlistName,
    "description": "Awesome trio strikes again",
    "public": true
    });
    print(playlistDetails);

    http.Response createPlaylistResponse = await http.post(
    Uri.parse('https://api.spotify.com/v1/users/$userId/playlists'),
    headers: getStandardHeaders(accessToken),
    body: playlistDetails,
    );

    // var createPlaylistResponse = await http.post(uriTypeUrl, headers: playlistHeaders, body: playlistDetails);

    // idk what's gonig on but this is blocking and I need to click a second time because of it
    // http.Response createPlaylistResponse =
    //     await oauth2Helper.post(url, body: playlistDetails);

/*    http.Response createPlaylistResponse;
    try {
      createPlaylistResponse = await oauth2Helper.post(url, body: playlistDetails);
    } catch (e) {
      print(e);
    }
    print("Did it work?");*/

    var playlistId = jsonDecode(createPlaylistResponse.body)['id'];
    // var playlistId = "asdfasdf";
    print('Step 5: Get song suggestions from openAi');

/*
    sleep(const Duration(seconds: 5));
    print('Step 5: Get song suggestions from 44445555555');*/
    var openaiSongs = await getSongSuggestions(vibe);
    print('Step 6: Search for tracks based on song namews and artists');

    // print('decoded suggestions: $decodedSongSuggestions');
    List<String> trackIds = await searchForTrackIds(openaiSongs, accessToken);

    print('Step 7: Add tracks to playlist!');
    print("the track ids look like $trackIds");
    var trackUris = trackIds.map((id) => 'spotify:track:$id').toList();
    String encodedTrackUris = jsonEncode(trackUris);

    print("track uirs look like $trackUris");
    var trackUriJsonData = '''
    {
      "uris": $encodedTrackUris
    }
    ''';

    var addToPlaylistUrl =
    'https://api.spotify.com/v1/playlists/$playlistId/tracks';
    // await oauth2Helper.post(addToPlaylistUrl,
    //     body: trackUriJsonData);
    await http.post(
    Uri.parse(addToPlaylistUrl),
    headers: getStandardHeaders(accessToken),
    body: trackUriJsonData,
    );

    print(
    "ALL DONE! Check your spotify afccount for the awesome playlist you just made");
  }

  Future<List<String>> searchForTrackIds(Map<String, String> openaiSongs,
      String accessToken) async {
    List<String> trackIds = [];

    // Iterate through each entry in the map
    for (var entry in openaiSongs.entries) {
      String key = entry.key;
      String value = entry.value;
      var searchTracksUrl = 'https://api.spotify.com/v1/search?q=track:$key artist:$value&type=track,artist&limit=1';

      // Perform the HTTP request and await the response
      // var trackSearchResponse = await oauth2Helper.get(searchTracksUrl);
      var trackSearchResponse = await http.get(
        Uri.parse(searchTracksUrl),
        headers: getStandardHeaders(accessToken),
      );
      var decodedTracks = jsonDecode(
          trackSearchResponse.body)['tracks']['items'];

      // Check if the response contains any tracks
      if (decodedTracks.isNotEmpty) {
        // If tracks are found, add the first track's ID to the list
        String? trackId = decodedTracks[0]['id'] as String?;
        if (trackId != null) {
          print('adding TrackId to list: $trackId');
          trackIds.add(trackId);
        }
      }
    }
    return trackIds;
  }

  Future<Map<String, String>> getSongSuggestions(String vibe) async {
    final openAiKey = dotenv.env['OPENAI_API_KEY'];

    var url = Uri.parse('https://api.openai.com/v1/chat/completions');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openAiKey',
    };

    String body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'system', 'content': Prompts.systemMessage},
        {'role': 'user', 'content': Prompts.generatePrompt(vibe)}
      ]
    });

    var response = await http.post(url, headers: headers, body: body);

    // print("open ai go");
    // print(jsonDecode(response.body));

    var songs = jsonDecode(response.body)['choices'][0]['message']['content'];

    print('time to convert');
    // print(songs);
    Map<String, String> parsedSongs = {};
    jsonDecode(songs)['items'].forEach((songItem) {
      var name = songItem['song'];
      var artist = songItem['artist'];

      parsedSongs[name] = artist;
    });

    print('does this look like anything $parsedSongs');

    return parsedSongs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Choose your playlist name:',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall,
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
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall,
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: vibeController,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await doEverything(playlistNameController.text, vibeController.text);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
