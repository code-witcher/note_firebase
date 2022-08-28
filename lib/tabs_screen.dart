import 'package:flutter/material.dart';
import 'package:notes_firebase/home_page.dart';
import 'package:notes_firebase/profile.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  var currentIndex = 0;

  final pages = [];

  List<Widget> get getPages {
    return [
      const HomePage(),
      // const AddNote(),
      const Profile(),
    ];
  }

  @override
  void initState() {
    pages.addAll(getPages);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text('Notes'),
      //   actions: [
      //     IconButton(
      //       onPressed: () async {
      //         await FirebaseAuth.instance.signOut();
      //       },
      //       icon: Icon(Icons.exit_to_app),
      //     ),
      //   ],
      // ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.add_circle),
          //   label: 'Add Note',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
