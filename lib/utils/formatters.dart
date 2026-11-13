import 'package:intl/intl.dart';

/// Funções utilitárias de formatação usadas nas telas.
class Formatters {
  static final DateFormat _dataHora = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final DateFormat _dataCurta = DateFormat('dd/MM/yyyy HH:mm');

  static String dataHora(DateTime d) => _dataHora.format(d);
  static String dataCurta(DateTime d) => _dataCurta.format(d);

  static String coordenadas(double? lat, double? lng) {
    if (lat == null || lng == null) return 'Localização indisponível';
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }
}
