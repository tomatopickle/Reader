import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map settings = {
    'openWithSystemViewer': false,
  };
  @override
  void initState() {
    initSettings();
    super.initState();
  }

  void initSettings() async {
    final SharedPreferences db = await SharedPreferences.getInstance();
    settings['openWithSystemViewer'] =
        db.getBool('settings/openWithSystemViewer') ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SettingsList(
        applicationType: ApplicationType.material,
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) async{
                  print('DONE');
                  final SharedPreferences db =
                      await SharedPreferences.getInstance();
                  settings['openWithSystemViewer'] =
                  value;
                  setState(() {});
                  db.setBool('settings/openWithSystemViewer',
                      settings['openWithSystemViewer']);
                },
                initialValue: settings['openWithSystemViewer'],
                onPressed: (context) async {
                  print('DONE');
                  final SharedPreferences db =
                      await SharedPreferences.getInstance();
                  settings['openWithSystemViewer'] =
                      !settings['openWithSystemViewer'];
                  setState(() {});
                  db.setBool('settings/openWithSystemViewer',
                      settings['openWithSystemViewer']);
                },
                leading: const Icon(Icons.folder_open_rounded),
                title: const Text('Open files with sytem default viewer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
