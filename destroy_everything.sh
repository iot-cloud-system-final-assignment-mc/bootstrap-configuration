if [ -z "$1" ]; then
    echo "Usage: $0 <AWS REGION> [<SAM S3 BUCKET>]"
    exit 0
fi

AWS_REGION=$1
SAM_S3_BUCKET=$2

# STACKS WITH RESOURCES

# delete bootstrap
BOOTSTRAP_S3_BUCKET=$(aws cloudformation list-exports --region ${AWS_REGION} --query "Exports[?Name=='Cloud-Systems-IoT-ApplicationSiteBucket'].Value" --output text)
aws s3 rm s3://${BOOTSTRAP_S3_BUCKET} --recursive --region $AWS_REGION
aws cloudformation delete-stack --stack-name bootstrap-resources --region $AWS_REGION

# delete lambda-products
aws cloudformation delete-stack --stack-name lambda-products --region $AWS_REGION

# delete lambda-orders
aws cloudformation delete-stack --stack-name lambda-orders --region $AWS_REGION

# delete auth-lambda
aws cloudformation delete-stack --stack-name auth-lambda --region $AWS_REGION

# delete api-gateway
aws cloudformation delete-stack --stack-name api-gateway --region $AWS_REGION

# PIPELINES

# delete web-client-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name web-client-pipeline --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $AWS_REGION
aws cloudformation delete-stack --stack-name web-client-pipeline --region $AWS_REGION

# delete lambda-products-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name lambda-products-pipeline --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $AWS_REGION
aws cloudformation delete-stack --stack-name lambda-products-pipeline --region $AWS_REGION

# delete lambda-orders-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name lambda-orders-pipeline --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $AWS_REGION
aws cloudformation delete-stack --stack-name lambda-orders-pipeline --region $AWS_REGION

# delete auth-lambda-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name auth-lambda-pipeline --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $AWS_REGION
aws cloudformation delete-stack --stack-name auth-lambda-pipeline --region $AWS_REGION

# delete api-gateway-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name api-gateway-pipeline --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $AWS_REGION
aws cloudformation delete-stack --stack-name api-gateway-pipeline --region $AWS_REGION

# if sam s3 bucket is provided, delete it
if [ ! -z "$SAM_S3_BUCKET" ]; then
    aws s3 rm s3://$SAM_S3_BUCKET --recursive --region $AWS_REGION
    aws s3 rb s3://$SAM_S3_BUCKET --region $AWS_REGION
fi