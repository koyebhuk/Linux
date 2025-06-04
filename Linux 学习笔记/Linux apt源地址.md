## 由于默认镜像可能不可用，建议更换为国内更稳定的源：

## （1）备份原有源列表
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

## （2）编辑源列表
sudo nano /etc/apt/sources.list
## 删除原有内容，替换为清华源（推荐）：
deb https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free non-free-firmware

## 或阿里源：
deb https://mirrors.aliyun.com/kali kali-rolling main contrib non-free non-free-firmware
deb-src https://mirrors.aliyun.com/kali kali-rolling main contrib non-free non-free-firmware

## （3）更新软件包缓存
sudo apt update