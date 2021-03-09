import 'dart:io';

import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/parental_gate.dart';
import 'package:atendimentos/ui/agendar.dart';
import 'package:atendimentos/ui/assinatura.dart';
import 'package:atendimentos/ui/busca.dart';
import 'package:atendimentos/ui/cadastro.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:atendimentos/ui/consultas.dart';
import 'package:atendimentos/ui/edicao.dart';
import 'package:atendimentos/ui/login.dart';
import 'package:atendimentos/ui/politica.dart';
import 'package:atendimentos/ui/prontuarios.dart';
import 'package:atendimentos/ui/ver_cadastro.dart';
import 'package:device_calendar/device_calendar.dart' as calendar;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:liquid_ui/liquid_ui.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:atendimentos/services/sign_in.dart';
import 'package:atendimentos/services/auth_service.dart';
import 'package:lottie/lottie.dart';
import 'package:atendimentos/components.dart';
import 'dart:ui' as ui;

final FirebaseDatabase db = FirebaseDatabase.instance;
final FirebaseDatabase db2 = FirebaseDatabase.instance;

class FirstScreen extends StatefulWidget {

  Profissional profissional;

  FirstScreen({Key key, this.profissional}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  Profissional profissional = new Profissional(name, "", email, "", usuario, imageUrl, "", "", "",
      false, false, false, false, false, false, false, null, false);
  Profissional pro = new Profissional('', '', '', '', '', '', '', '', '',
      false, false, false, false, false, false, false, null, false);
  List<Paciente> listaPacientes = List();
  List<Profissional> listaProfissional = List();
  DatabaseReference dbPacientes;
  DatabaseReference dbProfissional;
  bool presente = false;
  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String nomeBuscado;
  final TextEditingController _nomeController = TextEditingController();
  AuthService auth = new AuthService();

  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<SideMenuState> _endSideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  calendar.DeviceCalendarPlugin _deviceCalendarPlugin;
  List<calendar.Calendar> calendarioCerto = List();
  calendar.Calendar calendarioEscolhido;
  List<calendar.Calendar> _calendars;
  calendar.Event eventoApagado;

  _FirstScreenState() {
    _deviceCalendarPlugin = calendar.DeviceCalendarPlugin();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    carregarInfos();
    //_retrieveCalendars();

    if(widget.profissional != null) {
      profissional = widget.profissional;
    }

    for (int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
    }
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    for(int i = 0; i < listaProfissional.length; i++) {
      if(listaProfissional[i].email == profissional.email) {
        setState(() {
          presente = true;
          pro = listaProfissional[i];
        });
        break;
      }
    }

    listaPacientes.sort((a, b) => (((converterData(a.data)).compareTo(converterData(b.data)))));
    double distancia = AppBar().preferredSize.height + 40;

    print('##### presente = $presente  ######');
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
          key: _scaffoldKey,
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
                      if (_state.isOpened) {
                        _state.closeSideMenu();
                      } else {
                        _state.openSideMenu();
                      }
                    },
                  ),
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if(appData.isPro == true) {
                              dialogBusca(context);
                            } else {
                              WidgetsBinding.instance.addPostFrameCallback((
                                  _) =>
                                  _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        action: SnackBarAction(
                                          label: 'OK',
                                          onPressed: () {
                                            _scaffoldKey.currentState
                                                .hideCurrentSnackBar();
                                          },
                                        ),
                                        duration: Duration(seconds: 2),
                                        content: Text(
                                          'Você deve ser assinante para ter acesso a todos os recursos do app.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontSize: MediaQuery
                                                .of(context)
                                                .size
                                                .height / 55,
                                          ),
                                        ),
                                        backgroundColor: Colors.black,
                                        behavior: SnackBarBehavior.floating,
                                      )
                                  )
                              );
                            }
                          });
                        }
                    ),
                  ],
                  title: Text('Meu consultório online',
                    style: TextStyle(
                        fontFamily: 'quicksand',
                        color: Colors.white
                    ),
                  ),
                ),
                body: new Container(
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
                      Center(
                        child: appData.isPro == false ?
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Icon(
                                Icons.error,
                                color: Theme.of(context).errorColor,
                                size: MediaQuery.of(context).size.height/20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                  "Se você já é assinante, clique no botão abaixo para carregar suas informações.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
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
                                  )
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
                                Navigator.pushReplacement(context, MaterialPageRoute(
                                    builder: (BuildContext context) => super.widget));                                },
                              child: Text(
                                "Área do assinante",
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                  "Se ainda não é assinante, faça sua assinatura para ter acesso a todos os recursos do aplicativo.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
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
                                  )
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ParentalGate(), settings: RouteSettings(name: 'Parental Gate')));
                              },
                              child: Text(
                                "Assine",
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
                        appData.isPro == true && presente == false ?
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
                        presente == true && listaPacientes.length <= 0 ?
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: distancia,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text('Nenhum atendimento marcado',
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
                                Lottie.asset(
                                  'assets/images/sad.json',
                                  animate: true,
                                  repeat: true,
                                  reverse: true,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.fill,
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
                                    child: Text(
                                      "Marcar atendimento",
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
                                        Navigator.push(context, MaterialPageRoute(builder:
                                            (context) => Agendar(profissional: pro)));
                                      });
                                    }
                                ),
                              ],
                            ),
                          ],
                        )
                            :
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Flexible(
                              child: ListView.builder(
                                  itemCount: listaPacientes.length,
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
                                            fontSize: MediaQuery.of(context).size.height/50,
                                            /*shadows: [
                                                Shadow( // bottomLeft
                                                    offset: Offset(-0.6, -0.6),
                                                    color: Colors.black
                                                ),
                                                Shadow( // bottomRight
                                                    offset: Offset(0.6, -0.6),
                                                    color: Colors.black
                                                ),
                                                Shadow( // topRight
                                                    offset: Offset(0.6, 0.6),
                                                    color: Colors.black
                                                ),
                                                Shadow( // topLeft
                                                    offset: Offset(-0.6, 0.6),
                                                    color: Colors.black
                                                ),
                                              ]*/
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${listaPacientes[posicao].data} às ${listaPacientes[posicao].hora}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontWeight: FontWeight.w100,
                                            fontSize: MediaQuery.of(context).size.height/55,
                                            /*shadows: [
                                                Shadow( // bottomLeft
                                                    offset: Offset(-0.6, -0.6),
                                                    color: Colors.black
                                                ),
                                                Shadow( // bottomRight
                                                    offset: Offset(0.6, -0.6),
                                                    color: Colors.black
                                                ),
                                                Shadow( // topRight
                                                    offset: Offset(0.6, 0.6),
                                                    color: Colors.black
                                                ),
                                                Shadow( // topLeft
                                                    offset: Offset(-0.6, 0.6),
                                                    color: Colors.black
                                                ),
                                              ]*/
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            listaPacientes[posicao].confirmado == false ?
                                            Visibility(
                                              visible: true,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                child: IconButton(
                                                  icon: Icon(Icons.calendar_today),
                                                  color: Colors.black,
                                                  onPressed: () {
                                                    _retrieveCalendars(listaPacientes[posicao]);
                                                  },
                                                ),
                                              ),
                                            )
                                                :
                                            Visibility(
                                              visible: false,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                child: IconButton(
                                                  icon: Icon(Icons.calendar_today),
                                                  color: Colors.black,
                                                  onPressed: () {
                                                    _retrieveCalendars(listaPacientes[posicao]);
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3.0,
                                            ),
                                            CircleAvatar(
                                              child: IconButton(
                                                icon: Icon(Icons.edit),
                                                color: Colors.green,
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder:
                                                      (context) => Edicao(paciente: listaPacientes[posicao], profissional: profissional)));
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
                                                onPressed: () async {
                                                  _showDialog(context, listaPacientes[posicao], posicao);
                                                  //await _deviceCalendarPlugin.deleteEvent(_calendar.id, event.eventId);
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.exit_to_app),
            mini: true,
            elevation: 16,
            backgroundColor: Colors.black,
            onPressed: () {
              //if(Platform.isIOS) {
              auth.signOut();
              //}
              signOutGoogle();
              Fluttertoast.showToast(
                msg:'Logout efetuado com sucesso.',
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 5,
              );
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
                pro.imageURL != null ?
                CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 45,
                  backgroundColor: Colors.transparent,
                )
                :
                CircleAvatar(
                  child: Text('${pro.nome.substring(0, 1).toUpperCase()}',
                    style: TextStyle(
                        fontFamily: 'quicksand',
                        fontSize: MediaQuery.of(context).size.height/40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  radius: 45,
                  backgroundColor: Colors.black,
                ),
                SizedBox(height: 16.0),
                LText(name != null ? "\l.lead{Bem-vindo(a)},\n\l.lead.bold{$name}" :
                "\l.lead{Bem-vindo(a)}",
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
          /*LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Assinatura()));
            },
            leading: Icon(Icons.monetization_on, size: 20.0, color: Colors.white),
            title: Text("Assinatura",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),*/
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              if(appData.isPro == true) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Consultas(profissional: pro)));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                        },
                      ),
                      duration: Duration(seconds: 2),
                      content: Text('Você deve ser assinante para ter acesso a todos os recursos do app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/55,
                        ),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                    )
                )
                );
              }
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
              if(appData.isPro == true) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Agendar(profissional: pro)));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                        },
                      ),
                      duration: Duration(seconds: 2),
                      content: Text('Você deve ser assinante para ter acesso a todos os recursos do app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/55,
                        ),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                    )
                )
                );
              }
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
              if(appData.isPro == true) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Prontuarios(profissional: pro)));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                        },
                      ),
                      duration: Duration(seconds: 2),
                      content: Text('Você deve ser assinante para ter acesso a todos os recursos do app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/55,
                        ),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                    )
                )
                );
              }
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
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              if(appData.isPro == true) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditarCadastro(profissional: pro,)));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                        },
                      ),
                      duration: Duration(seconds: 2),
                      content: Text('Você deve ser assinante para ter acesso a todos os recursos do app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/55,
                        ),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                    )
                )
                );
              }
            },
            leading:
            Icon(Icons.wysiwyg, size: 20.0, color: Colors.white),
            title: Text("Editar cadastro",
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
              if(appData.isPro == true) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PoliticadePrivacidade()));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                        },
                      ),
                      duration: Duration(seconds: 2),
                      content: Text('Você deve ser assinante para ter acesso a todos os recursos do app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/55,
                        ),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                    )
                )
                );
              }
            },
            leading:
            Icon(Icons.description, size: 20.0, color: Colors.white),
            title: Text("Política de privacidade",
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
              Fluttertoast.showToast(
                msg:'Logout efetuado com sucesso.',
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 5,
              );
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
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

  void carregarInfos() {
    dbProfissional = db2.reference().child('atendimentos');
    dbProfissional.onChildAdded.listen(_gravarProfissional);
    dbProfissional.onChildChanged.listen(_updateProfissional);
    dbProfissional.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      Profissional prof = new Profissional(values['nome'], values['telefone'],
          values['email'], values['areaAtuacao'], values['usuario'],
          values['imageURL'], values['facebook'], values['instagram'],
          values['num_conselho'], snapshot.value['domingo'], snapshot.value['segunda'],
          snapshot.value['terca'], snapshot.value['quarta'], snapshot.value['quinta'],
          snapshot.value['sexta'], snapshot.value['sabado'], values['horarios'], values['assinante']);
      if(prof.nome != null) {
        listaProfissional.add(prof);
      }
    });

    dbPacientes = db.reference().child('atendimentos/${profissional.usuario}/pacientes');
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

  Future<void> initPlatformState() async {
    appData.isPro = false;

    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("DJJaRnCSTAaKSZyiIGlanyjcHkalioBY");

    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print(purchaserInfo.toString());
      if (purchaserInfo.entitlements.all['VIP'] != null) {
        appData.isPro = purchaserInfo.entitlements.all['VIP'].isActive;
      } else {
        appData.isPro = false;
      }
    } on PlatformException catch (e) {
      print(e);
    }

    print('#### is user pro? ${appData.isPro}');
  }

  void _retrieveCalendars(Paciente paciente) async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          print('permissão não concedida');
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      setState(() {
        _calendars = calendarsResult?.data;
        for(int i = 0; i < _calendars.length; i++) {
          if(_calendars[i].name == profissional.email) {
            calendarioEscolhido = _calendars[i];
          }
        }

        int hora = int.parse(paciente.hora.substring(0, 2));
        int minuto = int.parse(paciente.hora.substring(paciente.hora.length-2, paciente.hora.length - 1));
        salvarnoCalendario(paciente, calendarioEscolhido, converterData(paciente.data), hora, minuto);

      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  DateTime datadoEvento(DateTime data, String horario) {
    horario = horario.substring(0, horario.length - 1);
    int hora = int.parse(horario.substring(0, 2));
    int minuto = int.parse(horario.substring(horario.length-2, horario.length - 1));
    DateTime datadoEvento = new DateTime(data.year, data.month, data.day, hora, minuto);
    return datadoEvento;
  }

  void salvarnoCalendario(Paciente paciente, calendar.Calendar calendario, DateTime dataInicial, int hora, int minuto) async {
    calendar.Event event;
    DateTime _startDate;
    DateTime _endDate;

    _startDate = new DateTime(dataInicial.year, dataInicial.month, dataInicial.day, hora, minuto);
    _endDate = new DateTime(dataInicial.year, dataInicial.month, dataInicial.day, hora + 1, minuto);

    event = calendar.Event(calendario.id, title: 'Consulta de ${paciente.nome}',
        description: 'Consulta com ${profissional.nome} no dia ${dataInicial.day}/${dataInicial.month}/${dataInicial.year} às $hora:$minuto',
        start: _startDate, end: _endDate);

    /*setState(() {
      = event;
    });*/

    if (event == null) {
      event = calendar.Event(calendario.id, title: 'Consulta de ${paciente.nome}',
          description: 'Consulta de ${paciente.nome} no dia ${dataInicial.day}/${dataInicial.month}/${dataInicial.year} às $hora:$minuto',
          start: _startDate, end: _endDate);
    } else {
      var createEventResult =
      await _deviceCalendarPlugin.createOrUpdateEvent(event);
      if (createEventResult.isSuccess) {
        setState(() {
          paciente.confirmado = true;
          atualizarPaciente(paciente);
        });
      } else {
        print('não criou o evento no calendário de ${calendario.name}');
//        showInSnackBar(createEventResult.errorMessages.join(' | '));
      }

      Fluttertoast.showToast(
        msg:'Consulta salva no calendário do seu celular.',
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    }
  }

  void atualizarPaciente(Paciente paciente) async {
    await dbPacientes.child(paciente.primaryKey).update({
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