import 'package:flutter/material.dart';

class TermosdeUso extends StatefulWidget {
  TermosdeUso({Key key});

  @override
  _TermosdeUsoState createState() => _TermosdeUsoState();
}

class _TermosdeUsoState extends State<TermosdeUso> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 64.0,
        title: Text('Termos de uso',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'quicksand',
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/papel.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    text: '\nTERMOS DE USO\n\n',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'quicksand',
                      fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                        '1 - Estes termos de uso são regidos e interpretados de acordo com as leis brasileiras.\n\n'
                        '2 - O usuário tem direito de utilizar o aplicativo desde que esteja de acordo com os termos de uso e nossa política de privacidade.\n\n'
                        '3 - É importante que essa página dos termos de uso, assim como a política de privacidade, seja visitada constantemente, pois ela pode ser atualizada a qualquer momento.\n\n'
                        '4 - Para que os profissionais tenham acesso a todas as funcionalidade do aplicativo, eles precisam ser assinantes e estar com a assinatura (mensal ou anual) ativa. A assinatura é autorrenovável, de acordo com os termos da Play Store e da App Store, até que seja cancelada.\n\n'
                        '5 - As assinaturas têm um período gratuito para avaliação de 14 dias.\n\n'
                        '6 - A assinatura mensal custa R\$ 99,00 e a anual, R\$ 1099,00.\n\n'
                        '7- Os pacientes não precisam fazer assinatura para utilizar o aplicativo.\n\n'
                        '8 - Trabalhamos frequentemente para melhorar nossos serviços a fim de trazer uma melhor experiência para os usuários, mas nos reservamos o direito de parar ou limitar o suporte ou manutenção a esse aplicativo a qualquer momento.\n\n'
                        '9 - Caso não esteja de acordo com qualquer dos termos, pedimos que desinstale o aplicativo e, se for o caso, cancele sua assinatura.\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height/50 : MediaQuery.of(context).size.height/50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
