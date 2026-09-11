import 'package:flutter/material.dart';

import '../models/transaction_category.dart'; // Make sure to import this!

class AddCategoryView extends StatefulWidget {
  final TransactionCategory?
  existingCategory; // If null, we are creating. If not, we are editing!

  const AddCategoryView({super.key, this.existingCategory});

  @override
  State<AddCategoryView> createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  int _selectedIconCode = Icons.park.codePoint;
  final List<String> _subcategories = [];

  final List<IconData> _availableIcons = [
    Icons.park,
    Icons.lunch_dining,
    Icons.movie,
    Icons.checkroom,
    Icons.medical_services,
    Icons.directions_car,
    Icons.flight,
    Icons.pets,
    Icons.shopping_cart,
    Icons.sports_esports,
    Icons.school,
    Icons.home,

    // Income icons
    Icons.paid,
    Icons.work,
    Icons.account_balance,
    Icons.receipt_long,
  ];

  @override
  void initState() {
    super.initState();
    // If we passed in a category, pre-fill all the data!
    if (widget.existingCategory != null) {
      _titleController.text = widget.existingCategory!.name;
      _selectedIconCode = widget.existingCategory!.iconCode;
      _subcategories.addAll(widget.existingCategory!.subcategories);
    }
  }

  // Opens a pop-up menu at the bottom of the screen
  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: _availableIcons.length,
          itemBuilder: (context, index) {
            final icon = _availableIcons[index];
            return InkWell(
              onTap: () {
                setState(
                  () => _selectedIconCode = icon.codePoint,
                ); // Update state
                Navigator.pop(context); // Close the picker
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.orangeAccent, size: 32),
              ),
            );
          },
        );
      },
    );
  }

  // Adds a tag to our list and clears the text field
  void _addSubcategory() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _subcategories.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

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
          widget.existingCategory == null ? 'New category' : 'Edit category',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          // Show a delete icon ONLY if we are editing an existing category
          if (widget.existingCategory != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                // Return 'delete' action
                Navigator.pop(context, {'action': 'delete'});
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TITLE ---
            const Text(
              'Title',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter the title',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1C1C1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- ICON PICKER ---
            InkWell(
              onTap: _showIconPicker, // Open bottom sheet when tapped
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Icon',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Icon(
                      _availableIcons.firstWhere(
                        (icon) => icon.codePoint == _selectedIconCode,
                      ),
                      color: Colors.pinkAccent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- SUBCATEGORIES ---
            const Text(
              'Subcategories (Tags)',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a tag (e.g. Fuel)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1C1C1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _addSubcategory(), // Add when hitting "Enter" on keyboard
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.orangeAccent,
                    size: 36,
                  ),
                  onPressed: _addSubcategory, // Add when tapping the button
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Display the added tags as visual Chips
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _subcategories.map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFF2C2C2E),
                  deleteIcon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 18,
                  ),
                  onDeleted: () {
                    setState(
                      () => _subcategories.remove(tag),
                    ); // Remove tag if user taps 'X'
                  },
                );
              }).toList(),
            ),

            const Spacer(),

            // --- CREATE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  final title = _titleController.text.trim();
                  if (title.isNotEmpty) {
                    Navigator.pop(context, {
                      'action': 'save',
                      'title': title,
                      'iconCode': _selectedIconCode,
                      'subcategories': List<String>.from(_subcategories),
                    });
                  }
                },
                child: Text(
                  widget.existingCategory == null ? 'Create' : 'Save',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
