mixin Loggable {
  void logAction(String action) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] [AUDIT] $action');
  }
}
