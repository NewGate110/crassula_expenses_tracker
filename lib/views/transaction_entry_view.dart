import 'package:flutter/material.dart';

import '../models/transaction_category.dart';

class TransactionEntryResult {
  final double amount;
  final int categoryIndex;
  final DateTime date;
  final String? tag;
  final String comment;

  const TransactionEntryResult({
    required this.amount,
    required this.categoryIndex,
    required this.date,
    required this.tag,
    required this.comment,
  });
}

class TransactionEntryView extends StatefulWidget {
  final List<TransactionCategory> categories;
  final int initialCategoryIndex;
  final bool isIncome;

  const TransactionEntryView({
    super.key,
    required this.categories,
    required this.initialCategoryIndex,
    required this.isIncome,
  });

  @override
  State<TransactionEntryView> createState() => _TransactionEntryViewState();
}

class _TransactionEntryViewState extends State<TransactionEntryView> {
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final TextEditingController _commentController = TextEditingController();

  late int _selectedCategoryIndex;
  late DateTime _selectedDate;
  String? _selectedTag;
  String _display = '0';
  String? _errorText;
  double? _storedValue;
  String? _pendingOperator;
  bool _replaceDisplay = true;

  TransactionCategory get _selectedCategory =>
      widget.categories[_selectedCategoryIndex];

  String get _calculatorDisplay {
    if (_storedValue != null && _pendingOperator != null) {
      final firstValue = _formatNumber(_storedValue!);
      if (_replaceDisplay) {
        return '$firstValue $_pendingOperator';
      }
      return '$firstValue $_pendingOperator $_display';
    }
    return _display;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex;
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final prefix = isToday ? 'Today, ' : '';
    return '$prefix${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _inputCharacter(String character) {
    setState(() {
      _errorText = null;
      if (_replaceDisplay) {
        _display = character == '.' ? '0.' : character;
        _replaceDisplay = false;
        return;
      }

      if (character == '.' && _display.contains('.')) {
        return;
      }
      if (_display == '0' && character != '.') {
        _display = character;
      } else if (_display == '-0' && character != '.') {
        _display = '-$character';
      } else if (_display.length < 12) {
        _display += character;
      }
    });
  }

  void _clearCalculator() {
    setState(() {
      _display = '0';
      _storedValue = null;
      _pendingOperator = null;
      _replaceDisplay = true;
      _errorText = null;
    });
  }

  void _backspace() {
    setState(() {
      _errorText = null;
      if (_replaceDisplay ||
          _display.length <= 1 ||
          (_display.startsWith('-') && _display.length <= 2)) {
        _display = '0';
        _replaceDisplay = true;
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _toggleSign() {
    setState(() {
      _errorText = null;
      if (_replaceDisplay) {
        _display = '-0';
        _replaceDisplay = false;
      } else if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  bool _evaluatePending() {
    if (_storedValue == null || _pendingOperator == null) {
      return true;
    }

    final currentValue = double.tryParse(_display);
    if (currentValue == null) {
      return false;
    }

    double result;
    switch (_pendingOperator) {
      case '+':
        result = _storedValue! + currentValue;
      case '-':
        result = _storedValue! - currentValue;
      case '×':
        result = _storedValue! * currentValue;
      case '÷':
        if (currentValue == 0) {
          setState(() => _errorText = 'Cannot divide by zero');
          return false;
        }
        result = _storedValue! / currentValue;
      default:
        return false;
    }

    setState(() {
      _display = _formatNumber(result);
      _storedValue = null;
      _pendingOperator = null;
      _replaceDisplay = true;
      _errorText = null;
    });
    return true;
  }

  void _chooseOperator(String value) {
    if (_pendingOperator != null && _replaceDisplay) {
      setState(() => _pendingOperator = value);
      return;
    }

    if (_pendingOperator != null && !_evaluatePending()) {
      return;
    }

    final currentValue = double.tryParse(_display);
    if (currentValue == null) {
      return;
    }

    setState(() {
      _storedValue = currentValue;
      _pendingOperator = value;
      _replaceDisplay = true;
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orangeAccent,
              surface: Color(0xFF1C1C1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _pickCategory() async {
    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              return ListTile(
                leading: Icon(
                  categoryIconFor(category.iconCode),
                  color: widget.isIncome
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: index == _selectedCategoryIndex
                    ? const Icon(Icons.check, color: Colors.orangeAccent)
                    : null,
                onTap: () => Navigator.pop(context, index),
              );
            },
          ),
        );
      },
    );

    if (selectedIndex != null && mounted) {
      setState(() {
        _selectedCategoryIndex = selectedIndex;
        _selectedTag = null;
      });
    }
  }

  void _saveTransaction() {
    if (_pendingOperator != null && !_replaceDisplay && !_evaluatePending()) {
      return;
    }

    final amount = double.tryParse(_display);
    if (amount == null || !amount.isFinite || amount == 0) {
      setState(() => _errorText = 'Enter a non-zero amount');
      return;
    }

    Navigator.pop(
      context,
      TransactionEntryResult(
        amount: amount,
        categoryIndex: _selectedCategoryIndex,
        date: _selectedDate,
        tag: _selectedTag,
        comment: _commentController.text.trim(),
      ),
    );
  }

  Widget _calculatorButton(
    String label, {
    VoidCallback? onPressed,
    Color? foregroundColor,
    Color? backgroundColor,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 62,
          child: Material(
            color: backgroundColor ?? const Color(0xFF000000),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(18),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor ?? Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryCard() {
    final accentColor = widget.isIncome
        ? Colors.greenAccent
        : Colors.orangeAccent;
    return InkWell(
      onTap: _pickCategory,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Icon(
              categoryIconFor(_selectedCategory.iconCode),
              color: accentColor,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _selectedCategory.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 19),
                  ),
                ],
              ),
            ),
            const Icon(Icons.expand_more, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tags = _selectedCategory.subcategories;

    return FractionallySizedBox(
      heightFactor: 0.95,

      child: Material(
        color: const Color(0xFF1C1C1E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                    Expanded(
                      child: Text(
                        widget.isIncome ? 'Add income' : 'Add expense',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(
                            const Duration(days: 1),
                          );
                        });
                      },
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white70,
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(
                          Icons.calendar_month,
                          color: Colors.orangeAccent,
                        ),
                        label: Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(
                            const Duration(days: 1),
                          );
                        });
                      },
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _categoryCard(),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) {
                        return ChoiceChip(
                          label: Text(tag),
                          selected: _selectedTag == tag,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTag = selected ? tag : null;
                            });
                          },
                          labelStyle: TextStyle(
                            color: _selectedTag == tag
                                ? Colors.black
                                : Colors.white70,
                          ),
                          selectedColor: Colors.orangeAccent,
                          backgroundColor: const Color(0xFF2C2C2E),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                TextField(
                  controller: _commentController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white54,
                    ),
                    hintText: 'Add a comment',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '$_calculatorDisplay MVR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _calculatorButton(
                      'C',
                      onPressed: _clearCalculator,
                      foregroundColor: Colors.redAccent,
                    ),
                    _calculatorButton(
                      '±',
                      onPressed: _toggleSign,
                      foregroundColor: Colors.orangeAccent,
                    ),
                    _calculatorButton(
                      '⌫',
                      onPressed: _backspace,
                      foregroundColor: Colors.redAccent,
                    ),
                    _calculatorButton(
                      '÷',
                      onPressed: () => _chooseOperator('÷'),
                      foregroundColor: Colors.orangeAccent,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _calculatorButton(
                      '7',
                      onPressed: () => _inputCharacter('7'),
                    ),
                    _calculatorButton(
                      '8',
                      onPressed: () => _inputCharacter('8'),
                    ),
                    _calculatorButton(
                      '9',
                      onPressed: () => _inputCharacter('9'),
                    ),
                    _calculatorButton(
                      '×',
                      onPressed: () => _chooseOperator('×'),
                      foregroundColor: Colors.orangeAccent,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _calculatorButton(
                      '4',
                      onPressed: () => _inputCharacter('4'),
                    ),
                    _calculatorButton(
                      '5',
                      onPressed: () => _inputCharacter('5'),
                    ),
                    _calculatorButton(
                      '6',
                      onPressed: () => _inputCharacter('6'),
                    ),
                    _calculatorButton(
                      '-',
                      onPressed: () => _chooseOperator('-'),
                      foregroundColor: Colors.orangeAccent,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _calculatorButton(
                      '1',
                      onPressed: () => _inputCharacter('1'),
                    ),
                    _calculatorButton(
                      '2',
                      onPressed: () => _inputCharacter('2'),
                    ),
                    _calculatorButton(
                      '3',
                      onPressed: () => _inputCharacter('3'),
                    ),
                    _calculatorButton(
                      '+',
                      onPressed: () => _chooseOperator('+'),
                      foregroundColor: Colors.orangeAccent,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _calculatorButton(
                      '0',
                      flex: 2,
                      onPressed: () => _inputCharacter('0'),
                    ),
                    _calculatorButton(
                      '.',
                      onPressed: () => _inputCharacter('.'),
                    ),
                    _calculatorButton(
                      '=',
                      onPressed: _evaluatePending,
                      foregroundColor: Colors.orangeAccent,
                    ),
                    _calculatorButton(
                      '✓',
                      onPressed: _saveTransaction,
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
