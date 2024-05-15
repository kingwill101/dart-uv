import 'dart:ffi';
import 'package:dartuv/src/bindings/libuv.dart';
import 'package:dartuv/src/handles/handle.dart';
import 'package:ffi/ffi.dart';

class Idle extends Handle {
  Idle([super.loop]);

  @override
  void init() {
    super.init();
    handle = calloc<uv_idle_t>();
    uv_idle_init(loop!.inner, handle.cast());
  }

  /// Starts the idle handle and optionally sets a callback function to be called when the handle is active.
  ///
  /// If a [callback] is provided, it will be called when the idle handle is active. The callback function should have the signature `void Function()`.
  /// If no [callback] is provided, the idle handle will still be started, but no function will be called when it is active.
  ///
  /// This method will also set the "start" property of the handle to the provided [callback], if it is not null.
  void start([HandleCallback? callback]) {
    if (callback != null) {
      set('start', callback);
      set("start", callback);
    }
    uv_idle_cb callbackPtr =
        Pointer.fromFunction<uv_idle_cbFunction>(_idleCallback);

    uv_idle_start(handle.cast(), callback == null ? nullptr : callbackPtr);
  }

  static void _idleCallback(Pointer<uv_idle_s> handle) {
    addressToHandle(handle)?.call('start');
  }

  /// Stops the idle handle.
  ///
  /// This method will stop the idle handle, preventing the associated callback from being called.
  void stop() {
    uv_idle_stop(handle.cast());
  }
}
