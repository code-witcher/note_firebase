import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddNote extends StatefulWidget {
  const AddNote({Key? key}) : super(key: key);
  static const routeName = '/add-note';

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final formKey = GlobalKey<FormState>();
  final scaffoldState = GlobalKey<ScaffoldState>();
  final currentUid = FirebaseAuth.instance.currentUser?.uid;

  final note = {
    'title': '',
    'body': '',
    'doc': '',
    // 'image': '',
  };

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
          'image': imageURL ?? '',
        });
      } else {
        await FirebaseFirestore.instance
            .collection('notes/$currentUid/userNote')
            .add({
          'title': note['title'],
          'body': note['body'],
          'image': imageURL ?? '',
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

  String? imageURL;

  bool isLoading = false;

  Future<void> getImage(bool isCamera) async {
    File pickedImage;

    final imageFile = await ImagePicker().pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (imageFile == null) return;

    pickedImage = File(imageFile.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child(currentUid!)
        .child('${UniqueKey()}.png');

    setState(() {
      isLoading = true;
    });

    await ref.putFile(pickedImage);

    final link = await ref.getDownloadURL();

    setState(() {
      isLoading = false;

      imageURL = link;
    });
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

      imageURL = arguments['image'];
    }

    return Scaffold(
      key: scaffoldState,
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
            if (isLoading)
              Container(
                height: 200,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Container(
                  height: 35,
                  child: CircularProgressIndicator(),
                ),
              ),
            if (imageURL != null)
              if (imageURL!.isNotEmpty)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageURL!),
                    ),
                  ),
                ),
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
                return null;
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
                  return null;
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
        onPressed: () async {
          dynamic isCamera;

          FocusScope.of(context).unfocus();

          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (ctx) => BottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              backgroundColor: Colors.grey.shade200,
              onClosing: () {},
              builder: (ctx) => FractionallySizedBox(
                heightFactor: 0.17,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      onPressed: () {
                        setState(() {
                          isCamera = true;
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: const Text(
                        "Camera",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      // margin: const EdgeInsets.symmetric(horizontal: 32),
                      color: Colors.blueGrey,
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 1,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      onPressed: () {
                        setState(() {
                          isCamera = false;
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: const Text(
                        "Gallery",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).then((value) {
            if (isCamera == null) return;
            getImage(isCamera);
          });
        },
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }
}
