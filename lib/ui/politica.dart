import 'package:flutter/material.dart';

class PoliticadePrivacidade extends StatefulWidget {
  @override
  _PoliticadePrivacidadeState createState() => _PoliticadePrivacidadeState();
}

class _PoliticadePrivacidadeState extends State<PoliticadePrivacidade> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 64.0,
        title: Text('Política de privacidade',
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
                    text: '\nPOLÍTICA DE PRIVACIDADE\n',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'quicksand',
                      fontSize: MediaQuery.of(context).size.height/50,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: '\nSEÇÃO 1 - QUE INFORMAÇÕES COLETAMOS?\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(
                        text: 'São coletadas as informações pessoais que você nos dá: nome, e-mail, sua área de atuação profissional, seu endereço do instagram e do facebook e telefone.',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(text: '\n\nSEÇÃO 2 - O QUE FAREMOS COM ESSAS INFORMAÇÕES?\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(
                        text: 'À exceção do e-mail, que poderá ser utilizado para ações de marketing do aplicativo, as outras informações serão utilizadas exclusivamente para fins de funcionamento do aplicativo.',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(text: '\n\nSEÇÃO 3 - CONSENTIMENTO\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(
                        text: 'Como vocês obtêm meu consentimento?\nQuando você fornece informações pessoais como nome, telefone e e-mail para seu cadastro no aplicativo. Após o preenchimento do formulário para cadastro, entendemos que você está de acordo com a coleta de dados para serem utilizados pelo aplicativo.',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(text: '\n\nSEÇÃO 4 - DIVULGAÇÃO\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(
                        text: 'Podemos divulgar suas informações pessoais caso sejamos obrigados pela lei para fazê-lo.',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(text: '\n\nSEÇÃO 5 - SERVIÇOS DE TERCEIROS\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(
                        text: 'No geral, os fornecedores terceirizados usados por nós irão apenas coletar, usar e divulgar suas informações na medida do necessário para permitir que eles realizem os serviços que eles nos fornecem. Lembre-se que certos fornecedores podem ser localizados em ou possuir instalações que são localizadas em jurisdições diferentes que você ou nós. Assim, se você quer continuar com uma transação que envolve os serviços de um fornecedor de serviço terceirizado, então suas informações podem tornar-se sujeitas às leis da(s) jurisdição(ões) nas quais o fornecedor de serviço ou suas instalações estão localizados. Como um exemplo, se você está localizado no Canadá e sua transação é processada nos Estados Unidos, então suas informações pessoais usadas para completar aquela transação podem estar sujeitas a divulgação sob a legislação dos Estados Unidos, incluindo o Ato Patriota. Uma vez que você deixe o aplicativo, você não será mais regido por essa política de privacidade.',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(text: '\n\nSEÇÃO 6 - SEGURANÇA\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(
                        text: 'Para proteger suas informações pessoais, tomamos precauções razoáveis e seguimos as melhores práticas da indústria para nos certificar que elas não serão perdidas inadequadamente, usurpadas, acessadas, divulgadas, alteradas ou destruídas. Seus dados ficam armazenados, de forma segura, em servidores Google por meio de um banco de dados na plataforma Firebase.',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(text: '\n\nSEÇÃO 7 - ALTERAÇÕES PARA ESSA POLÍTICA DE PRIVACIDADE\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
                        ),
                      ),
                      TextSpan(
                        text: 'Reservamos o direito de modificar essa política de privacidade a qualquer momento, então, por favor, revise-a com frequência. Alterações e esclarecimentos vão surtir efeito imediatamente após sua publicação no site. Se fizermos alterações nessa política, iremos notificá-lo(a) que ela foi atualizada, para que você tenha ciência sobre quais informações coletamos, como as usamos, e sob que circunstâncias, usamos e/ou as divulgamos. Se o aplicativo for adquirido por ou fundido com outro, suas informações podem ser transferidas para os novos proprietários, para que o aplicativo possa continuar em operação.\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'quicksand',
                          fontSize: MediaQuery.of(context).size.height/50,
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
