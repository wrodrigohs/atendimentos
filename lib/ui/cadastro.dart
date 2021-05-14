import 'dart:io';
import 'dart:ui' as ui;

import 'package:atendimentos/model/profissional.dart';
import 'package:atendimentos/ui/firstscreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;

class Cadastro extends StatefulWidget {
  Profissional profissional;
//  Paciente paciente;
  String email;
//  String tipo;
  Cadastro({Key key, this.profissional, this.email}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  Profissional profissional;
  DatabaseReference dbReference;
  List<Profissional> listaProfissional = List();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _areaAtuacaoController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _num_conselhoController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String> horas = ['07:00h', '07:30h', '08:00h', '08:30h', '09:00h', '09:30h', '10:00h',
    '10:30h', '11:00h', '11:30h', '12:00h', '12:30h', '13:00h', '13:30h', '14:00h', '14:30h',
    '15:00h', '15:30h', '16:00h', '16:30h', '17:00h', '17:30h', '18:00h', '18:30h', '19:00h',
    '19:30h', '20:00h', '20:30h', '21:00h', '21:30h', '22:00h'];
  List<bool> diasEscolhidos = List();
  List<dynamic> horasEscolhidas = List();

  bool domingo = false;
  bool segunda = false;
  bool terca = false;
  bool quarta = false;
  bool quinta = false;
  bool sexta = false;
  bool sabado = false;

  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String paisOrigem = 'BR';
  String facebook;
  String instagram;
  String tel;
  double distancia;

  @override
  void initState() {
    super.initState();

    for(int i = 0; i < listaProfissional.length; i++) {
      listaProfissional.removeAt(i);
    }

    for(int i = 0; i < horasEscolhidas.length; i++) {
      horasEscolhidas.removeAt(i);
    }

//    if(widget.tipo == 'profissional') {
      diasEscolhidos.add(domingo);
      diasEscolhidos.add(segunda);
      diasEscolhidos.add(terca);
      diasEscolhidos.add(quarta);
      diasEscolhidos.add(quinta);
      diasEscolhidos.add(sexta);
      diasEscolhidos.add(sabado);

      _nomeController.text = widget.profissional.nome;
      _emailController.text = widget.profissional.email;
      _facebookController.text = "https://www.facebook.com/";
      _instagramController.text = "https://www.instagram.com/";

      dbReference = db2.reference().child('atendimentos');
      dbReference.onChildAdded.listen(_gravar);
//      dbReference.onChildChanged.listen(_update);
      dbReference.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        Profissional prof = new Profissional(values['nome'], values['telefone'],
            values['email'], values['areaAtuacao'], values['usuario'],
            values['imageURL'], values['facebook'], values['instagram'],
            values['num_conselho'], snapshot.value['domingo'], snapshot.value['segunda'],
            snapshot.value['terca'], snapshot.value['quarta'], snapshot.value['quinta'],
            snapshot.value['sexta'], snapshot.value['sabado'], values['horarios'], values['assinante']);
        if(prof.email != null) {
          listaProfissional.add(prof);
        }
      });
//    }
    /*else {
      _nomeController.text = widget.paciente.nome;
      _emailController.text = widget.paciente.email;

      dbReference = db2.reference().child('atendimentos/pacientes');
      dbReference.onChildAdded.listen(_gravar);
      dbReference.onChildChanged.listen(_update);
      dbReference.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        Paciente paciente = new Paciente(
            values['nome'], values['telefone'], values['email'], values['imageURL'],
            values['data'], values['hora'], values['anotacao'], values['confirmado'],
            values['objetivo'], values['vegetariano'], values['bebidaAlcoolica'],
            values['fumante'], values['sedentario'], values['patologia'],
            values['nomePatologia'], values['medicamentos'], values['nomeMedicamentos'],
            values['alergia'], values['nomeAlergia'], values['sexo'], values['estadoCivil']
        );
        if(paciente.nome != null) {
          listaPacientes.add(paciente);
        }
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Profissional profissional = new Profissional(widget.profissional.nome, "",
        widget.profissional.email, "", widget.profissional.usuario,
        widget.profissional.imageURL, "", "",
        widget.profissional.num_conselho, widget.profissional.domingo, widget.profissional.segunda,
        widget.profissional.terca, widget.profissional.quarta,
        widget.profissional.quinta, widget.profissional.sexta,
        widget.profissional.sabado, null, widget.profissional.assinante);

    if (Platform.isIOS) {
      distancia = AppBar().preferredSize.height + 60;
    } else {
      distancia = AppBar().preferredSize.height + 40;
    }

    return Scaffold(
      key: _scaffoldKey,
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
                image: AssetImage("assets/images/imglogin.jpg"),
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
//                      widget.tipo == 'profissional' ?
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: distancia
                            ),
                            Flexible(
                              child: ListTile(
                                leading: Icon(Icons.account_box, color: Colors.white),
                                title: TextFormField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                  readOnly: false,
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
                                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                  tel = '${phone.dialCode.toString()}' + '${_telefoneController.text}';
                                },
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                  Icons.alternate_email, color: Colors.white),
                              title: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                readOnly: false,
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                face.length < 25
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                insta.length < 26
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
                                  hintText: "https://www.instagram.com/nomedeusuario",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                  Icons.work, color: Colors.white),
                              title: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                controller: _num_conselhoController,
                                onSaved: (registro_profissional) => profissional.num_conselho
                                = registro_profissional,
                                validator: (registro_profissional) =>
                                registro_profissional.length < 8
                                    ? "Digite seu número do registro profissional."
                                    : null,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    profissional.num_conselho = _num_conselhoController.text.toString();
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
                                  hintText: "CRM XXXXX - MS",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                  labelText: "Registro profissional",
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                              leading: Icon(Icons.today, color: Colors.white),
                              title: Container(
                                height: 40,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        diasEscolhidos[0] == false && diasEscolhidos[1] == false
                                            && diasEscolhidos[2] == false && diasEscolhidos[3] == false
                                            && diasEscolhidos[4] == false && diasEscolhidos[5] == false
                                            && diasEscolhidos[6] == false
                                            ? 'Defina os dias'
                                            : 'Dias definidos',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                                        ),
                                      ),
                                    ),
                                    FlatButton(
                                      color: Colors.black,
                                      child: Text(
                                        'Definir dias',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/60,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                              style: BorderStyle.solid
                                          ),
                                          borderRadius: BorderRadius.circular(40)
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showDialog(context);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.alarm_on, color: Colors.white),
                              title: Container(
                                height: 40,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        horasEscolhidas.isEmpty
                                            ? 'Defina seus horários'
                                            : 'Horários definidos',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                                        ),
                                      ),
                                    ),
                                    FlatButton(
                                      color: Colors.black,
                                      textColor: Colors.white,
                                      child: Text(
                                        'Definir horários',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/60,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                              style: BorderStyle.solid
                                          ),
                                          borderRadius: BorderRadius.circular(40)
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _dialogHorarios(context);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlatButton(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                      style: BorderStyle.solid
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Text(
                                  "Cadastrar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    if (diasEscolhidos[0] == false && diasEscolhidos[1] == false
                                        && diasEscolhidos[2] == false && diasEscolhidos[3] == false
                                        && diasEscolhidos[4] == false && diasEscolhidos[5] == false
                                        && diasEscolhidos[6] == false) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) =>
                                          _scaffoldKey.currentState
                                              .showSnackBar(
                                              SnackBar(
                                                duration: Duration(
                                                    seconds: 2),
                                                content: Text(
                                                  'Você deve definir seus dias de trabalho.',
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
                                                behavior: SnackBarBehavior
                                                    .floating,
                                              )
                                          )
                                      );
                                      return;
                                    }

                                    if (horasEscolhidas.isEmpty) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) =>
                                          _scaffoldKey.currentState
                                              .showSnackBar(
                                              SnackBar(
                                                duration: Duration(
                                                    seconds: 2),
                                                content: Text(
                                                  'Você deve definir seus horários de trabalho.',
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
                                                behavior: SnackBarBehavior
                                                    .floating,
                                              )
                                          )
                                      );
                                      return;
                                    }

                                    if(profissional.facebook.length < 25) {
                                      profissional.facebook = 'https://www.facebook.com/';
                                    }

                                    if(profissional.instagram.length < 26) {
                                      profissional.instagram = 'https://www.instagram.com/';
                                    }

                                    if (formKey.currentState.validate()) {
                                      formKey.currentState.save();
                                      Profissional pro = new Profissional(
                                          profissional.nome,
                                          tel,
                                          profissional.email,
                                          profissional.areaAtuacao,
                                          profissional.usuario,
                                          profissional.imageURL,
                                          profissional.facebook,
                                          profissional.instagram,
                                          profissional.num_conselho,
                                          domingo,
                                          segunda,
                                          terca,
                                          quarta,
                                          quinta,
                                          sexta,
                                          sabado,
                                          horasEscolhidas,
                                          false);

                                      _submit(pro);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                      /*:
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                                height: distancia
                            ),
                            Flexible(
                              child: ListTile(
                                leading: Icon(
                                    Icons.account_box, color: Colors.white),
                                title: TextFormField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery
                                        .of(context)
                                        .size
                                        .width > 600 && MediaQuery
                                        .of(context)
                                        .size
                                        .width < 1000 ? MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50 : MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50,
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
                                  readOnly: widget.paciente.nome.isEmpty ||
                                      widget.paciente.nome == null ? false : true,
                                  controller: _nomeController,
                                  onSaved: (nome) => paciente.nome = nome,
                                  validator: (nome) =>
                                  nome.length < 3
                                      ? "Deve ter ao menos 3 caracteres."
                                      : null,
                                  cursorColor: Theme
                                      .of(context)
                                      .accentColor,
                                  onFieldSubmitted: (_) {
                                    setState(() {
                                      paciente.nome = _nomeController.text.toString();
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
                                      borderRadius: new BorderRadius.circular(
                                          8.0),
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 2.0),
                                    ),
                                    hintText: "Nome completo",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery
                                          .of(context)
                                          .size
                                          .width > 600 && MediaQuery
                                          .of(context)
                                          .size
                                          .width < 1000 ? MediaQuery
                                          .of(context)
                                          .size
                                          .height / 50 : MediaQuery
                                          .of(context)
                                          .size
                                          .height / 50,
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
                                      fontSize: MediaQuery
                                          .of(context)
                                          .size
                                          .width > 600 && MediaQuery
                                          .of(context)
                                          .size
                                          .width < 1000 ? MediaQuery
                                          .of(context)
                                          .size
                                          .height / 50 : MediaQuery
                                          .of(context)
                                          .size
                                          .height / 50,
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
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 3.0),
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
                                  fontSize: MediaQuery
                                      .of(context)
                                      .size
                                      .width > 600 && MediaQuery
                                      .of(context)
                                      .size
                                      .width < 1000 ? MediaQuery
                                      .of(context)
                                      .size
                                      .height / 50 : MediaQuery
                                      .of(context)
                                      .size
                                      .height / 50,
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
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(
                                        8.0),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  hintText: "xx xxxxx xxxx",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery
                                        .of(context)
                                        .size
                                        .width > 600 && MediaQuery
                                        .of(context)
                                        .size
                                        .width < 1000 ? MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50 : MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50,
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
                                    fontSize: MediaQuery
                                        .of(context)
                                        .size
                                        .width > 600 && MediaQuery
                                        .of(context)
                                        .size
                                        .width < 1000 ? MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50 : MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50,
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
                                    new BorderSide(
                                        color: Colors.red, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                countries: ['BR'],
                                //, 'PT', 'US', 'GB-NIR', 'ES', 'GB'],
                                locale: 'BR',
                                onInputChanged: (phone) {
                                  tel = '${phone.dialCode.toString()}' +
                                      '${_telefoneController.text}';
                                },
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                  Icons.alternate_email, color: Colors.white, ),
                              title: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery
                                      .of(context)
                                      .size
                                      .width > 600 && MediaQuery
                                      .of(context)
                                      .size
                                      .width < 1000 ? MediaQuery
                                      .of(context)
                                      .size
                                      .height / 50 : MediaQuery
                                      .of(context)
                                      .size
                                      .height / 50,
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
                                readOnly: widget.paciente.email.isEmpty ||
                                  widget.paciente.email == null ? false : true,
                                controller: _emailController,
                                onSaved: (email) => paciente.email = email,
                                validator: validateEmail,
                                cursorColor: Theme
                                    .of(context)
                                    .accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    paciente.email =
                                        _emailController.text.toString();
                                  });
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(
                                        8.0),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  hintText: "Digite seu e-mail",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery
                                        .of(context)
                                        .size
                                        .width > 600 && MediaQuery
                                        .of(context)
                                        .size
                                        .width < 1000 ? MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50 : MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50,
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
                                    fontSize: MediaQuery
                                        .of(context)
                                        .size
                                        .width > 600 && MediaQuery
                                        .of(context)
                                        .size
                                        .width < 1000 ? MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50 : MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50,
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
                                    const BorderSide(
                                        color: Colors.red, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                  Icons.adjust, color: Colors.white),
                              title: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery
                                      .of(context)
                                      .size
                                      .width > 600 && MediaQuery
                                      .of(context)
                                      .size
                                      .width < 1000 ? MediaQuery
                                      .of(context)
                                      .size
                                      .height / 50 : MediaQuery
                                      .of(context)
                                      .size
                                      .height / 50,
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
                                readOnly: false,
                                controller: _estadoCivilController,
                                onSaved: (estadoCivil) => paciente.estadoCivil = estadoCivil,
                                validator: (estadoCivil) =>
                                estadoCivil.length < 3
                                    ? "Não pode ficar em branco."
                                    : null,
                                cursorColor: Theme
                                    .of(context)
                                    .accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    paciente.estadoCivil =
                                        _estadoCivilController.text.toString();
                                  });
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(
                                        8.0),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  hintText: "Seu estado civil",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery
                                        .of(context)
                                        .size
                                        .width > 600 && MediaQuery
                                        .of(context)
                                        .size
                                        .width < 1000 ? MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50 : MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50,
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
                                    fontSize: MediaQuery
                                        .of(context)
                                        .size
                                        .width > 600 && MediaQuery
                                        .of(context)
                                        .size
                                        .width < 1000 ? MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50 : MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50,
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
                                    const BorderSide(
                                        color: Colors.red, width: 3.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            Radio(
                              value: 'Feminino',
                              activeColor: Colors.cyanAccent,
                              groupValue: sexo,
                              onChanged: (val) {
                                setState(() {
                                  sexo = 'Feminino';
                                });
                              },
                            ),
                            Text(
                              'Feminino',
                              style: new TextStyle(
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                  color: Colors.white,
                                  fontFamily: 'quicksand',
                                  shadows: [
                                    Shadow( // bottomLeft
                                        offset: Offset(-0.5, -0.5),
                                        color: Colors.black
                                    ),
                                    Shadow( // bottomRight
                                        offset: Offset(0.5, -0.5),
                                        color: Colors.black
                                    ),
                                    Shadow( // topRight
                                        offset: Offset(0.5, 0.5),
                                        color: Colors.black
                                    ),
                                    Shadow( // topLeft
                                        offset: Offset(-0.5, 0.5),
                                        color: Colors.black
                                    ),
                                  ]
                              ),
                            ),
                            Radio(
                              value: 'Masculino',
                              groupValue: sexo,
                              activeColor: Colors.cyanAccent,
                              onChanged: (val) {
                                setState(() {
                                  sexo = 'Masculino';
                                });
                              },
                            ),
                            Text(
                              'Masculino',
                              style: new TextStyle(
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                  color: Colors.white,
                                  fontFamily: 'quicksand',
                                  shadows: [
                                    Shadow( // bottomLeft
                                        offset: Offset(-0.5, -0.5),
                                        color: Colors.black
                                    ),
                                    Shadow( // bottomRight
                                        offset: Offset(0.5, -0.5),
                                        color: Colors.black
                                    ),
                                    Shadow( // topRight
                                        offset: Offset(0.5, 0.5),
                                        color: Colors.black
                                    ),
                                    Shadow( // topLeft
                                        offset: Offset(-0.5, 0.5),
                                        color: Colors.black
                                    ),
                                  ]
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlatButton(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                      style: BorderStyle.solid
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Text(
                                  "Cadastrar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery
                                        .of(context)
                                        .size
                                        .width > 600 && MediaQuery
                                        .of(context)
                                        .size
                                        .width < 1000 ? MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50 : MediaQuery
                                        .of(context)
                                        .size
                                        .height / 50,
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
                                      Paciente paciente = new Paciente(
                                          _nomeController.text.toString(),
                                          tel,
                                          _emailController.text.toString(),
                                          widget.paciente.imageURL,
                                          "",
                                          "",
                                          "",
                                          true, "", false, false, false, false, false,
                                          "", false, "", false, "", sexo,
                                          _estadoCivilController.text.toString());

                                      _submitPaciente(paciente);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),*/
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
//    if(widget.tipo == 'profissional') {
      setState(() {
        listaProfissional.add(Profissional.fromSnapshot(event.snapshot));
      });
    /*} else {
      setState(() {
        listaPacientes.add(Paciente.fromSnapshot(event.snapshot));
      });
    }*/
  }

  /*void _update(Event event) {
//    if(widget.tipo == 'profissional') {
      var oldEntry = listaProfissional.singleWhere((entry) {
        return entry.primaryKey == event.snapshot.key;
      });

      setState(() {
        listaProfissional[listaProfissional.indexOf(oldEntry)] =
            Profissional.fromSnapshot(event.snapshot);
      });
    *//*} else {
      var oldEntry = listaPacientes.singleWhere((entry) {
        return entry.primaryKey == event.snapshot.key;
      });

      setState(() {
        listaPacientes[listaPacientes.indexOf(oldEntry)] =
            Paciente.fromSnapshot(event.snapshot);
      });
    }*//*
  }*/

  void _submit(Profissional profissional) async {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      listaProfissional.add(profissional);
      //cria novo paciente a cada push
      dbReference.push().set(profissional.toJson());
    }

    form.reset();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
        FirstScreen(tipo: 'profissional', presente: true,)));
    print('============== C A D A S T R A D O ==================');
//    Navigator.of(context).pop();
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

  void _showDialog(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState)
            {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                contentPadding: EdgeInsets.all(6.0),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          "Dias de trabalho",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 50,
                              fontFamily: 'quicksand'
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        height: 1.0,
                      ),
                      Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height / 4,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: diasEscolhidos.length,
                          itemBuilder: (BuildContext context, int posicao) {
                            return diasEscolhidos[posicao] == false ?
                            ListTile(
                                title: FlatButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ListTile(
                                    title: Text(posicao == 0 ? 'Domingo' : posicao == 1 ?
                                    'Segunda-feira' : posicao == 2 ? 'Terça-feira' :
                                    posicao == 3 ? 'Quarta-feira' : posicao == 4 ? 'Quinta-feira' :
                                    posicao == 5 ? 'Sexta-feira' : posicao == 6 ? 'Sábado' : '',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 10, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color: Colors.transparent), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      mudarDia(posicao);
                                    });
                                  },
                                )
                            )
                                :
                            ListTile(
                                title: FlatButton(
                                  color: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ListTile(
                                    title: Text(posicao == 0 ? 'Domingo' : posicao == 1 ?
                                    'Segunda-feira' : posicao == 2 ? 'Terça-feira' :
                                    posicao == 3 ? 'Quarta-feira' : posicao == 4 ? 'Quinta-feira' :
                                    posicao == 5 ? 'Sexta-feira' : posicao == 6 ? 'Sábado' : '',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color: Colors.green), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      removerDia(posicao);
                                    });
                                  },
                                )
                            );
                          },
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        height: 1.0,
                      ),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid
                            ),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        onPressed: () {
                          setState(() {
                            Navigator.of(context).pop();
                          });
                        },
                        color: Colors.black,
                        child: Text('OK',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'quicksand'
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void _dialogHorarios(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState)
            {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                contentPadding: EdgeInsets.all(6.0),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          "Meus horários",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 50,
                              fontFamily: 'quicksand'
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        height: 1.0,
                      ),
                      Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height / 4,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: horas.length,
                          itemBuilder: (BuildContext context, int posicao) {
                            return horasEscolhidas.contains(horas[posicao]) == false ?
                            ListTile(
                                title: FlatButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ListTile(
                                    title: Text('${horas[posicao]}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color: Colors.transparent), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      definirHorario(horas[posicao]);
                                    });
                                  },
                                )
                            )
                                :
                            ListTile(
                                title: FlatButton(
                                  color: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ListTile(
                                    title: Text('${horas[posicao]}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color: Colors.green), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      removerHorario(horas[posicao]);
                                    });
                                  },
                                )
                            );
                          },
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        height: 1.0,
                      ),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid
                            ),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        onPressed: () {
                          setState(() {
                            Navigator.of(context).pop();
                          });
                        },
                        color: Colors.black,
                        child: Text('OK',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'quicksand'
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void mudarDia(int posicao) {
    setState(() {
      diasEscolhidos[posicao] = true;
      if(posicao == 0) {
        domingo = diasEscolhidos[posicao];
      } else if (posicao == 1) {
        segunda = diasEscolhidos[posicao];
      } else if (posicao == 2) {
        terca = diasEscolhidos[posicao];
      } else if (posicao == 3) {
        quarta = diasEscolhidos[posicao];
      } else if (posicao == 4) {
        quinta = diasEscolhidos[posicao];
      } else if (posicao == 5) {
        sexta = diasEscolhidos[posicao];
      } else if (posicao == 6) {
        sabado = diasEscolhidos[posicao];
      }
    });
  }

  void removerDia(int posicao) {
    setState(() {
      diasEscolhidos[posicao] = false;
      if(posicao == 0) {
        domingo = diasEscolhidos[posicao];
      } else if (posicao == 1) {
        segunda = diasEscolhidos[posicao];
      } else if (posicao == 2) {
        terca = diasEscolhidos[posicao];
      } else if (posicao == 3) {
        quarta = diasEscolhidos[posicao];
      } else if (posicao == 4) {
        quinta = diasEscolhidos[posicao];
      } else if (posicao == 5) {
        sexta = diasEscolhidos[posicao];
      } else if (posicao == 6) {
        sabado = diasEscolhidos[posicao];
      }
    });
  }


  void definirHorario(String horario) {
    if(!horasEscolhidas.contains(horario)) {
      horasEscolhidas.add(horario);
    }
  }

  void removerHorario(String horario) {
    if(horasEscolhidas.contains(horario)) {
      horasEscolhidas.remove(horario);
    }
  }
}