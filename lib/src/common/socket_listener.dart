import 'package:gmpay/src/common/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIOService {
  late IO.Socket socket;

  void onClose() {
    socket.close();
    socket.dispose();
  }

  Future<SocketIOService> init() async {
    try {
      socket = IO.io(AppConstants.base,
          IO.OptionBuilder().setTransports(['websocket']).build());
    } catch (_) {}
    return this;
  }
}
