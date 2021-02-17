import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RecuperarSenha extends StatefulWidget {
  @override
  _RecuperarSenhaState createState() => _RecuperarSenhaState();
}

class _RecuperarSenhaState extends State<RecuperarSenha> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userEmail = '';
  bool emailValido;

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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(top: 20),
                  child: Image.asset(
                    'assets/images/health.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.fill,
                  ),
                ),
                ListTile(
                  title: new Center(
                      child: Text("Meu consultório online",
                        style: new TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MediaQuery.of(context).size.height/45,
                            fontFamily: 'quicksand',
                            color: Colors.white
                        ),
                      )
                  ),
                  subtitle: Center(
                      child: Text("Seus pacientes a um clique de distância",
                        style: new TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: MediaQuery.of(context).size.height/55,
                            fontFamily: 'quicksand',
                            color: Colors.white
                        ),
                      )
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.2,
                height: MediaQuery.of(context).size.height / 3.9,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    border: Border.all(color: Colors.transparent),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white,
                          blurRadius: 1
                      )
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Redefinição de senha',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery.of(context).size.height/50,
                              ),
                              controller: _emailController,
                              //onSaved: (email) => paciente.email = email,
                              validator: validateEmail,
                              cursorColor: Colors.black,
                              onFieldSubmitted: (_) {
                                setState(() {
                                  _userEmail = _emailController.text.toString();
                                });
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  const BorderSide(color: Colors.black, width: 1.0),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                enabledBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  borderSide:
                                  new BorderSide(color: Colors.black, width: 1.0),
                                ),
                                hintText: "Digite seu e-mail",
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                ),
                                labelText: "E-mail",
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                  const BorderSide(color: Colors.red, width: 2.0),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      Text('Digite um email válido',
                        style: TextStyle(
                            color: emailValido == false ? Colors.transparent : Colors.red.shade900,
                            fontSize: MediaQuery.of(context).size.height/60,
                            fontFamily: 'quicksand'
                        ),
                      ),
                      FlatButton(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid
                            ),
                            borderRadius: BorderRadius.circular(40)
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            recuperarSenha(_emailController.text.toString());
                            Fluttertoast.showToast(
                              msg:'Email para redefinição de senha enviado',
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIosWeb: 5,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Container(
                              color: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: Text(
                                  'Redefinir senha',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.height/55,
                                    fontFamily: 'quicksand',
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> recuperarSenha(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      setState(() {
        emailValido = false;
      });
      return 'Digite um e-mail válido.';
    } else {
      setState(() {
        emailValido = true;
      });
      return null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}