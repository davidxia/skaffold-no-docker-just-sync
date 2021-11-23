## Update

Removing image tag and digest from K8s YAML worked!
Found a way to not have a Dockerfile!
Found a hacky way using post-deploy hook and `touch` to force an initial sync of all relevant files.

### TODOs and Questions

What are the implications of `touch`ing everything?

Is there a way to make skaffold sync to an existing Pod without redeploying and destroying it? Want to keep existing
remote context whenever possible.

skaffold is using `alpine:3.15.0-rc.4@sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add`. But I don't see that
digest for the [3.15.0-rc.4 tag here](https://hub.docker.com/_/alpine?tab=tags). Any idea where that digest is coming
from?

Will the current skaffold.yaml have problems with future updates?

If I restore the image tag and digest in my K8s YAML and
run `skaffold dev --tag 3.15.0-rc.4 --digest-source none --cleanup=false` there's another error.
Is there a way to make skaffold use the tag and digest in my K8s YAML?

```
skaffold dev --tag 3.15.0-rc.4 --digest-source none --cleanup=false

Listing files to watch...
 - alpine
Tags used in deployment:
Starting deploy...
 - deployment.apps/dxia-test configured
Waiting for deployments to stabilize...
 - dxia:deployment/dxia-test is ready.
Deployments stabilized in 3.849 seconds
Press Ctrl+C to exit
Watching for changes...
WARN[0044] error adding dirty artifact to changeset: could not find latest tag for image alpine in builds: []  subtask=-1 task=DevLoop
```

## Original problem statement

This repo provides a minimal repro of a skaffold file syncing issue I'm facing. I want skaffold to
start a pre-built image and sync all local repo files to the remote container. I don't want it to
build any image and don't want a local Docker daemon to be running. It'd be nice to not have to use
a Dockerfile at all either if possible.

I'm using a Docker hub alpine image and deploying to GKE.

platform: Macbook Pro M1
OS: macOS 12.0.1 
skaffold: v1.35.1
kubectl (not sure if skaffold is using its own kubectl binary): v1.19.14
GKE cluster running 1.20.10-gke.1600 on master and nodes

Kube config

```
kubectl config get-contexts
CURRENT   NAME               CLUSTER           AUTHINFO            NAMESPACE
*         my-kube-context    my-kube-context   my-kube-context
```

```
skaffold dev --tag 3.15.0-rc.4 --cleanup=false -v debug

DEBU[0000] skaffold API not starting as it's not requested  subtask=-1 task=DevLoop
INFO[0000] Skaffold &{Version:v1.35.1 ConfigVersion:skaffold/v2beta26 GitVersion: GitCommit:4ec4a23aeac4eab0ec6eaefc5aff459cd59166ba BuildDate:2021-11-18T21:50:13Z GoVersion:go1.17.2 Compiler:gc Platform:darwin/arm64 User:}  subtask=-1 task=DevLoop
INFO[0000] Loaded Skaffold defaults from "/Users/dxia/.skaffold/config"  subtask=-1 task=DevLoop
DEBU[0000] parsed 1 configs from configuration file /private/tmp/skaffold-no-docker-just-sync/skaffold.yaml  subtask=-1 task=DevLoop
INFO[0000] Using kubectl context: my-kube-context  subtask=-1 task=DevLoop
DEBU[0000] Running command: [minikube version --output=json]  subtask=-1 task=DevLoop
DEBU[0000] setting Docker user agent to skaffold-v1.35.1  subtask=-1 task=DevLoop
DEBU[0000] Using builder: local                          subtask=-1 task=DevLoop
DEBU[0000] push value not present in NewBuilder, defaulting to true because cluster.PushImages is true  subtask=-1 task=DevLoop
INFO[0000] build concurrency first set to 1 parsed from *local.Builder[0]  subtask=-1 task=DevLoop
INFO[0000] final build concurrency value is 1            subtask=-1 task=DevLoop
Listing files to watch...
 - alpine
DEBU[0000] Found dependencies for dockerfile: [{. /src/test true 3 3}]  subtask=-1 task=DevLoop
DEBU[0000] Skipping excluded path: .git
INFO[0000] List generated in 798.542µs                   subtask=-1 task=DevLoop
Generating tags...
 - alpine -> alpine:3.15.0-rc.4
INFO[0000] Tags generated in 32.25µs                     subtask=-1 task=Build
Checking cache...
DEBU[0000] FIXME: Got an status-code for which error does not match any expected type!!!: -1  module=api status_code=-1
DEBU[0000] Importing artifact alpine:3.15.0-rc.4 from docker registry  subtask=-1 task=Build
DEBU[0000] FIXME: Got an status-code for which error does not match any expected type!!!: -1  module=api status_code=-1
WARN[0000] failed to get default registry endpoint from daemon (Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?). Using system default: https://index.docker.io/v1/  subtask=-1 task=Build
DEBU[0000] FIXME: Got an status-code for which error does not match any expected type!!!: -1  module=api status_code=-1
DEBU[0000] Could not import artifact from Docker, building instead (pulling image from repository: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?)  subtask=-1 task=Build
 - alpine: Not found. Building
INFO[0000] Cache check completed in 1.778875ms           subtask=-1 task=Build
Starting build...
Building [alpine]...
DEBU[0000] Executing template &{envTemplate 0x14000c37b00 0x140004c6320  } with environment map[COLORFGBG:12;8 COLORTERM:truecolor COMMAND_MODE:unix2003 CONDA_DEFAULT_ENV:base CONDA_EXE:/opt/homebrew/Caskroom/miniforge/base/bin/conda CONDA_PREFIX:/opt/homebrew/Caskroom/miniforge/base CONDA_PROMPT_MODIFIER:(base)  CONDA_PYTHON_EXE:/opt/homebrew/Caskroom/miniforge/base/bin/python CONDA_SHLVL:1 DISPLAY:/private/tmp/com.apple.launchd.lH8eu1FYgA/org.xquartz:0 EDITOR:/usr/bin/vim GOPATH:/Users/dxia/src/go GPG_TTY:/dev/ttys010 HOME:/Users/dxia ITERM_PROFILE:Default ITERM_SESSION_ID:w0t2p2:3FAA49E5-6150-4A03-B94C-22A57927C04D JENV_LOADED:1 JENV_SHELL:fish LANG:en_US.UTF-8 LC_TERMINAL:iTerm2 LC_TERMINAL_VERSION:3.4.12 LOGNAME:dxia PATH:/opt/homebrew/Caskroom/miniforge/base/bin:/opt/homebrew/Caskroom/miniforge/base/condabin:/Users/dxia/.jenv/shims:/Users/dxia/.jenv/shims:/Users/dxia/.rbenv/shims:/Users/dxia/google-cloud-sdk/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/Users/dxia/.pyenv/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/sbin:/usr/local/opt/fzf/bin:/opt/homebrew/opt/fzf/bin PWD:/tmp/skaffold-no-docker-just-sync PYENV_ROOT:/Users/dxia/.pyenv RBENV_SHELL:fish SHELL:/opt/homebrew/bin/fish SHLVL:1 SSH_AUTH_SOCK:/Users/dxia/.gnupg/S.gpg-agent.ssh TERM:xterm-256color TERM_PROGRAM:iTerm.app TERM_PROGRAM_VERSION:3.4.12 TERM_SESSION_ID:w0t2p2:3FAA49E5-6150-4A03-B94C-22A57927C04D TMPDIR:/var/folders/x1/f9sjnv7j43z73sdv5lsk3r8h0000gp/T/ USER:dxia WECHALLTOKEN:73A44-C8B2C-3257E-36352-EF117-85CE3 WECHALLUSER:sobriquet XPC_FLAGS:0x0 XPC_SERVICE_NAME:0 _CE_CONDA: _CE_M: __CFBundleIdentifier:com.googlecode.iterm2 __CF_USER_TEXT_ENCODING:0x1F6:0x0:0x0 fish_user_paths:/opt/homebrew/sbin /opt/homebrew/bin /Users/dxia/.pyenv/bin /usr/local/bin /usr/bin /bin /usr/sbin /sbin /opt/X11/bin /usr/local/sbin /usr/local/opt/fzf/bin /opt/homebrew/opt/fzf/bin]  subtask=-1 task=DevLoop
DEBU[0000] Running command: [sh -c echo]                 subtask=alpine task=Build

INFO[0000] Build completed in 596.543084ms               subtask=-1 task=Build
DEBU[0000] push value not present in isImageLocal(), defaulting to true because cluster.PushImages is true  subtask=-1 task=DevLoop
Tags used in deployment:
 - alpine -> alpine:3.15.0-rc.4@sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add
DEBU[0000] push value not present in isImageLocal(), defaulting to true because cluster.PushImages is true  subtask=-1 task=DevLoop
Starting deploy...
DEBU[0000] getting client config for kubeContext: `my-kube-context`  subtask=-1 task=DevLoop
DEBU[0000] Running command: [kubectl version --client -ojson]  subtask=0 task=Deploy
DEBU[0001] Command output: [{
  "clientVersion": {
    "major": "1",
    "minor": "20+",
    "gitVersion": "v1.20.8-dispatcher",
    "gitCommit": "283881f025da4f5b3cefb6cd4c35f2ee4c2a79b8",
    "gitTreeState": "clean",
    "buildDate": "2021-09-14T05:14:54Z",
    "goVersion": "go1.15.13",
    "compiler": "gc",
    "platform": "darwin/amd64"
  }
}
]  subtask=0 task=Deploy
DEBU[0001] Running command: [kubectl --context my-kube-context create --dry-run=client -oyaml -f /tmp/skaffold-no-docker-just-sync/skaffold/deployment.yaml]  subtask=0 task=Deploy
DEBU[0002] Command output: [apiVersion: apps/v1
kind: Deployment
metadata:
  name: dxia-test
  namespace: dxia
spec:
  replicas: 1
  selector:
    matchLabels:
      name: dxia-test
  template:
    metadata:
      labels:
        name: dxia-test
    spec:
      containers:
      - args:
        - while true; do sleep 30; done;
        command:
        - /bin/sh
        - -c
        - --
        image: alpine:3.15.0-rc.4@sha256:3eea5acfa729637baeedf1059a2a03d5a29356aac6baf65fea08762afa72321b
        name: dxia-test
]  subtask=0 task=Deploy
DEBU[0002] image [alpine] is not used by the current deployment  subtask=-1 task=DevLoop
DEBU[0002] manifests with tagged images:apiVersion: apps/v1
kind: Deployment
metadata:
  name: dxia-test
  namespace: dxia
spec:
  replicas: 1
  selector:
    matchLabels:
      name: dxia-test
  template:
    metadata:
      labels:
        name: dxia-test
    spec:
      containers:
      - args:
        - while true; do sleep 30; done;
        command:
        - /bin/sh
        - -c
        - --
        image: alpine:3.15.0-rc.4@sha256:3eea5acfa729637baeedf1059a2a03d5a29356aac6baf65fea08762afa72321b
        name: dxia-test  subtask=0 task=Deploy
DEBU[0002] manifests with labels apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    skaffold.dev/run-id: a87ec8b1-de12-4bb1-bfa3-99f8f5e5c30f
  name: dxia-test
  namespace: dxia
spec:
  replicas: 1
  selector:
    matchLabels:
      name: dxia-test
  template:
    metadata:
      labels:
        name: dxia-test
        skaffold.dev/run-id: a87ec8b1-de12-4bb1-bfa3-99f8f5e5c30f
    spec:
      containers:
      - args:
        - while true; do sleep 30; done;
        command:
        - /bin/sh
        - -c
        - --
        image: alpine:3.15.0-rc.4@sha256:3eea5acfa729637baeedf1059a2a03d5a29356aac6baf65fea08762afa72321b
        name: dxia-test  subtask=-1 task=DevLoop
DEBU[0002] Running command: [kubectl --context my-kube-context get -f - --ignore-not-found -ojson]  subtask=0 task=Deploy
DEBU[0003] Command output: [{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "4",
                    "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"apps/v1\",\"kind\":\"Deployment\",\"metadata\":{\"annotations\":{},\"labels\":{\"skaffold.dev/run-id\":\"e6251b3d-f9f1-46cb-960e-c129e1dc3a50\"},\"name\":\"dxia-test\",\"namespace\":\"dxia\"},\"spec\":{\"replicas\":1,\"selector\":{\"matchLabels\":{\"name\":\"dxia-test\"}},\"template\":{\"metadata\":{\"labels\":{\"name\":\"dxia-test\",\"skaffold.dev/run-id\":\"e6251b3d-f9f1-46cb-960e-c129e1dc3a50\"}},\"spec\":{\"containers\":[{\"args\":[\"while true; do sleep 30; done;\"],\"command\":[\"/bin/sh\",\"-c\",\"--\"],\"image\":\"alpine:3.15.0-rc.4@sha256:3eea5acfa729637baeedf1059a2a03d5a29356aac6baf65fea08762afa72321b\",\"name\":\"dxia-test\"}]}}}}\n"
                },
                "creationTimestamp": "2021-11-23T17:27:03Z",
                "generation": 4,
                "labels": {
                    "skaffold.dev/run-id": "e6251b3d-f9f1-46cb-960e-c129e1dc3a50"
                },
                "managedFields": [
                    {
                        "apiVersion": "apps/v1",
                        "fieldsType": "FieldsV1",
                        "fieldsV1": {
                            "f:metadata": {
                                "f:annotations": {
                                    ".": {},
                                    "f:kubectl.kubernetes.io/last-applied-configuration": {}
                                },
                                "f:labels": {
                                    ".": {},
                                    "f:skaffold.dev/run-id": {}
                                }
                            },
                            "f:spec": {
                                "f:progressDeadlineSeconds": {},
                                "f:replicas": {},
                                "f:revisionHistoryLimit": {},
                                "f:selector": {
                                    "f:matchLabels": {
                                        ".": {},
                                        "f:name": {}
                                    }
                                },
                                "f:strategy": {
                                    "f:rollingUpdate": {
                                        ".": {},
                                        "f:maxSurge": {},
                                        "f:maxUnavailable": {}
                                    },
                                    "f:type": {}
                                },
                                "f:template": {
                                    "f:metadata": {
                                        "f:labels": {
                                            ".": {},
                                            "f:name": {},
                                            "f:skaffold.dev/run-id": {}
                                        }
                                    },
                                    "f:spec": {
                                        "f:containers": {
                                            "k:{\"name\":\"dxia-test\"}": {
                                                ".": {},
                                                "f:args": {},
                                                "f:command": {},
                                                "f:image": {},
                                                "f:imagePullPolicy": {},
                                                "f:name": {},
                                                "f:resources": {},
                                                "f:terminationMessagePath": {},
                                                "f:terminationMessagePolicy": {}
                                            }
                                        },
                                        "f:dnsPolicy": {},
                                        "f:restartPolicy": {},
                                        "f:schedulerName": {},
                                        "f:securityContext": {},
                                        "f:terminationGracePeriodSeconds": {}
                                    }
                                }
                            }
                        },
                        "manager": "kubectl-client-side-apply",
                        "operation": "Update",
                        "time": "2021-11-23T17:27:03Z"
                    },
                    {
                        "apiVersion": "apps/v1",
                        "fieldsType": "FieldsV1",
                        "fieldsV1": {
                            "f:metadata": {
                                "f:annotations": {
                                    "f:deployment.kubernetes.io/revision": {}
                                }
                            },
                            "f:status": {
                                "f:availableReplicas": {},
                                "f:conditions": {
                                    ".": {},
                                    "k:{\"type\":\"Available\"}": {
                                        ".": {},
                                        "f:lastTransitionTime": {},
                                        "f:lastUpdateTime": {},
                                        "f:message": {},
                                        "f:reason": {},
                                        "f:status": {},
                                        "f:type": {}
                                    },
                                    "k:{\"type\":\"Progressing\"}": {
                                        ".": {},
                                        "f:lastTransitionTime": {},
                                        "f:lastUpdateTime": {},
                                        "f:message": {},
                                        "f:reason": {},
                                        "f:status": {},
                                        "f:type": {}
                                    }
                                },
                                "f:observedGeneration": {},
                                "f:readyReplicas": {},
                                "f:replicas": {},
                                "f:updatedReplicas": {}
                            }
                        },
                        "manager": "kube-controller-manager",
                        "operation": "Update",
                        "time": "2021-11-23T17:31:41Z"
                    }
                ],
                "name": "dxia-test",
                "namespace": "dxia",
                "resourceVersion": "95161986",
                "selfLink": "/apis/apps/v1/namespaces/dxia/deployments/dxia-test",
                "uid": "c8b78d9c-ed75-4430-8c6c-cf8efc7eb28a"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "name": "dxia-test"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": "25%"
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "name": "dxia-test",
                            "skaffold.dev/run-id": "e6251b3d-f9f1-46cb-960e-c129e1dc3a50"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "args": [
                                    "while true; do sleep 30; done;"
                                ],
                                "command": [
                                    "/bin/sh",
                                    "-c",
                                    "--"
                                ],
                                "image": "alpine:3.15.0-rc.4@sha256:3eea5acfa729637baeedf1059a2a03d5a29356aac6baf65fea08762afa72321b",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "dxia-test",
                                "resources": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                }
            },
            "status": {
                "availableReplicas": 1,
                "conditions": [
                    {
                        "lastTransitionTime": "2021-11-23T17:27:07Z",
                        "lastUpdateTime": "2021-11-23T17:27:07Z",
                        "message": "Deployment has minimum availability.",
                        "reason": "MinimumReplicasAvailable",
                        "status": "True",
                        "type": "Available"
                    },
                    {
                        "lastTransitionTime": "2021-11-23T17:27:03Z",
                        "lastUpdateTime": "2021-11-23T17:31:41Z",
                        "message": "ReplicaSet \"dxia-test-5b4bcffbc6\" has successfully progressed.",
                        "reason": "NewReplicaSetAvailable",
                        "status": "True",
                        "type": "Progressing"
                    }
                ],
                "observedGeneration": 4,
                "readyReplicas": 1,
                "replicas": 1,
                "updatedReplicas": 1
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
]  subtask=0 task=Deploy
DEBU[0003] 1manifests to deploy.1are updated or new      subtask=0 task=Deploy
DEBU[0003] Running command: [kubectl --context my-kube-context apply -f -]  subtask=0 task=Deploy
 - deployment.apps/dxia-test configured
INFO[0004] Deploy completed in 3.876 seconds             subtask=-1 task=Deploy
Waiting for deployments to stabilize...
DEBU[0004] getting client config for kubeContext: `my-kube-context`  subtask=-1 task=DevLoop
DEBU[0004] getting client config for kubeContext: `my-kube-context`  subtask=-1 task=DevLoop
DEBU[0004] checking status dxia:deployment/dxia-test     subtask=-1 task=Deploy
DEBU[0005] Running command: [kubectl --context my-kube-context rollout status deployment dxia-test --namespace dxia --watch=false]  subtask=-1 task=Deploy
DEBU[0007] Command output: [deployment "dxia-test" successfully rolled out
]  subtask=-1 task=Deploy
 - dxia:deployment/dxia-test is ready.
Deployments stabilized in 2.531 seconds
DEBU[0007] getting client config for kubeContext: `my-kube-context`  subtask=-1 task=DevLoop
Press Ctrl+C to exit
DEBU[0007] Change detected<nil>                          subtask=-1 task=DevLoop
Watching for changes...
DEBU[0008] Found dependencies for dockerfile: [{. /src/test true 3 3}]  subtask=-1 task=DevLoop
DEBU[0008] Skipping excluded path: .git
```

In another terminal

```
echo foo >> foo
```

in original terminal

```
DEBU[0017] Change detectednotify.Write: "/private/tmp/skaffold-no-docker-just-sync/foo"  subtask=-1 task=DevLoop
DEBU[0017] Change detectednotify.Remove: "/private/tmp/skaffold-no-docker-just-sync/.git/index.lock"  subtask=-1 task=DevLoop
DEBU[0017] Change detectednotify.Create: "/private/tmp/skaffold-no-docker-just-sync/.git/index.lock"  subtask=-1 task=DevLoop
DEBU[0018] Found dependencies for dockerfile: [{. /src/test true 3 3}]  subtask=-1 task=DevLoop
DEBU[0018] Skipping excluded path: .git
INFO[0018] files modified: [foo]                         subtask=-1 task=DevLoop
DEBU[0018] Found dependencies for dockerfile: [{. /src/test true 3 3}]  subtask=-1 task=DevLoop
DEBU[0018] Skipping excluded path: .git
DEBU[0018]  devloop: build false, sync true, deploy false  subtask=-1 task=DevLoop
Syncing 1 files for alpine:3.15.0-rc.4@sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add
INFO[0018] Copying files:map[foo:[/src/test/foo]]toalpine:3.15.0-rc.4@sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add  subtask=-1 task=DevLoop
DEBU[0018] getting client config for kubeContext: `my-kube-context`  subtask=-1 task=DevLoop
WARN[0018] Skipping deploy due to sync error:copying files: didn't sync any files  subtask=-1 task=DevLoop
Watching for changes...
```
