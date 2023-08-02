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
import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

String serverUrl = 'https://reader-backend-qo9b.onrender.com';
// String serverUrl = 'http://localhost:8000';

String? downloadDirectory() {
  switch (Platform.operatingSystem) {
    case 'linux':
    case 'macos':
      return Platform.environment['HOME'];
    case 'windows':
      return '${Platform.environment['USERPROFILE']!}\\.reader';
    case 'android':
      // Probably want internal storage.
      return '/storage/emulated/0/Download/reader';
    case 'fuchsia':
      // I have no idea.
      return null;
    default:
      return '/';
  }
}

void showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(
          width: 15,
        ),
        Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text("Loading...")),
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

void openReader(title, context, bookInfo) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('settings/openWithSystemViewer') ?? false) {
    if (Platform.isAndroid) {
      String path = getFileName(title);

      final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull(path),
          type: "application/epub+zip");
      intent.launch();
      return;
    }
    launchUrl(Uri.parse('file:///' + getFileName(title)));
    return;
  }
  List<String> RecentReads = prefs.getStringList('recentReads') ?? [];
  RecentReads.removeWhere((e) => (jsonDecode(e)['title'] == title));
  RecentReads.insert(0, jsonEncode(bookInfo));
  prefs.setStringList('recentReads', RecentReads);
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
    String locatorString = prefs.getString('locators/$title') ?? '{}';

    VocsyEpub.open(getFileName(title),
        lastLocation: EpubLocator.fromJson(jsonDecode((locatorString))));
    VocsyEpub.locatorStream.listen((locator) {
      prefs.setString('locators/$title', locator);
    });
  }
}
