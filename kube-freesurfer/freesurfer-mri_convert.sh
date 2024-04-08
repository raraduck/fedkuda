#!/bin/bash
src_path=$1
trg_path=$2

# trg_path 경로가 존재하지 않는 경우, 디렉토리 생성
if [ ! -d "$trg_path" ]; then
    mkdir -p "$trg_path"
fi

# src_path 내부의 모든 폴더를 순회합니다.
for folder in $(find $src_path -mindepth 1 -maxdepth 1 -type d)
do
  # 각 폴더 내부의 mri 폴더가 있는지 확인합니다.
  if [ -d "$folder/mri" ]; then
    # 복사할 대상 경로를 생성합니다. 이때 원본 폴더 구조를 유지합니다.
    dest_folder="${trg_path}/$(basename $folder)"
    mkdir -p "$dest_folder"

    # # mri 폴더를 대상 경로로 복사합니다.
    # cp "~/GAAIN/FBB/AD/PT/$folder.nii" "$dest_folder" ;

    mri_convert "$folder/mri/aseg.mgz" --frame 0 "$dest_folder/aseg.nii.gz" ;
    mri_convert "$folder/mri/aparc+aseg.mgz" --frame 0 "$dest_folder/aparc+aseg.nii.gz" ;
    mri_convert "$folder/mri/orig.mgz" --frame 0 "$dest_folder/orig.nii" ;
    mri_convert "$folder/mri/brainmask.mgz" --frame 0 "$dest_folder/brainmask.nii.gz" ;
    mri_convert "$folder/mri/brain.mgz" --frame 0 "$dest_folder/brain.nii.gz" ;
  fi
done

echo "모든 mri 폴더가 ${src_path} --> ${trg_path}로 복사되었습니다."
