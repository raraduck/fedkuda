#!/bin/bash

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

        if [ "$elapsed_time" -gt 21600 ]; then
            echo "Warning: Job $job is running for more than 6 hours. Attempting to terminate..."
            kubectl delete job "$job"
            echo "Warning: Job $job has been terminated after exceeding 6 hours of runtime." > $log_file
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
            echo "INFO: Still waiting for job $job to complete... (elapsed: $elapsed_time)"
            sleep 900
        fi
    done
}
