# terraform-aws-provider
**Terraform with AWS Provider**  
with **AWS Provider**  
이것저것 해보기
  <br />
    <br />

## asg-elb-s3-db
### Architecture
![image](https://user-images.githubusercontent.com/49095587/211987429-756a397b-68cf-488d-b6d3-78318ea8752f.png)
```
tf-aws-provider
	ㄴ 📁 global
		ㄴ 📁 s3  # Remote State Storage(s3 bucket) 
			ㄴ 📄 main.tf
			ㄴ 📄 output.tf
	ㄴ 📁 stage
		ㄴ 📁 datastores
			ㄴ 📁 mysql # Database
				ㄴ 📄 main.tf
				ㄴ 📄 var.tf
				ㄴ 📄 output.tf
		ㄴ 📁 services
			ㄴ 📁 webserver-cluster # ASG(EC2 instances) + ELB
				ㄴ 📄 main.tf
				ㄴ 📄 var.tf
				ㄴ 📄 data.tf
				ㄴ 📄 output.tf
```
[✨ Notion 설명 바로가기](https://dandy-antimatter-039.notion.site/Terraform-with-AWS-Provider-1e761b0f3ebe4c09a32b5682eaabaa69)
