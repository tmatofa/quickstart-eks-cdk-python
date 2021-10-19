# Deploy and connect to OpenSearch for log search and visualisation

If you set `deploy_managed_opensearch` to `True` in `cluster-bootstrap/cdk.json` then the template will deploy a managed OpenSerach as well as a Fluent Bit shipping your logs to it.

We put the OpenSearch both in the VPC (i.e. not on the Internet) as well as in its own Security Group - which will give access by default only from our EKS cluster's SG (so that can ship the logs to it) as well as to from our (optional) Client VPN's Security Group to allow us access OpenSearch Dashboards when on VPN.

Since this OpenSearch can only be reached if you are both within the private VPC network *and* allowed by this Security Group, then it is low risk to allow 'open access' to it - especially in a Proof of Concept (POC) environment. As such, we've configured its default access policy so that no login and password and are required - choosing to control access to it from a network perspective instead.

For production use, though, you'd likely want to consider implementing Cognito to facilitate authentication/authorization for user access to OpenSearch Dashboards - https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-walkthrough-iam. You'd also likley want to consider [sizing it](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/sizing-domains.html) for your needs as well as move to [dedicated master nodes](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/managedomains-dedicatedmasternodes.html) by adjusting the other `opensearch_` parameters in `cdk.json`.

### Connect to OpenSearch Dashboards and do initial setup

1. Connect to the Client VPN or ensure that you have private network connectivity to the OpenSearch (site-to-site VPN, DirectConnect, etc.)
1. Go to the OpenSearch service in the AWS Console
1. Click on the Domain name
1. Click on the link next to `OpenSearch Dashboards`
1. Click the `Explore on my own` link
1. Click the OpenSearch Dashboards blue box / link in the center of the page
1. Click the blue `Add your data` button
1. Click the blue `Create index pattern` button
1. In the Index pattern name box enter `logstash-*` and click Next step
1. Pick `@timestamp` from the dropdown box and click the `Create index pattern` button
1. Then click the Hamburger menu in the upper left and choose `Discover`

You should see all of your logs.

TODO: Document how to do a few basic things here re: searching, filtering and visualizing your logs