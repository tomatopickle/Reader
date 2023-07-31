import 'dart:io';
import 'dart:typed_data';
import '../globals.dart';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key, required this.filename});
  final String filename;
  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late EpubController _epubController;
  @override
  void initState() {
    super.initState();
    _epubController = EpubController(
      // Load document

      document: EpubDocument.openFile(File(widget.filename)),
      // Set start point
      // epubCfi: 'epubcfi(/6/6[chapter-2]!/4/2/1612)',
    );
  }

  @override
  Widget build(BuildContext context) =>
      ResponsiveBuilder(builder: (context, sizingInformation) {
        return Scaffold(
          appBar: AppBar(
            // Show actual chapter name

            title: EpubViewActualChapter(
                controller: _epubController,
                builder: (chapterValue) => Text(
                      'Chapter: ${chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? ''}',
                      textAlign: TextAlign.start,
                    )),
            actions: [
              if (sizingInformation.isDesktop) ...[
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close_rounded),
                    label: Text('Close'))
              ]
            ],
          ),
          // Show table of contents
          drawer: Drawer(
            child: EpubViewTableOfContents(
              controller: _epubController,
            ),
          ),
          // Show epub document
          body: EpubView(
            shrinkWrap: true,
            controller: _epubController,
          ),
        );
      });
}
