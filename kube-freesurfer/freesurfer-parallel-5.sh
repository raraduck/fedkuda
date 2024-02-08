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

# Job 완료 확인을 위한 함수 정의
wait_for_job_completion() {
    local job="$1"
    echo "Waiting for job $job to complete..."
    while true; do
        # Job 상태 체크
        if kubectl get job "$job" -o 'jsonpath={.status.conditions[?(@.type=="Complete")].status}' | grep -q "True"; then
            echo "Job $job completed successfully."
            return 0
        elif kubectl get job "$job" -o 'jsonpath={.status.conditions[?(@.type=="Failed")].status}' | grep -q "True"; then
            echo "Job $job failed."
            return 1
        else
            echo "Still waiting for job $job to complete..."
            sleep 1800
        fi
    done
}

# 생성된 Job들의 완료를 기다림
for idx in $idx1 $idx2 $idx3 $idx4 $idx5; do
    job_name="freesurfer-job-${lbl}-${idx}"
    if ! wait_for_job_completion "$job_name"; then
        echo "Error: Processing of job $job_name encountered an error."
        exit 1
    fi
done

echo "All specified jobs completed successfully."