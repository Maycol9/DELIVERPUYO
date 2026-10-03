enum UiDemoState { normal, loading, empty, error }

class AppDemoConfig {
  const AppDemoConfig._();

  static const String _rawState = String.fromEnvironment(
    'UI_DEMO_STATE',
    defaultValue: 'normal',
  );

  static UiDemoState get state {
    return switch (_rawState.toLowerCase()) {
      'loading' => UiDemoState.loading,
      'empty' => UiDemoState.empty,
      'error' => UiDemoState.error,
      _ => UiDemoState.normal,
    };
  }

  static bool get isDemoMode => state != UiDemoState.normal;
}
