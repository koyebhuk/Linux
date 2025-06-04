# 要求管理员权限
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

# 清理主程序
Write-Host "`n=== 系统清理工具 v2.0 ===" -ForegroundColor Cyan
$startFreeSpace = (Get-PSDrive -Name C).Free

# 清理任务数组
$cleanTasks = @(
    { 
        Write-Host "`n[1/7] 清理临时文件..." -ForegroundColor Yellow
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    },
    {
        Write-Host "`n[2/7] 清理更新缓存..." -ForegroundColor Yellow
        try {
            Stop-Service wuauserv -Force -ErrorAction Stop
            Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction Stop
        } finally { Start-Service wuauserv -ErrorAction SilentlyContinue }
    },
    {
        Write-Host "`n[3/7] 清理系统日志..." -ForegroundColor Yellow
        "Application", "Security", "System", "Setup" | ForEach-Object {
            wevtutil cl $_ 2>&1 | Out-Null
        }
    },
    {
        Write-Host "`n[4/7] 清理回收站..." -ForegroundColor Yellow
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    },
    {
        Write-Host "`n[5/7] 清理缩略图缓存..." -ForegroundColor Yellow
        Get-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -ErrorAction SilentlyContinue | Remove-Item -Force
    },
    {
        Write-Host "`n[6/7] 清理浏览器缓存..." -ForegroundColor Yellow
        $paths = @(
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\*\Cache",
            "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Cache",
            "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2",
            "$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files"
        )
        $paths | ForEach-Object { Remove-Item "$_\*" -Recurse -Force -ErrorAction SilentlyContinue }
    },
    {
        Write-Host "`n[7/7] 运行磁盘清理..." -ForegroundColor Yellow
        Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait -WindowStyle Hidden
    }
)

# 执行所有清理任务
$cleanTasks | ForEach-Object { Invoke-Command $_ }

# 显示清理结果
$endFreeSpace = (Get-PSDrive -Name C).Free
$spaceFreed = [math]::Round(($endFreeSpace - $startFreeSpace) / 1GB, 2)
Write-Host "`n清理完成! 释放空间: $spaceFreed GB" -ForegroundColor Green
Write-Host "`n按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")