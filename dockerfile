# 필요한 패키지 설치 및 SSH 설정
FROM nvidia/cuda:12.3.1-base-ubuntu22.04

RUN apt-get update && \
    apt-get install -y python3.10 python3-pip openssh-server && \
    ln -s /usr/bin/python3.10 /usr/bin/python && \
    pip3 install torchio torchvision torchsummary SimpleITK tqdm opencv-python tensorboard natsort pandas matplotlib jupyterlab medmnist && \
    mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    rm -rf /var/lib/apt/lists/*

# SSH 포트 열기
EXPOSE 22

# SSH 서버 실행
CMD ["/usr/sbin/sshd", "-D"]


