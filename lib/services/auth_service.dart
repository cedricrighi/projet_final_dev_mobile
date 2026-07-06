import 'package:local_auth/local_auth.dart';

/// Encapsule l'authentification biométrique (Face ID / Touch ID / empreinte).
///
/// C'est la fonctionnalité native "Le Plus" : elle protège l'accès à
/// l'onglet "Mon Garage".
class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Indique si l'appareil dispose d'une biométrie configurée et utilisable.
  Future<bool> canAuthenticate() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      // MissingPluginException (web/desktop) ou PlatformException : pas de biométrie.
      return false;
    }
  }

  /// Déclenche l'invite biométrique. Retourne `true` si l'utilisateur est
  /// authentifié. En l'absence de biométrie configurée, `biometricOnly: false`
  /// autorise le repli sur le code de déverrouillage de l'appareil.
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authentifiez-vous pour accéder à votre garage',
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
