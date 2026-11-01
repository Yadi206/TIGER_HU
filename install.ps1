# TIGER_HU 安装脚本
# 用途：克隆本仓库后运行本脚本，得到完整的 TIGER_HU 项目结构。
# 用法：powershell -ExecutionPolicy Bypass -File .\install.ps1
# 说明：脚本可重复执行；已存在的目录、VERSION、git 仓库不会被覆盖。

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
if (-not (Test-Path (Join-Path $src '.git'))) {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        git -C $src init | Out-Null
        Write-Host '  03-src 已执行 git init'
    }
    else {
        Write-Host '  未检测到 git，跳过 03-src 的 git init'
    }
}

Write-Host '完成。目录约定见 00-standards/PROJECT-STRUCTURE.md'
