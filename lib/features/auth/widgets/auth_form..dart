import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';
import '../../../utils/texts.dart';

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
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

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
              // NOMBRE SOLO EN REGISTRO
              if (!widget.isLogin)
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: Texts.t("name", isEnglish),
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? Texts.t("fillAllFields", isEnglish)
                      : null,
                ),

              // CORREO
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: Texts.t("email", isEnglish),
                  labelStyle: const TextStyle(color: Colors.black),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@')
                    ? null
                    : Texts.t("invalidUserId", isEnglish),
              ),

              // CONTRASEÑA
              TextFormField(
                controller: passCtrl,
                decoration: InputDecoration(
                  labelText: Texts.t("password", isEnglish),
                  labelStyle: const TextStyle(color: Colors.black),
                ),
                obscureText: true,
                validator: (v) => v != null && v.length >= 8
                    ? null
                    : Texts.t("fillAllFields", isEnglish),
              ),

              if (isLoading) const CircularProgressIndicator(),
              if (!isLoading) const SizedBox(height: 20),

              // BOTÓN TRADUCIDO
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[300],
                  foregroundColor: Colors.white,
                ),
                onPressed: submit,
                child: Text(
                  widget.isLogin
                      ? Texts.t("login", isEnglish) // Entrar
                      : Texts.t("register", isEnglish), // Registrar
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
