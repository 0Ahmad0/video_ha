import 'dart:math';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cam/controller/utils/firebase.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'dart:math' as Math;

import '../models/models.dart';
import '../models/utils/consts_manager.dart';

class VideoProvider with ChangeNotifier {
  Video video = Video.init();
  Videos videos = Videos.init();
  List<Video> listVideo = [];
  Map<String, dynamic> mapThumbnail = {};
  Map<String, dynamic> mapVideoPlayer = {};
  bool checkSend = false;
  fetchVideos(BuildContext context) async {
    var result;
    result = await FirebaseFun.fetchVideos();
    if (result['status']) {
      videos = Videos.fromJson(result['body']);
    } else {
      Get.snackbar("Error",
          "${FirebaseFun.findTextToast(result['message'].toString())}");
      // Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString()));
    }
    return result;
  }

  fetchVideosStream() {
    final result = FirebaseFirestore.instance
        .collection(AppConstants.collectionVideo)
        .orderBy("sendingTime")
        .snapshots();
    return result;
  }

  copyVideo(BuildContext context,
      {required Video video,required String category}) async {
    var result;
    video.sendingTime = DateTime.now();
    video.category=category;


      result = await FirebaseFun.addVideo(video: video);
      //Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString()));
    Get.snackbar(
        "result", "${FirebaseFun.findTextToast(result['message'].toString())}");

    return result;
  }
  addVideo(BuildContext context,
      {required File file,
        required String category,
        required String pathStorage}) async {
    var result;
    video = Video(
        name: basename(file.path),
        category: category,
        typeVideo: 'mp4',
        senderId: '',
        sendingTime: DateTime.now());
    await getThumbnailForVideo(url: file.path);

    var photoUrl = await FirebaseFun.uploadFileData(
        file: file,
        data: mapThumbnail[file.path],
        folder: 'Images/${category}');
    print('object ${photoUrl}');
    var url = await FirebaseFun.uploadFileWithProgress(context,
        filePath: file.path, typePathStorage: pathStorage);
    print(url);
    if (url != null) {
      video.url = url.toString();
      video.sizeFile = await file.length();
      video.urlTempPhoto = await photoUrl;
    } else
      result = FirebaseFun.onError('fail upload video');
    if (result == null) {
      result = await FirebaseFun.addVideo(video: video);
      //Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString()));
    }
    Get.snackbar(
        "result", "${FirebaseFun.findTextToast(result['message'].toString())}");

    return result;
  }

  updateReport(BuildContext context, {required Video video}) async {
    var result;
    result = await FirebaseFun.updateVideo(video: video);
    Get.snackbar(
        "result", "${FirebaseFun.findTextToast(result['message'].toString())}");
    //Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString()));
    return result;
  }

  filterVideos({required List<Video> listVideo, required String category}) {
    List<Video> listTemp = [];
    if (category.toLowerCase() == 'all') return listVideo;
    for (Video video in listVideo) {
      if (category.toLowerCase() == video.category.toLowerCase())
        listTemp.add(video);
    }
    return listTemp;
  }

  getVideoPlayers({required List<Video> listVideo}) async {
    for (Video video in listVideo) {
      if (!mapVideoPlayer.containsKey(video.url)) {
        VideoPlayerController controller;
        mapVideoPlayer[video.url] = VideoPlayerController.network(video.url);
        mapVideoPlayer[video.url].initialize().then((value) {
          notifyListeners();
        });
      }
    }
    return mapVideoPlayer;
  }

  getVideoPlayer({required Video video}) async {
    if (!mapVideoPlayer.containsKey(video.url)) {
      VideoPlayerController controller;
      controller = await VideoPlayerController.network(video.url);
      await controller.initialize().then((value) {
        mapVideoPlayer[video.url] = controller;
        notifyListeners();
      });
    }
    return mapThumbnail[video.url];
  }

  getThumbnailForVideo({required String url}) async {
    if (!mapThumbnail.containsKey(url)) {
      mapThumbnail[url] = await VideoThumbnail.thumbnailData(
        video: url,
        imageFormat: ImageFormat.JPEG,
        quality: 25,
      );
    }
    return mapThumbnail[url];
  }
}
