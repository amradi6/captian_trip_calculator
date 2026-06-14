import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/l10n.dart';

class CaptainProfileScreen extends StatelessWidget {
  const CaptainProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final auth = context.watch<AuthProvider>();
    final trips = context.watch<TripProvider>();
    final l = L10n(appState.language);
    final cs = Theme.of(context).colorScheme;

    final name = auth.userModel?.displayName
      ?? auth.firebaseUser?.displayName
      ?? 'Captain';
    final rating = auth.userModel?.rating ?? 5.0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue header
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      // IconButton(
                      //   icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      //     color: Colors.white, size: 18),
                      //   onPressed: () {},
                      // ),
                      Expanded(
                        child: Text(l.captainProfile,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  //     IconButton(
                  //       icon: const Icon(Icons.edit_outlined,
                  //         color: Colors.white, size: 18),
                  //       onPressed: () {},
                  //     ),
                     ],
                   ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: auth.firebaseUser?.photoURL != null
                      ? NetworkImage(auth.firebaseUser!.photoURL!)
                      : null,
                    child: auth.firebaseUser?.photoURL == null
                      ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ))
                      : null,
                  ),
                  const SizedBox(height: 10),
                  Text(name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded,
                        color: AppColors.tertiary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(2)} • ${l.goldCaptain}',
                        style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Stats card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _statItem(context,
                      trips.completedTrips.toString(), l.totalTripsLabel),
                    _divider(),
                    _statItem(context,
                      rating.toStringAsFixed(1), l.ratingLabel),
                    _divider(),
                    _statItem(context, '3.5', l.yearsLabel),
                  ],
                ),
              ),
            ),
            // Vehicle info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.vehicleInfo,
                    style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.directions_car_rounded,
                            color: AppColors.secondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ABC 1234 • White',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('Toyota Camry 2022',
                                style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(l.active,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l.accountSettings,
                    style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  _settingTile(context,
                    Icons.person_outline, Colors.blue, l.personalInfo, l.personalInfoSub),
                  const SizedBox(height: 8),
                  _settingTile(context,
                    Icons.account_balance_outlined, Colors.green, l.payoutSettings, l.payoutSettingsSub),
                  const SizedBox(height: 8),
                  _settingTile(context,
                    Icons.settings_outlined, Colors.orange, l.appSettings, ''),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                      label: Text(l.signOut,
                        style: const TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: AppColors.divider);
  }

  Widget _settingTile(BuildContext context, IconData icon, Color color,
      String title, String subtitle) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
          : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppColors.secondary),
        onTap: () {
          if (title.contains('Settings') || title.contains('إعدادات')) {
            Navigator.of(context).pushNamed('/settings');
          }
        },
      ),
    );
  }
}
