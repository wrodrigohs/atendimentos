import 'package:firebase_database/firebase_database.dart';

class Profissional {
  String primaryKey;
  String nome;
  String telefone;
  String email;
  String areaAtuacao;
  String usuario;
  bool assinante;

  Profissional(this.nome, this.telefone, this.email, this.areaAtuacao, this.usuario, this.assinante);

  Profissional.fromSnapshot(DataSnapshot snapshot) :
        primaryKey = snapshot.key,
        nome = snapshot.value['nome'],
        telefone = snapshot.value['telefone'],
        email = snapshot.value['email'],
        areaAtuacao = snapshot.value['areaAtuacao'],
        usuario = snapshot.value['usuario'],
        assinante = snapshot.value['assinante'];

  toJson() {
    return {
      "nome" : nome,
      "telefone" : telefone,
      "email" : email,
      "areaAtuacao" : areaAtuacao,
      "usuario" : usuario,
      "assinante" : assinante
    };
  }
}