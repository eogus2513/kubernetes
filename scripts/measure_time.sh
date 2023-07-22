#!/bin/bash

cd ../terraform || exit

terraform plan || exit

start_time=$(date +%s)

terraform apply --auto-approve

end_time=$(date +%s)

elapsed_time=$((end_time - start_time))
minutes=$((elapsed_time / 60))
seconds=$((elapsed_time % 60))

echo "Terraform Apply Success (${minutes}분 ${seconds}초 소요)"
