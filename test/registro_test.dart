import 'package:flutter_test/flutter_test.dart';
import 'package:geodiario/models/registro.dart';

void main() {
  test('Registro converte para Map e volta corretamente', () {
    final original = Registro(
      id: 1,
      titulo: 'Praça',
      descricao: 'Passeio no fim de tarde',
      caminhoFoto: '/data/fotos/foto_1.jpg',
      dataHora: DateTime(2026, 11, 13, 14, 30),
      latitude: -19.9191,
      longitude: -43.9386,
    );

    final copia = Registro.fromMap(original.toMap());

    expect(copia.id, original.id);
    expect(copia.titulo, original.titulo);
    expect(copia.descricao, original.descricao);
    expect(copia.caminhoFoto, original.caminhoFoto);
    expect(copia.dataHora, original.dataHora);
    expect(copia.latitude, original.latitude);
    expect(copia.longitude, original.longitude);
  });
}
