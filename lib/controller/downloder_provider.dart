

import 'dart:async';
import 'dart:io';


import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class DownloaderProvider with ChangeNotifier{
  Map<String,double> downloadProgress={};
  Map<String,bool> checkClickDownload={};
  Map<String,bool> checkCompleteDownload={};
   late var tempDir;
  Future downloadFile(Video element) async {
    checkClickDownload[element.id]=true;
    checkCompleteDownload[element.id]=false;
    downloadProgress[element.id]=0;
    notifyListeners();
    final tempDir= await getTemporaryDirectory();
    final path = "${tempDir.path}/${element.name}";
    var result =await Dio().download(
        element.url,
        path,
      onReceiveProgress: (received,total){
          double progress=received/total;
          if(received==total){
            checkCompleteDownload[element.id]=true;
            checkClickDownload[element.id]=false;
          }
          downloadProgress[element.id]=progress;
          notifyListeners();
      }
    );
  }

}