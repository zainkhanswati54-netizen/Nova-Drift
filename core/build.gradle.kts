plugins {
    id("java-library")
    kotlin("jvm")
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlin {
    jvmToolchain(17)
}

dependencies {
    val gdx = project.findProperty("gdxVersion") as String? ?: "1.12.1"
    implementation("com.badlogicgames.gdx:gdx:$gdx")
}
