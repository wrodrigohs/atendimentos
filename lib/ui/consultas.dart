import 'dart:io';
import 'dart:ui' as ui;

import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;

class Consultas extends StatefulWidget {
  Paciente paciente;
  Profissional profissional;

  Consultas({Key key, this.paciente, this.profissional}) : super(key: key);

  @override
  _ConsultasState createState() => _ConsultasState();
}

class _ConsultasState extends State<Consultas> {
  Paciente paciente;
  DatabaseReference dbReference;
  // List<DataPaciente> listaDt = List();
  List<Paciente> listaPacientes = List();
  List<Paciente> listaBuscado = List();
  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');

  @override
  void initState() {
    super.initState();

    /*for (int i = 0; i < listaDt.length; i++) {
      listaDt.removeAt(i);
    }*/

    for (int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
    }

    paciente = new Paciente("", "", "", "", "", "", "", false, "", false, false, false, false, false, "", false, "", false, "", "", "");
    dbReference = db.reference().child('atendimentos/${widget.profissional.usuario}/pacientes');
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
  }

  @override
  Widget build(BuildContext context) {

    /*for (int i = 0; i < listaDt.length; i++) {
      DataPaciente dt_pac = new DataPaciente(listaPacientes[i].primaryKey, listaPacientes[i].nome, listaPacientes[i].telefone,
          listaPacientes[i].email, converterData(listaPacientes[i].data), listaPacientes[i].hora,
          listaPacientes[i].anotacao, listaPacientes[i].confirmado, listaPacientes[i].objetivo,
          listaPacientes[i].vegetariano, listaPacientes[i].bebidaAlcoolica,
          listaPacientes[i].fumante, listaPacientes[i].sedentario,
          listaPacientes[i].patologia, listaPacientes[i].nomePatologia,
          listaPacientes[i].medicamentos, listaPacientes[i].nomeMedicamentos,
          listaPacientes[i].alergia, listaPacientes[i].nomeAlergia,
          listaPacientes[i].sexo, listaPacientes[i].estadoCivil);
      listaDt.remove(dt_pac);
      listaDt.removeAt(i);
    }

    for(int i = 0; i < listaPacientes.length; i++) {
      DataPaciente dt_pac = new DataPaciente(listaPacientes[i].primaryKey, listaPacientes[i].nome, listaPacientes[i].telefone,
          listaPacientes[i].email, converterData(listaPacientes[i].data), listaPacientes[i].hora,
          listaPacientes[i].anotacao, listaPacientes[i].confirmado, listaPacientes[i].objetivo,
          listaPacientes[i].vegetariano, listaPacientes[i].bebidaAlcoolica,
          listaPacientes[i].fumante, listaPacientes[i].sedentario,
          listaPacientes[i].patologia, listaPacientes[i].nomePatologia,
          listaPacientes[i].medicamentos, listaPacientes[i].nomeMedicamentos,
          listaPacientes[i].alergia, listaPacientes[i].nomeAlergia,
          listaPacientes[i].sexo, listaPacientes[i].estadoCivil);
      listaDt.add(dt_pac);
    }*/

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    DateTime hoje = DateTime.now();
    String d1 = formatarData(hoje);
    DateTime data = converterData(d1);

    for(int i = 0; i < listaPacientes.length; i++) {
      if(equalsIgnoreCase(listaPacientes[i].data, d1) == true) {
        listaBuscado.add(listaPacientes[i]);
      }
    }

    listaBuscado.sort((a, b) => ((a.hora).compareTo(b.hora)));
    double distancia = AppBar().preferredSize.height + 40;

    return Scaffold(
      body: Stack(
        children: <Widget>[
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Color(0x44000000),
            elevation: 0.0,
            centerTitle: true,
            title: Text('Atendimentos de hoje',
                style: TextStyle(
                    fontFamily: 'quicksand'
                )
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
                  listaBuscado.isEmpty ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: distancia,
                      ),
                      Text('Nenhum atendimento marcado para hoje',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            inherit: false,
                            fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/45,
                            fontFamily: 'quicksand',
                            color: Colors.white,
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
                      Lottie.asset(
                        'assets/images/sad.json',
                        animate: true,
                        repeat: true,
                        reverse: true,
                        width: 200,
                        height: 200,
                        fit: BoxFit.fill,
                      ),
                    ],
                  )
                      :
                  Flexible(
                    child: ListView.builder(
                        itemCount: listaBuscado.length,
                        itemBuilder: (BuildContext context, int posicao) {
                          String id = listaBuscado[posicao].primaryKey;
                          return Card(
                            shadowColor: Color(0xFFd6d0c1),
                            elevation: 0.1,
                            color: Colors.transparent,
                            margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(width: 0.5, color: new Color(0x00000000)),
                            ),
                            child: ListTile(
                              onTap: () {
                                launchWhatsApp(phone: '${listaBuscado[posicao].telefone}', message: 'Oi, ${listaBuscado[posicao].nome}, entro em contato para tratar da sua consulta de ${DateFormat.d().format(data)}/${DateFormat.M().format(data)}/${DateFormat.y().format(data)}.');
                              },
                              leading: CircleAvatar(
                                  child: Text('${listaBuscado[posicao].nome.substring(0,1)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'quicksand',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  backgroundColor: Colors.black),
                              title: Text(
                                '${listaBuscado[posicao].nome}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w300,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                                ),
                              ),
                              subtitle: Text(
                                '${DateFormat.d().format(data)}/${DateFormat.M().format(data)}/${DateFormat.y().format(data)} às ${listaBuscado[posicao].hora}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w100,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.green,
                                    onPressed: () {
                                      Paciente pacienteEdicao = new Paciente(listaBuscado[posicao].nome, listaBuscado[posicao].telefone,
                                          listaBuscado[posicao].email, listaBuscado[posicao].imageURL, listaBuscado[posicao].data, listaBuscado[posicao].hora,
                                          listaBuscado[posicao].anotacao, listaBuscado[posicao].confirmado,
                                          listaBuscado[posicao].objetivo,
                                          listaBuscado[posicao].vegetariano, listaBuscado[posicao].bebidaAlcoolica,
                                          listaBuscado[posicao].fumante, listaBuscado[posicao].sedentario,
                                          listaBuscado[posicao].patologia, listaBuscado[posicao].nomePatologia,
                                          listaBuscado[posicao].medicamentos, listaBuscado[posicao].nomeMedicamentos,
                                          listaBuscado[posicao].alergia, listaBuscado[posicao].nomeAlergia,
                                          listaBuscado[posicao].sexo, listaBuscado[posicao].estadoCivil);
                                      //Navigator.push(context, MaterialPageRoute(builder: (context) => Edicao(paciente: pacienteEdicao)));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Theme.of(context).errorColor,
                                    onPressed: () {
                                      _showDialog(context, listaBuscado[posicao], posicao);
                                      //remover(id, posicao);
                                    //  await _deviceCalendarPlugin.deleteEvent(_calendar.id, _event.eventId);
                                    }, //=> deleteTx(transactions[index].id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
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

  DateTime converterData(String strDate){
    DateTime data = dateFormat.parse(strDate);
    return data;
  }

  String formatarData(DateTime dt) {
    String data = dateFormat.format(dt);
    return data;
  }

  void launchWhatsApp({@required String phone, @required String message}) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Houve um erro';
    }
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

  void remover(String id, int index, Paciente paciente) {
    setState(() {
      Paciente pac = new Paciente(paciente.nome, paciente.telefone,
          paciente.email, paciente.imageURL, paciente.data, paciente.hora,
          paciente.anotacao, paciente.confirmado, paciente.objetivo,
          paciente.vegetariano, paciente.bebidaAlcoolica,
          paciente.fumante, paciente.sedentario,
          paciente.patologia, paciente.nomePatologia,
          paciente.medicamentos, paciente.nomeMedicamentos,
          paciente.alergia, paciente.nomeAlergia,
          paciente.sexo, paciente.estadoCivil);
      listaBuscado.removeAt(index);
      listaPacientes.removeAt(index);
      dbReference.child(id).remove().then((_) {
      });
    });
  }

  void _showDialog(BuildContext context, Paciente paciente, int posicao) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.all(8.0),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    child: Text(
                      "ATENÇÃO",
                      style: TextStyle(color: Colors.red, fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.black,
                    height: 4.0,
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Tem certeza que deseja APAGAR a consulta de ${paciente.nome} no dia ${paciente.data} às ${paciente.hora}?",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            FlatButton(
                              color: Colors.black,
                              textColor: Colors.white,
                              child: Text(
                                'Sim',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/60,
                                  fontFamily: 'quicksand',
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  remover('${paciente.primaryKey}', posicao,
                                      paciente);
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                            FlatButton(
                              color: Colors.black,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                'Não',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                          ],
                        ),
                      ]),
                ],
              ),
            ),
          );
        });
  }
}
