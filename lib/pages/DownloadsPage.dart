import 'dart:convert';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../globals.dart' as globals;
import '../downloadManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

var dl = DownloadManager();

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  List downloads = [];
  List previouslyDownloaded = [];
  @override
  void initState() {
    print(dl.getAllDownloads());
    getAllDownloads().forEach((element) {
      DownloadTask? downloadTask = dl.getDownload(element['downloadLink']);
      Map download = {
        'progress': downloadTask?.progress.value,
        'status': downloadTask?.status.value ?? DownloadStatus.queued,
        'info': element
      };
      downloads.add(download);
      setState(() {});
      downloadTask?.progress.addListener(() {
        print("UPDATE");
        var i = 0;
        for (var el in downloads) {
          if (el['info']['title'] == element['title']) {
            setState(() {
              downloads[i]['progress'] = downloadTask.progress.value;
            });
          }
          i++;
        }
      });
      downloadTask?.status.addListener(() {
        print("UPDATE");
        var i = 0;
        for (var el in downloads) {
          if (el['info']['title'] == element['title']) {
            setState(() {
              downloads[i]['status'] = downloadTask.status.value;
            });
          }
          i++;
        }
      });
    });
    super.initState();
    loadPreviouslyDownloaded();
  }

  void loadPreviouslyDownloaded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List data = prefs.getStringList('downloadedBooks') ?? [];
    int i = 0;
    previouslyDownloaded = [];
    data.forEach((el) {
      print(el.runtimeType);

      previouslyDownloaded.add(jsonDecode(el));
      i++;
    });
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Downloads'),
        ),
        body: ResponsiveBuilder(builder: (context, sizingInformation) {
          return Padding(
            padding: EdgeInsets.all(sizingInformation.isDesktop ? 50.0 : 5),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var download in downloads)
                    ListTile(
                        leading: Image.network(download['info']['cover']),
                        title: Text(download['info']['title']),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Text(download['status']
                                .toString()
                                .replaceAll('DownloadStatus.', '')
                                .capitalize),
                            const SizedBox(
                              height: 15,
                            ),
                            LinearProgressIndicator(
                                value: download['progress']),
                          ],
                        )),
                  const SizedBox(
                    height: 45,
                  ),
                  if (previouslyDownloaded.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Previously Downloaded',
                        style: sizingInformation.isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.start,
                      ),
                    )
                  ],
                  const SizedBox(
                    height: 30,
                  ),
                  for (var download in previouslyDownloaded)
                    Column(
                      children: [
                        ListTile(
                          leading: Image.network(download['cover']),
                          title: Text(download['title']),
                          trailing: ElevatedButton(
                              onPressed: () {
                                globals.openReader(download['title'], context,download);
                              },
                              child: const Text('Open')),
                        ),
                        const SizedBox(
                          height: 15,
                        )
                      ],
                    )
                ],
              ),
            ),
          );
        }));
  }
}
