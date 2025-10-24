import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockService {
  static void enable() {
    WakelockPlus.enable();
  }

  static void disable() {
    WakelockPlus.disable();
  }
}
