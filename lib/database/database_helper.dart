import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/registro.dart';

/// Responsável pela criação do banco SQLite e pelas operações CRUD.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _nomeBanco = 'geodiario.db';
  static const _versaoBanco = 1;
  static const tabela = 'registros';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _abrirBanco();
    return _db!;
  }

  Future<Database> _abrirBanco() async {
    final caminho = join(await getDatabasesPath(), _nomeBanco);
    return openDatabase(
      caminho,
      version: _versaoBanco,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tabela (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo       TEXT    NOT NULL,
            descricao    TEXT,
            caminho_foto TEXT    NOT NULL,
            data_hora    TEXT    NOT NULL,
            latitude     REAL,
            longitude    REAL
          )
        ''');
      },
    );
  }

  /// CREATE - insere um novo registro e retorna o id gerado.
  Future<int> inserir(Registro registro) async {
    final db = await database;
    final map = registro.toMap()..remove('id');
    return db.insert(tabela, map);
  }

  /// READ - lista todos os registros (mais recentes primeiro).
  Future<List<Registro>> listarTodos() async {
    final db = await database;
    final linhas = await db.query(tabela, orderBy: 'data_hora DESC');
    return linhas.map(Registro.fromMap).toList();
  }

  /// READ - busca um registro pelo id.
  Future<Registro?> buscarPorId(int id) async {
    final db = await database;
    final linhas =
        await db.query(tabela, where: 'id = ?', whereArgs: [id], limit: 1);
    if (linhas.isEmpty) return null;
    return Registro.fromMap(linhas.first);
  }

  /// DELETE - exclui um registro pelo id.
  Future<int> excluir(int id) async {
    final db = await database;
    return db.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }
}
