import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({this.from, super.key});

  final String? from;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text.trim(),
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
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
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
                      'Registro',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    SizedBox(height: tokens.spaceSm),
                    Text(
                      'Crea una cuenta de cliente para usar DeliverPuyo.',
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
                      label: 'Nombre',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      prefix: const Icon(Icons.person_outline),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Ingresa tu nombre.';
                        if (text.length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres.';
                        }
                        if (text.length > 120) {
                          return 'El nombre no puede superar 120 caracteres.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: tokens.spaceMd),
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
                        final text = value ?? '';
                        if (text.isEmpty) return 'Ingresa tu contraseña.';
                        if (text.length < 8) {
                          return 'La contraseña debe tener al menos 8 caracteres.';
                        }
                        if (!RegExp('[A-Z]').hasMatch(text)) {
                          return 'La contraseña debe incluir una mayúscula.';
                        }
                        if (!RegExp('[0-9]').hasMatch(text)) {
                          return 'La contraseña debe incluir un número.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: tokens.spaceLg),
                    AppPrimaryButton(
                      text: 'CREAR CUENTA',
                      loading: loading,
                      onPressed: _submit,
                      icon: const Icon(Icons.person_add_alt_1),
                    ),
                    SizedBox(height: tokens.spaceSm),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () => context.go(
                              widget.from == null
                                  ? '/login'
                                  : '/login?from=${Uri.encodeComponent(widget.from!)}',
                            ),
                      child: const Text('Ya tengo cuenta'),
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
