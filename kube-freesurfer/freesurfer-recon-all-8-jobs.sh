#!/bin/bash

# 인자로부터 값 받기
lbl=$1
usr=$2
idx1=$3
idx2=$4
idx3=$5
idx4=$6
idx5=$7
idx6=$8
idx7=$9
idx8=$10


# 로그 파일과 새 YAML 파일을 저장할 폴더 확인 및 생성
mkdir -p logs

# 원본 및 새 파일명 정의
original_file="freesurfer-recon-all-8-jobs.yml"
new_file="logs/freesurfer-recon-all-jobs-${lbl}-${idx1}-${idx2}-${idx3}-${idx4}-${idx5}-${idx6}-${idx7}-${idx8}.yml"

# sed를 사용하여 변수 대체하고 결과를 새 파일에 저장
sed "s/\${LBL}/$lbl/g; s/\${USR}/$usr/g; s/\${IDX1}/$idx1/g; s/\${IDX2}/$idx2/g; s/\${IDX3}/$idx3/g; s/\${IDX4}/$idx4/g; s/\${IDX5}/$idx5/g; s/\${IDX5}/$idx6/g; s/\${IDX5}/$idx7/g; s/\${IDX5}/$idx8/g" $original_file > $new_file

kubectl apply -f $new_file

# Job 완료 확인을 위한 함수 정의
wait_for_job_completion() {
    local job="$1"
    local log_file="logs/${job}.log"
    
    # Job의 시작 시간을 Unix timestamp로 가져옴
    local start_time_str=$(kubectl get job "$job" -o jsonpath='{.status.startTime}')
    local start_time=$(date -d "$start_time_str" +%s)
    
    echo "Waiting for job $job to complete..."
    
    while true; do
        local current_time=$(date +%s)
        local elapsed_time=$((current_time-start_time))

        # Job의 실행 시간이 6시간(21600초)을 초과했는지 체크 0.5시간(1800초)
        if [ "$elapsed_time" -gt 1800 ]; then
            echo "Job $job is running for more than 0.5 hours. Attempting to terminate..."
            kubectl delete job "$job"
            echo "Job $job has been terminated after exceeding 0.5 hours of runtime." > $log_file
            return 0
        fi

        # Job 상태 체크
        if kubectl get job "$job" -o 'jsonpath={.status.conditions[?(@.type=="Complete")].status}' | grep -q "True"; then
            echo "Job $job completed successfully."
            return 0
        elif kubectl get job "$job" -o 'jsonpath={.status.conditions[?(@.type=="Failed")].status}' | grep -q "True"; then
            echo "Job $job failed." > $log_file
            echo "Error: Job $job failed. Details logged to $log_file."
            return 1
        else
            echo "Still waiting for job $job to complete... (elapsed: $elapsed_time)"
            sleep 900
        fi
    done
}

# 생성된 Job들의 완료를 기다림
for idx in $idx1 $idx2 $idx3 $idx4 $idx5 $idx6 $idx7 $idx8; do
    job_name="freesurfer-recon-all-job-${lbl}-${idx}"
    echo "Processing job: $job_name"
    if ! wait_for_job_completion "$job_name"; then
        # 에러 메시지는 각 Job의 로그 파일에 기록됩니다.
        echo "Error encountered with job $job_name. See logs/${job_name}.log for details."
    fi
done

echo "All specified jobs processing attempted. Check logs folder for any errors."