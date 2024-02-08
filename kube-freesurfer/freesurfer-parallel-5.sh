#!/bin/bash

# 인자로부터 값 받기
lbl=$1
usr=$2
idx1=$3
idx2=$4
idx3=$5
idx4=$6
idx5=$7

# 원본 및 새 파일명 정의
original_file="freesurfer-job-template.yml"
new_file="freesurfer-job-${lbl}-${idx1}.yml"

# sed를 사용하여 변수 대체하고 결과를 새 파일에 저장
sed "s/\${LBL}/$lbl/g; s/\${USR}/$usr/g; s/\${IDX1}/$idx1/g; s/\${IDX2}/$idx2/g; s/\${IDX3}/$idx3/g; s/\${IDX4}/$idx4/g; s/\${IDX5}/$idx5/g" $original_file > $new_file

kubectl apply -f $new_file

# Job 이름 정의
job_name="freesurfer-job-${lbl}-${idx1}"

# Job이 완료될 때까지 기다림
while true; do
    # Job 상태 체크
    status=$(kubectl get job $job_name -o=jsonpath='{.status.conditions[?(@.type=="Complete")].status}')
    
    # Job 상태가 True면 완료됨
    if [ "$status" == "True" ]; then
        echo "Job $job_name completed successfully."
        break
    else
        echo "Waiting for job $job_name to complete..."
        sleep 3600  # 1시간 동안 대기
    fi
done