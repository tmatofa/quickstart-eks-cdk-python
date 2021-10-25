# Deploy and connect to the Client VPN

If you set `deploy_vpn` to `True` in `cluster-bootstrap/cdk.json` then the template will deploy a Client VPN so that you can securely access the cluster's private VPC subnets from any machine. You'll need this to be able to reach the OpenSearch Dashboards for your logs and Grafana for your metrics by default (unless you are using an existing VPC where you have already arranged such connectivity)

Note that you'll also need to create client and server certificates and upload them to ACM by following these instructions - https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual - and update `ekscluster.py` with the certificate ARNs for this to work.

Once it has created your VPN you then need to download and configure the client. You can follow these instructions to do so - https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-config

Once you are connected it is a split tunnel - meaning only the addresses in your EKS VPC will get routed through the VPN tunnel.

You then need to add the EKS cluster to your local kubeconfig by running the command in the clusterConfigCommand Output of the EKSClusterStack.

Then you should be able to run a `kubectl get all -A` and see everything running on your cluster.
