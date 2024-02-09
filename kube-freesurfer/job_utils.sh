#!/bin/bash

# Job 완료 확인을 위한 함수 정의
wait_for_job_completion() {
    local logs_folder="$1"
    local job="$2"
    local log_file="${logs_folder}/${job}.log"
    local max_runtime_hours="$3" # 함수의 두 번째 인자로 max_runtime을 시간 단위로 받음

    # 시간 단위의 max_runtime을 초 단위로 변환
    local max_runtime=$(($max_runtime_hours * 3600))

    # Job의 시작 시간을 Unix timestamp로 가져옴
    local start_time_str=$(kubectl get job "$job" -o jsonpath='{.status.startTime}')
    local start_time=$(date -d "$start_time_str" +%s)

    while true; do
        local current_time=$(date +%s)
        local elapsed_time=$((current_time-start_time))

        if [ "$elapsed_time" -gt "$max_runtime" ]; then
            echo "Warning: Job $job is running for more than $max_runtime_hours hours. Attempting to terminate..."
            kubectl delete job "$job"
            echo "Warning: Job $job has been terminated after exceeding $max_runtime_hours hours of runtime." > $log_file
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
            echo "INFO: Still waiting for job $job to complete... (hours: $(($elapsed_time / 3600)) / $max_runtime_hours) (sec: $elapsed_time / $max_runtime) "
            sleep 900
        fi
    done
}
