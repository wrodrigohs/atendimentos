import 'package:atendimentos/model/paciente.dart';
import 'package:atendimentos/model/profissional.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Paciente> listaPacientes = List();
  final _nomeController = TextEditingController();
  TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String dataString;
  String horaSelecionada = null;
  String paisOrigem = 'BR';
  String tel;
  PhoneNumber numero = PhoneNumber(isoCode: 'BR');
  var maskTextInputFormatter = MaskTextInputFormatter(
      mask: "xxxxxxxxxxx", filter: {"x": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();

    _nomeController.clear();
    _telefoneController.text = '';
    _emailController.clear();
    _dataEscolhida = null;
    horaSelecionada = null;

    for(int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
    }

    paciente = new Paciente("", "", "", "", "", "", false);
    dbReference = db.reference().child('${widget.profissional.usuario}/pacientes');
    dbReference.onChildAdded.listen(_gravar);
    dbReference.onChildChanged.listen(_update);
    dbReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      Paciente paciente = new Paciente(
          values['nome'], values['telefone'], values['email'],
          values['data'], values['hora'], values['anotacao'], values['confirmado']);
      listaPacientes.add(paciente);
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
                image: AssetImage("assets/images/homebg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            height: double.infinity,
            child: SingleChildScrollView(
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
                                  hintStyle: TextStyle(color: Colors.white, fontFamily: 'quicksand', fontSize: MediaQuery.of(context).size.height/50,),
                                  labelText: "Nome",
                                  labelStyle: TextStyle(color: Colors.white, fontFamily: 'quicksand', fontSize: MediaQuery.of(context).size.height/50,),
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
                                        fontSize: MediaQuery.of(context).size.height/50,
                                        fontFamily: 'quicksand',
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
                                        fontSize: MediaQuery.of(context).size.height/60,
                                        fontFamily: 'quicksand',
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
                                        fontSize: MediaQuery.of(context).size.height/50,
                                        fontFamily: 'quicksand',
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
                                        fontSize: MediaQuery.of(context).size.height/60,
                                        fontFamily: 'quicksand',
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
                                        Navigator.of(context).push(
                                          showPicker(
                                            accentColor: Theme.of(context).accentColor,
                                            blurredBackground: true,
                                            cancelText: 'cancelar',
                                            okText: 'Escolher',
                                            unselectedColor: Colors.grey,
                                            context: context,
                                            value: _time,
                                            onChange: onTimeChanged,
                                            is24HrFormat: true,
                                            // Optional onChange to receive value as DateTime
                                            onChangeDateTime: (DateTime dateTime) {
                                              //print(dateTime);
                                            },
                                          ),
                                        );
                                        //inputTimeSelect();
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
                                  if(dataString == '' || dataString == null || dataString.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: 'Você deve escolher uma data.',
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 5,
                                    );
                                    return;
                                  }

                                  if(horaSelecionada == '' || horaSelecionada == null || horaSelecionada.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: 'Você deve escolher um horário.',
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 5,
                                    );
                                    return;
                                  }

                                  if (formKey.currentState.validate()) {
                                    formKey.currentState.save();
                                    Paciente paciente = new Paciente(
                                        _nomeController.text.toString(),
                                        tel,
                                        _emailController.text.toString(),
                                        dataString, horaSelecionada, "Anotações sobre o atendimento de ${_nomeController.text.toString()} no dia $dataString às $horaSelecionada\n\n", false);

                                    validar(paciente);
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
          ),
        )
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

  void updatePaciente(Paciente paciente) {
    //Toggle completed
    //paciente.completed = !paciente.completed;
    if (paciente != null) {
      dbReference.child(paciente.primaryKey).set(paciente.toJson());
    }
  }

  void _submit(Paciente paciente) async {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      //form.reset();

      //Paciente paciente = new Paciente(_nomeController.text.toString(), dia, mes, ano, dropdownValue);
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

    Fluttertoast.showToast(
      msg: 'Consulta marcada.',
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 5,
    );

    /*Navigator.push(context, MaterialPageRoute(builder: (context) =>
        Consultas(paciente: paciente)));*/
    Navigator.of(context).pop();
  }

  void validar(Paciente paciente) {
    for(int i = 0; i < listaPacientes.length; i++) {
      if (((paciente.data) == (listaPacientes[i].data)) && ((paciente.hora) == (listaPacientes[i].hora))) {
        Fluttertoast.showToast(
          msg: 'Horário já escolhido. Por favor selecione outro.',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 5,
        );
        return;
      }
    }
    _submit(paciente);
  }

  void remover(String id, int index) {
    //String indice = index.toString();
    setState(() {
      listaPacientes.removeAt(index);
      //listaPacientes.remove(paciente);
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

  /*void convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate);
    print(todayDate);
    print(formatDate(todayDate, [yyyy, '/', mm, '/', dd, ' ', hh, ':', nn, ':', ss, ' ', am]));
  }*/

  void _presentDatePicker() {
    DateTime now = DateTime.now();
    DateTime currentTime = new DateTime(now.year);
    DateTime nextYear = new DateTime(now.year + 2);
    showDatePicker(
      context: context,
      initialDate: checarFDS(now),//now.weekday == 6 || now.weekday == 7 ? now.add(new Duration(days: 2)) : now,//|| now.weekday == 7 ? false : true,//checarFDS(), //initialvalue NÃO pode ser sábado ou domingo porque
      //CONFLITA com o selectableDayPredicate e causa erro
      firstDate: DateTime.now().subtract(new Duration(days: 0)),
      lastDate: nextYear,
      selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true, //exclui sábado e domingo
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF3B4E61),
            accentColor: const Color(0xFF3B4E61),
            colorScheme: ColorScheme.light(primary: const Color(0xFF3B4E61)),
            buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary
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

  /*void _presentDatePicker() {
    DateTime now = DateTime.now();
    DateTime currentTime = new DateTime(now.year);
    DateTime nextYear = new DateTime(now.year + 2);
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: nextYear,
      selectableDayPredicate: (DateTime val) =>
      val.weekday == 6 || val.weekday == 7 ? false : true,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
              //primarySwatch: const Color(0xFF000000),//OK/Cancel button text color
              primaryColor: const Color(0xFF3B4E61), //Head background
              accentColor: const Color(0xFF3B4E61),
              buttonColor: const Color(0xFFFF0000),
              backgroundColor: const Color(0xFFAA00DE) //selection color
              //dialogBackgroundColor: Colors.white,//Background color
              ),
          child: child,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _dataEscolhida = pickedDate;
        String formattedDate = DateFormat('dd-MM-yyyy').format(_dataEscolhida);
        dataString = dateFormat.format(_dataEscolhida);
        return dataString;
      });
    });
    //return formattedDate;
  }*/

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Digite um e-mail válido.';
    else
      return null;
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
                      style: TextStyle(color: Colors.black,
                          fontSize: 18.0),
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
                          child: Text(
                            "${paciente.nome},\nsua consulta de ${paciente
                                .data} às ${paciente
                                .hora} só será CONFIRMADA após o envio do comprovante de pagamento.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                            ),
                          ),
                        ),
                        FlatButton(
                          color: Colors.black,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontFamily: 'quicksand',
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                      ]
                  ),
                ],
              ),
            ),
          );
        });
  }

  DateTime checarFDS(DateTime now) {
    if(now.weekday == 6) {
      now = now.add(new Duration(days: 2));
    }

    if(now.weekday == 7) {
      now = now.add(new Duration(days: 1));
    }

    return now;
  }
}