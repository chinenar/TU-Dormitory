// ✅ Buildscript ต้องอยู่ด้านบนสุด
buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal() // ✅ เพิ่มแหล่งโหลด plugin
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0") // ✅ ใช้เวอร์ชันที่ถูกต้อง
        classpath("com.google.gms:google-services:4.3.15") // ✅ ใช้เวอร์ชันที่ถูกต้อง
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ แก้โครงสร้าง build directory ให้ถูกต้อง
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    project.evaluationDependsOn(":app") // ✅ ต้องอยู่ภายใน `subprojects {}` เดียวกัน
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
