# Deploy and connect to Kubecost for cost/usage analysis and attribution

We have deployed an in-VPC private Network Load Balancer (NLB) to access your Kubecost service. There is no login or password - access is controlled from a network perspective.

To access this enter the following command `get service kubecost-nlb --namespace=kube-system` to find the address of this under EXTERNAL-IP. Alternatively, you can find the Kubecost NLB in the AWS EC2 console and get its address from there.

You'll need to have network connectivity via something like the Client VPN, Site-to-Site VPN or DirectConnect to be able to reach it.