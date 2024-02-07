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
