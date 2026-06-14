import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/l10n.dart';
import '../../widgets/shared_widgets.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl = TextEditingController(
        text: auth.userModel?.displayName ?? auth.firebaseUser?.displayName ?? '');
    _phoneCtrl = TextEditingController(text: auth.userModel?.phoneNumber ?? '');
    _emailCtrl = TextEditingController(
        text: auth.userModel?.email ?? auth.firebaseUser?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      displayName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final auth = context.watch<AuthProvider>();
    final l = L10n(appState.language);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.personalInfo),
        centerTitle: true,
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                backgroundImage: auth.firebaseUser?.photoURL != null
                    ? NetworkImage(auth.firebaseUser!.photoURL!)
                    : null,
                child: auth.firebaseUser?.photoURL == null
                    ? Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 28),
            _field(
              context,
              label: l.fullName,
              controller: _nameCtrl,
              icon: Icons.person_outline,
              enabled: _editing,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 14),
            _field(
              context,
              label: l.email,
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              enabled: false,
              keyboardType: TextInputType.emailAddress,
              hint: 'Email cannot be changed here.',
            ),
            const SizedBox(height: 14),
            _field(
              context,
              label: l.phoneNumber,
              controller: _phoneCtrl,
              icon: Icons.phone_outlined,
              enabled: _editing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 28),
            if (_editing) ...[
              PrimaryButton(
                label: appState.isAr ? 'حفظ التغييرات' : 'Save Changes',
                loading: auth.loading,
                onPressed: _save,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    final a = context.read<AuthProvider>();
                    _nameCtrl.text =
                        a.userModel?.displayName ?? a.firebaseUser?.displayName ?? '';
                    _phoneCtrl.text = a.userModel?.phoneNumber ?? '';
                    setState(() => _editing = false);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: cs.outline),
                  ),
                  child: Text(appState.isAr ? 'إلغاء' : 'Cancel'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: cs.secondary),
            hintText: hint,
            filled: !enabled,
            fillColor: enabled ? null : cs.surfaceContainerHighest.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
