/// Modelo que representa um registro do GeoDiário.
class Registro {
  final int? id;
  final String titulo;
  final String descricao;
  final String caminhoFoto;
  final DateTime dataHora;
  final double? latitude;
  final double? longitude;

  const Registro({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.caminhoFoto,
    required this.dataHora,
    this.latitude,
    this.longitude,
  });

  bool get temLocalizacao => latitude != null && longitude != null;

  /// Converte o objeto em Map para gravar no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'caminho_foto': caminhoFoto,
      'data_hora': dataHora.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Cria o objeto a partir de uma linha do SQLite.
  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: (map['descricao'] as String?) ?? '',
      caminhoFoto: map['caminho_foto'] as String,
      dataHora: DateTime.parse(map['data_hora'] as String),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}
