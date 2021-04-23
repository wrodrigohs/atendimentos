import 'package:atendimentos/ui/firstscreen.dart';
import 'package:atendimentos/upsell_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'components.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

PurchaserInfo _purchaserInfo;

class UpgradeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  Offerings _offerings;
  String erro;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
    } on PlatformException catch (e) {
      print(e);
    }

    Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      print(e);
      if(e.code == 'BILLING_UNAVAILABLE') {
        Alert(
          context: context,
          style: kWelcomeAlertStyle,
          image: Image.asset(
            "assets/images/health.png",
            height: 150,
          ),
          title: "Erro!",
          content: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                child: Text(
                    'Verifique se o seu dispositivo permite fazer compras.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'quicksand',
                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/40 : MediaQuery.of(context).size.height/50,
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
                    fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/35 : MediaQuery.of(context).size.height/40,
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
      }
    }
    if (!mounted) return;

    setState(() {
      _purchaserInfo = purchaserInfo;
      _offerings = offerings;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_purchaserInfo == null) {
      return TopBarAgnosticNoIcon(
        text: "Upgrade Screen",
        style: kSendButtonTextStyle,
        uniqueHeroTag: 'upgrade_screen',
        child: Scaffold(
            backgroundColor: kColorPrimary,
            body: Center(
                child: Text(
                  "Carregando...",
                ))),
      );
    } else {
      if (_purchaserInfo.entitlements.all.isNotEmpty && _purchaserInfo.entitlements.all['VIP'].isActive != null) {
        appData.isPro = _purchaserInfo.entitlements.all['VIP'].isActive;
      } else {
        appData.isPro = false;
      }
      if (appData.isPro) {
        Fluttertoast.showToast(
          msg:'Você já é assinante.',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 5,
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FirstScreen()));
      } else {
        return UpsellScreen(
          offerings: _offerings,
        );
      }
    }
  }
}