import 'supabase_client.dart';
import '../models/transaction.dart';

class TransactionService {
  Future<List<Transaction>> getTransactions() async {
    final response = await supabase.from('transactions').select();

    if (response.isEmpty) {
      throw Exception('Ошибка при загрузке транзакций');
    }

    final data = response as List<dynamic>;
    return data
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final insertedTransaction = transaction.toJson();
    await supabase.from('transactions').insert(insertedTransaction);
  }

  Future<void> deleteTransaction(int id) async {
    final response = await supabase.from('transactions').delete().eq('id', id);
    if (response.isEmpty) {
      throw Exception('Ошибка при удалении транзакции');
    }
  }
}
