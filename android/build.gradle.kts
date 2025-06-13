allprojects {
    repositories {
        google()
        mavenCentral()
    }

    afterEvaluate {
        if (project.name == "dual_screen") {
            extensions.findByName("android")?.let {
                (it as com.android.build.gradle.LibraryExtension).compileSdk = 31
            }
        }
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    layout.buildDirectory.value(newBuildDir.dir(name))
    evaluationDependsOn(":app")

    configurations.all {
        resolutionStrategy {
            force("org.jetbrains.kotlin:kotlin-stdlib:1.8.22")
            force("org.jetbrains.kotlin:kotlin-stdlib-common:1.8.22")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
