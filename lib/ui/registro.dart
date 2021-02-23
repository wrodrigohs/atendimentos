import 'dart:ui' as ui;

import 'package:atendimentos/services/applesigninavailable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class Registro extends StatefulWidget {
  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _success;
  String _userEmail;
  bool _obscureText = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final appleSignInAvailable =
    Provider.of<AppleSignInAvailable>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
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
                height: MediaQuery.of(context).size.height / 2.8,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                                  //paciente.email = _emailController.text.toString();
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
                            //Senha
                            TextFormField(
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery.of(context).size.height/50,
                              ),
                              enableInteractiveSelection: false,
                              controller: _passwordController,
                              obscureText: _obscureText,
                              //onSaved: (email) => paciente.email = email,
                              validator: (String value) => value.length < 9 ? 'Senha deve ter 8 caracteres, no mínimo' : null,
                              cursorColor: Colors.black,
                              onFieldSubmitted: (_) {
                                setState(() {
                                  //paciente.email = _emailController.text.toString();
                                });
                              },
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _verSenha();
                                  },
                                ),
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
                                hintText: "Digite sua senha",
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                ),
                                labelText: "Senha",
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
                              width: 5,
                            ),
                          ],
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
                            _register();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Container(
                              color: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: Text(
                                  'Registre-se',
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

  void _register() async {
    try {
      final User user = (await
      _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )
      ).user;
      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = user.email;
          Fluttertoast.showToast(
            msg: 'Registro efetuado com sucesso',
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 5,
          );
          Navigator.of(context).pop();
        });
      } else {
        setState(() {
          _success = false;
        });
      }
    } on FirebaseAuthException catch(ex) {
      print(ex.code);
      print(ex.message);
      if(ex.code == 'email-already-in-use') {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 1),
                  content: Text('Email já cadastrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'quicksand',
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .height / 50,
                    ),
                  ),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                )
            ));
      }
    }
  }

  void _verSenha() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Digite um e-mail válido.';
    else
      return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}