import 'package:dartuv/src/handles/check.dart';
import 'package:dartuv/src/handles/idle.dart';
import 'package:dartuv/src/handles/prepare.dart';
import 'package:dartuv/src/handles/timer.dart';
import 'package:test/test.dart';
import 'package:dartuv/src/bindings/libuv.dart';
import 'package:dartuv/src/handles/handle.dart';
import 'package:dartuv/src/handles/process.dart';
import 'package:dartuv/uv.dart';

void main() {

  group('handlers', () {
    test('uv_loop', () {
      var loop = Loop();
      loop.init();
      loop.run();
      loop.close();
    });

    test('time', () {
      var loop = Loop();
      var time = Timer(loop);
      String now = DateTime.now().toUtc().toIso8601String();
      print('time: $now');
      time.start((h) {
        var _now = DateTime.now().toUtc().toIso8601String();
        print("callback at $_now");
        h.close();
      }, 5, 3);

      loop.run();
      loop.close();
    });

    test('uv_idle', () {
      var loop = Loop();
      Idle idle = Idle(loop);
      int counter = 0;
      idle.start((h) {
        while (counter < 10) {
          counter++;
        }
        assert(idle.active());
        idle.stop();
      });
      loop.run();
      loop.close();

      expect(counter, equals(10));
    });

    test('uv_check', () {
      var loop = Loop();
      int check_called = 0;
      int timer_called = 0;

      Check check = Check(loop);
      check.start((h) {
        check_called++;
        check.stop();
        check.close();
        h.close();
      });

      Timer timer = Timer(loop);
      timer.start((h) {
        timer_called++;
        timer.stop();
        h.close();
      }, 1, 0);

      loop.run();
      loop.close();

      expect(check_called, equals(1));
      expect(timer_called, equals(1));
    });

    test('uv_prepare', () {
      var loop = Loop();
      int check_called = 0;
      int timer_called = 0;

      Prepare prepare = Prepare(loop);
      prepare.start((h) {
        check_called++;
        prepare.stop();
        prepare.close();
        h.close();
      });

      Timer timer = Timer(loop);
      timer.start((h) {
        timer_called++;
        timer.stop();
        h.close();
      }, 1, 0);

      loop.run();
      loop.close();

      expect(check_called, equals(1));
      expect(timer_called, equals(1));
    });
  });
}
