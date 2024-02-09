#!/bin/bash

# Job 완료 확인을 위한 함수 정의
wait_for_job_completion() {
    local job="$1"
    local log_file="logs/${job}.log"
    
    # 최대 실행 시간을 초 단위로 설정 (예: 6시간)
    local max_runtime="$2" # 추가된 부분: 함수의 두 번째 인자로 max_runtime을 받음

    # Job의 시작 시간을 Unix timestamp로 가져옴
    local start_time_str=$(kubectl get job "$job" -o jsonpath='{.status.startTime}')
    local start_time=$(date -d "$start_time_str" +%s)
    
    echo "Waiting for job $job to complete..."

    while true; do
        local current_time=$(date +%s)
        local elapsed_time=$((current_time-start_time))

        if [ "$elapsed_time" -gt "$max_runtime" ]; then
            echo "Warning: Job $job is running for more than $(($max_runtime / 3600)) hours. Attempting to terminate..."
            kubectl delete job "$job"
            echo "Warning: Job $job has been terminated after exceeding $(($max_runtime / 3600)) hours of runtime." > $log_file
            return 0
        fi

        if kubectl get job "$job" -o 'jsonpath={.status.conditions[?(@.type=="Complete")].status}' | grep -q "True"; then
            echo "INFO: Job $job completed successfully."
            return 0
        elif kubectl get job "$job" -o 'jsonpath={.status.conditions[?(@.type=="Failed")].status}' | grep -q "True"; then
            echo "Error: Job $job failed." > $log_file
            echo "Error: Job $job failed. Details logged to $log_file."
            return 1
        else
            echo "INFO: Still waiting for job $job to complete... (elapsed: $elapsed_time / $max_runtime)"
            sleep 900
        fi
    done
}
