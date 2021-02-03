import 'dart:io';

import 'package:atendimentos/model/datapaciente.dart';
import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  List<DataPaciente> listaDt = List();
  List<Paciente> listaPacientes = List();
  List<DataPaciente> listaBuscado = List();
  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < listaDt.length; i++) {
      listaDt.removeAt(i);
    }

    paciente = new Paciente("", "", "", "", "", "", false);
    dbReference = db.reference().child('${widget.profissional.usuario}/pacientes');
    dbReference.onChildAdded.listen(_gravar);
    dbReference.onChildChanged.listen(_update);
    dbReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      Paciente paciente = new Paciente(values['nome'], values['telefone'],
          values['email'], values['data'], values['hora'], values['anotacao'], values['confirmado']);
      if(paciente.nome != null) {
        listaPacientes.add(paciente);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    for (int i = 0; i < listaDt.length; i++) {
      DataPaciente dt_pac = new DataPaciente(listaPacientes[i].primaryKey, listaPacientes[i].nome, listaPacientes[i].telefone,
          listaPacientes[i].email, converterData(listaPacientes[i].data), listaPacientes[i].hora,
          listaPacientes[i].anotacao, listaPacientes[i].confirmado);
      listaDt.remove(dt_pac);
      listaDt.removeAt(i);
    }

    for(int i = 0; i < listaPacientes.length; i++) {
      DataPaciente dt_pac = new DataPaciente(listaPacientes[i].primaryKey, listaPacientes[i].nome, listaPacientes[i].telefone,
          listaPacientes[i].email, converterData(listaPacientes[i].data), listaPacientes[i].hora,
          listaPacientes[i].anotacao, listaPacientes[i].confirmado);
      listaDt.add(dt_pac);
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    DateTime hoje = DateTime.now();
    String d1 = formatarData(hoje);
    DateTime data = converterData(d1);

    for(int i = 0; i < listaDt.length; i++) {
      if((listaDt[i].data).compareTo(data) == 0) {
        listaBuscado.add(listaDt[i]);
      }
    }

    listaBuscado.sort((a, b) => ((a.hora).compareTo(b.hora)));
    double distancia = AppBar().preferredSize.height + 40;

    return Scaffold(
      body: Stack(children: <Widget>[
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
                image: AssetImage("assets/images/ceu.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            width: double.infinity,
            child: listaBuscado.isEmpty ?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text('Nenhum atendimento marcado para hoje',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height/50,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'quicksand',
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
                      elevation: 4,
                      margin: EdgeInsets.all(4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: Colors.purpleAccent),
                        title: Text(
                          '${listaBuscado[posicao].nome}',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'quicksand',
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat.d().format(data)}/${DateFormat.M().format(data)}/${DateFormat.y().format(data)} às ${listaBuscado[posicao].hora}',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'quicksand',
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: (listaDt[posicao].confirmado) ?
                              Icon(Icons.done_outline,
                                  color: Colors.green)
                                  :
                              Icon(Icons.done,
                                  color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  if (listaDt[posicao].confirmado == true) {
                                    Fluttertoast.showToast(
                                      msg:'Consulta confirmada',
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 5,
                                    );
                                    //envia mensagem ao paciente confirmando a consulta
                                    launchWhatsApp(phone: '${listaDt[posicao].telefone}', message: 'Oi, ${listaDt[posicao].nome}, sua consulta de ${DateFormat.d().format(listaDt[posicao].data)}/${DateFormat.M().format(listaDt[posicao].data)}/${DateFormat.y().format(listaDt[posicao].data)} está confirmada.');
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:'Consulta não confirmada',
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 5,
                                    );
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.green,
                              onPressed: () {
                                Paciente pacienteEdicao = new Paciente(listaBuscado[posicao].nome, listaBuscado[posicao].telefone,
                                    listaBuscado[posicao].email, formatarData(listaBuscado[posicao].data), listaBuscado[posicao].hora,
                                    listaBuscado[posicao].anotacao, listaBuscado[posicao].confirmado);
                                //Navigator.push(context, MaterialPageRoute(builder: (context) => Edicao(paciente: pacienteEdicao)));
                              }, //=> deleteTx(transactions[index].id),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Theme.of(context).errorColor,
                              onPressed: () {
                                _showDialog(
                                    context, listaBuscado[posicao], posicao);
                                //remover(id, posicao);
                              }, //=> deleteTx(transactions[index].id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              ),
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

  void remover(String id, int index, DataPaciente paciente) {
    setState(() {
      Paciente pac = new Paciente(paciente.nome, paciente.telefone,
          paciente.email, formatarData(paciente.data), paciente.hora,
          paciente.anotacao, paciente.confirmado);
      listaDt.removeAt(index);
      listaDt.remove(paciente);
      listaBuscado.removeAt(index);
      listaBuscado.remove(paciente);
      listaPacientes.removeAt(index);
      listaPacientes.remove(pac);
      dbReference.child(id).remove().then((_) {
      });
    });
  }

  void _showDialog(BuildContext context, DataPaciente paciente, int posicao) async {
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
                            "Tem certeza que deseja APAGAR a consulta de ${paciente.nome} no dia ${DateFormat.d().format(paciente.data)}/${DateFormat.M().format(paciente.data)}/${DateFormat.y().format(paciente.data)} às ${paciente.hora}?",
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                'Sim',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
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
