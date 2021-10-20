# Deploy Open Policy Agent (OPA) Gatekeeper and sample policies via the Flux GitOps Operator

The [gatekeeper](https://github.com/aws-quickstart/quickstart-eks-cdk-python/tree/main/gatekeeper) folder contains the manifests to deploy [Gatekeeper's Helm Chart](https://github.com/open-policy-agent/gatekeeper/tree/master/charts/gatekeeper) as well as an example set of policies to help achieve a much better security and noisy neighbor situation - especially if doing multi-tenancy. See more about these example policies in [gatekeeper/README.md](https://github.com/aws-quickstart/quickstart-eks-cdk-python/blob/main/gatekeeper/README.md).

This also serves as an example of how to use Flux v2 with EKS.

In order to deploy Gatekeeper and the example policies:
1. Ensure you are on a system where `kubectl` is installed and working against the cluster (like the bastion)
1. [Install the Flux v2 CLI](https://fluxcd.io/docs/installation/#install-the-flux-cli)
1. Run `flux install` to install Flux onto the cluster
1. Change directory into the root of quickstart-eks-cdk-python
1. Run `kubectl apply -f gatekeeper/gatekeeper-sync.yaml` to install the Gatekeeper Helm Chart w/Flux (as well as enable future GitOps if the main branch of the repo is updated)
1. Run `flux get all` to see the progress of getting and installing the Gatekeeper Helm Chart
1. Run `flux create source git gatekeeper --url=https://github.com/aws-quickstart/quickstart-eks-cdk-python --branch=main` to add this repo to Flux as a source
    1. Alternatively, and perhaps advisably, specify the URL of your git repo you've forked/cloned the project to instead - as it will trigger GitOps actions going forward when this changes!
1. Run `kubectl apply -f gatekeeper/policies/policies-sync.yaml` to install the policies with Flux (as well as enable future GitOps if the main branch of the repo is updated)
1. Run `flux get all` to see all of the Flux items and their reconciliation statuses

If you want to change any of the Gatekeeper Constraints or ConstraintTemplates you just change the YAML and then push/merge it to the repo and branch you indicated above and Flux will them deploy those changes to your cluster via GitOps.
