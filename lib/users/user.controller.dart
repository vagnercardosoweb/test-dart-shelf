import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserController {
  File usersFile = File('lib/users/data.json');
  List usersData;

  UserController() {
    usersData = json.decode(usersFile.readAsStringSync());
  }

  Response responseToJson(body) {
    return Response.ok(json.encode(body),
        headers: {'Content-Type': 'application/json'});
  }

  void saveNewUsersInFile(users) {
    usersFile.writeAsStringSync(json.encode(users));
  }

  Response all(Request request) {
    return responseToJson(usersData);
  }

  Response findById(Request request, String id) {
    final parsedId = int.tryParse(id);
    var user = usersData.firstWhere((element) => element['id'] == parsedId,
        orElse: () => null);

    if (user == null) {
      return Response.notFound('Usuário não encontrado.');
    }

    return responseToJson(user);
  }

  Future<Response> add(Request request) async {
    final payload = json.decode(await request.readAsString());
    payload['id'] = DateTime.now().microsecondsSinceEpoch;
    usersData.add(payload);

    saveNewUsersInFile(usersData);

    return responseToJson(usersData);
  }

  Response remove(Request request, String id) {
    final parsedId = int.tryParse(id);
    usersData.removeWhere((row) => row['id'] == parsedId);

    saveNewUsersInFile(usersData);

    return responseToJson(usersData);
  }

  Future<Response> update(Request request, String id) async {
    final parsedId = int.tryParse(id);
    var userIndex = usersData.indexWhere((row) => row['id'] == parsedId);

    if (userIndex == -1) {
      return Response.notFound('Usuário não encontrado.');
    }

    var payload = json.decode(await request.readAsString());
    usersData[userIndex] = {}..addAll(usersData[userIndex])..addAll(payload);

    saveNewUsersInFile(usersData);

    return responseToJson(usersData[userIndex]);
  }

  Router getRouter() {
    var router = Router();

    router.get('/', all);
    router.post('/', add);
    router.get('/<id|[0-9]+>', findById);
    router.put('/<id|[0-9]+>', update);
    router.delete('/<id|[0-9]+>', remove);

    return router;
  }
}
