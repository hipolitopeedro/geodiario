import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Responsável por capturar fotos e gerenciar os arquivos no
/// armazenamento local do aplicativo.
class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  /// Abre a câmera e retorna o arquivo temporário da foto (ou null se o
  /// usuário cancelar).
  static Future<File?> capturarFoto() async {
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (foto == null) return null;
    return File(foto.path);
  }

  /// Copia a foto temporária para o diretório de documentos do app e
  /// retorna o caminho definitivo, que será salvo no banco.
  static Future<String> salvarNoArmazenamentoLocal(File fotoTemporaria) async {
    final docs = await getApplicationDocumentsDirectory();
    final pasta = Directory(p.join(docs.path, 'fotos'));
    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }
    final extensao = p.extension(fotoTemporaria.path).isEmpty
        ? '.jpg'
        : p.extension(fotoTemporaria.path);
    final nome = 'foto_${DateTime.now().millisecondsSinceEpoch}$extensao';
    final destino = await fotoTemporaria.copy(p.join(pasta.path, nome));
    return destino.path;
  }

  /// Exclui o arquivo de imagem, se existir.
  static Future<void> excluirArquivo(String caminho) async {
    final arquivo = File(caminho);
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }
}
