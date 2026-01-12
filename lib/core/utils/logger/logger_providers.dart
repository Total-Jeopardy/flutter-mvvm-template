import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sly_killer_template/core/utils/logger/app_logger.dart';

final loggerProvider = Provider<Logger>((ref) {
  return const ConsoleLogger();
});
