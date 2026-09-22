import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//Modelo de dados de um registro de ponto/diário de campo.
class Registro {
  final int? id;
  final String dataHora;
  final double latitude;
  final double longitude;
  final String observacao;
  final String caminhoFoto;

  Registro({
    this.id,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
    required this.observacao,
    required this.caminhoFoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data_hora': dataHora,
      'latitude': latitude,
      'longitude': longitude,
      'observacao': observacao,
      'caminho_foto': caminhoFoto,
    };
  }

  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      id: map['id'] as int?,
      dataHora: map['data_hora'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      observacao: map['observacao'] as String? ?? '',
      caminhoFoto: map['caminho_foto'] as String,
    );
  }
}

//Helper de acesso ao banco SQLite local (tabela `registros`).
class BancoHelper {
  static final BancoHelper instance = BancoHelper._internal();
  static Database? _database;

  BancoHelper._internal();

  factory BancoHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String caminho = join(await getDatabasesPath(), 'senai_checkin.db');
    return openDatabase(
      caminho,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_hora TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        observacao TEXT,
        caminho_foto TEXT NOT NULL
      )
    ''');
  }

  Future<int> inserirRegistro(Registro registro) async {
    final db = await database;
    return db.insert('registros', registro.toMap());
  }

  Future<List<Registro>> listarRegistros() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'registros',
      orderBy: 'id DESC',
    );
    return maps.map(Registro.fromMap).toList();
  }

  Future<Registro?> buscarPorId(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'registros',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Registro.fromMap(maps.first);
  }

  Future<int> excluirRegistro(int id) async {
    final db = await database;
    return db.delete('registros', where: 'id = ?', whereArgs: [id]);
  }
}