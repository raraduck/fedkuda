import torch
import socket
import time

def main():
    cuda_available = torch.cuda.is_available()
    print(f"CUDA available: {cuda_available}")
    # 현재 시스템의 호스트명을 가져옵니다.
    hostname = socket.gethostname()
    print(f"Hostname: {hostname}")
    # 5초 동안 실행되는 for 루프
    for i in range(50):
        time.sleep(0.1)  # 각 반복에서 0.1초 대기

if __name__ == "__main__":
    main()
