import 'package:atendimentos/model/paciente.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
//import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;

class LerProntuario extends StatelessWidget {
  Paciente paciente;
  LerProntuario ({Key key, @required this.paciente}) : super(key: key);
  List<String> listaTextos = new List();

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    //listaTextos.add(texto);
    String anotacao = paciente.anotacao;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.deepPurpleAccent, Colors.purpleAccent]
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text("${paciente.nome}",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'quicksand',
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.purpleAccent, Colors.white30]
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('$anotacao',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                    fontFamily: 'quicksand',
                    color: Colors.white
                ),
              ),/*Linkify(
                onOpen: (link) async {
                  if (await canLaunch(link.url)) {
                    await launch(link.url);
                  } else {
                    throw 'Could not launch $link';
                  }
                },
                text: '\n${paciente.anotacao}',
                //textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                    fontFamily: 'quicksand',
                    color: Colors.white
                ),
                linkStyle: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline
                ),
              ),*/
            ),

          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, Paciente paciente) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.all(8.0),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    child: Text(
                      "ATENÇÃO",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                          fontFamily: 'quicksand'
                      ),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("${paciente.nome},\nsua consulta de ${paciente.data} às ${paciente.hora} só será CONFIRMADA após o envio do comprovante de pagamento.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'quicksand'
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: FlatButton(
                                  color: Colors.white,
                                  textColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                  ),
                ],
              ),
            ),
          );
        });
  }
}