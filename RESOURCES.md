# List of challenges for each section faced and resources listed to guide through the same

## 1. Setting up AWS Glue job to access RapidAPI endpoint (External REST API in the public internet)

- ### Challenges faced:
    - The current aggregator was supposed to be hosted as a lambda endpoint to gather data from external API , however there are multiple endpoints needed to be called in current API usage and requires multiple intermediate outputs , which doesn't seem feasible.
    - AWS Glue allows to use scripts in a way so that it can transform intermediate outputs on the fly and make use of parallelism to gather data on a quicker rate.
    - One caveat though is that there are [no clear docs to explain how to connect glue to external API](https://stackoverflow.com/questions/59714187/aws-glue-job-consuming-data-from-external-rest-api) and to implement that via terraform was present on internet , based on my research so far.
    - That led to understand and refreshing my knowledge on networking subnetting , VPCs and much more.

- ### Prereqs: Understanding of networking is needed in here
    - ### Resources that were referred:
        - [AWS VPC Fundamentals](https://www.youtube.com/watch?v=TUTqYEZZUdc&list=PL0X6fGhFFNTcU-_MCPe9dkH6sqmgfhy_M&index=13)
        - [NAT Gateway usage](https://www.youtube.com/watch?v=Iqzgu5UEDKo&list=PL0X6fGhFFNTcU-_MCPe9dkH6sqmgfhy_M&index=15)
        - [Connecting Glue to external API](https://aws-dojo.com/ws26/labs/pre-requisite/)

- ### Key Takeaways: 
    - VPC (Virtual Private Cloud) is a wrapper or layer that can be introduced and kept common for one project as a whole.
    - Every service within the VPC needs to be added to a private subnet if they need to interact with each other within the VPC.
    - NAT Gateway needs to be placed in public subnet to allow communication with the external world and to hide the IPs for respective application.
    - In case of webapp , we can place loadbalancer and NAT Gateway in Public subnet to act as reverse proxy and increase security.