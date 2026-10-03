import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({this.from, super.key});

  final String? from;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted || !ok) return;
    context.go(widget.from ?? '/products');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final authState = ref.watch(authControllerProvider);
    final loading = authState is AuthLoading;
    final message = switch (authState) {
      AuthFailure(:final message) => message,
      Unauthenticated(:final message) => message,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.spaceMd),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'DeliverPuyo',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    SizedBox(height: tokens.spaceSm),
                    Text(
                      'Accede para ver detalles y gestionar pedidos.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (message != null) ...[
                      SizedBox(height: tokens.spaceMd),
                      Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    SizedBox(height: tokens.spaceLg),
                    AppTextField(
                      label: 'Correo electrónico',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefix: const Icon(Icons.email_outlined),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Ingresa tu correo electrónico.';
                        }
                        if (!text.contains('@')) {
                          return 'Ingresa un correo electrónico válido.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: tokens.spaceMd),
                    AppTextField(
                      label: 'Contraseña',
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      prefix: const Icon(Icons.lock_outline),
                      suffix: IconButton(
                        tooltip: _showPassword
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        onPressed: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Ingresa tu contraseña.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: tokens.spaceLg),
                    AppPrimaryButton(
                      text: 'INGRESAR',
                      loading: loading,
                      onPressed: _submit,
                      icon: const Icon(Icons.login),
                    ),
                    SizedBox(height: tokens.spaceSm),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () => context.go(
                              widget.from == null
                                  ? '/register'
                                  : '/register?from=${Uri.encodeComponent(widget.from!)}',
                            ),
                      child: const Text('Crear cuenta'),
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
