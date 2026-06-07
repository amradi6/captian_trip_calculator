import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/models.dart';
import '../../utils/l10n.dart';
import '../../widgets/shared_widgets.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  int _filterIndex = 0;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TripModel> _filtered(List<TripModel> all, L10n l) {
    var list = all;
    // filter tab
    if (_filterIndex == 1) list = list.where((t) => t.status == 'completed').toList();
    if (_filterIndex == 2) list = list.where((t) => t.status == 'cancelled').toList();
    if (_filterIndex == 3) {
      final now = DateTime.now();
      list = list.where((t) {
        try {
          final d = DateTime.parse(t.dateTime);
          return now.difference(d).inDays < 7;
        } catch (_) { return false; }
      }).toList();
    }
    // search
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((t) =>
        t.pickupAddress.toLowerCase().contains(q) ||
        t.destinationAddress.toLowerCase().contains(q),
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final trips = context.watch<TripProvider>();
    final l = L10n(appState.language);
    final cs = Theme.of(context).colorScheme;
    final currency = appState.currency;
    final filtered = _filtered(trips.trips, l);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l.searchTrips,
                      prefixIcon: Icon(Icons.search, color: cs.secondary, size: 20),
                      suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Filter chips
                  FilterChipRow(
                    labels: [l.all, l.completed, l.cancelled, l.thisWeek],
                    selected: _filterIndex,
                    onSelected: (i) => setState(() => _filterIndex = i),
                  ),
                  const SizedBox(height: 14),
                  // Earnings banner
                  EarningsBanner(
                    label: l.totalEarningsMonth,
                    amount: trips.monthEarnings.toStringAsFixed(2),
                    currency: currency,
                  ),
                  const SizedBox(height: 14),
                  SectionHeader(title: '${l.recentTrips} (${filtered.length})'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: trips.loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                  ? Center(
                      child: Text(l.noTrips,
                        style: Theme.of(context).textTheme.bodyMedium),
                    )
                  : RefreshIndicator(
                      onRefresh: () => trips.loadTrips(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final t = filtered[i];
                          return TripListTile(
                            pickup: t.pickupAddress,
                            destination: t.destinationAddress,
                            distanceKm: t.distanceKm.toStringAsFixed(1),
                            durationMins: t.durationMins.toString(),
                            fare: '${t.fareAmount.toStringAsFixed(2)} $currency',
                            status: t.status,
                            dateLabel: t.dateTime.length >= 10
                              ? t.dateTime.substring(0, 10)
                              : t.dateTime,
                            onTap: () => Navigator.of(context).pushNamed(
                              '/trip-details', arguments: t.id,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
