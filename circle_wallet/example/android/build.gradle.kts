allprojects {
    repositories {
        google()
        mavenCentral()

        // Circle Programmable Wallet SDK repository
        val properties = java.util.Properties().apply {
            load(File(rootProject.projectDir, "local.properties").inputStream())
        }

        val mavenUrl = properties.getProperty("pwsdk.maven.url")
            ?: error("pwsdk.maven.url not found in local.properties")

        maven {
            url = uri(mavenUrl)
            credentials {
                username = properties.getProperty("pwsdk.maven.username").orEmpty()
                password = properties.getProperty("pwsdk.maven.password").orEmpty()
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}