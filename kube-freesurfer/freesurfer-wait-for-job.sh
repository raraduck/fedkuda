#!/bin/bash

# 사용법: ./freesurfer-wait_for_job.sh <job-name> <logs-folder> <max-runtime-hours>
JOB_NAME=$1
LOGS_FOLDER=$2
MAX_RUNTIME_HOURS=$3

# 로그 파일 경로 설정
LOG_FILE="${LOGS_FOLDER}/${JOB_NAME}.log"
# 로그 파일을 저장할 폴더 생성
mkdir -p $LOGS_FOLDER

# 최대 실행 시간을 초 단위로 변환
MAX_RUNTIME_SECONDS=$((MAX_RUNTIME_HOURS * 3600))

# Job의 시작 시간을 Unix timestamp로 가져옴
START_TIME_STR=$(kubectl get job "$JOB_NAME" -o jsonpath='{.status.startTime}')
START_TIME=$(date -d "$START_TIME_STR" +%s)

while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

    # 최대 실행 시간 초과 검사
    if [ "$ELAPSED_TIME" -gt "$MAX_RUNTIME_SECONDS" ]; then
        echo "Warning: Job $JOB_NAME is running longer than $MAX_RUNTIME_HOURS hours. Attempting to terminate..."
        kubectl delete job "$JOB_NAME"
        echo "Warning: Job $JOB_NAME has been terminated after exceeding $MAX_RUNTIME_HOURS hours of runtime." >> $LOG_FILE
        exit 1
    fi

    # Job 완료 상태 확인
    if kubectl get job "$JOB_NAME" -o 'jsonpath={.status.conditions[?(@.type=="Complete")].status}' | grep -q "True"; then
        echo "INFO: Job $JOB_NAME completed successfully." >> $LOG_FILE
        exit 0
    elif kubectl get job "$JOB_NAME" -o 'jsonpath={.status.conditions[?(@.type=="Failed")].status}' | grep -q "True"; then
        echo "Error: Job $JOB_NAME failed." >> $LOG_FILE
        echo "Error: Job $JOB_NAME failed. Details logged to $LOG_FILE."
        exit 1
    else
        echo "INFO: Still waiting for job $JOB_NAME to complete... (elapsed hours: $(($ELAPSED_TIME / 3600)) / $MAX_RUNTIME_HOURS) (seconds: $ELAPSED_TIME)"
        sleep 60
    fi
done
