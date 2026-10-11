import java.util.zip.ZipFile

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Validate the delivered APK, not only pubspec or intermediate build outputs.
// A stale/incomplete Flutter bundle must never count as a successful build.
val verifyDebugMaterialIcons = tasks.register("verifyDebugMaterialIcons") {
    dependsOn("packageDebug")
    doLast {
        val apk = layout.buildDirectory.file("outputs/apk/debug/app-debug.apk").get().asFile
        ZipFile(apk).use { archive ->
            val prefix = "assets/flutter_assets/"
            val font = archive.getEntry("${prefix}fonts/MaterialIcons-Regular.otf")
                ?: error("APK is missing MaterialIcons; run flutter clean and rebuild")
            val signature = archive.getInputStream(font).use { it.readNBytes(4) }
            check(signature.contentEquals(byteArrayOf(0x4f, 0x54, 0x54, 0x4f))) {
                "APK contains an invalid MaterialIcons OpenType font"
            }
            val manifest = archive.getEntry("${prefix}FontManifest.json")
                ?: error("APK is missing FontManifest.json")
            val text = archive.getInputStream(manifest).bufferedReader(Charsets.UTF_8).use { it.readText() }
            check(text.contains("MaterialIcons") && text.contains("fonts/MaterialIcons-Regular.otf")) {
                "APK font manifest does not declare MaterialIcons"
            }
            check(archive.getEntry("${prefix}AssetManifest.bin") != null) {
                "APK is missing AssetManifest.bin"
            }
            logger.lifecycle("MaterialIcons APK packaging verification PASS (${font.size} bytes)")
        }
    }
}
tasks.matching { it.name == "assembleDebug" }.configureEach {
    finalizedBy(verifyDebugMaterialIcons)
}

android {
    namespace = "com.geoguideai.geoguide_ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.geoguideai.geoguide_ai"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
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

flutter {
    // Windows junction aliases must not produce two textual paths for the same
    // Flutter output: stale-output cleanup can otherwise delete fresh assets.
    source = file("../..").toPath().toRealPath().toString()
}

// Dependency-free JVM checks for the same policy used by Activity and Service.
tasks.register<JavaExec>("b1PolicyChecks") {
    dependsOn("compileDebugUnitTestJavaWithJavac")
    classpath = files(tasks.named("compileDebugUnitTestJavaWithJavac").map { it.outputs.files },
        tasks.named("compileDebugKotlin").map { it.outputs.files })
    mainClass.set("com.geoguideai.geoguide_ai.B1PolicyChecks")
}

// Executes the actual dependency-free voice controller with observable output doubles.
tasks.register<JavaExec>("c2VoiceChecks") {
    dependsOn("compileDebugUnitTestKotlin")
    classpath = files(tasks.named("compileDebugUnitTestKotlin").map { it.outputs.files },
        tasks.named("compileDebugKotlin").map { it.outputs.files },
        tasks.named("compileDebugUnitTestKotlin").map { (it as org.jetbrains.kotlin.gradle.tasks.KotlinCompile).libraries.filter { file -> file.name.startsWith("kotlin-stdlib") } })
    mainClass.set("com.geoguideai.geoguide_ai.C2VoiceChecks")
}
