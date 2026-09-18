import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:secure_document_manager/features/auth/presentation/screens/login_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SecureDocumentManagerApp());
}

class SecureDocumentManagerApp extends StatelessWidget {
  const SecureDocumentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Document Manager',
      home: const LoginScreen(),
    );
  }
}