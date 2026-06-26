abstract interface class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
  });
}

final class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    required super.quantity,
    required super.unit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['nome'] as String,
      category: json['categoria'] as String,
      price: (json['preco'] as num).toDouble(),
      quantity: json['quantidade'] as int,
      unit: json['unidade'] as String,
    );
  }
}
