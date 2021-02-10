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
  bool assinante;

  Profissional(this.nome, this.telefone, this.email, this.areaAtuacao,
      this.usuario, this.imageURL, this.facebook, this.instagram, this.assinante);

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
      "assinante" : assinante
    };
  }
}