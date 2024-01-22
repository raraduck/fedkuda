import torch

def main():
    cuda_available = torch.cuda.is_available()
    print(f"CUDA available: {cuda_available}")

if __name__ == "__main__":
    main()