import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'invoices_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  String userName = '';
  String userEmail = '';
  bool isLoading = false;
  List<FileObject> userFiles = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserFiles();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? 'Sin correo';
        userName = user.userMetadata?['username'] ?? 'Usuario';
      });
    }
  }

  Future<void> _loadUserFiles() async {
    setState(() => isLoading = true);
    try {
      final files = await supabase.storage.from('cero').list();
      setState(() => userFiles = files);
    } catch (e) {
      _showSnack('Error al cargar archivos: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.first;
      if (file.bytes == null) {
        _showSnack('Error: No se pudo leer el archivo');
        return;
      }

      setState(() => isLoading = true);

      final userId = supabase.auth.currentUser?.id ?? 'unknown';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.extension ?? 'bin';
      final fileName = '${userId}_$timestamp.$extension';

      await supabase.storage.from('cero').uploadBinary(fileName, file.bytes!);

      _showSnack('Archivo subido exitosamente');
      await _loadUserFiles();
    } catch (e) {
      _showSnack('Error al subir archivo: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      _showSnack('Error al cerrar sesión: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // HEADER - PERFIL DEL USUARIO + LOG OUT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PERFIL DEL USUARIO',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 2),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'LOG OUT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // CONTENIDO PRINCIPAL
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // INFO DEL USUARIO
                      _buildInfoRow('NOMBRE USUARIO', userName),
                      const SizedBox(height: 12),
                      _buildInfoRow('CORREO', userEmail),
                      const SizedBox(height: 12),
                      _buildInfoRow('CONTRASEÑA', '••••••••'),

                      const SizedBox(height: 24),

                      // SECCIÓN DE ARCHIVOS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: isLoading ? null : _uploadFile,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            child: const Text(
                              'TUS ARCHIVOS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          // BOTÓN SUBIR ARCHIVOS (esquina inferior derecha)
                        ],
                      ),

                      const Spacer(),

                      // BOTÓN SUBIR ARCHIVOS EN LA ESQUINA
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: isLoading ? null : _uploadFile,
                                icon: const Icon(Icons.arrow_upward, size: 32),
                                padding: const EdgeInsets.all(12),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'SUBIR ARCHIVOS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
