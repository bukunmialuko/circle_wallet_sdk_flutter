rootProject.name = "circle_wallet_android"

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {

    repositories {
        google()
        mavenCentral()

        // Circle Programmable Wallet SDK repository
        val localPropertiesFile = File(rootDir, "local.properties")

        if (localPropertiesFile.exists()) {
            val properties = java.util.Properties()
            properties.load(localPropertiesFile.inputStream())

            val mavenUrl = properties.getProperty("pwsdk.maven.url")
            val mavenUsername = properties.getProperty("pwsdk.maven.username")
            val mavenPassword = properties.getProperty("pwsdk.maven.password")

            if (!mavenUrl.isNullOrEmpty()) {
                maven {
                    url = uri(mavenUrl)
                    credentials {
                        username = mavenUsername ?: ""
                        password = mavenPassword ?: ""
                    }
                }
            }
        }
    }
}

plugins {
    id("com.android.library") version "8.12.0" apply false
    id("org.jetbrains.kotlin.android") version "2.2.10" apply false
}