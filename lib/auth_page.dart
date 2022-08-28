import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  UserCredential? userCredential;

  final formKey = GlobalKey<FormState>();
  String? username;
  String? email;
  String? password;
  bool _login = true;
  var _isLoading = false;

  void signup() async {
    if (!formKey.currentState!.validate()) return;

    formKey.currentState?.save();

    FocusScope.of(context).unfocus();

    // if (!await InternetConnectionChecker().hasConnection) {
    //   AwesomeDialog(
    //     context: context,
    //     dialogType: DialogType.ERROR,
    //     body:
    //         const Text('Please check your Internet connection then try again'),
    //   ).show();
    // }

    try {
      setState(() {
        _isLoading = true;
      });
      if (_login) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email!,
          password: password!,
        );
      } else {
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email!,
          password: password!,
        );

        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential?.user?.uid)
            .set(
          {
            'username': username,
            'email': email,
          },
        );
      }

      setState(() {
        _isLoading = false;
      });

      // print(userCredential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(e.code),
        ),
        title: "Error",
        btnCancel: TextButton(
          onPressed: () {
            if (e.code == "email-already-in-use") {
              setState(() {
                _login = true;
              });
            }
            Navigator.of(context).pop();
          },
          child: const Text('Ok'),
        ),
      ).show();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print(
          '$e ==================================================================');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Something went wrong'),
        ),
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: Image.asset(
                      'images/owl.png',
                      color: Colors.blue,
                    ),
                  ),
                  if (!_login)
                    AuthField(
                      hintText: 'Username',
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "This Field can't be empty";
                        }
                        if (value.length < 2) {
                          return "Username can't be less than 2 characters";
                        }
                      },
                      onSaved: (value) {
                        username = value;
                      },
                    ),
                  const SizedBox(height: 16),
                  AuthField(
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Email',
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This Field can't be empty";
                      }
                      if (!value.contains('.com') || !value.contains('@')) {
                        return "Invalid email address";
                      }
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthField(
                    obscureText: true,
                    hintText: 'Password',
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: FontAwesomeIcons.lock,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This Field can't be empty";
                      }
                      if (value.length < 6) {
                        return "Password can't be less than 6 characters";
                      }
                    },
                    onSaved: (value) {
                      password = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      children: [
                        const Text('If you have account'),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _login = !_login;
                            });
                          },
                          child: const Text('Click Here'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      signup();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoading
                          ? const SizedBox(
                              height: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(_login ? 'Login' : 'Register Me'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: StadiumBorder(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        userCredential = await signInWithGoogle();

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userCredential?.user?.uid)
                            .set(
                          {
                            'username': userCredential?.user?.displayName,
                            'email': userCredential?.user?.email,
                          },
                        );
                      } on FirebaseAuthException catch (e) {
                        print(e);
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _login ? 'Login with Google' : 'Signup with Google',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField(
      {required this.hintText,
      this.prefixIcon,
      super.key,
      this.validator,
      this.onSaved,
      this.obscureText,
      this.keyboardType});

  final String hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final bool? obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
      ),
      obscureText: obscureText ?? false,
      validator: validator,
      onSaved: onSaved,
    );
  }
}
