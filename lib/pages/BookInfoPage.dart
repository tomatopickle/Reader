import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:reader/pages/DownloadsPage.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../globals.dart' as globals;
import '../downloadManager.dart';
import 'dart:io';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({super.key, required this.bookInfo});
  final Map bookInfo;
  @override
  State<BookInfoPage> createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  bool downloading = false;
  bool downloaded = false;
  @override
  void initState() {
    getAllDownloads().forEach((element) {
      if (element['title'] == widget.bookInfo['title']) {
        setState(() {
          downloading = true;
        });
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    downloaded =
        File(globals.getFileName(widget.bookInfo['title'])).existsSync();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reader'),
        ),
        body: ResponsiveBuilder(builder: (context, sizingInformation) {
          return Padding(
            padding: EdgeInsets.all(sizingInformation.isDesktop ? 50.0 : 10),
            child: SingleChildScrollView(
                physics: sizingInformation.isDesktop
                    ? const NeverScrollableScrollPhysics()
                    : const ScrollPhysics(),
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: sizingInformation.screenSize.height,
                        minWidth: sizingInformation.screenSize.width),
                    child: IntrinsicHeight(
                        child: Flex(
                      direction: sizingInformation.isDesktop
                          ? Axis.horizontal
                          : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Column(
                              mainAxisSize: sizingInformation.isDesktop
                                  ? MainAxisSize.max
                                  : MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      widget.bookInfo['cover'],
                                      width: sizingInformation.isDesktop
                                          ? 250
                                          : 150,
                                    )),
                                const SizedBox(
                                  height: 30,
                                ),
                                if (!downloading && !downloaded) ...[
                                  Container(
                                      width: 250,
                                      child: FloatingActionButton.extended(
                                        onPressed: () {
                                          print(
                                              widget.bookInfo['downloadLink']);
                                          print(globals.downloadDirectory());
                                          createDownloadTask(
                                              widget.bookInfo['downloadLink'],
                                              widget.bookInfo);

                                          setState(() {
                                            downloading = true;
                                          });
                                          globals.showLoaderDialog(context);
                                          Timer(Duration(seconds: 5), () {
                                            Navigator.pop(context);
                                            var dl = DownloadManager();
                                            DownloadTask? downloadTask =
                                                dl.getDownload(widget
                                                    .bookInfo['downloadLink']);
                                            downloadTask?.status
                                                .addListener(() {
                                              if (downloadTask.status.value ==
                                                  DownloadStatus.completed) {
                                                setState(() {
                                                  downloading = false;
                                                  downloaded = true;
                                                });
                                              }
                                            });
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return DownloadsPage();
                                            })).then((value) {
                                              setState(() {});
                                            });
                                          });
                                        },
                                        icon: Icon(Icons.download_rounded),
                                        label: Text('Download'),
                                      )),
                                ] else if (downloading && !downloaded) ...[
                                  Container(
                                      width: 250,
                                      child: FloatingActionButton.extended(
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return DownloadsPage();
                                          })).then((value) {
                                            setState(() {});
                                          });
                                        },
                                        icon: Transform.scale(
                                            scale: 0.75,
                                            child: CircularProgressIndicator()),
                                        label: const Text('Downloading'),
                                      ))
                                ] else ...[
                                  Container(
                                      width: 250,
                                      child: FloatingActionButton.extended(
                                        onPressed: () {
                                          globals.openReader(
                                              widget.bookInfo['title'],
                                              context,widget.bookInfo);
                                        },
                                        icon: Icon(Icons.book),
                                        label: const Text('Read'),
                                      )),
                                ]
                              ]),
                        ),
                        SizedBox(
                          width: sizingInformation.isDesktop ? 30 : 0,
                          height: sizingInformation.isDesktop ? 0 : 30,
                        ),
                        Flexible(
                          flex: 8,
                          child: SingleChildScrollView(
                              physics: sizingInformation.isDesktop
                                  ? const ScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SelectableText(
                                    widget.bookInfo['title'],
                                    style: sizingInformation.isDesktop
                                        ? Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)
                                        : Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Opacity(
                                    opacity: .8,
                                    child: SelectableText(
                                      widget.bookInfo['publisher'],
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SelectableText(widget.bookInfo['authors'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Opacity(
                                    opacity: .95,
                                    child: SelectableText(
                                      widget.bookInfo['description'],
                                    ),
                                  ),
                                ],
                              )),
                        )
                      ],
                    )))),
          );
        }));
  }
}
