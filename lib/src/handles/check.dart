import 'dart:ffi';
import 'package:dartuv/src/bindings/libuv.dart';
import 'package:dartuv/src/handles/handle.dart';
import 'package:ffi/ffi.dart';

class Check extends Handle {
  Check([super.loop]);

  @override
  void init() {
    super.init();
    handle = calloc<uv_check_t>();
    uv_check_init(loop!.inner, handle.cast());
  }

  /// Starts the check handle and optionally sets a callback function to be called when the check handle is ready.
  ///
  /// If a [callback] is provided, it will be called when the check handle is ready. Otherwise, the default [_idleCallback] function will be used.
  ///
  /// The [start] method should be called to activate the check handle and begin checking for events.
  void start([HandleCallback? callback]) {
    if (callback != null) {
      set('start', callback);
    }
    uv_check_cb callbackPtr =
        Pointer.fromFunction<uv_check_cbFunction>(_idleCallback);
    uv_check_start(handle.cast(), callback == null ? nullptr : callbackPtr);
  }

  static void _idleCallback(Pointer<uv_check_s> handle) {
    addressToHandle(handle)?.call('start');
  }

  /// Stops the check handle.
  ///
  /// This method stops the check handle, preventing the [_idleCallback] from being called.
  void stop() {
    uv_idle_stop(handle.cast());
  }
}
