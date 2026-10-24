import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadKeyFile = rootProject.file("key.properties")
val uploadKey = Properties()
if (uploadKeyFile.exists()) {
    uploadKeyFile.inputStream().use { uploadKey.load(it) }
    for (name in listOf("storeFile", "storePassword", "keyAlias", "keyPassword")) {
        require(!uploadKey.getProperty(name).isNullOrBlank()) {
            "Missing $name in android/key.properties"
        }
    }
    require(rootProject.file(uploadKey.getProperty("storeFile")).isFile) {
        "Upload keystore file does not exist"
    }
}
require(!providers.gradleProperty("requireReleaseSigning").map { it.toBoolean() }.getOrElse(false) || uploadKeyFile.exists()) {
    "Release signing is required. Configure the protected android/key.properties file first."
}

android {
    namespace = "com.sanskarin.puzzleforge"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.sanskarin.puzzleforge"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (uploadKeyFile.exists()) {
            create("release") {
                storeFile = rootProject.file(uploadKey.getProperty("storeFile"))
                storePassword = uploadKey.getProperty("storePassword")
                keyAlias = uploadKey.getProperty("keyAlias")
                keyPassword = uploadKey.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            if (uploadKeyFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Flutter regenerates the Android plugin registrant during every build. Keep
// the app-owned version in a tracked template and copy it after Flutter's
// generation task so release builds remain independent of debug-only plugins.
val generatedPluginRegistrant = file("src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java")
val pluginRegistrantTemplate = file("registrant/GeneratedPluginRegistrant.java")
val restorePluginRegistrant = tasks.register("restoreGeneratedPluginRegistrant") {
    inputs.file(pluginRegistrantTemplate)
    outputs.file(generatedPluginRegistrant)
    outputs.upToDateWhen { false }
    doLast {
        pluginRegistrantTemplate.copyTo(generatedPluginRegistrant, overwrite = true)
    }
}
tasks.matching { it.name.startsWith("compileFlutterBuild") }.configureEach {
    finalizedBy(restorePluginRegistrant)
}
tasks.matching {
    it.name.contains("compile", ignoreCase = true) &&
        (it.name.contains("Kotlin") || it.name.contains("JavaWithJavac"))
}.configureEach {
    dependsOn(restorePluginRegistrant)
    mustRunAfter(restorePluginRegistrant)
}
