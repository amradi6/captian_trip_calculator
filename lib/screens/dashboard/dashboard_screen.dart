import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/l10n.dart';
import '../../widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final auth = context.watch<AuthProvider>();
    final trips = context.watch<TripProvider>();
    final l = L10n(appState.language);
    final cs = Theme.of(context).colorScheme;

    final name = auth.userModel?.displayName
      ?? auth.firebaseUser?.displayName
      ?? (appState.isAr ? 'كابتن' : 'Captain');
    final currency = appState.currency;
    final totalStr = trips.monthEarnings.toStringAsFixed(2);
    final todayStr = trips.todayEarnings.toStringAsFixed(2);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => trips.loadTrips(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.goodMorning,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(name,
                            style: Theme.of(context).textTheme.headlineSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    LangToggle(
                      current: appState.language,
                      onChanged: (lang) => appState.setLanguage(lang),
                    ),
                    const SizedBox(width: 10),
                    // Avatar
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      backgroundImage: auth.firebaseUser?.photoURL != null
                        ? NetworkImage(auth.firebaseUser!.photoURL!)
                        : null,
                      child: auth.firebaseUser?.photoURL == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'C',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    StatCard(
                      label: l.todayEarnings,
                      value: '$todayStr $currency',
                      icon: Icons.play_circle_outline_rounded,
                      iconBg: AppColors.primary,
                    ),
                    StatCard(
                      label: l.totalTrips,
                      value: '${trips.completedTrips} ${l.trips}',
                      icon: Icons.swap_horiz_rounded,
                      iconBg: AppColors.primary,
                    ),
                    StatCard(
                      label: l.kilometers,
                      value: '${trips.totalKm.toStringAsFixed(1)} ${l.km}',
                      icon: Icons.route_rounded,
                      iconBg: AppColors.tertiary,
                    ),
                    StatCard(
                      label: l.rating,
                      value: (auth.userModel?.rating ?? 5.0).toStringAsFixed(1),
                      icon: Icons.star_rounded,
                      iconBg: AppColors.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Total earnings row
                Row(
                  children: [
                    Text('${l.totalEarnings}: ', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      '$totalStr $currency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 16),
                // Earnings chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: WeeklyEarningsChart(
                    data: trips.weeklyData,
                    labels: l.weekDays,
                  ),
                ),
                const SizedBox(height: 20),
                // Recent trips
                SectionHeader(
                  title: l.recentTrips,
                  actionLabel: l.seeAll,
                ),
                const SizedBox(height: 12),
                if (trips.loading)
                  const Center(child: CircularProgressIndicator())
                else if (trips.trips.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l.noTrips,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ...trips.trips.take(3).map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TripListTile(
                      pickup: t.pickupAddress,
                      destination: t.destinationAddress,
                      distanceKm: t.distanceKm.toStringAsFixed(1),
                      durationMins: t.durationMins.toString(),
                      fare: '${t.fareAmount.toStringAsFixed(2)} $currency',
                      status: t.status,
                      dateLabel: t.dateTime.length >= 10 ? t.dateTime.substring(0, 10) : t.dateTime,
                      onTap: () => Navigator.of(context).pushNamed(
                        '/trip-details', arguments: t.id,
                      ),
                    ),
                  )),
                const SizedBox(height: 24),
                // CTA
                ElevatedButton.icon(
                  onPressed: () {
                    // switch to calculator tab via parent
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l.startNewTrip),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
