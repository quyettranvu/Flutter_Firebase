# LEARNING SOME SERVICES FOR WORKING WITH FIREBASE ON FLUTTER #
  * Firebase Firestore(Firebase Database)
  * Firebase Authentication
  * Firebase Storage
  * Firebase Messaging
  * Firebase Analytics(DebugView)

## Besides the default settings for working with Firebase on Android, 
  * For working with Firebase Messaging: In file AndroidManifest.xml:
            <intent-filter>
                <action android:name="FLUTTER_NOTIFICATION_CLICK" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>

  * For working with Firebase Analytics: In file build.gradle under app directory:
  * ```gradle
buildTypes {
release {
signingConfig signingConfigs.debug
}
debug {
minifyEnabled false
debuggable true
manifestPlaceholders = [ debugFirebaseAnalytics: "true" ]
}
}
```
  * Command for setting project name(need to have the same project name in Project Setting of Firebase and in AndroidManifest.xml):
  adb shell setprop debug.firebase.analytics.app name_project_name

