import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_note.dart';
import 'note_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = '/home-page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Notes'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notes/$currentUid/userNote')
              .orderBy('createAt', descending: true)
              .snapshots(),
          builder: (ctx, AsyncSnapshot<QuerySnapshot<Map>> streamSnapshot) {
            final documents = streamSnapshot.data?.docs ?? [];

            return streamSnapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: documents.isEmpty
                        ? Center(
                            child: Text(
                              'No notes yet',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemBuilder: (ctx, i) => NoteWidget(
                              document: documents[i],
                              index: i,
                              title: documents[i]['title'],
                              body: documents[i]['body'],
                            ),
                            itemCount: documents.length,
                          ),
                  );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddNote.routeName);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// class GridCust extends StatelessWidget {
//   const GridCust({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MasonryGridView.count(
//       crossAxisCount: 2,
//       crossAxisSpacing: 8,
//       mainAxisSpacing: 8,
//       itemCount: 10,
//       itemBuilder: (BuildContext context, int index) {
//         return Container(
//           color: Colors.red,
//           height: (index % 5 + 1) * 100,
//           child: Note,
//         );
//       },
//     );
//   }
// }
