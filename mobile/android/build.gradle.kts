allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Resolve an existing parent before appending build (which may not exist after
// flutter clean). Flutter depfiles and explicit outputs must use the same path
// when the workspace is opened through a Windows junction.
val newBuildDir = rootProject.layout.projectDirectory.asFile.toPath()
    .toRealPath().parent.resolve("build").toFile()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.resolve(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
