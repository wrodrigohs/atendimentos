import 'package:atendimentos/model/profissional.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui' as ui;

import '../model/paciente.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;

class Anotar extends StatefulWidget {
  Paciente paciente;
  Profissional profissional;

  Anotar({Key key, @required this.paciente, @required this.profissional}) : super(key: key);

  @override
  _AnotarState createState() => _AnotarState();

}

class _AnotarState extends State<Anotar> {

  List<Paciente> listaPacientes = new List();
  DatabaseReference dbReference;
  TextEditingController _anotacaoController = TextEditingController();
  String anotacao;

  @override
  void initState() {
    super.initState();

    for(int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
    }

    _anotacaoController.text = widget.paciente.anotacao;

    dbReference = db.reference().child('atendimentos/${widget.profissional.usuario}/pacientes');
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
      listaPacientes.add(widget.paciente);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    double distancia = AppBar().preferredSize.height + 40;

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
              title: Text('Dados de ${widget.paciente.nome}',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'quicksand',
                ),
              ),
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
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: new BoxDecoration(color: Colors.black.withOpacity(0.0)),
                      child: new BackdropFilter(
                        filter: new ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                        child: new Container(
                          decoration: new BoxDecoration(color: Colors.transparent.withOpacity(0.1)),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: distancia,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
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
                              maxLines: null,
                              controller: _anotacaoController,
                              keyboardType: TextInputType.text,
                              onSaved: (corpoTexto) => corpoTexto = corpoTexto,
                              validator: (corpoTexto) => corpoTexto.length < 10 ? "O texto não pode estar vazio." : null,
                              cursorColor: Colors.white,
                              onFieldSubmitted: (_) {
                                setState(() {
                                  widget.paciente.anotacao = _anotacaoController.text.toString();
                                  anotacao = _anotacaoController.text.toString();
                                });
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white, width: 3.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                enabledBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                                ),
                                hintText: "Faça suas anotações aqui.",
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
                                labelText: "Anotações",
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
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 3.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 3.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
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
                              "Salvar anotação",
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
                                anotacao = _anotacaoController.text.toString();

                                Paciente pacienteAtualizado = new Paciente(widget.paciente.nome, widget.paciente.telefone,
                                    widget.paciente.email, widget.paciente.imageURL, widget.paciente.data, widget.paciente.hora,
                                  anotacao, widget.paciente.confirmado, widget.paciente.objetivo,
                                  widget.paciente.vegetariano, widget.paciente.bebidaAlcoolica,
                                  widget.paciente.fumante, widget.paciente.sedentario,
                                  widget.paciente.patologia, widget.paciente.nomePatologia,
                                  widget.paciente.medicamentos, widget.paciente.nomeMedicamentos,
                                  widget.paciente.alergia, widget.paciente.nomeAlergia,
                                  widget.paciente.sexo, widget.paciente.estadoCivil);
                                validar(pacienteAtualizado);
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ]
              ),
            ),
          ),
        ],
      ),
    );
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

  void validar(Paciente paciente) {
    for(int i = 0; i < listaPacientes.length; i++) {
      if (((paciente.data) == (listaPacientes[i].data)) && ((paciente.hora) == (listaPacientes[i].hora))
          && ((paciente.nome) != (listaPacientes[i].nome))) {
        Fluttertoast.showToast(
          msg: 'Horário já escolhido. Por favor selecione outro.',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 5,
        );
        return;
      }
    }
    atualizarPaciente(paciente);
  }
}