import 'package:atendimentos/model/profissional.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;

class Cadastro extends StatefulWidget {
  Profissional profissional;
  Cadastro({Key key, this.profissional}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  Profissional profissional;
  DatabaseReference dbReference;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Profissional> listaProfissional = List();
  final _nomeController = TextEditingController();
  TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _areaAtuacaoController = TextEditingController();

  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String dataString;
  String horaSelecionada = null;
  String paisOrigem = 'BR';
  String tel;
  //PhoneNumber numero = PhoneNumber(isoCode: 'BR');
  //var maskTextInputFormatter = MaskTextInputFormatter(mask: "xxxxxxxxxxx", filter: {"x": RegExp(r'[0-9]')});

  TimeOfDay _time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    for(int i = 0; i < listaProfissional.length; i++) {
      listaProfissional.removeAt(i);
    }

    _nomeController.text = widget.profissional.nome;
    _emailController.text = widget.profissional.email;
    //paciente = new Paciente("", "", "", "", "", "", false);
    dbReference = db.reference().child('${widget.profissional.usuario}');
    dbReference.onChildAdded.listen(_gravar);
    dbReference.onChildChanged.listen(_update);
    dbReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      /*Paciente paciente = new Paciente(
          values['nome'], values['telefone'], values['email'],
          values['data'], values['hora'], values['anotacao'], values['confirmado']);
      listaPacientes.add(paciente);*/
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Profissional profissional = new Profissional(widget.profissional.nome, "", widget.profissional.email, "", widget.profissional.usuario, widget.profissional.assinante);

    return Scaffold(
      body: Stack(children: <Widget>[
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Color(0x44000000),
            elevation: 0.0,
            centerTitle: true,
            title: Text('Cadastro'),
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
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 100.0),
                        Flexible(
                          child: ListTile(
                            leading: Icon(Icons.account_box, color: Colors.white),
                            title: TextFormField(
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
                              controller: _nomeController,
                              onSaved: (nome) => profissional.nome = nome,
                              validator: (nome) =>
                              nome.length < 3
                                  ? "Deve ter ao menos 3 caracteres."
                                  : null,
                              cursorColor: Theme.of(context).accentColor,
                              onFieldSubmitted: (_) {
                                setState(() {
                                  profissional.nome = _nomeController.text.toString();
                                });
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 3.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                enabledBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                                ),
                                hintText: "Nome completo",
                                hintStyle: TextStyle(
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
                                labelText: "Nome",
                                labelStyle: TextStyle(
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
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 3.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        /*ListTile(
                      leading: Icon(Icons.phone, color: Theme.of(context).accentColor),
                      title: InternationalPhoneNumberInput(
                        maxLength: 15,
                        textStyle: Theme.of(context).textTheme.subtitle1,
                        textFieldController: _telefoneController,
                        autoValidate: false,
                        inputDecoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).accentColor, width: 3.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0),
                          ),
                          hintText: "xx xxxxx xxxx",
                          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                          labelText: "WhatsApp/Telefone",
                          labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                          errorBorder: OutlineInputBorder(
                            borderSide:
                            new BorderSide(color: Colors.red, width: 3.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        countries: ['BR'],//, 'PT', 'US', 'GB-NIR', 'ES', 'GB'],
                        locale: 'BR',
                        onInputChanged: (phone) {
                          tel = '${phone.dialCode.toString()}' +
                              '${_telefoneController.text}';
                        },
                      ),
                    ),*/
                        ListTile(
                          leading: Icon(
                              Icons.alternate_email, color: Colors.white),
                          title: TextFormField(
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
                            controller: _emailController,
                            onSaved: (email) => profissional.email = email,
                            //validator: validateEmail,
                            cursorColor: Theme.of(context).accentColor,
                            onFieldSubmitted: (_) {
                              setState(() {
                                profissional.email = _emailController.text.toString();
                              });
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 3.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.white, width: 2.0),
                              ),
                              hintText: "Digite seu e-mail",
                              hintStyle: TextStyle(
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
                              labelText: "E-mail",
                              labelStyle: TextStyle(
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
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.red, width: 3.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                              Icons.attach_money, color: Colors.white),
                          title: TextFormField(
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
                            controller: _areaAtuacaoController,
                            onSaved: (area) => profissional.areaAtuacao = area,
                            //validator: validateEmail,
                            cursorColor: Theme.of(context).accentColor,
                            onFieldSubmitted: (_) {
                              setState(() {
                                profissional.areaAtuacao = _areaAtuacaoController.text.toString();
                              });
                            },
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 3.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.white, width: 2.0),
                              ),
                              hintText: "Digite sua área profissional",
                              hintStyle: TextStyle(
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
                              labelText: "Área de atuação",
                              labelStyle: TextStyle(
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
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.red, width: 3.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        /*ListTile(
                      leading: Icon(Icons.date_range, color: Theme.of(context).accentColor),
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
                                    color: Theme.of(context).accentColor,
                                    fontFamily: 'notosans'
                                ),
                              ),
                            ),
                            FlatButton(
                              textColor: Theme.of(context).accentColor,
                              child: Text(
                                'Escolher data',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontFamily: 'notosans',
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 1,
                                      style: BorderStyle.solid
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
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
                      leading: Icon(Icons.alarm, color: Theme.of(context).accentColor),
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
                                  color: Theme.of(context).accentColor,
                                  fontFamily: 'notosans',
                                ),
                              ),
                            ),
                            FlatButton(
                              textColor: Theme.of(context).accentColor,
                              child: Text(
                                'Escolher hora',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontFamily: 'notosans',
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 1,
                                      style: BorderStyle.solid
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(
                                    showPicker(
                                      accentColor: Colors.blueGrey,
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
                    ),*/
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FlatButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                  style: BorderStyle.solid
                              ),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Text(
                              "Cadastrar",
                              style: TextStyle(
                                color: Colors.black,
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
                            onPressed: () {
                              setState(() {

                                if (formKey.currentState.validate()) {
                                  formKey.currentState.save();
                                  Profissional profissional = new Profissional(
                                      _nomeController.text.toString(),
                                      tel,
                                      _emailController.text.toString(),
                                      _areaAtuacaoController.text.toString(),
                                      widget.profissional.usuario.toString(),
                                      false);

                                  _submit(profissional);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]
      ),
    );
  }

  void _gravar(Event event) {
    setState(() {
      listaProfissional.add(Profissional.fromSnapshot(event.snapshot));
    });
  }

  void _update(Event event) {
    var oldEntry = listaProfissional.singleWhere((entry) {
      return entry.primaryKey == event.snapshot.key;
    });

    setState(() {
      listaProfissional[listaProfissional.indexOf(oldEntry)] =
          Profissional.fromSnapshot(event.snapshot);
    });
  }

  void _submit(Profissional profissional) async {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      listaProfissional.add(profissional);
      //cria novo paciente a cada push
      dbReference.push().set(profissional.toJson());
    }

    form.reset();
    /*_nomeController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _dataEscolhida = null;
    horaSelecionada = null;*/

    Navigator.of(context).pop();
  }

/*void validar(Paciente paciente) {
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

  void convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate);
    print(todayDate);
    print(formatDate(todayDate, [yyyy, '/', mm, '/', dd, ' ', hh, ':', nn, ':', ss, ' ', am]));
  }

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
                              fontWeight: FontWeight.bold,
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
  }*/
}