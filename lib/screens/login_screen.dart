import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _criarConta = false;
  bool _loading = false;
  bool _verPassword = false;
  String? _erro;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _continuarOffline() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _submeter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _erro = null;
    });

    final erro = _criarConta
        ? await AuthService.signUp(_emailCtrl.text, _passCtrl.text)
        : await AuthService.signIn(_emailCtrl.text, _passCtrl.text);

    if (!mounted) return;

    if (erro != null) {
      setState(() {
        _loading = false;
        _erro = erro;
      });
      return;
    }

    if (_criarConta) {
      setState(() {
        _loading = false;
        _erro = null;
        _criarConta = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Conta criada. Verifica o email se for pedida confirmação, depois entra.'),
      ));
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        'pulso',
                        style: TextStyle(
                          fontFamily: 'FamiljenGrotesk',
                          fontWeight: FontWeight.w700,
                          fontSize: 44,
                          letterSpacing: -1,
                          color: ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        _criarConta ? 'Criar conta' : 'Entrar',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (_erro != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _erro!,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),

                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Email inválido'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: !_verPassword,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_verPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _verPassword = !_verPassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                      onFieldSubmitted: (_) => _submeter(),
                    ),
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: _loading ? null : _submeter,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_criarConta ? 'Criar conta' : 'Entrar'),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() {
                                _criarConta = !_criarConta;
                                _erro = null;
                              }),
                      child: Text(
                        _criarConta
                            ? 'Já tenho conta — entrar'
                            : 'Não tenho conta — criar',
                      ),
                    ),

                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _loading ? null : _continuarOffline,
                        child: Text(
                          'Continuar sem conta (sem sincronização)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
