# Android Release Guide

Debug builds use `flutter build apk --debug`. Select JDK 17 for local and CI Android builds. CI pins Flutter 3.47.0, the toolchain verified in this workspace.

## Upload signing

The app now loads `android/key.properties` when that ignored file exists. Create the upload keystore outside the repository, then create this local file with the four required properties:

```properties
storeFile=C:/protected/location/upload-keystore.jks
storePassword=<private store password>
keyAlias=upload
keyPassword=<private key password>
```

Use an absolute keystore path. Relative paths resolve from `android/`. A supplied configuration with missing values or a missing keystore fails before compilation. Passwords are never printed by the configuration validation.

With the protected file available, `flutter build appbundle --release` signs with the upload key. Without it, release outputs remain unsigned for compilation checks. For a production build, require signing explicitly so a missing file cannot silently produce an unsigned artifact:

```powershell
Set-Location android
.\gradlew.bat bundleRelease -PrequireReleaseSigning=true --no-daemon
```

Verify the resulting AAB using `jarsigner -verify -verbose -certs` and compare its signer certificate with the upload certificate registered in Play Console. Verify release APKs using Android SDK `apksigner verify --verbose --print-certs`. Successful compilation alone does not establish signature validity.

The configuration follows the [Flutter Android signing guide](https://docs.flutter.dev/deployment/android#sign-the-app). A production keystore has not been created or supplied in this workspace; signed release verification remains pending.

Never commit `.jks`, `.keystore`, `key.properties`, passwords, Play service-account JSON, or upload credentials. Back up the upload key securely and document recovery access privately. Verify package ID, min/target SDK, 64-bit libraries, R8 output, mapping retention, backup policy, network security, Data Safety form, content rating, and Play pre-launch report for every release.
