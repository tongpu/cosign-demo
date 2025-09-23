# Cosign demo

This repository builds a simple Python Flask based demo application and signs the built container image using cosign.

The instructions in this repository are based on a blog post from GitLab: <https://about.gitlab.com/blog/annotate-container-images-with-build-provenance-using-cosign-in-gitlab-ci-cd/>

## Validate images with the Sigstore policy-controller

1. Install the Sigstore policy-controller by installing the Helm chart: https://github.com/sigstore/helm-charts/tree/main/charts/policy-controller
2. Add the label `policy.sigstore.dev/include=true` to the namespace you want to protect
3. Configure a `ClusterImagePolicy` to only accept signed images from the `main` branch
   ```yaml
   apiVersion: policy.sigstore.dev/v1beta1
   kind: ClusterImagePolicy
   metadata:
     name: gitlab-images-are-signed
   spec:
     images:
       - glob: registry.gitlab.com/tongpu/**
     authorities:
       - keyless:
           url: https://fulcio.sigstore.dev
           identities:
             - issuer: https://gitlab.com
               subject: https://gitlab.com/tongpu/cosign-demo//.gitlab-ci.yml@refs/heads/main
         ctlog:
           url: https://rekor.sigstore.dev
         name: authority-0
   ```
4. Create a pod using an image built on `main` and it will be accepted
5. Create a pod using an image built on another branch and it will be denied
