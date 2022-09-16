# if args are less than 3, then exit
if [ $# -lt 3 ]; then
    echo "Usage: $0 <ADMIN_EMAIL> <GITHUB_OAUTH_TOKEN> <AWS_REGION> [<SAM_S3_BUCKET>]"
    exit 0
fi

ADMIN_EMAIL=$1
GITHUB_OAUTH_TOKEN=$2
AWS_REGION=$3

# if SAM_S3_BUCKET is not provided, then create one
if [ -z "$4" ]; then
    SAM_S3_BUCKET="iot-cloud-systems-sam-$(date +%s)"
    echo "Creating SAM S3 bucket: $SAM_S3_BUCKET"
    aws s3 mb s3://${SAM_S3_BUCKET} --region ${AWS_REGION}
else
    SAM_S3_BUCKET=$4
fi

# CLONE EVERY REPO

mkdir products-app
cd products-app

git clone https://github.com/iot-cloud-system-final-assignment-mc/bootstrap-configuration.git
git clone https://github.com/iot-cloud-system-final-assignment-mc/lambda-products.git
git clone https://github.com/iot-cloud-system-final-assignment-mc/lambda-orders.git
git clone https://github.com/iot-cloud-system-final-assignment-mc/auth-lambda.git
git clone https://github.com/iot-cloud-system-final-assignment-mc/api-gateway.git
git clone https://github.com/iot-cloud-system-final-assignment-mc/web-client.git

# DEPLOY STACK WITH RESOURCES

# deploy bootstrap.configuration
cd bootstrap-configuration
sam deploy -t template.yml --stack-name bootstrap-resources  --s3-bucket $SAM_S3_BUCKET --s3-prefix bootstrap-resources --region $AWS_REGION --capabilities CAPABILITY_AUTO_EXPAND --parameter-overrides AdminEmailParameter=$ADMIN_EMAIL
cd ..

LAYER_ARN=$(aws cloudformation list-exports --region ${AWS_REGION} --query "Exports[?Name=='Cloud-Systems-IoT-HttpUtilsLayerArn'].Value" --output text)

# deploy lambda-products
cd lambda-products
cd code && npm install && cd ..
sam build
sam deploy -t ./.aws-sam/build/template.yaml --stack-name lambda-products --s3-bucket $SAM_S3_BUCKET --s3-prefix lambda-products --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM --parameter-overrides UtilsLayerArn=$LAYER_ARN
cd ..

# deploy lambda-orders
cd lambda-orders
cd code && npm install && cd ..
sam build
sam deploy -t ./.aws-sam/build/template.yaml --stack-name lambda-orders --s3-bucket $SAM_S3_BUCKET --s3-prefix lambda-orders --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM --parameter-overrides UtilsLayerArn=$LAYER_ARN
cd ..

# deploy auth-lambda
cd auth-lambda
cd code && npm install && cd ..
sam build
sam deploy -t ./.aws-sam/build/template.yaml --stack-name auth-lambda --s3-bucket $SAM_S3_BUCKET --s3-prefix auth-lambda --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM --parameter-overrides UtilsLayerArn=$LAYER_ARN
cd ..

# deploy api-gateway
cd api-gateway
sam deploy -t template.yml --stack-name api-gateway --s3-bucket $SAM_S3_BUCKET --s3-prefix api-gateway --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM
cd ..

# DEPLOY STACKS WITH PIPELINES

# deploy web-client-pipeline
DEPLOY_BUCKET=$(aws cloudformation list-exports --region ${AWS_REGION} --query "Exports[?Name=='Cloud-Systems-IoT-ApplicationSiteBucket'].Value" --output text)
cd web-client
sam deploy -t pipeline-template.yml --stack-name web-client-pipeline --s3-bucket $SAM_S3_BUCKET --s3-prefix web-client --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM --parameter-overrides GithubOAuthToken=$GITHUB_OAUTH_TOKEN DeployBucket=$DEPLOY_BUCKET
cd ..

# deploy lambda-products-pipeline
cd lambda-products
sam deploy -t pipeline-template.yml --stack-name lambda-products-pipeline --s3-bucket $SAM_S3_BUCKET --s3-prefix lambda-products-pipeline --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM --parameter-overrides GithubOAuthToken=$GITHUB_OAUTH_TOKEN s3SamBucket=$SAM_S3_BUCKET
cd ..

# deploy lambda-orders-pipeline
cd lambda-orders
sam deploy -t pipeline-template.yml --stack-name lambda-orders-pipeline --s3-bucket $SAM_S3_BUCKET --s3-prefix lambda-orders-pipeline --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM --parameter-overrides GithubOAuthToken=$GITHUB_OAUTH_TOKEN s3SamBucket=$SAM_S3_BUCKET
cd ..

# deploy auth-lambda-pipeline
cd auth-lambda
sam deploy -t pipeline-template.yml --stack-name auth-lambda-pipeline --s3-bucket $SAM_S3_BUCKET --s3-prefix auth-lambda-pipeline --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM --parameter-overrides GithubOAuthToken=$GITHUB_OAUTH_TOKEN s3SamBucket=$SAM_S3_BUCKET
cd ..

# deploy api-gateway-pipeline
cd api-gateway
sam deploy -t pipeline-template.yml --stack-name api-gateway-pipeline --s3-bucket $SAM_S3_BUCKET --s3-prefix api-gateway-pipeline --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM --parameter-overrides GithubOAuthToken=$GITHUB_OAUTH_TOKEN s3SamBucket=$SAM_S3_BUCKET
cd ..


echo "Done!"
echo "You can now access the web client at http://$(aws cloudformation list-exports --region ${AWS_REGION} --query "Exports[?Name=='Cloud-Systems-IoT-ApplicationSite'].Value" --output text)"
echo "If you can't access the web client, wait a few minutes and try again because the files in the S3 bucket may require a couple of minutes to be uploaded."