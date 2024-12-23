import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';


class AddTransactionModal extends StatefulWidget {
  final int idNewTransaction;
  final List<Category> categories;
  final Function(Transaction) onTransactionAdded;

  const AddTransactionModal({
    Key? key,
    required this.idNewTransaction,
    required this.categories,
    required this.onTransactionAdded,
  }) : super(key: key);

  @override
  _AddTransactionModalState createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  Category? selectedCategory;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добавить транзакцию',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButton<Category>(
              hint: const Text('Выберите категорию'),
              value: selectedCategory,
              onChanged: (category) {
                setState(() {
                  selectedCategory = category!;
                });
              },
              items: widget.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Сумма'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Дата'),
              readOnly: true,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                    dateController.text =
                        DateFormat.yMd().format(selectedDate!);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory != null &&
                    amountController.text.isNotEmpty &&
                    selectedDate != null) {
                  final transaction = Transaction(
                    id: widget.idNewTransaction,
                    categoryId: selectedCategory!.id,
                    amount: double.parse(amountController.text),
                    date: selectedDate!,
                  );
                  widget.onTransactionAdded(transaction);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заполните все поля!')),
                  );
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
