import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.dynamic-feature")
    id("kotlin-android")
}

android {
    namespace = "com.webkrux.gallery.crane"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        minSdk = 21
        // Remove versionCode and versionName - they're inherited from the base app
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    implementation(project(":app"))
}