// lib/services/category_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _coll = 'categories';

  Stream<List<CategoryModel>> streamCategories() {
    return _db.collection(_coll).snapshots().map((snap) =>
        snap.docs.map((d) => CategoryModel.fromMap(d.data(), d.id)).toList());
  }

  Future<List<CategoryModel>> fetchCategoriesOnce() async {
    final snap = await _db.collection(_coll).get();
    return snap.docs.map((d) => CategoryModel.fromMap(d.data(), d.id)).toList();
  }
}
