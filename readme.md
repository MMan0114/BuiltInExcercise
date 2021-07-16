This is a sample terraform script to build out an EC2 Instance and install the Apache Webserver on it, and allow access from the outside world. 
<sub><sup>*Normally, would add the .tfvars file to gitignore to not expose your AWS keys and potentially the statefile if you are not storing it remotely</sup></sub>

To deploy this application, clone the files from the git repo and then move/cd into that directory

1. git clone 

2. Then initialize the terraform provider, this will install the AWS provider so you can create AWS resources

```
terraform init
```
3. Then we plan it out to verify what resources will be created based on what's in your main.tf
```
terraform plan
```
4. If everything looks good, we can go ahead and apply those changes, hit yes and enter when prompted. This will output the public ip address of the EC2 Instance running the apache webserver that was created.
```
terraform apply
```
5. Copy that IP address into a browser of your choice and you will be able to view the web server running

If you want to make changes to any of the resources built after the initial apply, you can update your main.tf and then rerun the terraform plan and apply. For example, updating the VPC, or subnets, or security groups. 

If you want to destroy all the resources created you can run the following
```
terraform destroy
```

Some enhancements for this basic setup: 
- include building out multiple EC2 instances and putting it behind a Load Balancer to route traffic.
- splitting out the installation of the apache from the creation of the EC2 instance and other AWS resources and deploying it through Ansible or even containerizing your Apache image and deploying to the EC2 instance with a CI tool like Jenkins
