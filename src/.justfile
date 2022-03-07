deploy-all:
    @just deploy-backend profiles

build-backend MODULE:
    python3 ./scripts/build-lambdas.py {{MODULE}}

deploy-backend MODULE: 
    @just build-backend {{MODULE}}
    terraform apply -auto-approve

deploy-client BUCKET_NAME:
    cd ./client
    npm build
    aws s3 sync ./build/ s3://{{BUCKET_NAME}}
