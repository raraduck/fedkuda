# FedKuda

### 0. Cluster join
```
anp -i inventory/firstCluster/inventory.ini cluster.yml -v -b --become-user=root -e ansible_ssh_timeout=60 --limit vk02
```

### 1. Initialization requirements
```
kubectl label nodes [node name] key=[node label]
ex> kubectl label nodes vk02 key=vk
```
### 2. ssh-copy-id
```
ssh-copy-id -i ~/.ssh/[pub key] root@[ip] -p [node port]
ex> ssh-copy-id -i ~/.ssh/id_ed25519.pub root@10.246.246.23 -p 30023
password: ****
```

### TODO: ans-fedkuda
#### 2024-01-30
- [x] main_worker.py 에서 Cent_avg_{rnd} 파일 읽어서 모델 학습 rnd: 1~N
- [x] main_center.py 에서 Cent_avg를 만들고 Fed_avg로 배포하여 main_worker에서 Fed_avg로 읽음
- [x] Pre, Post-test 와 Solo, Fed-train 표기 추가 (type 변수)
- [ ] mnist_cnn.state라는 파일을 main_worker.py가 생성하며, ansible에서 이름 변경하면서 가져오는 상황 --> mnist_cnn.state 파일명을 좀 더 general하게 수정
- [ ] fedkuda repo 에 push 되었을 때 hook로 control node에 pull 수행
- [ ] Cluster20_fedkuda-fed_MNIST의 stage3에서 mdl을 vd30021 모델을 지정하여 사용중이므로, 나중에 최적 파라미터 선별하여 수행

#### 2024-01-31
- [x] jenkinsfile-pull 로 SCM + webhook 적용 (test try 2)
- [x] solokuda와 fedkuda jenkinsfile 추가 후, solokuda만 SCM 적용
- [ ] models와 dataset 모듈 파일로 분리하기
- [ ] logger 가 생성한 파일을 Fetch하도록 추가

####
```
sudo docker run -it --rm -v /home2/dwnusa/Downloads/.license:/usr/local/freesurfer/.license -v /home2/dwnusa/2024_data/FREESURFER/PPMI:/root/data -v /home2/dwnusa/2024_data/FREESURFER/FREESURFER_PPMI:/root/output freesurfer/freesurfer:7.2.0 /bin/bash -c "source /usr/local/freesurfer/SetUpFreeSurfer.sh; recon-all -subjid 4139 -i /root/data/4139.nii -sd /root/output -all"
```
