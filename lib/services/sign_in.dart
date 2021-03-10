import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

// Add these three variables to store the info
// retrieved from the FirebaseUser
String name;
String email;
String imageUrl;
String usuario;

Future<String> signInWithGoogle() async {
  await Firebase.initializeApp();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult = await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    // Add the following lines after getting the user
    // Checking if email and name is null
    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoURL != null);

    // Store the retrieved data
    name = user.displayName;
    email = user.email;
    imageUrl = user.photoURL;

    if (email.contains("@")) {
      usuario = email.substring(0, email.indexOf("@"));
      if(usuario.contains('.') || usuario.contains('#') || usuario.contains('\$') ||
          usuario.contains('[') || usuario.contains(']')) {
        usuario = usuario.replaceAll('\.', '');
        usuario = usuario.replaceAll('#', '');
        usuario = usuario.replaceAll('\$', '');
        usuario = usuario.replaceAll('[', '');
        usuario = usuario.replaceAll(']', '');
      }
    }

    // Only taking the first part of the name, i.e., First Name
    /*if (name.contains(" ")) {
      name = name.substring(0, name.indexOf(" "));
    }*/
    CircularProgressIndicator();

    print('$email acessou o sistema');
    return '$user';
  }

    return null;
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();

  print("$email saiu do sistema");
}