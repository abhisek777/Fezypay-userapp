import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:six_cash/data/api/api_client.dart';
import 'package:six_cash/features/auth/domain/models/user_short_data_model.dart';
import 'package:six_cash/util/app_constants.dart';


class AuthRepo extends GetxService{
   final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({required this.apiClient, required this.sharedPreferences});


  Future<Response> checkPhoneNumber({String? phoneNumber}) async {
    return apiClient.postData(AppConstants.customerPhoneCheckUri, {"phone": phoneNumber});
  }
  
  Future<Response> verifyPhoneNumber({String? phoneNumber,String? otp}) async {
    return apiClient.postData(AppConstants.customerPhoneVerifyUri, {"phone": phoneNumber, "otp": otp});
  }
   Future<Response> registration(Map<String,String> customerInfo,List<MultipartBody> multipartBody) async {
     return await apiClient.postMultipartData(AppConstants.customerRegistrationUri, customerInfo,multipartBody);
   }
   Future<Response> login({String? dialCode,String? phone, String? password}) async {
     return await apiClient.postData(
       AppConstants.customerLoginUri,
       {"phone": phone, "password": password, "dial_country_code": dialCode},
     );
   }
   Future<Response> deleteUser() async {
     return await apiClient.deleteData(AppConstants.customerRemove);
   }


   Future<Response> updateToken({bool? isLogOut}) async {
     String? deviceToken;

     if(!(isLogOut ?? false)){
       if (GetPlatform.isIOS) {
         NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
           alert: true, announcement: false, badge: true, carPlay: false,
           criticalAlert: false, provisional: false, sound: true,
         );
         if(settings.authorizationStatus == AuthorizationStatus.authorized) {
           deviceToken = await _saveDeviceToken();
           FirebaseMessaging.instance.subscribeToTopic(AppConstants.all);
           FirebaseMessaging.instance.subscribeToTopic(AppConstants.users);
           debugPrint('=========>Device Token ======$deviceToken');
         }
       }else {
         deviceToken = await _saveDeviceToken();
         FirebaseMessaging.instance.subscribeToTopic(AppConstants.all);
         FirebaseMessaging.instance.subscribeToTopic(AppConstants.users);
         debugPrint('=========>Device Token ======$deviceToken');
       }
       if(!GetPlatform.isWeb) {
         FirebaseMessaging.instance.subscribeToTopic(AppConstants.all);
         FirebaseMessaging.instance.subscribeToTopic(AppConstants.users);
       }
     }

     // For Logout => Clear token using this API, That's why we are using isLogOut variable to identify if it's for logout or not.
     return await apiClient.postData(AppConstants.tokenUri, {"_method": "put", "token": (isLogOut ?? false) ? '@' : deviceToken});
   }


   Future<String?> _saveDeviceToken() async {
     String? deviceToken = '';

     deviceToken = (await FirebaseMessaging.instance.getToken())!;
     return deviceToken;
   }


   Future<Response>  checkOtpApi() async {
     return await apiClient.postData(AppConstants.customerCheckOtp,{});
   }

   Future<Response>  verifyOtpApi({required String otp}) async {
     return await apiClient.postData(AppConstants.customerVerifyOtp, {'otp': otp });
   }


   Future<Response> logout() async {
     return await apiClient.postData(AppConstants.customerLogoutUri,{});
   }
   Future<Response> updateProfile(Map<String,String> profileInfo, List<MultipartBody> multipartBody) async {
     return await apiClient.postMultipartData(AppConstants.customerUpdateProfile, profileInfo, multipartBody);
   }
   Future<Response>  pinVerifyApi({required String pin}) async {
     return await apiClient.postData(AppConstants.customerPinVerify,{'pin': pin});
   }

   Future<bool> saveUserToken(String token) async {
     apiClient.token = token;
     apiClient.updateHeader(token);
     return await sharedPreferences.setString(AppConstants.token, token);
   }

   String? getUserToken() {
     return sharedPreferences.getString(AppConstants.token);
   }
   bool isLoggedIn() {
     return sharedPreferences.containsKey(AppConstants.token);
   }
   void removeUserToken()async{
     await sharedPreferences.remove(AppConstants.token);
   }

   void removeCustomerToken() async{
     await sharedPreferences.remove(AppConstants.token);
   }

   // for Forget password
   Future<Response> forgetPassOtp({String? phoneNumber}) async {
     return apiClient.postData(AppConstants.customerForgetPassOtpUri, {"phone": phoneNumber});
   }
   Future<Response> forgetPassVerification({String? phoneNumber, String? otp}) async {
     return apiClient.postData(AppConstants.customerForgetPassVerification, {"phone": phoneNumber, "otp": otp});
   }


   Future<void> setBiometric(bool isActive) async {
    if(!isActive) {
     await deleteSecureData(AppConstants.biometricPin);
    }
     sharedPreferences.setBool(AppConstants.biometricAuth, isActive);
   }

   bool isBiometricEnabled() {
     return sharedPreferences.getBool(AppConstants.biometricAuth) ?? true;
   }

   final FlutterSecureStorage _storage = const FlutterSecureStorage();

   IOSOptions _getIOSOptions() => const IOSOptions(
     accessibility: KeychainAccessibility.first_unlock,
   );

   AndroidOptions _getAndroidOptions() => const AndroidOptions(
     encryptedSharedPreferences: true,
   );

   Future<String> readSecureData(String key) async {
     String value = "";
     try {
      String value0 = await (_storage.read(key: key, aOptions: _getAndroidOptions(), iOptions: _getIOSOptions())) ?? "";
       String decodeValue =  utf8.decode(base64Url.decode(value0));
       value = decodeValue.replaceRange(4, decodeValue.length, '');

     } catch (e) {
       debugPrint('error ===> $e');

     }
     return value;
   }

   Future<void> deleteSecureData(String key) async {
     try {
       await _storage.delete(key: key, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
     } catch (e) {
       debugPrint('error ===> $e');
     }

   }

   Future<void> writeSecureData(String key, String? value) async {
     String uniqueKey = base64Encode(utf8.encode('${UniqueKey().toString()}${UniqueKey().toString()}'));
     String storeValue = base64Encode(utf8.encode('$value $uniqueKey'));
     try {
       await _storage.write(
         key: key,
         value: storeValue,
         iOptions: _getIOSOptions(),
         aOptions: _getAndroidOptions(),
       );
     } catch (e) {
       debugPrint('error from : repo : $e');
     }
   }

   Future<bool> containsKeyInSecureData(String key) async {
     var containsKey = await _storage.containsKey(key: key, aOptions: _getAndroidOptions(), iOptions: _getIOSOptions());
     return containsKey;
   }

   Future<void> setUserData(UserShortDataModel userData) async{
     try{
       await sharedPreferences.setString(AppConstants.userData, jsonEncode(userData.toJson()));
     }
     catch(e){
       rethrow;
     }
   }

   void removeUserData()=> sharedPreferences.remove(AppConstants.userData);

   String getUserData() {
     return sharedPreferences.getString(AppConstants.userData) ?? '';
   }

   Future<void> setTourWidgetStatus(bool newValue) async {
     sharedPreferences.setBool(AppConstants.showTourWidget, newValue);
   }

   bool showTourWidget() {
     return sharedPreferences.getBool(AppConstants.showTourWidget) ?? true;
   }

   Future<void> setWelcomeBottomSheetStatus(bool newValue) async {
     sharedPreferences.setBool(AppConstants.showWelcomeBottomSheet, newValue);
   }

   bool showWelcomeBottomSheet() {
     return sharedPreferences.getBool(AppConstants.showWelcomeBottomSheet) ?? true;
   }

}