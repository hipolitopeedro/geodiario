import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/registro.dart';
import '../widgets/registro_card.dart';
import 'detalhes_screen.dart';
import 'novo_registro_screen.dart';

/// Tela inicial: galeria com todos os registros salvos (RF04).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Registro> _registros = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarRegistros();
  }

  Future<void> _carregarRegistros() async {
    final lista = await DatabaseHelper.instance.listarTodos();
    if (!mounted) return;
    setState(() {
      _registros = lista;
      _carregando = false;
    });
  }

  Future<void> _novoRegistro() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NovoRegistroScreen()),
    );
    if (salvou == true) _carregarRegistros();
  }

  Future<void> _abrirDetalhes(Registro registro) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(registro: registro)),
    );
    if (alterou == true) _carregarRegistros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoDiário'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarRegistros,
              child: _registros.isEmpty ? _listaVazia() : _galeria(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoRegistro,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Novo registro'),
      ),
    );
  }

  Widget _listaVazia() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 160),
        Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Center(
          child: Text(
            'Nenhum registro ainda.\nToque em "Novo registro" para começar!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _galeria() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemCount: _registros.length,
      itemBuilder: (context, i) {
        final registro = _registros[i];
        return RegistroCard(
          registro: registro,
          onTap: () => _abrirDetalhes(registro),
        );
      },
    );
  }
}
