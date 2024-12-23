import 'supabase_client.dart';
import '../models/category.dart';

class CategoryService {
  Future<List<Category>> getCategories() async {
    final response = await supabase.from('categories').select();

    return (response as List<dynamic>)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCategory(Category category) async {
    await supabase.from('categories').insert(category.toJson());
  }

  Future<void> deleteCategory(int id) async {
    await supabase.from('categories').delete().eq('id', id);
  }
}
