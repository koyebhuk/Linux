# 清理Windows临时文件
Write-Host "清理临时文件..."
Remove-Item -Path "$env:TEMP\*" -Recurse -Force

# 清理Windows更新缓存
Write-Host "清理Windows更新缓存..."
Stop-Service -Name wuauserv -Force
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
Start-Service -Name wuauserv

# 清理系统日志
Write-Host "清理系统日志..."
wevtutil cl Application
wevtutil cl Security
wevtutil cl System

# 清理回收站
Write-Host "清理回收站..."
Clear-RecycleBin -Force

# 清理缩略图缓存
Write-Host "清理缩略图缓存..."
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*" -Force

# 清理Windows临时Internet文件
Write-Host "清理临时Internet文件..."
Remove-WebBrowserIECache

# 使用Disk Cleanup工具
Write-Host "启动磁盘清理工具..."
Start-Process cleanmgr -ArgumentList "/sagerun:1"

Write-Host "清理完成！"
