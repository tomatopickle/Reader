library globals;

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sanitize_filename/sanitize_filename.dart';
import './pages/ReaderPage.dart';
import 'dart:io' show Platform;
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

String serverUrl = 'https://reader-backend-qo9b.onrender.com';

String? downloadDirectory() {
  switch (Platform.operatingSystem) {
    case 'linux':
    case 'macos':
      return Platform.environment['HOME'];
    case 'windows':
      return '${Platform.environment['USERPROFILE']!}\\.reader';
    case 'android':
      // Probably want internal storage.
      return '/storage/emulated/0/Download/.reader';
    case 'fuchsia':
      // I have no idea.
      return null;
    default:
      return '/';
  }
}

void showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: new Row(
      children: [
        CircularProgressIndicator(),
        SizedBox(
          width: 15,
        ),
        Container(margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

String getFileName(title) {
  return p.join(downloadDirectory() ?? '', sanitizeFilename(title + '.epub'));
}


void openReader(title, context) async{
  VocsyEpub.setConfig(
    themeColor: Theme.of(context).primaryColor,
    identifier: "iosBook",
    scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
    allowSharing: true,
    enableTts: true,
    nightMode: true,
  );
  if (Platform.isWindows) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      print(getFileName(title));
      return ReaderPage(filename: getFileName(title));
    }));
  } else {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String locatorString = prefs.getString('locators/$title') ?? '{}';

    VocsyEpub.open(getFileName(title),lastLocation: EpubLocator.fromJson(jsonDecode((locatorString))));
    VocsyEpub.locatorStream.listen((locator)  {
      prefs.setString('locators/$title', locator);
    });

  }
}
