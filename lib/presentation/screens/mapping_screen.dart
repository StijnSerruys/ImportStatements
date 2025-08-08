import 'package:flutter/material.dart';
import '../../data/db/db_helper.dart';

class MappingScreen extends StatefulWidget {
  final int importBatchId;
  const MappingScreen({super.key, required this.importBatchId});
  @override
  State<MappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends State<MappingScreen> {
  final DBHelper dbh = DBHelper.instance;
  List<Map<String, dynamic>> _toMap = [];
  List<Map<String, dynamic>> _cats = [];
  Map<String,int> _selections = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cs = await dbh.getCategories();
    final rows = await dbh.getUnmappedCounterparties(widget.importBatchId);
    setState(() {
      _cats = cs;
      _toMap = rows;
      _loading = false;
    });
  }

  Future<void> _saveAll() async {
    // create mappings and update transactions
    for (var row in _toMap) {
      final counter = row['counterparty'] as String;
      final selectedCatId = _selections[counter];
      if (selectedCatId == null) continue;
      // insert mapping
      final mappingId = await dbh.insertMapping({
        'counterparty': counter,
        'account_no': null,
        'category_id': selectedCatId,
        'created_at': DateTime.now().toIso8601String(),
        'created_by': 'user',
        'last_used_at': DateTime.now().toIso8601String()
      });
      // update tx rows
      await dbh.updateTransactionsByCounterparty(widget.importBatchId, counter, mappingId, selectedCatId);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mappings opgeslagen en transactions bijgewerkt')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk mapping')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _toMap.length,
              itemBuilder: (context, idx) {
                final counter = _toMap[idx]['counterparty'] as String;
                return ListTile(
                  title: Text(counter),
                  subtitle: const Text('Kies categorie'),
                  trailing: DropdownButton<int>(
                    value: _selections[counter],
                    hint: const Text('Select'),
                    items: _cats.map((c) => DropdownMenuItem<int>(value: c['id'] as int, child: Text(c['name']))).toList(),
                    onChanged: (v) { setState(()=> _selections[counter] = v!); },
                  ),
                );
              }
            )
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(onPressed: _saveAll, child: const Text('Save mappings')),
          )
        ],
      ),
    );
  }
}
