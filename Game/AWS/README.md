# __AWS Cloudformation Template__

## via website :

- Go to aws cloudformation
- Create stack 
- upload template file
- enter parameters

    - CIDR range use in the VPC subnets
    ```
        ParameterKey=VpcCidrPrefix
        ParameterValue=172.16
    ```

   - Existing key pair to make ssh connection to ec2 instances (ex: mykey.pem)
   ```
        ParameterKey=KeyName
        ParameterValue=mykey

    ```

## via aws cli

```
    aws cloudformation create-stack --stack-name my-stack --template-body file://path/to/the/template/file.json --parameters ParameterKey=VpcCidrPrefix,ParameterValue=172.16 ParameterKey=KeyName,ParameterValue=mykey

```



    


