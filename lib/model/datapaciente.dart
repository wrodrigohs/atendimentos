import 'package:firebase_database/firebase_database.dart';

class DataPaciente {
  String primaryKey;
  String nome;
  String telefone;
  String email;
  DateTime data;
  String hora;
  String anotacao;
  bool confirmado;

  DataPaciente(this.primaryKey, this.nome, this.telefone, this.email, this.data, this.hora, this.anotacao, this.confirmado);

  /*Paciente.fromSnapshot(DataSnapshot snapshot) :
        primaryKey = snapshot.key,
        nome = snapshot.value['nome'],
        telefone = snapshot.value['telefone'],
        email = snapshot.value['email'],
        data = snapshot.value['data'],
        hora = snapshot.value['hora'],
        anotacao = snapshot.value['anotacao'],
        confirmado = snapshot.value['confirmado'];

  toJson() {
    return {
      "nome" : nome,
      "telefone" : telefone,
      "email" : email,
      "data" : data,
      "hora" : hora,
      "anotacao" : anotacao,
      "confirmado" : confirmado
    };
  }*/
}