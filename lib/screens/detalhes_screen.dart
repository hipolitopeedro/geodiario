import 'dart:io';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/registro.dart';
import '../services/photo_service.dart';
import '../utils/formatters.dart';
import '../widgets/info_tile.dart';

/// Tela de visualização e exclusão de um registro (RF05).
class DetalhesScreen extends StatelessWidget {
  final Registro registro;

  const DetalhesScreen({super.key, required this.registro});

  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text(
            'Deseja realmente excluir "${registro.titulo}"? A foto também será apagada.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    // Remove do banco e apaga o arquivo de imagem.
    await DatabaseHelper.instance.excluir(registro.id!);
    await PhotoService.excluirArquivo(registro.caminhoFoto);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro excluído.')));
    Navigator.pop(context, true);
  }

  void _abrirFotoTelaCheia(BuildContext context, File arquivo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(child: Image.file(arquivo)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arquivo = File(registro.caminhoFoto);
    final existe = arquivo.existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(registro.titulo, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: existe ? () => _abrirFotoTelaCheia(context, arquivo) : null,
            child: Hero(
              tag: 'foto_${registro.id}',
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: existe
                    ? Image.file(arquivo, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text('Arquivo de imagem não encontrado'),
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(registro.titulo,
                    style: Theme.of(context).textTheme.headlineSmall),
                if (registro.descricao.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(registro.descricao,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
                const Divider(height: 32),
                InfoTile(
                  icone: Icons.schedule,
                  rotulo: 'Data e hora',
                  valor: Formatters.dataHora(registro.dataHora),
                ),
                InfoTile(
                  icone: Icons.north,
                  rotulo: 'Latitude',
                  valor: registro.latitude?.toStringAsFixed(6) ?? '—',
                ),
                InfoTile(
                  icone: Icons.east,
                  rotulo: 'Longitude',
                  valor: registro.longitude?.toStringAsFixed(6) ?? '—',
                ),
                InfoTile(
                  icone: Icons.folder_outlined,
                  rotulo: 'Arquivo',
                  valor: registro.caminhoFoto,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red),
                    onPressed: () => _confirmarExclusao(context),
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir registro'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
