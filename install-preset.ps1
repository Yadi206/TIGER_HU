# TIGER_HU 预设安装脚本
# 作用：把 presets/TIGER_HU.yml 这份 agent 预设写进 DSH 的 profile 补丁层，
#       并把 agent-preset-registry 的 selectedDefault 指向 TIGER_HU。
# 用法：powershell -ExecutionPolicy Bypass -File .\install-preset.ps1
# 前置：DSH 至少启动过一次（已生成 profiles/<profile>/cordis.patch.yml）。
# 可重复执行：已存在 preset-TIGER_HU 时不会重复追加；每次都会先备份。

$ErrorActionPreference = 'Stop'

$dshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $env:USERPROFILE '.dsh' }
$profileName = if ($env:DSH_PROFILE) { $env:DSH_PROFILE } else { 'web' }
$profileDir = Join-Path $dshHome (Join-Path 'profiles' $profileName)
$patchPath = Join-Path $profileDir 'cordis.patch.yml'
$fragmentPath = Join-Path $PSScriptRoot 'presets\TIGER_HU.yml'

if (-not (Test-Path $fragmentPath)) { throw "找不到预设文件：$fragmentPath" }

if (-not (Test-Path $patchPath)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    $header = @(
        '# Your patch layer for this dsh profile, applied after every bundle layer:',
        '# a top-level YAML array of loader patch entries (id-targeted config',
        '# overrides, disables, and insert lists; `!!js` expressions allowed).',
        ''
    ) -join [Environment]::NewLine
    [System.IO.File]::WriteAllText($patchPath, $header + [Environment]::NewLine, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "已创建补丁层：$patchPath"
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$text = [System.IO.File]::ReadAllText($patchPath, $utf8)

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$patchPath.bak-$stamp"
Copy-Item $patchPath $backup
Write-Host "已备份到：$backup"

if ($text -match 'preset-TIGER_HU') {
    Write-Host '预设 TIGER_HU 已存在，跳过追加。'
}
else {
    $fragment = [System.IO.File]::ReadAllText($fragmentPath, $utf8)
    $text = $text.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $fragment.TrimEnd() + [Environment]::NewLine
    Write-Host '已追加预设 TIGER_HU（复制自 ptc 组合，含项目目录约定）。'
}

if ($text -match '(?m)^\s*selectedDefault:') {
    $text = [regex]::Replace($text, '(?m)^(\s*)selectedDefault:.*$', '$1selectedDefault: TIGER_HU')
    Write-Host 'agent-preset-registry.selectedDefault 已指向 TIGER_HU。'
}
elseif ($text -match '(?m)^\s*- id: agent-preset-registry') {
    $extra = @(
        '',
        '- id: agent-preset-registry',
        "  name: '@deepseek-ai/dsh-agent-preset-registry'",
        '  config:',
        '    selectedDefault: TIGER_HU'
    ) -join [Environment]::NewLine
    $text = $text.TrimEnd() + [Environment]::NewLine + $extra + [Environment]::NewLine
    Write-Host '已为 agent-preset-registry 补充 selectedDefault。'
}
else {
    $extra = @(
        '',
        '- id: agent-preset-registry',
        "  name: '@deepseek-ai/dsh-agent-preset-registry'",
        '  config:',
        '    default: standard',
        '    selectedDefault: TIGER_HU'
    ) -join [Environment]::NewLine
    $text = $text.TrimEnd() + [Environment]::NewLine + $extra + [Environment]::NewLine
    Write-Host '已注册 agent-preset-registry 并选中 TIGER_HU。'
}

[System.IO.File]::WriteAllText($patchPath, $text, $utf8)

Write-Host ''
Write-Host "完成：$patchPath"
Write-Host '重启 DSH 后，新建会话即可选择 TIGER_HU 预设。'
