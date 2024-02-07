#!/bin/bash

for i in {900..910}; do
  # Job 파일 생성
  job_file="freesurfer-job-$i.yaml"

  # Job 정의를 job_file에 작성
  cat <<EOF > $job_file
apiVersion: batch/v1
kind: Job
metadata:
  name: freesurfer-job-$i
spec:
  template:
    spec:
      containers:
      - name: freesurfer-container
        image: freesurfer/freesurfer:latest
        command: ["recon-all"]
        args: ["-subjid", "subject$i", "-i", "/data/subject$i.nii", "-all"]
        volumeMounts:
        - name: data-volume
          mountPath: /data
      restartPolicy: Never
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: freesurfer-pvc
  backoffLimit: 0
EOF

  # 생성한 Job 파일을 사용하여 Job 실행
  kubectl apply -f $job_file
done
