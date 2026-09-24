import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Encapsula a obtenção de coordenadas GPS e o tratamento da permissão de localização em tempo de execução.
class MapaDefinitions {
  /// Precisão máxima (em metros) considerada aceitável para o registro.
  static const double precisaoMaximaAceitavel = 50;

  /// Solicita permissão de localização e retorna a posição atual.
  /// Lança [Exception] com mensagem amigável se a permissão for negada ou se o serviço de localização (GPS) estiver desativado.
  static Future<Position> obterLocalizacaoAtual() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      throw Exception('Permissão de localização negada.');
    }

    final bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw Exception('Serviço de localização desativado. Ative o GPS.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Indica se a precisão (`position.accuracy`, em metros) obtida está dentro do limite aceitável para validar um registro de campo.
  static bool precisaoAceitavel(Position posicao) {
    return posicao.accuracy <= precisaoMaximaAceitavel;
  }

  /// Formata latitude/longitude para exibição (4 casas decimais).
  static String formatarCoordenadas(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }
}
