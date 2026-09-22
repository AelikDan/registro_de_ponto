import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraDefinitions {
  static final ImagePicker _picker = ImagePicker();

  //Solicita permissão de câmera, abre a câmera nativa e copia a foto
  //capturada para o diretório de documentos do app.
  //Retorna o caminho local do arquivo salvo, ou `null` se o usuário cancelar a captura. Lança [Exception] se a permissão for negada.
  static Future<String?> capturarFoto() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception('Permissão de câmera negada.');
    }

    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (foto == null) return null;

    final Directory diretorio = await getApplicationDocumentsDirectory();
    final String nomeArquivo =
        'checkin_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String caminhoFinal = '${diretorio.path}/$nomeArquivo';

    await File(foto.path).copy(caminhoFinal);
    return caminhoFinal;
  }
}