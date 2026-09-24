import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:secure_document_manager/features/auth/providers/user_provider.dart';
import 'package:secure_document_manager/features/auth/presentation/screens/dashboard_home_screen.dart';
import 'package:secure_document_manager/features/auth/presentation/screens/profile_screen.dart';
import 'package:secure_document_manager/features/auth/presentation/widgets/dashboard/dashboard_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    context.read<UserProvider>().loadUser();

    _screens = [
      const DashboardHomeScreen(),
      const Center(
        child: Text('Documents'),
      ),
      const Center(
        child: Text('AI'),
      ),
      const Center(
        child: Text('Messages'),
      ),
      const ProfileScreen(),
    ];
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            18,
          ),
          child: DashboardBottomNav(
            selectedIndex: _selectedIndex,
            onItemSelected: _onNavigationChanged,
          ),
        ),
      ),
    );
  }
}