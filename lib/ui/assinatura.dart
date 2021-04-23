import 'dart:ui' as ui;
import 'package:atendimentos/purchase_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

PurchaserInfo _purchaserInfo;

class Assinatura extends StatefulWidget {
  @override
  _AssinaturaState createState() => _AssinaturaState();
}

class _AssinaturaState extends State<Assinatura> {
  Offerings _offerings;
  var ofertaAtual = null;

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

      if (!mounted) return;

      setState(() {
        _purchaserInfo = purchaserInfo;
        _offerings = offerings;
      });

      ofertaAtual = _offerings.current;
      /*if (ofertaAtual != null) {
        final monthly = offering.monthly;
      }*/
    }
  }

  double distancia = AppBar().preferredSize.height + 10;

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: <Widget>[
            Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.transparent,
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
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: distancia,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                            child: Text(
                                'Verifique se o seu dispositivo permite fazer compras.',
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PurchaseButton(package: ofertaAtual),
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
      );
    }
  }
