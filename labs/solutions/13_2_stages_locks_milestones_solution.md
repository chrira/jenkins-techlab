Solution Lab 13.2: Stages, Locks and Milestones (Scripted Syntax)
=================================================================

Solution for [Lab 13.2: Stages, Locks and Milestones (Scripted Syntax)](../13_stages_locks_milestones.md#lab-132-stages-locks-and-milestones-scripted-syntax)

Create a new branch named lab-13.2 from branch lab-12.2 and change the contents of the Jenkinsfile to:

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
            env.ARTIFACT = "${env.JOB_NAME.split('/')[0]}-hello"
            env.REPO_URL = 'https://artifactory.puzzle.ch/artifactory/ext-release-local'
            node(env.JOB_NAME.split('/')[0]) {
                stage('Build') {
                    milestone(10)  // The first milestone step starts tracking concurrent build order
                    withEnv(["JAVA_HOME=${tool 'jdk8'}", "PATH+MAVEN=${tool 'maven35'}/bin:${env.JAVA_HOME}/bin"]) {
                        checkout scm
                        sh 'mvn -B -V -U -e clean verify -DskipTests'
                    }
                }
                stage('Test') {
                    try {
                        // Only one build is allowed to use test resources, newest builds run first
                        lock(resource: 'myResource', inversePrecedence: true) {  // Lockable Resources Plugin
                            withEnv(["JAVA_HOME=${tool 'jdk8_oracle'}", "PATH+MAVEN=${tool 'maven35'}/bin:${env.JAVA_HOME}/bin"]) {
                                sh 'mvn -B -V -U -e verify -Dsurefire.useFile=false'
                            }
                            milestone(20)  // Abort all older builds that didn't get here
                        }
                    } finally {
                        archiveArtifacts 'target/*.?ar'
                        junit 'target/**/*.xml'  // JUnit Plugin
                    }
                }
                stage('Deploy') {
                    input "Deploy?"
                    milestone(30)  // Abort all older builds that didn't get here
                    withCredentials([
                        file(credentialsId: 'm2_settings', variable: 'M2_SETTINGS'),
                        usernameColonPassword(credentialsId: 'jenkins-artifactory', variable: 'ARTIFACTORY'),
                        file(credentialsId: 'known_hosts', variable: 'KNOWN_HOSTS')
                    ]) {  // Credentials Binding Plugin
                        withEnv(["JAVA_HOME=${tool 'jdk8'}", "PATH+MAVEN=${tool 'maven35'}/bin:${env.JAVA_HOME}/bin"]) {
                            sh "mvn -s '${M2_SETTINGS}' -B deploy:deploy-file -DrepositoryId='puzzle-releases' -Durl='${REPO_URL}' -DgroupId='com.puzzleitc.jenkins-techlab' -DartifactId='${ARTIFACT}' -Dversion='1.0' -Dpackaging='jar' -Dfile=`echo target/*.jar`"
                        }

                        sshagent(['testserver']) {  // SSH Agent Plugin
                            sh "ls -l target"
                            sh "ssh -o UserKnownHostsFile='${KNOWN_HOSTS}' -p 2222 richard@testserver.vcap.me 'curl -O -u \'${ARTIFACTORY}\' ${REPO_URL}/com/puzzleitc/jenkins-techlab/${ARTIFACT}/1.0/${ARTIFACT}-1.0.jar && ls -l'"
                        }
                    }
                }
            }
        }
    }
} finally {
    notifyPuzzleChat()
}
```

---

[← back to Lab 13](../13_stages_locks_milestones.md)
