import 'dart:io';

import 'package:flutter/material.dart';

import '../models/registro.dart';
import '../utils/formatters.dart';

/// Card exibido na galeria da tela inicial.
class RegistroCard extends StatelessWidget {
  final Registro registro;
  final VoidCallback onTap;

  const RegistroCard({super.key, required this.registro, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final arquivo = File(registro.caminhoFoto);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'foto_${registro.id}',
                child: arquivo.existsSync()
                    ? Image.file(arquivo, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registro.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          Formatters.dataCurta(registro.dataHora),
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        registro.temLocalizacao
                            ? Icons.location_on
                            : Icons.location_off,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          Formatters.coordenadas(
                              registro.latitude, registro.longitude),
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
