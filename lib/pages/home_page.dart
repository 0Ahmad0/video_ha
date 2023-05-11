import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cam/pages/upload_video_page.dart';
import 'package:flutter_cam/pages/video_player_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:provider/provider.dart';

import '../controller/video_provider.dart';
import '../models/models.dart';
import 'app/picture/cach_picture_widget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  var getVideos;

  final List<Map<String, dynamic>> _tabs = [
    {"text": "Records", "icon": null},
    //{"text": "Important", "icon": Icons.label_important},
    // {"text": "Games", "icon": Icons.sports_esports_rounded},
    // {"text": "Food", "icon": Icons.fastfood},
    // {"text": "Sport", "icon": Icons.sports_handball},
    // {"text": "Learning", "icon": Icons.school},
  ];
  Future<bool> getData() {
    return Future.delayed(Duration(seconds: 5), () {
      return true;
    });
  }

  getVideosFun() async {
    // chatProvider.fetchChatByListIdUser( listIdUser: chatProvider.chat.listIdUser);
    getVideos = videoProvider.fetchVideosStream();
    return getVideos;
  }

  late TabController _tabController;
  late VideoProvider videoProvider;
  @override
  void initState() {
    videoProvider = Provider.of<VideoProvider>(context, listen: false);
    getVideosFun();
    loadVideoPlayer();
    generateThumbnail();

    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  late VideoPlayerController controller;
  loadVideoPlayer() {
    controller = VideoPlayerController.asset('assets/video/1.mp4');
    controller.addListener(() {
      ///setState(() {});
    });
    controller.initialize().then((value) {
      /// setState(() {});
    });
  }

  String category = 'all';
  String? _thumbnailFile;

  String? _thumbnailUrl;

  Uint8List? _thumbnailData;

  Future<File> copyAssetFile(String assetFileName) async {
    Directory tempDir = await getTemporaryDirectory();
    final byteData = await rootBundle.load(assetFileName);

    File videoThumbnailFile = File("${tempDir.path}/$assetFileName")
      ..createSync(recursive: true)
      ..writeAsBytesSync(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return videoThumbnailFile;
  }

  void generateThumbnail() async {
    File videoTempFile1 = await copyAssetFile("assets/video/1.mp4");
    File videoTempFile2 = await copyAssetFile("assets/video/2.mp4");

    _thumbnailFile = await VideoThumbnail.thumbnailFile(
        video: videoTempFile2.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG);

    _thumbnailUrl = await VideoThumbnail.thumbnailFile(
        video:
            "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.WEBP);

    _thumbnailData = await VideoThumbnail.thumbnailData(
      video: videoTempFile2.path,
      imageFormat: ImageFormat.JPEG,
      quality: 25,
    );

    ///setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    videoProvider = Provider.of<VideoProvider>(context);
    return DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => UploadVideoPage()));
                },
                label: const Text('Upload')),
            appBar: AppBar(
              title: const Text("Recorded Videos"), // records
              centerTitle: true,
              bottom: TabBar(
                onTap: (index) {
                  category = _tabs[index]['text'];
                  videoProvider.notifyListeners();
                },
                isScrollable: true,
                tabs: [
                  for (var i = 0; i < _tabs.length; i++)
                    Tab(
                      child: Row(
                        children: [
                          Icon(_tabs[i]['icon']),
                          Text(_tabs[i]['text']),
                        ],
                      ),
                    )
                ],
              ),
            ),
            body: StreamBuilder<QuerySnapshot>(
                //prints the messages to the screen0
                stream: getVideos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return shimmer();
                  } else if (snapshot.connectionState ==
                      ConnectionState.active) {
                    if (snapshot.hasError) {
                      return const Text('Error');
                    } else if (snapshot.hasData) {
                      shimmer();
                      videoProvider.videos =
                          Videos.fromJson(snapshot.data!.docs);
                      videoProvider.listVideo = videoProvider.videos.listVideo;
                      videoProvider.getVideoPlayers(
                          listVideo: videoProvider.listVideo);
                      return ChangeNotifierProvider<VideoProvider>.value(
                          value: Provider.of<VideoProvider>(context),
                          child: Consumer<VideoProvider>(
                              builder: (context, value, child) {
                            videoProvider.listVideo =
                                videoProvider.filterVideos(
                                    listVideo: videoProvider.videos.listVideo,
                                    category: category!);
                            return builderVideos(videoProvider: videoProvider);
                          }));

                      /// }));
                    } else {
                      return const Text('Empty data');
                    }
                  } else {
                    return Text('State: ${snapshot.connectionState}');
                  }
                })));
  }

  shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      // enabled: _enabled,
      child: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 6,
                color: Theme.of(context).cardColor,
              ),
              const SizedBox(
                height: 8.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 8.0,
                    color: Theme.of(context).cardColor,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width / 3),
                    width: double.infinity,
                    height: 8.0,
                    color: Theme.of(context).cardColor,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width / 2),
                    width: double.infinity,
                    height: 8.0,
                    color: Theme.of(context).cardColor,
                  ),
                ],
              )
            ],
          ),
        ),
        itemCount: _tabs.length,
      ),
    );
  }

  builderVideos({required VideoProvider videoProvider}) {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemBuilder: (_, index) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: .2)]),
            margin: const EdgeInsets.all(10.0),
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 3.75,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CacheNetworkImage(
                        photoUrl: //  'https://firebasestorage.googleapis.com/v0/b/hasan-pro.appspot.com/o/Images%2FMusic%2Fimage_picker.mp4?alt=media&token=79a38914-2edf-4437-97ac-538ddfdc4935',
                            videoProvider.listVideo[index].urlTempPhoto,
                        width: double.infinity,
                        boxFit: BoxFit.fill,
                        height: MediaQuery.of(context).size.height / 3,
                        errorWidget: Icon(Icons.image),
                        waitWidget: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // FutureBuilder(
                      //     future: videoProvider.getThumbnailForVideo(video: videoProvider.listVideo[index]),
                      //     builder: (context, snapShot) {
                      //       return snapShot.hasData
                      //           ?Image.memory(
                      //         videoProvider.mapThumbnail[videoProvider.listVideo[index].url]!,
                      //         width: double.infinity,
                      //         fit: BoxFit.fill,
                      //         height:
                      //         MediaQuery.of(context).size.height / 3,
                      //       )
                      //           :Shimmer.fromColors(
                      //         baseColor: Colors.grey[300]!,
                      //         highlightColor: Colors.grey[100]!, child: Container(
                      //         width: double.infinity,
                      //         height: MediaQuery.of(context).size.height / 6,
                      //         color: Colors.white,
                      //       ),); }),
                      ChangeNotifierProvider<VideoProvider>.value(
                          value: Provider.of<VideoProvider>(context),
                          child: Consumer<VideoProvider>(
                              builder: (context, value, child) => Visibility(
                                    visible: videoProvider
                                        .mapVideoPlayer[
                                            videoProvider.listVideo[index].url]
                                        .value
                                        .isInitialized,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ViderPlayerScreen(
                                                      controller: videoProvider
                                                              .mapVideoPlayer[
                                                          videoProvider
                                                              .listVideo[index]
                                                              .url],
                                                    )));
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black45,
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )))
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.blue,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4.0)),
                        child: ChangeNotifierProvider<VideoProvider>.value(
                            value: Provider.of<VideoProvider>(context),
                            child: Consumer<VideoProvider>(
                                builder: (context, value, child) =>
                                    videoProvider
                                            .mapVideoPlayer[videoProvider
                                                .listVideo[index].url]
                                            .value
                                            .isInitialized
                                        ? Text(
                                            //    '${controller.value.duration.inMinutes}'
                                            '${videoProvider.mapVideoPlayer[videoProvider.listVideo[index].url]!.value.duration.inMinutes}'
                                            ':'
                                            // '${controller.value.duration.inSeconds}'
                                            '${videoProvider.mapVideoPlayer[videoProvider.listVideo[index].url]!.value.duration.inSeconds}',
                                            style: TextStyle(
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          )
                                        : Text('Loading ...'))),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.0)),
                          child: Text(
                            '${videoProvider.listVideo[index].name}',
                            style: TextStyle(overflow: TextOverflow.ellipsis),
                            //'${controller.dataSource}'
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //ToDo: Mriwed
          Positioned(
            top: 20,
            left: 20,
            child: CircleAvatar(
                child: IconButton(onPressed: () {}, icon: Icon(Icons.copy))),
          ),
        ],
      ),
      itemCount: videoProvider.listVideo.length,
    );
  }
}
