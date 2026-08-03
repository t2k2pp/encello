pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP 9 の built-in Kotlin を使うため KGP（org.jetbrains.kotlin.android）は適用しない。
    // compileSdk 37 はマイナーバージョン方式（android-37.0）配布のため 9.1.1 以上が要る。
    // [Docs/08_platform_setup.md] §2
    id("com.android.application") version "9.2.1" apply false
}

include(":app")
