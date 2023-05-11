// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ehtooa/app/controller/utils/firebase.dart';
// import 'package:ehtooa/app/model/utils/local/storage.dart';
// import 'package:ehtooa/translations/locale_keys.g.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../model/models.dart' as models;
// import '../model/models.dart';
// import '../model/utils/const.dart';
// import '../view/resources/consts_manager.dart';
// import '../view/screens/questions/questions_view.dart';
//
// class HomeProvider with ChangeNotifier{
//   models.Users doctors=models.Users(users: []);
//   models.Groups groups=models.Groups(groups: []);
//   models.Sessions sessions=models.Sessions(sessions: []);
//   Map<String,dynamic> cacheUser=Map<String,dynamic>();
//   List<InteractiveSessions> sessionsToUser=[];
//   String idUser="";
//   String search="";
//   var setState3;
//   var setState2;
//  static bool isUpdate=false;
//   fetchDoctors(context) async {
//     var result =await FirebaseFun.fetchDoctors();
//     print(result);
//     (!result['status'])?Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString())):"";
//     return result;
//   }
//   fetchGroups(context) async {
//
//     var result =await FirebaseFun.fetchGroups();
//     print(result);
//     (!result['status'])?Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString())):"";
//     return result;
//   }
//
//   fetchSessionsIdUser(context,{required String typeUser,required List groups,required PaySession paySession,required String idUser}) async {
//     if(typeUser.contains(AppConstants.collectionPatient)){
//       return await fetchSessionsToUser(context, groups: groups, paySession: paySession, idUser: idUser);
//     }else if(typeUser.contains(AppConstants.collectionDoctor)){
//       return await fetchSessionsToDoctor(context, idUser: idUser);
//     }else if(typeUser.contains(AppConstants.collectionAdmin)){
//       return await fetchSessionsToAdmin(context);
//     }else
//       return await fetchSessionsToAdmin(context);
//   }
//   fetchSessionsToUser(context,{required List groups,required PaySession paySession,required String idUser}) async {
//     List idGroups=[];
//     for(models.Group group in groups){
//       idGroups.add(group.id);
//     }
//     this.idUser=idUser;
//     var result =await FirebaseFun.fetchSessionsToUser(idGroups: idGroups);
//     print(result);
//     if(result['status']){
//       sessions=models.Sessions.fromJson(result['body']);
//       if(search!=""){
//         sessions.sessions =await searchListSession(context, search: search, sessions: sessions.sessions);
//       }
//       sessionsToUser=[];
//       await processessionsToUser(context,groupsUser: groups, paySession: paySession);
//     }
//     (!result['status'])?Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString())):"";
//     return result;
//   }
//   fetchSessionsToAdmin(context) async {
//
//     var result =await FirebaseFun.fetchSessions();
//     print(result);
//     if(result['status']){
//       sessions=models.Sessions.fromJson(result['body']);
//       if(search!=""){
//         sessions.sessions =await searchListSession(context, search: search, sessions: sessions.sessions);
//       }
//       sessionsToUser=[];
//       await processessionsToDoctorOrAdmin(context);
//     }
//     (!result['status'])?Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString())):"";
//     return result;
//   }
//   fetchSessionsToDoctor(context,{required String idUser}) async {
//     this.idUser=idUser;
//     var result =await FirebaseFun.fetchSessionsToDoctor(idUser: idUser);
//     print(result);
//     if(result['status']){
//       sessions=models.Sessions.fromJson(result['body']);
//       if(search!=""){
//         sessions.sessions =await searchListSession(context, search: search, sessions: sessions.sessions);
//       }
//       sessionsToUser=[];
//       await processessionsToDoctorOrAdmin(context);
//     }
//     (!result['status'])?Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString())):"";
//     return result;
//   }
//   fetchNameUser(context,{required String idUser}) async{
//     if(cacheUser.containsKey(idUser)) return cacheUser[idUser];
//     var result =await FirebaseFun.fetchUserId(id: idUser,typeUser: AppConstants.collectionPatient);
//     if(result['status']&&result['body']==null){
//        result =await FirebaseFun.fetchUserId(id: idUser,typeUser: AppConstants.collectionDoctor);
//       if(result['status']&&result['body']==null){
//          result =await FirebaseFun.fetchUserId(id: idUser,typeUser: AppConstants.collectionAdmin);
//       }
//     }
//       cacheUser[idUser]=(result['status'])?models.User.fromJson(result['body']).name:"user";
//       return cacheUser[idUser];
//   }
//   processessionsToUser(context, {required List groupsUser,required PaySession paySession}){
//     sessionsToUser=[];
//     for(models.Session session in sessions.sessions){
//       int indexListPaySession=fetchIndexFromListPaySession(idGroup: session.idGroup);
//       bool isSold=false;
//       ///if(paySession.listCheckSessionPay[indexListPaySession]){
//         ///if(FirebaseFun.compareDateWithDateNowToDay(dateTime: paySession.listSessionPay[indexListPaySession])<=30){
//         if(checkUserPay(groupsUser, session.idGroup, idUser)){
//           isSold=true;
//        }
//           /// }
//       sessionsToUser.add( InteractiveSessions(
//         idGroup: session.idGroup,
//           name: session.name,
//           id_link:session.sessionUrl,
//           doctorName: session.listDoctor[0],
//           price: "${session.price}",
//           isSold: isSold
//       ));
//     }
//   }
//   processessionsToDoctorOrAdmin(context){
//     sessionsToUser=[];
//     for(models.Session session in sessions.sessions){
//       /// }
//       sessionsToUser.add( InteractiveSessions(
//           idGroup: session.idGroup,
//           name: session.name,
//           id_link:session.sessionUrl,
//           doctorName: session.listDoctor[0],
//           price: "${session.price}",
//           isSold: true
//       ));
//     }
//   }
//   addUserToGroup(context,{required String idUser,required String idGroup}) async {
//     if(!groups.groups[fetchIndexGroup(idGroup: idGroup)].listUsers.contains(idUser)){
//       groups.groups[fetchIndexGroup(idGroup: idGroup)].listUsers.add(idUser);
//     }
//     var result =await FirebaseFun.updateGroup(group: groups.groups[fetchIndexGroup(idGroup: idGroup)], id: idGroup,updateGroupType:models.UpdateGroupType.add_user);
//     print(result);
//     (!result['status'])?Const.TOAST(context,textToast: FirebaseFun.findTextToast(result['message'].toString())):"";
//     return result;
//   }
//  int fetchIndexFromListPaySession({required String idGroup}){
//     switch(idGroup){
//       case "YMfMrXosR8VF1xmbw1uU":
//         return 3;
//       case "eGcR8N9qBycAH6Y9xupV":
//         return 1;
//       case  "eK8OgCTMRTeIx3OWZz4Z":
//         return 0;
//     }
//     return 2;
//  }
//   int fetchIndexGroup({required String idGroup}){
//     switch(idGroup){
//       case "YMfMrXosR8VF1xmbw1uU":
//         return 0;
//       case "eGcR8N9qBycAH6Y9xupV":
//         return 1;
//       case  "eK8OgCTMRTeIx3OWZz4Z":
//         return 2;
//     }
//     return 3;
//   }
//   int fetchIndexGroupFromIndexList({required int index}){
//     switch(index){
//       case 3:
//         return 0;
//       case 1:
//         return 1;
//       case  0:
//         return 2;
//     }
//     return 3;
//   }
//
// Future<List<models.Session>> searchListSession(context,
//     {required String search, required List<models.Session> sessions}) async {
//     List<models.Session> tempSessions=[];
//     for(models.Session session in sessions){
//       String tempNameDoctor=await fetchNameUser(context, idUser: session.listDoctor[0]);
//       if(tempNameDoctor.contains(search)){
//         tempSessions.add(session);
//       }
//     }
//     return tempSessions;
// }
//
//   List<models.User> searchListDoctors(context,
//       {required String search, required List<models.User> users})  {
//     List<models.User> tempUsers=[];
//     for(models.User user in users){
//       if(user.name.contains(search)){
//         tempUsers.add(user);
//       }
//     }
//     return tempUsers;
//   }
//
//   bool checkUserPay(List groupsUser,String idGroup,String idUser){
//     Map listUserPay={};
//    /// print("idgroup ${idGroup}");
//     groupsUser.forEach((element) {
//       if(idGroup.contains(element.id)){
//         listUserPay=element.listUserPay;
//         ///print("listUserPay ${listUserPay}");
//       }
//
//     });
//    /// print("listUserPay ${idUser}");
//     if(listUserPay.containsKey(idUser)){
//       return checkUserPayTimestamp(timestamp: listUserPay[idUser]);
//     }else
//       return false;
//   }
//   bool checkUserPayTimestamp({required Timestamp timestamp}){
//     double secondInDay=60*60*24;
//     double currentNumberDaysPayment=(Timestamp.now().seconds-timestamp.seconds)/secondInDay;
//     if(currentNumberDaysPayment>0&&currentNumberDaysPayment<=30)
//       return true;
//     else
//       return false;
//
//     /*print("listUserPay : ${timestamp.seconds/secondInDay}");
//     print("listUserPay : ${Timestamp.now().seconds/secondInDay}");
//     DateTime dateTime =DateTime.now();
//     DateTime tempDateTime=DateTime(2022,9,29,23);
//     print("listUserPay : ${}");*/
//   }
// Future<void> goToUrl(context,String idLink) async {
//   var urllaunchable = await canLaunchUrl(Uri.parse(idLink)); //canLaunch is from url_launcher package
//   if(urllaunchable){
//     Const.LOADIG(context);
//     await launchUrl(Uri.parse(idLink));
//     Navigator.of(context).pop();//launch is from url_launcher package to launch URL
//   }else{
//     Const.TOAST(context,textToast: FirebaseFun.findTextToast("URL can't be launched."));
//   }
// }
//
//   onError(error){
//     print(false);
//     print(error);
//     return {
//       'status':false,
//       'message':error,
//       //'body':""
//     };
//   }
// }