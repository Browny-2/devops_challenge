# Utrust DevOps Challenge
This project has been created for the Utrust DevOps Challenge. The project is split into two sections a NodeJS application and IaC (Infrastructure as Code).

To reduce the number of moving parts, I decided to store both the infrastructure code and the application code in the same repository. This has been done purely for this challenge, and I would recommend that these would be separate under a typical circumstance.  

Due to the nature of the job and with a view of transparency, a guide for the NodeJS application was followed (https://blog.logrocket.com/nodejs-expressjs-postgresql-crud-rest-api-example/). I have modified the application itself slightly to allow the initialisation of the RDS instance to create the initial "users" table as it is in a private subnet and cant be connected to directly.

To enable the user to be able to access the application, the following steps need to be followed;
Initialise Terraform.
Build the Infrastructure.
Using the Terraform outputs, create the GitHub secrets that are to be used in the CI/CD pipeline.
Update GitHub with the outputted secrets. These will be used to push to ECR and inject the RDS address and password into the container. 
Create a tag that will then trigger the GitHub actions to build the docker container and update the task-definition redeploying the new version.
Access the application with the outputted ALB address.

Technologies Used; 
- Terraform
- NodeJS
- PostgreSQL
- Docker
- GitHub Actions 

## Setup and creation of Infrastructure
A presumption has been made that an AWS account already and that a user with Administrator permissions is available. The user that will be following this guide must have at least Terraform v1.0.0 installed.

Initialisation of the local environment
- Clone the GitHub repository to your local machine.
- Obtain an AWS Key / Secret Key, which is to be exported into the local shell environment to allow AWS access for Terraform.
- Exporting the credentials into the local environment;
    - `export AWS_ACCESS_KEY_ID=<access key>`
    - `export AWS_SECRET_ACCESS_KEY=<secret key>`

Initialising / Using Terraform for the first time
- Log into AWS and navigate to S3.
- Create an S3 bucket Note: the name must be a unique namespace.
- Via the local shell cd into the terraform folder within the cloned repository.
- Initialise Terraform using `terraform init` and provide the bucket name from the step above when prompted.
- Trigger creation of the Infrastructure via one of the two methods below;
    - Plan outputted to a file, and then the application.
        - `terraform plan -out=initial.tfplan`
        - `terraform apply "initial.tfplan"`
    - Run Terraform plan to show the changes and then run an application with the `auto-approve` parameter.
        - `terraform plan`
        - `terraform apply --auto-approve`

## Build and Deployment of the applications 
- Access the repository via the browser, navigating to Settings > Secrets > Select "New repository secret"
- Using the Terraform outputs, create the following secrets; Note: to retrieve the sensitive valued keys use `terraform output <value to be retrieved>`
    - PUBLISHER_ACCESS_KEY_ID
    - PUBLISHER_SECRET_ACCESS_KEY
    - RDS_DATABASE_ADDRESS
    - RDS_PASSWORD

At this point a build can be triggered by adding a new tag. When in the code view in GitHub, on the right side select Releases;

- Draft new release.
- Tag version making sure it is unique.
- Publish Release.
- Navigate to the "Actions" header to be able to view the status of the workflow.
- Verify the deployment has been completed successfully, at this point the application will now be available for use.

## Using the application 

Once the GitHub actions have been completed successfully using the URL Provided by the Terraform output, you will be able to interact with the application. Initially, the database will be empty as it was initialised with no data. To populate with some data, please see the instructions below to interact with the application. 

To be able to access the data from the browser you can either retrieve all values or a single value based on the sequence. 

http://<app_url>/users

http://<app_url>/users/<DB sequence number>

##### POST

Add a new user with the name Michael and email michael@example.com, with each entry the sequence will increase by 1.

curl --data "name=Michael&email=michael@example.com" http://<app_url>/users

curl -X DELETE utrust-alb-1253693615.eu-central-1.elb.amazonaws.com/users/1
##### PUT

Update the user with ID 1 to have the name Tamara and email tamara@example.com.

curl -X PUT -d "name=Tamara" -d "email=tamara@example.com" http://<app_url>/users/1

#### DELETE

Delete the user with id 1.

curl -X "DELETE" http://<app_url>/users/1

## Environment destruction

Once finished with the environment to ensure all resources are cleaned up we will destroy everything with Terraform

- Via the local shell cd into the terraform folder within the cloned repository.
- Destroy all Terraform resources using `terraform destroy --auto-approve`.

## Security Recommendations

Within this project, I have built-in some of my security recommendations, such as;

Splitting the subnets over public/private so the likes of RDS cannot be accessed directly from outside the organisation. This could go one step further and have a separate private subnet for databases and applications.

Separate role allowing the likes of publishing to ECR and updating task-definitions rather than an admin account.

Additional Considerations (not completed as part of this challenge).

Enable access logs on the ALB to audit purposes.

Certificate to be added and traffic routed on HTTPS

Specific Route53 domain, which then routes to the ALB to protect the resource name. 

## Scale the application

Approach 1 - Using ECS create an autoscaling policy that will monitor both CPU and Memory usage with a defined threshold. If this threshold is breached, an additional container is to be span up and added to the load balancer providing horizontal scaling. 

Approach 2 - With the addition of another service such as Prometheus, constant monitoring can be completed of applications. If it is identified that services constantly have to be scaled, they can be vertically scaled, providing the task-definition with additional resources.  
