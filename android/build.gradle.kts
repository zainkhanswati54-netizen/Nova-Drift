plugins {
    id("com.android.application")
    kotlin("android")
}

val gdxVersion = project.findProperty("gdxVersion") as String? ?: "1.12.1"

android {
    namespace = "com.novadrift.game"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.novadrift.game"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "0.1.0-alpha"
    }

    sourceSets {
        getByName("main") {
            assets.srcDirs("assets")
            jniLibs.srcDirs("libs")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    packaging {
        resources.excludes.add("META-INF/robovm/ios/robovm.xml")
    }
}

dependencies {
    implementation(project(":core"))

    implementation("com.badlogicgames.gdx:gdx-backend-android:$gdxVersion")
    implementation("com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-armeabi-v7a")
    implementation("com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-arm64-v8a")
    implementation("com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86")
    implementation("com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86_64")
}
