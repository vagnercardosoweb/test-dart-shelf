import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class App {
  int port;
  String address;
  Router router;
  HttpServer httpServer;

  App({this.address = 'localhost', this.port = 3333}) {
    router = Router();
  }

  void registerController(String prefix, Handler handler) {
    router.mount(prefix, handler);
  }

  FutureOr<void> start() async {
    httpServer = await io.serve(router.call, address, port);
    print('Server running on localhost: ${httpServer.port}');
  }

  FutureOr<void> close() async {
    await httpServer?.close();
  }

  void registerNotFoundRouter() {
    router.all(
        '/<ignored|.*>',
        (Request request) => Response.notFound(json.encode({
              'statusCode': HttpStatus.notFound,
              'message': 'Page not found.'
            })));
  }
}
