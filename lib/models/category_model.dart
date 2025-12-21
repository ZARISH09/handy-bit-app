// lib/models/category_model.dart
class CategoryModel {
  final String id;
  final String name;
  final String image; // url (optional)
  final String colorHex; // string like "#EAF2FF"

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.colorHex,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      colorHex: map['color'] ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'color': colorHex,
    };
  }
}
