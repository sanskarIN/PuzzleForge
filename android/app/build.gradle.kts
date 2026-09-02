plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
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

    buildTypes {
        release {
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
