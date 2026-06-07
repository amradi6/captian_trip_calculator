import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/l10n.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final l = L10n(appState.language);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.appSettings),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance
            _sectionTitle(context, l.appearance),
            const SizedBox(height: 10),
            _settingTile(
              context,
              leading: _iconBox(Icons.dark_mode_rounded, Colors.blue),
              title: l.darkMode,
              subtitle: l.darkModeDesc,
              trailing: Switch(
                value: appState.isDark,
                onChanged: (v) => appState.setDarkMode(v),
              ),
            ),
            const SizedBox(height: 8),
            _settingTile(
              context,
              leading: _iconBox(Icons.translate_rounded, Colors.purple),
              title: l.language,
              subtitle: l.languageValue,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appState.isAr ? 'العربية' : 'English',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.secondary,
                    )),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.secondary),
                ],
              ),
              onTap: () => _showLanguagePicker(context, appState, l),
            ),
            const SizedBox(height: 20),
            // Trip Calculator
            _sectionTitle(context, l.tripCalculator),
            const SizedBox(height: 10),
            _settingTile(
              context,
              leading: _iconBox(Icons.route_rounded, Colors.teal),
              title: l.distanceUnit,
              subtitle: l.distanceUnitValue,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appState.distanceUnit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.secondary,
                    )),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.secondary),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _settingTile(
              context,
              leading: _iconBox(Icons.currency_exchange_rounded, Colors.orange),
              title: l.currency,
              subtitle: appState.currency,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appState.currency,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.secondary,
                    )),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.secondary),
                ],
              ),
              onTap: () => _showCurrencyPicker(context, appState),
            ),
            const SizedBox(height: 20),
            // Notifications
            _sectionTitle(context, l.notifications),
            const SizedBox(height: 10),
            _settingTile(
              context,
              leading: _iconBox(Icons.notifications_active_outlined, Colors.red),
              title: l.pushNotifications,
              trailing: Switch(
                value: appState.pushNotifications,
                onChanged: (v) => appState.setPushNotifications(v),
              ),
            ),
            const SizedBox(height: 8),
            _settingTile(
              context,
              leading: _iconBox(Icons.location_on_outlined, Colors.green),
              title: l.tripAlerts,
              subtitle: l.tripAlertsDesc,
              trailing: Switch(
                value: appState.tripAlerts,
                onChanged: (v) => appState.setTripAlerts(v),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AppStateProvider appState, L10n l) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.language,
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...['en', 'ar'].map((lang) => ListTile(
              title: Text(lang == 'en' ? 'English' : 'العربية'),
              trailing: appState.language == lang
                ? const Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
              onTap: () {
                appState.setLanguage(lang);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Currency',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...['SAR', 'AED', 'USD', 'EGP', 'KWD'].map((c) => ListTile(
              title: Text(c),
              trailing: appState.currency == c
                ? const Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
              onTap: () {
                appState.setCurrency(c);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.secondary,
        fontSize: 12,
        letterSpacing: 0.5,
      ));
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _settingTile(
    BuildContext context, {
    required Widget leading,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
