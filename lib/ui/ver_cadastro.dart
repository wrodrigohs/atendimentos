import 'dart:developer';

import 'package:atendimentos/model/profissional.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'dart:ui' as ui;

final FirebaseDatabase db = FirebaseDatabase.instance;

class EditarCadastro extends StatefulWidget {
  Profissional profissional;
  EditarCadastro({Key key, this.profissional}) : super(key: key);

  @override
  _EditarCadastroState createState() => _EditarCadastroState();
}

class _EditarCadastroState extends State<EditarCadastro> {
  Profissional prof = new Profissional('', '', '', '', '', '', '', '', '', false, false, false,
      false, false, false, false, null, false);
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

  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String paisOrigem = 'BR';
  String facebook;
  String instagram;
  String tel;
  List<bool> diasEscolhidos = List();
  List<dynamic> horasEscolhidas = List();

  bool domingo = false;
  bool segunda = false;
  bool terca = false;
  bool quarta = false;
  bool quinta = false;
  bool sexta = false;
  bool sabado = false;

  List<String> horas = ['07:00h', '07:30h', '08:00h', '08:30h', '09:00h', '09:30h', '10:00h',
    '10:30h', '11:00h', '11:30h', '12:00h', '12:30h', '13:00h', '13:30h', '14:00h', '14:30h',
    '15:00h', '15:30h', '16:00h', '16:30h', '17:00h', '17:30h', '18:00h', '18:30h', '19:00h',
    '19:30h', '20:00h', '20:30h', '21:00h', '21:30h', '22:00h'];

  @override
  void initState() {
    super.initState();

    for(int i = 0; i < listaProfissional.length; i++) {
      listaProfissional.removeAt(i);
    }

    diasEscolhidos.add(widget.profissional.domingo);
    diasEscolhidos.add(widget.profissional.segunda);
    diasEscolhidos.add(widget.profissional.terca);
    diasEscolhidos.add(widget.profissional.quarta);
    diasEscolhidos.add(widget.profissional.quinta);
    diasEscolhidos.add(widget.profissional.sexta);
    diasEscolhidos.add(widget.profissional.sabado);

    for(int i = 0; i < widget.profissional.horarios.length; i++) {
      if(!horasEscolhidas.contains(widget.profissional.horarios[i])) {
        horasEscolhidas.add(widget.profissional.horarios[i]);
      }
    }

    prof = widget.profissional;

    _nomeController.text = widget.profissional.nome;
    String telefone = widget.profissional.telefone.replaceAll(new RegExp(r"\s+"), "");
    telefone = telefone.replaceAll(new RegExp(r"-"), "");
    _telefoneController.text = telefone.substring(3, telefone.length);
    _emailController.text = widget.profissional.email;
    _areaAtuacaoController.text = widget.profissional.areaAtuacao;
    _facebookController.text = widget.profissional.facebook;
    _instagramController.text = widget.profissional.instagram;
    _num_conselhoController.text = widget.profissional.num_conselho;

    dbReference = db.reference().child('atendimentos');
    dbReference.onChildAdded.listen(_gravar);
    dbReference.onChildChanged.listen(_update);
    dbReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      Profissional pro = new Profissional(
          values['nome'], values['telefone'], values['email'],
          values['areaAtuacao'], values['usuario'], values['imageURL'],
          values['facebook'], values['instagram'], values['num_conselho'],
          snapshot.value['domingo'], snapshot.value['segunda'], snapshot.value['terca'],
          snapshot.value['quarta'], snapshot.value['quinta'], snapshot.value['sexta'],
          snapshot.value['sabado'], values['horarios'], values['confirmado']);
      if(pro.nome == widget.profissional.nome) {
        listaProfissional.add(pro);
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    for(int i = 0; i < listaProfissional.length; i++) {
      for(int j = i + 1; j < listaProfissional.length; j++) {
        if(listaProfissional[i].nome == listaProfissional[j].nome) {
          listaProfissional.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaProfissional.length; i++) {
      for(int j = i + 1; j < listaProfissional.length; j++) {
        if(listaProfissional[i].nome == listaProfissional[j].nome) {
          listaProfissional.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaProfissional.length; i++) {
      for(int j = i + 1; j < listaProfissional.length; j++) {
        if(listaProfissional[i].nome == listaProfissional[j].nome) {
          listaProfissional.removeAt(j);
        }
      }
    }

    /*for(int i = 0; i < listaProfissional.length; i++) {
      if(listaProfissional[i].nome == widget.profissional.nome) {
        prof = listaProfissional[i];
        break;
      }
    }*/

    return Scaffold(
      body: Stack(children: <Widget>[
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Color(0x44000000),
            elevation: 0.0,
            centerTitle: true,
            title: Text('Editar cadastro',
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
                                  controller: _nomeController,
                                  onSaved: (nome) => prof.nome = nome,
                                  validator: (nome) =>
                                  nome.length < 3
                                      ? "Deve ter ao menos 3 caracteres."
                                      : null,
                                  cursorColor: Theme.of(context).accentColor,
                                  onFieldSubmitted: (_) {
                                    setState(() {
                                      prof.nome = _nomeController.text.toString();
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
                                controller: _emailController,
                                onSaved: (email) => prof.email = email,
                                validator: validateEmail,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    prof.email = _emailController.text.toString();
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
                                onSaved: (area) => prof.areaAtuacao = area,
                                validator: (area) =>
                                area.length < 1
                                    ? "Não pode ficar em branco"
                                    : null,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    prof.areaAtuacao = _areaAtuacaoController.text.toString();
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
                                onSaved: (face) => prof.facebook = face,
                                validator: (face) =>
                                face.length < 25
                                    ? "Digite seu facebook."
                                    : null,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    prof.facebook = _facebookController.text.toString();
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
                                onSaved: (insta) => prof.instagram = insta,
                                validator: (insta) =>
                                insta.length < 26
                                    ? "Digite seu instagram."
                                    : null,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    prof.instagram = _instagramController.text.toString();
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
                                onSaved: (registro_profissional) => prof.num_conselho
                                = registro_profissional,
                                validator: (registro_profissional) =>
                                registro_profissional.length < 5
                                    ? "Digite seu número do registro profissional."
                                    : null,
                                cursorColor: Theme.of(context).accentColor,
                                onFieldSubmitted: (_) {
                                  setState(() {
                                    prof.num_conselho = _num_conselhoController.text.toString();
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
                                      textColor: Colors.white,
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
                                              color: Colors.black,
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
                                              color: Colors.black,
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
                                      color: Colors.black,
                                      width: 1,
                                      style: BorderStyle.solid
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Text(
                                  "Atualizar cadastro",
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

                                    if(prof.facebook.length < 25) {
                                      prof.facebook = 'https://www.facebook.com/';
                                    }

                                    if(prof.instagram.length < 26) {
                                      prof.instagram = 'https://www.instagram.com/';
                                    }

                                    if (formKey.currentState.validate()) {
                                      formKey.currentState.save();
                                      Profissional pro = new Profissional(
                                          prof.nome,
                                          tel,
                                          prof.email,
                                          prof.areaAtuacao,
                                          prof.usuario,
                                          prof.imageURL,
                                          prof.facebook,
                                          prof.instagram,
                                          prof.num_conselho,
                                          prof.domingo,
                                          prof.segunda,
                                          prof.terca,
                                          prof.quarta,
                                          prof.quinta,
                                          prof.sexta,
                                          prof.sabado,
                                          horasEscolhidas,
                                          false);

                                      atualizarProfissional(pro);
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

  void atualizarProfissional(Profissional profissional) async {
    await dbReference.child(widget.profissional.primaryKey).update({
      "nome" : profissional.nome,
      "telefone" : profissional.telefone,
      "email" : profissional.email,
      "areaAtuacao" : profissional.areaAtuacao,
      "usuario" : profissional.usuario,
      "imageURL" : profissional.imageURL,
      "facebook" : profissional.facebook,
      "instagram" : profissional.instagram,
      "num_conselho" : profissional.num_conselho,
      "domingo" : profissional.domingo,
      "segunda" : profissional.segunda,
      "terca" : profissional.terca,
      "quarta" : profissional.quarta,
      "quinta" : profissional.quinta,
      "sexta" : profissional.sexta,
      "sabado" : profissional.sabado,
      "horarios" : profissional.horarios,
      "assinante" : profissional.assinante
    }).then((_) {
      //print('Transaction  committed.');
    });
    Fluttertoast.showToast(
      msg: 'Dados atualizados com sucesso.',
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 5,
    );
//    Navigator.of(context).pop();
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
                            return !(horasEscolhidas.contains(horas[posicao])) ?
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
        prof.domingo = diasEscolhidos[posicao];
      } else if (posicao == 1) {
        prof.segunda = diasEscolhidos[posicao];
      } else if (posicao == 2) {
        prof.terca = diasEscolhidos[posicao];
      } else if (posicao == 3) {
        prof.quarta = diasEscolhidos[posicao];
      } else if (posicao == 4) {
        prof.quinta = diasEscolhidos[posicao];
      } else if (posicao == 5) {
        prof.sexta = diasEscolhidos[posicao];
      } else if (posicao == 6) {
        prof.sabado = diasEscolhidos[posicao];
      }
    });
  }

  void removerDia(int posicao) {
    setState(() {
      diasEscolhidos[posicao] = false;
      if(posicao == 0) {
        prof.domingo = diasEscolhidos[posicao];
      } else if (posicao == 1) {
        prof.segunda = diasEscolhidos[posicao];
      } else if (posicao == 2) {
        prof.terca = diasEscolhidos[posicao];
      } else if (posicao == 3) {
        prof.quarta = diasEscolhidos[posicao];
      } else if (posicao == 4) {
        prof.quinta = diasEscolhidos[posicao];
      } else if (posicao == 5) {
        prof.sexta = diasEscolhidos[posicao];
      } else if (posicao == 6) {
        prof.sabado = diasEscolhidos[posicao];
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