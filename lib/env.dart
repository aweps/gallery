// Constant names mirror the --dart-define keys verbatim.
// ignore_for_file: constant_identifier_names

/// Build-time configuration injected via --dart-define (see _ops/.env
/// DART_DEFINES_B64_* payloads).
class EnvironmentConfig {
  static const APP_NAME = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Missing DartDefine',
  );
  static const APP_SUFFIX = String.fromEnvironment(
    'APP_SUFFIX',
    defaultValue: 'Missing DartDefine',
  );
}
