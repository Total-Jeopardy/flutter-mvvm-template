// ignore_for_file: unintended_html_in_doc_comment, duplicate_ignore

import 'package:flutter_riverpod/legacy.dart' show StateNotifier;
import 'package:sly_killer_template/core/presentation/ui_state.dart/ui_message.dart';

import '../../result/api_result/result.dart';
import 'async_state.dart';

/// Template standard ViewModel base for Riverpod (StateNotifier).
// ignore: unintended_html_in_doc_comment
/// - Persistent state: AsyncState<T>
/// - One-off events: UiEvent<UiMessage>
abstract class StateNotifierVm<T> extends StateNotifier<AsyncState<T>> {
  StateNotifierVm([AsyncState<T>? initial]) : super(initial ?? const UiIdle());

  UiEvent<UiMessage>? _messageEvent;
  UiEvent<UiMessage>? get messageEvent => _messageEvent;

  // ---- State helpers ----
  void setIdle() => state = const UiIdle();
  void setLoading() => state = const UiLoading();
  void setData(T data) => state = UiData(data);
  void setError(Object error) => state = UiError(error);

  void applyResult(Result<T> result) {
    result.when(
      success: (data) => setData(data),
      failure: (error) => setError(error),
    );
  }

  Future<void> run(Future<Result<T>> Function() work) async {
    setLoading();
    final res = await work();
    applyResult(res);
  }

  // ---- Message helpers ----
  void emitMessage(UiMessage message) {
    _messageEvent = UiEvent(message);
    // Force a notify without mutating persistent state meaningfully.
    // This is safe because Riverpod notifies listeners when `state` is set.
    state = state;
  }

  /// Call this from UI after consuming to avoid reprocessing.
  void clearMessage() {
    _messageEvent = null;
    state = state;
  }
}
