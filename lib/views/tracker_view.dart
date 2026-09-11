import 'package:flutter/material.dart';

import '../view_models/tracker_view_model.dart';
import '../models/transaction_category.dart';
import 'change_categories_view.dart';
import 'transaction_entry_view.dart';

class TrackerView extends StatefulWidget {
  const TrackerView({super.key});

  @override
  State<TrackerView> createState() => _TrackerViewState();
}

class _TrackerViewState extends State<TrackerView> {
  final TrackerViewModel _viewModel = TrackerViewModel();

  bool _showIncome = false;

  @override
  void initState() {
    super.initState();
    _viewModel.loadData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _showTransactionEntry(
    BuildContext context,
    bool isIncome, {
    required int categoryIndex,
  }) async {
    final categories = _viewModel.categoriesFor(isIncome);
    final result = await showModalBottomSheet<TransactionEntryResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TransactionEntryView(
          categories: categories,
          initialCategoryIndex: categoryIndex,
          isIncome: isIncome,
        );
      },
    );

    if (result == null) {
      return;
    }

    _viewModel.addTransaction(
      amount: result.amount,
      isIncome: isIncome,
      categoryIndex: result.categoryIndex,
      date: result.date,
      tag: result.tag,
      comment: result.comment,
    );
  }

  // The Dark Theme Card Builder
  Widget _buildCategoryCard(
    TransactionCategory category,
    int index, {
    required bool isIncome,
  }) {
    return InkWell(
      // Passes the specific index to the dialog
      onTap: () =>
          _showTransactionEntry(context, isIncome, categoryIndex: index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                categoryIconFor(category.iconCode),
                color: isIncome ? Colors.greenAccent : Colors.orangeAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.categoryTotal.toStringAsFixed(2)} MVR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab({
    required String title,
    required double total,
    required bool isIncome,
  }) {
    final isSelected = _showIncome == isIncome;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _showIncome = isIncome;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF151519) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${total.toStringAsFixed(2)} MVR',
                style: TextStyle(
                  color: isIncome ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF48484F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildCategoryTab(
            title: 'Expenses',
            total: _viewModel.totalFor(false),
            isIncome: false,
          ),
          _buildCategoryTab(
            title: 'Incomes',
            total: _viewModel.totalFor(true),
            isIncome: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // (Note: The screenshot has "New category" here, but usually the main
        // screen says something like "Dashboard" or "Overall balance")
        title: const Text(
          'Overall balance',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        centerTitle: true,
      ),
      // 1. We moved the ListenableBuilder right here to wrap the whole body!
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final categories = _viewModel.categoriesFor(_showIncome);

          return Column(
            children: [
              const SizedBox(height: 10),
              // Overall Balance Text
              Text(
                '${_viewModel.overallBalance.toStringAsFixed(2)} MVR',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              _buildCategorySelector(),
              const SizedBox(height: 28),

              // The GridView
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      // 2. Just draw the normal cards! The + Add button is gone.
                      final category = categories[index];
                      return _buildCategoryCard(
                        category,
                        index,
                        isIncome: _showIncome,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'categories',
        backgroundColor: const Color(0xFF1C1C1E),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeCategoriesView(
                viewModel: _viewModel,
                isIncome: _showIncome,
              ),
            ),
          );
        },
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
