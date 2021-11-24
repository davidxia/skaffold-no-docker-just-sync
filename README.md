## Problem Statement

This repo provides a minimal repro of a skaffold file syncing issue I'm facing. I want skaffold to
sync local files to the remote containers. I need it to be able to start new ones **and find
existing ones without restarting them**. I don't want it to build any image and don't want a local
Docker daemon to be running. It'd be nice to not have to use a Dockerfile at all either if possible.

Use case: My users are ML researchers who write Python. They already have pre-built images.
They just need to start a remote env (sometimes with GPUs), sync code from local, connect their
IDEs, and run that code in the remote environment. These remote envs should persist between
invocations of skaffold.

This repo uses a Docker hub alpine image and deploys to GKE. At time of writing:

* skaffold: v1.35.1
* kubectl (not sure if skaffold is using its own kubectl binary): v1.19.14
* GKE cluster running 1.20.10-gke.1600 on master and nodes

## Conclusion

skaffold currently doesn't support file syncing to an existing Pod without redeploying it.

### Update

* Removing image tag and digest from K8s YAML worked!
* Found a way to not have a Dockerfile!
* Found a hacky way using post-deploy hook and `touch` to force an initial sync of all relevant files.

### TODOs and Questions (in order of importance)

1. Is there a way to make skaffold sync to an existing Pod without redeploying and destroying it? Want to keep existing
   remote context whenever possible. **NO**
2. In inferred file syncing mode, skaffold doesn't sync empty directories or deletions of files and dirs. Is this expected?
3. "Inferred sync mode only applies to modified and added files. File deletion will always cause a complete
   rebuild." [inferred-sync-docs]. Looks like I've fortunately avoided this behavior. skaffold will still deploy my K8s
   manifests, but the Pods aren't recreated since nothing's changed from K8s' point of view. Is this workaround too
   brittle? Why does skaffold do this? Is there a way to disable this behavior or even better sync the deletions? 
4. What are the implications of `touch`ing everything?
5. skaffold is using `alpine:3.15.0-rc.4@sha256:fb150366bfb5a297a7f8852e0cec462a12f638374f8a04ad235c56a97e780add`. But I
   don't see that digest for the [3.15.0-rc.4 tag here](https://hub.docker.com/_/alpine?tab=tags). Any idea where that
   digest is coming from?
6. Will the current skaffold.yaml have problems with future updates?
7. If I restore the image tag and digest in my K8s YAML and
   run `skaffold dev --tag 3.15.0-rc.4 --digest-source none --cleanup=false` there's another error. Is there a way to
   make skaffold use the tag and digest in my K8s YAML?
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
