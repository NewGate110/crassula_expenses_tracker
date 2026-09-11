import 'package:flutter/material.dart';

final Map<int, IconData> categoryIcons = {
  Icons.park.codePoint: Icons.park,
  Icons.lunch_dining.codePoint: Icons.lunch_dining,
  Icons.movie.codePoint: Icons.movie,
  Icons.checkroom.codePoint: Icons.checkroom,
  Icons.medical_services.codePoint: Icons.medical_services,
  Icons.directions_car.codePoint: Icons.directions_car,
  Icons.flight.codePoint: Icons.flight,
  Icons.pets.codePoint: Icons.pets,
  Icons.shopping_cart.codePoint: Icons.shopping_cart,
  Icons.sports_esports.codePoint: Icons.sports_esports,
  Icons.school.codePoint: Icons.school,
  Icons.home.codePoint: Icons.home,
  Icons.paid.codePoint: Icons.paid,
  Icons.work.codePoint: Icons.work,
  Icons.account_balance.codePoint: Icons.account_balance,
  Icons.receipt_long.codePoint: Icons.receipt_long,
};

IconData categoryIconFor(int codePoint) {
  return categoryIcons[codePoint] ?? Icons.category;
}

class TransactionCategory {
  final String name;
  final int iconCode;
  double categoryTotal;
  final List<String> subcategories; // NEW: Stores our tags

  TransactionCategory({
    required this.name,
    required this.iconCode,
    this.categoryTotal = 0.0,
    this.subcategories = const [], // Default to an empty list
  });
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconCode': iconCode,
      'categoryTotal': categoryTotal,
      'subcategories': subcategories,
    };
  }

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      name: json['name'] as String,
      iconCode: json['iconCode'] as int,
      categoryTotal: (json['categoryTotal'] as num).toDouble(),
      subcategories: List<String>.from(
        json['subcategories'] as List? ?? const [],
      ),
    );
  }
}

//this is the file for intializing a each type of data model for the tracker app.
