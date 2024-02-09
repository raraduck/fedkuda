#!/bin/bash

# 외부 파일 소싱
source job_utils.sh

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
idx8=${10} # 수정된 부분


# 로그 파일과 새 YAML 파일을 저장할 폴더 확인 및 생성
mkdir -p logs

# 원본 및 새 파일명 정의
original_file="freesurfer-recon-all-8-jobs.yml"
new_file="logs/freesurfer-recon-all-jobs-${lbl}-${idx1}-${idx2}-${idx3}-${idx4}-${idx5}-${idx6}-${idx7}-${idx8}.yml"

# sed를 사용하여 변수 대체하고 결과를 새 파일에 저장
sed "s/\${LBL}/$lbl/g; s/\${USR}/$usr/g; s/\${IDX1}/$idx1/g; s/\${IDX2}/$idx2/g; s/\${IDX3}/$idx3/g; s/\${IDX4}/$idx4/g; s/\${IDX5}/$idx5/g; s/\${IDX6}/$idx6/g; s/\${IDX7}/$idx7/g; s/\${IDX8}/$idx8/g" $original_file > $new_file

kubectl apply -f $new_file

# 생성된 Job들의 완료를 기다림
for idx in $idx1 $idx2 $idx3 $idx4 $idx5 $idx6 $idx7 $idx8; do
    job_name="freesurfer-recon-all-job-${lbl}-${idx}"
    echo "Processing job: $job_name"
    if ! wait_for_job_completion "$job_name" 21600; then
        # 에러 메시지는 각 Job의 로그 파일에 기록됩니다.
        echo "Error encountered with job $job_name. See logs/${job_name}.log for details."
    fi
done

echo "All specified jobs processing attempted. Check logs folder for any errors."