# TIGER_HU 安装脚本
# 用途：克隆本仓库后运行本脚本，得到完整的 TIGER_HU 项目结构。
# 用法：
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -GitUrl https://github.com/you/repo.git
# 说明：
#   - 不传 -GitUrl：03-src/ 初始化为本地 git 仓库（git init）。
#   - 传 -GitUrl：03-src/ 不做本地 git，直接把该远程仓库克隆进去。
#   - 脚本可重复执行；已存在的目录、VERSION、代码仓库不会被覆盖。

param(
    [string]$GitUrl = ''
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Write-Host "TIGER_HU 安装到: $root"

$dirs = @('00-standards','01-tmp','02-output','03-src','04-templates','05-release','06-references','07-tasks')
foreach ($d in $dirs) {
    $p = Join-Path $root $d
    if (-not (Test-Path $p)) {
        New-Item -ItemType Directory -Path $p | Out-Null
        Write-Host "  创建目录 $d"
    }
}

$versionFile = Join-Path $root '00-standards\VERSION'
if (-not (Test-Path $versionFile)) {
    Set-Content -Path $versionFile -Value '1.0' -Encoding utf8
    Write-Host '  写入 VERSION = 1.0'
}

$src = Join-Path $root '03-src'
$gitAvailable = [bool](Get-Command git -ErrorAction SilentlyContinue)
$hasRepo = Test-Path (Join-Path $src '.git')
$srcItems = @(Get-ChildItem -Force -LiteralPath $src)

if ($hasRepo) {
    $remotes = @()
    if ($gitAvailable) {
        $remotes = @(git -C $src remote 2>$null)
    }
    if ($remotes.Count -gt 0) {
        Write-Host "  03-src 已是 git 仓库（远程：$($remotes -join ', ')），跳过初始化"
    }
    else {
        Write-Host '  03-src 已是本地 git 仓库，跳过初始化'
    }
}
elseif ($srcItems.Count -gt 0) {
    Write-Host '  03-src 已有文件但未初始化 git，跳过（不覆盖已有内容）'
}
elseif ($GitUrl) {
    if (-not $gitAvailable) {
        Write-Host '  未检测到 git，无法克隆 03-src，已跳过'
    }
    else {
        & git clone $GitUrl $src
        if ($LASTEXITCODE -ne 0) {
            throw "克隆失败：$GitUrl（git 退出码 $LASTEXITCODE）；03-src 保持为空"
        }
        Write-Host "  03-src 已克隆远程仓库：$GitUrl"
    }
}
elseif (-not $gitAvailable) {
    Write-Host '  未检测到 git，跳过 03-src 的 git init'
}
else {
    git -C $src init | Out-Null
    Write-Host '  03-src 已执行 git init（本地 git）'
}

Write-Host '完成。目录约定见 00-standards/PROJECT-STRUCTURE.md'
