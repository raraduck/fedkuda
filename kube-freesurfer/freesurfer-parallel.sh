#!/bin/bash

for i in {900..910}; do
  # Job 파일 이름 정의
  job_file="freesurfer-job-template.yaml"

  # 템플릿 파일에서 ${INDEX}를 실제 인덱스 값으로 대체하여 job_file 생성
  sed "s/\${INDEX}/$i/g" freesurfer-job-template.yaml > $job_file

  # 생성한 Job 파일을 사용하여 Job 실행
  kubectl apply -f $job_file
done