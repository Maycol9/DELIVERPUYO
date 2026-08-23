import 'package:flutter/material.dart';

import '../config/app_demo_config.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_text_field.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/state_view.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? _errorMessage;
  String? _connectionMessage;
  bool? _apiConnectionOk;
  List<Product> _products = const [];
  int _totalProducts = 0;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    if (AppDemoConfig.state == UiDemoState.loading) {
      return;
    }

    if (AppDemoConfig.state == UiDemoState.empty) {
      setState(() {
        _loading = false;
        _products = const [];
        _totalProducts = 0;
      });
      return;
    }

    if (AppDemoConfig.state == UiDemoState.error) {
      setState(() {
        _loading = false;
        _products = const [];
        _totalProducts = 0;
        _errorMessage = 'No fue posible conectarse con el servidor.';
      });
      return;
    }

    final result = await _apiService.getProducts();
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (result.success) {
        _products = result.products;
        _totalProducts = result.totalItems;
      } else {
        _products = const [];
        _totalProducts = 0;
        _errorMessage = result.message;
      }
    });
  }

  Future<void> _testCategoriesConnection() async {
    setState(() {
      _connectionMessage = 'Consultando categorías...';
    });
    final result = await _apiService.getCategories();
    if (!mounted) return;

    setState(() {
      _connectionMessage = result.success
          ? 'GET /api/categories respondió ${result.statusCode}.'
          : result.message;
      _apiConnectionOk = result.success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('DeliverPuyo')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(tokens.spaceMd),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1320),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(
                            searchController: _searchController,
                            onSearchChanged: (_) => setState(() {}),
                            onClearSearch: _searchController.text.isEmpty
                                ? null
                                : () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                            onTestConnection: _testCategoriesConnection,
                            connectionMessage: _connectionMessage,
                            apiConnectionOk: _apiConnectionOk,
                            demoMode: AppDemoConfig.isDemoMode,
                            totalProducts: _totalProducts,
                            visibleProducts: _visibleProducts.length,
                            categories: _categories,
                            selectedCategory: _selectedCategory,
                            onCategorySelected: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                          SizedBox(height: tokens.spaceLg),
                          if (_loading)
                            const StateView(
                              type: StateViewType.loading,
                              title: 'Cargando catálogo',
                              message: 'Cargando productos...',
                            )
                          else if (_errorMessage != null)
                            StateView(
                              type: StateViewType.error,
                              title: 'No se pudo cargar el catálogo',
                              message: _errorMessage!,
                              onRetry: _loadProducts,
                            )
                          else if (_visibleProducts.isEmpty)
                            const StateView(
                              type: StateViewType.empty,
                              title: 'Catálogo vacío',
                              message:
                                  'No hay productos disponibles en este momento.',
                            )
                          else
                            _ProductsGrid(products: _visibleProducts),
                          SizedBox(height: tokens.spaceLg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Product> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    final category = _selectedCategory;

    return _products
        .where((product) {
          final matchesSearch =
              query.isEmpty || product.name.toLowerCase().contains(query);
          final matchesCategory =
              category == null || product.categoryName == category;
          return matchesSearch && matchesCategory;
        })
        .toList(growable: false);
  }

  List<String> get _categories {
    final categories =
        _products
            .map((product) => product.categoryName)
            .whereType<String>()
            .where((category) => category.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return categories;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onTestConnection,
    required this.connectionMessage,
    required this.apiConnectionOk,
    required this.demoMode,
    required this.totalProducts,
    required this.visibleProducts,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onClearSearch;
  final VoidCallback onTestConnection;
  final String? connectionMessage;
  final bool? apiConnectionOk;
  final bool demoMode;
  final int totalProducts;
  final int visibleProducts;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = Theme.of(context).colorScheme;
    final countText = _countText(totalProducts, visibleProducts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Catálogo de productos',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        SizedBox(height: tokens.spaceSm),
        Text(
          demoMode
              ? 'Modo demostración visual activo. El modo normal consume GET /api/products.'
              : 'Encuentra productos disponibles en DeliverPuyo.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: tokens.spaceMd),
        Text(
          countText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: tokens.spaceLg),
        AppTextField(
          label: 'Buscar productos',
          hintText: 'Buscar productos...',
          controller: searchController,
          onChanged: onSearchChanged,
          prefix: const Icon(Icons.search, semanticLabel: 'Buscar'),
          suffix: onClearSearch == null
              ? null
              : Tooltip(
                  message: 'Limpiar búsqueda',
                  child: IconButton(
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.close),
                  ),
                ),
        ),
        SizedBox(height: tokens.spaceMd),
        _CategoryFilters(
          categories: categories,
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
        ),
        SizedBox(height: tokens.spaceMd),
        _ApiStatusPanel(
          connectionOk: apiConnectionOk,
          message: connectionMessage,
          onPressed: onTestConnection,
        ),
      ],
    );
  }

  String _countText(int total, int visible) {
    if (total == 0) return 'Sin productos disponibles';
    if (visible != total) {
      return '$visible de $total productos disponibles';
    }
    return '$total productos disponibles';
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryFilterChip(
            label: 'Todos',
            selected: selectedCategory == null,
            onSelected: (_) => onCategorySelected(null),
          ),
          for (final category in categories) ...[
            SizedBox(width: tokens.spaceSm),
            CategoryFilterChip(
              label: category,
              selected: selectedCategory == category,
              onSelected: (_) => onCategorySelected(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApiStatusPanel extends StatelessWidget {
  const _ApiStatusPanel({
    required this.connectionOk,
    required this.message,
    required this.onPressed,
  });

  final bool? connectionOk;
  final String? message;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = Theme.of(context).colorScheme;
    final ok = connectionOk == true;
    final label = ok ? 'API conectada' : 'Comprobar conexión';

    return Semantics(
      liveRegion: message != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(tokens.radiusCard),
          border: Border.all(color: colors.outline.withAlpha(90)),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Wrap(
            spacing: tokens.spaceMd,
            runSpacing: tokens.spaceSm,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    ok ? Icons.check_circle_outline : Icons.cloud_sync,
                    color: ok ? colors.primary : colors.onSurfaceVariant,
                    semanticLabel: ok ? 'API conectada' : 'API no comprobada',
                  ),
                  SizedBox(width: tokens.spaceSm),
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              OutlinedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.refresh),
                label: Text(ok ? 'Actualizar' : 'Comprobar conexión'),
              ),
              if (message != null)
                Text(message!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  const _ProductsGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900 ? 3 : (width >= 600 ? 2 : 1);
        final spacing = tokens.spaceMd;
        final itemWidth = columns == 1
            ? width
            : (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final product in products)
              SizedBox(
                width: itemWidth,
                child: ProductCard(
                  name: product.name,
                  price: product.price,
                  stock: product.stock,
                  category: product.categoryName,
                  imageUrl: product.imageUrl,
                  compact: columns > 1,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Producto seleccionado: ${product.name}'),
                      ),
                    );
                  },
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
          ],
        );
      },
    );
  }
}
