import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:perairan_ngale/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class SaveFileMobile {
  Future<void> download(List<int> bytes, String fileName) async {
    final path = await findLocalPath();

    final isDirExist = Directory(path).existsSync();

    if (!isDirExist) {
      await Directory(path).create();
    }

    final fileLocation = '$path/$fileName';
    final file = File(fileLocation);
    await file.writeAsBytes(bytes, flush: true);
    logger.d('File saved at ${file.path}');

    await OpenFile.open(file.path);
  }

  Future<String> findLocalPath() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final platform = getPlatform();
      if (platform == TargetPlatform.android) {
        return '/storage/emulated/0/Download/ngale';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        return '${'${directory.path}${Platform.pathSeparator}Download${Platform.pathSeparator}'}racquet';
      }
    }
    throw 'Permission denied';
  }

  TargetPlatform getPlatform() {
    if (Platform.isAndroid) {
      return TargetPlatform.android;
    } else {
      return TargetPlatform.iOS;
    }
  }
}
