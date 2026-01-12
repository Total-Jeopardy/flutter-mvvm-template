import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sly_killer_template/core/presentation/ui_state.dart/error_to_ui_message.dart';

final errorToUiMessageProvider = Provider<ErrorToUiMessage>((ref) {
  return const ErrorToUiMessage();
});
