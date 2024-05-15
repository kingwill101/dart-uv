import 'dart:ffi';

import 'package:dartuv/src/bindings/libuv.dart';
import 'package:dartuv/src/loop.dart';

typedef HandleCallback = void Function(Handle);

/// Stops the event loop.
///
/// If a [Loop] instance is provided, it will be used to stop the event loop.
/// Otherwise, a new [Loop] instance will be created and used to stop the event loop.
///
/// This function is used to stop the event loop, which is typically used to
/// handle asynchronous I/O operations. Calling this function will cause the
/// event loop to exit, allowing the program to terminate.
void uvStop([Loop? loop]) {
  loop ??= Loop();
  uv_stop(loop.inner);
}

/// Represents a handle, which is a reference to an object in the underlying
/// event loop. Handles can be associated with callbacks that are called when
/// certain events occur on the handle.
///
/// Handles are registered in a global registry, which allows them to be looked
/// up by their unique identifier (ObjectId). The handle's pointer address is
/// also mapped to the ObjectId, allowing handles to be looked up by their
/// pointer address.
///
/// Handles are responsible for initializing the event loop they are associated
/// with, and provide methods for checking the active and closing state of the
/// handle.
abstract class Handle {
  Loop? loop;
  Pointer handle = nullptr;


  Handle([this.loop]) {
    init();
  }

  /// Initializes the handle's associated event loop if it has not already been initialized.
  ///
  /// This method ensures that the handle's associated event loop is initialized before any other operations are performed on the handle. It checks if the loop is null, and if so, creates a new Loop instance. It then checks if the loop has been initialized, and if not, calls the init() method on the loop to initialize it.
  void init() {
    loop ??= Loop();
    if (!loop!.initialized) {
      loop!.init();
    }
  }

  /// Returns whether the handle is active.
  ///
  /// The handle is considered active if it is executing a callback or if it is waiting for a resource (e.g. a TCP connection).
  ///
  /// This method calls `uv_is_active` with the handle to determine if it is active.
  /// Returns whether the handle is currently active.
  ///
  /// This method calls `uv_is_active` with the handle to determine if it is currently active.
  bool active() {
    var result = uv_is_active(handle.cast());
    return result == 1;
  }

  /// Returns whether the handle is currently closing.
  ///
  /// This method calls `uv_is_closing` with the handle to determine if it is currently in the process of closing.
  bool closing() {
    var result = uv_is_closing(handle.cast());
    return result == 1;
  }

  /// Closes the handle.
  ///
  /// If a [callback] is provided, it will be called when the handle is closed. Otherwise, the handle will be closed synchronously.
  ///
  /// Calling this method multiple times has no effect - the handle will only be closed once.
  void close([HandleCallback? callback]) {
    if (closing()) return;
    NativeCallable<uv_close_cbFunction>? callbackPtr =
        NativeCallable.isolateLocal((Pointer<uv_handle_t> handle) {
      callback != null ? callback(this) : null;
    });
    uv_close(handle.cast(), callbackPtr.nativeFunction);
  }

  /// Increments the reference count for the handle.
  ///
  /// This method calls `uv_ref` with the handle to increment its reference count.
  /// Increasing the reference count prevents the event loop from exiting if there
  /// are no other active references.
  ref() {
    uv_ref(handle.cast());
  }

  /// Decrements the reference count for the handle.
  ///
  /// This method calls `uv_unref` with the handle to decrement its reference count.
  /// Decreasing the reference count allows the event loop to exit if there are no
  /// other active references.
  unref() {
    uv_unref(handle.cast());
  }

  /// Returns whether the handle has an active reference.
  ///
  /// This method calls `uv_has_ref` with the handle to determine if it has an active reference.
  bool hasRef() {
    return uv_has_ref(handle.cast()) != 0;
  }

  /// Returns the size of the UV handle.
  ///
  /// This method calls `uv_handle_size` with the type of the handle to get its size.
  size() {
    uv_handle_size(_type());
  }

  _type() {
    return handle.cast<uv_handle_t>().ref.type;
  }
}
