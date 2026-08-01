plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.safe_ride_app"
    compileSdk = flutter.compileSdkVersion
    // Pinned explicitly instead of the dynamic `flutter.ndkVersion`. Not
    // strictly required — the ":jni:compileDebugJavaWithJavac" / "Cannot
    // query the value of this provider" failure some machines hit turned out
    // to be caused by the Gradle distribution itself never finishing its
    // download (services.gradle.org redirects to a github.com release asset,
    // which some networks silently reset connections to), not NDK
    // resolution. Left pinned anyway since it's a harmless, deterministic
    // value. If Gradle reports this version isn't installed, install it via
    // Android Studio's SDK Manager > SDK Tools > NDK (side by side), or
    // change this to whatever version you have installed.
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications requires this — it uses java.time APIs
        // that need desugaring to run on older Android API levels.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.safe_ride_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
