import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category_bloc.dart';
import '../blocs/category_state.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Transaction', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount (₹)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Expense'),
                  value: 'debit',
                  groupValue: _selectedType,
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Income'),
                  value: 'credit',
                  groupValue: _selectedType,
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoaded) {
                 if (state.categories.isEmpty) {
                   return const Text('Please add a category first from the top right menu.', style: TextStyle(color: Colors.red));
                 }
                 
                 // if the selected category is null, or got deleted and is no longer in the list, default to the first
                 if (_selectedCategory == null || !state.categories.any((c) => c.id == _selectedCategory)) {
                     _selectedCategory = state.categories.first.id;
                 }

                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: state.categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final double? amount = double.tryParse(_amountController.text);
                if (amount != null && _noteController.text.isNotEmpty && _selectedCategory != null) {
                  context.read<TransactionBloc>().add(AddTransaction(
                    amount: amount,
                    note: _noteController.text,
                    type: _selectedType,
                    categoryId: _selectedCategory!,
                  ));
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields properly')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
