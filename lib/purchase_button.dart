import 'package:atendimentos/components.dart';
import 'package:atendimentos/upgrade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class PurchaseButton extends StatefulWidget {
  final Package package;

  PurchaseButton({Key key, @required this.package}) : super(key: key);

  @override
  _PurchaseButtonState createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<PurchaseButton> {
  PurchaserInfo _purchaserInfo;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Container(
        color: kColorPrimaryLight,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: RaisedButton(
                onPressed: () async {
                  try {
                    print('now trying to purchase');
                    _purchaserInfo = await Purchases.purchasePackage(widget.package);
                    print('purchase completed');

                    appData.isPro = _purchaserInfo.entitlements.all["VIP"].isActive;

                    print('is user pro? ${appData.isPro}');

                    if (appData.isPro) {
                      Alert(
                        context: context,
                        style: kWelcomeAlertStyle,
                        image: Image.asset(
                          "assets/images/avatar_demo.png",
                          height: 150,
                        ),
                        title: "Parabéns!",
                        content: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                              child: Text(
                                'Excelente! Agora você tem acesso a todo o conteúdo do aplicativo.',
                                textAlign: TextAlign.center,
                                style: kSendButtonTextStyle,
                              ),
                            )
                          ],
                        ),
                        buttons: [
                          DialogButton(
                            radius: BorderRadius.circular(10),
                            child: Text(
                              "Ótimo",
                              style: kSendButtonTextStyle,
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
                          "assets/images/avatar_demo.png",
                          height: 150,
                        ),
                        title: "Erro",
                        content: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                              child: Text(
                                'There was an error. Please try again later',
                                textAlign: TextAlign.center,
                                style: kSendButtonTextStyle,
                              ),
                            )
                          ],
                        ),
                        buttons: [
                          DialogButton(
                            radius: BorderRadius.circular(10),
                            child: Text(
                              "COOL",
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
                      title: "Error",
                      content: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                            child: Text(
                              'There was an error. Please try again later',
                              textAlign: TextAlign.center,
                              style: kSendButtonTextStyle,
                            ),
                          )
                        ],
                      ),
                      buttons: [
                        DialogButton(
                          radius: BorderRadius.circular(10),
                          child: Text(
                            "COOL",
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
                  return UpgradeScreen();
                },
                textColor: kColorText,
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xFF0D47A1),
                        Color(0xFF1976D2),
                        Color(0xFF42A5F5),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Comprar ${widget.package.product.title}\n${widget.package.product.priceString}',
                    style: TextStyle(fontSize: MediaQuery.of(context).size.height/50, fontFamily: 'quicksand'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
              child: Text(
                '${widget.package.product.description}',
                textAlign: TextAlign.center,
                style: kSendButtonTextStyle.copyWith(fontSize: MediaQuery.of(context).size.height/60, fontFamily: 'quicksand'),
              ),
            )
          ],
        ),
      ),
    );
  }
}