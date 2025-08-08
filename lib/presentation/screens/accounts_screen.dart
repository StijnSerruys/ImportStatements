import 'package:flutter/material.dart';
import '../db_helper.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final DBHelper dbh = DBHelper.instance;
  List<Map<String, dynamic>> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final db = await dbh.database;
    final res = await db.query('accounts');
    setState(() {
      _accounts = res;
      _loading = false;
    });
  }

  Future<void> _addOrEdit({Map<String, dynamic>? account}) async {
    final nameController =
        TextEditingController(text: account != null ? account['name'] : '');
    final numberController = TextEditingController(
        text: account != null ? account['account_number'] : '');
    final currencyController = TextEditingController(
        text: account != null ? account['currency'] : 'EUR');
    final balanceController = TextEditingController(
        text: account != null ? account['balance'].toString() : '0');

    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(account != null ? 'Bewerk account' : 'Nieuw account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Naam')),
                  TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Rekeningnummer')),
                  TextField(controller: currencyController, decoration: const InputDecoration(labelText: 'Valuta')),
                  TextField(controller: balanceController, decoration: const InputDecoration(labelText: 'Saldo'), keyboardType: TextInputType.number),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuleren')),
                ElevatedButton(
                    onPressed: () async {
                      final db = await dbh.database;
                      final data = {
                        'name': nameController.text,
                        'account_number': numberController.text,
                        'currency': currencyController.text,
                        'balance': double.tryParse(balanceController.text) ?? 0.0
                      };
                      if (account == null) {
                        await db.insert('accounts', data);
                      } else {
                        await db.update('accounts', data,
                            where: 'id=?', whereArgs: [account['id']]);
                      }
                      Navigator.pop(context);
                      _loadAccounts();
                    },
                    child: const Text('Opslaan'))
              ],
            ));
  }

  Future<void> _delete(int id) async {
    final db = await dbh.database;
    await db.delete('accounts', where: 'id=?', whereArgs: [id]);
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _accounts.length,
              itemBuilder: (_, i) {
                final acc = _accounts[i];
                return ListTile(
                  title: Text(acc['name']),
                  subtitle: Text('${acc['account_number']} (${acc['currency']})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: () => _addOrEdit(account: acc), icon: const Icon(Icons.edit)),
                      IconButton(onPressed: () => _delete(acc['id']), icon: const Icon(Icons.delete)),
                    ],
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
