import 'package:flutter/material.dart';

/// Linha de informação com ícone, rótulo e valor (usada nas telas de
/// detalhes e de novo registro).
class InfoTile extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;
  final Widget? trailing;

  const InfoTile({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.valor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icone, color: Theme.of(context).colorScheme.primary),
      title: Text(rotulo, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(valor, style: Theme.of(context).textTheme.bodyLarge),
      trailing: trailing,
    );
  }
}
