import 'dart:ffi';

import 'package:dartuv/src/bindings/libuv.dart';
import 'package:dartuv/src/handles/handle.dart';
import 'package:ffi/ffi.dart';

/// Represents a prepare handle, which is used to execute a callback before the event loop waits for new events.
///
/// The `Prepare` class extends the `Handle` class and provides methods to initialize, start, and stop the prepare handle.
///
class Prepare extends Handle {
  Prepare([super.loop]);

  @override
  void init() {
    super.init();
    handle = calloc<uv_prepare_t>();
    uv_prepare_init(loop!.inner, handle.cast());
  }

  /// Starts the prepare handle and optionally sets a callback function to be called when the handle is ready.
  ///
  /// If a [callback] is provided, it will be called when the prepare handle is ready. The callback function should have the signature `void Function()`.
  /// If no [callback] is provided, the prepare handle will start without any additional callback.
  /// The prepare handle is used to schedule a callback to be executed on the next event loop iteration.
  void start([HandleCallback? callback]) {
    NativeCallable<uv_prepare_cbFunction>? callbackPtr =
        NativeCallable.isolateLocal((Pointer<uv_prepare_s> handle) {
      callback != null ? callback(this) : null;
    });

    uv_prepare_start(
        handle.cast(), callback == null ? nullptr : callbackPtr.nativeFunction);
  }

  /// Stops the prepare handle.
  ///
  /// This method stops the prepare handle, preventing the associated callback from being called.
  void stop() {
    uv_prepare_stop(handle.cast());
  }
}
