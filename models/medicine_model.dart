// lib/models/medicine_model.dart
class Medicine {
  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final String image;
  final String strength;
  final int stock;
  final double price;

  final String ingredients;
  final String sideEffects;
  final String description;
  final double rating; // average rating

  Medicine({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.image,
    required this.strength,
    required this.stock,
    required this.price,
    this.ingredients = '',
    this.sideEffects = '',
    this.description = '',
    this.rating = 0,
  });

  factory Medicine.fromDoc(Map<String, dynamic> data, String id) {
    return Medicine(
      id: id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      categoryId: data['categoryId'] ?? '',
      image: data['image'] ?? 'assets/medicine.png',
      strength: data['strength'] ?? '',
      stock: int.tryParse(data['stock']?.toString() ?? '0') ?? 0,
      price: double.tryParse(data['price']?.toString() ?? '0') ?? 0,
      ingredients: data['ingredients'] ?? '',
      sideEffects: data['sideEffects'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'categoryId': categoryId,
      'image': image,
      'strength': strength,
      'stock': stock.toString(),
      'price': price.toString(),
      'ingredients': ingredients,
      'sideEffects': sideEffects,
      'description': description,
      'rating': rating,
    };
  }
}
