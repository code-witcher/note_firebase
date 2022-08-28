import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNote extends StatefulWidget {
  const AddNote({Key? key}) : super(key: key);
  static const routeName = '/add-note';

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final formKey = GlobalKey<FormState>();
  final currentUid = FirebaseAuth.instance.currentUser?.uid;

  final note = {'title': '', 'body': '', 'doc': ''};

  Future<void> addNote() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState?.save();

    FocusScope.of(context).unfocus();

    try {
      if (isEdit) {
        await FirebaseFirestore.instance
            .collection('notes/$currentUid/userNote')
            .doc(note['doc'])
            .update({
          'title': note['title'],
          'body': note['body'],
        });
      } else {
        await FirebaseFirestore.instance
            .collection('notes/$currentUid/userNote')
            .add({
          'title': note['title'],
          'body': note['body'],
          'createAt': Timestamp.now(),
        });
      }

      Navigator.of(context).pop();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
      ).show();
    }
  }

  var isEdit = false;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      setState(() {
        isEdit = true;
      });

      note['title'] = arguments['title'];
      note['body'] = arguments['body'];
      note['doc'] = arguments['doc'].id;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEdit ? 'Edit Note' : 'Add Note'),
        actions: [
          IconButton(
            onPressed: () {
              addNote();
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                hintText: 'Title',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              initialValue: note['title'],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title for your note';
                }
              },
              onSaved: (value) {
                note['title'] = value!;
              },
            ),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  hintText: 'Type here your note...',
                  contentPadding: EdgeInsets.all(16),
                ),
                maxLines: 100,
                initialValue: note['body'],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Note can't be empty";
                  }
                },
                onSaved: (value) {
                  note['body'] = value!;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNote();
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
