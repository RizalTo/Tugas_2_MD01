
import 'package:flutter/material.dart';
import 'package:inventory_system/auth/auth_get.dart';
import 'package:inventory_system/pages/barang/barang_page.dart';
import 'package:inventory_system/pages/dashboard_page.dart';
import 'package:inventory_system/pages/login_page.dart';
import 'package:inventory_system/pages/register_page.dart';
import 'package:inventory_system/pages/supplier/supplier_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://tlyvzxglfadbigehsbck.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRseXZ6eGdsZmFkYmlnZWhzYmNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwMTcwNDksImV4cCI6MjA1MDU5MzA0OX0._7s4hWl9rcI3G9c1lwkhmdx6ldER5q9S0LWmglWlJ9I',
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'Inventaris',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGet(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/barangList': (context) => const BarangPage(),
        '/supplierList': (context) => const SupplierPage(),
      },
    );
  }
}