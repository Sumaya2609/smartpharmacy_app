class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromDoc(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'name': name};
}
