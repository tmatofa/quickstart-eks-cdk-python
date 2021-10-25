# Demo Applications

## hello-kubernetes

Here we're deploying the container from https://github.com/paulbouwer/hello-kubernetes but via a custom Deployment and Ingress Spec.

This is to provide an example of a Kubernetes Deployment as well as how to present a service out to the Internet via the AWS Load Balancer controller as your Ingress Controller.

To deploy it run `kubectl apply -f hello-kubernetes.yaml`

The Deployment implements CPU and memory requests and limits, readiness and liveness probes (Kubernetes' healthchecks) as well as is explicit about its use of non-root UID and GID and dropping of unnecessary capabilities and privileges (which are enforced by our example Gatekeeper polices).

The Ingress (and the required Service it uses) implements an HTTP ALB to serve this app. If you have a valid ACM certificate and/or a valid Route53 domain name you can uncomment the annotations to make this HTTPS and automatically create a DNS alias to a 'proper' DNS name.

## EBS

Elastic Block Storage (EBS) is the AWS block storage service in AWS. We've integrated it with our EKS environment by adding the CSI driver AWS maintains to the cluster as an add-on in the Quick Start.

To deploy this example run:
1. `kubectl apply -f ebs-pod.yaml` to create a PersistentVolumeClaim and a Pod that mounts that PVC from the StorageClass creaed by the Quick Start `ebs`
1. `kubectl get pods` and see our new `storage-test-ebs` running
1. `kubectl exec -it storage-test-ebs -- /bin/bash` to give us an interactive shell into the running Pod
1. `df -h` to show us the mounted Volumes - you can see our 1GB volume mounted to /mnt/test as we requested.
1. `exit` to return to the bastion's shell
1. Go to the EC2 Service in the AWS console
1. Go to Volumes on the left-hand side navigation pane
1. Sort by Size such that the 1GB volume we created is at the top of the list by clicking on the Size heading

## EFS

Elastic File System (EFS) is a managed service that presents filesystems that can be mounted by NFS clients.

Unlike the EBS CSI Driver, the EFS CSI driver requires an EFS Filesytem to already exist and for us to tell it which one to use as part of each StorageClass. We created both such an EFS Filesystem as well as a StorateClass referencing it called `efs` in the Quick Start.

**NOTE:** By default we set the EFS Filesystem's Security Group to allow NFS connections from the Cluster's Security Group. If you are using Security Groups for Pods and the Pods don't have that Security Group attached you'll need to update the Filesystem's Security Group to allow them to connect. This example doesn't include a SG for the Pod so, unless you have set one on the default namespace etc. it should work.

To deploy this example run:
1. `kubectl apply -f efs-pod.yaml` to create a PersistentVolumeClaim and a Pod that mounts that PVC from the StorageClass creaed by the Quick Start `ebs`
1. `kubectl get pods` and see our new `storage-test-efs` running
1. `kubectl exec -it storage-test-efs -- /bin/bash` to give us an interactive shell into the running Pod
1. `df -h` to show us the mounted Volumes - you can see our unlimited (it shows as 8 Exabytes!) volume mounted to /mnt/test as we requested.
1. `exit` to return to the bastion's shell
1. Go to the EFS Service in the AWS Console
1. Go to `Access points` on the left-hand navigation pane
1. Note that the EFS CSI Driver created a path for this PersistentVolumeClaim in the volume tied to an EFS Access Point to control access to that path for us automatically.

## Ghost
Note that this requires the Kubernetes External Secrets Opeartor (https://github.com/external-secrets/kubernetes-external-secrets). This is an optional part of the Quick Start so you can enable it there. Alternatively, you can flip `deploy_external_secrets` to true in `cdk.json` to true and this CDK example will deploy it for you as well. 

To deploy our CDK-based Ghost example:
1. `cd ghost-cdk`
1. (If npm isn't already installed) `sudo npm install -g aws-cdk`
1. `pip3 install -r requirements.txt` to install the required Python CDK packages
1. `cdk synth` to generate the CloudFormation from the `ghost_example.py` CDK template and make sure everything is working. It will not only output it to the screen but also store it in the `cdk.out/` folder
1. `cdk deploy` to deploy template this to our account in a new CloudFormation stack
1. Answer `y` to the security confirmation and press Enter/Return

### Understanding what this example is doing

When we run our `ghost_example.py` CDK template there are both AWS and Kubernetes components that CDK provisions for us.
![Git Flow Diagram](diagram1.PNG?raw=true "Git Flow Diagram")

We are also adding a new controller/operator to Kubernetes - [kubernetes-external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) - which is UPSERTing the AWS Secrets Manager secret that CDK is creating into Kubernetes so that we can easily consume this in our Pod(s). This joins the existing [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/) which turns our Ingress Specs into an integration/delegation to the AWS Application Load Balancer (ALB).
![Operator Flow Diagram](diagram2.PNG?raw=true "Operator Flow Diagram")

### Bringing in our YAML Manifest files directly

You'll notice that rather than copying/pasting the YAML mainifests into our Python template as JSON (as we did for a few things in eks_cluster.py) here we added some code using a Python library called pyaml to import the files at runtime. This allows people to deal with their Kubernetes manifest files directly but CDK to facilitate their deployment.

```
import yaml

...

ghost_deployment_yaml_file = open("ghost-deployment.yaml", 'r')
ghost_deployment_yaml = yaml.load(ghost_deployment_yaml_file, Loader=yaml.FullLoader)
ghost_deployment_yaml_file.close()
#print(ghost_deployment_yaml)
eks_cluster.add_manifest("GhostDeploymentManifest",ghost_deployment_yaml)
```

### Cross-Stack CDK

We're deploying Ghost in a totally seperate CDK stack in a seperate template. This is made possible by a few things:
1. Some CDK Constructs like VPC can import object, with all the associated properties and methods, from existing environments. In the case of VPC you'll see this is all it takes to import our existing VPC we want to deploy into by its name:
```
vpc = ec2.Vpc.from_lookup(self, 'VPC', vpc_name="EKSClusterStack/VPC")
```
1. Other Constructs like EKS we need to tell it several of the parameters for it to reconstruct the object. Here we need to tell it a few things like the `open_id_connect_provider`, the `kubectl_role_arn`, etc. for it to give us an object we can call/use like we'd created the EKS cluster in *this* template. 

We pass these parameters across our Stacks using CloudFormation Exports (Outputs in one CF stack we can reference in another):

Here is an example of exporting the things we need in eks_cluster.py
```
core.CfnOutput(
    self, "EKSClusterName",
    value=eks_cluster.cluster_name,
    description="The name of the EKS Cluster",
    export_name="EKSClusterName"
)
```

And here is an example of importing them in ghost_example.py to reconstitute an eks.Cluster object from the required attributes.
```
eks_cluster = eks.Cluster.from_cluster_attributes(
  self, "cluster",
  cluster_name=core.Fn.import_value("EKSClusterName"),
  open_id_connect_provider=eks.OpenIdConnectProvider.from_open_id_connect_provider_arn(
    self, "EKSClusterOIDCProvider",
    open_id_connect_provider_arn = core.Fn.import_value("EKSClusterOIDCProviderARN")
  ),
  kubectl_role_arn=core.Fn.import_value("EKSClusterKubectlRoleARN"),
  vpc=vpc,
  kubectl_security_group_id=core.Fn.import_value("EKSSGID"),
  kubectl_private_subnet_ids=[vpc.private_subnets[0].subnet_id, vpc.private_subnets[1].subnet_id]
)
```
And here is what those Exports look like in the CloudFormation console
![CF Exports](diagram3.PNG?raw=true "CF Exports")

### Exploring Ghost after it is deployed

1. Run `kubectl get ingresses` to see the address for the ALB in front of our service
1. Go to that address in your web browser to see the service
1. In your browser append a `/ghost` to the end of the address to get to the Ghost management interface. Set up your initial account there (before some random person/bot on the Internet does it for you!)
1. Go to the EC2 Service in the AWS Console
1. Go to `Load Balancers` on the left hand navigation pane
1. Select the `k8s-default-ghost-...` Load Balancer - this is the ALB that the AWS Ingress Controller created for us
1. Select the Monitoring Tab to see some metrics about the traffic flowing though to our new Ghost
1. Select `Target Groups` on the left-hand navigation pane
1. Select the `k8s-default-ghost-...` Target Group
1. Select the Targets tab on the lower pane
1. The AWS Load Balancer controller adds/removes the Pod IPs directly as LB Targets as they come and go
1. Go to the Secrets Manager service in the AWS Console
1. Click on the Secret named `RDSSecret...`
1. Scroll down until you see the `Secret value` section and click the `Retrieve secret value` button. This secret was created by the CDK as part of its creation of the MySQL RDS. We map this secret into a Kubernetes secret our app consumes to know how to connect to the database with the [kubernetes-external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) add-on we install in this stack. That in turn is passed in at runtime by Kubernetes as environment variables.
1. `kubectl describe externalsecrets` shows the mapping document telling kubernetes-external-secrets what secret(s) to fetch and what Kubernetes secrets to put them in
1. `kubectl descibe secret ghost-database` shows the resulting Kubernetes secret that we're importing into our Ghost Pods via environment variables