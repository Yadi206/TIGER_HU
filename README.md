# TIGER_HU

> **这是 DSH（DeepSeek Harness）的一个 agent 预设（agent preset）。**
> 预设内容复制自 DSH 自带的 `ptc` 组合，再叠加 TIGER_HU 的项目目录约定。

如果你在找一个可以直接装进 DSH、让新会话按固定目录结构与版本规则干活的东西，就是这里。安装方式是用本仓库的文件把预设写进 DSH 的 profile。

## 快速开始

```powershell
git clone https://github.com/Yadi206/TIGER_HU.git TIGER_HU
cd TIGER_HU
powershell -ExecutionPolicy Bypass -File .\install-preset.ps1
```

然后**重启 DSH**，新建会话时在预设里选择 **TIGER_HU**。

脚本做的事：

1. 定位 `$DSH_HOME/profiles/<profile>/cordis.patch.yml`（默认 `%USERPROFILE%\.dsh\profiles\web\cordis.patch.yml`）；
2. 把 `presets/TIGER_HU.yml` 里的预设条目追加进补丁层（已存在则跳过，不会重复追加）；
3. 把 `agent-preset-registry` 的 `selectedDefault` 指向 `TIGER_HU`；
4. 每次改动前先备份成 `cordis.patch.yml.bak-<时间戳>`。

前置条件：DSH 至少启动过一次，profile 目录已经生成。

## 手动安装（不想跑脚本）

1. 打开 `%USERPROFILE%\.dsh\profiles\web\cordis.patch.yml`（把 profile 名换成你在用的那个）；
2. 把 [presets/TIGER_HU.yml](presets/TIGER_HU.yml) 的内容整段追加到文件末尾；
3. 找到该文件里 `agent-preset-registry` 的 `config`，把 `selectedDefault` 改成 `TIGER_HU`（没有这一项就按下面补）：

```yaml
- id: agent-preset-registry
  name: '@deepseek-ai/dsh-agent-preset-registry'
  config:
    default: standard
    selectedDefault: TIGER_HU
```

改完重启 DSH。

## 这个预设里有什么

| 项 | 值 | 说明 |
| --- | --- | --- |
| `id` | `TIGER_HU` | 会话保存的预设标识 |
| `name` | `TIGER_HU 项目模式` | 预设列表里显示的名称 |
| `description` | 按 8 个标准目录组织项目，版本号记在 VERSION 里自动流水，发布按 v大.小 归档；工具与 ptc 组合一致。 | 预设列表里的说明 |
| `order` | `5` | 预设列表排序 |
| 插件行 | 22 条 | 与 PTC 一致的工具与分组 |

- **persona**：前缀沿用 `You are a coding agent powered by the {{model}} model.`；后缀是 TIGER_HU 的目录与版本约定（8 个目录、VERSION 规则、发版、`03-src` 只做 `git init` 等）。
- **工具**：`pwsh`（Windows）/ `bash`（其他平台）、文件读写与搜索、job、schedule、skill、goal、todo、web、present、ask_user_question、subagent 与 subagent_fork。
- **分组**：`planning`（plan-mode）、`compaction`（压缩与工具结果修剪）、`delegation`（子代理，`workflow-ptc` 与 `tool-workflow` 默认关闭）。
- **工具呈现**：`tool-presentation` 用 `mode: ptc`，与 PTC 一致。

想改行为，编辑 `presets/TIGER_HU.yml` 里的 `config.plugins`，再跑一次 `install-preset.ps1`（会跳过已存在的预设条目，所以要先从 profile 里删掉旧的 `preset-TIGER_HU` 块）。

## 附带：项目骨架脚手架（可选）

预设负责「怎么干活」，脚手架负责「目录长什么样」。想直接得到一份符合约定的项目：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

它会创建 8 个目录、写入 `00-standards/VERSION`，并在 `03-src/` 内执行 `git init`。可重复执行，不覆盖已有内容。

```
TIGER_HU/
├── 00-standards/     本项目的开发标准与版本号
├── 01-tmp/           临时文件与一次性测试脚本
├── 02-output/        任务产出的文件
├── 03-src/           正式代码（目录内独立 git 仓库）
├── 04-templates/     模板文件
├── 05-release/       发布的正式文件
├── 06-references/    参考应用
└── 07-tasks/         用户写的任务说明
```

| 目录 | 用途 |
| --- | --- |
| `00-standards/` | 编码规范、命名与目录约定、评审与验收要求、流程说明，以及 `VERSION`。其中的约定优先于其他目录。 |
| `01-tmp/` | 临时文件与一次性测试脚本，可随时清理。 |
| `02-output/` | 生成的报表、文档、中间结果。 |
| `03-src/` | 正式源码，目录内初始化为独立本地 git 仓库。 |
| `04-templates/` | 模板文件，供创建参考应用时使用。 |
| `05-release/` | 每次发布放进 `05-release/v<大>.<小>/`，旧版本保留不覆盖。 |
| `06-references/` | 通过模板创建需求的那类应用的实现，不是输入资料。 |
| `07-tasks/` | 用户撰写的任务说明。 |

## 版本号规则

- 版本文件是 `00-standards/VERSION`，只存一行「大.小」，例如 `1.4`。
- 新项目从 `1.0` 开始（`install.ps1` 在文件缺失时写入）。
- **小版本自动流水**：每完成一次任务级修改（代码、文档、目录或标准），小版本 +1。
- **大版本必须由人确认**：确认后大版本 +1、小版本归 0（如 1.7 → 2.0）。

## 发版规则

- 按当前 `VERSION` 建 `05-release/v<大>.<小>/`，把发布物放进去。
- 旧版本目录保留，不覆盖、不删除。
- 目标目录已存在时先确认版本号。

## 仓库内容

```
TIGER_HU/
├── README.md                 本文件
├── install-preset.ps1        把 agent 预设装进 DSH profile
├── install.ps1               生成项目骨架目录
├── presets/TIGER_HU.yml      agent 预设定义（复制自 ptc）
├── 00-standards/
│   ├── PROJECT-STRUCTURE.md  目录与流程的详细约定
│   └── VERSION               版本号
└── .gitignore
```

## 常见问题

**装完没看到 TIGER_HU？** 先确认重启过 DSH；再检查 `cordis.patch.yml` 里是否同时有 `preset-TIGER_HU` 和 `selectedDefault: TIGER_HU`。

**会不会覆盖我原来的配置？** 脚本只做三件事：追加一段预设、改 `selectedDefault`、备份原文件。不会删你的条目。

**为什么仓库里没有那 8 个空目录？** git 不跟踪空目录，所以由 `install.ps1` 创建。

**凭据文件会不会被传上去？** 不会，`00-standards/git-accounts.json` 已被 `.gitignore` 排除。

更完整的项目约定见 [00-standards/PROJECT-STRUCTURE.md](00-standards/PROJECT-STRUCTURE.md)。
