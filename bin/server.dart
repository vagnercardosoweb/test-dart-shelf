import 'dart:async';

import 'package:restapi/app.dart';
import 'package:restapi/users/user.controller.dart';

FutureOr<void> main(List<String> arguments) async {
  var app = App();
  app.registerController('/users/', UserController().getRouter());
  app.registerNotFoundRouter();

  try {
    await app.start();
  } catch (e) {
    print(e);

    await app.close();
  }
}
