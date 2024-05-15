import 'package:test/test.dart';
import 'package:dartuv/src/bindings/libuv.dart';
import 'package:dartuv/src/handles/handle.dart';
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
        var now0 = DateTime.now().toUtc().toIso8601String();
        print("callback at $now0");
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
      int checkCalled = 0;
      int timerCalled = 0;

      Check check = Check(loop);
      check.start((h) {
        checkCalled++;
        check.stop();
        check.close();
        h.close();
      });

      Timer timer = Timer(loop);
      timer.start((h) {
        timerCalled++;
        timer.stop();
        h.close();
      }, 1, 0);

      loop.run();
      loop.close();

      expect(checkCalled, equals(1));
      expect(timerCalled, equals(1));
    });

    test('uv_prepare', () {
      var loop = Loop();
      int checkCalled = 0;
      int timerCalled = 0;

      Prepare prepare = Prepare(loop);
      prepare.start((h) {
        checkCalled++;
        prepare.stop();
        prepare.close();
        h.close();
      });

      Timer timer = Timer(loop);
      timer.start((h) {
        timerCalled++;
        timer.stop();
        h.close();
      }, 1, 0);

      loop.run();
      loop.close();

      expect(checkCalled, equals(1));
      expect(timerCalled, equals(1));
    });
    test('uv_process', () {
      var loop = Loop();

      callback(Handle process) {
        print("callback called");
        process.close();
      }

      final process = Process(
        loop,
        file: 'id',
        args: ['id'],
        callback: callback,
        flags: uv_process_flags.UV_PROCESS_DETACHED,
      );

      assert(process.pid > 0);
      // process.close();

      loop.run();
      print("something");
    });
  });
}
