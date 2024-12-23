import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/transaction_service.dart';
import '../utils/category_service.dart';
import 'category_view.dart';
import '../widgets/add_transaction_widget.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  TransactionScreenState createState() => TransactionScreenState();
}

class TransactionScreenState extends State<TransactionScreen> {
  final transactionService = TransactionService();
  final categoryService = CategoryService();
  List<Transaction> allTransactions = [];
  List<Transaction> filtredTransactions = [];
  List<Category> categories = [];
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController amountController = TextEditingController();
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final categoriesData = await categoryService.getCategories();
      setState(() {
        categories = categoriesData;
      });

      final transactionsData = await transactionService.getTransactions();
      setState(() {
        allTransactions = transactionsData;
        filtredTransactions = allTransactions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );
    }
  }

  Future<void> addTransaction() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || selectedCategory == null) return;

    try {
      final transaction = Transaction(
        id: allTransactions.length + 1,
        categoryId: selectedCategory!.id,
        amount: amount,
        date: DateTime.now(),
      );
      await transactionService.addTransaction(transaction);
      amountController.clear();
      loadTransactions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления транзакции: $e')),
      );
    }
  }

  void resetFilters() {
    setState(() {
      filtredTransactions = allTransactions;
      startDate = null;
      endDate = null;
    });
  }

  void filterInRange(DateTime? start, DateTime? end) {
    setState(() {
      if (start == null || end == null) {
        filtredTransactions = allTransactions;
      } else {
        filtredTransactions = allTransactions.where((transaction) {
          return transaction.date
                  .isAfter(start.subtract(const Duration(seconds: 1))) &&
              transaction.date.isBefore(end.add(const Duration(seconds: 1)));
        }).toList();
      }
    });
  }

  Future<void> filterCustomPeriod(BuildContext context) async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (pickedRange != null) {
      setState(() {
        startDate = pickedRange.start;
        endDate = pickedRange.end;
      });

      filterInRange(startDate, endDate);
    }
  }

  void filterToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end =
        start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    filterInRange(start, end);
  }

  void filterThisWeek() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    final start =
        DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
    final end = DateTime(
        lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day, 23, 59, 59);
    filterInRange(start, end);
  }

  void filterThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1)
        .subtract(const Duration(seconds: 1));
    filterInRange(start, end);
  }

  double calculateIncome() {
    return filtredTransactions
        .where((t) => categories.any((c) => c.id == t.categoryId && c.isIncome))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateExpense() {
    return filtredTransactions
        .where(
            (t) => categories.any((c) => c.id == t.categoryId && !c.isIncome))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateBalance() {
    return calculateIncome() - calculateExpense();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Транзакции',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.filter_alt,
              color: Colors.white,
            ),
            onSelected: (String selected) {
              switch (selected) {
                case 'today':
                  filterToday();
                  break;
                case 'week':
                  filterThisWeek();
                  break;
                case 'month':
                  filterThisMonth();
                  break;
                case 'custom':
                  filterCustomPeriod(context);
                  break;
                case 'reset':
                  resetFilters();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'today',
                child: Text('Сегодня'),
              ),
              const PopupMenuItem(
                value: 'week',
                child: Text('Эта неделя'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('Этот месяц'),
              ),
              const PopupMenuItem(
                value: 'custom',
                child: Text('Выбрать период'),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Text('Сбросить фильтры'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.category,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(
                    onCategoryUpdated: loadTransactions,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filtredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filtredTransactions[index];
                final category = categories.firstWhere(
                    (cat) => cat.id == transaction.categoryId,
                    orElse: () =>
                        Category(id: 0, name: 'Неизвестно', isIncome: false));

                return ListTile(
                  title: Text(category.name),
                  subtitle: Text(DateFormat.yMd().format(transaction.date)),
                  trailing: Text(
                    (category.isIncome)
                        ? '+ ${transaction.amount.toStringAsFixed(2)} ₽'
                        : '- ${transaction.amount.toStringAsFixed(2)} ₽',
                    style: TextStyle(
                      color: (category.isIncome) ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Доходы: ${calculateIncome().toStringAsFixed(2)} ₽',
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text('Расходы: ${calculateExpense().toStringAsFixed(2)} ₽',
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text(
                    'Баланс: ${calculateBalance().toStringAsFixed(2)} ₽',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: calculateBalance() >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => showAddTransactionModal(context),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddTransactionModal(
        idNewTransaction: allTransactions.length + 1,
        categories: categories,
        onTransactionAdded: (Transaction transaction) async {
          try {
            await transactionService.addTransaction(transaction);
            loadTransactions();
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка добавления транзакции: $e')),
            );
          }
        },
      ),
    );
  }
}
