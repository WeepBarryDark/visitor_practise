class AuthNavDecision {
  final String? routeName;
  final bool clearAndBackToRoot;

  const AuthNavDecision({
    required this.routeName,
    required this.clearAndBackToRoot,
  });

  const AuthNavDecision.go(String route)
      : routeName = route,
        clearAndBackToRoot = false;

  const AuthNavDecision.backToRoot()
      : routeName = null,
        clearAndBackToRoot = true;
}
