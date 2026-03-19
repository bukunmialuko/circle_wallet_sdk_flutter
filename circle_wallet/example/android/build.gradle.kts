allprojects {
    repositories {
        google()
        mavenCentral()

        // Circle Programmable Wallet SDK repository
        val mavenUrl = System.getenv("PWSDK_MAVEN_URL")
            ?: error("PWSDK_MAVEN_URL env var is not set. Create ${rootProject.projectDir}/../.env and export it (or set the env vars before running Gradle).")
        maven {
            url = uri(mavenUrl)
            credentials {
                username = System.getenv("PWSDK_MAVEN_USERNAME").orEmpty()
                password = System.getenv("PWSDK_MAVEN_PASSWORD").orEmpty()
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