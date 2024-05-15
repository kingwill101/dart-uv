import 'dart:ffi';

import 'package:dartuv/src/options.dart';
import 'package:ffi/ffi.dart';
import 'package:dartuv/src/bindings/libuv.dart';

class Loop {
  Pointer<uv_loop_t> _loop = nullptr;

  Pointer<uv_loop_t> get inner => _loop;
  bool _initialized = false;

  bool isDefault;

  bool get initialized => _initialized;

  Loop([this.isDefault = true]);

  /// Initializes the event loop.
  ///
  /// If [isDefault] is `false`, a new event loop is allocated using [calloc] and
  /// initialized with [uv_loop_init]. Otherwise, the default event loop is used.
  /// The [_initialized] flag is set to `true` to indicate that the event loop has
  /// been initialized.
  void init() {
    if (!isDefault) {
      _loop = calloc<uv_loop_t>();
      uv_loop_init(_loop);
    } else {
      _loop = uv_default_loop();
    }
    _initialized = true;
  }

  /// Runs the event loop.
  ///
  /// This function will block until the event loop is stopped. The [mode] parameter
  /// can be used to control how the event loop behaves. The default mode is
  /// [UV_RUN_DEFAULT], which will run the event loop until there are no more active
  /// and referenced handles in the loop. Other modes include [UV_RUN_ONCE], which
  /// will process events that are ready to be processed, and [UV_RUN_NOWAIT], which
  /// will process any events that are ready, but will not block if there are no
  /// ready events.
  void run([int mode = RunMode.UV_RUN_DEFAULT]) {
    uv_run(_loop, mode);
  }

  /// Closes the event loop.
  ///
  /// If the event loop was initialized with [isDefault] set to `false`, the memory
  /// allocated for the loop is freed using [calloc.free]. The [_loop] and
  /// [_initialized] fields are reset to their initial values.
  void close() {
    uv_loop_close(_loop);

    if (!isDefault) {
      calloc.free(_loop);
    }

    _loop = nullptr;
    _initialized = false;
  }
}
