import 'dart:io';
import 'dart:ui' as ui;

import 'package:atendimentos/services/applesigninavailable.dart';
import 'package:atendimentos/ui/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double distancia;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (Platform.isIOS) {
      distancia = AppBar().preferredSize.height + 60;
    } else {
      distancia = AppBar().preferredSize.height + 40;
    }

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
                SizedBox(
                  height: distancia,
                ),
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
                      child: Text("Consultório online",
                        style: new TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/45,
                            fontFamily: 'quicksand',
                            color: Colors.white
                        ),
                      )
                  ),
                  subtitle: Center(
                      child: Text("Pacientes e profissionais a um clique de distância",
                        style: new TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                            fontFamily: 'quicksand',
                            color: Colors.white
                        ),
                      )
                  ),
                ),
              ],
            ),
            /*child: Container(
                width: MediaQuery.of(context).size.width / 1.2,
                height: MediaQuery.of(context).size.height / 2,
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
                ),*/
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /*Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                ),
                                labelText: "E-mail",
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                              ),
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
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                ),
                                labelText: "Senha",
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                              height: MediaQuery.of(context).size.height/110,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
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
                                      _signInWithEmailAndPassword().then((result) {
                                        if (result != null) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return FirstScreen();
                                              },
                                            ),
                                          );
                                        }
//                                        _emailController.text = '';
//                                        _passwordController.text = '';
                                      });
//                                      _register();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Container(
                                        color: Colors.black,
                                        child :Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: Text(
                                            'Fazer login',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                              fontFamily: 'quicksand',
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
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
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Registro();
                                        },
                                      ),
                                    );
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
                                              fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
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
                            SizedBox(
                              height: MediaQuery.of(context).size.height/100,
                            ),
                            GestureDetector(
                              child: Text(
                                'Esqueceu sua senha? Clique aqui.',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height/57,
                                  fontFamily: 'quicksand',
                                  color: Colors.black,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return RecuperarSenha();
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height/100,
                            ),*/
                  Align(
                    alignment: Alignment.bottomCenter,
                    child:
                    Container(
                        width: MediaQuery.of(context).size.width/2,
                        child: FlatButton(
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
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(tipo: 'paciente')));
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Container(
                              color: Colors.white,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image(image: AssetImage("assets/images/people.png"), height: MediaQuery.of(context).size.height/55),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 3),
                                    child: Text(
                                      'Paciente',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width/2,
                      child: FlatButton(
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
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(tipo: 'profissional')));
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Container(
                            color: Colors.white,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image(image: AssetImage("assets/images/nurse.png"), height: MediaQuery.of(context).size.height/55),
                                Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Text(
                                    'Profissional',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                      fontFamily: 'quicksand',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                  ),
                  SizedBox(
                    height: Platform.isAndroid ? distancia - 30 : distancia - 40,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*Future<User> _signInWithEmailAndPassword() async {
    String nome;
    String email;
    String imageUrl;
    String usuario;

    try {
      final UserCredential authResult = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ));

      final User user = authResult.user;

      if (user != null) {
        assert(user.email != null);
        email = user.email;

        if (email.contains("@")) {
          usuario = email.substring(0, email.indexOf("@"));
          if (usuario.contains('.') || usuario.contains('#') ||
              usuario.contains('\$') ||
              usuario.contains('[') || usuario.contains(']')) {
            usuario = usuario.replaceAll('\.', '');
            usuario = usuario.replaceAll('#', '');
            usuario = usuario.replaceAll('\$', '');
            usuario = usuario.replaceAll('[', '');
            usuario = usuario.replaceAll(']', '');
          }
        }

        nome = '';
        imageUrl = '';
        _emailController.text = '';
        _passwordController.text = '';
        print('$email acessou o sistema');
        return user;
      }
    } on FirebaseAuthException catch  (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
      if(e.code == 'user-not-found') {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              content: Text('Email não cadastrado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'quicksand',
                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                ),
              ),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            )
        ));
      } else if (e.code == 'wrong-password') {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              content: Text('Senha incorreta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'quicksand',
                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                ),
              ),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            )
        ));
      }
    }
  }


  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (ex) {
      if(ex.code == 'ERROR_INVALID_EMAIL') {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              content: Text('Email não cadastrado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'quicksand',
                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                ),
              ),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            )
        )
        );
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
  }*/

  @override
  void dispose() {
    super.dispose();
  }
}