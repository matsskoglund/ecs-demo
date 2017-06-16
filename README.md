# Infrastructure as Code Demo
A short demo of IaC (Infrastructure as Code) using AWS ECS, Docker and Terraform. The use of the code is shown in the IaC video demonstration on [Youtube](https://youtu.be/byM_OSNE9zw)

In order for this to work vpc, subnet1, subnet2 and AWS profile need to be changed or specified using the Terraform -var flag.

## The terraform commands used 
The terraform commands used is `terraform apply` to create and change the infrastructure and `terraform destroy -force` to delete it.

The code in the demo used VPC, subnet and AWS profiles specific for my account. You must use other values for your AWS account. You can do this in at least two ways. One way is to change the `variables.tf` file by updating the default values of the following variables:
*  "cluster_vpc"
*  "subnet1"
*  "subnet2"
*  "profile" [[More info on profiles at Terraform](https://www.terraform.io/docs/providers/aws)]

Another way is to pass these values as arguments as show below:

To create the infrastructure using the orange image and pass the neccessary values as arguments use:
```
terraform apply -var "cluster_vpc=[your_vpc]" -var "subnet1=[your_subnet1]" -var "subnet2=[your_subnet2]" -var "image_tag=orange" -var profile="[your_profilename]"
```

To use the green image:
```
terraform apply -var "cluster_vpc=[your_vpc]" -var "subnet1=[your_subnet1]" -var "subnet2=[your_subnet2]" -var "image_tag=green" -var profile="[your_profilename]"
```

To destroy the infrastructure:
```
terraform destroy -force
```

The docker images of used used can be found [here](https://hub.docker.com/r/matsskoglund/house-demo/).

[Terraform](https://www.terraform.io)

[AWS ECS](http://aws.amazon.com/ecs)
