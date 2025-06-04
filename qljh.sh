#!/bin/bash

# 清理APT缓存
echo "清理APT缓存..."
sudo apt clean
sudo apt autoclean

# 移除无用依赖包
echo "移除无用依赖包..."
sudo apt autoremove
sudo apt autoremove --purge

# 清理旧内核
echo "清理旧内核..."
sudo apt purge $(dpkg --list | grep 'linux-image.*[0-9]' | awk '{print $3,$2}' | sort -nr | tail -n +2 | grep -v $(uname -r) | awk '{print $2}')

# 清理日志文件
echo "清理日志文件..."
sudo journalctl --vacuum-time=7d
sudo rm -rf /var/log/*.gz /var/log/*.old

# 清理临时文件
echo "清理临时文件..."
sudo rm -rf /tmp/*
rm -rf ~/.cache/*

# 清理Thumbnail缓存
echo "清理Thumbnail缓存..."
rm -rf ~/.cache/thumbnails/*

# 使用工具自动化清理
echo "安装bleachbit进行深度清理..."
sudo apt install -y bleachbit
bleachbit --gui &

# 检查大文件/目录
echo "检查大文件/目录..."
sudo du -sh /var/*
sudo du -ah / | sort -rh | head -n 20

echo "清理完成！"