# Deploy and connect to Kubecost for cost/usage analysis and attribution

If you set `deploy_kubecost` to `True` in `cluster-bootstrap/cdk.json` then the template will deploy the [open core Helm Chart for Kubecost](https://github.com/kubecost/cost-model). 

We have deployed an in-VPC private Network Load Balancer (NLB) to access your Kubecost service. There is no login or password - access is controlled from a network perspective.

To access this enter the following command `get service kubecost-nlb --namespace=kube-system` to find the address of this under EXTERNAL-IP. Alternatively, you can find the Kubecost NLB in the AWS EC2 console and get its address from there.

You'll need to have network connectivity via something like the Client VPN, Site-to-Site VPN or DirectConnect to be able to reach it.

You can see more about how to use Kubecost here - https://docs.kubecost.com/cost-allocation.html