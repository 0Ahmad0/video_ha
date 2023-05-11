import 'dart:io';

import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../controller/uploader_provider.dart';
import '../controller/video_provider.dart';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({Key? key}) : super(key: key);

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}
List<Map<String, dynamic>> tabs = [
{
//records
"path": "Saved_clips_RPI/home/pi/camera",
"text": "Records", // change directory from firebase here >> only add the
"icon": Icons.video_camera_back_outlined
},
{
//important
"path": "reported_clips_RPI/home/pi/camera",
"text": "Important",
"icon": Icons.label_important
},
  // {"text": "Games", "icon": Icons.sports_esports_rounded},
  // {"text": "Food", "icon": Icons.fastfood},
  // {"text": "Sport", "icon": Icons.sports_handball},
  // {"text": "Learning", "icon": Icons.school},
];

class _UploadVideoPageState extends State<UploadVideoPage> {
  // late  VideoPlayerController _videoPlayerController;

  // loadVideoPlayer(String path) async {
  //   _videoPlayerController = VideoPlayerController.asset(path);
  //   // _videoPlayerController.addListener(() {
  //   //   setState(() {});
  //   // });
  //   await  _videoPlayerController.initialize().then((value) {
  //    // setState(() {});
  //    });
  //   return _videoPlayerController;
  // }
  String? _thumbnailFile;
  String? category;
  String? pathStorage;
  XFile? cameraPicker;
  XFile? galleryPicker;
  //XFile? picker;

  File? _video;
  final picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;

  _pickVideo() async {
    PickedFile? pickedFile = await picker.getVideo(source: ImageSource.gallery);
    _video = File(pickedFile!.path);
    _videoPlayerController = VideoPlayerController.file(_video!)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      });
  }

  _pickVideoFromCamera() async {
    XFile? pickedFile = await picker.pickVideo(source: ImageSource.camera);
    _video = File(pickedFile!.path);
    _videoPlayerController = VideoPlayerController.file(_video!)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      });
  }

  final _formKey = GlobalKey<FormState>();
  late UploaderProvider uploaderProvider;
  @override
  Widget build(BuildContext context) {
    VideoProvider videoProvider = Provider.of<VideoProvider>(context);
    uploaderProvider = Provider.of<UploaderProvider>(context);
    videoProvider.checkSend = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                  child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                        onPressed: _pickVideo,
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('From Gallery'),
                          trailing: Icon(Icons.videocam_rounded),
                        ),
                      )),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: _pickVideoFromCamera,
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('From Camera'),
                          trailing: Icon(Icons.camera_alt),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  if (_video != null)
                    _videoPlayerController!.value.isInitialized
                        ? Expanded(
                            child: AspectRatio(
                              aspectRatio:
                                  _videoPlayerController!.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController!),
                            ),
                          )
                        : const SizedBox(),
                ],
              )),
              const SizedBox(
                height: 20.0,
              ),
              DropdownButtonFormField(
                  items: [
                    for (int i = 0; i < tabs.length; i++)
                      DropdownMenuItem(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${tabs[i]['text']}'),
                            Icon(tabs[i]['icon'])
                          ],
                        ),
                        value: i,
                      )
                  ],
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select Category'),
                  validator: (val) {
                    if (val == null) {
                      return 'This Filed Is Required';
                    }
                  },
                  onChanged: (val) {
                    category = tabs[val!]['text'];
                    pathStorage = tabs[val]['path'];
                    //print('${category}');
                  }),
              const SizedBox(
                height: 10.0,
              ),
              ChangeNotifierProvider<VideoProvider>.value(
                  value: Provider.of<VideoProvider>(context),
                  child: Consumer<VideoProvider>(
                      builder: (context, value, child) => !videoProvider
                              .checkSend
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 60.0)),
                              onPressed: () async {
                                if (!videoProvider.checkSend) {
                                  if (_formKey.currentState!.validate() &&
                                      picker != null) {
                                    videoProvider.checkSend = true;
                                    videoProvider.notifyListeners();
                                    await videoProvider.addVideo(context,
                                        file: _video!,
                                        category: category!,
                                        pathStorage: pathStorage!);
                                    videoProvider.checkSend = false;
                                    videoProvider.notifyListeners();
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text("Done"))
                          : buildProgress(filePath: _video!.path)))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProgress({required String filePath}) =>
      ChangeNotifierProvider<UploaderProvider>.value(
          value: Provider.of<UploaderProvider>(context),
          child: Consumer<UploaderProvider>(
              builder: (context, uploaderProvider, child) => (uploaderProvider
                          .mapUploadTask[filePath] !=
                      null)
                  ? StreamBuilder<TaskSnapshot>(
                      stream: uploaderProvider
                          .mapUploadTask[filePath]?.snapshotEvents,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data!;
                          double progress =
                              data.bytesTransferred / data.totalBytes;
                          uploaderProvider.mapUploadProgress[filePath] =
                              progress;
                          return buildLinearProgress(
                              progress: progress,
                              child: Text(
                                  "Upload " + '${(100 * progress).round()}%',
                                  style: const TextStyle(color: Colors.white)));
                        } else {
                          return buildLinearProgress(
                              progress: 0,
                              child: Text("Upload 0%",
                                  style: const TextStyle(color: Colors.white)));
                        }
                      })
                  : buildLinearProgress(
                      progress: 0,
                      child: Text("Processing 0%",
                          style: const TextStyle(color: Colors.white)))));

  buildLinearProgress({required double progress, required child}) {
    return Container(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.loose,
        children: [
          LinearProgressIndicator(
            minHeight: 60.0,
            value: progress,
            backgroundColor: Colors.grey,
            color: Colors.green,
          ),
          child
        ],
      ),
    );
  }
}
