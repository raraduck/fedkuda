import socket
import time
import sys
import json

import argparse
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torchvision import datasets, transforms
from torch.optim.lr_scheduler import StepLR

class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.conv1 = nn.Conv2d(1, 32, 3, 1)
        self.conv2 = nn.Conv2d(32, 64, 3, 1)
        self.dropout1 = nn.Dropout(0.25)
        self.dropout2 = nn.Dropout(0.5)
        self.fc1 = nn.Linear(9216, 128)
        self.fc2 = nn.Linear(128, 10)

    def forward(self, x):
        x = self.conv1(x)
        x = F.relu(x)
        x = self.conv2(x)
        x = F.relu(x)
        x = F.max_pool2d(x, 2)
        x = self.dropout1(x)
        x = torch.flatten(x, 1)
        x = self.fc1(x)
        x = F.relu(x)
        x = self.dropout2(x)
        x = self.fc2(x)
        output = F.log_softmax(x, dim=1)
        return output
    
class FedKuda:
    def __init__(self, args):
        # args 객체의 모든 속성을 self 변수로 복사
        for key, value in vars(args).items():
            setattr(self, key, value)

    def train(self, model, device, train_loader, optimizer, epoch):
        model.train()
        for batch_idx, (data, target) in enumerate(train_loader):
            data, target = data.to(device), target.to(device)
            optimizer.zero_grad()
            output = model(data)
            loss = F.nll_loss(output, target)
            loss.backward()
            optimizer.step()
            if batch_idx % self.log_interval == 0:
                print('Train Epoch: {} [{}/{} ({:.0f}%)]\tLoss: {:.6f}'.format(
                    epoch, batch_idx * len(data), len(train_loader.dataset),
                    100. * batch_idx / len(train_loader), loss.item()))
                if self.dry_run:
                    break

    def test(self, model, device, test_loader):
        model.eval()
        test_loss = 0
        correct = 0
        with torch.no_grad():
            for data, target in test_loader:
                data, target = data.to(device), target.to(device)
                output = model(data)
                test_loss += F.nll_loss(output, target, reduction='sum').item()  # sum up batch loss
                pred = output.argmax(dim=1, keepdim=True)  # get the index of the max log-probability
                correct += pred.eq(target.view_as(pred)).sum().item()

        test_loss /= len(test_loader.dataset)

        print('\nTest set: Average loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)\n'.format(
            test_loss, correct, len(test_loader.dataset),
            100. * correct / len(test_loader.dataset)))
    
    def main(self):
        use_cuda = not self.no_cuda and torch.cuda.is_available()
        use_mps = self.no_mps

        torch.manual_seed(self.seed)

        if use_cuda:
            device = torch.device("cuda")
        elif use_mps:
            device = torch.device("mps")
        else:
            device = torch.device("cpu")

        train_kwargs = {'batch_size': self.batch_size}
        test_kwargs = {'batch_size': self.test_batch_size}
        if use_cuda:
            cuda_kwargs = {'num_workers': 1,
                          'pin_memory': True,
                          'shuffle': True}
            train_kwargs.update(cuda_kwargs)
            test_kwargs.update(cuda_kwargs)

        transform=transforms.Compose([
            transforms.ToTensor(),
            transforms.Normalize((0.1307,), (0.3081,))
            ])
        dataset1 = datasets.MNIST('./data', train=True, download=True,
                          transform=transform)
        dataset2 = datasets.MNIST('./data', train=False,
                          transform=transform)
        train_loader = torch.utils.data.DataLoader(dataset1,**train_kwargs)
        test_loader = torch.utils.data.DataLoader(dataset2, **test_kwargs)

        model = Net().to(device)
        optimizer = optim.Adadelta(model.parameters(), lr=self.lr)

        scheduler = StepLR(optimizer, step_size=1, gamma=self.gamma)
        for epoch in range(1, self.epochs + 1):
            self.train(model, device, train_loader, optimizer, epoch)
            self.test(model, device, test_loader)
            scheduler.step()

        if self.save_model:
            torch.save(model.state_dict(), "mnist_cnn.pt")

# JSON 파일로부터 설정 읽기
def read_config(config_file):
    with open(config_file, 'r') as file:
        config = json.load(file)
    return config

if __name__ == "__main__":
    try:
        # argparse를 사용하여 JSON 파일 경로를 명령줄 인자로 받음
        parser = argparse.ArgumentParser(description="FedKuda args")
        parser.add_argument('-c', '--config', required=True, type=str, help='Path to the config JSON file')

        args = parser.parse_args()

        # JSON 파일에서 설정 읽기
        config = read_config(args.config)

        # FedApp 인스턴스 생성 및 실행
        app = FedKuda(argparse.Namespace(**config))
        app.main()

    except Exception as e:
        raise e
