pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP 9.0.1 (released Jan 2026, weeks old at the time this project was
    // scaffolded) fails to build path_provider_android's jni-based Android
    // module — Gradle can't resolve the NDK-related provider it depends on
    // (":jni:compileDebugJavaWithJavac" — "Cannot query the value of this
    // provider because it has no value available"), reproducible on a clean
    // NDK+JDK17 setup. Pinned to a mature, widely-tested AGP/Gradle/Kotlin
    // combination instead — see gradle-wrapper.properties for the paired
    // Gradle version.
    id("com.android.application") version "8.11.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.4.4") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
