// TODO: Put public facing types in this file.

import 'package:dio/dio.dart';
import 'ipfs_service.dart';

/// Checks if you are awesome. Spoiler: you are.
class LocalIpfsClient {
  String? url;
  String? authorizationToken;
  final IpfsService _ipfsService = IpfsService();

  LocalIpfsClient(
      {this.url = 'http://127.0.0.1:5001', this.authorizationToken});

  Future<dynamic> add(
      {required String dir,
      required String filePath,
      String fileName = ""}) async {
    _checkDir(dir);
    var params = {
      'arg': dir,
      'create': true,
    };
    try {
      var response = await _ipfsService.postFile(
          url: '$url/api/v0/add?',
          formData: await _getFormData(filePath, fileName),
          queryParameters: params,
          authorizationToken: authorizationToken);
      return response;
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        return e.response?.data;
      }
    }
  }

  /// Write to a file in a given filesystem.
  /// For more: https://docs.ipfs.io/reference/http/api/#api-v0-files-write
  Future<dynamic> write(
      {required String dir,
      required String filePath,
      String fileName = ""}) async {
    _checkDir(dir);
    var params = {
      'arg': dir,
      'create': true,
    };
    try {
      var response = await _ipfsService.postFile(
          url: '$url/api/v0/files/write?',
          formData: await _getFormData(filePath, fileName),
          queryParameters: params,
          authorizationToken: authorizationToken);
      return response;
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        return e.response?.data;
      }
    }
  }

  /// Read a file in a given MFS.
  /// For more: https://docs.ipfs.io/reference/http/api/#api-v0-files-read
  Future<dynamic> read({required String dir}) async {
    _checkDir(dir);
    var params = {
      'arg': dir,
      'offset': 0,
      'count': 10000000,
    };
    try {
      var response = await _ipfsService.post(
          url: '$url/api/v0/files/read?',
          queryParameters: params,
          authorizationToken: authorizationToken,
          responseType: ResponseType.bytes);
      return response;
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        return e.response?.data;
      }
    }
  }

  /// Remove a file/dir
  /// https://docs.ipfs.io/reference/http/api/#api-v0-files-rm
  /// recursive [bool]: recursively remove directories. Required: no.
  Future<dynamic> remove({required String dir, bool recursive = true}) async {
    _checkDir(dir);
    var params = {
      'arg': dir,
      'recursive': recursive,
    };
    try {
      var response = await _ipfsService.post(
          url: '$url/api/v0/files/rm?',
          queryParameters: params,
          authorizationToken: authorizationToken);
      return response;
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        return e.response?.data;
      }
    }
  }

  /// move a file/mv
  /// https://docs.ipfs.io/reference/http/api/#api-v0-files-mv
  Future<dynamic> mv({required String oldPath, required String newPath}) async {
    _checkDir(oldPath);
    _checkDir(newPath);
    try {
      var response = await _ipfsService.post(
          url: '$url/api/v0/files/mv?arg=$oldPath&arg=$newPath',
          // queryParameters: params,
          authorizationToken: authorizationToken);
      return response;
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        return e.response?.data;
      }
    }
  }

  String _checkDir(String dir) {
    if (!dir.startsWith("/")) return dir = "/$dir";
    return dir;
  }

  Future<FormData> _getFormData(String filePath, String fileName) async {
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });
  }
}
