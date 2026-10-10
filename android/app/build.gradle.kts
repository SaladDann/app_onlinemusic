
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.offline_music"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.offline_music"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
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
    source = "../.."
}

dependencies {
    // Todos los módulos Media3 deben usar la misma versión.
    implementation("androidx.media3:media3-exoplayer:1.9.3")
    implementation("androidx.media3:media3-session:1.9.3")

    // Compatibilidad con la biblioteca AndroidX Media existente.
    implementation("androidx.media:media:1.7.0")

    // Decodificadores FFmpeg de NextLib, incluido ALAC.
    implementation("io.github.anilbeesetti:nextlib-media3ext:1.9.3-0.12.0")
}
