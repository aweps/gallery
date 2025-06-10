import java.io.FileInputStream
import java.util.Base64
import java.util.Properties
import java.io.FileNotFoundException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties().apply {
    val propsFile = rootProject.file("local.properties")
    if (propsFile.exists()) {
        load(FileInputStream(propsFile))
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"
val flutterRoot = localProperties.getProperty("flutter.sdk")
    ?: throw FileNotFoundException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")

val dartDefines = (findProperty("dart-defines") as? String)?.split(",") ?: emptyList()
val dartEnv = mutableMapOf(
    "APP_NAME" to "GalleryApp",
    "APP_SUFFIX" to "gallery"
)
for (entry in dartDefines) {
    val decoded = String(Base64.getDecoder().decode(entry), Charsets.UTF_8)
    val parts = decoded.split("=")
    if (parts.size == 2) {
        dartEnv[parts[0]] = parts[1]
    }
}

android {
    namespace = "com.webkrux.gallery"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.webkrux.${dartEnv["APP_SUFFIX"]}"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        resValue("string", "app_name", dartEnv["APP_NAME"] ?: "GalleryApp")
    }

    signingConfigs {
        create("release") {
            storeFile = file("../../_ops/keystore.jks")
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            keyAlias = "upload"
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }

    lint {
        disable.add("InvalidPackage")
    }

    applicationVariants.all {
        println("Building app variant: ${name}, applicationId: ${applicationId}")
    }
}

flutter {
    source = "../.."
}
