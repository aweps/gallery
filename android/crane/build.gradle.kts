import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.dynamic-feature")
    id("kotlin-android")
    id("com.google.firebase.crashlytics") version "2.9.9"
}

val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

android {
    namespace = "com.webkrux.gallery.crane"
    compileSdk = 31

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    // Note: applicationVariants is not available in sourceSets in Kotlin DSL.
    // Use android.applicationVariants.all in afterEvaluate if needed.
    sourceSets {
        getByName("main") {
            // These will be set up in a Gradle task, not here.
        }
    }

    defaultConfig {
        minSdk = 21
    }
}

dependencies {
    implementation(project(":app"))
}