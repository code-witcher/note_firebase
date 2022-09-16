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

  final _primary = {
    50: const Color(0xFF80c9ff),
    100: const Color(0xFF6bc0ff),
    200: const Color(0xFF55b7ff),
    300: const Color(0xFF40aeff),
    400: const Color(0xFF2ba5ff),
    500: const Color(0xFF2795e6),
    600: const Color(0xFF2284cc),
    700: const Color(0xFF1e73b3),
    800: const Color(0xFF1a6399),
    900: const Color(0xFF165380),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF2BA5FF, _primary),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
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
// #2BA5FF
