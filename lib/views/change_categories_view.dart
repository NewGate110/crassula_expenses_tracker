import 'package:flutter/material.dart';

import '../view_models/tracker_view_model.dart';
import '../models/transaction_category.dart';
import 'add_category_view.dart';

class ChangeCategoriesView extends StatelessWidget {
  final TrackerViewModel viewModel;
  final bool isIncome;

  const ChangeCategoriesView({
    super.key,
    required this.viewModel,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isIncome ? 'Change income categories' : 'Change expense categories',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. Full Width "Create a new category" Button
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddCategoryView(),
                      ),
                    );
                    if (result != null && result['action'] == 'save') {
                      viewModel.addNewCategory(
                        result['title'],
                        result['iconCode'],
                        result['subcategories'],
                        isIncome: isIncome,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white54),
                        SizedBox(width: 8),
                        Text(
                          'Create a new category',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. The Grid of Categories to Edit
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: viewModel.categoriesFor(isIncome).length,
                    itemBuilder: (context, index) {
                      final category = viewModel.categoriesFor(isIncome)[index];
                      return _buildEditCard(context, category, index);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditCard(
    BuildContext context,
    TransactionCategory category,
    int index,
  ) {
    return InkWell(
      onTap: () async {
        // Open in EDIT mode by passing the existing category
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCategoryView(existingCategory: category),
          ),
        );

        if (result != null) {
          if (result['action'] == 'delete') {
            viewModel.deleteCategory(index, isIncome: isIncome);
          } else if (result['action'] == 'save') {
            viewModel.updateCategory(
              index,
              result['title'],
              result['iconCode'],
              result['subcategories'],
              isIncome: isIncome,
            );
          }
        }
      },
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
              child: Text(
                category.name,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
