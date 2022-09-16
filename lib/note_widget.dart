import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_firebase/add_note.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget({
    required this.document,
    required this.title,
    required this.body,
    Key? key,
    required this.index,
    required this.image,
  }) : super(key: key);

  final String body;
  final String title;
  final int index;
  final String image;
  final QueryDocumentSnapshot<Map<dynamic, dynamic>> document;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: (index % 5 + 1) * 100,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(AddNote.routeName, arguments: {
            'doc': document,
            'title': title,
            'body': body,
            'image': image,
          });
        },
        child: Column(
          children: [
            if (image.isNotEmpty)
              Container(
                constraints:
                    const BoxConstraints(maxHeight: 250, minHeight: 50),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade700,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    final currentUid = FirebaseAuth.instance.currentUser?.uid;

                    FirebaseFirestore.instance
                        .collection('notes/$currentUid/userNote')
                        .doc(document.id)
                        .delete();
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                ),
              ],
            ),
            Text(
              body,
              overflow: TextOverflow.ellipsis,
              maxLines: 10,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.blueGrey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
