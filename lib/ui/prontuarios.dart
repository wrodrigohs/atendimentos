import 'dart:collection';
import 'dart:io';

import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/model/profissional.dart';
import "package:collection/collection.dart";
import 'package:atendimentos/ui/verprontuarios.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;

class Prontuarios extends StatefulWidget {
  Paciente paciente;
  Profissional profissional;

  Prontuarios({Key key, this.profissional, this.paciente}) : super(key: key);

  @override
  _ProntuariosState createState() => _ProntuariosState();
}

class _ProntuariosState extends State<Prontuarios> {
  Paciente paciente;
  DatabaseReference dbReference;
  List<Paciente> listaPacientes = List();
  List<Paciente> listaAnotacoes = List();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
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

  bool equalsIgnoreCase(String a, String b) =>
      (a == null && b == null) || (a != null && b != null && a.toLowerCase() == b.toLowerCase());

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    for(int i = 0; i < listaPacientes.length; i++) {
      listaAnotacoes.add(listaPacientes[i]);
      for(int j = i + 1; j < listaPacientes.length; j++) {
        if ((equalsIgnoreCase(listaPacientes[i].nome, listaPacientes[j].nome)) &&
        (equalsIgnoreCase(listaPacientes[i].telefone, listaPacientes[j].telefone)) &&
        (equalsIgnoreCase(listaPacientes[i].email, listaPacientes[j].email)) &&
        (!equalsIgnoreCase(listaPacientes[i].primaryKey, listaPacientes[j].primaryKey))){
          //listaAnotacoes.add(listaPacientes[i]);
          listaPacientes.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaAnotacoes.length; i++) {
      for(int j = i + 1; j < listaAnotacoes.length; j++) {
        if ((equalsIgnoreCase(listaAnotacoes[i].nome, listaAnotacoes[j].nome))) {
          listaAnotacoes.removeAt(j);
        }
      }
    }

    listaAnotacoes.sort((a, b) => ((a.nome).compareTo(b.nome)));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Color(0x44000000),//Color(0xFF333366)
              elevation: 0.0,
              centerTitle: true,
              title: Text('Prontuários',
                style: TextStyle(
                    fontFamily: 'nanumgothic'
                ),
              ),
            ),
            body: new Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/ceu.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  listaAnotacoes.isEmpty ?
                  Column(
                    children: <Widget>[
                      Text('Nenhum atendimento marcado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'nanumgothic',
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          height: 200,
                          child: Image.asset(
                            'assets/images/triste.png',
                            fit: BoxFit.cover,
                            color: Colors.white,
                          )
                      ),
                    ],
                  )
                      :
                  Flexible(
                    child: ListView.builder(
                        itemCount: listaAnotacoes.length,
                        itemBuilder: (BuildContext context, int posicao) {
                          String id = listaAnotacoes[posicao].primaryKey;
                          return Card(
                            shadowColor: Color(0xFF333366),
                            elevation: 4,
                            color: Colors.transparent,
                            margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(width: 0.5, color: new Color(0xFF333366)),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => VerProntuarios(profissional: widget.profissional, paciente: listaAnotacoes[posicao])),
                                );
                              },
                              leading: CircleAvatar(
                                  child: Text('${listaAnotacoes[posicao].nome.substring(0,1)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'nanumgothic',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.black),
                              title: Text(
                                'Prontuário de ${listaAnotacoes[posicao].nome}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'nanumgothic',
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
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

  /*void updateTexto(Texto texto) {
    //Toggle completed
    //paciente.completed = !paciente.completed;
    if (texto != null) {
      dbReference.child(texto.primaryKey).set(texto.toJson());
    }
  }*/
}
