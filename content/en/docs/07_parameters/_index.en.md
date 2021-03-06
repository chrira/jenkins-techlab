---
title: "7. Build Parameters"
weight: 7
sectionnumber: 7
---


Jobs can be parametrized with user provided input, e.g. to select a deployment target.
When such a job gets started through the web interface a form is presented to the user
where he can provide the necessary arguments.


## Task {{% param sectionnumber %}}.1: Build Parameters (Declarative Syntax)


In declarative pipelines parameters are declared with the ``parameters`` section.
Create a new branch named ``lab-7.1`` from branch ``lab-3.1`` and change the contents of the ``Jenkinsfile`` to:

```groovy
pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 10, unit: 'MINUTES')
        timestamps()  // Requires the "Timestamper Plugin"
    }
    parameters {
        string(name: 'Greetings_to', defaultValue: 'Jenkins Techlab', description: 'Who to greet?')
    }
    stages {
        stage('Greeting') {
            steps {
                echo "Hello, ${params.Greetings_to}!"
            }
        }
    }
}
```

Helper methods like ``string`` or ``booleanParam`` are used to declare the parameter types.
The corresponding documentation should soon be available here: <https://jenkins.io/doc/book/pipeline/syntax/#parameters>.
There is an open issue for the parameter documentation: [INFRA-1053](https://issues.jenkins-ci.org/browse/INFRA-1053).
In the meantime use the snippet generator like described in the next lab to see all available types.

**Note:** Use the "Build with Parameters" action on Jenkins master and change the greetings value. The build log output will show the changed greeting.
