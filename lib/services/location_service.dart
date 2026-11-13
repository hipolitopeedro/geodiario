import 'package:geolocator/geolocator.dart';

/// Encapsula o acesso ao GPS do dispositivo.
class LocationService {
  /// Obtém a posição atual. Lança [LocationException] com uma mensagem
  /// amigável caso o GPS esteja desligado ou a permissão seja negada.
  static Future<Position> obterPosicaoAtual() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw LocationException(
          'O serviço de localização (GPS) está desativado.');
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        throw LocationException('Permissão de localização negada.');
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      throw LocationException(
          'Permissão de localização negada permanentemente. '
          'Habilite-a nas configurações do aparelho.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }
}

class LocationException implements Exception {
  final String mensagem;
  LocationException(this.mensagem);

  @override
  String toString() => mensagem;
}
