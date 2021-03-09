import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:device_calendar/device_calendar.dart' as calendar;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'dart:ui' as ui;

final FirebaseDatabase db = FirebaseDatabase.instance;

class Agendar extends StatefulWidget {
  Paciente paciente;
  Profissional profissional;
  Agendar({Key key, this.paciente, this.profissional}) : super(key: key);

  @override
  _AgendarState createState() => _AgendarState();
}

class _AgendarState extends State<Agendar> {
  Paciente paciente;
  DatabaseReference dbReference;
  DateTime _dataEscolhida;
  List<Paciente> listaPacientes = List();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController _nomeController = TextEditingController();
  TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String dataString;
  String horaSelecionada = null;
  String paisOrigem = 'BR';
  String tel;
  PhoneNumber numero = PhoneNumber(isoCode: 'BR');

  calendar.DeviceCalendarPlugin _deviceCalendarPlugin;
  List<calendar.Calendar> calendarioCerto = List();
  calendar.Calendar calendarioEscolhido;
  List<calendar.Calendar> _calendars;

  List<bool> dias = List();

  _AgendarState() {
    _deviceCalendarPlugin = calendar.DeviceCalendarPlugin();
  }

  @override
  void initState() {
    super.initState();
    _retrieveCalendars();

    dias.add(widget.profissional.domingo);
    dias.add(widget.profissional.segunda);
    dias.add(widget.profissional.terca);
    dias.add(widget.profissional.quarta);
    dias.add(widget.profissional.quinta);
    dias.add(widget.profissional.sexta);
    dias.add(widget.profissional.sabado);

    _nomeController.clear();
    _telefoneController.text = '';
    _emailController.clear();
    _dataEscolhida = null;
    horaSelecionada = null;

    for(int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
    }

    paciente = new Paciente("", "", "", "", "", "", false);
    dbReference = db.reference().child('atendimentos/${widget.profissional.usuario}/pacientes');
    dbReference.onChildAdded.listen(_gravar);
    dbReference.onChildChanged.listen(_update);
    dbReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      Paciente paciente = new Paciente(
          values['nome'], values['telefone'], values['email'],
          values['data'], values['hora'], values['anotacao'], values['confirmado']);
      if(paciente.nome != null && paciente != null) {
        listaPacientes.add(paciente);
      }
    });
  }

  TimeOfDay _time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    double distancia = AppBar().preferredSize.height + 40;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(children: <Widget>[
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Color(0x44000000),
            elevation: 0.0,
            centerTitle: true,
            title: Text('Agendar atendimento',
              style: TextStyle(
                fontFamily: 'quicksand',
              ),
            ),
          ),
          body: Container(
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
                SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: distancia,
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Flexible(
                                child: ListTile(
                                  leading: Icon(Icons.account_box, color: Colors.white),
                                  title: TextFormField(
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'quicksand',
                                      fontSize: MediaQuery.of(context).size.height/50,
                                    ),
                                    controller: _nomeController,
                                    onSaved: (nome) => paciente.nome = nome,
                                    validator: (nome) => nome.length < 3 ? "Deve ter ao menos 3 caracteres." : null,
                                    cursorColor: Colors.white,
                                    keyboardType: TextInputType.text,
                                    onFieldSubmitted: (_) {
                                      setState(() {
                                        paciente.nome = _nomeController.text.toString();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(color: Colors.white, width: 3.0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      enabledBorder: new OutlineInputBorder(
                                        borderRadius: new BorderRadius.circular(8.0),
                                        borderSide:
                                        new BorderSide(color: Colors.white, width: 2.0),
                                      ),
                                      hintText: "Nome e sobrenome",
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
                                      ),
                                      labelText: "Nome",
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                              ListTile(
                                leading: Icon(Icons.phone, color: Colors.white),
                                title: InternationalPhoneNumberInput(
                                  //maxLength: 15,
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.height/50,
                                  ),
                                  textFieldController: _telefoneController,
                                  //autoValidate: false,
                                  //onInputValidated: (value) => validarTelefone(tel),
                                  //errorMessage: 'Número fora do padrão',
                                  inputDecoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Colors.white, width: 3.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    enabledBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(8.0),
                                      borderSide:
                                      new BorderSide(color: Colors.white, width: 2.0),
                                    ),
                                    hintText: "xx xxxxx xxxx",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'quicksand',
                                      fontSize: MediaQuery.of(context).size.height/50,
                                    ),
                                    labelText: "WhatsApp/Telefone",
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'quicksand',
                                      fontSize: MediaQuery.of(context).size.height/50,
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Colors.red, width: 3.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  locale: 'BR',
                                  countries: ['BR'],
                                  onInputChanged: (phone) {
                                    tel = '${phone.dialCode.toString()}' + '${_telefoneController.text}';
                                  },
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.alternate_email, color: Colors.white),
                                title: TextFormField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.height/50,
                                  ),
                                  controller: _emailController,
                                  onSaved: (email) => paciente.email = email,
                                  validator: validateEmail,
                                  cursorColor: Colors.white,
                                  onFieldSubmitted: (_) {
                                    setState(() {
                                      paciente.email = _emailController.text.toString();
                                    });
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Colors.white, width: 3.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    enabledBorder: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(8.0),
                                      borderSide:
                                      new BorderSide(color: Colors.white, width: 2.0),
                                    ),
                                    hintText: "Digite seu e-mail",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.height/50,
                                      fontFamily: 'quicksand',
                                    ),
                                    labelText: "E-mail",
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.height/50,
                                      fontFamily: 'quicksand',
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Colors.red, width: 3.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.date_range, color: Colors.white),
                                title: Container(
                                  height: 40,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          _dataEscolhida == null
                                              ? 'Data da consulta'
                                              : '${DateFormat.d().format(
                                              _dataEscolhida)}/${DateFormat.M().format(
                                              _dataEscolhida)}/${DateFormat.y().format(
                                              _dataEscolhida)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontSize: MediaQuery.of(context).size.height/50,
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                        color: Colors.black,
                                        textColor: Colors.white,
                                        child: Text(
                                          'Escolher data',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontSize: MediaQuery.of(context).size.height/60,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.black,
                                                width: 1,
                                                style: BorderStyle.solid
                                            ),
                                            borderRadius: BorderRadius.circular(40)
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _presentDatePicker();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.alarm, color: Colors.white),
                                title: Container(
                                  height: 40,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          horaSelecionada == null
                                              ? 'Hora da consulta'
                                              : '$horaSelecionada',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontSize: MediaQuery.of(context).size.height/50,
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                        color: Colors.black,
                                        textColor: Colors.white,
                                        child: Text(
                                          'Escolher hora',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontSize: MediaQuery.of(context).size.height/60,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.black,
                                                width: 1,
                                                style: BorderStyle.solid
                                            ),
                                            borderRadius: BorderRadius.circular(40)
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if(dataString == '' || dataString == null || dataString.isEmpty) {
                                              WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
                                                  SnackBar(
                                                    duration: Duration(seconds: 2),
                                                    content: Text('Você deve escolher uma data antes',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'quicksand',
                                                        fontSize: MediaQuery.of(context).size.height/50,
                                                      ),
                                                    ),
                                                    backgroundColor: Colors.black,
                                                    behavior: SnackBarBehavior.floating,
                                                  )
                                              )
                                              );
                                              return;
                                            }
                                            _dialogHorarios(context);
                                          });
                                        },
                                      ),
                                    ],
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
                                      if (dataString == '' ||
                                          dataString == null ||
                                          dataString.isEmpty) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) =>
                                            _scaffoldKey.currentState
                                                .showSnackBar(
                                                SnackBar(
                                                  duration: Duration(
                                                      seconds: 2),
                                                  content: Text(
                                                    'Você deve escolher uma data antes',
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
                                        return;
                                      }

                                      if (horaSelecionada == '' ||
                                          horaSelecionada == null ||
                                          horaSelecionada.isEmpty) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) =>
                                            _scaffoldKey.currentState
                                                .showSnackBar(
                                                SnackBar(
                                                  duration: Duration(
                                                      seconds: 2),
                                                  content: Text(
                                                    'Você deve escolher um horário',
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
                                        return;
                                      }

                                      if (formKey.currentState.validate()) {
                                        formKey.currentState.save();
                                        Paciente paciente = new Paciente(
                                            _nomeController.text.toString(),
                                            tel,
                                            _emailController.text.toString(),
                                            dataString,
                                            horaSelecionada,
                                            "Anotações sobre o atendimento de ${_nomeController
                                                .text
                                                .toString()} no dia $dataString às $horaSelecionada\n\n",
                                            true);
                                        int hora = int.parse(horaSelecionada.substring(0, 2));
                                        int minuto = int.parse(horaSelecionada.substring(horaSelecionada.length - 2, horaSelecionada.length - 1));
//                                        print('hora = $hora minuto = $minuto');
                                        salvarnoCalendario(converterData(dataString), hora, minuto, paciente);
                                        _submit(paciente);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                  ),
                ),
              ],
            ),
          ),
        )
      ],
      ),
    );
  }

  void _retrieveCalendars() async {
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
          if(_calendars[i].name == widget.profissional.email) {
            calendarioEscolhido = _calendars[i];
          }
        }

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

  void updatePaciente(Paciente paciente) {
    if (paciente != null) {
      dbReference.child(paciente.primaryKey).set(paciente.toJson());
    }
  }

  void _submit(Paciente paciente) async {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();

      listaPacientes.add(paciente);
      //cria novo paciente a cada push
      dbReference.push().set(paciente.toJson());
    }
    form.reset();
    _nomeController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _dataEscolhida = null;
    horaSelecionada = null;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Consulta marcada.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'quicksand',
              fontSize: MediaQuery.of(context).size.height/50,
            ),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        )
    )
    );

    Navigator.of(context).pop();
  }

  void remover(String id, int index) {
    setState(() {
      listaPacientes.removeAt(index);
      dbReference.child(id).remove().then((_) {
      });
    });
  }

  String onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
      horaSelecionada = formatTimeOfDay(_time);
      return horaSelecionada;
    });
  }

  void inputTimeSelect() async {
    TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              // change the border color
              primary: Colors.blueGrey,
              // change the text color
              onSurface: Colors.blueGrey,
            ),
            // button colors
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: Colors.blueGrey,
              ),
            ),
          ),
          child: child,
        );
      },
      // ignore: missing_return
    ).then((picked) {
      if (picked == null) {
        return;
      }
      setState(() {
        horaSelecionada = formatTimeOfDay(picked);
        return horaSelecionada;
      });
    });
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    //final format = DateFormat.jm();  //"6:00 AM"
    String formattedDate = DateFormat.Hm().format(dt);
    return formattedDate + 'h';
  }

  void _presentDatePicker() {
    DateTime now = DateTime.now();
    DateTime currentTime = new DateTime(now.year);
    DateTime nextYear = new DateTime(now.year + 2);
    showDatePicker(
      context: context,
      initialDate: dias[now.weekday - 1] == false ? now.add(Duration(days: 1)) : now,//checarDia(now),
      firstDate: DateTime.now().subtract(new Duration(days: 0)),
      lastDate: nextYear,
      selectableDayPredicate: (now) => dias[now.weekday - 1] == false ? false : true,/*(DateTime val) {
        val = DateTime.now();
        for(int i = 0; i < dias.length; i++) {
          if(dias[i] == false) {
            return false;
          } else {
            return true;
          }
        }*/
      // return true;
      /*for (int i = 0; i < widget.profissional.dias.length; i++) {
          if (widget.profissional.dias[i] == false) {
            if (val.weekday == i) {
              return false;
            } else {
              return true;
            }
          }
        }*/
      //},
      //_diasExcluidos(),
//        val.weekday == 6 || val.weekday == 7 ? false : true,
      //exclui sábado e domingo
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF000000),
            accentColor: Color(0xFF000000),
            colorScheme: ColorScheme.light(primary: Color(0xFF000000)),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      } else {
        setState(() {
          _dataEscolhida = pickedDate;
          dataString = dateFormat.format(_dataEscolhida);
          return dataString;
        });
      }
    });
    //return formattedDate;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Digite um e-mail válido.';
    else
      return null;
  }

  void _dialogHorarios(BuildContext context) async {
    widget.profissional.horarios.sort((a, b) => (a.compareTo(b)));
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
                          "Meus horários",
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
                          itemCount: widget.profissional.horarios.length,
                          itemBuilder: (BuildContext context, int posicao) {
                            return horaSelecionada != (widget.profissional.horarios[posicao]) ?
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
                                    title: Text('${widget.profissional.horarios[posicao]}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color: Colors.transparent), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      definirHorario(widget.profissional.horarios[posicao]);
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
                                    title: Text('${widget.profissional.horarios[posicao]}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color: Colors.green), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      definirHorario(widget.profissional.horarios[posicao]);
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

  void definirHorario(String horario) {
    setState(() {
      horaSelecionada = horario;
    });
  }


/*void removerHorario(String horario) {
    setState(() {
      horaSelecionada = horario;
    });
}*/

/*void _showDialog(BuildContext context, String dataString) async {
    List<String> horas = ['08:00h', '08:30h', '09:00h', '09:30h', '10:00h', '10:30h', '11:00h', '11:30h',
      '12:00h', '12:30h', '13:00h', '13:30h', '14:00h', '14:30h', '15:00h', '15:30h',
      '16:00h', '16:30h', '17:00h', '17:30h', '18:00h', '18:30h', '19:00h', '19:30h', '20:00h'];

    if(listaPacientes.isNotEmpty) {
      for (int i = 0; i < listaPacientes.length; i++) {
        if (((listaPacientes[i].data) == dataString)) {
          if(horas.contains(listaPacientes[i].hora)) {
            horas.remove('${listaPacientes[i].hora}');
          }
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
                          "Horários disponíveis",
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
                          itemCount: widget.profissional.horarios.length,
                          itemBuilder: (BuildContext context, int posicao) {
                            return horaSelecionada != widget.profissional.horarios[posicao] ?
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
                                      '${widget.profissional.horarios[posicao]}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color: Colors.transparent), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      horaSelecionada = widget.profissional.horarios[posicao];
                                      mudarHora(widget.profissional.horarios[posicao]);
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
                                      '${widget.profissional.horarios[posicao]}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand'
                                      ),
                                    ),
                                    leading: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Icon(Icons.done_all,
                                            color: Colors.green), // icon-2
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      horaSelecionada = widget.profissional.horarios[posicao];
                                      mudarHora(widget.profissional.horarios[posicao]);
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
  }*/

void mudarHora(String hora) {
  setState(() {
    horaSelecionada = hora;
  });
}

/*DateTime checarDia(DateTime now) {
    for(int i = 0; i < widget.profissional.dias.length; i++) {
      while(now.weekday == i && widget.profissional.dias[i] == false) {
        now = now.add(Duration(days: 1));
        i++;
      }
    }
    return now;
  }*/

DateTime converterData(String strDate){
  DateTime data = dateFormat.parse(strDate);
  return data;
}

void salvarnoCalendario(DateTime dataInicial, int hora, int minuto, Paciente paciente) async {
  print(calendarioEscolhido.id);
  print(calendarioEscolhido.name);
  calendar.Event event;
  DateTime _startDate;
  DateTime _endDate;

  _startDate = new DateTime(dataInicial.year, dataInicial.month, dataInicial.day, hora, minuto);
  _endDate = new DateTime(dataInicial.year, dataInicial.month, dataInicial.day, hora + 1, minuto);

  event = calendar.Event(calendarioEscolhido.id, title: 'Consulta de ${paciente.nome}',
      description: 'Consulta com ${widget.profissional.nome} no dia ${dataInicial.day}/${dataInicial.month}/${dataInicial.year} às $hora:$minuto',
      start: _startDate, end: _endDate);

  if (event == null) {
    event = calendar.Event(calendarioEscolhido.id, title: 'Consulta de ${paciente.nome}',
        description: 'Consulta de ${paciente.nome} no dia ${dataInicial.day}/${dataInicial.month}/${dataInicial.year} às ${dataInicial.hour}:${dataInicial.minute}',
        start: _startDate, end: _endDate);
  } else {

    var createEventResult =
    await _deviceCalendarPlugin.createOrUpdateEvent(event);
    if (createEventResult.isSuccess) {
//        Navigator.pop(context, true);
      print('Evento criado no calendário de ${calendarioEscolhido.name}');
    } else {
      print('não criou o evento no calendário de ${calendarioEscolhido.name}');
//        showInSnackBar(createEventResult.errorMessages.join(' | '));
    }

    Fluttertoast.showToast(
      msg:'Consulta salva no calendário do seu celular.',
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 5,
    );
  }
}
}