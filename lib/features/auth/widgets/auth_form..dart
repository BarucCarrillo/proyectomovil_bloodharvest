import 'package:flutter/material.dart';

// FORMULARIO DE AUTENTICACION PARA LOGIN Y REGISTRO

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final Function(String email, String password, [String? displayName]) onSubmit;

  const AuthForm({super.key, required this.isLogin, required this.onSubmit});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();

  bool isLoading = false;

  void submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      if (widget.isLogin) {
        await widget.onSubmit(emailCtrl.text.trim(), passCtrl.text.trim());
      } else {
        await widget.onSubmit(
          emailCtrl.text.trim(),
          passCtrl.text.trim(),
          nameCtrl.text.trim(),
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.black,
      color: Colors.brown,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.isLogin)
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Usuario',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
                ),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Correo Invalido',
              ),
              TextFormField(
                controller: passCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 8 ? null : 'Minimo 8 caracteres',
              ),
              if (isLoading) const CircularProgressIndicator(),
              if (!isLoading) SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[300],
                  foregroundColor: Colors.white,
                ),
                onPressed: submit,
                child: Text(widget.isLogin ? 'Entrar' : 'Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
