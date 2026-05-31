import '../utils/platform_utils.dart';
import 'package:local_auth/local_auth.dart';

class LockService {
  final _auth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    if (!PlatformUtils.supportsBiometrics) return false;
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Unlock your diary'}) async {
    if (!PlatformUtils.supportsBiometrics) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
