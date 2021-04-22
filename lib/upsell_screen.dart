import 'package:atendimentos/components.dart';
import 'package:atendimentos/purchase_button.dart';
import 'package:atendimentos/ui/politica.dart';
import 'package:atendimentos/upgrade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import 'ui/firstscreen.dart';

class UpsellScreen extends StatefulWidget {
  final Offerings offerings;

  UpsellScreen({Key key, @required this.offerings}) : super(key: key);

  @override
  _UpsellScreenState createState() => _UpsellScreenState();
}

class _UpsellScreenState extends State<UpsellScreen> {
  bool politica = true;
  _launchURLWebsite(String zz) async {
    if (await canLaunch(zz)) {
      await launch(zz);
    } else {
      throw 'Could not launch $zz';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offerings != null) {
      print('offeringS is not null');
      print(widget.offerings.current.toString());
      print('--');
      print(widget.offerings.toString());
      final offering = widget.offerings.current;
      if (offering != null) {
        final monthly = offering.monthly;
        final annual = offering.annual;
        if (monthly != null) {
          return Scaffold(
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: FloatingActionButton(
                                        backgroundColor: Colors.red,
                                        mini: true,
                                        child: Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          /*Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FirstScreen(tipo: 'profissional',)));*/
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 60.0,
                                      child: Image.asset(
                                        'assets/images/health.png',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Text(
                                      'Escolha um dos planos para ter acesso a todo o conteúdo do aplicativo.\n',
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PurchaseButton(package: monthly),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PurchaseButton(package: annual),
                                  ),
                                  /*Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: GestureDetector(
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          color: kColorPrimaryDark,
                                          borderRadius: new BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Text(
                                            'Estornar compra',
                                            style: kSendButtonTextStyle.copyWith(
                                              fontSize: MediaQuery.of(context).size.height/50,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        try {
                                          print('now trying to restore');
                                          PurchaserInfo restoredInfo = await Purchases.restoreTransactions();
                                          print('restore completed');
                                          print(restoredInfo.toString());

                                          appData.isPro = restoredInfo.entitlements.all["VIP"].isActive;

                                          print('is user pro? ${appData.isPro}');

                                          if (appData.isPro) {
                                            Alert(
                                              context: context,
                                              style: kWelcomeAlertStyle,
                                              image: Image.asset(
                                                "assets/images/health.png",
                                                height: 150,
                                              ),
                                              title: "Parabéns!",
                                              content: Column(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                                                    child: Text(
                                                        'Sua compra foi ressarcida com sucesso!',
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
                                                  )
                                                ],
                                              ),
                                              buttons: [
                                                DialogButton(
                                                  radius: BorderRadius.circular(10),
                                                  child: Text(
                                                      "OK",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'quicksand',
                                                        fontSize: MediaQuery.of(context).size.height/40,
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
                                                  onPressed: () {
                                                    Navigator.of(context, rootNavigator: true).pop();
                                                    Navigator.of(context, rootNavigator: true).pop();
                                                    Navigator.of(context, rootNavigator: true).pop();
                                                  },
                                                  width: 127,
                                                  color: kColorAccent,
                                                  height: 52,
                                                ),
                                              ],
                                            ).show();
                                          } else {
                                            Alert(
                                              context: context,
                                              style: kWelcomeAlertStyle,
                                              image: Image.asset(
                                                "assets/images/health.png",
                                                height: 150,
                                              ),
                                              title: "Erro",
                                              content: Column(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                                                    child: Text(
                                                        'Houve um erro. Tente mais tarde.',
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
                                                  )
                                                ],
                                              ),
                                              buttons: [
                                                DialogButton(
                                                  radius: BorderRadius.circular(10),
                                                  child: Text(
                                                    "OK",
                                                    style: kSendButtonTextStyle,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context, rootNavigator: true).pop();
                                                  },
                                                  width: 127,
                                                  color: kColorAccent,
                                                  height: 52,
                                                ),
                                              ],
                                            ).show();
                                          }
                                        } on PlatformException catch (e) {
                                          print('----xx-----');
                                          var errorCode = PurchasesErrorHelper.getErrorCode(e);
                                          if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
                                            print("User cancelled");
                                          } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
                                            print("User not allowed to purchase");
                                          }
                                          Alert(
                                            context: context,
                                            style: kWelcomeAlertStyle,
                                            image: Image.asset(
                                              "assets/images/avatar_demo.png",
                                              height: 150,
                                            ),
                                            title: "Erro",
                                            content: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                                                  child: Text(
                                                      'Houve um erro. Tente novamente mais tarde.',
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
                                                )
                                              ],
                                            ),
                                            buttons: [
                                              DialogButton(
                                                radius: BorderRadius.circular(10),
                                                child: Text(
                                                    "OK",
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
                                                onPressed: () {
                                                  Navigator.of(context, rootNavigator: true).pop();
                                                },
                                                width: 127,
                                                color: kColorAccent,
                                                height: 52,
                                              ),
                                            ],
                                          ).show();
                                        }
                                        return UpgradeScreen();
                                      },
                                    ),
                                  ),*/

                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PoliticadePrivacidade(tipo: 'profissional',)));
                                      },
                                      child: Text(
                                          'Política de privacidade (clique para ler)',
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
                                  ),
                                  /*Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: GestureDetector(
                              onTap: () {
                                _launchURLWebsite('https://yahoo.com');
                              },
                              child: Text(
                                'Term of Use (click to read)',
                                style: kSendButtonTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),*/
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }

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
                  //erro == 'BILLING_UNAVAILABLE' ?
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Icon(
                            Icons.error,
                            color: Theme.of(context).errorColor,
                            size: 44.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                              "Houve um erro. Por favor, verifique se seu dispositivo permite fazer compras e tente novamente.",
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
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}