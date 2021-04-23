import 'dart:math';
import 'dart:ui' as ui;

import 'package:atendimentos/components.dart';
import 'package:atendimentos/upgrade.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ParentalGate extends StatefulWidget {
  @override
  _ParentalGateState createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  String answer;
  int firstNumber = 0;
  int secondNumber = 0;
  String solution;
  final myController = TextEditingController();

  @override
  void initState() {
    firstNumber = generateRandomNumbers();
    secondNumber = generateRandomNumbers();
    solution = (firstNumber + secondNumber).toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: kColorPrimary,
      body: Stack(
          children: <Widget>[
            Scaffold(
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
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                                  child: Hero(
                                    tag: 'logo',
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 80.0,
                                      child: Image.asset(
                                        'assets/images/health.png',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.fill,
                                      ),
                                      //backgroundImage:
                                    ),
                                  ),
                                ),
                                Text(
                                    'Prevenção de compras acidentais',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'quicksand',
                                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/50,
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
                                SizedBox(
                                  height: 40.0,
                                ),
                                Text(
                                    'Responda corretamente à pergunta abaixo para continuar.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'quicksand',
                                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/50,
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
                                SizedBox(
                                  height: 20.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Quanto é ${firstNumber.toString()} + ${secondNumber.toString()}?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'quicksand',
                                            fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/50,
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
                                  ),
                                ),
                                TextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'quicksand',
                                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/50,
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
                                  controller: myController,
                                  autofocus: true,
                                  onChanged: (value) {
                                    answer = value;
                                  },
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
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
                                          setState(() {
                                            myController.text = '';
                                          });
                                          if (answer == solution) {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => UpgradeScreen(),
                                                  settings: RouteSettings(name: 'Upgrade screen'),
                                                ));
                                          } else {
                                            Alert(
                                              context: context,
                                              style: kWelcomeAlertStyle,
                                              image: Image.asset(
                                                'assets/images/health.png',
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.fill,
                                              ),
                                              title: "Erro",
                                              content: Column(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                                                    child: Text(
                                                      'Resposta incorreta. Tente novamente.',
                                                      textAlign: TextAlign.center,
                                                      style: kSendButtonTextStyle.copyWith(fontSize: 19, color: kColorText),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              buttons: [
                                                DialogButton(
                                                  radius: BorderRadius.circular(10),
                                                  child: Text(
                                                    "OK!",
                                                    style: kSendButtonTextStyle,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context, rootNavigator: true).pop();
                                                    solvePuzzle();
                                                  },
                                                  width: 127,
                                                  color: kColorAccent,
                                                  height: 52,
                                                ),
                                              ],
                                            ).show();
                                          }
                                        },
                                        child: Text(
                                          "Confirmar",
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
                                  /*RaisedButton(
                                      color: Colors.black,
                                      textColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.white,
                                            width: 1,
                                            style: BorderStyle.solid
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'Confirmar',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'quicksand',
                                              fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/50,
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
                                  onPressed: () {
                                        setState(() {
                                          myController.text = '';
                                        });
                                        if (answer == solution) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => UpgradeScreen(),
                                                settings: RouteSettings(name: 'Upgrade screen'),
                                              ));
                                        } else {
                                          Alert(
                                            context: context,
                                            style: kWelcomeAlertStyle,
                                            image: Image.asset(
                                              'assets/images/health.png',
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.fill,
                                            ),
                                            title: "Erro",
                                            content: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                                                  child: Text(
                                                    'Resposta incorreta. Tente novamente.',
                                                    textAlign: TextAlign.center,
                                                    style: kSendButtonTextStyle.copyWith(fontSize: 19, color: kColorText),
                                                  ),
                                                )
                                              ],
                                            ),
                                            buttons: [
                                              DialogButton(
                                                radius: BorderRadius.circular(10),
                                                child: Text(
                                                  "OK!",
                                                  style: kSendButtonTextStyle,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context, rootNavigator: true).pop();
                                                  solvePuzzle();
                                                },
                                                width: 127,
                                                color: kColorAccent,
                                                height: 52,
                                              ),
                                            ],
                                          ).show();
                                        }
                                      }*/
                                ),
                                //),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
              ),
            ),
          ]
      ),
    );
  }

  void solvePuzzle() {
    firstNumber = generateRandomNumbers();
    secondNumber = generateRandomNumbers();
    solution = (firstNumber + secondNumber).toString();
    setState(() {});
  }

  generateRandomNumbers() {
    int min = 11;
    int max = 95;
    //print('max is ' + max.toString());
    int randomNumber = min + (Random().nextInt(max - min));
    return randomNumber;
  }
}
