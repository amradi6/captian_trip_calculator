import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/l10n.dart';
import 'dashboard_screen.dart';
import '../trip_calculator/trip_calculator_screen.dart';
import '../trip_history/trip_history_screen.dart';
import '../profile/captain_profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final l = L10n(appState.language);

    final screens = const [
      DashboardScreen(),
      TripCalculatorScreen(),
      TripHistoryScreen(),
      CaptainProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_rounded),
              label: l.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calculate_outlined),
              label: l.calculator,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_rounded),
              label: l.history,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              label: l.profile,
            ),
          ],
        ),
      ),
    );
  }
}
