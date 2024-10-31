import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/variables.dart';
import '../models/request/user_request_model.dart';
import '../models/response/auth_response_model.dart';
import 'auth_local_datasource.dart';

class UserRemoteDatasource {
  Future<Either<String, User>> getUser() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url =
        Uri.parse('${Variables.baseUrl}/api/api-user/${authData!.user!.id!}');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      },
    );
    if (response.statusCode == 200) {
      return right(User.fromMap(jsonDecode(response.body)['data']));
    } else {
      return left(response.body);
    }
  }

  Future<Either<String, User>> updateProfile(
      UserRequestModel model, int id) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${authData!.token}',
      'Content-Type': 'multipart/form-data',
      'Accept': 'multipart/form-data'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${Variables.baseUrl}/api/api-user/edit'));
    request.fields.addAll(model.toMap());
    if (model.image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', model.image!.path));
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    final String body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return right(User.fromMap(jsonDecode(body)['data']));
    } else {
      return left(body);
    }
  }
}
