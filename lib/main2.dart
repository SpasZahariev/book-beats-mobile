// import 'dart:async';
// import 'dart:convert';
//
// import 'package:app_links/app_links.dart';
// import 'package:book_beats_flutter/prompts.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
//
// import 'dart:io';
//
// import 'package:oauth2/oauth2.dart' as oauth2;
// import 'package:url_launcher/url_launcher.dart';
//
//
// final authorizationEndpoint =
// Uri.parse('https://accounts.spotify.com/authorize');
// final tokenEndpoint = Uri.parse('https://accounts.spotify.com/api/token');
// final redirectUrl = Uri.parse('http://my.test.app:/callback');
// final credentialsFile = File('~/.myapp/credentials.json');
// final spotifyScopes = [
//   'playlist-modify-public',
//   'playlist-modify-private',
//   'user-read-private',
//   'user-read-email'
// ];
//
// var clientId = null;
// var clientSecret = null;
//
//
// Future<void> main() async {
//   await dotenv.load(fileName: ".env");
//
//   clientId = dotenv.env['CLIENT_ID'];
//   clientSecret = dotenv.env['CLIENT_SECRET'];
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   final _navigatorKey = GlobalKey<NavigatorState>();
//   late AppLinks _appLinks;
//   StreamSubscription<Uri>? _linkSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//
//     initDeepLinks();
//   }
//
//   @override
//   void dispose() {
//     _linkSubscription?.cancel();
//
//     super.dispose();
//   }
//
//   Future<void> initDeepLinks() async {
//     _appLinks = AppLinks();
//
//     // Handle links
//     _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
//       debugPrint('onAppLink: $uri');
//       openAppLink(uri);
//     });
//   }
//
//   void openAppLink(Uri uri) {
//     _navigatorKey.currentState?.pushNamed(uri.fragment);
//   }
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: _navigatorKey,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Book-beats'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final TextEditingController playlistNameController =
//   TextEditingController(text: 'SpasFlutterPlaylist');
//   final TextEditingController vibeController =
//   TextEditingController(text: 'Relaxing classical music');
//
//   Future<void> doEverything(String playlistName, String vibe) async {
//     // Auth Configuration
//     /*SpotifyOAuth2Client client = SpotifyOAuth2Client(
//       customUriScheme: 'my.test.app',
//       redirectUri: 'my.test.app:/callback',
//     );
// */
//
//     print('Step 1 and 2, get the authorization code and auth token');
//
//     /*OAuth2Helper oauth2Helper = OAuth2Helper(client,
//       grantType: OAuth2Helper.authorizationCode,
//       clientId: clientId ?? "OR NOPE",
//       clientSecret: clientSecret,
//       webAuthOpts: {'preferEphemeral': true},
//       scopes: [
//         'playlist-modify-public,playlist-modify-private,user-read-private,user-read-email'
//       ],
//     );*/
//
//     try {
//       // Perform OAuth2 authentication
//       // await makeApiRequests(oauth2Helper, playlistName, vibe);
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }
//
// /*  Future<void> makeApiRequests(OAuth2Helper oauth2Helper, String playlistName,
//       String vibe) async {
//     print('Step 3: Accept The Challenge and Get the user ID');
//     http.Response response =
//     await oauth2Helper.get('https://api.spotify.com/v1/me');
//     var data = jsonDecode(response.body);
//     var userId = data['id'];
//     print('here is the userId: $userId');
// *//*    AccessTokenResponse? accessTokenResponse = await oauth2Helper.getTokenFromStorage();
//     print("This is the response: ${accessTokenResponse}");
//     String accessToken = accessTokenResponse!.accessToken!;
//     print("what kind of token is this: ${accessToken}");*//*
//
//     print('Step 4: Create a Playlist for $userId');
//
//     var url = 'https://api.spotify.com/v1/users/$userId/playlists';
//     print(url);
//     var playlistDetails = jsonEncode({
//       "name": playlistName,
//       "description": "Awesome trio strikes again",
//       "public": true
//     });
//     print(playlistDetails);
//
//
//     // var createPlaylistResponse = await http.post(uriTypeUrl, headers: playlistHeaders, body: playlistDetails);
//
//     // idk what's gonig on but this is blocking and I need to click a second time because of it
//     http.Response createPlaylistResponse =
//     await oauth2Helper.post(url, body: playlistDetails);
//
// *//*    http.Response createPlaylistResponse;
//     try {
//       createPlaylistResponse = await oauth2Helper.post(url, body: playlistDetails);
//     } catch (e) {
//       print(e);
//     }
//     print("Did it work?");*//*
//
//     var playlistId = jsonDecode(createPlaylistResponse.body)['id'];
//     // var playlistId = "asdfasdf";
//     print('Step 5: Get song suggestions from openAi');
//
// *//*
//     sleep(const Duration(seconds: 5));
//     print('Step 5: Get song suggestions from 44445555555');*//*
//     var openaiSongs = await getSongSuggestions(vibe);
//     print('Step 6: Search for tracks based on song namews and artists');
//
//     // print('decoded suggestions: $decodedSongSuggestions');
//     List<String> trackIds = await searchForTrackIds(openaiSongs, oauth2Helper);
//
//     print('Step 7: Add tracks to playlist!');
//     print("the track ids look like $trackIds");
//     var trackUris = trackIds.map((id) => 'spotify:track:$id').toList();
//
//     print("track uirs look like $trackUris");
//     var trackUriJsonData = '''
//     {
//       "uris": $trackUris
//     }
//     ''';
//
//     var addToPlaylistUrl =
//         'https://api.spotify.com/v1/playlists/$playlistId/tracks';
//     await oauth2Helper.post(addToPlaylistUrl,
//         body: jsonEncode(trackUriJsonData));
//
//     print(
//         "ALL DONE! Check your spotify afccount for the awesome playlist you just made");
//   }*/
//
//
//   /// Either load an OAuth2 client from saved credentials or authenticate a new
//   /// one.
//   Future<oauth2.Client> createClient() async {
//     final appLinks = AppLinks(); // AppLinks is singleton
//     var exists = await credentialsFile.exists();
//
//     // If the OAuth2 credentials have already been saved from a previous run, we
//     // just want to reload them.
//     if (exists) {
//       var credentials =
//       oauth2.Credentials.fromJson(await credentialsFile.readAsString());
//       return oauth2.Client(
//           credentials, identifier: clientId, secret: clientSecret);
//     }
//
//     // If we don't have OAuth2 credentials yet, we need to get the resource owner
//     // to authorize us. We're assuming here that we're a command-line application.
//     var grant = oauth2.AuthorizationCodeGrant(
//         clientId, authorizationEndpoint, tokenEndpoint,
//         secret: clientSecret);
//
//     // A URL on the authorization server (authorizationEndpoint with some additional
//     // query parameters). Scopes and state can optionally be passed into this method.
//     var authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes:spotifyScopes);
//
//     // Redirect the resource owner to the authorization URL. Once the resource
//     // owner has authorized, they'll be redirected to `redirectUrl` with an
//     // authorization code. The `redirect` should cause the browser to redirect to
//     // another URL which should also have a listener.
//     //
//     // `redirect` and `listen` are not shown implemented here. See below for the
//     // details.
//     await _launchUrl();
//
//     var responseUrl = await listen(redirectUrl);
//
//     final linksStream = _appLinks.uriLinkStream.listen((Uri uri) async {
//       if (uri.toString().startsWith(redirectUrl)) {
//         responseUrl = uri;
//       }
//     });
//     _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
//       debugPrint('onAppLink: $uri');
//       openAppLink(uri);
//     });
//
//     // Subscribe to all events (initial link and further)
//     // final sub = appLinks.uriLinkStream.listen((redirectUrl) {
//     //   Navigator.push(
//     //       context,
//     //       MaterialPageRoute(builder: (context) => customScreen())
//     // });
//
//     // Once the user is redirected to `redirectUrl`, pass the query parameters to
//     // the AuthorizationCodeGrant. It will validate them and extract the
//     // authorization code to create a new Client.
//     return await grant.handleAuthorizationResponse(responseUrl.queryParameters);
//   }
//
//   Future<void> _launchUrl() async {
//     if (!await launchUrl(authorizationEndpoint)) {
//       throw Exception('Could not launch $authorizationEndpoint');
//     }
//   }
//
//   Widget customScreen() {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Second Screen')),
//       body: Center(child: Text('Opened with app links)
//     );
//   }
//
//   /*Future<List<String>> searchForTrackIds(Map<String, String> openaiSongs,
//       OAuth2Helper oauth2Helper) async {
//     List<String> trackIds = [];
//
//     // Iterate through each entry in the map
//     for (var entry in openaiSongs.entries) {
//       String key = entry.key;
//       String value = entry.value;
//       var searchTracksUrl = 'https://api.spotify.com/v1/search?q=track:$key artist:$value&type=track,artist&limit=1';
//
//       // Perform the HTTP request and await the response
//       var trackSearchResponse = await oauth2Helper.get(searchTracksUrl);
//       var decodedTracks = jsonDecode(
//           trackSearchResponse.body)['tracks']['items'];
//
//       // Check if the response contains any tracks
//       if (decodedTracks.isNotEmpty) {
//         // If tracks are found, add the first track's ID to the list
//         String? trackId = decodedTracks[0]['id'] as String?;
//         if (trackId != null) {
//           trackIds.add(trackId);
//         }
//       }
//     }
//     return trackIds;
//   }
//
//   Future<Map<String, String>> getSongSuggestions(String vibe) async {
//     final openAiKey = dotenv.env['OPENAI_API_KEY'];
//
//     var url = Uri.parse('https://api.openai.com/v1/chat/completions');
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $openAiKey',
//     };
//
//     String body = jsonEncode({
//       'model': 'gpt-4o-mini',
//       'messages': [
//         {'role': 'system', 'content': Prompts.systemMessage},
//         {'role': 'user', 'content': Prompts.generatePrompt(vibe)}
//       ]
//     });
//
//     var response = await http.post(url, headers: headers, body: body);
//
//     // print("open ai go");
//     // print(jsonDecode(response.body));
//
//     var songs = jsonDecode(response.body)['choices'][0]['message']['content'];
//
//     print('time to convert');
//     // print(songs);
//     Map<String, String> parsedSongs = {};
//     jsonDecode(songs)['items'].forEach((songItem) {
//       var name = songItem['song'];
//       var artist = songItem['artist'];
//
//       parsedSongs[name] = artist;
//     });
//
//     print('does this look like anything $parsedSongs');
//
//     return parsedSongs;
//   }*/
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme
//             .of(context)
//             .colorScheme
//             .inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Choose your playlist name:',
//               style: Theme
//                   .of(context)
//                   .textTheme
//                   .headlineSmall,
//             ),
//             Container(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: playlistNameController,
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(20.0),
//             ),
//             Text(
//               'Describe the vibe you are going for:',
//               style: Theme
//                   .of(context)
//                   .textTheme
//                   .headlineSmall,
//             ),
//             Container(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: vibeController,
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await doEverything(playlistNameController.text, vibeController.text);
//         },
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
