import 'package:crassula_tracker/view_models/tracker_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'an expense creates a saved transaction and reduces the balance',
    () async {
      final viewModel = TrackerViewModel();
      final date = DateTime(2026, 9, 12);

      viewModel.addTransaction(
        amount: 25.50,
        isIncome: false,
        categoryIndex: 0,
        date: date,
        tag: 'Lunch',
        comment: 'Cafe',
      );
      await viewModel.saveData();

      expect(viewModel.overallBalance, 474.50);
      expect(viewModel.expenseCategories[0].categoryTotal, 25.50);
      expect(viewModel.transactions, hasLength(1));

      final restoredViewModel = TrackerViewModel();
      await restoredViewModel.loadData();

      final restored = restoredViewModel.transactions.single;
      expect(restored.amount, 25.50);
      expect(restored.categoryName, 'Food');
      expect(restored.tag, 'Lunch');
      expect(restored.comment, 'Cafe');
      expect(restored.date, date);
    },
  );

  test('income increases both its category total and overall balance', () {
    final viewModel = TrackerViewModel();

    viewModel.addTransaction(
      amount: 100,
      isIncome: true,
      categoryIndex: 0,
      date: DateTime(2026, 9, 12),
    );

    expect(viewModel.overallBalance, 600);
    expect(viewModel.incomeCategories[0].categoryTotal, 100);
    expect(viewModel.transactions.single.isIncome, isTrue);
  });

  test('negative expenses and incomes reverse their usual balance effect', () {
    final viewModel = TrackerViewModel();
    final date = DateTime(2026, 9, 12);

    viewModel.addTransaction(
      amount: -20,
      isIncome: false,
      categoryIndex: 0,
      date: date,
    );
    expect(viewModel.overallBalance, 520);
    expect(viewModel.expenseCategories[0].categoryTotal, -20);

    viewModel.addTransaction(
      amount: -50,
      isIncome: true,
      categoryIndex: 0,
      date: date,
    );
    expect(viewModel.overallBalance, 470);
    expect(viewModel.incomeCategories[0].categoryTotal, -50);
  });
}
