import 'dart:async';
import 'dart:collection';
import 'dart:math';

/// A token-bucket rate limiter that throttles requests to respect third-party provider limits.
class ProviderRateLimiter {
  ProviderRateLimiter({
    required this.provider,
    required this.maxRequests,
    required this.interval,
  }) : _tokens = maxRequests.toDouble() {
    _lastRefillTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// Preset constructors for well-known providers.
  factory ProviderRateLimiter.openLibrary() => ProviderRateLimiter(
        provider: 'openlibrary',
        maxRequests: 1,
        interval: const Duration(milliseconds: 1000),
      );

  factory ProviderRateLimiter.musicBrainz() => ProviderRateLimiter(
        provider: 'musicbrainz',
        maxRequests: 1,
        interval: const Duration(milliseconds: 1000),
      );

  factory ProviderRateLimiter.mangaDex() => ProviderRateLimiter(
        provider: 'mangadex',
        maxRequests: 5,
        interval: const Duration(milliseconds: 1000),
      );

  factory ProviderRateLimiter.aniList() => ProviderRateLimiter(
        provider: 'anilist',
        maxRequests: 90,
        interval: const Duration(minutes: 1),
      );

  factory ProviderRateLimiter.comicVine() => ProviderRateLimiter(
        provider: 'comicvine',
        maxRequests: 1,
        interval: const Duration(milliseconds: 1000),
      );

  factory ProviderRateLimiter.tmdb() => ProviderRateLimiter(
        provider: 'tmdb',
        maxRequests: 40,
        interval: const Duration(seconds: 10),
      );

  factory ProviderRateLimiter.hardcover() => ProviderRateLimiter(
        provider: 'hardcover',
        maxRequests: 5,
        interval: const Duration(seconds: 1),
      );

  factory ProviderRateLimiter.bgg() => ProviderRateLimiter(
        provider: 'bgg',
        maxRequests: 1,
        interval: const Duration(seconds: 2),
      );

  factory ProviderRateLimiter.igdb() => ProviderRateLimiter(
        provider: 'igdb',
        maxRequests: 4,
        interval: const Duration(seconds: 1),
      );

  factory ProviderRateLimiter.gcd() => ProviderRateLimiter(
        provider: 'gcd',
        maxRequests: 2,
        interval: const Duration(seconds: 1),
      );

  final String provider;
  final int maxRequests;
  final Duration interval;

  double _tokens;
  late int _lastRefillTime;
  DateTime? _pausedUntil;
  final Queue<_RateLimitRequest> _queue = Queue<_RateLimitRequest>();
  Timer? _drainTimer;

  /// Temporarily halt all requests until [until] (e.g. when 429 Retry-After is encountered).
  void pauseUntil(DateTime until) {
    if (_pausedUntil == null || until.isAfter(_pausedUntil!)) {
      _pausedUntil = until;
      _scheduleDrain();
    }
  }

  /// Acquire permission to send a request, suspending execution if necessary.
  Future<void> acquire() {
    final completer = Completer<void>();
    _queue.add(_RateLimitRequest(completer));
    _processQueue();
    return completer.future;
  }

  void _refillTokens() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = now - _lastRefillTime;
    _lastRefillTime = now;

    if (elapsedMs <= 0) return;

    final refillRatePerMs = maxRequests / interval.inMilliseconds;
    _tokens =
        min(maxRequests.toDouble(), _tokens + (elapsedMs * refillRatePerMs));
  }

  void _processQueue() {
    if (_queue.isEmpty) return;

    final now = DateTime.now();
    if (_pausedUntil != null && now.isBefore(_pausedUntil!)) {
      _scheduleDrain();
      return;
    } else {
      _pausedUntil = null;
    }

    _refillTokens();

    while (_queue.isNotEmpty && _tokens >= 1.0) {
      _tokens -= 1.0;
      final req = _queue.removeFirst();
      if (!req.completer.isCompleted) {
        req.completer.complete();
      }
    }

    if (_queue.isNotEmpty) {
      _scheduleDrain();
    }
  }

  void _scheduleDrain() {
    if (_drainTimer?.isActive ?? false) return;

    Duration delay;
    final now = DateTime.now();
    if (_pausedUntil != null && now.isBefore(_pausedUntil!)) {
      delay = _pausedUntil!.difference(now);
    } else {
      final refillRatePerMs = maxRequests / interval.inMilliseconds;
      final neededTokens = 1.0 - _tokens;
      final waitMs =
          neededTokens > 0 ? (neededTokens / refillRatePerMs).ceil() : 50;
      delay = Duration(milliseconds: max(waitMs, 20));
    }

    _drainTimer = Timer(delay, () {
      _drainTimer = null;
      _processQueue();
    });
  }

  void dispose() {
    _drainTimer?.cancel();
    _drainTimer = null;
    while (_queue.isNotEmpty) {
      final req = _queue.removeFirst();
      if (!req.completer.isCompleted) {
        req.completer.completeError(
          Exception('Rate limiter for $provider was disposed'),
        );
      }
    }
  }
}

class _RateLimitRequest {
  _RateLimitRequest(this.completer);
  final Completer<void> completer;
}

/// Registry and factory for provider rate limiters.
class ProviderRateLimiterRegistry {
  final Map<String, ProviderRateLimiter> _limiters = {};

  ProviderRateLimiter getLimiter(String provider) {
    final key = provider.trim().toLowerCase();
    return _limiters.putIfAbsent(key, () {
      switch (key) {
        case 'openlibrary':
          return ProviderRateLimiter.openLibrary();
        case 'musicbrainz':
          return ProviderRateLimiter.musicBrainz();
        case 'mangadex':
          return ProviderRateLimiter.mangaDex();
        case 'anilist':
          return ProviderRateLimiter.aniList();
        case 'comicvine':
          return ProviderRateLimiter.comicVine();
        case 'tmdb':
          return ProviderRateLimiter.tmdb();
        case 'hardcover':
          return ProviderRateLimiter.hardcover();
        case 'bgg':
          return ProviderRateLimiter.bgg();
        case 'igdb':
          return ProviderRateLimiter.igdb();
        case 'gcd':
          return ProviderRateLimiter.gcd();
        default:
          return ProviderRateLimiter(
            provider: key,
            maxRequests: 2,
            interval: const Duration(seconds: 1),
          );
      }
    });
  }

  void dispose() {
    for (final limiter in _limiters.values) {
      limiter.dispose();
    }
    _limiters.clear();
  }
}
