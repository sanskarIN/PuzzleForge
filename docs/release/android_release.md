# Android Release Guide

Debug builds use `flutter build apk --debug`. Production distribution uses `flutter build appbundle --release` after a maintainer creates an upload keystore outside the repository and supplies Gradle properties through a protected local or CI environment.

Never commit `.jks`, `.keystore`, `key.properties`, passwords, Play service-account JSON, or upload credentials. Back up the upload key securely and document recovery access privately. Verify package ID, min/target SDK, 64-bit libraries, R8 output, mapping retention, backup policy, network security, Data Safety form, content rating, and Play pre-launch report for every release.
