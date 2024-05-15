import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:dartuv/src/bindings/libuv.dart';
import 'package:dartuv/src/handles/handle.dart';

typedef ProcessCallback = Function(Handle process);

/// Represents a process handle in the Dart UV library.
///
/// The `Process` class provides an interface for managing and interacting with
/// a child process. It allows you to start a new process, pass arguments and
/// environment variables, and handle the process lifecycle events.
///
/// To create a new `Process` instance, you need to provide a [loop] object,
/// which represents the event loop. You can also specify additional options
/// such as [args], [env], [cwd], [flags], [uid], and [gid].
///
/// The [callback] parameter allows you to provide a callback function that will
/// be called when the process exits. The [pid] and [status] properties provide
/// access to the process ID and exit status, respectively.
///
/// The `Process` class uses the underlying libuv library to manage the child
/// process. It provides a high-level API for working with processes in a
/// cross-platform manner.
class Process extends Handle {
  List<String> args;
  Map<String, String> env;
  String cwd;
  int flags;
  int uid;
  int gid;

  static final _exitCb = Pointer.fromFunction<uv_exit_cbFunction>(exitCb);

  late Pointer<uv_process_options_t> _processOptionsPtr;

  ProcessCallback? callback;

  String file;

  int get pid => handle.cast<uv_process_t>().ref.pid;

  int get status => handle.cast<uv_process_t>().ref.status;

  Process(
    super.loop, {
    this.args = const <String>[],
    this.env = const <String, String>{},
    this.cwd = '',
    this.flags = 0,
    this.uid = 0,
    this.gid = 0,
    this.file = '',
    this.callback,
  });

  @override
  init() {
    super.init();
    handle = calloc<uv_process_t>();
    _processOptionsPtr = calloc<uv_process_options_t>();

    final cArgs = calloc<Pointer<Char>>(args.length + 1);
    for (var i = 0; i < args.length; i++) {
      cArgs[i] = args[i].toNativeUtf8().cast();
    }
    cArgs[args.length] = nullptr;

    final cEnv = calloc<Pointer<Char>>(args.length + 1);
    var j = 0;
    env.forEach((key, value) {
      cEnv[j] = '$key=$value'.toNativeUtf8().cast();
      j++;
    });

    cEnv[env.length] = nullptr;

    _processOptionsPtr.ref.args = cArgs.cast();
    _processOptionsPtr.ref.env = env.isEmpty ? nullptr : cEnv;
    _processOptionsPtr.ref.flags = flags;
    _processOptionsPtr.ref.uid = uid;
    _processOptionsPtr.ref.gid = gid;
    _processOptionsPtr.ref.file = file.toNativeUtf8().cast<Char>();

    if (callback != null) {
      set('exit', callback!);
    }

    _processOptionsPtr.ref.exit_cb = _exitCb;

    _processOptionsPtr.ref.cwd =
        cwd.isEmpty ? nullptr : cwd.toNativeUtf8().cast<Char>();

    var result = uv_spawn(loop!.inner, handle.cast(), _processOptionsPtr);

    if (result != 0) {
      String error = uv_strerror(result).cast<Utf8>().toDartString();
      String errorName = uv_err_name(result).cast<Utf8>().toDartString();

      throw Exception('uv_spawn error: $result - err $error - name $errorName');
    }

    // calloc.free(cArgs);
    // calloc.free(cEnv);
  }

  static void exitCb(Pointer<uv_process_t> handle, int s, int sig) {
    // print('...exitCb...');
    // addressToHandle(handle.cast())?.call('exit');

    uv_close(handle.cast(), nullptr);
  }
}
