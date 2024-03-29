import 'dart:io';
import 'dart:ui' as ui;
import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:atendimentos/services/applesigninavailable.dart';
import 'package:atendimentos/ui/firstscreen.dart';
import 'package:atendimentos/services/sign_in.dart';
import 'package:atendimentos/services/auth_service.dart';
import 'package:atendimentos/ui/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  String tipo;

  LoginPage({Key key, this.tipo}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//  final TextEditingController _emailController = TextEditingController();
//  final TextEditingController _passwordController = TextEditingController();
//  final FirebaseAuth _auth = FirebaseAuth.instance;
//  bool _obscureText = true;
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

    final appleSignInAvailable =
    Provider.of<AppleSignInAvailable>(context, listen: false);

    if (Platform.isIOS) {
      distancia = AppBar().preferredSize.height + 60;
    } else {
      distancia = AppBar().preferredSize.height + 40;
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: (Platform.isAndroid) ?
                Icon(Icons.arrow_back, color: Colors.white,)
                    :
                Icon(Icons.arrow_back_ios, color: Colors.white,),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute
                    (builder: (context) => Home()));
                },
              ),
              backgroundColor: Color(0x44000000),//Color(0xFF333366)
              elevation: 0.0,
              centerTitle: true,
              title: Text('Consultório online',
                style: TextStyle(
                    fontFamily: 'quicksand',
                    color: Colors.white
                ),
              ),
            ),
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
                        height: distancia + 10,
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
                        _signInButton(),
                        SizedBox(
                          height: 5,
                        ),
                        (appleSignInAvailable.isAvailable) ?
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
                          onPressed: () {
                            _signInWithApple(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Container(
                              color: Colors.black,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor: Colors.black,
                                    radius: 8.0,
                                    child: Image(color: Colors.white, image: AssetImage("assets/images/apple-logo.png"), height: MediaQuery.of(context).size.height/55),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 3),
                                    child: Text(
                                      'Iniciar sessão com a Apple',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                        fontFamily: 'quicksand',
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                            :
                        Container(),
                        SizedBox(
                          height: Platform.isAndroid ? distancia - 30 : distancia - 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _signInButton() {
    return FlatButton(
      color: Colors.blue.shade700,
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.blue.shade700,
              width: 1,
              style: BorderStyle.solid
          ),
          borderRadius: BorderRadius.circular(40)
      ),
      onPressed: () {
        signInWithGoogle().then((result) {
          if (result != null) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                FirstScreen(tipo: widget.tipo,)), (Route<dynamic> route) => false);
            }
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
          color: Colors.blue.shade700,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 8.0,
                child: Image(image: AssetImage("assets/images/google_logo.png"), height: MediaQuery.of(context).size.height/55),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Text(
                  'Iniciar sessão com Google',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                    fontFamily: 'quicksand',
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithApple(
          scopes: [apple.Scope.email, apple.Scope.fullName]);
      print('uid: ${user.uid}');
      String nomeIOS = user.displayName != null ? user.displayName : null;//apple.Scope.fullName.toString();
      String emailIOS = user.email != null ? user.email : null;//apple.Scope.email.toString();
      String usuarioIOS = '';

      if (emailIOS != null) {
        usuarioIOS = emailIOS.substring(0, emailIOS.indexOf("@"));
        if (usuarioIOS.contains('.') || usuarioIOS.contains('#') ||
            usuarioIOS.contains('\$') ||
            usuarioIOS.contains('[') || usuarioIOS.contains(']')) {
          usuarioIOS = usuarioIOS.replaceAll('\.', '');
          usuarioIOS = usuarioIOS.replaceAll('#', '');
          usuarioIOS = usuarioIOS.replaceAll('\$', '');
          usuarioIOS = usuarioIOS.replaceAll('[', '');
          usuarioIOS = usuarioIOS.replaceAll(']', '');
        }
      }

      if (user != null) {
        if(widget.tipo == 'profissional') {
          Profissional profissional = new Profissional(nomeIOS, "", emailIOS, "", '', '', "", "", "",
              false, false, false, false, false, false, false, null, false);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) =>
                  FirstScreen(tipo: widget.tipo, proIOS: profissional, logadoIOS: true,)), (
              Route<dynamic> route) => false);
        } else {
          Paciente pac = new Paciente(nomeIOS, "", emailIOS, '', "", "", "", false, "", false, false, false, false, false, "", false, "", false, "", "", "");
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) =>
                  FirstScreen(tipo: widget.tipo, pacienteIOS: pac, logadoIOS: true,)), (
              Route<dynamic> route) => false);
        }
      }
    } catch (e) {
      // TODO: Show alert here
      print('Erro no login com Apple ===> $e');
    }

    /*final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    print(credential);

    // This is the endpoint that will convert an authorization code obtained
    // via Sign in with Apple into a session in your system
    final signInWithAppleEndpoint = Uri(
      scheme: 'https',
      host: 'https://bristle-unique-behavior.glitch.me/callbacks',
      path: '/sign_in_with_apple',
      queryParameters: <String, String>{
        'code': credential.authorizationCode,
        if (credential.givenName != null)
          'firstName': credential.givenName,
        if (credential.familyName != null)
          'lastName': credential.familyName,
        'useBundleId':
        Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
        if (credential.state != null) 'state': credential.state,
      },
    );

    final session = await http.Client().post(
      signInWithAppleEndpoint,
    );

    // If we got this far, a session based on the Apple ID credential has been created in your system,
    // and you can now set this as the app's session
    print(session);

    if (credential != null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        FirstScreen(tipo: widget.tipo)), (Route<dynamic> route) => false);
    }*/
  }

  @override
  void dispose() {
    super.dispose();
  }
}