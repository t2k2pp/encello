plugins {
    id("com.android.application")
    // Kotlin は AGP 9 の built-in Kotlin でコンパイルする（KGP は適用しない）。
    // [Docs/08_platform_setup.md] §2
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.encello.encello"
    // compileSdk は 37 に固定する（Flutter 既定の 36 にしない）。
    // receive_sharing_intent 1.9.0 の AAR メタデータが compileSdk>=37 を要求するため。
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications が java.time 等の desugaring を要求する（FR-88）。
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.encello.encello"
        // flutter_tts の voice 選択 API と対象端末の想定に合わせて Android 8.0 を最低とする。
        // [Docs/08_platform_setup.md] §2
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // リリース署名は android/key.properties から読む（[Docs/08_platform_setup.md] §2.6）。
            // ストア提出までの間はデバッグ鍵で `flutter run --release` が通る状態にとどめる。
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// built-in Kotlin（AGP 9）の Kotlin コンパイル設定。android{} の外に置く。
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // flutter_local_notifications v22+ は desugar_jdk_libs 2.1.4 以上を要求する。
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
