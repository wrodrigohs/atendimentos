import 'dart:io';
import 'dart:ui' as ui;

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:atendimentos/ui/firstscreen.dart';
import 'package:atendimentos/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/imglogin.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height/1,
              width: MediaQuery.of(context).size.width/1,
              decoration: new BoxDecoration(color: Colors.black.withOpacity(0.2)),
              child: new BackdropFilter(
                filter: new ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: new Container(
                  decoration: new BoxDecoration(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
            ),
            Center(
              child: _signInButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signInButton() {
    return FlatButton(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.black,
              width: 1,
              style: BorderStyle.solid
          ),
          borderRadius: BorderRadius.circular(40)
      ),
      onPressed: () {
        signInWithGoogle().then((result) {
          if (result != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return FirstScreen();
                },
              ),
            );
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("assets/images/google_logo.png"), height: 25.0),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Login com Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'quicksand',
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInApple() {
    return FlatButton(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      onPressed: () {
        signInWithGoogle().then((result) {
          if (result != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return FirstScreen();
                },
              ),
            );
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("assets/images/apple-logo.png"), height: 35.0),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Login com Apple',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}