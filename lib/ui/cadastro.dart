import 'package:atendimentos/model/profissional.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'dart:ui' as ui;

final FirebaseDatabase db = FirebaseDatabase.instance;

class Cadastro extends StatefulWidget {
  Profissional profissional;
  Cadastro({Key key, this.profissional}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  Profissional profissional;
  DatabaseReference dbReference;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Profissional> listaProfissional = List();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _areaAtuacaoController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String paisOrigem = 'BR';
  String facebook;
  String instagram;
  //PhoneNumber numero = PhoneNumber(isoCode: 'BR');
  //var maskTextInputFormatter = MaskTextInputFormatter(mask: "xxxxxxxxxxx", filter: {"x": RegExp(r'[0-9]')});

  TimeOfDay _time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    for(int i = 0; i < listaProfissional.length; i++) {
      listaProfissional.removeAt(i);
    }

    _nomeController.text = widget.profissional.nome;
    _emailController.text = widget.profissional.email;
    _facebookController.text = "https://www.facebook.com/";
    _instagramController.text = "https://www.instagram.com/";
    //paciente = new Paciente("", "", "", "", "", "", false);
    dbReference = db.reference().child('${widget.profissional.usuario}');
    dbReference.onChildAdded.listen(_gravar);
    dbReference.onChildChanged.listen(_update);
    dbReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      /*Paciente paciente = new Paciente(
          values['nome'], values['telefone'], values['email'],
          values['data'], values['hora'], values['anotacao'], values['confirmado']);
      listaPacientes.add(paciente);*/
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Profissional profissional = new Profissional(widget.profissional.nome, "", widget.profissional.email, "", widget.profissional.usuario, widget.profissional.imageURL, "", "", widget.profissional.assinante);

    return Scaffold(
      body: Stack(children: <Widget>[
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Color(0x44000000),
            elevation: 0.0,
            centerTitle: true,
            title: Text('Cadastro',
              style: TextStyle(
                fontFamily: 'quicksand',
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/homebg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            height: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height/1,
                  width: MediaQuery.of(context).size.width/1,
                  decoration: new BoxDecoration(color: Colors.black.withOpacity(0.0)),
                  child: new BackdropFilter(
                    filter: new ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    child: new Container(
                      decoration: new BoxDecoration(color: Colors.transparent.withOpacity(0.1)),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 100.0),
                            Flexible(
                              child: ListTile(
                                leading: Icon(Icons.account_box, color: Colors.white),
                                title: TextFormField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    fontFamily: 'quicksand',
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  controller: _nomeController,
                                  onSaved: (nome) => profissional.nome = nome,
                                  validator: (nome) =>
                                  nome.length < 3
                                      ? "Deve ter ao menos 3 caracteres."
                                      : null,
                                  cursorColor: Theme.of(context).accentColor,
                                  onFieldSubmitted: (_) {
                                    setState(() {
                                      profissional.nome = _nomeController.text.toString();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 3.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    enabledBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(8.0),
                                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                                    ),
                                    hintText: "Nome completo",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.height/50,
                                      fontFamily: 'quicksand',
                                      shadows: <Shadow>[
                                        Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                        Shadow(
                                          offset: Offset(2.0, 1.0),
                                          blurRadius: 8.0,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                    labelText: "Nome",
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'quicksand',
                                      fontSize: MediaQuery.of(context).size.height/50,
                                      shadows: <Shadow>[
                                        Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                        Shadow(
                                          offset: Offset(2.0, 1.0),
                                          blurRadius: 8.0,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 3.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.phone, color: Colors.white),
                              title: InternationalPhoneNumberInput(
                                maxLength: 15,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    Shadow(
                                      offset: Offset(2.0, 1.0),
                                      blurRadius: 8.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ],
                                ),
                                textFieldController: _telefoneController,
                                autoValidate: false,
                                errorMessage: 'Número fora do padrão',
                                inputDecoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  hintText: "xx xxxxx xxxx",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  labelText: "WhatsApp/Telefone",
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                    new BorderSide(color: Colors.red, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                countries: ['BR'],//, 'PT', 'US', 'GB-NIR', 'ES', 'GB'],
                                locale: 'BR',
                                onInputChanged: (phone) {
                                  profissional.telefone = '${phone.dialCode.toString()}' +
                                      '${_telefoneController.text}';
                                },
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                  Icons.alternate_email, color: Colors.white),
                              title: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    Shadow(
                                      offset: Offset(2.0, 1.0),
                                      blurRadius: 8.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ],
                                ),
                                controller: _emailController,
                                onSaved: (email) => profissional.email = email,
                                validator: validateEmail,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    profissional.email = _emailController.text.toString();
                                  });
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  hintText: "Digite seu e-mail",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  labelText: "E-mail",
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    fontFamily: 'quicksand',
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.red, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                  Icons.attach_money, color: Colors.white),
                              title: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    Shadow(
                                      offset: Offset(2.0, 1.0),
                                      blurRadius: 8.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ],
                                ),
                                controller: _areaAtuacaoController,
                                onSaved: (area) => profissional.areaAtuacao = area,
                                validator: (area) =>
                                area.length < 1
                                    ? "Não pode ficar em branco"
                                    : null,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    profissional.areaAtuacao = _areaAtuacaoController.text.toString();
                                  });
                                },
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  hintText: "Digite sua área profissional",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    fontFamily: 'quicksand',
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  labelText: "Área de atuação",
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    fontFamily: 'quicksand',
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.red, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                  Icons.account_circle, color: Colors.white),
                              title: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    Shadow(
                                      offset: Offset(2.0, 1.0),
                                      blurRadius: 8.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ],
                                ),
                                controller: _facebookController,
                                onSaved: (face) => profissional.facebook = face,
                                validator: (face) =>
                                face.length < 26
                                    ? "Digite seu facebook."
                                    : null,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    profissional.facebook = _facebookController.text.toString();
                                  });
                                },
                                keyboardType: TextInputType.url,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  hintText: "https://www.facebook.com/nomedeusuario",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    fontFamily: 'quicksand',
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  labelText: "Seu Facebook",
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.red, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                  Icons.assignment_ind, color: Colors.white),
                              title: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.height/50,
                                  fontFamily: 'quicksand',
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    Shadow(
                                      offset: Offset(2.0, 1.0),
                                      blurRadius: 8.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ],
                                ),
                                controller: _instagramController,
                                onSaved: (insta) => profissional.instagram = insta,
                                validator: (insta) =>
                                insta.length < 27
                                    ? "Digite seu instagram."
                                    : null,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    profissional.instagram = _instagramController.text.toString();
                                  });
                                },
                                keyboardType: TextInputType.url,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  hintText: "https://instagram.com/nomedeusuario",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  labelText: "Instagram",
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    fontFamily: 'quicksand',
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.red, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlatButton(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                      style: BorderStyle.solid
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Text(
                                  "Cadastrar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.height/50,
                                    fontFamily: 'quicksand',
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(2.0, 1.0),
                                        blurRadius: 8.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (formKey.currentState.validate()) {
                                      formKey.currentState.save();
                                      Profissional pro = new Profissional(
                                          profissional.nome,
                                          profissional.telefone,
                                          profissional.email,
                                          profissional.areaAtuacao,
                                          profissional.usuario,
                                          profissional.imageURL,
                                          profissional.facebook,
                                          profissional.instagram,
                                          false);

                                      _submit(pro);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ),
        ),
      ]
      ),
    );
  }

  void _gravar(Event event) {
    setState(() {
      listaProfissional.add(Profissional.fromSnapshot(event.snapshot));
    });
  }

  void _update(Event event) {
    var oldEntry = listaProfissional.singleWhere((entry) {
      return entry.primaryKey == event.snapshot.key;
    });

    setState(() {
      listaProfissional[listaProfissional.indexOf(oldEntry)] =
          Profissional.fromSnapshot(event.snapshot);
    });
  }

  void _submit(Profissional profissional) async {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      listaProfissional.add(profissional);
      //cria novo paciente a cada push
      dbReference.push().set(profissional.toJson());
    }

    form.reset();
    /*_nomeController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _dataEscolhida = null;
    horaSelecionada = null;*/

    Navigator.of(context).pop();
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
}