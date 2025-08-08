import 'package:flutter/material.dart';
import '../db_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final DBHelper dbh = DBHelper.instance;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _type = 'expense';
  int? _selectedAccount;
  int? _selectedCategory;

  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await dbh.database;
    final accs = await db.query('accounts');
    final cats = await db.query('categories');
    setState(() {
      _accounts = accs;
      _categories = cats;
      if (_accounts.isNotEmpty) _selectedAccount = _accounts.first['id'] as int;
    });
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    await dbh.insertTransaction({
      'account_id': _selectedAccount,
      'date': _selectedDate.toIso8601String(),
      'description': _descController.text,
      'amount': amount,
      'currency': _accounts.firstWhere((a) => a['id'] == _selectedAccount)['currency'],
      'type': _type,
      'category_id': _selectedCategory,
      'tags': _tagsController.text,
      'note': _noteController.text
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nieuwe transactie')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Bedrag'), keyboardType: TextInputType.number),
            DropdownButton<int>(
              value: _selectedAccount,
              isExpanded: true,
              hint: const Text('Selecteer account'),
              items: _accounts.map((acc) => DropdownMenuItem<int>(
                value: acc['id'] as int,
                child: Text(acc['name'])
              )).toList(),
              onChanged: (v) => setState(() => _selectedAccount = v),
            ),
            DropdownButton<String>(
              value: _type,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('Uitgave')),
                DropdownMenuItem(value: 'income', child: Text('Inkomst')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'expense'),
            ),
            DropdownButton<int>(
              value: _selectedCategory,
              isExpanded: true,
              hint: const Text('Selecteer categorie'),
              items: _categories.map((c) => DropdownMenuItem<int>(
                value: c['id'] as int,
                child: Text(c['name'])
              )).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Omschrijving')),
            TextField(controller: _tagsController, decoration: const InputDecoration(labelText: 'Tags')),
            TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Opmerking')),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Datum: ${_selectedDate.toLocal()}'.split(' ')[0]),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100)
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: const Text('Kies datum'),
                )
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Opslaan'))
          ],
        ),
      ),
    );
  }
}
