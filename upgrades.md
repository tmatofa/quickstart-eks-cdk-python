# Upgrading your EKS Cluster and add-ons via he CDK

## Upgrading your cluster

Since we are explicit both with the EKS Control Plane version as well as the Managed Node Group AMI version upgrading these is simply incrementing these versions, saving `cluster-bootstrap/cdk.json` and then running a `npx cdk deploy`.

As per the [EKS Upgrade Instructions](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html) you start by upgrading the control plane, then any required add-on versions and then the worker nodes.

Upgrade the control plane by changing `eks_version` in  `cluster-bootstrap/cdk.json`. You can see what to put there by looking at the [CDK documentation for KubernetesVersion](https://docs.aws.amazon.com/cdk/api/latest/python/aws_cdk.aws_eks/KubernetesVersion.html). Then run `npx cdk deploy` - or let the CodeBuild GitOps provided in `cluster-codebuild` do it for you.

Upgrade the worker nodes by updating `eks_node_ami_version` in  `cluster-bootstrap/cdk.json` with the new version. You find the version to type there in the [EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html) as shown here:
![](eks_ami_version.PNG)

## Upgrading an add-on

Each of our add-ons are deployed via Helm Charts and are explicit about the chart version being deployed. In the comment above each chart version we link to the GitHub repo for that chart where you can see what the current chart version is and can see what changes may have been rolled in since the one cited in the template.

To upgrade the chart version update the chart version to the upstream version you see there, save it and then do a `npx cdk deploy`.

**NOTE:** While we were thinking about parameterizing the chart versions within `cluster-bootstrap/cdk.json`, it is possible as the Chart versions change that the values you have to specify might also change. As such, we have not done so as a reminder that this change might require a bit of research and testing rather than just popping a new version number parameter in and expecting it'll work.