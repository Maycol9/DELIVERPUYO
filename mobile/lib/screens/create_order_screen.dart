import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../addresses/addresses_provider.dart';
import '../models/address.dart';
import '../models/product.dart';
import '../orders/orders_controller.dart';
import '../products/products_controller.dart';
import '../providers/app_providers.dart';
import '../state/remote_state.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_text_field.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _quantityFocus = FocusNode();
  final _quantityKey = GlobalKey<FormFieldState<String>>();
  Map<String, String> _serverErrors = const {};
  bool _submitting = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(orderDraftProvider);
    _quantityController.text = draft.quantity;
    _quantityFocus.addListener(() {
      if (!_quantityFocus.hasFocus) {
        _quantityKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _serverErrors = const {};
      _generalError = null;
    });
    if (!_formKey.currentState!.validate()) {
      _quantityFocus.requestFocus();
      return;
    }

    setState(() => _submitting = true);
    final result = await ref
        .read(ordersControllerProvider.notifier)
        .create(ref.read(orderDraftProvider));
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido creado correctamente.')),
      );
      context.go('/orders');
      return;
    }

    setState(() {
      _serverErrors = result.fieldErrors;
      _generalError = result.fieldErrors.isEmpty ? result.message : null;
    });
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final productsState = ref.watch(productsControllerProvider);
    final addressesState = ref.watch(addressesProvider);
    final draft = ref.watch(orderDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear pedido'),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => context.go('/products'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nuevo pedido',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    SizedBox(height: tokens.spaceMd),
                    if (_generalError != null) ...[
                      Text(
                        _generalError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      SizedBox(height: tokens.spaceMd),
                    ],
                    _AddressField(
                      state: addressesState.valueOrNull,
                      value: draft.addressId.isEmpty ? null : draft.addressId,
                      errorText: _serverErrors['addressId'],
                      onChanged: (value) {
                        ref
                            .read(orderDraftProvider.notifier)
                            .setAddress(value ?? '');
                      },
                    ),
                    SizedBox(height: tokens.spaceMd),
                    _ProductField(
                      state: productsState,
                      value: draft.productId.isEmpty ? null : draft.productId,
                      errorText:
                          _serverErrors['items'] ?? _serverErrors['productId'],
                      onChanged: (value) {
                        ref
                            .read(orderDraftProvider.notifier)
                            .setProduct(value ?? '');
                      },
                    ),
                    SizedBox(height: tokens.spaceMd),
                    AppTextField(
                      formFieldKey: _quantityKey,
                      label: 'Cantidad',
                      controller: _quantityController,
                      focusNode: _quantityFocus,
                      keyboardType: TextInputType.number,
                      errorText: _serverErrors['quantity'],
                      prefix: const Icon(Icons.numbers_outlined),
                      onChanged: (value) {
                        ref
                            .read(orderDraftProvider.notifier)
                            .setQuantity(value);
                      },
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        final quantity = int.tryParse(text);
                        if (_serverErrors['items'] != null) {
                          return _serverErrors['items'];
                        }
                        if (text.isEmpty) {
                          return 'La cantidad es obligatoria.';
                        }
                        if (quantity == null) {
                          return 'La cantidad debe ser un número entero.';
                        }
                        if (quantity <= 0) {
                          return 'La cantidad debe ser mayor que cero.';
                        }
                        if (quantity > 50) {
                          return 'La cantidad no puede superar 50 unidades.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: tokens.spaceLg),
                    AppPrimaryButton(
                      text: 'CREAR PEDIDO',
                      loading: _submitting,
                      onPressed: _submit,
                      icon: const Icon(Icons.check),
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

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.state,
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  final RemoteState<List<Address>>? state;
  final String? value;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final addresses = switch (state) {
      RemoteData<List<Address>>(:final value) => value,
      _ => const <Address>[],
    };

    return DropdownButtonFormField<String>(
      initialValue: addresses.any((item) => item.id == value) ? value : null,
      decoration: InputDecoration(
        labelText: 'Dirección',
        errorText: errorText,
        prefixIcon: const Icon(Icons.location_on_outlined),
      ),
      items: [
        for (final address in addresses)
          DropdownMenuItem(
            value: address.id,
            child: Text('${address.label} - ${address.address}'),
          ),
      ],
      onChanged: addresses.isEmpty ? null : onChanged,
      validator: (value) {
        if (errorText != null) return errorText;
        if (value == null || value.isEmpty) return 'Selecciona una dirección.';
        return null;
      },
    );
  }
}

class _ProductField extends StatelessWidget {
  const _ProductField({
    required this.state,
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  final RemoteState<List<Product>> state;
  final String? value;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final products = switch (state) {
      RemoteData<List<Product>>(:final value) => value,
      _ => const <Product>[],
    };

    return DropdownButtonFormField<String>(
      initialValue: products.any((item) => item.id == value) ? value : null,
      decoration: InputDecoration(
        labelText: 'Producto',
        errorText: errorText,
        prefixIcon: const Icon(Icons.local_mall_outlined),
      ),
      items: [
        for (final product in products)
          DropdownMenuItem(
            value: product.id,
            child: Text(
              '${product.name} - \$${product.price.toStringAsFixed(2)}',
            ),
          ),
      ],
      onChanged: products.isEmpty ? null : onChanged,
      validator: (value) {
        if (errorText != null) return errorText;
        if (value == null || value.isEmpty) return 'Selecciona un producto.';
        return null;
      },
    );
  }
}
