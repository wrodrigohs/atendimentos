import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/ui/agendar.dart';
import 'package:atendimentos/ui/busca.dart';
import 'package:atendimentos/ui/cadastro.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:atendimentos/ui/consultas.dart';
import 'package:atendimentos/ui/historico.dart';
import 'package:atendimentos/ui/prontuarios.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:liquid_ui/liquid_ui.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:atendimentos/sign_in.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui' as ui;
//import 'package:sticky_headers/sticky_headers/widget.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;
final FirebaseDatabase db2 = FirebaseDatabase.instance;

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  Profissional profissional = new Profissional(name, "", email, "", usuario, imageUrl, "", "", false);
  List<Paciente> listaPacientes = List();
  List<Profissional> listaProfissional = List();
  DatabaseReference dbPacientes;
  DatabaseReference dbProfissional;
  bool presente = false;
  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String nomeBuscado;
  final TextEditingController _nomeController = TextEditingController();

  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<SideMenuState> _endSideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
    }

    dbProfissional = db2.reference().child('${profissional.usuario}');
    dbProfissional.onChildAdded.listen(_gravarProfissional);
    dbProfissional.onChildChanged.listen(_updateProfissional);
    dbProfissional.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      Profissional prof = new Profissional(values['nome'], values['telefone'],
          values['email'], values['areaAtuacao'], values['usuario'],
          values['imageURL'], values['facebook'], values['instagram'], values['assinante']);
      if(prof.nome != null) {
        listaProfissional.add(prof);
      }
    });

    dbPacientes = db.reference().child('${profissional.usuario}/pacientes');
    dbPacientes.onChildAdded.listen(_gravar);
    dbPacientes.onChildChanged.listen(_update);
    dbPacientes.once().then((DataSnapshot snapshot) {
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

    for(int i = 0; i < listaProfissional.length; i++) {
      if(listaProfissional[i].email == profissional.email) {
        presente = true;
      }
    }

    listaPacientes.sort((a, b) => (((converterData(a.data)).compareTo(converterData(b.data)))));

    return SideMenu(
      key: _endSideMenuKey,
      inverse: true,
      type: SideMenuType.slideNRotate,
      menu: buildMenu(context),
      child: SideMenu(
        background: Colors.black,
        key: _sideMenuKey,
        menu: buildMenu(context),
        type: SideMenuType.slideNRotate,
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Color(0x44000000),//Color(0xFF333366)
                  elevation: 0.0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      final _state = _sideMenuKey.currentState;
                      if (_state.isOpened)
                        _state.closeSideMenu();
                      else
                        _state.openSideMenu();
                    },
                  ),
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          dialogBusca(context);
                        }
                    ),
                  ],
                  title: Text('Atendimentos',
                    style: TextStyle(
                        fontFamily: 'quicksand'
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
                      Center(
                          child: presente == false ?
                          //Cadastro()
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\nCadastre-se para ter acesso aos recursos do aplicativo.',
                                textAlign: TextAlign.center,
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
                              FlatButton(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                      style: BorderStyle.solid
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Cadastro(profissional: profissional)),
                                  );
                                },
                                child: Text(
                                  "Cadastre-se",
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
                              )
                            ],
                          )
                              :
                          listaPacientes.length <= 0 ?
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text('Nenhum atendimento marcado',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height/50,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'quicksand',
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
                              ),
                            ],
                          )
                              :
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Flexible(
                                child: ListView.builder(
                                    itemCount: listaPacientes.length,
                                    itemBuilder: (BuildContext context, int posicao) {
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
                                          onTap: () {},
                                          leading: CircleAvatar(
                                              child: Text(
                                                '${listaPacientes[posicao].nome.substring(0, 1).toUpperCase()}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'quicksand',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              backgroundColor: Colors.black),
                                          title: Text(
                                            '${listaPacientes[posicao].nome}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'quicksand',
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${listaPacientes[posicao].data} às ${listaPacientes[posicao].hora}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'quicksand',
                                              fontWeight: FontWeight.w100,
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
                                                    //Navigator.push(context, MaterialPageRoute(builder:
                                                    //  (context) => Anotar(paciente: listaAnotacoes[posicao], profissional: widget.profissional)));
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
                                                  icon: Icon(Icons.delete_forever),
                                                  color: Theme.of(context).errorColor,
                                                  onPressed: () {
                                                    _showDialog(context, listaPacientes[posicao], posicao);
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
                              //profissional.assinante == false ?
                              /*Text(
                            '\nAQUI SERÁ O CARD PARA ASSINATURA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
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
                          ),
                          FlatButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid
                            ), borderRadius: BorderRadius.circular(40)),
                            onPressed: () {
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Container(
                                color: Colors.white,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    //Image(image: AssetImage("assets/images/google_logo.png"), height: 35.0),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Text(
                                        'Assinar',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )*/
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.exit_to_app),
            elevation: 16,
            backgroundColor: Colors.black,
            onPressed: () {
              signOutGoogle();
              Navigator.of(context).pop();
              //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return LoginPage();}), ModalRoute.withName('/'));
              //Navigator.pushReplacementNamed(context, "logout");
            },
          ),
        ),
      ),
    );
  }

  Widget buildMenu(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    imageUrl,
                  ),
                  radius: 30,
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(height: 16.0),
                LText(
                  "\l.lead{Bem-vindo(a)},\n\l.lead.bold{$name}",
                  baseStyle: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height/55,
                    fontFamily: 'quicksand',
                  ),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Consultas(profissional: profissional)));
            },
            leading: Icon(Icons.home, size: 20.0, color: Colors.white),
            title: Text("Atendimentos de hoje",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Agendar(profissional: profissional)));
            },
            leading: Icon(Icons.add_circle, size: 20.0, color: Colors.white),
            title: Text("Agendar atendimento",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Prontuarios(profissional: profissional)));
            },
            leading:
            Icon(Icons.assignment, size: 20.0, color: Colors.white),
            title: Text("Anotações/Prontuários",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
          SizedBox(height: 10.0),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              signOutGoogle();
              Navigator.of(context).pop();
            },
            leading: Icon(Icons.exit_to_app, size: 20.0, color: Colors.white),
            title: Text("Sair",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
        ],
      ),
    );
  }

  void _gravarProfissional(Event event) {
    setState(() {
      listaProfissional.add(Profissional.fromSnapshot(event.snapshot));
    });
  }

  void _updateProfissional(Event event) {
    var oldEntry = listaProfissional.singleWhere((entry) {
      return entry.primaryKey == event.snapshot.key;
    });

    setState(() {
      listaProfissional[listaProfissional.indexOf(oldEntry)] =
          Profissional.fromSnapshot(event.snapshot);
    });
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

  DateTime converterData(String strDate){
    DateTime data = dateFormat.parse(strDate);
    return data;
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
                        fontSize: MediaQuery.of(context).size.height/50,
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
                              fontSize: MediaQuery.of(context).size.height/50,
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
                                  fontSize: MediaQuery.of(context).size.height/60,
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
                                  fontSize: MediaQuery.of(context).size.height/60,
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
      listaPacientes.removeAt(index);
      dbPacientes.child(id).remove().then((_) {
      });
    });
  }

  void dialogBusca(BuildContext context) async {
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
                      "Digite o nome a ser buscado",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: MediaQuery.of(context).size.height/50,
                        fontFamily: 'quicksand',
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Form(
                          key: formKey,
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Flexible(
                                  child: ListTile(
                                    title: TextFormField(
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50
                                      ),
                                      controller: _nomeController,
                                      onSaved: (nome) => nomeBuscado = nome,
                                      validator: (nome) =>
                                      nome.length < 3
                                          ? "Deve ter ao menos 3 caracteres."
                                          : null,
                                      cursorColor: Colors.black,
                                      onFieldSubmitted: (_) {
                                        setState(() {
                                          nomeBuscado = _nomeController.text.toString();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2.0),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: new OutlineInputBorder(
                                          borderRadius: new BorderRadius.circular(8.0),
                                          borderSide:
                                          new BorderSide(color: Colors.black, width: 2.0),
                                        ),
                                        hintText: "Paciente buscado",
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'quicksand',
                                            fontSize: MediaQuery.of(context).size.height/50
                                        ),
                                        labelText: "Nome",
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'quicksand',
                                            fontSize: MediaQuery.of(context).size.height/50
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide:
                                          const BorderSide(color: Colors.red, width: 3.0),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                FlatButton(
                                  color: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Text(
                                    'Buscar',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50
                                      ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      nomeBuscado = _nomeController.text.toString();
                                      _nomeController.text = '';
                                      Navigator.of(context).pop();
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => Busca(nomeBuscado: nomeBuscado,
                                            profissional: profissional)),
                                      );
                                      //_presentDatePicker();
                                    });
                                  },
                                ),
                              ]
                          ),
                        ),
                      ]
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}