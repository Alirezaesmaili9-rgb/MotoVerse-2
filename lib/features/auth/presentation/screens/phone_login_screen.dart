import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

/// Phone OTP entry — the first step of authentication.
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _toE164(String input) {
    final digits = PersianUtils.toEn(input).replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) return '+98${digits.substring(1)}';
    if (digits.startsWith('98')) return '+$digits';
    return '+98$digits';
  }

  Future<void> _submit() async {
    final phone = _toE164(_controller.text);
    await ref.read(otpControllerProvider.notifier).sendOtp(phone);
    final state = ref.read(otpControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else if (state.valueOrNull == OtpStage.codeSent && mounted) {
      context.push(AppRoutes.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.brandGradient),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.two_wheeler, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 24),
              Text('به MotoVerse خوش آمدید',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'شماره موبایل خود را وارد کنید تا کد تأیید برایتان ارسال شود.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2),
                decoration: const InputDecoration(hintText: '0912 345 6789'),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'ارسال کد تأیید',
                gradient: true,
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('یا', style: Theme.of(context).textTheme.bodySmall),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),
              _OAuthButton(
                label: 'ورود با گوگل',
                icon: Icons.g_mobiledata,
                onTap: () =>
                    ref.read(authRepositoryProvider).signInWithGoogle(),
              ),
              const SizedBox(height: 10),
              _OAuthButton(
                label: 'ورود با Apple',
                icon: Icons.apple,
                onTap: () => ref.read(authRepositoryProvider).signInWithApple(),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.textPrimary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
