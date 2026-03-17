import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category_bloc.dart';
import '../blocs/category_state.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';
import '../utils/app_colors.dart';
import '../widgets/primary_button.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({Key? key}) : super(key: key);

  @override
  _AddTransactionSheetState createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedType = 'debit';
  String? _selectedCategory;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'ADD Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildTypeToggle(),
            const SizedBox(height: 32),
            const Text('How much?', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '₹0',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('Towards'),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(hintText: 'What was this for?'),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('Category'),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoaded) {
                  if (state.categories.isEmpty) {
                    return const Text('No categories', style: TextStyle(color: AppColors.expense));
                  }
                  if (_selectedCategory == null || !state.categories.any((c) => c.id == _selectedCategory)) {
                    _selectedCategory = state.categories.first.id;
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: state.categories.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  );
                }
                return const LinearProgressIndicator();
              },
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'Save',
              onPressed: () {
                final double? amount = double.tryParse(_amountController.text.replaceAll('₹', ''));
                if (amount != null && _noteController.text.isNotEmpty && _selectedCategory != null) {
                  context.read<TransactionBloc>().add(AddTransaction(
                    amount: amount,
                    note: _noteController.text,
                    type: _selectedType,
                    categoryId: _selectedCategory!,
                  ));
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleItem('Expense', 'debit', AppColors.expense)),
          Expanded(child: _buildToggleItem('Income', 'credit', AppColors.income)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, String type, Color activeColor) {
    bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
