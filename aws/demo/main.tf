module "vpc" {
    source = "../vpc"
}

module "security_group" {
    source = "../security-group"
    vpc_id = module.vpc.vpc_id
    depends_on = [ module.vpc ]
}

module "ec2"  {
    source = "../ec2"
    subnet_id = module.vpc.subnets["demo-private-subnet-a"]
    name = "demo-ec2"
    role_name = "demo-ec2-role"
    ami = "ami-02c956980e9e063e5"
    depends_on = [ module.security_group ]
}

module "s3" {
    source = "../s3"
    bucket_name = "cloud-club-terraform-bucket"
    public_access_block = false
    enable_versioning = false
    cors_policy = [
        {
            allowed_headers = ["*"]
            allowed_methods = ["GET","POST","PUT"]
            allowed_origins = ["*"]
            expose_headers  = []
        }
    ]
}