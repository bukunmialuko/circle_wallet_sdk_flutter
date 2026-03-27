import java.io.FileInputStream
import java.util.Properties

val circlefinMavenProperties = Properties()
val circlefinMavenPropertiesFile = rootProject.file("circlefin-maven.properties")
if (circlefinMavenPropertiesFile.exists()) {
    circlefinMavenProperties.load(FileInputStream(circlefinMavenPropertiesFile))
}

allprojects {
    repositories {
        google()
        mavenCentral()

        // Circle Programmable Wallet SDK repository
        maven {
            if (!System.getenv("PWSDK_MAVEN_URL").isNullOrBlank()) {
                url = uri(System.getenv("PWSDK_MAVEN_URL")!!)
                credentials {
                    username = System.getenv("PWSDK_MAVEN_USERNAME") ?: ""
                    password = System.getenv("PWSDK_MAVEN_PASSWORD") ?: ""
                }
            } else {
                url = uri(
                    circlefinMavenProperties.getProperty("PWSDK_MAVEN_URL")
                        ?: error(
                            "PWSDK_MAVEN_URL not set. Provide the PWSDK_MAVEN_URL environment " +
                                    "variable or create circle_wallet/example/android/circlefin-maven.properties",
                        ),
                )
                credentials {
                    username = circlefinMavenProperties.getProperty("PWSDK_MAVEN_USERNAME") ?: ""
                    password = circlefinMavenProperties.getProperty("PWSDK_MAVEN_PASSWORD") ?: ""
                }
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