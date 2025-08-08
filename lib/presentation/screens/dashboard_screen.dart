drawer: Drawer(
  child: ListView(
    children: [
      const DrawerHeader(child: Text('Menu')),
      ListTile(
        leading: const Icon(Icons.import_export),
        title: const Text('Import'),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportScreen()));
        }
      ),
      ListTile(
        leading: const Icon(Icons.account_balance),
        title: const Text('Accounts'),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountsScreen()));
        }
      ),
      ListTile(
        leading: const Icon(Icons.category),
        title: const Text('Categorieën'),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesScreen()));
        }
      ),
      ListTile(
        leading: const Icon(Icons.add),
        title: const Text('Nieuwe transactie'),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        }
      )
    ],
  ),
),
