import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/ui/agendar.dart';
import 'package:atendimentos/ui/cadastro.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:atendimentos/ui/consultas.dart';
import 'package:atendimentos/ui/prontuarios.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_ui/liquid_ui.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:atendimentos/sign_in.dart';
//import 'package:sticky_headers/sticky_headers/widget.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;
final FirebaseDatabase db2 = FirebaseDatabase.instance;

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  Profissional profissional = new Profissional(name, "", email, "", usuario, false);
  List<Paciente> listaPacientes = List();
  List<Profissional> listaProfissional = List();
  DatabaseReference dbPacientes;
  DatabaseReference dbProfissional;
  bool presente = false;

  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<SideMenuState> _endSideMenuKey = GlobalKey<SideMenuState>();

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
          values['email'], values['areaAtuacao'], values['usuario'], values['assinante']);
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

    /*for(int i = 0; i < 6; i++) {
      listaPacientes.add(profissional);
    }*/

    return SideMenu(
      key: _endSideMenuKey,
      inverse: true, // end side menu
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
                  title: Text('Atendimentos',
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
                  child: Center(
                      child: presente == false ?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\nCadastre-se para ter acesso aos recursos do aplicativo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
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
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid
                              ),
                            borderRadius: BorderRadius.circular(40)
                          ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => Cadastro(profissional: profissional)),
                              );
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
                                        'Cadastre-se',
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
                          )
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
                                              fontFamily: 'nanumgothic',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          backgroundColor: Colors.black),
                                      title: Text(
                                        '${listaPacientes[posicao].nome}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'nanumgothic',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${listaPacientes[posicao].data} às ${listaPacientes[posicao].hora}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'nanumgothic',
                                          fontWeight: FontWeight.w100,
                                        ),
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
                              fontSize: 17.0,
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
                  baseStyle: TextStyle(color: Colors.white),
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
                  fontSize: 13.0
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
            title: Text("Agendar atendimento"),
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
            title: Text("Anotações/Prontuários"),
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
            title: Text("Sair"),
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
}