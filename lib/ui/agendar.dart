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
  String tipo;
  Agendar({Key key, this.paciente, this.profissional, this.tipo}) : super(key: key);

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
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _objetivoController = TextEditingController();
  final TextEditingController _patologiaController = TextEditingController();
  final TextEditingController _medicamentoController = TextEditingController();
  final TextEditingController _alergiaController = TextEditingController();
  final TextEditingController _estadoCivilController = TextEditingController();

  DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_Br');
  String dataString;
  String horaSelecionada = null;
  String paisOrigem = 'BR';
  String tel;
  String sexo = 'Feminino';
  PhoneNumber numero = PhoneNumber(isoCode: 'BR');

  String objetivo;
  bool vegetariano = true;
  bool bebidaAlcoolica = true;
  bool fumante = true;
  bool sedentario = true;
  bool patologia = false;
  String nomePatologia;
  bool medicamento = false;
  String nomeMedicamento;
  String estadoCivil;
  bool alergia = false;

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

    dias.add(widget.profissional.segunda);
    dias.add(widget.profissional.terca);
    dias.add(widget.profissional.quarta);
    dias.add(widget.profissional.quinta);
    dias.add(widget.profissional.sexta);
    dias.add(widget.profissional.sabado);
    dias.add(widget.profissional.domingo);

    _nomeController.clear();
    _telefoneController.text = '';
    _emailController.clear();
    _dataEscolhida = null;
    horaSelecionada = null;

    if(widget.tipo == 'paciente') {
      _nomeController.text = widget.paciente.nome;
      _emailController.text = widget.paciente.email;
    }

    for(int i = 0; i < listaPacientes.length; i++) {
      listaPacientes.removeAt(i);
    }

    paciente = new Paciente("", "", "", "", "", "", "", false, "", false, false, false, false, false, "", false, "", false, "", "", "");
    dbReference = db.reference().child('atendimentos/${widget.profissional.usuario}/pacientes');
    dbReference.onChildAdded.listen(_gravar);
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
      if(paciente.nome != null && paciente != null) {
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
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width/1,
                  decoration: new BoxDecoration(color: Colors.black.withOpacity(0.0)),
                  child: new BackdropFilter(
                    filter: new ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    child: new Container(
                      decoration: new BoxDecoration(color: Colors.transparent.withOpacity(0.1)),
                    ),
                  ),
                ),
                widget.tipo == 'profissional' ?
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  // leading: Icon(Icons.account_box, color: Colors.white),
                                  title: TextFormField(
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                    readOnly: false,
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
                                      labelText: "Nome",
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50,
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
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(color: Colors.red, width: 3.0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  // leading: Icon(Icons.phone, color: Colors.white),
                                  title: InternationalPhoneNumberInput(
                                    //maxLength: 15,
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                      labelText: "WhatsApp/Telefone",
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50,
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  // leading: Icon(Icons.alternate_email, color: Colors.white),
                                  title: TextFormField(
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                    readOnly: false,
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
                                      labelText: "E-mail",
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context).size.height/50,
                                          fontFamily: 'quicksand',
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
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(color: Colors.red, width: 3.0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  // leading: Icon(Icons.account_box, color: Colors.white),
                                  title: TextFormField(
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                    controller: _estadoCivilController,
                                    onSaved: (estadoCivil) => paciente.estadoCivil = estadoCivil,
                                    validator: (estadoCivil) => estadoCivil.length < 3 ? "Não pode ficar em branco." : null,
                                    cursorColor: Colors.white,
                                    keyboardType: TextInputType.text,
                                    onFieldSubmitted: (_) {
                                      setState(() {
                                        paciente.estadoCivil = _estadoCivilController.text.toString();
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
                                      hintText: "Estado civil",
                                      hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50,
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
                                      labelText: "Estado civil",
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50,
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
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(color: Colors.red, width: 3.0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Sexo: ',
                                          style: new TextStyle(
                                              fontSize: MediaQuery.of(context).size.height/55,
                                              color: Colors.white,
                                              fontFamily: 'quicksand',
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
                                        Radio(
                                          value: 'Feminino',
                                          activeColor: Colors.cyanAccent,
                                          groupValue: sexo,
                                          onChanged: (val) {
                                            setState(() {
                                              sexo = 'Feminino';
                                            });
                                          },
                                        ),
                                        Text(
                                          'Feminino',
                                          style: new TextStyle(
                                              fontSize: MediaQuery.of(context).size.height/55,
                                              color: Colors.white,
                                              fontFamily: 'quicksand',
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
                                        Radio(
                                          value: 'Masculino',
                                          groupValue: sexo,
                                          activeColor: Colors.cyanAccent,
                                          onChanged: (val) {
                                            setState(() {
                                              sexo = 'Masculino';
                                            });
                                          },
                                        ),
                                        Text(
                                          'Masculino',
                                          style: new TextStyle(
                                              fontSize: MediaQuery.of(context).size.height/55,
                                              color: Colors.white,
                                              fontFamily: 'quicksand',
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
                                    ),
                                  ),
                                ),
                              ),
                              equalsIgnoreCase(widget.profissional.areaAtuacao, 'nutrição') ?
                              Visibility(
                                visible: true,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          // leading: Icon(Icons.adjust, color: Colors.white),
                                          title: TextFormField(
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'quicksand',
                                                fontSize: MediaQuery.of(context).size.height/50,
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
                                            controller: _objetivoController,
                                            onSaved: (objetivo) => paciente.objetivo = objetivo,
                                            validator: (objetivo) => objetivo.length < 3 ? "Não pode ficar em branco." : null,
                                            cursorColor: Colors.white,
                                            onFieldSubmitted: (_) {
                                              setState(() {
                                                paciente.objetivo = _objetivoController.text.toString();
                                              });
                                            },
                                            keyboardType: TextInputType.text,
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
                                              hintText: "Digite seu objetivo",
                                              hintStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: MediaQuery.of(context).size.height/50,
                                                  fontFamily: 'quicksand',
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
                                              labelText: "Objetivo",
                                              labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: MediaQuery.of(context).size.height/50,
                                                  fontFamily: 'quicksand',
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
                                              errorBorder: OutlineInputBorder(
                                                borderSide:
                                                const BorderSide(color: Colors.red, width: 3.0),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CheckboxListTile(
                                          checkColor: Colors.black,
                                          activeColor: Colors.white,
                                          selected: vegetariano ? true : false,
                                          title: Text('É vegetariano/vegano?',
                                            style: TextStyle(
                                                fontFamily: 'quicksand',
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.height/55,
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
                                          value: vegetariano,
                                          onChanged: (value) {
                                            setState(() {
                                              vegetariano = !vegetariano;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CheckboxListTile(
                                          checkColor: bebidaAlcoolica ? Colors.black : Colors.white,
                                          activeColor: bebidaAlcoolica ? Colors.white : Colors.white,
                                          selected: bebidaAlcoolica ? true : false,
                                          title: Text('Ingere bebida alcoólica?',
                                            style: TextStyle(
                                                fontFamily: 'quicksand',
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.height/55,
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
                                          value: bebidaAlcoolica,
                                          onChanged: (value) {
                                            setState(() {
                                              bebidaAlcoolica = !bebidaAlcoolica;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CheckboxListTile(
                                          checkColor: Colors.black,
                                          activeColor: Colors.white,
                                          selected: fumante ? true : false,
                                          title: Text('Você fuma?',
                                            style: TextStyle(
                                                fontFamily: 'quicksand',
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.height/55,
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
                                          value: fumante,
                                          onChanged: (value) {
                                            setState(() {
                                              fumante = !fumante;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CheckboxListTile(
                                          checkColor: Colors.black,
                                          activeColor: Colors.white,
                                          selected: sedentario ? true : false,
                                          title: Text('Pratica atividade física?',
                                            style: TextStyle(
                                                fontFamily: 'quicksand',
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.height/55,
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
                                          value: sedentario,
                                          onChanged: (value) {
                                            setState(() {
                                              sedentario = !sedentario;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text('Tem alguma patologia?',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: true,
                                                  activeColor: Colors.cyanAccent,
                                                  groupValue: patologia,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      patologia = true;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Sim',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: false,
                                                  groupValue: patologia,
                                                  activeColor: Colors.cyanAccent,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      patologia = false;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Não',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                            ),
                                          ),
                                        ),
                                      ),
                                      patologia == true ?
                                      Visibility(
                                        visible: true,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            // leading: Icon(Icons.adjust, color: Colors.white),
                                            title: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'quicksand',
                                                  fontSize: MediaQuery.of(context).size.height/50,
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
                                              controller: _patologiaController,
                                              onSaved: (patologia) => paciente.nomePatologia = patologia,
                                              validator: (patologia) => patologia.length < 3 ? "Não pode ficar em branco." : null,
                                              cursorColor: Colors.white,
                                              onFieldSubmitted: (_) {
                                                setState(() {
                                                  paciente.nomePatologia = _patologiaController.text.toString();
                                                });
                                              },
                                              keyboardType: TextInputType.text,
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
                                                hintText: "Digite sua(s) patologia(s)",
                                                hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                labelText: "Patologia",
                                                labelStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                errorBorder: OutlineInputBorder(
                                                  borderSide:
                                                  const BorderSide(color: Colors.red, width: 3.0),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          :
                                      Visibility(
                                        visible: false,
                                        child: Container(
                                          height: 0,
                                          width: 0,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text('Faz uso de algum medicamento?',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: true,
                                                  activeColor: Colors.cyanAccent,
                                                  groupValue: medicamento,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      medicamento = true;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Sim',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: false,
                                                  groupValue: medicamento,
                                                  activeColor: Colors.cyanAccent,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      medicamento = false;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Não',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                            ),
                                          ),
                                        ),
                                      ),
                                      medicamento == true ?
                                      Visibility(
                                        visible: true,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            // leading: Icon(Icons.adjust, color: Colors.white),
                                            title: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'quicksand',
                                                  fontSize: MediaQuery.of(context).size.height/50,
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
                                              controller: _medicamentoController,
                                              onSaved: (nomeMedicamentos) => paciente.nomeMedicamentos = nomeMedicamentos,
                                              validator: (nomeMedicamentos) => nomeMedicamentos.length < 3 ? "Não pode ficar em branco." : null,
                                              cursorColor: Colors.white,
                                              onFieldSubmitted: (_) {
                                                setState(() {
                                                  paciente.nomeMedicamentos = _medicamentoController.text.toString();
                                                });
                                              },
                                              keyboardType: TextInputType.text,
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
                                                hintText: "Digite seu(s) medicamento(s)",
                                                hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                labelText: "Medicamento(s)",
                                                labelStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                errorBorder: OutlineInputBorder(
                                                  borderSide:
                                                  const BorderSide(color: Colors.red, width: 3.0),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          :
                                      Visibility(
                                        visible: false,
                                        child: Container(
                                          height: 0,
                                          width: 0,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Alguma alergia?',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: true,
                                                  activeColor: Colors.cyanAccent,
                                                  groupValue: alergia,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      alergia = true;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Sim',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: false,
                                                  groupValue: alergia,
                                                  activeColor: Colors.cyanAccent,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      alergia = false;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Não',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                            ),
                                          ),
                                        ),
                                      ),
                                      alergia == true ?
                                      Visibility(
                                        visible: true,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            // leading: Icon(Icons.adjust, color: Colors.white),
                                            title: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'quicksand',
                                                  fontSize: MediaQuery.of(context).size.height/50,
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
                                              controller: _alergiaController,
                                              onSaved: (nomeAlergia) => paciente.nomeAlergia = nomeAlergia,
                                              validator: (nomeAlergia) => nomeAlergia.length < 3 ? "Não pode ficar em branco." : null,
                                              cursorColor: Colors.white,
                                              onFieldSubmitted: (_) {
                                                setState(() {
                                                  paciente.nomeAlergia = _alergiaController.text.toString();
                                                });
                                              },
                                              keyboardType: TextInputType.text,
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
                                                hintText: "Digite sua(s) alergia(s)",
                                                hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                labelText: "Alergia(s)",
                                                labelStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                errorBorder: OutlineInputBorder(
                                                  borderSide:
                                                  const BorderSide(color: Colors.red, width: 3.0),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          :
                                      Visibility(
                                        visible: false,
                                        child: Container(
                                          height: 0,
                                          width: 0,
                                        ),
                                      ),
                                    ]
                                ),
                              )
                                  :
                              Visibility(
                                visible: false,
                                child: Container(
                                  height: 0,
                                  width: 0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
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
                                        FlatButton(
                                          color: Colors.black,
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
                                                  color: Colors.white,
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
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
                                        FlatButton(
                                          color: Colors.black,
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
                                                  color: Colors.white,
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
                                              _dialogHorarios(context, dataString);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
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
                                      if(equalsIgnoreCase(widget.profissional.areaAtuacao, 'nutrição')) {
                                        Paciente paciente = new Paciente(
                                            _nomeController.text.toString(),
                                            tel,
                                            _emailController.text.toString(),
                                            null,
                                            dataString,
                                            horaSelecionada,
                                            "Anotações sobre o atendimento de ${_nomeController.text.toString()} no dia $dataString às $horaSelecionada\n\n",
                                            true,
                                            _objetivoController.text.toString(),
                                            vegetariano,
                                            bebidaAlcoolica,
                                            fumante,
                                            sedentario,
                                            patologia,
                                            _patologiaController.text.toString(),
                                            medicamento,
                                            _medicamentoController.text.toString(),
                                            alergia,
                                            _alergiaController.text.toString(),
                                            sexo,
                                            _estadoCivilController.text.toString()
                                        );
                                        int hora = int.parse(horaSelecionada.substring(0, 2));
                                        int minuto = int.parse(horaSelecionada.substring(horaSelecionada.length - 2, horaSelecionada.length - 1));
//                                        print('hora = $hora minuto = $minuto');
                                        salvarnoCalendario(converterData(dataString), hora, minuto, paciente);
                                        _submit(paciente);
                                      } else {
                                        Paciente paciente = new Paciente(
                                            _nomeController.text.toString(),
                                            tel,
                                            _emailController.text.toString(),
                                            null,
                                            dataString,
                                            horaSelecionada,
                                            "Anotações sobre o atendimento de ${_nomeController
                                                .text
                                                .toString()} no dia $dataString às $horaSelecionada\n\n",
                                            true, "", false, false, false, false, false,
                                            "", false, "", false, "", sexo, _estadoCivilController.text.toString());

                                        int hora = int.parse(horaSelecionada.substring(0, 2));
                                        int minuto = int.parse(horaSelecionada.substring(horaSelecionada.length - 2, horaSelecionada.length - 1));
                                        salvarnoCalendario(converterData(dataString), hora, minuto, paciente);
                                        _submit(paciente);
                                      }
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ]
                  ),
                )
                    :
                //PACIENTE AGENDANDO CONSULTA
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  // leading: Icon(Icons.account_box, color: Colors.white),
                                  title: TextFormField(
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                    readOnly: true,
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
                                      labelText: "Nome",
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50,
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
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(color: Colors.red, width: 3.0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  // leading: Icon(Icons.phone, color: Colors.white),
                                  title: InternationalPhoneNumberInput(
                                    //maxLength: 15,
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                      labelText: "WhatsApp/Telefone",
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50,
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  // leading: Icon(Icons.alternate_email, color: Colors.white),
                                  title: TextFormField(
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                    readOnly: true,
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
                                      labelText: "E-mail",
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context).size.height/50,
                                          fontFamily: 'quicksand',
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
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(color: Colors.red, width: 3.0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  // leading: Icon(Icons.account_box, color: Colors.white),
                                  title: TextFormField(
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'quicksand',
                                        fontSize: MediaQuery.of(context).size.height/50,
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
                                    controller: _estadoCivilController,
                                    onSaved: (estadoCivil) => paciente.estadoCivil = estadoCivil,
                                    validator: (estadoCivil) => estadoCivil.length < 3 ? "Não pode ficar em branco." : null,
                                    cursorColor: Colors.white,
                                    keyboardType: TextInputType.text,
                                    onFieldSubmitted: (_) {
                                      setState(() {
                                        paciente.estadoCivil = _estadoCivilController.text.toString();
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
                                      hintText: "Estado civil",
                                      hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50,
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
                                      labelText: "Estado civil",
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'quicksand',
                                          fontSize: MediaQuery.of(context).size.height/50,
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
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(color: Colors.red, width: 3.0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Sexo: ',
                                          style: new TextStyle(
                                              fontSize: MediaQuery.of(context).size.height/55,
                                              color: Colors.white,
                                              fontFamily: 'quicksand',
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
                                        Radio(
                                          value: 'Feminino',
                                          activeColor: Colors.cyanAccent,
                                          groupValue: sexo,
                                          onChanged: (val) {
                                            setState(() {
                                              sexo = 'Feminino';
                                            });
                                          },
                                        ),
                                        Text(
                                          'Feminino',
                                          style: new TextStyle(
                                              fontSize: MediaQuery.of(context).size.height/55,
                                              color: Colors.white,
                                              fontFamily: 'quicksand',
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
                                        Radio(
                                          value: 'Masculino',
                                          groupValue: sexo,
                                          activeColor: Colors.cyanAccent,
                                          onChanged: (val) {
                                            setState(() {
                                              sexo = 'Masculino';
                                            });
                                          },
                                        ),
                                        Text(
                                          'Masculino',
                                          style: new TextStyle(
                                              fontSize: MediaQuery.of(context).size.height/55,
                                              color: Colors.white,
                                              fontFamily: 'quicksand',
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
                                    ),
                                  ),
                                ),
                              ),
                              equalsIgnoreCase(widget.profissional.areaAtuacao, 'nutrição') ?
                              Visibility(
                                visible: true,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          // leading: Icon(Icons.adjust, color: Colors.white),
                                          title: TextFormField(
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'quicksand',
                                                fontSize: MediaQuery.of(context).size.height/50,
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
                                            controller: _objetivoController,
                                            onSaved: (objetivo) => paciente.objetivo = objetivo,
                                            validator: (objetivo) => objetivo.length < 3 ? "Não pode ficar em branco." : null,
                                            cursorColor: Colors.white,
                                            onFieldSubmitted: (_) {
                                              setState(() {
                                                paciente.objetivo = _objetivoController.text.toString();
                                              });
                                            },
                                            keyboardType: TextInputType.text,
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
                                              hintText: "Digite seu objetivo",
                                              hintStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: MediaQuery.of(context).size.height/50,
                                                  fontFamily: 'quicksand',
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
                                              labelText: "Objetivo",
                                              labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: MediaQuery.of(context).size.height/50,
                                                  fontFamily: 'quicksand',
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
                                              errorBorder: OutlineInputBorder(
                                                borderSide:
                                                const BorderSide(color: Colors.red, width: 3.0),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CheckboxListTile(
                                          checkColor: Colors.black,
                                          activeColor: Colors.white,
                                          selected: vegetariano ? true : false,
                                          title: Text('É vegetariano/vegano?',
                                            style: TextStyle(
                                                fontFamily: 'quicksand',
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.height/55,
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
                                          value: vegetariano,
                                          onChanged: (value) {
                                            setState(() {
                                              vegetariano = !vegetariano;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CheckboxListTile(
                                          checkColor: bebidaAlcoolica ? Colors.black : Colors.white,
                                          activeColor: bebidaAlcoolica ? Colors.white : Colors.white,
                                          selected: bebidaAlcoolica ? true : false,
                                          title: Text('Ingere bebida alcoólica?',
                                            style: TextStyle(
                                                fontFamily: 'quicksand',
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.height/55,
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
                                          value: bebidaAlcoolica,
                                          onChanged: (value) {
                                            setState(() {
                                              bebidaAlcoolica = !bebidaAlcoolica;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CheckboxListTile(
                                          checkColor: Colors.black,
                                          activeColor: Colors.white,
                                          selected: fumante ? true : false,
                                          title: Text('Você fuma?',
                                            style: TextStyle(
                                                fontFamily: 'quicksand',
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.height/55,
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
                                          value: fumante,
                                          onChanged: (value) {
                                            setState(() {
                                              fumante = !fumante;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CheckboxListTile(
                                          checkColor: Colors.black,
                                          activeColor: Colors.white,
                                          selected: sedentario ? true : false,
                                          title: Text('Pratica atividade física?',
                                            style: TextStyle(
                                                fontFamily: 'quicksand',
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.height/55,
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
                                          value: sedentario,
                                          onChanged: (value) {
                                            setState(() {
                                              sedentario = !sedentario;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text('Tem alguma patologia?',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: true,
                                                  activeColor: Colors.cyanAccent,
                                                  groupValue: patologia,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      patologia = true;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Sim',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: false,
                                                  groupValue: patologia,
                                                  activeColor: Colors.cyanAccent,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      patologia = false;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Não',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                            ),
                                          ),
                                        ),
                                      ),
                                      patologia == true ?
                                      Visibility(
                                        visible: true,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            // leading: Icon(Icons.adjust, color: Colors.white),
                                            title: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'quicksand',
                                                  fontSize: MediaQuery.of(context).size.height/50,
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
                                              controller: _patologiaController,
                                              onSaved: (patologia) => paciente.nomePatologia = patologia,
                                              validator: (patologia) => patologia.length < 3 ? "Não pode ficar em branco." : null,
                                              cursorColor: Colors.white,
                                              onFieldSubmitted: (_) {
                                                setState(() {
                                                  paciente.nomePatologia = _patologiaController.text.toString();
                                                });
                                              },
                                              keyboardType: TextInputType.text,
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
                                                hintText: "Digite sua(s) patologia(s)",
                                                hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                labelText: "Patologia",
                                                labelStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                errorBorder: OutlineInputBorder(
                                                  borderSide:
                                                  const BorderSide(color: Colors.red, width: 3.0),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          :
                                      Visibility(
                                        visible: false,
                                        child: Container(
                                          height: 0,
                                          width: 0,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text('Faz uso de algum medicamento?',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: true,
                                                  activeColor: Colors.cyanAccent,
                                                  groupValue: medicamento,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      medicamento = true;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Sim',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: false,
                                                  groupValue: medicamento,
                                                  activeColor: Colors.cyanAccent,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      medicamento = false;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Não',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                            ),
                                          ),
                                        ),
                                      ),
                                      medicamento == true ?
                                      Visibility(
                                        visible: true,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            // leading: Icon(Icons.adjust, color: Colors.white),
                                            title: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'quicksand',
                                                  fontSize: MediaQuery.of(context).size.height/50,
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
                                              controller: _medicamentoController,
                                              onSaved: (nomeMedicamentos) => paciente.nomeMedicamentos = nomeMedicamentos,
                                              validator: (nomeMedicamentos) => nomeMedicamentos.length < 3 ? "Não pode ficar em branco." : null,
                                              cursorColor: Colors.white,
                                              onFieldSubmitted: (_) {
                                                setState(() {
                                                  paciente.nomeMedicamentos = _medicamentoController.text.toString();
                                                });
                                              },
                                              keyboardType: TextInputType.text,
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
                                                hintText: "Digite seu(s) medicamento(s)",
                                                hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                labelText: "Medicamento(s)",
                                                labelStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                errorBorder: OutlineInputBorder(
                                                  borderSide:
                                                  const BorderSide(color: Colors.red, width: 3.0),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          :
                                      Visibility(
                                        visible: false,
                                        child: Container(
                                          height: 0,
                                          width: 0,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Alguma alergia?',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: true,
                                                  activeColor: Colors.cyanAccent,
                                                  groupValue: alergia,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      alergia = true;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Sim',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                                Radio(
                                                  value: false,
                                                  groupValue: alergia,
                                                  activeColor: Colors.cyanAccent,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      alergia = false;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  'Não',
                                                  style: new TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height/55,
                                                      color: Colors.white,
                                                      fontFamily: 'quicksand',
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
                                            ),
                                          ),
                                        ),
                                      ),
                                      alergia == true ?
                                      Visibility(
                                        visible: true,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            // leading: Icon(Icons.adjust, color: Colors.white),
                                            title: TextFormField(
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'quicksand',
                                                  fontSize: MediaQuery.of(context).size.height/50,
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
                                              controller: _alergiaController,
                                              onSaved: (nomeAlergia) => paciente.nomeAlergia = nomeAlergia,
                                              validator: (nomeAlergia) => nomeAlergia.length < 3 ? "Não pode ficar em branco." : null,
                                              cursorColor: Colors.white,
                                              onFieldSubmitted: (_) {
                                                setState(() {
                                                  paciente.nomeAlergia = _alergiaController.text.toString();
                                                });
                                              },
                                              keyboardType: TextInputType.text,
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
                                                hintText: "Digite sua(s) alergia(s)",
                                                hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                labelText: "Alergia(s)",
                                                labelStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.height/50,
                                                    fontFamily: 'quicksand',
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
                                                errorBorder: OutlineInputBorder(
                                                  borderSide:
                                                  const BorderSide(color: Colors.red, width: 3.0),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          :
                                      Visibility(
                                        visible: false,
                                        child: Container(
                                          height: 0,
                                          width: 0,
                                        ),
                                      ),
                                    ]
                                ),
                              )
                                  :
                              Visibility(
                                visible: false,
                                child: Container(
                                  height: 0,
                                  width: 0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
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
                                        FlatButton(
                                          color: Colors.black,
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
                                                  color: Colors.white,
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
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
                                        FlatButton(
                                          color: Colors.black,
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
                                                  color: Colors.white,
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
                                              _dialogHorarios(context, dataString);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
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
                                      if(equalsIgnoreCase(widget.profissional.areaAtuacao, 'nutrição')) {
                                        Paciente paciente = new Paciente(
                                            _nomeController.text.toString(),
                                            tel,
                                            _emailController.text.toString(),
                                            widget.paciente.imageURL,
                                            dataString,
                                            horaSelecionada,
                                            "Anotações sobre o atendimento de ${_nomeController.text.toString()} no dia $dataString às $horaSelecionada\n\n",
                                            true,
                                            _objetivoController.text.toString(),
                                            vegetariano,
                                            bebidaAlcoolica,
                                            fumante,
                                            sedentario,
                                            patologia,
                                            _patologiaController.text.toString(),
                                            medicamento,
                                            _medicamentoController.text.toString(),
                                            alergia,
                                            _alergiaController.text.toString(),
                                            sexo,
                                            _estadoCivilController.text.toString()
                                        );
                                        int hora = int.parse(horaSelecionada.substring(0, 2));
                                        int minuto = int.parse(horaSelecionada.substring(horaSelecionada.length - 2, horaSelecionada.length - 1));
                                        salvarnoCalendario(converterData(dataString), hora, minuto, paciente);
                                        _submit(paciente);
                                      } else {
                                        Paciente paciente = new Paciente(
                                            _nomeController.text.toString(),
                                            tel,
                                            _emailController.text.toString(),
                                            widget.paciente.imageURL,
                                            dataString,
                                            horaSelecionada,
                                            "Anotações sobre o atendimento de ${_nomeController
                                                .text
                                                .toString()} no dia $dataString às $horaSelecionada\n\n",
                                            true, "", false, false, false, false, false,
                                            "", false, "", false, "", sexo,
                                            _estadoCivilController.text.toString());

                                        int hora = int.parse(horaSelecionada.substring(0, 2));
                                        int minuto = int.parse(horaSelecionada.substring(horaSelecionada.length - 2, horaSelecionada.length - 1));
                                        salvarnoCalendario(converterData(dataString), hora, minuto, paciente);
                                        _submit(paciente);
                                      }
                                    }
                                  });
                                },
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

  void _presentDatePicker() {
    DateTime now = DateTime.now();
    DateTime currentTime = new DateTime(now.year);
    DateTime nextYear = new DateTime(now.year + 2);
    showDatePicker(
      context: context,
      initialDate: dias[now.weekday - 1] == true ? now : checarDia(now.add(Duration(days: 1))) ,//checarDia(now),
      firstDate: DateTime.now().subtract(new Duration(days: 0)),
      lastDate: nextYear,
      selectableDayPredicate: (now) => dias[now.weekday - 1] == false ? false : true,
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

  void _dialogHorarios(BuildContext context, String data) async {
    List<String> listaHorarios = List();
    for(int i = 0; i < widget.profissional.horarios.length; i++) {
      listaHorarios.add(widget.profissional.horarios[i]);
    }

    listaHorarios.sort((a, b) => (a.compareTo(b)));

    for(int i = 0; i < listaPacientes.length; i++) {
      if(listaPacientes[i].data == data && listaHorarios.contains(listaPacientes[i].hora)) {
        listaHorarios.remove(listaPacientes[i].hora);
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
                        child: listaHorarios.isNotEmpty ?
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: listaHorarios.length,
                          itemBuilder: (BuildContext context, int posicao) {
                            return horaSelecionada != (listaHorarios[posicao]) ?
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
                                    title: Text('${listaHorarios[posicao]}',
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
                                      definirHorario(listaHorarios[posicao]);
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
                                    title: Text('${listaHorarios[posicao]}',
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
                                      definirHorario(listaHorarios[posicao]);
                                    });
                                  },
                                )
                            );
                          },
                        )
                            :
                        Align(
                          alignment: Alignment.center,
                          child: Text('Não há horários disponíveis.',
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

  void mudarHora(String hora) {
    setState(() {
      horaSelecionada = hora;
    });
  }

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

  bool equalsIgnoreCase(String a, String b) =>
      (a == null && b == null) || (a != null && b != null && a.toLowerCase() == b.toLowerCase());

  DateTime checarDia(DateTime now) {
    if (dias[now.weekday - 1] == true) {
      return now;
    } else {
      return checarDia(now.add(Duration(days: 1)));
    }
  }
}