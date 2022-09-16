if [ -z "$1" ]; then
    echo "Usage: $0 <AWS REGION>"
    exit 0
fi

# STACKS WITH RESOURCES

# delete bootstrap
BOOTSTRAP_S3_BUCKET=$(aws cloudformation list-exports --region ${AWS_REGION} --query "Exports[?Name=='Cloud-Systems-IoT-ApplicationSiteBucket'].Value" --output text)
aws s3 rm s3://${BOOTSTRAP_S3_BUCKET} --recursive --region $1
sam delete --stack-name bootstrap-resources --region $1

# delete lambda-products
sam delete --stack-name lambda-products --region $1

# delete lambda-orders
sam delete --stack-name lambda-orders --region $1

# delete auth-lambda
sam delete --stack-name auth-lambda --region $1

# delete api-gateway
sam delete --stack-name api-gateway --region $1

# PIPELINES

# delete web-client-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name web-client --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $1
sam delete --stack-name web-client-pipeline --region $1

# delete lambda-products-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name lambda-products-pipeline --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $1
sam delete --stack-name lambda-products-pipeline --region $1

# delete lambda-orders-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name lambda-orders-pipeline --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $1
sam delete --stack-name lambda-orders-pipeline --region $1

# delete auth-lambda-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name auth-lambda-pipeline --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $1
sam delete --stack-name auth-lambda-pipeline --region $1

# delete api-gateway-pipeline
PIPELINE_BUCKET=$(aws cloudformation list-stack-resources --stack-name api-gateway-pipeline --region ${AWS_REGION} --query "StackResourceSummaries[?LogicalResourceId == 'PipelineBucket'].PhysicalResourceId" --output text)
aws s3 rm s3://${PIPELINE_BUCKET} --recursive --region $1
sam delete --stack-name api-gateway-pipeline --region $1