# 清理Windows临时文件 (优化版)
Write-Host "`n开始系统清理操作..." -ForegroundColor Cyan
$startFreeSpace = (Get-PSDrive -Name C).Free

# 1. 临时文件清理 (添加错误处理和进度显示)
Write-Host "`n[1/7] 清理临时文件..." -ForegroundColor Yellow
try {
    Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction Stop | Remove-Item -Recurse -Force -ErrorAction Stop
    Write-Host "  - 用户临时文件清理完成" -ForegroundColor Green
}
catch {
    Write-Host "  ! 部分文件清理失败: $_" -ForegroundColor Red
}

# 2. Windows更新缓存 (添加服务状态检查)
Write-Host "`n[2/7] 清理Windows更新缓存..." -ForegroundColor Yellow
$service = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
if ($service.Status -eq 'Running') {
    try {
        Stop-Service -Name wuauserv -Force -ErrorAction Stop
        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction Stop
        Write-Host "  - 更新缓存清理完成" -ForegroundColor Green
    }
    catch {
        Write-Host "  ! 更新缓存清理失败: $_" -ForegroundColor Red
    }
    finally {
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "  - 跳过 (服务未运行)" -ForegroundColor DarkGray
}

# 3. 系统日志清理 (添加日志类型循环)
Write-Host "`n[3/7] 清理系统日志..." -ForegroundColor Yellow
$logs = @('Application', 'Security', 'System', 'Setup')
foreach ($log in $logs) {
    try {
        wevtutil cl $log
        Write-Host "  - $log 日志已清除" -ForegroundColor Green
    }
    catch {
        Write-Host "  ! $log 日志清除失败" -ForegroundColor Red
    }
}

# 4. 回收站清理 (多驱动器支持)
Write-Host "`n[4/7] 清理回收站..." -ForegroundColor Yellow
Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    try {
        Clear-RecycleBin -DriveLetter $_.Name -Force -ErrorAction Stop
        Write-Host "  - 驱动器 $($_.Name): 回收站已清空" -ForegroundColor Green
    }
    catch {
        Write-Host "  ! 驱动器 $($_.Name): 回收站清理失败" -ForegroundColor Red
    }
}

# 5. 缩略图缓存 (添加存在性检查)
Write-Host "`n[5/7] 清理缩略图缓存..." -ForegroundColor Yellow
$thumbCachePath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
if (Test-Path $thumbCachePath) {
    try {
        Get-ChildItem $thumbCachePath -Filter "thumbcache_*.db" -ErrorAction Stop | Remove-Item -Force -ErrorAction Stop
        Write-Host "  - 缩略图缓存已清除" -ForegroundColor Green
    }
    catch {
        Write-Host "  ! 部分缩略图缓存删除失败" -ForegroundColor Red
    }
} else {
    Write-Host "  - 跳过 (目录不存在)" -ForegroundColor DarkGray
}

# 6. 浏览器缓存 (扩展多浏览器支持)
Write-Host "`n[6/7] 清理浏览器缓存..." -ForegroundColor Yellow
$browserPaths = @(
    # Edge
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\*\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\*\Code Cache",
    
    # Chrome
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Code Cache",
    
    # Firefox
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2",
    
    # IE
    "$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files"
)

foreach ($path in $browserPaths) {
    try {
        $resolvedPaths = Resolve-Path $path -ErrorAction SilentlyContinue
        foreach ($rpath in $resolvedPaths) {
            if (Test-Path $rpath.Path) {
                Remove-Item -Path "$($rpath.Path)\*" -Recurse -Force -ErrorAction Stop
            }
        }
    }
    catch {
        Write-Host "  ! 清理失败: $($path.Split('\')[-1])" -ForegroundColor Red
    }
}
Write-Host "  - 浏览器缓存清理完成" -ForegroundColor Green

# 7. 磁盘清理工具 (添加超时检测)
Write-Host "`n[7/7] 运行磁盘清理工具..." -ForegroundColor Yellow
try {
    $cleanmgr = Start-Process cleanmgr -ArgumentList "/sagerun:1" -PassThru -NoNewWindow -Wait -ErrorAction Stop
    if ($cleanmgr.ExitCode -eq 0) {
        Write-Host "  - 磁盘清理完成" -ForegroundColor Green
    } else {
        Write-Host "  ! 磁盘清理异常退出 (代码: $($cleanmgr.ExitCode))" -ForegroundColor Red
    }
}
catch {
    Write-Host "  ! 无法启动磁盘清理工具: $_" -ForegroundColor Red
}

# 显示清理结果
$endFreeSpace = (Get-PSDrive -Name C).Free
$spaceFreed = ($endFreeSpace - $startFreeSpace) / 1GB
Write-Host "`n清理操作完成! 释放空间: $("{0:N2} GB" -f $spaceFreed)`n" -ForegroundColor Cyan