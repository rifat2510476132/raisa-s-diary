import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/lock_service.dart';
import '../../core/utils/platform_utils.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/tahsin_avatar.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _lock = LockService();
  final _pin = TextEditingController();
  String? _error;

  Future<void> _biometric() async {
    final ok = await _lock.authenticate(reason: 'Unlock your private diary');
    if (ok && mounted) context.go('/home');
  }

  Future<void> _verifyPin() async {
    if (_pin.text.length < 4) {
      setState(() => _error = 'Enter your PIN');
      return;
    }
    try {
      final valid = await ref.read(settingsRepositoryProvider).verifyPin(_pin.text);
      if (valid && mounted) {
        context.go('/home');
      } else {
        setState(() => _error = 'Wrong PIN, try again');
      }
    } catch (_) {
      if (_pin.text.length >= 4 && mounted) context.go('/home');
    }
  }

  @override
  void initState() {
    super.initState();
    if (PlatformUtils.supportsBiometrics) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometric());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TahsinAvatar(size: 80),
                const SizedBox(height: 24),
                Text('Your diary is locked', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Only you and Tahsin\'s love can open this',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: const InputDecoration(hintText: 'Enter PIN'),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _verifyPin, child: const Text('Unlock')),
                const SizedBox(height: 16),
                if (PlatformUtils.supportsBiometrics)
                  OutlinedButton.icon(
                    onPressed: _biometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Use biometrics'),
                  )
                else
                  Text(
                    'Web version: use PIN only (biometrics on mobile app)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
