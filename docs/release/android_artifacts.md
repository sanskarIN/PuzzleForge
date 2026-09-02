# Android Build Artifacts

Verified on 2026-09-02 from the release-hardening commit series ending at `1cb205e`.

## Local outputs

These files are generated under the ignored `build/` directory and are available in the workspace:

| Artifact | Absolute path | Size | SHA-256 |
|---|---|---:|---|
| Debug APK | `E:\Games\PuzzleForge\build\app\outputs\flutter-apk\app-debug.apk` | 156,667,673 bytes | `A73E37B2C5A86653B4FD34AE9BE9D3D5562C19F3DD50F539ADCD3FB5DA07A16F` |
| Release APK (unsigned) | `E:\Games\PuzzleForge\build\app\outputs\flutter-apk\app-release.apk` | 54,422,872 bytes | `F89D738AD45DD91C0F4DC383EE832C00EBFF427331C992A868B6413D9CF71975` |
| Release AAB (unsigned) | `E:\Games\PuzzleForge\build\app\outputs\bundle\release\app-release.aab` | 53,221,934 bytes | `52FB57F21051C35A93FBC88DA9B193C0E8353D05777D26921ACFE6B88A64EC6A` |

The APKs can be installed for QA, but the release APK/AAB are not production-signed. Do not upload them to Google Play. Create an upload keystore outside the repository, configure the protected Gradle signing properties, rebuild, and verify the signed bundle before distribution.

## Reproducible command

From `android/`, select JDK 17 and use the populated Gradle cache:

```powershell
$env:JAVA_HOME='C:\Users\dell\.gradle\jdks\eclipse_adoptium-17-amd64-windows.2'
$env:PATH="$env:JAVA_HOME\bin;$env:PATH"
.\gradlew.bat assembleDebug assembleRelease bundleRelease --no-daemon --offline
```

The build completed successfully with Flutter 3.47.0, Gradle 9.1.0, AGP 9.0.1, and Android API 36 tooling. The Android SDK emitted non-fatal SDK XML/package-location warnings; they do not change the artifact hashes above. JDK 17 is required in this workspace because the available JDK 26 fails Android's `JdkImageTransform` during Flutter/AGP compilation.
