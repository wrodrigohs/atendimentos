import 'package:firebase_database/firebase_database.dart';

class Paciente {
  String primaryKey;
  String nome;
  String telefone;
  String email;
  String data;
  String hora;
  String anotacao;
  bool confirmado;
  String objetivo;
  bool vegetariano;
  bool bebidaAlcoolica;
  bool fumante;
  bool sedentario;
  bool patologia;
  String nomePatologia;
  bool medicamentos;
  String nomeMedicamentos;
  bool alergia;
  String nomeAlergia;
  String sexo;
  String estadoCivil;

  Paciente(this.nome, this.telefone, this.email, this.data, this.hora, this.anotacao, this.confirmado,
  this.objetivo, this.vegetariano, this.bebidaAlcoolica, this.fumante, this.sedentario,
    this.patologia, this.nomePatologia, this.medicamentos, this.nomeMedicamentos,
    this.alergia, this.nomeAlergia, this.sexo, this.estadoCivil);

  Paciente.fromSnapshot(DataSnapshot snapshot) :
      primaryKey = snapshot.key,
      nome = snapshot.value['nome'],
      telefone = snapshot.value['telefone'],
      email = snapshot.value['email'],
      data = snapshot.value['data'],
      hora = snapshot.value['hora'],
      anotacao = snapshot.value['anotacao'],
      confirmado = snapshot.value['confirmado'],
      objetivo = snapshot.value['objetivo'],
      vegetariano = snapshot.value['vegetariano'],
      bebidaAlcoolica = snapshot.value['bebidaAlcoolica'],
      fumante = snapshot.value['fumante'],
      sedentario = snapshot.value['sedentario'],
      patologia = snapshot.value['patologia'],
      nomePatologia = snapshot.value['nomePatologia'],
      medicamentos = snapshot.value['medicamentos'],
      nomeMedicamentos = snapshot.value['nomeMedicamentos'],
      alergia = snapshot.value['alergia'],
      nomeAlergia = snapshot.value['nomeAlergia'],
      sexo = snapshot.value['sexo'],
      estadoCivil = snapshot.value['estadoCivil'];

  toJson() {
    return {
      "nome" : nome,
      "telefone" : telefone,
      "email" : email,
      "data" : data,
      "hora" : hora,
      "anotacao" : anotacao,
      "confirmado" : confirmado,
      "objetivo" : objetivo,
      "vegetariano" : vegetariano,
      "bebidaAlcoolica" : bebidaAlcoolica,
      "fumante" : fumante,
      "sedentario" : sedentario,
      "patologia" : patologia,
      "nomePatologia" : nomePatologia,
      "medicamentos" : medicamentos,
      "nomeMedicamentos" : nomeMedicamentos,
      "alergia" : alergia,
      "nomeAlergia" : nomeAlergia,
      "sexo" : sexo,
      "estadoCivil" : estadoCivil
    };
  }
}