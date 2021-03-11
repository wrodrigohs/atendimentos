import 'package:atendimentos/model/profissional.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'dart:ui' as ui;

import '../model/paciente.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;

class Edicao extends StatefulWidget {
  Paciente paciente;
  Profissional profissional;

  Edicao({Key key, @required this.paciente, @required this.profissional}) : super(key: key);

  @override
  _EdicaoState createState() => _EdicaoState();

}

class _EdicaoState extends State<Edicao> {

  List<Paciente> listaPacientes = new List();
  DatabaseReference dbReference;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _anotacaoController = TextEditingController();

  DateTime _dataEscolhida;
  String dataString;
  String horaSelecionada;
  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String anotacao;
  bool confirmar;
  TimeOfDay _time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    for(int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
    }

    confirmar = widget.paciente.confirmado;
    _anotacaoController.text = widget.paciente.anotacao;
    dataString = widget.paciente.data;
    horaSelecionada = widget.paciente.hora;

    dbReference = db.reference().child('atendimentos/${widget.profissional.usuario}/pacientes');
    dbReference.onChildAdded.listen(_gravar);
    dbReference.onChildChanged.listen(_update);
    dbReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      Paciente paciente = new Paciente(
          values['nome'], values['telefone'], values['email'],
          values['data'], values['hora'], values['anotacao'], values['confirmado'],
          values['objetivo'], values['vegetariano'], values['bebidaAlcoolica'],
          values['fumante'], values['sedentario'], values['patologia'],
          values['nomePatologia'], values['medicamentos'], values['nomeMedicamentos'],
          values['alergia'], values['nomeAlergia'], values['sexo'], values['estadoCivil']
      );
      listaPacientes.add(paciente);
    });
    //listaPacientes.add(widget.paciente);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    double distancia = AppBar().preferredSize.height + 40;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Dados de ${widget.paciente.nome}',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'quicksand',
                  //fontSize: MediaQuery.of(context).size.height/50,
                ),
              ),
              backgroundColor: Color(0x44000000),
              elevation: 0.0,
              centerTitle: true,
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/imglogin.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          height: distancia,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            // leading: Icon(Icons.account_box, color: Colors.white),
                              title: Text('${widget.paciente.nome}',
                                style: TextStyle(
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
                                    ],
                                  fontSize: MediaQuery.of(context).size.height/50,
                                ),
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            // leading: Icon(Icons.phone, color: Colors.white),
                            title: Text('${widget.paciente.telefone}',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery.of(context).size.height/50,
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
                                ],
                              ),
                            ),
                            onTap: () => launch("tel://${widget.paciente.telefone}"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            //leading: Icon(Icons.alternate_email, color: Colors.white),
                            title: Text('${widget.paciente.email}',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery.of(context).size.height/50,
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
                                ],
                              ),
                            ),
                            onTap: () => launch("mailto:${widget.paciente.email}?subject=&body="),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            //leading: Icon(Icons.alternate_email, color: Colors.white),
                            title: Text('Estado civil: ${widget.paciente.estadoCivil}',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery.of(context).size.height/50,
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
                                ],
                              ),
                            ),
                            onTap: () => launch("mailto:${widget.paciente.email}?subject=&body="),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            //leading: Icon(Icons.alternate_email, color: Colors.white),
                            title: Text('Sexo: ${widget.paciente.sexo}',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery.of(context).size.height/50,
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        equalsIgnoreCase(widget.profissional.areaAtuacao, 'nutrição') ?
                        Visibility(
                          visible: true,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    //leading: Icon(Icons.alternate_email, color: Colors.white),
                                    title: Text('Objetivo: ${widget.paciente.objetivo}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    //leading: Icon(Icons.alternate_email, color: Colors.white),
                                    title: Text(widget.paciente.vegetariano == false ? 'É vegetariano/vegano? Não' : 'É vegetariano/vegano? Sim',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    //leading: Icon(Icons.alternate_email, color: Colors.white),
                                    title: Text(widget.paciente.bebidaAlcoolica == false ? 'Ingere bebida alcoólica? Não' : 'Ingere bebida alcoólica? Sim',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    //leading: Icon(Icons.alternate_email, color: Colors.white),
                                    title: Text(widget.paciente.fumante == false ? 'Fuma? Não' : 'Fuma? Sim',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(widget.paciente.sedentario == false ? 'Pratica atividade física? Não' : 'Pratica atividade física? Sim',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(widget.paciente.patologia == false ? 'Tem alguma patologia? Não' :
                                    'Tem alguma patologia? Sim. ${widget.paciente.nomePatologia}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(widget.paciente.medicamentos == false ? 'Faz uso de algum medicamento? Não' :
                                    'Faz uso de algum medicamento? Sim. ${widget.paciente.nomeMedicamentos}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(widget.paciente.alergia == false ? 'Alguma alergia? Não' :
                                    'Alguma alergia? Sim. ${widget.paciente.nomeAlergia}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        )
                            :
                        Container(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(Icons.date_range, color: Colors.white),
                            title: Container(
                              height: 40,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(_dataEscolhida == null
                                        ? '${widget.paciente.data}'
                                        : '${DateFormat.d().format(
                                        _dataEscolhida)}/${DateFormat.M().format(
                                        _dataEscolhida)}/${DateFormat.y().format(
                                        _dataEscolhida)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Nova data',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/55,
                                      ),
                                    ),
                                    color: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.white,
                                            width: 1,
                                            style: BorderStyle.solid
                                        ),
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _presentDatePicker();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(Icons.alarm, color: Colors.white),
                            title: Container(
                              height: 40,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      horaSelecionada == null ? '${widget.paciente.hora}' : '$horaSelecionada',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Novo horário',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/55,
                                      ),
                                    ),
                                    color: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.white,
                                            width: 1,
                                            style: BorderStyle.solid
                                        ),
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showDialog(context, dataString);
                                      });
                                    },
                                  ),
                                ],
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
                                    color: Colors.white,
                                    width: 1,
                                    style: BorderStyle.solid
                                ),
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              "Atualizar dados",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery.of(context).size.height/55,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                if(dataString == "" || dataString == null) {
                                  dataString = widget.paciente.data;
                                }

                                if(horaSelecionada == "" || horaSelecionada == null) {
                                  horaSelecionada = widget.paciente.hora;
                                }

                                anotacao = _anotacaoController.text.toString();

                                Paciente pacienteAtualizado = new Paciente(
                                    widget.paciente.nome,
                                    widget.paciente.telefone,
                                    widget.paciente.email,
                                    dataString,
                                    horaSelecionada,
                                    anotacao,
                                    true,
                                    widget.paciente.objetivo,
                                    widget.paciente.vegetariano,
                                    widget.paciente.bebidaAlcoolica,
                                    widget.paciente.fumante,
                                    widget.paciente.sedentario,
                                    widget.paciente.patologia,
                                    widget.paciente.nomePatologia,
                                    widget.paciente.medicamentos,
                                    widget.paciente.nomeMedicamentos,
                                    widget.paciente.alergia,
                                    widget.paciente.nomeAlergia,
                                    widget.paciente.sexo,
                                    widget.paciente.estadoCivil
                                );
                                atualizarPaciente(pacienteAtualizado);

                                //Navigator.of(context).pop();
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
          )
        ],
      ),
    );
  }

  bool equalsIgnoreCase(String a, String b) =>
      (a == null && b == null) || (a != null && b != null && a.toLowerCase() == b.toLowerCase());

  void _gravar(Event event) {
    setState(() {
      listaPacientes.add(Paciente.fromSnapshot(event.snapshot));
    });
  }

  void _update(Event event) {
    var oldEntry = listaPacientes.singleWhere((entry) {
      return entry.primaryKey == event.snapshot.key;
    });

    setState(() {
      listaPacientes[listaPacientes.indexOf(oldEntry)] =
          Paciente.fromSnapshot(event.snapshot);
    });
  }

  void updatePaciente(Paciente paciente) {
    if (paciente != null) {
      dbReference.child('${paciente.primaryKey}').set(paciente.toJson());
    }
  }

  void atualizarPaciente(Paciente paciente) async {
    await dbReference.child(widget.paciente.primaryKey).update({
      "nome" : paciente.nome,
      "telefone" : paciente.telefone,
      "email" : paciente.email,
      "data" : paciente.data,
      "hora" : paciente.hora,
      "anotacao" : paciente.anotacao,
      "confirmado" : paciente.confirmado
    }).then((_) {
      //print('Transaction  committed.');
    });
    Navigator.of(context).pop();
  }

  void _showDialog(BuildContext context, String dataString) async {
    List<String> horas = ['08:00h', '08:30h', '09:00h', '09:30h', '10:00h', '10:30h', '11:00h', '11:30h',
      '12:00h', '12:30h', '13:00h', '13:30h', '14:00h', '14:30h', '15:00h', '15:30h',
      '16:00h', '16:30h', '17:00h', '17:30h', '18:00h', '18:30h', '19:00h', '19:30h', '20:00h'];
    if(listaPacientes.isNotEmpty) {
      for (int i = 0; i < listaPacientes.length; i++) {
        if (((listaPacientes[i].data) == widget.paciente.data)) {
          if(horas.contains(listaPacientes[i].hora)) {
            horas.remove('${listaPacientes[i].hora}');
          }
        }
      }
    }

    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            contentPadding: EdgeInsets.all(8.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    child: Text(
                      "Horários disponíveis",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: MediaQuery.of(context).size.height/50,
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
                    height: MediaQuery.of(context).size.height/4,
                    width: MediaQuery.of(context).size.width/3.5,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: horas.length,
                      itemBuilder: (BuildContext context, int posicao) {
                        return ListTile(
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
                              child: Text('${horas[posicao]}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'quicksand'
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  horaSelecionada = horas[posicao];

                                  WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text('Escolheu ${horas[posicao]}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontSize: MediaQuery.of(context).size.height/50,
                                          ),
                                        ),
                                        backgroundColor: Colors.black,
                                        behavior: SnackBarBehavior.floating,
                                      )
                                  )
                                  );
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
        });
  }

  void _presentDatePicker() {
    DateTime now = DateTime.now();
    DateTime currentTime = new DateTime(now.year);
    DateTime nextYear = new DateTime(now.year + 2);
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),//now.weekday == 6 || now.weekday == 7 ? now.add(new Duration(days: 2)) : now,//|| now.weekday == 7 ? false : true,//checarFDS(), //initialvalue NÃO pode ser sábado ou domingo porque
      //CONFLITA com o selectableDayPredicate e causa erro
      firstDate: DateTime.now().subtract(new Duration(days: 0)),
      lastDate: nextYear,
      //selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true, //exclui sábado e domingo
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            //primaryColor: Color(0xFFFFFFFF),
            //accentColor: Color(0xFFFFFFFF),
            colorScheme: ColorScheme.dark(primary: Color(0xFFFFFFFF)),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      } else {
        setState(() {
          _dataEscolhida = pickedDate;
          dataString = dateFormat.format(_dataEscolhida);
          return dataString;
        });
      }
    });
    //return formattedDate;
  }
}