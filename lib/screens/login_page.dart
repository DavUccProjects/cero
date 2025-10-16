import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  bool hidePassword = true;
  bool hideConfirm = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final userController = TextEditingController();

  final supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      _showSnack('Error al iniciar sesión: $e');
    }
  }

  Future<void> _signUp() async {
    if (passwordController.text != confirmController.text) {
      _showSnack('Las contraseñas no coinciden');
      return;
    }

    try {
      final res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {'username': userController.text.trim()},
      );

      if (res.user != null) {
        _showSnack('Usuario registrado con éxito. ¡Ahora inicia sesión!');
        setState(() => isLogin = true);
      }
    } catch (e) {
      _showSnack('Error al registrarse: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final title = isLogin ? 'LOGIN' : 'REGISTER';

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO / TÍTULO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                ),
                child: const Text(
                  'STORAGE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // TÍTULO DE SECCIÓN
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),

              if (!isLogin)
                _buildBoxedField(controller: userController, hint: 'USUARIO'),
              _buildBoxedField(controller: emailController, hint: 'CORREO'),
              _buildBoxedField(
                controller: passwordController,
                hint: 'CONTRASEÑA',
                obscure: hidePassword,
                toggle: () => setState(() => hidePassword = !hidePassword),
              ),
              if (!isLogin)
                _buildBoxedField(
                  controller: confirmController,
                  hint: 'CONFIRMAR CONTRASEÑA',
                  obscure: hideConfirm,
                  toggle: () => setState(() => hideConfirm = !hideConfirm),
                ),

              const SizedBox(height: 20),

              // BOTÓN PRINCIPAL
              SizedBox(
                width: 150,
                child: OutlinedButton(
                  onPressed: isLogin ? _signIn : _signUp,
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // SWITCH ENTRE LOGIN Y REGISTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? '¿No tienes cuenta?' : '¿Ya tienes una cuenta?',
                  ),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? 'Regístrate aquí' : 'Inicia sesión',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxedField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (toggle != null)
            IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                size: 18,
              ),
              onPressed: toggle,
            ),
        ],
      ),
    );
  }
}
