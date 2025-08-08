import 'package:flutter/material.dart';
import '../db_helper.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DBHelper dbh = DBHelper.instance;
  List<Map<String, dynamic>> _cats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCats();
  }

  Future<void> _loadCats() async {
    final res = await dbh.getCategories();
    setState(() {
      _cats = res;
      _loading = false;
    });
  }

  Future<void> _addOrEdit({Map<String, dynamic>? cat}) async {
    final nameController =
        TextEditingController(text: cat != null ? cat['name'] : '');
    final budgetController = TextEditingController(
        text: cat != null ? cat['monthly_budget'].toString() : '0');

    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(cat != null ? 'Bewerk categorie' : 'Nieuwe categorie'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Naam')),
                  TextField(controller: budgetController, decoration: const InputDecoration(labelText: 'Maandbudget'), keyboardType: TextInputType.number),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuleren')),
                ElevatedButton(
                    onPressed: () async {
                      final db = await dbh.database;
                      final data = {
                        'name': nameController.text,
                        'monthly_budget': double.tryParse(budgetController.text) ?? 0.0
                      };
                      if (cat == null) {
                        await db.insert('categories', data);
                      } else {
                        await db.update('categories', data, where: 'id=?', whereArgs: [cat['id']]);
                      }
                      Navigator.pop(context);
                      _loadCats();
                    },
                    child: const Text('Opslaan'))
              ],
            ));
  }

  Future<void> _delete(int id) async {
    final db = await dbh.database;
    await db.delete('categories', where: 'id=?', whereArgs: [id]);
    _loadCats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorieën')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _cats.length,
              itemBuilder: (_, i) {
                final c = _cats[i];
                return ListTile(
                  title: Text(c['name']),
                  subtitle: Text('Budget: €${c['monthly_budget']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: () => _addOrEdit(cat: c), icon: const Icon(Icons.edit)),
                      IconButton(onPressed: () => _delete(c['id']), icon: const Icon(Icons.delete)),
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
