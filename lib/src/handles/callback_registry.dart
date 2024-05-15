import 'package:dartuv/src/handles/handle.dart';

class CallbackRegistry {
  final Map<String, Map<String, HandleCallback>> _callbacks = {};

  void register(String id, String name, HandleCallback callback) {
    final handleCallbacks = _callbacks.putIfAbsent(id, () => {});
    handleCallbacks[name] = callback;
  }

  HandleCallback? get(String id, String name) {
    return _callbacks[id]?[name];
  }
}
