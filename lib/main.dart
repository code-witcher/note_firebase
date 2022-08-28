import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_firebase/auth_page.dart';
import 'package:notes_firebase/tabs_screen.dart';

import 'add_note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  // if (shouldUseFirestoreEmulator) {
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<User?> s = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, AsyncSnapshot<User?> userSnap) {
          return userSnap.hasData ? const TabsScreen() : const AuthPage();
        },
      ),
      // ? const AuthPage()
      // : const HomePage(),
      routes: {
        // HomePage.routeName: (ctx) => const HomePage(),
        AddNote.routeName: (ctx) => const AddNote(),
      },
    );
  }
}
