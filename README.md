# Amazon Connect Wisdom Loader

This sample code shows a mechanism to upload content to a Wisdom Knowledge Base. The project is composed of a set of resources for automating content loading to a Knowledge Base and a shell script to be used with BASH CLIs.

## Deployed resources

The project includes a cloud formation template with a Serverless Application Model (SAM) transform to deploy resources as follows:

### AWS Lambda functions

- presignFunction: Generates a temporary URL to upload files to an S3 bucket.
- wisdomLoad: Uploads files from the S3 bucket to Wisdom KB.

### AWS Lambda Layers
 - AxiosLayer: Axios layer used to upload content.

### API Gateway 
- presign: Endpoint to get presigned URLs for uploading files.


## Prerequisites.

1. AWS Console Access with administrator account.
1. Cloud9 IDE or AWS and SAM tools installed and properly configured with administrator credentials.
1. 
1. Amazon Connect Instance already set up.
1. Preconfigured Amazon Wisdom Knowledge base and Assistant.

## Deploy the solution
1. Clone this repo.

`git clone https://github.com/aws-samples/amazon-connect-wisdom-cli-loader`

2. Build the solution with SAM.

`sam build -u` 

3. Deploy the solution.

`sam deploy -g`

SAM will ask for the name of the application (name it something relevant such as "wisdom-loader") as all resources will be grouped under it and deployment region.Reply Y on the confirmation prompt before deploying resources. SAM can save this information if you plan un doing changes, answer Y when prompted and accept the default environment and file name for the configuration.

Make a note on the outputs generated by SAM (also visible on the CloudFormation screen for this template). An example command is displayed to upload files.
### Configure wisdomLoad function
1. Browse to the Application page in AWS Lambda console, select the deployed application and finally select the wisdomLoad lambda function.
1. Go to configuration -> Environment variables and replace the value for the KNOWLEDGE_BASE_ID variable.

## Usage 
1. From a linux/Mac OS terminal, change permissions on file s3upload.sh:

    `chmod +x s3upload.sh`

1. Upload specific files: 

    `./s3upload.sh -a <API_ID> -r <REGION> -b <BUCKET> -f <FILE>`

Replace the parameters produced while deploying the solution.
FILE: File to upload
BUCKET: Destination bucket.
REGION: Region where bucket is located.
API_ID: API ID for signing requests.


## Resource deletion
1. Delete all files in the S3 Bucket.
1. From the cloudformation console, select the stack associated with the application and click on Delete and confirm it by pressing Delete Stack.