# This Dockerfile is only used to configure skaffold behavior.
# This Dockerfile is not used to build any image.
# This file is required when using skaffold's inferred file sync feature.
# This feature lets us specify files to ignore during file sync in .dockerignore.
# We want to sync everything in this repo and ignore specific paths.
# There's no way to exclude paths to sync in skaffold.yaml's
# `.build.artifacts[].sync.manual`.
FROM scratch
WORKDIR /src/test
ADD . .
