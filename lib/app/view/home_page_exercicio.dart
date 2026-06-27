import 'package:exemplos_com_scroll/app/data/controller/product_controller.dart';
import 'package:exemplos_com_scroll/app/data/model/product_model.dart';
import 'package:flutter/material.dart';

class HomePageExercicio extends StatefulWidget {
  const HomePageExercicio({super.key});

  @override
  State<HomePageExercicio> createState() => _HomePageExercicioState();
}

class _HomePageExercicioState extends State<HomePageExercicio> {
  final ProductController _productController = ProductController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  List<ProductModel> _loadedProducts = [];
  int _currentPage = 1;
  final int _pageSize = 20; // Quantidade de itens por página
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMoreProducts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Detecta quando o usuário chega próximo ao fim da página
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  // Busca e pagina os produtos localmente ou via Controller
  void _loadMoreProducts({bool isRefresh = false}) {
    if (_isLoading || (!_hasMore && !isRefresh)) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _currentPage = 1;
        _loadedProducts.clear();
        _hasMore = true;
      }
    });

    // Filtra a lista completa baseada na busca
    final allFiltered = _searchQuery.isEmpty
        ? _productController.products
        : _productController.search(searched: _searchQuery);

    // Calcula os índices da paginação
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= allFiltered.length) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      return;
    }

    final endIndex = (startIndex + _pageSize) > allFiltered.length
        ? allFiltered.length
        : (startIndex + _pageSize);

    // Extrai apenas o pedaço (página) necessário
    final nextPageProducts = allFiltered.sublist(startIndex, endIndex);

    setState(() {
      _currentPage++;
      _loadedProducts.addAll(nextPageProducts);
      _isLoading = false;
      if (endIndex >= allFiltered.length) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              child: FormField<String>(
                initialValue: _searchQuery,
                builder: (state) {
                  return TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar produto por nome ou categoria',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery =
                                      ''; // Zera a string de busca e limpa o textfield
                                });
                                _loadMoreProducts(
                                  isRefresh: true,
                                ); // Reseta o Lazy Loading
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      errorText: state.errorText,
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _loadMoreProducts(
                        isRefresh: true,
                      ); // Reseta a paginação ao buscar
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller:
                    _scrollController, // Vincula o controlador de scroll
                itemCount: _loadedProducts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final product = _loadedProducts[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      'R\$ ${product.price.toStringAsFixed(2)} / ${product.unit}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
