import 'dart:convert';
import 'package:reader/pages/DownloadsPage.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './SettingsPage.dart';
import './BookInfoPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List books = [];
  bool searching = false;
  List<Map> recentReads = [];
  @override
  void initState() {
    loadRecentReads();
    print('Init state called');
    loadDiscoverBooks();
    super.initState();
  }

  void loadRecentReads() {
    SharedPreferences.getInstance().then((value) {
      recentReads = [];
      List<String> data = value.getStringList('recentReads') ?? [];
      data.forEach((element) {
        recentReads.add(jsonDecode(element));
      });
      setState(() {});
    });
  }

  void loadDiscoverBooks() {
    http.get(Uri.parse('${globals.serverUrl}/trending')).then((value) {
      print('done');
      print(jsonDecode(value.body)[0]);
      setState(() {
        books = jsonDecode(value.body);
        searching = false;
      });
    });
  }

  void searchBooks(q, context) {
    globals.showLoaderDialog(context);
    http.get(Uri.parse('${globals.serverUrl}/search?q=$q libgen')).then((value) {
      print('done');
      setState(() {
        books = jsonDecode(value.body);
        searching = true;
      });
      Navigator.pop(context);
    });
  }

  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Reader'),
          actions: [
            if (sizingInformation.isDesktop) ...[
              FilledButton.icon(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return DownloadsPage();
                    }));
                  },
                  icon: Icon(Icons.download_rounded),
                  label: Text('Downloads')),
            ] else ...[
              IconButton(
                  color: Theme.of(context)
                      .elevatedButtonTheme
                      .style!
                      .foregroundColor!
                      .resolve({MaterialState.hovered}),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return DownloadsPage();
                    }));
                  },
                  icon: Icon(Icons.download_rounded)),
            ],
            const SizedBox(
              width: 15,
            ),
            if (sizingInformation.isDesktop) ...[
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SettingsPage();
                    }));
                  },
                  label: Text('Settings'),
                  icon: Icon(Icons.settings_rounded))
            ] else ...[
              IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SettingsPage();
                    }));
                  },
                  icon: Icon(Icons.settings))
            ]
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              Center(
                child: FractionallySizedBox(
                  widthFactor: sizingInformation.isDesktop ? .50 : 0.9,
                  child: TextField(
                    onSubmitted: (q) {
                      searchBooks(q, context);
                    },
                    decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Search Books',
                        prefixIcon: Icon(Icons.search_rounded)),
                  ),
                ),
              ),
              if (!searching && recentReads.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text('Recent',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(
                        height: 15,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var book in recentReads)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Tooltip(
                                    message: book['title'],
                                    verticalOffset: 125,
                                    waitDuration: const Duration(seconds: 1),
                                    child: Card(
                                      elevation: 0,
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          globals.openReader(
                                              book['title'], context, book);
                                        },
                                        child: SizedBox(
                                          width: 150,
                                          child: Column(
                                            children: [
                                              Image.network(
                                                  '${globals.serverUrl}/cors?url=${book['cover']}',
                                                  height: 200,
                                                  width: 150,
                                                  fit: BoxFit.fitWidth),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  book['title'],
                                                  maxLines: 1,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Text(searching ? 'Results' : 'Discover',
                        style: Theme.of(context).textTheme.headlineMedium),
                    Spacer(),
                    if (searching) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          loadDiscoverBooks();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Clear Search'),
                      )
                    ]
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: FractionallySizedBox(
                  widthFactor: sizingInformation.isDesktop ? .8 : 1,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(children: [
                      for (Map item in books)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () {
                              if (!searching) {
                                searchBooks(item['title'], context);
                              } else {
                                globals.showLoaderDialog(context);
                                http
                                    .get(Uri.parse(
                                        '${globals.serverUrl}/book?url=${item['link']}'))
                                    .then((value) {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: ((context) {
                                    return BookInfoPage(
                                        bookInfo: jsonDecode(value.body));
                                  })));
                                });
                              }
                            },
                            child: Container(
                                child: Row(
                              children: [
                                Expanded(
                                  flex: sizingInformation.isDesktop ? 1 : 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      '${globals.serverUrl}/cors?url=${item['cover']}',
                                      height: 150,
                                      width: 105,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  flex: sizingInformation.isDesktop ? 9 : 8,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (item.containsKey('fileName')) ...[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Opacity(
                                            opacity: .75,
                                            child: Text(
                                              item['fileName'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                          ),
                                        )
                                      ],
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                            fontSize:
                                                sizingInformation.isDesktop
                                                    ? 20
                                                    : 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (item.containsKey('publisher')) ...[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Opacity(
                                            opacity: .9,
                                            child: Text(
                                              item['publisher'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                          ),
                                        )
                                      ],
                                      Text(item['authors']),
                                    ],
                                  ),
                                )
                              ],
                            )),
                          ),
                        ),
                    ]),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
