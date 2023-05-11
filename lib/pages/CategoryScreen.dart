import 'package:flutter/material.dart';
import 'package:flutter_cam/pages/CategoryConstants.dart';
import 'package:flutter_cam/pages/home_page.dart';
import 'package:flutter_cam/pages/setting.dart';
import 'package:flutter_cam/pages/upload_video_page.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import 'important.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category'),
        centerTitle: true,
      ),
      body: Center(
        child: GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: CategoryConstants.category_item.length,
            itemBuilder: (_, index) {
              var category = CategoryConstants.category_item;
              return GestureDetector(
                onTap: () {
                  if (index == 3 || index == 4) {
                    showToast('Not Available Yet', context: context);
                  } else if (index == 5) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SettingPage()));
                  } else if (index == 1) {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => HomePage()));
                  } else if (index == 0) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => UploadVideoPage()));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ImportantPage()));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.2),
                          blurRadius: 6,
                          spreadRadius: 2)
                    ],
                    color: (index == 3 || index == 4)
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category[index].icon,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        category[index].text,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
