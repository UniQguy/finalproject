plugins {
    id("com.android.application")
    // Firebase / Google Services plugin
    id("com.google.gms.google-services")
    id("kotlin-android")
    // Must be after Android and Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.finalproject" // change to your package name
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ Matches Firebase plugins requirement

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.finalproject"
        minSdk = 23
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }



    buildTypes {
        getByName("release") {
            // Temporary debug signing so flutter run --release works
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
    implementation("com.google.firebase:firebase-analytics")
    // Add other Firebase services you're using:
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
