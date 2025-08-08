import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.initDb();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers later if needed
      ],
      child: MaterialApp(
        title: 'Statements App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const DashboardScreen(),
      ),
    );
  }
}
