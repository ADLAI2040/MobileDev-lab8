import 'package:flutter/material.dart';
import '../utils/category_service.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  final VoidCallback onCategoryUpdated;
  const CategoryScreen({Key? key, required this.onCategoryUpdated})
      : super(key: key);

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  final categoryService = CategoryService();
  List<Category> categories = [];
  final TextEditingController controller = TextEditingController();
  bool isIncome = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final categoriesData = await categoryService.getCategories();
      setState(() {
        categories = categoriesData;
      });
      widget.onCategoryUpdated.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки категорий: $e')),
      );
    }
  }

  Future<void> addCategory() async {
    final name = controller.text.trim();
    if (name.isEmpty) return;

    final isDuplicate = categories.any((category) =>
        category.name.toLowerCase() == name.toLowerCase() &&
        category.isIncome == isIncome);

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Такая категория уже существует.')),
      );
      return;
    }

    try {
      await categoryService.addCategory(Category(
        id: categories.length + 1,
        name: name,
        isIncome: isIncome,
      ));
      controller.clear();
      loadCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления категории: $e')),
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await categoryService.deleteCategory(id);
      loadCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления категории: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
        title: const Text('Категории', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Название категории',
                    ),
                  ),
                ),
                DropdownButton<bool>(
                  value: isIncome,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Доход')),
                    DropdownMenuItem(value: false, child: Text('Расход')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      isIncome = value!;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addCategory,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.name),
                  subtitle: Text(category.isIncome ? 'Доход' : 'Расход'),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => deleteCategory(category.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
