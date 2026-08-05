plugins {
    id("java-library")
    kotlin("jvm")
}

sourceCompatibility = JavaVersion.VERSION_17
targetCompatibility = JavaVersion.VERSION_17

val gdxVersion: String by rootProject.extra.properties.withDefault { "1.12.1" }

dependencies {
    val gdx = project.findProperty("gdxVersion") as String? ?: "1.12.1"
    implementation("com.badlogicgames.gdx:gdx:$gdx")
}
