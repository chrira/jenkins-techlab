Solution Lab 11.3: Use Shared Library (Scripted Syntax)
=======================================================

Solution for [Lab 11.3: Use Shared Library (Scripted Syntax)](../11_shared_libs.md#lab-113-use-shared-library-scripted-syntax)

Create a new branch named lab-11.3 from branch lab-10.2 and change the contents of the Jenkinsfile to:

```groovy
@Library('jenkins-techlab-libraries') _

properties([
    buildDiscarder(logRotator(numToKeepStr: '5')),
    pipelineTriggers([
        pollSCM('H/5 * * * *')
    ])
])

try {
    timestamps() {
        timeout(time: 10, unit: 'MINUTES') {
            node(env.JOB_NAME.split('/')[0]) {
                stage('Build') {
                    try {
                        withEnv(["JAVA_HOME=${tool 'jdk8_oracle'}", "PATH+MAVEN=${tool 'maven35'}/bin:${env.JAVA_HOME}/bin"]) {
                            checkout scm
                            sh 'mvn -B -V -U -e clean verify -Dsurefire.useFile=false'
                            archiveArtifacts 'target/*.?ar'
                        }
                    } finally {
                        junit 'target/**/*.xml'  // Requires JUnit plugin
                    }
                }
            }

        }
    }
} catch (e) {
    node {
        notifyPuzzleChat('jenkins-techlab')
    }
    throw e
} finally {
    node {
        notifyPuzzleChat('jenkins-techlab')
    }
}
```
**Note:** Check the build log output on the Jenkins master. Search for ``Loading library jenkins-techlab-libraries@master``.
Find also the success message in the jenkins-techlab Rocket.Chat.

---

[← back to Lab 11](../11_shared_libs.md)
