import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';


import 'package:path/path.dart' ;

import '../../models/models.dart' as model;

import 'package:provider/provider.dart';

import '../uploader_provider.dart';

//import '../../translations/locale_keys.g.dart';

class FirebaseFun{
  static var rest;
  static  FirebaseAuth auth=FirebaseAuth.instance;
  static Duration timeOut =Duration(seconds: 30);

   ///Video
  static addVideo( {required model.Video video}) async {
    final result= await FirebaseFirestore.instance.collection('Video').add(
        video.toJson()
    ).then(onValueAddVideo).catchError(onError).timeout(timeOut,onTimeout: onTimeOut);
    return result;
  }
  static updateVideo( {required model.Video video}) async {
    final result= await FirebaseFirestore.instance.collection('Video').doc(
        video.id
    ).update(video.toJson()).then(onValueUpdateVideo).catchError(onError).timeout(timeOut,onTimeout: onTimeOut);
    return result;
  }
  static deleteVideo( {required model.Video video}) async {
    final result= await FirebaseFirestore.instance.collection('Video').doc(
        video.id
    ).delete().then(onValueDeleteVideo).catchError(onError).timeout(timeOut,onTimeout: onTimeOut);
    return result;
  }
  static fetchVideos()  async {
    final result=await FirebaseFirestore.instance.collection('Video')
    .orderBy('dateTime',descending: true)
        .get()
        .then((onValueFetchVideos))
        .catchError(onError).timeout(timeOut,onTimeout: onTimeOut);
    return result;
  }



  static Future<Map<String,dynamic>>  onError(error) async {
    print(false);
    print(error);
    return {
      'status':false,
      'message':error,
      //'body':""
    };
  }
  static Future<Map<String,dynamic>>  onTimeOut() async {
    print(false);
    return {
      'status':false,
      'message':'time out',
      //'body':""
    };
  }

  static Future<Map<String,dynamic>>  errorUser(String messageError) async {
    print(false);
    print(messageError);
    return {
      'status':false,
      'message':messageError,
      //'body':""
    };
  }


  static Future<Map<String,dynamic>>onValueAddVideo(value) async{
    return {
      'status':true,
      'message':'Video successfully add',
      'body':{}
    };
  }
  static Future<Map<String,dynamic>>onValueUpdateVideo(value) async{
    return {
      'status':true,
      'message':'Video successfully update',
      'body':{}
    };
  }
  static Future<Map<String,dynamic>>onValueDeleteVideo(value) async{
    return {
      'status':true,
      'message':'Video successfully delete',
      'body':{}
    };
  }
  static Future<Map<String,dynamic>> onValueFetchVideos(value) async{
    // print(true);
    print("Videos count : ${value.docs.length}");

    return {
      'status':true,
      'message':'Videos successfully fetch',
      'body':value.docs
    };
  }




  static String findTextToast(String text){
     // if(text.contains("Password should be at least 6 characters")){
     //   return tr(LocaleKeys.toast_short_password);
     // }else if(text.contains("The email address is already in use by another account")){
     //   return tr(LocaleKeys.toast_email_already_use);
     // }
     // else if(text.contains("Account Unsuccessfully created")){
     //   return tr(LocaleKeys.toast_Unsuccessfully_created);
     // }
     // else if(text.contains("Account successfully created")){
     //    return tr(LocaleKeys.toast_successfully_created);
     // }
     // else if(text.contains("The password is invalid or the user does not have a password")){
     //    return tr(LocaleKeys.toast_password_invalid);
     // }
     // else if(text.contains("There is no user record corresponding to this identifier")){
     //    return tr(LocaleKeys.toast_email_invalid);
     // }
     // else if(text.contains("The email address is badly formatted")){
     //   return tr(LocaleKeys.toast_email_invalid);
     // }
     // else if(text.contains("Account successfully logged")){
     //     return tr(LocaleKeys.toast_successfully_logged);
     // }
     // else if(text.contains("A network error")){
     //    return tr(LocaleKeys.toast_network_error);
     // }
     // else if(text.contains("An internal error has occurred")){
     //   return tr(LocaleKeys.toast_network_error);
     // }else if(text.contains("field does not exist within the DocumentSnapshotPlatform")){
     //   return tr(LocaleKeys.toast_Bad_data_fetch);
     // }else if(text.contains("Given String is empty or null")){
     //   return tr(LocaleKeys.toast_given_empty);
     // }
     // else if(text.contains("time out")){
     //   return tr(LocaleKeys.toast_time_out);
     // }
     // else if(text.contains("Account successfully logged")){
     //   return tr(LocaleKeys.toast);
     // }
     // else if(text.contains("Account not Active")){
     //   return tr(LocaleKeys.toast_account_not_active);
     // }

     return text;
  }
  static int compareDateWithDateNowToDay({required DateTime dateTime}){
     int year=dateTime.year-DateTime.now().year;
     int month=dateTime.year-DateTime.now().month;
     int day=dateTime.year-DateTime.now().day;
     return (year*365+
            month*30+
            day);
  }
  static Future uploadFile({required String filePath,required String typePathStorage}) async {
    try {
      String path = basename(filePath);
      print(path);
      File file =File(filePath);

//FirebaseStorage storage = FirebaseStorage.instance.ref().child(path);
      Reference storage = FirebaseStorage.instance.ref().child("${typePathStorage}/${path}");
      UploadTask storageUploadTask = storage.putFile(file);
      TaskSnapshot taskSnapshot = await storageUploadTask;
      //Const.LOADIG(context);
      String url = await taskSnapshot.ref.getDownloadURL();
      //Navigator.of(context).pop();
      print('url $url');
      return url;
    } catch (ex) {
      //Const.TOAST( context,textToast:FirebaseFun.findTextToast("Please, upload the image"));
    }
  }
  static Future uploadFileWithProgress(BuildContext context,{required String filePath,required String typePathStorage}) async {
    UploaderProvider uploaderProvider=Provider.of<UploaderProvider>(context,listen: false);
    try {
      String path = basename(filePath);
      print(path);
      File file =File(filePath);

//FirebaseStorage storage = FirebaseStorage.instance.ref().child(path);
      Reference storage = FirebaseStorage.instance.ref().child("${typePathStorage}/${path}");
      UploadTask storageUploadTask = storage.putFile(file);
      uploaderProvider.setValueMapUploadTask(key: filePath, value: storageUploadTask);
      TaskSnapshot taskSnapshot = await storageUploadTask;

      //Const.LOADIG(context);
      String url = await taskSnapshot.ref.getDownloadURL();
      //Navigator.of(context).pop();
      print('url $url');
      return url;
    } catch (ex) {
      //Const.TOAST( context,textToast:FirebaseFun.findTextToast("Please, upload the image"));
    }
  }
  static Future uploadFileData({required File file,required Uint8List data, required String folder}) async {
    try {
      String path = basename(file.path);

//FirebaseStorage storage = FirebaseStorage.instance.ref().child(path);
      Reference storage = FirebaseStorage.instance.ref().child("${folder}/${path}");
      UploadTask storageUploadTask = storage.putData(data);
      TaskSnapshot taskSnapshot = await storageUploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    } catch (ex) {
      //Const.TOAST( context,textToast:FirebaseFun.findTextToast("Please, upload the image"));
    }
  }
  static Future uploadImage({required XFile image, required String folder}) async {
    try {
      String path = basename(image.path);
      print(image.path);
      File file =File(image.path);

//FirebaseStorage storage = FirebaseStorage.instance.ref().child(path);
      Reference storage = FirebaseStorage.instance.ref().child("${folder}/${path}");
      UploadTask storageUploadTask = storage.putFile(file);
      TaskSnapshot taskSnapshot = await storageUploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    } catch (ex) {
      //Const.TOAST( context,textToast:FirebaseFun.findTextToast("Please, upload the image"));
    }
  }
}