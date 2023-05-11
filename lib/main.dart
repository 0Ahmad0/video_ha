import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cam/WelcomePage.dart';

import 'controller/downloder_provider.dart';
import 'controller/uploader_provider.dart';
import 'controller/video_provider.dart';

import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter_cam/LogIn.dart";
import 'package:provider/provider.dart';
StreamController<bool> setTheme = StreamController();

Future<void>  main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     // options: DefaultFirebaseOptions.currentPlatform
  );
  Provider.debugCheckInvalidValueType = null;
  runApp( const MyApp());
}

/* Map<String, StatelessWidget Function(dynamic context)> routes = {
  //"/": (context) => Login(),
  "/categories_screen": (context) => CategoriesScreen(),
  "/In_categories": (context) => In_Category(),
}; */

// to format shift option F
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //flutter will always call build method for drawing
  @override
  Widget build(BuildContext context) {
    return
      MultiProvider(
          providers: [
            Provider<DownloaderProvider>(create: (_)=>DownloaderProvider()),
            Provider<UploaderProvider>(create: (_)=>UploaderProvider()),
            Provider<VideoProvider>(create: (_)=>VideoProvider()),
          ],
          child : StreamBuilder<bool>(
              initialData: true,
              stream: setTheme.stream,
            builder: (context, snapshot) {
              return MaterialApp(
                  title: 'home_Menu',
                  theme:  snapshot.data!?ThemeData.dark().copyWith(
                    elevatedButtonTheme: ElevatedButtonThemeData(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 60.0)
                        ))
                  ):ThemeData(
                    primarySwatch: Colors.blue,
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60.0)
                      )
                    ),// color for the bar
                    canvasColor:
                    Color.fromARGB(210, 255, 255, 255), //color for the background
                  ),
                  home: WelcomePage(),

              );
            }
          )
      );
  }
}
bool theme = true;
/* class mainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
          body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyApp();
          } else {
            return Login();
          }
        },
      ));
} */
/*body: Card(
         child: Row(
           children: <Widget>[
            Image.asset('assets/test.jpeg'),
            Text('pokemoon card')
           ],
         ),
       ),
*/

/*body: Container(
          width: 200.0,
          height: 100.0,
          color: Colors.green,
          margin: EdgeInsets.all(20),
          child: Text("Hello! I am in the container widget",
              style: TextStyle(fontSize: 25)),
        ),*/
/*body: Card(
           child: Row(
             children: <Widget>[
               Image.asset('assets/test.jpeg'),
               Text('pokemoon card')
             ],
           ),
         ),*/

//class SecondScreen extends StatelessWidget {
//  @override
//Widget build(BuildContext ctxt) {
//  return new Scaffold(
//   appBar: new AppBar(
//   title: new Text("Multi Page Application Page-1"),
//  ),
// body: new Text("Another Page...!!!!!!"),
//  );
// }
//}
