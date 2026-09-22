import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'banco_helper.dart';
import 'camera_definitions.dart';
import 'mapa_definitions.dart';

void main() {
  runApp(const SenaiCheckInApp());
}

class SenaiCheckInApp extends StatelessWidget {
  const SenaiCheckInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SENAI CheckIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

//Tela inicial: listagem de registros

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BancoHelper _banco = BancoHelper.instance;
  late Future<List<Registro>> _futureRegistros;

  @override
  void initState() {
    super.initState();
    _carregarRegistros();
  }

  void _carregarRegistros() {
    setState(() {
      _futureRegistros = _banco.listarRegistros();
    });
  }

  Future<void> _abrirNovoRegistro() async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const NovoRegistroScreen()),
    );
    if (salvou == true) _carregarRegistros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SENAI CheckIn')),
      body: FutureBuilder<List<Registro>>(
        future: _futureRegistros,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final registros = snapshot.data ?? [];
          if (registros.isEmpty) {
            return const Center(
              child: Text('Nenhum registro ainda. Toque em "+" para começar.'),
            );
          }

          return ListView.builder(
            itemCount: registros.length,
            itemBuilder: (context, index) {
              final registro = registros[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                    File(registro.caminhoFoto),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
                title: Text(registro.dataHora),
                subtitle: Text(
                  registro.observacao,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetalheScreen(registro: registro),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNovoRegistro,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Tela de novo registro

class NovoRegistroScreen extends StatefulWidget {
  const NovoRegistroScreen({super.key});

  @override
  State<NovoRegistroScreen> createState() => _NovoRegistroScreenState();
}

class _NovoRegistroScreenState extends State<NovoRegistroScreen> {
  final TextEditingController _observacaoController = TextEditingController();

  String? _caminhoFoto;
  double? _latitude;
  double? _longitude;
  bool _carregandoFoto = false;
  bool _carregandoLocalizacao = false;
  bool _salvando = false;

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _capturarFoto() async {
    setState(() => _carregandoFoto = true);
    try {
      final caminho = await CameraDefinitions.capturarFoto();
      if (caminho != null) {
        setState(() => _caminhoFoto = caminho);
      }
    } catch (e) {
      _mostrarErro(e.toString());
    } finally {
      setState(() => _carregandoFoto = false);
    }
  }

  Future<void> _obterLocalizacao() async {
    setState(() => _carregandoLocalizacao = true);
    try {
      final posicao = await MapaDefinitions.obterLocalizacaoAtual();
      setState(() {
        _latitude = posicao.latitude;
        _longitude = posicao.longitude;
      });
    } catch (e) {
      _mostrarErro(e.toString());
    } finally {
      setState(() => _carregandoLocalizacao = false);
    }
  }

  bool get _podeSalvar =>
      _caminhoFoto != null && _latitude != null && _longitude != null;

  Future<void> _salvarRegistro() async {
    if (!_podeSalvar) {
      _mostrarErro('Capture a foto e obtenha a localização antes de salvar.');
      return;
    }

    setState(() => _salvando = true);

    final registro = Registro(
      dataHora: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      latitude: _latitude!,
      longitude: _longitude!,
      observacao: _observacaoController.text.trim(),
      caminhoFoto: _caminhoFoto!,
    );

    await BancoHelper.instance.inserirRegistro(registro);

    //Confirmação sonora ao salvar.
    await SystemSound.play(SystemSoundType.click);

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo registro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: _caminhoFoto == null
                ? Container(
                    width: 200,
                    height: 200,
                    color: Colors.black12,
                    child: const Icon(Icons.photo_camera, size: 48),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_caminhoFoto!),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _carregandoFoto ? null : _capturarFoto,
            icon: _carregandoFoto
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt),
            label: Text(_caminhoFoto == null
                ? 'Capturar foto'
                : 'Capturar novamente'),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(
              _latitude != null
                  ? MapaDefinitions.formatarCoordenadas(_latitude!, _longitude!)
                  : 'Localização não obtida',
            ),
          ),
          ElevatedButton.icon(
            onPressed: _carregandoLocalizacao ? null : _obterLocalizacao,
            icon: _carregandoLocalizacao
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: const Text('Obter localização'),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _observacaoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observação',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _salvando ? null : _salvarRegistro,
            icon: const Icon(Icons.save),
            label: Text(_salvando ? 'Salvando...' : 'Salvar registro'),
          ),
        ],
      ),
    );
  }
}

//Tela de detalhe do registro

class DetalheScreen extends StatelessWidget {
  final Registro registro;

  const DetalheScreen({super.key, required this.registro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do registro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(registro.caminhoFoto)),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Data/hora'),
            subtitle: Text(registro.dataHora),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Coordenadas'),
            subtitle: Text(
              MapaDefinitions.formatarCoordenadas(
                registro.latitude,
                registro.longitude,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notes),
            title: const Text('Observação'),
            subtitle: Text(
              registro.observacao.isEmpty ? '(sem observação)' : registro.observacao,
            ),
          ),
        ],
      ),
    );
  }
}