import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final currentUser = FirebaseAuth.instance.currentUser!;

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
        .child(currentUser.uid)
        .child('${UniqueKey()}.png');

    setState(() {
      isLoading = true;
    });

    await ref.putFile(pickedImage);

    final link = await ref.getDownloadURL();

    setState(() {
      isLoading = false;
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'userImage': link});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get(),
        builder: (ctx, snap) => snap.connectionState == ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 100,
                            backgroundImage: (snap.data?['userImage'] != null
                                    ? NetworkImage(snap.data?['userImage'])
                                    : const AssetImage('images/owl.png'))
                                as ImageProvider,
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : null,
                          ),
                          PositionedDirectional(
                            bottom: 4,
                            end: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300,
                              ),
                              // padding: const EdgeInsets.all(8),
                              child: IconButton(
                                onPressed: () async {
                                  dynamic isCamera;

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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
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
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
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
                                icon: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        snap.data?['username'],
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade700,
                                ),
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Email',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade800,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              snap.data!['email'] ?? "Unknown",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.blueGrey.shade700,
                                  ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Divider(
                              color: Colors.white,
                              thickness: 1.15,
                            ),
                          ),
                          Text(
                            'Phone',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade800,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              snap.data!.data()!.containsKey('phone')
                                  ? snap.data!['phone']
                                  : "Unknown",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.blueGrey.shade700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
