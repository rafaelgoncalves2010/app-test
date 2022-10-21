## Prerequisites
Flutter >=2.7.0 < 2.12

## Installation

example package access run the command:

```sh
flutter pub get
```

you need to add your "sdk_key" in `main.dart`:

```dart
  static const authKey = "you_sdk_key";
  static final publicKeyHash = ["publickeyhash"];


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    IdwallSdk.initializeWithLoggingLevel(authKey, IdwallLoggingLevel.VERBOSE);
    IdwallSdk.setIdwallEventsHandler((event) => {print("event: $event")});
    IdwallSdk.setupPublic(publicKeyHash);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }
```

## Config Android
For your project's Android code to download our SDK and add it as a dependency, you will need to request a username and password from the idwall team.
Having obtained your credentials, just add them to the file `gradle.properties` in the root of your project's android directory. You should also add the flags for using AndroidX in your `gradle.properties`, as shown below:

```sh
# Other configs here
# idwall credentials
idwallUrl=https://artifacts.idwall.services/repository/sdk-mobile-android/
idwallUsername=yourUsername
idwallPassword=yourPassword

# AndroidX related flags
android.useAndroidX=true
android.enableJetifier=true
```


## Getting Started

Access the example project and run the command:
```sh
flutter run
```
generate apk by terminal for debug android [flutter documentation for android](https://flutter.dev/docs/deployment/android#build-an-apk)

```sh
flutter build apk --debug
```
generate ipa by terminal for debug ios [flutter documentation for ios](https://flutter.dev/docs/deployment/ios#create-a-build-archive-with-xcode)

```sh
flutter build ipa --debug
```

### Deploying Flutter SDK to Nexus

Locally, you need to git checkout to the master branch and make sure it is up to date.
After that, run:

```sh
git archive --format zip --output idwall_sdk.zip HEAD
```

Then:
```sh
zip --delete idwall_sdk.zip "example/*"
```

Finally, upload the file idwall_sdk.zip to the https://artifacts.idwall.services/ `sdk-flutter-releases` repository with the name idwall_sdk.zip (same as the file name)
and Directory's name equivalent to the version inside `pubspec.yaml` (e. g. 2.1.3)





