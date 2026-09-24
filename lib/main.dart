import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:secure_document_manager/features/auth/presentation/screens/dashboard_screen.dart';
import 'package:secure_document_manager/features/auth/providers/user_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Secure Document Manager',
        home: const DashboardScreen(),
      ),
    );
  }
}