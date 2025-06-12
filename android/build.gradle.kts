allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    afterEvaluate {
        if (project.name == "dual_screen") {
            extensions.findByName("android")?.let { ext ->
                ext as com.android.build.gradle.LibraryExtension
                ext.compileSdk = 31
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
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

