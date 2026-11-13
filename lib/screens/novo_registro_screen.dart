import 'dart:io';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/registro.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../utils/formatters.dart';
import '../widgets/info_tile.dart';

/// Tela de criação de um novo registro (RF01, RF02, RF03).
class NovoRegistroScreen extends StatefulWidget {
  const NovoRegistroScreen({super.key});

  @override
  State<NovoRegistroScreen> createState() => _NovoRegistroScreenState();
}

class _NovoRegistroScreenState extends State<NovoRegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  File? _foto;
  DateTime? _dataHora;
  double? _latitude;
  double? _longitude;
  String? _erroLocalizacao;
  bool _buscandoLocalizacao = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    // Abre a câmera assim que a tela é exibida.
    WidgetsBinding.instance.addPostFrameCallback((_) => _capturarFoto());
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _capturarFoto() async {
    try {
      final foto = await PhotoService.capturarFoto();
      if (foto == null) return; // usuário cancelou
      setState(() {
        _foto = foto;
        _dataHora = DateTime.now(); // data/hora automática do registro
      });
      _obterLocalizacao();
    } catch (e) {
      _mostrarMensagem('Erro ao acessar a câmera: $e');
    }
  }

  Future<void> _obterLocalizacao() async {
    setState(() {
      _buscandoLocalizacao = true;
      _erroLocalizacao = null;
    });
    try {
      final pos = await LocationService.obterPosicaoAtual();
      if (!mounted) return;
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroLocalizacao = e.toString());
    } finally {
      if (mounted) setState(() => _buscandoLocalizacao = false);
    }
  }

  Future<void> _salvar() async {
    if (_foto == null) {
      _mostrarMensagem('Capture uma fotografia antes de salvar.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null) {
      final continuar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sem localização'),
          content: const Text(
              'Não foi possível obter as coordenadas GPS. Deseja salvar o registro mesmo assim?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Salvar')),
          ],
        ),
      );
      if (continuar != true) return;
    }

    setState(() => _salvando = true);
    try {
      // 1) Copia a foto para o armazenamento local do app.
      final caminho = await PhotoService.salvarNoArmazenamentoLocal(_foto!);
      // 2) Grava o caminho e os demais dados no SQLite.
      final registro = Registro(
        titulo: _tituloCtrl.text.trim(),
        descricao: _descricaoCtrl.text.trim(),
        caminhoFoto: caminho,
        dataHora: _dataHora ?? DateTime.now(),
        latitude: _latitude,
        longitude: _longitude,
      );
      await DatabaseHelper.instance.inserir(registro);
      if (!mounted) return;
      _mostrarMensagem('Registro salvo com sucesso!');
      Navigator.pop(context, true);
    } catch (e) {
      _mostrarMensagem('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarMensagem(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _areaFoto(),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _salvando ? null : _capturarFoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(_foto == null ? 'Tirar foto' : 'Tirar outra foto'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe um título'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                maxLength: 300,
              ),
              const SizedBox(height: 8),
              InfoTile(
                icone: Icons.schedule,
                rotulo: 'Data e hora',
                valor: _dataHora == null
                    ? 'Será registrada ao tirar a foto'
                    : Formatters.dataHora(_dataHora!),
              ),
              _tileLocalizacao(),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('Salvar registro'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _areaFoto() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _foto == null
            ? InkWell(
                onTap: _capturarFoto,
                child: Container(
                  color: Colors.grey.shade200,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Toque para fotografar'),
                    ],
                  ),
                ),
              )
            : Image.file(_foto!, fit: BoxFit.cover),
      ),
    );
  }

  Widget _tileLocalizacao() {
    String valor;
    if (_buscandoLocalizacao) {
      valor = 'Obtendo coordenadas GPS...';
    } else if (_latitude != null) {
      valor = Formatters.coordenadas(_latitude, _longitude);
    } else if (_erroLocalizacao != null) {
      valor = _erroLocalizacao!;
    } else {
      valor = 'Será obtida ao tirar a foto';
    }

    return InfoTile(
      icone: Icons.location_on,
      rotulo: 'Localização (latitude, longitude)',
      valor: valor,
      trailing: _buscandoLocalizacao
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : (_foto != null
              ? IconButton(
                  tooltip: 'Atualizar localização',
                  icon: const Icon(Icons.my_location),
                  onPressed: _obterLocalizacao,
                )
              : null),
    );
  }
}
