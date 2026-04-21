allprojects {
    repositories {
        google()
        mavenCentral()
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

subprojects {
    afterEvaluate {
        val extension = project.extensions.findByName("android")
        if (extension != null) {
            try {
                val getNamespace = extension::class.java.getMethod("getNamespace")
                val setNamespace = extension::class.java.getMethod("setNamespace", String::class.java)
                
                if (getNamespace.invoke(extension) == null) {
                    // Fallback to project group or a generated name
                    val namespace = project.group.toString().takeIf { it.isNotEmpty() } 
                        ?: "com.fix.namespace.${project.name.replace("-", "_")}"
                    setNamespace.invoke(extension, namespace)
                    println("Forcing namespace '$namespace' for project '${project.name}'")
                }
            } catch (e: Exception) {
                // Ignore if methods don't exist
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
