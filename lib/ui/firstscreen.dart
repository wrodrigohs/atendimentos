import 'dart:io';

import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/parental_gate.dart';
import 'package:atendimentos/ui/agendar.dart';
import 'package:atendimentos/ui/busca.dart';
import 'package:atendimentos/ui/cadastro.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:atendimentos/ui/consultas.dart';
import 'package:atendimentos/ui/edicao.dart';
import 'package:atendimentos/ui/home.dart';
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

import 'package:url_launcher/url_launcher.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;
final FirebaseDatabase db2 = FirebaseDatabase.instance;

class FirstScreen extends StatefulWidget {

  Profissional profissional;
  String tipo;
  bool presente;

  FirstScreen({Key key, this.profissional, this.tipo, this.presente}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  Profissional profissional = new Profissional(name, "", email, "", usuario, imageUrl, "", "", "",
      false, false, false, false, false, false, false, null, false);
  Profissional pro = new Profissional('', '', '', '', '', '', '', '', '',
      false, false, false, false, false, false, false, null, false);
  Paciente pac = new Paciente(name, "", email, imageUrl, "", "", "", false, "", false, false, false, false, false, "", false, "", false, "", "", "");
  List<Paciente> listaPacientes = List();
  List<Paciente> listaConsultas = List();
  List<Profissional> listaProfissional = List();
  DatabaseReference dbPacientes;
  DatabaseReference dbProfissional;
  bool presente;
  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String nomeBuscado;
  final TextEditingController _nomeController = TextEditingController();
  AuthService auth = new AuthService();
  bool isPro = true;
  int selectedIndex = 0;
  List<String> listaNomesProfissionais = List();
  List<String> listaAreasdeAtuacao = List();
  String dropdownValue;
  String urlImg;
  String nomeEscolhido;
  String areadoEscolhido;
  String area;

  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<SideMenuState> _endSideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  calendar.DeviceCalendarPlugin _deviceCalendarPlugin;
  List<calendar.Calendar> calendarioCerto = List();
  calendar.Calendar calendarioEscolhido;
  List<calendar.Calendar> _calendars;
  calendar.Event eventoApagado;
  double distancia;

  _FirstScreenState() {
    _deviceCalendarPlugin = calendar.DeviceCalendarPlugin();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    carregarInfos();

    if(widget.profissional != null) {
      profissional = widget.profissional;
    }

    for (int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.tipo == 'profissional') {
      return widgetPro();
    } else {
      return widgetPaciente();
    }
  }

  Widget widgetPro() {
    //verificação das minhas contas para acesso VIP
    if(email == 'aplicativoswr@gmail.com' || email == 'rodrigoicarsaojose@gmail.com'|| email == 'rodiisilva@gmail.com'
        || email == 'w.rodrigo@ufms.br' ) {
      appData.isPro = true;
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if(widget.presente == true) {
      setState(() {
        presente = widget.presente;
      });
    }

    listaPacientes.sort((a, b) => (((converterData(a.data)).compareTo(converterData(b.data)))));

    if (Platform.isIOS) {
      distancia = AppBar().preferredSize.height + 60;
    } else {
      distancia = AppBar().preferredSize.height + 40;
    }

    presente = verificaPresente();

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
//                            if(isPro == true) {
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
                  title: Text('Consultório online',
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
//                        child: isPro == false ?
                        child: appData.isPro == false && pro.assinante == false && presente == false ?
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    color: Colors.white,
                                    width: 1,
                                    style: BorderStyle.solid
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              onPressed: () {
                                if(appData.isPro == false) {
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
                                            fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                          ),
                                        ),
                                        backgroundColor: Colors.black,
                                        behavior: SnackBarBehavior.floating,
                                      )
                                  )
                                  );
                                } else {
                                  Navigator.pushReplacement(context, MaterialPageRoute(
                                      builder: (BuildContext context) => super.widget));
                                }
                              },
                              child: Text(
                                "Área do assinante",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    color: Colors.white,
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
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                        //EX-ASSINANTE PODE VER AS CONSULTAS MARCADAS, MAS SÓ ISSO.
                        (appData.isPro == false && pro.assinante == false) == true && presente == true ?
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: distancia,
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width / 3,
                                height: MediaQuery.of(context).size.height / 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFF0D47A1),
                                      Color(0xFF1976D2),
                                      Color(0xFF42A5F5),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: FlatButton(
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.transparent,
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
                                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                            ),
                            listaPacientes.isEmpty ?
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Text('Nenhum atendimento marcado',
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
                                        onTap: () {
                                          String phone = '${listaPacientes[posicao].telefone}';
                                          String message = 'Olá, ${listaPacientes[posicao].nome}, '
                                              'entro em contato para tratar da sua consulta de ${listaPacientes[posicao].data}'
                                              'às ${listaPacientes[posicao].hora}.';
                                          launchWhatsApp(phone: phone, message: message);
                                        },
                                        leading: listaPacientes[posicao].imageURL != null ?
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(listaPacientes[posicao].imageURL),
                                        )
                                            :
                                        CircleAvatar(
                                            child: Text(
                                              '${listaPacientes[posicao].nome.substring(0, 1).toUpperCase()}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'quicksand',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            backgroundColor: Colors.black
                                        ),
                                        title: Text(
                                          '${listaPacientes[posicao].nome}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontWeight: FontWeight.w300,
                                            fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${listaPacientes[posicao].data} às ${listaPacientes[posicao].hora}',
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
                                            listaPacientes[posicao].confirmado == false ?
                                            Visibility(
                                              visible: true,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                child: IconButton(
                                                  icon: Icon(Icons.calendar_today),
                                                  color: Colors.black,
                                                  onPressed: () {
                                                    if(appData.isPro == false) {
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
                                                                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                                              ),
                                                            ),
                                                            backgroundColor: Colors.black,
                                                            behavior: SnackBarBehavior.floating,
                                                          )
                                                      )
                                                      );
                                                    } else {
                                                      _retrieveCalendars(listaPacientes[posicao]);
                                                    }
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
                                                  if(appData.isPro == false) {
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
                                                              fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                                            ),
                                                          ),
                                                          backgroundColor: Colors.black,
                                                          behavior: SnackBarBehavior.floating,
                                                        )
                                                    )
                                                    );
                                                  } else {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                Edicao(
                                                                    paciente: listaPacientes[posicao],
                                                                    profissional: pro)));
                                                  }//Navigator.of(context).pop();
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
                                                  if(appData.isPro == false) {
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
                                                              fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
                                                            ),
                                                          ),
                                                          backgroundColor: Colors.black,
                                                          behavior: SnackBarBehavior.floating,
                                                        )
                                                    )
                                                    );
                                                  } else {
                                                    _showDialog(context,
                                                        listaPacientes[posicao],
                                                        posicao);
                                                  }//await _deviceCalendarPlugin.deleteEvent(_calendar.id, event.eventId);
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
                        )
                            :
                        //ISSO PERMITE QUE A CONTA SEJA UTILIZADA EM MAIS DE UM DISPOSITIVO SIMULTANEAMENTE
                        (appData.isPro == true || pro.assinante == true) && presente == false ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\nCadastre-se para ter acesso aos recursos do aplicativo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                    color: Colors.white,
                                    width: 1,
                                    style: BorderStyle.solid
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              onPressed: () {
                                for(int i = 0; i < listaProfissional.length; i++) {
                                  if(listaProfissional[i].email == email) {
                                    Navigator.pushReplacement(context, MaterialPageRoute(
                                        builder: (BuildContext context) => super.widget));
                                    Fluttertoast.showToast(
                                      msg:'Você já se cadastrou.',
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 5,
                                    );
                                    return;
                                  }
                                }

                                if(presente == false) {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Cadastro(profissional: profissional, email: email)),
                                  );
                                }
                              },
                              child: Text(
                                "Cadastre-se",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                          ],
                        )
                            :
                        (appData.isPro == true || pro.assinante == true)
                            && presente == true && listaPacientes.length <= 0 ?
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
                                FlatButton(
                                    color: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.white,
                                          width: 1,
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Text(
                                      "Marcar atendimento",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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
                                            (context) => Agendar(profissional: pro, tipo: 'profissional',)));
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
                                        onTap: () {
                                          String phone = '${listaPacientes[posicao].telefone}';
                                          String message = 'Olá, ${listaPacientes[posicao].nome}, '
                                              'entro em contato para tratar da sua consulta de ${listaPacientes[posicao].data}'
                                              'às ${listaPacientes[posicao].hora}.';
                                          launchWhatsApp(phone: phone, message: message);
                                        },
                                        leading: listaPacientes[posicao].imageURL != null ?
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(listaPacientes[posicao].imageURL),
                                        )
                                            :
                                        CircleAvatar(
                                            child: Text(
                                              '${listaPacientes[posicao].nome.substring(0, 1).toUpperCase()}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'quicksand',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            backgroundColor: Colors.black
                                        ),
                                        title: Text(
                                          '${listaPacientes[posicao].nome}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontWeight: FontWeight.w300,
                                            fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${listaPacientes[posicao].data} às ${listaPacientes[posicao].hora}',
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
                                                      (context) => Edicao(paciente: listaPacientes[posicao], profissional: pro)));
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
            shape: CircleBorder(
                side: BorderSide(
                    color: Colors.white,
                    width: 1.0
                )
            ),
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
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
                        fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/50,
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
                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/55 : MediaQuery.of(context).size.height/55,
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
              if(email == 'aplicativoswr@gmail.com' //|| email == 'rodiisilva@gmail.com'
                  || email == 'w.rodrigo@ufms.br' || email == 'rodrigoicarsaojose@gmail.com') {
                appData.isPro = true;
              }
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
                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
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
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              if(email == 'aplicativoswr@gmail.com' //|| email == 'rodiisilva@gmail.com'
                  || email == 'w.rodrigo@ufms.br' || email == 'rodrigoicarsaojose@gmail.com') {
                appData.isPro = true;
              }
              if(appData.isPro == true) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Agendar(profissional: pro, tipo: 'profissional')));
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
                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
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
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              if(email == 'aplicativoswr@gmail.com' //|| email == 'rodiisilva@gmail.com'
                  || email == 'w.rodrigo@ufms.br' || email == 'rodrigoicarsaojose@gmail.com') {
                appData.isPro = true;
              }
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
                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
                        ),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                    )
                )
                );
              }
            },
            leading: Icon(Icons.assignment, size: 20.0, color: Colors.white),
            title: Text("Anotações/Prontuários",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              if(email == 'aplicativoswr@gmail.com' //|| email == 'rodiisilva@gmail.com'
                  || email == 'w.rodrigo@ufms.br' || email == 'rodrigoicarsaojose@gmail.com') {
                appData.isPro = true;
              }
              if(appData.isPro == true) {
                for(int i = 0; i < listaProfissional.length; i++) {
                  if(listaProfissional[i].email == email) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditarCadastro(profissional: pro,)));
                    return;
                  }
                }
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
                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
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
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PoliticadePrivacidade(tipo: widget.tipo)));
            },
            leading:
            Icon(Icons.description, size: 20.0, color: Colors.white),
            title: Text("Política de privacidade",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              for(int i = 0; i < listaProfissional.length; i++) {
                if(equalsIgnoreCase(listaProfissional[i].nome, pac.nome)
                    && equalsIgnoreCase(listaProfissional[i].email, pac.email)) {
                  Profissional profissional = listaProfissional[i];
                  _dialogRemocaoPermanenteProfissional(context, profissional, i);
                  return;
                }
              }
            },
            leading:
            Icon(Icons.delete, size: 20.0, color: Colors.red),
            title: Text("Requisitar exclusão permanente dos meus dados",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/55 : MediaQuery.of(context).size.height/55,
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
//              Navigator.of(context).pop();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
            },
            leading: Icon(Icons.exit_to_app, size: 20.0, color: Colors.white),
            title: Text("Sair",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
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

  Widget widgetPaciente() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (Platform.isIOS) {
      distancia = AppBar().preferredSize.height + 60;
    } else {
      distancia = AppBar().preferredSize.height + 40;
    }

    return SideMenu(
      key: _endSideMenuKey,
      inverse: true,
      type: SideMenuType.slideNRotate,
      menu: buildMenuPacientes(context),
      child: SideMenu(
        background: Colors.black,
        key: _sideMenuKey,
        menu: buildMenuPacientes(context),
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
                  title: Text('Consultório online',
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
                      mostrarWidget(selectedIndex, MediaQuery.of(context).size.height - distancia, MediaQuery.of(context).size.width),
                    ],
                  ),
                ),
                bottomNavigationBar: BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  color: Colors.black,
                  child: Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          //update the bottom app bar view each time an item is clicked
                          onPressed: () {
                            mostrarWidget(0, MediaQuery.of(context).size.height - distancia, MediaQuery.of(context).size.width);
                          },
                          iconSize: 27.0,
                          icon: Icon(
                            Icons.home,
                            color: selectedIndex == 0 ? Colors.cyan : Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            mostrarWidget(1, MediaQuery.of(context).size.height - distancia, MediaQuery.of(context).size.width);
                          },
                          iconSize: 27.0,
                          icon: Icon(
                            Icons.account_circle,
                            color: selectedIndex == 1 ? Colors.cyan : Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        IconButton(
                          onPressed: () {
                            mostrarWidget(2, MediaQuery.of(context).size.height - distancia, MediaQuery.of(context).size.width);
                          },
                          iconSize: 27.0,
                          icon: Icon(
                            Icons.calendar_today,
                            color: selectedIndex == 2 ? Colors.cyan : Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            signOutGoogle();
                            Fluttertoast.showToast(
                              msg:'Logout efetuado com sucesso.',
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIosWeb: 5,
                            );
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
                          },
                          iconSize: 27.0,
                          icon: Icon(
                            Icons.exit_to_app,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    setState(() {
                      for(int i = 0; i < listaProfissional.length; i++) {
                        if (equalsIgnoreCase(listaProfissional[i].nome, (pro.nome))) {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Agendar(paciente: pac,
                                  profissional: pro, tipo: widget.tipo)));
                          return;
                        } else {
                          WidgetsBinding.instance.addPostFrameCallback((_) =>
                              _scaffoldKey.currentState.showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text('Você deve escolher um profissional',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery
                                            .of(context)
                                            .size
                                            .height / 50,
                                      ),
                                    ),
                                    backgroundColor: Colors.black,
                                    behavior: SnackBarBehavior.floating,
                                  )
                              )
                          );
                        }
                      }
                    });
                  },
                  tooltip: 'Agendar atendimento',
                  child: Container(
                    margin: EdgeInsets.all(15.0),
                    child: Icon(Icons.add),
                  ),
                  elevation: 4.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuPacientes(BuildContext context) {
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
                        fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/50,
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
                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => PoliticadePrivacidade()));
            },
            leading:
            Icon(Icons.description, size: 20.0, color: Colors.white),
            title: Text("Política de privacidade",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
                fontFamily: 'quicksand',
              ),
            ),
            textColor: Colors.white,
            dense: true,
          ),
          LListItem(
            backgroundColor: Colors.transparent,
            onTap: () {
              for(int i = 0; i < listaPacientes.length; i++) {
                if(equalsIgnoreCase(listaPacientes[i].nome, pac.nome)
                    && equalsIgnoreCase(listaPacientes[i].email, pac.email)) {
                  Paciente paciente = listaPacientes[i];
                  _dialogRemocaoPermanente(context, paciente, i);
                }
              }
//              Navigator.push(context, MaterialPageRoute(builder: (context) => PoliticadePrivacidade()));
            },
            leading:
            Icon(Icons.delete, size: 20.0, color: Colors.red),
            title: Text("Requisitar exclusão permanente dos meus dados",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/55,
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
//              Navigator.of(context).pop();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
            },
            leading: Icon(Icons.exit_to_app, size: 20.0, color: Colors.white),
            title: Text("Sair",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/45 : MediaQuery.of(context).size.height/55,
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

  bool equalsIgnoreCase(String a, String b) =>
      (a == null && b == null) || (a != null && b != null && a.toLowerCase() == b.toLowerCase());


  Widget mostrarWidget(int index, double altura, double largura) {
    setState(() {
      selectedIndex = index;
    });

    switch(index) {
      case 0: return mostrarHome();
      case 1: return mostrarContatos(altura, largura);
      case 2: return mostrarConsultas(altura, largura);
    }
  }

  Widget mostrarHome() {

    if (Platform.isIOS) {
      distancia = AppBar().preferredSize.height + 60;
    } else {
      distancia = AppBar().preferredSize.height + 40;
    }

    //Remove profissionais NULL
    for (int i = 0; i < listaProfissional.length; i++) {
      if(listaProfissional[i] == null || listaProfissional[i].nome == null) {
        listaProfissional.removeAt(i);
      }
    }

    //Adiciona à listaAreasAtuacao as áreas de atuação dos profissionais cadastrados
    for (int i = 0; i < listaProfissional.length; i++) {
      if(listaProfissional[i].areaAtuacao != null) {
        listaAreasdeAtuacao.add(listaProfissional[i].areaAtuacao);
      }
    }

    for(int i = 0; i < listaAreasdeAtuacao.length; i++) {
      for(int j = i + 1; j < listaAreasdeAtuacao.length; j++) {
        if (equalsIgnoreCase(listaAreasdeAtuacao[i], listaAreasdeAtuacao[j])) {
          listaAreasdeAtuacao.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaAreasdeAtuacao.length; i++) {
      for(int j = i + 1; j < listaAreasdeAtuacao.length; j++) {
        if (equalsIgnoreCase(listaAreasdeAtuacao[i], listaAreasdeAtuacao[j])) {
          listaAreasdeAtuacao.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaAreasdeAtuacao.length; i++) {
      for(int j = i + 1; j < listaAreasdeAtuacao.length; j++) {
        if (equalsIgnoreCase(listaAreasdeAtuacao[i], listaAreasdeAtuacao[j])) {
          listaAreasdeAtuacao.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaAreasdeAtuacao.length; i++) {
      for(int j = i + 1; j < listaAreasdeAtuacao.length; j++) {
        if (equalsIgnoreCase(listaAreasdeAtuacao[i], listaAreasdeAtuacao[j])) {
          listaAreasdeAtuacao.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaAreasdeAtuacao.length; i++) {
      for(int j = i + 1; j < listaAreasdeAtuacao.length; j++) {
        if (equalsIgnoreCase(listaAreasdeAtuacao[i], listaAreasdeAtuacao[j])) {
          listaAreasdeAtuacao.removeAt(j);
        }
      }
    }

    listaAreasdeAtuacao.sort((a, b) => (a.compareTo(b)));

    return Container(
      height: MediaQuery.of(context).size.height/1.8,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: distancia,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      border: Border.all(color: Colors.transparent),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54,
                            blurRadius: 15
                        )
                      ]
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: DropdownButton<String>(
                        autofocus: true,
                        value: area,
                        icon: Icon(Icons.arrow_drop_down_circle,
                            color: Colors.black),
                        iconSize: 20,
                        elevation: 16,
                        isExpanded: true,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                        ),
                        underline: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: Colors.black
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            area = newValue;
                            _dialogProfissionais(context, area);
//                            Navigator.pushReplacement(context, MaterialPageRoute(
//                                builder: (BuildContext context) => super.widget));
                          });
                        },
                        items: listaAreasdeAtuacao.map((data) {
                          return DropdownMenuItem<String>(
                            child: new Text(data ?? ''),
                            value: data,
                          );
                        }).toList(),
                        hint: new Text("Escolha a área profissional",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'quicksand',
                          ),
                        ),
                      )
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  height: 10.0,
                ),
                pro != null ?
                Column(
                  children: [
                    pro.imageURL != null ?
                    CircleAvatar(
                      radius: 45.0,
                      backgroundImage:
                      NetworkImage(pro.imageURL),
                      backgroundColor: Colors.transparent,
                    )
                        :
                    CircleAvatar(
                      radius: 45.0,
                      backgroundColor: Colors.black,
                      child: Text('${pro.nome.substring(0, 1).toUpperCase()}',
                        style: TextStyle(
                            fontFamily: 'quicksand',
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('${pro.nome}',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/50,
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
                    Text('${pro.areaAtuacao}',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/50,
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
                    Text('${pro.num_conselho}',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/50,
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
                  ],
                )
                    :
                Container(),
                /*Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      border: Border.all(color: Colors.transparent),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black54, blurRadius: 15)
                      ]),
                  child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: DropdownButton<String>(
                        autofocus: true,
                        value: profissional,
                        icon: Icon(Icons.arrow_drop_down_circle,
                            color: Colors.black),
                        iconSize: 20,
                        elevation: 16,
                        isExpanded: true,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                        ),
                        underline: Container(
                            width: double.infinity,
                            height: 2,
                            color: Colors.black
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            profissional = newValue;
                            for(int i = 0; i < listaProfissionais.length; i++) {
                              if(equalsIgnoreCase(profissional, listaProfissionais[i].nome)) {
                                urlImg = listaProfissionais[i].imageURL;
                                pro = listaProfissionais[i];
                                receberImg(urlImg);
                                dbReferencePacientes = db.reference().child('atendimentos/${pro.usuario}/pacientes');
                                dbReferencePacientes.onChildAdded.listen(_gravar);
                                dbReferencePacientes.onChildChanged.listen(_update);
                                dbReferencePacientes.once().then((DataSnapshot snapshot) {
                                  Map<dynamic, dynamic> values = snapshot.value;
                                  Paciente paciente = new Paciente(values['nome'], values['telefone'],
                                      values['email'], values['data'], values['hora'], values['anotacao'],
                                      values['confirmado']);
                                  if(paciente.nome != null && (equalsIgnoreCase(paciente.nome, pac.nome))
                                      && (equalsIgnoreCase(paciente.email, pac.email))) {
                                    listaPacientes.add(paciente);
                                  }
                                });
                                return;
                              }
                            }
                            profissional = null;
                            area = null;
                            for(int i = 0; i < listaNomesProfissionais.length; i++) {
                              listaNomesProfissionais.removeAt(i);
                            }
                          });
                        },
                        items: listaNomesProfissionais.map((data) {
                          return DropdownMenuItem<String>(
                            onTap: () {
                              setState(() {
                                for(int i = 0; i < listaNomesProfissionais.length; i++) {
                                  listaNomesProfissionais.removeAt(i);
                                }
                              });
                            },
                            child: new Text(data ?? ''),
                            value: data,
                          );
                        }).toList(),
                        hint: new Text("Escolha o profissional",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'quicksand',
                            //fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                  ),
                ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _dialogProfissionais(BuildContext context, String area) async {

    for (int i = 0; i < listaNomesProfissionais.length; i++) {
      listaNomesProfissionais.removeAt(i);
    }

    for (int i = 0; i < listaProfissional.length; i++) {
      if((equalsIgnoreCase(area, listaProfissional[i].areaAtuacao)) == true) {
        listaNomesProfissionais.add(listaProfissional[i].nome);
      }
    }

    for (int i = 0; i < listaNomesProfissionais.length; i++) {
      for (int j = i + 1; j < listaNomesProfissionais.length; j++) {
        if ((equalsIgnoreCase(listaNomesProfissionais[i],
            listaNomesProfissionais[j])) == true) {
          listaNomesProfissionais.removeAt(j);
        }
      }
    }

    for (int i = 0; i < listaNomesProfissionais.length; i++) {
      for (int j = i + 1; j < listaNomesProfissionais.length; j++) {
        if ((equalsIgnoreCase(listaNomesProfissionais[i], listaNomesProfissionais[j])) == true) {
          listaNomesProfissionais.removeAt(j);
        }
      }
    }

    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState)
            {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                contentPadding: EdgeInsets.all(6.0),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          "Profissionais cadastrados",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 50,
                              fontFamily: 'quicksand'
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        height: 1.0,
                      ),
                      Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height / 4,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: listaNomesProfissionais.length,
                          itemBuilder: (BuildContext context, int posicao) {
                            return pro.nome != listaNomesProfissionais[posicao] ?
                            ListTile(
                                title: FlatButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      '${listaNomesProfissionais[posicao]}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color:Colors.transparent), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      for(int i = 0; i < listaProfissional.length; i++) {
                                        if(equalsIgnoreCase(listaProfissional[i].nome, listaNomesProfissionais[posicao])) {
                                          pro = listaProfissional[i];
                                          mudarPro(listaProfissional[i]);
                                          break;
                                        }
                                      }
                                    });
                                  },
                                )
                            )
                                :
                            ListTile(
                                title: FlatButton(
                                  color: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      '${listaNomesProfissionais[posicao]}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color:Colors.green), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      for (int i = 0; i < listaProfissional.length; i++) {
                                        if (equalsIgnoreCase(listaNomesProfissionais[posicao],
                                            listaProfissional[i].nome)) {
                                          mudarPro(listaProfissional[i]);
                                          break;
                                        }
                                      }
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) =>
                                          _scaffoldKey.currentState.showSnackBar(
                                              SnackBar(
                                                duration: Duration(seconds: 1),
                                                content: Text(
                                                  'Selecionou ${listaNomesProfissionais[posicao]}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'quicksand',
                                                    fontSize: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .height / 50,
                                                  ),
                                                ),
                                                backgroundColor: Colors.black,
                                                behavior: SnackBarBehavior
                                                    .floating,
                                              )
                                          )
                                      );
//                                      Navigator.of(context).pop();
                                    });
                                  },
                                )
                            );
                          },
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        height: 1.0,
                      ),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid
                            ),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        onPressed: () {
                          setState(() {
                            Navigator.of(context).pop();
                          });
                        },
                        color: Colors.black,
                        child: Text('OK',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'quicksand'
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Future<void> mudarPro(Profissional profissional) async {
    setState(() {
      pro = profissional;

      for(int i = 0; i < listaPacientes.length; i++) {
        listaPacientes.removeAt(i);
      }

      dbPacientes = db.reference().child('atendimentos/${pro.usuario}/pacientes');
      dbPacientes.onChildAdded.listen(_gravar);
      dbPacientes.onChildChanged.listen(_update);
      dbPacientes.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        Paciente paciente = new Paciente(
            values['nome'], values['telefone'], values['email'], values['imageURL'],
            values['data'], values['hora'], values['anotacao'], values['confirmado'],
            values['objetivo'], values['vegetariano'], values['bebidaAlcoolica'],
            values['fumante'], values['sedentario'], values['patologia'],
            values['nomePatologia'], values['medicamentos'], values['nomeMedicamentos'],
            values['alergia'], values['nomeAlergia'], values['sexo'], values['estadoCivil']
        );
        if((equalsIgnoreCase(paciente.nome, pac.nome)) &&
            (equalsIgnoreCase(paciente.email, pac.email))) {
          listaConsultas.add(paciente);
        }
      });
    });
  }

  Widget mostrarConsultas(double altura, largura) {

    for(int i = 0; i < listaPacientes.length; i++) {
      if(!(equalsIgnoreCase(listaPacientes[i].nome, pac.nome))) {
        listaPacientes.removeAt(i);
      }
    }

    for(int i = 0; i < listaPacientes.length; i++) {
      if(!(equalsIgnoreCase(listaPacientes[i].nome, pac.nome))) {
        listaPacientes.removeAt(i);
      }
    }

    for(int i = 0; i < listaPacientes.length; i++) {
      for (int j = i + 1; j < listaPacientes.length; j++) {
        if ((equalsIgnoreCase(listaPacientes[i].nome, listaPacientes[j].nome))
            &&
            (equalsIgnoreCase(listaPacientes[i].data, listaPacientes[j].data))
            && (equalsIgnoreCase(
                listaPacientes[i].hora, listaPacientes[j].hora))) {
          listaPacientes.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaPacientes.length; i++) {
      for (int j = i + 1; j < listaPacientes.length; j++) {
        if ((equalsIgnoreCase(listaPacientes[i].nome, listaPacientes[j].nome))
            &&
            (equalsIgnoreCase(listaPacientes[i].data, listaPacientes[j].data))
            && (equalsIgnoreCase(
                listaPacientes[i].hora, listaPacientes[j].hora))) {
          listaPacientes.removeAt(j);
        }
      }
    }

    for(int i = 0; i < listaPacientes.length; i++) {
      for (int j = i + 1; j < listaPacientes.length; j++) {
        if ((equalsIgnoreCase(listaPacientes[i].nome, listaPacientes[j].nome))
            &&
            (equalsIgnoreCase(listaPacientes[i].data, listaPacientes[j].data))
            && (equalsIgnoreCase(
                listaPacientes[i].hora, listaPacientes[j].hora))) {
          listaPacientes.removeAt(j);
        }
      }
    }

    if (Platform.isIOS) {
      distancia = AppBar().preferredSize.height + 60;
    } else {
      distancia = AppBar().preferredSize.height + 40;
    }

    listaPacientes.sort((a, b) => (((converterData(a.data)).compareTo(converterData(b.data)))));

    return listaPacientes.isEmpty ?
    Container(
      width: largura,
      height: altura,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: distancia,
          ),
          Text('\nNenhuma consulta marcada',
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
      ),
    )
        :
    SizedBox(
        width: largura,
        height: altura,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
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
                  leading: listaPacientes[posicao].imageURL != null ?
                  CircleAvatar(
                    backgroundImage: NetworkImage(listaPacientes[posicao].imageURL),
                  )
                      :
                  CircleAvatar(
                      child: Text(
                        '${listaPacientes[posicao].nome.substring(0, 1).toUpperCase()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: Colors.black
                  ),
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
                ),
              );
            })
    );
  }

  Widget mostrarContatos(double altura, double largura) {

    if (Platform.isIOS) {
      distancia = AppBar().preferredSize.height + 60;
    } else {
      distancia = AppBar().preferredSize.height + 40;
    }

    return pro.nome.isEmpty ?
    Container(
      width: largura/1.5,
      height: altura,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: distancia,
          ),
          Text('\nNão esqueça de selecionar um profissional',
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
            'assets/images/esqueceu.json',
            animate: true,
            repeat: true,
            reverse: true,
            width: 200,
            height: 200,
            fit: BoxFit.fill,
          ),
        ],
      ),
    )
        :
    Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: distancia,
        ),
        pro.imageURL != null ?
        CircleAvatar(
          radius: 45.0,
          backgroundImage:
          NetworkImage(pro.imageURL),
          backgroundColor: Colors.transparent,
        )
            :
        CircleAvatar(
          radius: 45.0,
          backgroundColor: Colors.black,
          child: Text('${pro.nome.substring(0, 1).toUpperCase()}',
            style: TextStyle(
                fontFamily: 'quicksand',
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/facebook.png'),
            backgroundColor: Colors.transparent,
          ),
          onTap: () {
            setState(() async {
              /*var url = '${pro.facebook}';
                if (await canLaunch(url)) {
                  await launch(url, universalLinksOnly: true);
                } else {
                  if (await canLaunch(url)) {
                    await launch(
                      url,
                      universalLinksOnly: false,
                    );
                  } else {
                    throw 'Houve um erro';
                  }
                }*/
              String fbProtocolUrl;
              if (Platform.isIOS) {
                if(pro.facebook == 'https://www.facebook.com/') {
                  WidgetsBinding.instance.addPostFrameCallback((_) =>
                      _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text('O profissional não cadastrou seu facebook.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery
                                    .of(context)
                                    .size
                                    .height / 50,
                              ),
                            ),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                          )
                      )
                  );
                } else {
                  fbProtocolUrl = 'fb://profile/${pro.facebook}';
                }
              } else {
                if(pro.facebook == 'https://www.facebook.com/') {
                  WidgetsBinding.instance.addPostFrameCallback((_) =>
                      _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text('O profissional não cadastrou seu facebook.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'quicksand',
                                fontSize: MediaQuery
                                    .of(context)
                                    .size
                                    .height / 50,
                              ),
                            ),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                          )
                      )
                  );
                } else {
                  fbProtocolUrl = 'fb://page/${pro.facebook}';
                }
              }

              String fallbackUrl = '${pro.facebook}';
              try {
                bool launched = await launch(fbProtocolUrl, forceWebView: true, forceSafariVC: false);

                if (!launched) {
                  await launch(fallbackUrl, forceSafariVC: false);
                }
              } catch (e) {
                await launch(fallbackUrl, forceSafariVC: false);
              }
            });
          },
          title: Text(
            'Facebook',
            style: TextStyle(
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
        ),
        SizedBox(
          height: 10,
        ),
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/instagram.png'),
            backgroundColor: Colors.transparent,
          ),
          onTap: () {
            setState(() async {
              String url;
              if(pro.instagram == 'https://www.instagram.com/') {
                WidgetsBinding.instance.addPostFrameCallback((_) =>
                    _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('O profissional não cadastrou seu instagram.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'quicksand',
                              fontSize: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 50,
                            ),
                          ),
                          backgroundColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                        )
                    )
                );
              } else {
                url = '${pro.instagram}';
                if (await canLaunch(url)) {
                  await launch(url, universalLinksOnly: true);
                } else {
                  if (await canLaunch(url)) {
                    await launch(
                      url,
                      universalLinksOnly: false,
                    );
                  } else {
                    throw 'Houve um erro';
                  }
                }
              }
            });
          },
          title: Text(
            'Instagram',
            style: TextStyle(
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
        ),
        SizedBox(
          height: 10,
        ),
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/whatsapp.png'),
            backgroundColor: Colors.transparent,
          ),
          onTap: () {
            String phone = '${pro.telefone}';
            String message = 'Olá, ${pro.nome}, entro em contato por meio do app \'Clínica online\'. Podemos conversar?';
            launchWhatsApp(phone: phone, message: message);
          },
          title: Text(
            'WhatsApp',
            style: TextStyle(
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
        ),
      ],
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

  void carregarInfos() async {
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
/*
    dbPacientes = db.reference().child('atendimentos/pacientes');
    dbPacientes.onChildAdded.listen(_gravarPacPresente);
    dbPacientes.onChildChanged.listen(_updatePacPresente);
    dbPacientes.once().then((DataSnapshot snapshot) {
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
        listaPacientesPresentes.add(paciente);
      }
    });*/
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

  void atualizarProfissional(Profissional profissional) {
    dbProfissional.child(profissional.primaryKey).update({
      "nome" : profissional.nome,
      "telefone" : profissional.telefone,
      "email" : profissional.email,
      "areaAtuacao" : profissional.areaAtuacao,
      "usuario" : profissional.usuario,
      "imageURL" : profissional.imageURL,
      "facebook" : profissional.facebook,
      "instagram" : profissional.instagram,
      "num_conselho" : profissional.num_conselho,
      "domingo" : profissional.domingo,
      "segunda" : profissional.segunda,
      "terca" : profissional.terca,
      "quarta" : profissional.quarta,
      "quinta" : profissional.quinta,
      "sexta" : profissional.sexta,
      "sabado" : profissional.sabado,
      "horarios" : profissional.horarios,
      "assinante" : profissional.assinante
    }).then((_) {
      //print('Transaction  committed.');
    });
    Navigator.of(context).pop();
  }

  DateTime converterData(String strDate){
    DateTime data = dateFormat.parse(strDate);
    return data;
  }

  void remover(String id, int index, Paciente paciente) {
    setState(() {
      listaPacientes.removeAt(index);
      dbPacientes.child(id).remove().then((_) {
      });
      Fluttertoast.showToast(
        msg:'Todos os seus dados foram excluídos com sucesso!',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 5,
      );
    });
  }

  void removerProfissional(String id, int index, Profissional profissional) {
    setState(() {
      listaProfissional.removeAt(index);
      dbProfissional.child(id).remove().then((_) {
      });
      Fluttertoast.showToast(
        msg:'Todos os seus dados foram excluídos com sucesso!',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 5,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (BuildContext context) => super.widget));
    });
  }

  void launchWhatsApp({@required String phone, @required String message}) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else if (Platform.isAndroid){
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      } else {
        setState(() async {
          var url = 'https://wa.me/$phone?text=$message';
          if (await canLaunch(url)) {
            await launch(
              url,
              universalLinksOnly: false,
            );
          } else {
            launch("sms://${phone}");
            throw 'Houve um erro';
          }
          //Navigator.of(context).pop();
        });
        return "";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      launch("sms://${phone}");
    }
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

  void _dialogRemocaoPermanente(BuildContext context, Paciente paciente, int posicao) async {
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
                            "Todos os seus dados serão APAGADOS PERMANENTEMENTE. Tem certeza disso?",
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
                                  signOutGoogle();
                                  Fluttertoast.showToast(
                                    msg:'Logout efetuado com sucesso.',
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 5,
                                  );
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
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

  void _dialogRemocaoPermanenteProfissional(BuildContext context, Profissional profissional, int posicao) async {
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
                            "Todos os seus dados serão APAGADOS PERMANENTEMENTE. Tem certeza disso?",
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
                                  removerProfissional(profissional.primaryKey, posicao, profissional);
                                  Navigator.of(context).pop();
                                  signOutGoogle();
                                  Fluttertoast.showToast(
                                    msg:'Logout efetuado com sucesso.',
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 5,
                                  );
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
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
                        fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
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

  bool verificaPresente() {
    bool presente = false;

    if(widget.tipo == 'profissional') {
      for(int i = 0; i < listaProfissional.length; i++) {
        if(equalsIgnoreCase(listaProfissional[i].email, email)) {
          setState(() {
            presente = true;
            pro = listaProfissional[i];
            if(appData.isPro == true && pro.assinante == false) {
              setState(() {
                pro.assinante = true;
                atualizarProfissional(pro);
              });
            } else if(appData.isPro == false && pro.assinante == true) {
              setState(() {
                pro.assinante = false;
                atualizarProfissional(pro);
              });
            }
          });
          return presente;
        }
      }
    } /*else {
      for(int i = 0; i < listaPacientesPresentes.length; i++) {
        if(equalsIgnoreCase(listaPacientesPresentes[i].email, email)) {
          setState(() {
            presente = true;
          });
          return presente;
        }
      }
    }*/

    return presente;
  }
}