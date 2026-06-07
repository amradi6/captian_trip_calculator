import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/l10n.dart';
import '../../widgets/shared_widgets.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  final _countryCode = '+966';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final phone = '$_countryCode${_phoneCtrl.text.trim()}';
    final ok = await auth.createAccount(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      phone,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final l = L10n(appState.language);
    final auth = context.watch<AuthProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              Text(l.createAccount,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(l.createAccountSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.secondary,
                ),
              ),
              const SizedBox(height: 28),
              // Full Name
              _label(context, l.fullName),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: l.isAr ? 'أدخل اسمك الكامل' : 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline, color: cs.secondary, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              // Email
              _label(context, l.email),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'example@mail.com',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.secondary, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              // Phone
              _label(context, l.phoneNumber),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E3F0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(_countryCode,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '5xxxxxxx',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Password
              _label(context, l.password),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, color: cs.secondary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: cs.secondary, size: 20,
                    ),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Confirm Password
              _label(context, l.confirmPassword),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, color: cs.secondary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: cs.secondary, size: 20,
                    ),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: l.createAccountBtn,
                loading: auth.loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}
