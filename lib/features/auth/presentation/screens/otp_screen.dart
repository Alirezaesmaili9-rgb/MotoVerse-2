import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

/// OTP verification step.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    await ref.read(otpControllerProvider.notifier).verify(_controller.text.trim());
    final state = ref.read(otpControllerProvider);
    if (!mounted) return;
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else if (state.valueOrNull == OtpStage.verified) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpControllerProvider);
    final phone = ref.read(otpControllerProvider.notifier).phone ?? '';

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('کد تأیید را وارد کنید',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('کد ۶ رقمی به شماره $phone ارسال شد.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 28),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 8),
              decoration: const InputDecoration(counterText: ''),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'تأیید و ورود',
              gradient: true,
              isLoading: state.isLoading,
              onPressed: _verify,
            ),
          ],
        ),
      ),
    );
  }
}
