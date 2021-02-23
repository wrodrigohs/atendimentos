import 'package:atendimentos/components.dart';
import 'package:atendimentos/purchase_button.dart';
import 'package:atendimentos/upgrade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class UpsellScreen extends StatefulWidget {
  final Offerings offerings;

  UpsellScreen({Key key, @required this.offerings}) : super(key: key);

  @override
  _UpsellScreenState createState() => _UpsellScreenState();
}

class _UpsellScreenState extends State<UpsellScreen> {
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
          return TopBarAgnosticNoIcon(
            text: "Upgrade Screen",
            style: kSendButtonTextStyle,
            uniqueHeroTag: 'purchase_screen',
            child: Scaffold(
                backgroundColor: kColorPrimary,
                body: Center(
                  child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Obrigado pelo interesse no app!',
                            textAlign: TextAlign.center,
                            style: kSendButtonTextStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: CircleAvatar(
                              backgroundColor: kColorPrimary,
                              radius: 80.0,
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
                            style: kSendButtonTextStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PurchaseButton(package: monthly),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PurchaseButton(package: annual),
                          ),
                          Padding(
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
                                      fontSize: 16,
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
                                        "assets/images/avatar_demo.png",
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
                                              'Houve um erro. Tente mais tarde.',
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
                          ),

                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: GestureDetector(
                              onTap: () {
                                _launchURLWebsite('https://google.com');
                              },
                              child: Text(
                                'Privacy Policy (click to read)',
                                style: kSendButtonTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          Padding(
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
                          ),
                        ],
                      )),
                )),
          );
        }
      }
    }
    return TopBarAgnosticNoIcon(
      text: "Upgrade Screen",
      style: kSendButtonTextStyle,
      uniqueHeroTag: 'upgrade_screen1',
      child: Scaffold(
          backgroundColor: kColorPrimary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Icon(
                    Icons.error,
                    color: kColorText,
                    size: 44.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "There was an error. Please check that your device is allowed to make purchases and try again. Please contact us at xxx@xxx.com if the problem persists.",
                    textAlign: TextAlign.center,
                    style: kSendButtonTextStyle,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}