import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/logger/logger_providers.dart';

typedef AppBuilder = Widget Function();

Future<ProviderContainer> bootstrap({required AppBuilder appBuilder}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final logger = container.read(loggerProvider);

  // Flutter framework errors (sync UI errors)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details); // keep default behavior in debug
    logger.e(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Any uncaught async errors (Dart zone)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    logger.e('Uncaught async error', error: error, stackTrace: stack);
    return true; // handled
  };

  // Wrap runApp in a guarded zone so stray errors are captured too.
  runZonedGuarded(
    () => runApp(
      UncontrolledProviderScope(container: container, child: appBuilder()),
    ),
    (error, stack) => logger.e('Zoned error', error: error, stackTrace: stack),
  );

  return container;
}
