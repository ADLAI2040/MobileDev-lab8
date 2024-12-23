import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/transaction_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ugsqvryvzcwfilzzlywb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnc3F2cnl2emN3ZmlsenpseXdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ4ODIzMDQsImV4cCI6MjA1MDQ1ODMwNH0.5hU88ey28j70Fr-x8S-tIr6AOTMx3pfoZXg1Fbic-uM',
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TransactionScreen(),
    );
  }
}
