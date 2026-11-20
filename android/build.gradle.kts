allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// ✅ নতুন অংশ: device_apps প্যাকেজে namespace সেট করা
subprojects {
    afterEvaluate {
        if (project.name == "device_apps") {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                namespace = "fr.g123k.deviceapps"
            }
        }
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}