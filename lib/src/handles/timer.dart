import 'dart:ffi';
import 'package:dartuv/src/bindings/libuv.dart';
import 'package:dartuv/src/handles/handle.dart';
import 'package:ffi/ffi.dart';

class Timer extends Handle {
  Timer([super.loop]);

  @override
  void init() {
    super.init();
    handle = calloc<uv_timer_t>();
    uv_timer_init(loop!.inner, handle.cast());
  }

  /// Starts the timer with an optional callback, timeout, and repeat interval.
  ///
  /// If a [callback] is provided, it will be called when the timer fires. The
  /// [timeout] parameter specifies the initial delay in milliseconds before the
  /// timer fires. The [repeat] parameter specifies the repeat interval in
  /// milliseconds.
  ///
  /// If no [callback] is provided, the timer will simply fire after the specified
  /// [timeout] and repeat at the specified [repeat] interval.
  void start([HandleCallback? callback, int timeout = 0, int repeat = 0]) {
    if (callback != null) {
      set('start', callback);
    }
    uv_timer_cb callbackPtr =
        Pointer.fromFunction<uv_timer_cbFunction>(_idleCallback);
    uv_timer_start(handle.cast(), callback == null ? nullptr : callbackPtr,
        timeout * 1000, repeat * 1000);
  }

  static void _idleCallback(Pointer<uv_timer_s> handle) {
    addressToHandle(handle)?.call('start');
  }

  /// Calls [uv_timer_again] on the underlying timer handle.
  ///
  /// This will restart the timer if it was previously stopped.
  void again() {
    uv_timer_again(handle.cast());
  }

  /// Stops the timer.
  ///
  /// This will cancel the timer and prevent it from firing again.
  void stop() {
    uv_timer_stop(handle.cast());
  }
}
