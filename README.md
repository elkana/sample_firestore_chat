# firestore_chat

This sample is more like a sceleton than a sample of a nice GUI app.

```
flutter create --org com.eric -i objc -a java firestore_chat

flutter build apk --release
```

* choose a project in https://console.firebase.google.com/u/0/ 
  * fyi, firestore can only be used on a single project, not app
* Register new App with package `com.eric.firestore_chat`
* get file `google_services.json` at https://console.firebase.google.com/u/0/project/flutterproject-57085/overview
* drop it into `android/app`
* per 19 juni 21, minimum Android SDK is 23
* WAJIB buat SHA fingerprint di package yg udah ditentukan (misal `com.eric.firestore_chat`). SHA-1 ini merujuk pada file keystore **DEBUG** atau **PROD** jd pastikan dulu file `.keystore` yg mau diregister.
Kalau debug, flutter menggunakan file yg sama dengan Android Studio.

To get fingerprint, run following :
```
$ keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore
Enter keystore password: android
...

Certificate fingerprints:
         SHA1: 4F:D1:...
         SHA256: C9:C1:...
```
COPAS the value of SHA1 to related package, ex: `com.eric.firestore_chat` :
```
https://console.firebase.google.com/u/0/project/flutterproject-57085/settings/general/android:com.eric.firestore_chat
```
Dont forget to SAVE !

* Finally, create database here https://console.firebase.google.com/u/0/project/flutterproject-57085/firestore

---
## Android Native Setup

`android/app/build.gradle`

```
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 23
        multiDexEnabled true
    }

    splits {
        abi {
            enable true
            reset()
            include 'armeabi', 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
            universalApk true
        }
    }    
```

`android/build.gradle`

```
buildscript {
    repositories {
        ...
    }

    dependencies {
        ...
        classpath 'com.google.gms:google-services:4.3.8'
    }
```

---
## `pubspec.yml` per 19-Jun-21
```
  firebase_core:
  cloud_firestore:
  google_sign_in:
  firebase_auth:
  bubble:
```

## `main.dart`
Call `Firebase.initializeApp` before everything :
```
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
...
      home: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error initializing Firebase');
            } else if (snapshot.connectionState == ConnectionState.done) {
              return MyHomePage(
                title: 'Firestore Demo',
              );
            }

            return CircularProgressIndicator();
          }),
    );
  }
}
```



## FAT APK
+/- 38 MBytes


---
## References

https://firebase.flutter.dev/docs/firestore/usage/

https://github.com/Xenon-Labs/Flutter-Development/tree/master/chat_app/lib

https://medium.com/flutter-community/flutter-crud-operations-using-firebase-cloud-firestore-a7ef38bbf027

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.me/ellkana)