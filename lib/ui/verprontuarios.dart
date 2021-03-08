import 'dart:io';
import 'dart:ui' as ui;

import 'package:atendimentos/model/profissional.dart';
import 'package:atendimentos/ui/anotar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:atendimentos/model/paciente.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as w;
import 'package:open_file/open_file.dart' as open_file;

final FirebaseDatabase db = FirebaseDatabase.instance;

class VerProntuarios extends StatefulWidget {
  Paciente paciente;
  Profissional profissional;
  VerProntuarios({Key key, this.profissional, this.paciente}) : super(key: key);

  @override
  _VerProntuariosState createState() => _VerProntuariosState();
}

class _VerProntuariosState extends State<VerProntuarios> {
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
    dbReference = db.reference().child('atendimentos/${widget.profissional.usuario}/pacientes');
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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    for(int i = 0; i < listaPacientes.length; i++) {
      if(equalsIgnoreCase(listaPacientes[i].nome, widget.paciente.nome)) {
        listaAnotacoes.add(listaPacientes[i]);
      }
    }

    for(int i = 0; i < listaAnotacoes.length; i++) {
      for(int j = i + 1; j < listaAnotacoes.length; j++) {
        if (equalsIgnoreCase(listaAnotacoes[i].data, listaAnotacoes[j].data) &&
            (equalsIgnoreCase(listaAnotacoes[i].hora, listaAnotacoes[j].hora)) &&
            (equalsIgnoreCase(listaAnotacoes[i].nome, listaAnotacoes[j].nome))) {
          listaAnotacoes.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaAnotacoes.length; i++) {
      for(int j = i + 1; j < listaAnotacoes.length; j++) {
        if (equalsIgnoreCase(listaAnotacoes[i].data, listaAnotacoes[j].data) &&
            (equalsIgnoreCase(listaAnotacoes[i].hora, listaAnotacoes[j].hora)) &&
            (equalsIgnoreCase(listaAnotacoes[i].nome, listaAnotacoes[j].nome))) {
          listaAnotacoes.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaAnotacoes.length; i++) {
      for(int j = i + 1; j < listaAnotacoes.length; j++) {
        if (equalsIgnoreCase(listaAnotacoes[i].data, listaAnotacoes[j].data) &&
            (equalsIgnoreCase(listaAnotacoes[i].hora, listaAnotacoes[j].hora)) &&
            (equalsIgnoreCase(listaAnotacoes[i].nome, listaAnotacoes[j].nome))) {
          listaAnotacoes.removeAt(j);
        }
      }
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
              centerTitle: true,
              title: Text("Prontuário de ${widget.paciente.nome}",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'quicksand',
                ),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
            body: new Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/imglogin.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
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
                      if (listaAnotacoes.isEmpty) Column(
                        children: <Widget>[
                          Text('Não há consultas marcadas.',
                            style: TextStyle(
                                inherit: false,
                                fontSize: MediaQuery.of(context).size.height/45,
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
                          SizedBox(
                            height: 20,
                            width: double.infinity,
                          ),
                          Container(
                              height: 230,
                              width: double.infinity,
                              child: Image.asset(
                                  'assets/images/triste.png',
                                  fit: BoxFit.cover,
                                  color: Colors.white
                              )
                          ),
                        ],
                      ) else Flexible(
                        child: ListView.builder(
                            itemCount: listaAnotacoes.length,
                            itemBuilder: (BuildContext context, int posicao) {
                              String id = listaAnotacoes[posicao].primaryKey;
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
                                    //Share.share('Anotações sobre a consulta de ${listaAnotacoes[posicao].nome} no dia ${listaAnotacoes[posicao].data} às ${listaAnotacoes[posicao].hora}\n\n${listaAnotacoes[posicao].anotacao}');
                                    //Navigator.push(context, MaterialPageRoute(builder: (context) => EditarTexto(texto: listaTextos[posicao])));
                                  },
                                  title: Text('Consulta de',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.height/55,
                                      fontFamily: 'quicksand',
                                    ),
                                  ),
                                  subtitle: Text('${listaAnotacoes[posicao].data} às ${listaAnotacoes[posicao].hora}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.height/55,
                                      fontFamily: 'quicksand',
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircleAvatar(
                                        child: IconButton(
                                          icon: Icon(Icons.edit),
                                          color: Colors.green.shade900,
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder:
                                                (context) => Anotar(paciente: listaAnotacoes[posicao], profissional: widget.profissional)));
                                            //Navigator.of(context).pop();
                                          },
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 3.0,
                                      ),
                                      CircleAvatar(
                                        child: IconButton(
                                          icon: Icon(Icons.picture_as_pdf),
                                          color: Theme.of(context).errorColor,
                                          onPressed: () {
                                            reportView(context, listaAnotacoes[posicao]);
                                            //Navigator.push(context, MaterialPageRoute(builder:
                                            //  (context) => reportView(context, listaAnotacoes[posicao])));
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
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

  bool equalsIgnoreCase(String a, String b) =>
      (a == null && b == null) || (a != null && b != null && a.toLowerCase() == b.toLowerCase());

  reportView(contexto, Paciente paciente) async {
    final w.Document pdf = w.Document();
    pdf.addPage(w.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 0.5 * PdfPageFormat.cm),
        crossAxisAlignment: w.CrossAxisAlignment.start,
        /*header: (w.Context context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return w.Container(
              alignment: w.Alignment.topLeft,
              margin: const w.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const w.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const w.BoxDecoration(
                  border: w.BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
              child: w.Text('Prontuário de ${paciente.nome}',
                  style: w.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },*/
        footer: (w.Context context) {
          return w.Container(
            //alignment: w.Alignment.topRight,
              margin: const w.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: w.Text('${widget.profissional.nome}\n${widget.profissional.num_conselho}\nPágina ${context.pageNumber}',
                  style: w.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey),
                  textAlign: w.TextAlign.right
              )
          );
        },
        build: (w.Context context) => <w.Widget>[
          w.Header(
              level: 0,
              child: w.Row(
                  mainAxisAlignment: w.MainAxisAlignment.spaceBetween,
                  children: <w.Widget>[
                    w.Text('Prontuário de ${paciente.nome}',
                      style: w.TextStyle(
                          fontSize: 13.0
                      ),
                      textScaleFactor: 2,
                      textAlign: w.TextAlign.justify,
                    ),
                    w.PdfLogo()
                  ])),
          //Header(level: 1, text: 'What is Lorem Ipsum?'),
          w.Paragraph(
            text:
            '${paciente.anotacao}',
            style: w.TextStyle(
                fontSize: MediaQuery.of(contexto).size.height/50,
            ),
            textAlign: w.TextAlign.justify,
          ),
        ]
    )
    );
    //save PDF

    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/${paciente.nome}${DateFormat.d().format(converterData(paciente.data))}${DateFormat.M().format(converterData(paciente.data))}${DateFormat.y().format(converterData(paciente.data))}.pdf';
    final File file = File(path);
    await file.writeAsBytes(pdf.save());

    await open_file.OpenFile.open('$path');

    /*FutureBuilder<Widget>(
      future: lerPdf(path),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
        if(snapshot.hasData)
          ;

        return Container(child: CircularProgressIndicator());
      }
    );*/

    //lerPdf(path);
  }

  lerPdf(String path) {
    open_file.OpenFile.open('$path');
    //return w.Container(child: w.CircularProgressIndicator(value: 1.0));
  }

  DateTime converterData(String strDate) {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
    DateTime data = dateFormat.parse(strDate);
    return data;
  }
}
