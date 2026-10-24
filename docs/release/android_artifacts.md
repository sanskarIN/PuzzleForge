# Android Build Artifacts

## Current verification — 24 October 2026

Built from the Puzzle Path source through `adeb7f7`; later review-stack merges preserve the same application/test source. Flutter 3.47.0, Dart 3.13.0, JDK 17, Gradle 9.1.0, AGP 9.0.1, Android API 36. Command from `android/`:

```powershell
$env:JAVA_HOME='C:\Users\dell\.gradle\jdks\eclipse_adoptium-17-amd64-windows.2'
$env:PATH="$env:JAVA_HOME\bin;$env:PATH"
.\gradlew.bat assembleDebug assembleRelease bundleRelease --offline --no-daemon --max-workers=2
```

Result: **BUILD SUCCESSFUL**, 316 tasks (62 executed, 254 up-to-date), release lint passed.

| Artifact | Workspace path | Bytes | SHA-256 |
|---|---|---:|---|
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` | 173,973,629 | `04BA078D3824D7750D07221824D34046F5C337FB6E6A8AEC5F3951617C6081AE` |
| Release APK, unsigned | `build/app/outputs/flutter-apk/app-release.apk` | 54,439,288 | `8BDFFAA52A96198FD783027D81A21D6ACCE3DD40F7384438D338C015B5944EBB` |
| Release AAB, unsigned | `build/app/outputs/bundle/release/app-release.aab` | 53,266,573 | `D891215A2B2292141D02336B18DBDF6650C748877A73461C6E6030D7BF08B138` |

Paths are relative to `E:\Games\PuzzleForge`. Generated binaries remain ignored, outside the PRs.

`aapt dump badging` confirms launcher label **Puzzle Path**, retained application ID `com.sanskarin.puzzleforge`, version 0.1.0/code 1, min SDK 24, and target SDK 36. `apksigner verify --verbose` verifies the debug APK with one v2 signer. It correctly rejects the unsigned release APK with `Missing META-INF/MANIFEST.MF`; `jarsigner -verify` reports the AAB is unsigned.

Only the debug APK is suitable for installation in this state. The unsigned release APK cannot be installed, and neither unsigned release artifact is ready for store distribution. No upload key was created or supplied. The required-signing negative check with `-PrequireReleaseSigning=true` correctly fails before compilation when `android/key.properties` is absent. See [the signing procedure](android_release.md).

No Android device was connected. Build, manifest, and signature inspection do not replace integration, accessibility, orientation, lifecycle, or profile performance tests on devices. Gradle emitted existing legacy Kotlin/DSL and SDK XML warnings; migration is tracked separately.

## Historical verification — 2 September 2026

The following earlier hashes are retained for traceability; they are not the current Puzzle Path builds. Verified from the release-hardening series ending at `1cb205e`.

## Local outputs

These files are generated under the ignored `build/` directory and are available in the workspace:

| Artifact | Absolute path | Size | SHA-256 |
|---|---|---:|---|
| Debug APK | `E:\Games\PuzzleForge\build\app\outputs\flutter-apk\app-debug.apk` | 156,669,243 bytes | `BC1BBC613A88F366C7828C839F0B1796ACFF81AF5C7B17DA5A21E9B73564DFAC` |
| Release APK (unsigned) | `E:\Games\PuzzleForge\build\app\outputs\flutter-apk\app-release.apk` | 54,422,872 bytes | `F89D738AD45DD91C0F4DC383EE832C00EBFF427331C992A868B6413D9CF71975` |
| Release AAB (unsigned) | `E:\Games\PuzzleForge\build\app\outputs\bundle\release\app-release.aab` | 53,221,934 bytes | `52FB57F21051C35A93FBC88DA9B193C0E8353D05777D26921ACFE6B88A64EC6A` |

Only the debug APK can be installed in this unsigned-output set. The release APK/AAB are not production-signed. Do not upload them to Google Play. Configure a protected upload keystore, rebuild, and verify the signed bundle before distribution.

`apksigner verify --verbose` was run against the release APK and correctly reported `DOES NOT VERIFY` with `Missing META-INF/MANIFEST.MF`; the unsigned state is intentional and is a release gate, not a build failure.

## Reproducible command

From `android/`, select JDK 17 and use the populated Gradle cache:

```powershell
$env:JAVA_HOME='C:\Users\dell\.gradle\jdks\eclipse_adoptium-17-amd64-windows.2'
$env:PATH="$env:JAVA_HOME\bin;$env:PATH"
.\gradlew.bat assembleDebug assembleRelease bundleRelease --no-daemon --offline
```

The build completed successfully with Flutter 3.47.0, Gradle 9.1.0, AGP 9.0.1, and Android API 36 tooling. The Android SDK emitted non-fatal SDK XML/package-location warnings; they do not change the artifact hashes above. JDK 17 is required in this workspace because the available JDK 26 fails Android's `JdkImageTransform` during Flutter/AGP compilation.
