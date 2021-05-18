import 'dart:io';
import 'dart:ui' as ui;

import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:atendimentos/ui/edicao.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;

class Busca extends StatefulWidget {
  Paciente paciente;
  Profissional profissional;
  String nomeBuscado;

  Busca({Key key, this.paciente, this.profissional, this.nomeBuscado}) : super(key: key);

  @override
  _BuscaState createState() => _BuscaState();
}

class _BuscaState extends State<Busca> {
  Paciente paciente;
  DatabaseReference dbReference;
  List<Paciente> listaPacientes = List();
  List<Paciente> listaBuscado = List();
  double distancia;

  @override
  void initState() {
    super.initState();

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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    for(int i = 0; i < listaPacientes.length; i++) {
      if((listaPacientes[i].nome.toLowerCase()).contains(widget.nomeBuscado.toLowerCase())) {
        listaBuscado.add(listaPacientes[i]);
      }
    }

    for(int i = 0; i < listaBuscado.length; i++) {
      for(int j = i + 1; j < listaBuscado.length; j++) {
        if ((equalsIgnoreCase(listaBuscado[i].nome, listaBuscado[j].nome)) &&
            (equalsIgnoreCase(listaBuscado[i].data, listaBuscado[j].data)) &&
            (equalsIgnoreCase(listaBuscado[i].hora, listaBuscado[j].hora))) {
          listaBuscado.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaBuscado.length; i++) {
      for(int j = i + 1; j < listaBuscado.length; j++) {
        if ((equalsIgnoreCase(listaBuscado[i].nome, listaBuscado[j].nome)) &&
            (equalsIgnoreCase(listaBuscado[i].data, listaBuscado[j].data)) &&
            (equalsIgnoreCase(listaBuscado[i].hora, listaBuscado[j].hora))) {
          listaBuscado.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaBuscado.length; i++) {
      for(int j = i + 1; j < listaBuscado.length; j++) {
        if ((equalsIgnoreCase(listaBuscado[i].nome, listaBuscado[j].nome)) &&
            (equalsIgnoreCase(listaBuscado[i].data, listaBuscado[j].data)) &&
            (equalsIgnoreCase(listaBuscado[i].hora, listaBuscado[j].hora))) {
          listaBuscado.removeAt(j);
        }
      }
    }

    if (Platform.isIOS) {
      distancia = AppBar().preferredSize.height + 60;
    } else {
      distancia = AppBar().preferredSize.height + 40;
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Color(0x44000000),//Color(0xFF333366)
              elevation: 0.0,
              title: Text("${widget.nomeBuscado}",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'quicksand',
                ),
              ),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      listaBuscado.isEmpty ?
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: distancia,
                          ),
                          Text('Nenhuma consulta de ${widget.nomeBuscado} econtrada',
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
                          Center(
                            child: Lottie.asset(
                              'assets/images/sad.json',
                              animate: true,
                              repeat: true,
                              reverse: true,
                              width: 200,
                              height: 200,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      )
                          :
                      Flexible(
                        child: ListView.builder(
                            itemCount: listaBuscado.length,
                            itemBuilder: (BuildContext context, int posicao) {
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
                                    launchWhatsApp(phone: '${listaBuscado[posicao].telefone}', message: 'Oi, ${listaBuscado[posicao].nome}, entro em contato para tratar da sua consulta de ${listaBuscado[posicao].data}.');
                                  },
                                  leading: listaBuscado[posicao].imageURL != null ?
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(listaBuscado[posicao].imageURL),
                                  )
                                      :
                                  CircleAvatar(
                                      child: Text(
                                        '${listaBuscado[posicao].nome.substring(0, 1).toUpperCase()}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      backgroundColor: Colors.black
                                  ),
                                  title: Text(
                                    '${listaBuscado[posicao].nome}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'quicksand',
                                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${listaBuscado[posicao].data} às ${listaBuscado[posicao].hora}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'quicksand',
                                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircleAvatar(
                                        child: IconButton(
                                          icon: Icon(Icons.edit),
                                          color: Colors.green,
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder:
                                                (context) => Edicao(paciente: listaPacientes[posicao], profissional: widget.profissional)));                                          },
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      CircleAvatar(
                                        child: IconButton(
                                          icon: Icon(Icons.delete_forever),
                                          color: Theme.of(context).errorColor,
                                          onPressed: () {_showDialog(context, listaBuscado[posicao], posicao);
                                          },
                                        ),
                                        backgroundColor: Colors.white,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'quicksand',
                        fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                        fontWeight: FontWeight.bold,),
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
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'quicksand',
                              fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                            ),
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
                                borderRadius: BorderRadius.circular(20.0),
                              ),
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
                                  remover('${paciente.primaryKey}', posicao, paciente);
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                            FlatButton(
                              color: Colors.black,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                'Não',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/60,
                                  fontFamily: 'quicksand',
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

  void remover(String id, int index, Paciente paciente) {
    setState(() {
      listaBuscado.removeAt(index);
      dbReference.child(id).remove().then((_) {
      });
    });
  }
}