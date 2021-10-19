# Deploy and connect to the Client VPN

If you set `deploy_vpn` to `True` in `cluster-bootstrap/cdk.json` then the template will deploy a Client VPN so that you can securely access the cluster's private VPC subnets from any machine. You'll need this to be able to reach the OpenSearch Dashboards for your logs and Grafana for your metrics by default (unless you are using an existing VPC where you have already arranged such connectivity)

Note that you'll also need to create client and server certificates and upload them to ACM by following these instructions - https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual - and update `ekscluster.py` with the certificate ARNs for this to work.

Once it has created your VPN you then need to configure the client:

1. Open the AWS VPC Console and go to the Client VPN Endpoints on the left panel
1. Click the Download Client Configuration button
1. Edit the downloaded file and add:
    1. A section at the bottom for the server cert in between `<cert>` and `</cert>`
    1. Then under that another section for the client private key between `<key>` and `</key>` under that
1. Install the AWS Client VPN Client - https://aws.amazon.com/vpn/client-vpn-download/
1. Create a new profile pointing it at that configuration file
1. Connect to the VPN

Once you are connected it is a split tunnel - meaning only the addresses in your EKS VPC will get routed through the VPN tunnel.

You then need to add the EKS cluster to your local kubeconfig by running the command in the clusterConfigCommand Output of the EKSClusterStack.

Then you should be able to run a `kubectl get all -A` and see everything running on your cluster.