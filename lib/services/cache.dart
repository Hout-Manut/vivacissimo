class Cache {
  static final Map<String, dynamic> _cache = {};

  static R cache<T, R>(
    String cacheKey,
    R Function() function,
  ) {
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as R;
    } else {
      final result = function();
      _cache[cacheKey] = result;
      return result;
    }
  }

  static Future<R> cacheAsync<T, R>(
    String cacheKey,
    Future<R> Function() function,
  ) async {
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as R;
    } else {
      final result = await function();
      _cache[cacheKey] = result;
      return result;
    }
  }

  static void clear() => _cache.clear();
}
