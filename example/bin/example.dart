import 'package:dartuv/uv.dart';

void main() {
  loopExample();
}

loopExample() {
  var loop = Loop();
  loop.init();
  print("Now quitting.");
  loop.run();
  loop.close();
}
