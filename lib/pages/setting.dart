import 'package:flutter/material.dart';
import 'package:flutter_cam/main.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.5),
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text(theme? 'Dark Theme':'Light Theme' ),
              trailing: IconButton(onPressed: (){
                theme = !theme;
                setTheme.add(theme);
                // setState(() {
                //
                // });
              }, icon: Icon(
                  theme ? Icons.dark_mode:Icons.sunny)),
            ),
          )
        ],
      ),
    );
  }
}
