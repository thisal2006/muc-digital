plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.muc_digital"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // ────────────────────────────────────────────────
    // FIXED: both Java and Kotlin now use Java 17
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        jvmToolchain(17)           // ← modern & recommended way
    }

    // You can keep jvmTarget if you prefer old style, but toolchain is better
    // kotlinOptions {
    //     jvmTarget = "17"
    // }
    // ────────────────────────────────────────────────

    defaultConfig {
        applicationId = "com.example.muc_digital"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}