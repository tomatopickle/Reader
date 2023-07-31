library download_manager;

import 'dart:convert';

import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'globals.dart' as globals;
import 'package:path/path.dart' as p;
import 'package:sanitize_filename/sanitize_filename.dart';
import 'package:shared_preferences/shared_preferences.dart';

var dl = DownloadManager();

List currentTasks = [];
var e = '';
void createDownloadTask(url, bookInfo) {
  currentTasks.add(bookInfo);
  dl
      .addDownload(
          url,
          p.join(globals.downloadDirectory() ?? '',
              sanitizeFilename(bookInfo['title'] + '.epub')))
      .then((value) {
    value?.status.addListener(() async {
      if (value.status.value == DownloadStatus.completed) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final List<String> downloadedBooks =
            prefs.getStringList('downloadedBooks') ?? [];
        downloadedBooks.insert(0, jsonEncode(bookInfo));
        await prefs.setStringList('downloadedBooks', downloadedBooks);
      }
    });
  });
}

List getAllDownloads() {
  return currentTasks;
}

double getTaskProgress(url) {
  DownloadTask? task = dl.getDownload(url);
  return task?.progress.value ?? 0;
}
