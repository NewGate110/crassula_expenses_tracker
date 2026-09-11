import 'package:flutter/material.dart';

import '../models/transaction_category.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TrackerViewModel extends ChangeNotifier {
  // We renamed this from currentBalance to match the screenshot
  double overallBalance = 500.00;

  List<TransactionCategory> expenseCategories = [
    TransactionCategory(name: 'Food', iconCode: Icons.lunch_dining.codePoint),
    TransactionCategory(name: 'Wants', iconCode: Icons.movie.codePoint),
    TransactionCategory(name: 'Clothes', iconCode: Icons.checkroom.codePoint),
    TransactionCategory(
      name: 'Health',
      iconCode: Icons.medical_services.codePoint,
    ),
  ];

  List<TransactionCategory> incomeCategories = [
    TransactionCategory(name: 'Salary', iconCode: Icons.work.codePoint),
    TransactionCategory(name: 'Other income', iconCode: Icons.paid.codePoint),
  ];

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
