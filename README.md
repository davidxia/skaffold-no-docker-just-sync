## Problem Statement

This is a minimal working example of using skaffold to sync local files to remote containers without rebuilding images
and restarting containers between skaffold invocations. Local Docker daemon isn't required.

Use case: My users are ML researchers who write Python. They already have pre-built images.
They just need to start a remote env (sometimes with GPUs), sync code from local, connect their
IDEs, and run that code in the remote environment. These remote envs should persist between
invocations of skaffold.

This repo uses a Docker hub alpine image and deploys to GKE. At time of writing:

* skaffold: v1.35.1
* kubectl (not sure if skaffold is using its own kubectl binary): v1.19.14
* GKE cluster running 1.20.10-gke.1600 on master and nodes

## How to use

`skaffold dev --tag 3.15.0-rc.4 --cleanup=false --label skaffold.dev/run-id=fixed`

skaffold will create the K8s Deployment if it doesn't exist. If one does and has the label `skaffold.dev/run-id=fixed`,
skaffold will sync to the existing Pod.

### Updates

* Found a hacky way using post-deploy hook and `touch` to force an initial sync of all relevant files.

### TODOs and Questions (in order of importance)

1. In inferred file syncing mode, skaffold doesn't sync empty directories or deletions of files and dirs. Is this expected?
2. "Inferred sync mode only applies to modified and added files. File deletion will always cause a complete
   rebuild." [inferred-sync-docs]. Looks like I've fortunately avoided this behavior. skaffold will still deploy my K8s
   manifests, but the Pods aren't recreated since nothing's changed from K8s' point of view. Is this workaround too
   brittle? Why does skaffold do this? Is there a way to disable this behavior or even better sync the deletions? 
3. How to make skaffold use the tag and digest in my K8s YAML? No combination of `--tag` and `--digest-source` works
   with file syncing. Having tag and digest in manifest with `--digest-source none` fails to sync.

   ```
   skaffold dev --digest-source none --cleanup=false --label skaffold.dev/run-id=fixed

   Listing files to watch...
    - alpine
   Tags used in deployment:
   Starting deploy...
    - deployment.apps/dxia-test created
   Waiting for deployments to stabilize...
    - dxia:deployment/dxia-test is ready.
   Deployments stabilized in 2.394 seconds
   Starting post-deploy hooks...
   Completed post-deploy hooks
   Waiting for deployments to stabilize...
   Deployments stabilized in 273.562542ms
   Press Ctrl+C to exit
   WARN[0006] error adding dirty artifact to changeset: could not find latest tag for image alpine in builds: []  subtask=-1 task=DevLoop
   Watching for changes...
   WARN[0019] error adding dirty artifact to changeset: could not find latest tag for image alpine in builds: []  subtask=-1 task=DevLoop
   WARN[0038] error adding dirty artifact to changeset: could not find latest tag for image alpine in builds: []  subtask=-1 task=DevLoop
   ```

   Having a digest in the manifest that doesn't match the digest skaffold determines fails to sync because skaffold is
   looking for a container with the digest it determined.

   ```
   skaffold dev --tag 3.15.0-rc.4 --cleanup=false --label skaffold.dev/run-id=fixed                                                                (base) ⮂ 10:40:43 ⮂ 2021-12-04
   Listing files to watch...
    - alpine
   Generating tags...
    - alpine -> alpine:3.15.0-rc.4
   Checking cache...
    - alpine: Found Remotely
   Tags used in deployment:
    - alpine -> alpine:3.15.0-rc.4@sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add
   Starting deploy...
    - deployment.apps/dxia-test created
   Waiting for deployments to stabilize...
    - dxia:deployment/dxia-test is ready.
   Deployments stabilized in 2.371 seconds
   Starting post-deploy hooks...
   Completed post-deploy hooks
   Waiting for deployments to stabilize...
   Deployments stabilized in 298.415833ms
   Press Ctrl+C to exit
   Watching for changes...
   Syncing 3 files for alpine:3.15.0-rc.4@sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add
   Watching for changes...
   Syncing 1 files for alpine:3.15.0-rc.4@sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add
   WARN[0039] Skipping deploy due to sync error:copying files: didn't sync any files  subtask=-1 task=DevLoop
   Watching for changes...
   ```

   The only way to have a tag and digest in the manifest is to use the exact same ones skaffold uses to sync for a given
   tag you pass to `--tag`.
5. What are the implications of `touch`ing everything?
6. Is it possible to not have a Dockerfile and still configure which files skaffold should ignore for file sync?
   Currently a Dockerfile is used to configure the target directory skaffold syncs to and which files to exclude. See
   comments in Dockerfile. **Seems like no?**
7. skaffold is using `alpine:3.15.0-rc.4@sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add`. But I
   don't see that digest for the [3.15.0-rc.4 tag here](https://hub.docker.com/_/alpine?tab=tags). Any idea where that
   digest is coming from? `crane digest alpine:3.15.0-rc.4`
   returns `sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add` but this isn't the digest for the
   tag on Docker Hub.
8. Will the current weird skaffold usage have problems with future updates?
