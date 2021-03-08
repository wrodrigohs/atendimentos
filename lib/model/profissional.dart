import 'package:firebase_database/firebase_database.dart';

class Profissional {
  String primaryKey;
  String nome;
  String telefone;
  String email;
  String areaAtuacao;
  String usuario;
  String imageURL;
  String facebook;
  String instagram;
  String num_conselho;
  bool domingo;
  bool segunda;
  bool terca;
  bool quarta;
  bool quinta;
  bool sexta;
  bool sabado;
  bool assinante;

  Profissional(this.nome, this.telefone, this.email, this.areaAtuacao,
      this.usuario, this.imageURL, this.facebook, this.instagram,
      this.num_conselho, this.domingo, this.segunda, this.terca,
      this.quarta, this.quinta, this.sexta, this.sabado, this.assinante);

  Profissional.fromSnapshot(DataSnapshot snapshot) :
        primaryKey = snapshot.key,
        nome = snapshot.value['nome'],
        telefone = snapshot.value['telefone'],
        email = snapshot.value['email'],
        areaAtuacao = snapshot.value['areaAtuacao'],
        usuario = snapshot.value['usuario'],
        imageURL = snapshot.value['imageURL'],
        facebook = snapshot.value['facebook'],
        instagram = snapshot.value['instagram'],
        num_conselho = snapshot.value['num_conselho'],
        domingo = snapshot.value['domingo'],
        segunda = snapshot.value['segunda'],
        terca = snapshot.value['terca'],
        quarta = snapshot.value['quarta'],
        quinta = snapshot.value['quinta'],
        sexta = snapshot.value['sexta'],
        sabado = snapshot.value['sabado'],
        assinante = snapshot.value['assinante'];

  toJson() {
    return {
      "nome" : nome,
      "telefone" : telefone,
      "email" : email,
      "areaAtuacao" : areaAtuacao,
      "usuario" : usuario,
      "imageURL" : imageURL,
      "facebook" : facebook,
      "instagram" : instagram,
      "num_conselho" : num_conselho,
      "domingo" : domingo,
      "segunda" : segunda,
      "terca" : terca,
      "quarta" : quarta,
      "quinta" : quinta,
      "sexta" : sexta,
      "assinante" : assinante
    };
  }
}