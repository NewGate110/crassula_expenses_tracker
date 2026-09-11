import 'package:flutter/material.dart';

import '../models/money_transaction.dart';
import '../models/transaction_category.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TrackerViewModel extends ChangeNotifier {
  // We renamed this from currentBalance to match the screenshot
  double overallBalance = 500.00;

  List<TransactionCategory> expenseCategories = [
    TransactionCategory(
      name: 'Food',
      iconCode: Icons.lunch_dining.codePoint,
      subcategories: ['Groceries'],
    ),
    TransactionCategory(
      name: 'Wants',
      iconCode: Icons.movie.codePoint,
      subcategories: ['Entertainment'],
    ),
    TransactionCategory(
      name: 'Clothes',
      iconCode: Icons.checkroom.codePoint,
      subcategories: ['Workwear'],
    ),
    TransactionCategory(
      name: 'Health',
      iconCode: Icons.medical_services.codePoint,
      subcategories: ['Medicine'],
    ),
  ];

  List<TransactionCategory> incomeCategories = [
    TransactionCategory(
      name: 'Salary',
      iconCode: Icons.work.codePoint,
      subcategories: ['Monthly salary'],
    ),
    TransactionCategory(
      name: 'Other income',
      iconCode: Icons.paid.codePoint,
      subcategories: ['Freelance'],
    ),
  ];

  List<MoneyTransaction> transactions = [];

  List<TransactionCategory> categoriesFor(bool isIncome) {
    return isIncome ? incomeCategories : expenseCategories;
  }

  double totalFor(bool isIncome) {
    return categoriesFor(isIncome)
        .fold(0.0, (total, category) => total + category.categoryTotal);
  }

  static const _balanceKey = 'overallBalance';
  static const _categoriesKey = 'expenseCategories';
  static const _incomeCategoriesKey = 'incomeCategories';
  static const _transactionsKey = 'transactions';
  static const _exampleTagsSeededKey = 'exampleTagsSeededV1';

  void _seedExampleTags() {
    const examples = <String, String>{
      'Food': 'Groceries',
      'Wants': 'Entertainment',
      'Clothes': 'Workwear',
      'Health': 'Medicine',
      'Salary': 'Monthly salary',
      'Other income': 'Freelance',
    };

    for (final category in [...expenseCategories, ...incomeCategories]) {
      final example = examples[category.name];
      if (example != null && category.subcategories.isEmpty) {
        category.subcategories.add(example);
      }
    }
  }

  Future<void> loadData() async {
    final preferences = await SharedPreferences.getInstance();

    overallBalance = preferences.getDouble(_balanceKey) ?? 500.00;

    final storedCategories = preferences.getString(_categoriesKey);
    if (storedCategories != null) {
      final decoded = jsonDecode(storedCategories) as List<dynamic>;

      expenseCategories = decoded
          .map(
            (item) =>
                TransactionCategory.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    final storedIncomeCategories = preferences.getString(_incomeCategoriesKey);

    if (storedIncomeCategories != null) {
      final decoded = jsonDecode(storedIncomeCategories) as List<dynamic>;

      incomeCategories = decoded
          .map(
            (item) =>
                TransactionCategory.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    final storedTransactions = preferences.getString(_transactionsKey);
    if (storedTransactions != null) {
      final decoded = jsonDecode(storedTransactions) as List<dynamic>;

      transactions = decoded
          .map(
            (item) => MoneyTransaction.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    if (!(preferences.getBool(_exampleTagsSeededKey) ?? false)) {
      _seedExampleTags();
      await saveData();
      await preferences.setBool(_exampleTagsSeededKey, true);
    }

    notifyListeners();
  }

  Future<void> saveData() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setDouble(_balanceKey, overallBalance);
    await preferences.setString(
      _categoriesKey,
      jsonEncode(
        expenseCategories.map((category) => category.toJson()).toList(),
      ),
    );
    await preferences.setString(
      _incomeCategoriesKey,
      jsonEncode(
        incomeCategories.map((category) => category.toJson()).toList(),
      ),
    );
    await preferences.setString(
      _transactionsKey,
      jsonEncode(
        transactions.map((transaction) => transaction.toJson()).toList(),
      ),
    );
  }

  void addNewCategory(
    String title,
    int iconCode,
    List<String> subcategories, {
    bool isIncome = false,
  }) {
    categoriesFor(isIncome).add(
      TransactionCategory(
        name: title,
        iconCode: iconCode,
        subcategories: subcategories,
      ),
    );

    notifyListeners();
    saveData();
  }

  void addExpenseToCategory(int categoryIndex, double amount) {
    expenseCategories[categoryIndex].categoryTotal += amount;
    overallBalance -= amount;
    notifyListeners();
    saveData();
  }

  void addIncomeToCategory(int categoryIndex, double amount) {
    incomeCategories[categoryIndex].categoryTotal += amount;
    overallBalance += amount;

    notifyListeners();
    saveData();
  }

  void addTransaction({
    required double amount,
    required bool isIncome,
    required int categoryIndex,
    required DateTime date,
    String? tag,
    String comment = '',
  }) {
    final category = categoriesFor(isIncome)[categoryIndex];

    transactions.add(
      MoneyTransaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        amount: amount,
        isIncome: isIncome,
        categoryName: category.name,
        categoryIconCode: category.iconCode,
        tag: tag,
        comment: comment.trim(),
        date: date,
      ),
    );

    category.categoryTotal += amount;
    overallBalance += isIncome ? amount : -amount;

    notifyListeners();
    saveData();
  }

  void updateCategory(
    int index,
    String title,
    int iconCode,
    List<String> subcategories, {
    bool isIncome = false,
  }) {
    final categories = categoriesFor(isIncome);
    final oldTotal = categories[index].categoryTotal;

    categories[index] = TransactionCategory(
      name: title,
      iconCode: iconCode,
      subcategories: subcategories,
      categoryTotal: oldTotal,
    );

    notifyListeners();
    saveData();
  }

  void deleteCategory(int index, {bool isIncome = false}) {
    categoriesFor(isIncome).removeAt(index);

    notifyListeners();
    saveData();
  }
}

// this is the files for completing the operations that will be occuring within the app such as adding and subtracting from the balance.
