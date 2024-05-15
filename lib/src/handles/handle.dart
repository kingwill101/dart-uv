import 'dart:ffi';

import 'package:dartuv/src/handles/callback_registry.dart';
import 'package:objectid/objectid.dart';
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

/// Looks up a [Handle] instance by its associated [Pointer] address.
///
/// This method retrieves the [Handle] instance that is associated with the
/// provided [Pointer] address. If a [Handle] instance is found, it is returned.
/// Otherwise, `null` is returned.
///
/// This method is used to look up a [Handle] instance based on its underlying
/// [Pointer] representation, which is useful when working with low-level
/// system APIs that deal with pointers.
Handle? addressToHandle(Pointer handle) {
  final objectId = Handle._pointerToIdMap[handle.address];
  return objectId != null ? Handle._handleRegistry[objectId] : null;
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
  final ObjectId id = ObjectId();
  Loop? loop;
  Pointer handle = nullptr;

  static final CallbackRegistry _callbackRegistry = CallbackRegistry();
  static final Map<String, Handle> _handleRegistry =
      {}; // Map of ObjectId to Handle
  static final Map<int, String> _pointerToIdMap =
      {}; // Map of Pointer address to ObjectId

  Map<int, String> get pointerMap => _pointerToIdMap;

  Handle([this.loop]) {
    init();
    _handleRegistry[id.hexString] = this; // Register this handle
    _pointerToIdMap[handle.address] =
        id.hexString; // Map the Pointer address to ObjectId
  }

  /// Registers a callback for the specified name.
  ///
  /// This method adds the provided callback to the internal callback registry,
  /// associating it with the given name. This allows the callback to be
  /// retrieved and executed later by calling the [call] method with the
  /// same name.
  void set(String name, HandleCallback callback) {
    _callbackRegistry.register(id.hexString, name, callback);
  }

  /// Calls the callback associated with the specified name.
  ///
  /// This method retrieves the callback registered for the given name and calls it with the current instance as the argument.
  void call(String name) {
    final callback = _callbackRegistry.get(id.hexString, name);
    callback?.call(this);
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

    if (callback == null) {
      uv_close(handle.cast(), nullptr);
    } else {
      set('close', callback);
      uv_close_cb callbackPtr =
          Pointer.fromFunction<uv_close_cbFunction>(_closeCallback);
      uv_close(handle.cast(), callbackPtr);
    }
  }

  static void _closeCallback(Pointer<uv_handle_t> handle) {
    addressToHandle(handle)?.call('close');
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
