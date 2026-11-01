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
| `description` | 按 8 个标准目录组织项目，版本号记在 VERSION 里自动流水，发布按 v大.小 归档；03-src 支持本地 git 或克隆远程仓库；工具与 ptc 组合一致。 | 预设列表里的说明 |
| `order` | `5` | 预设列表排序 |
| 插件行 | 22 条 | 与 PTC 一致的工具与分组 |

- **persona**：前缀沿用 `You are a coding agent powered by the {{model}} model.`；后缀是 TIGER_HU 的目录与版本约定（8 个目录、VERSION 规则、发版、`03-src` 的本地/远程 git 两种模式与提交规则等）。
- **工具**：`pwsh`（Windows）/ `bash`（其他平台）、文件读写与搜索、job、schedule、skill、goal、todo、web、present、ask_user_question、subagent 与 subagent_fork。
- **分组**：`planning`（plan-mode）、`compaction`（压缩与工具结果修剪）、`delegation`（子代理，`workflow-ptc` 与 `tool-workflow` 默认关闭）。
- **工具呈现**：`tool-presentation` 用 `mode: ptc`，与 PTC 一致。

想改行为，编辑 `presets/TIGER_HU.yml` 里的 `config.plugins`，再跑一次 `install-preset.ps1`（会跳过已存在的预设条目，所以要先从 profile 里删掉旧的 `preset-TIGER_HU` 块）。

## 模式说明

TIGER_HU 改变的是**会话开始时就固定的规则**，不是模型本身。它和 PTC 的差别只有一处：persona 的后缀里多了一段项目约定。工具集、工具呈现方式、计划/压缩/委派分组全部与 PTC 一致。

| 维度 | PTC（基底） | TIGER_HU |
| --- | --- | --- |
| 插件行 | 22 条 | 22 条，完全相同 |
| 工具呈现 | `mode: ptc` | 同 |
| persona 前缀 | `You are a coding agent powered by the {{model}} model.` | 同 |
| persona 后缀 | 无 | 8 目录约定 + VERSION 流水 + 发版规则 + `03-src` 两种 git 模式与提交规则 |

写进后缀的规则，共 7 条：

1. **新建项目才建目录**：新建项目（或说「建个工程」）时先建 8 个目录；对已有项目不动它的目录，也不擅自新建、移动、重排。
2. **只建目录，不造内容**：除 `03-src` 的 git 初始化/克隆和 `00-standards` 的 `VERSION`、`PROJECT-STRUCTURE.md` 外，不写 README、`.gitkeep`、示例文件之类的占位物。
3. **结构必须落文档**：创建后把目录树、各目录用途、版本号规则、发版与 git 规则写进 `00-standards/PROJECT-STRUCTURE.md`。
4. **版本号自动流水**：`00-standards/VERSION` 只存一行「大.小」；每次任务级修改把小数位 +1，并在回复里报当前版本；**大版本必须你确认**才能动。
5. **发版可追溯**：按当前版本建 `05-release/v<大>.<小>/`，旧版本保留不覆盖；同名目录已存在时先确认再动。
6. **标准优先**：`00-standards/` 里的约定覆盖其他说法。
7. **git 两种模式**：没给仓库地址时 `03-src/` 只做 `git init`（本地 git），发版时直接提交本地代码；给了仓库地址时把该仓库克隆进 `03-src/`（远程 git），发版不自动提交，等你明确发出提交指令再提交。

**适合**：要长期维护、需要版本流水与发布归档的项目；多人按同一套目录协作。
**不适合**：一次性脚本、已经有既定结构且不打算改的仓库——这时它只会守着规则不动你的目录，收益有限。

## 如何使用

1. 按上面的「快速开始」装好预设，重启 DSH。
2. 新建会话时把预设选成 **TIGER_HU**。模式在会话创建时固定，中途换模式要新开会话。
3. 之后正常对话即可，规则会自动生效。

常见起手式：

| 你想要的 | 直接说 | 它会做什么 |
| --- | --- | --- |
| 起一个新项目 | 「新建项目 my-app」 | 建 8 个目录、写 `VERSION` 为 1.0、写 `PROJECT-STRUCTURE.md`、在 `03-src` 里 `git init`，然后概述结构 |
| 起一个新项目并接远程仓库 | 「新建项目 my-app，代码仓库是 https://…/my-app.git」 | 建 8 个目录，把该仓库直接克隆到 `03-src`（不做本地 `git init`），之后发版不自动提交 |
| 在现有项目上改东西 | 「在 03-src 里加一个登录接口」 | 改代码，完成后把 `VERSION` 小版本 +1 并告诉你当前版本 |
| 发一个版本 | 「发布 1.3」 | 建 `05-release/v1.3/` 并放入发布物，旧版本不动；本地 git 会自动提交代码，远程 git 只发文件 |
| 提交远程仓库的代码 | 「提交代码」/「推送到远端」 | 远程 git 模式下才需要：按指令提交，要求推送时再 push |

想确认自己确实在这个模式里，可以问一句「复述你的项目目录约定」，或者看项目根目录有没有那 8 个目录和 `00-standards/VERSION`。

## 附带：项目骨架脚手架（可选）

预设负责「怎么干活」，脚手架负责「目录长什么样」。想直接得到一份符合约定的项目：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

它会创建 8 个目录、写入 `00-standards/VERSION`，并在 `03-src/` 内执行 `git init`。可重复执行，不覆盖已有内容。

如果要接已有的远程仓库，把代码仓库地址传给同一个脚本，它会把该仓库直接克隆进 `03-src/`，不再做本地 `git init`：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -GitUrl https://github.com/you/my-app.git
```

`03-src/` 里已有内容时脚本一律跳过，不会覆盖。

```
TIGER_HU/
├── 00-standards/     本项目的开发标准与版本号
├── 01-tmp/           临时文件与一次性测试脚本
├── 02-output/        任务产出的文件
├── 03-src/           正式代码（本地 git 仓库，或克隆的远程仓库）
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
| `03-src/` | 正式源码。未给仓库地址时为本地 git 仓库；给了地址时直接克隆该远程仓库到本目录。 |
| `04-templates/` | 模板文件，供创建参考应用时使用。 |
| `05-release/` | 每次发布放进 `05-release/v<大>.<小>/`，旧版本保留不覆盖。 |
| `06-references/` | 通过模板创建需求的那类应用的实现，不是输入资料。 |
| `07-tasks/` | 用户撰写的任务说明。 |

## 版本号规则

- 版本文件是 `00-standards/VERSION`，只存一行「大.小」，例如 `1.3`。
- 新项目从 `1.0` 开始（`install.ps1` 在文件缺失时写入）。
- **小版本自动流水**：每完成一次任务级修改（代码、文档、目录或标准），小版本 +1。
- **大版本必须由人确认**：确认后大版本 +1、小版本归 0（如 1.7 → 2.0）。

## 发版规则

- 按当前 `VERSION` 建 `05-release/v<大>.<小>/`，把发布物放进去。
- 旧版本目录保留，不覆盖、不删除。
- 目标目录已存在时先确认版本号。
- 发版时的代码提交按 `03-src/` 的 git 模式区分：
  - **本地 git**（`03-src/` 无 remote）：直接提交 `03-src/` 的代码，不用你额外下指令；没有改动就跳过。
  - **远程 git**（`03-src/` 有 remote）：不自动提交，等你说「提交」再提交；说「推送」再 push。只发版不提交时，回复里会提示代码尚未提交。

## 03-src 的 git 模式

| 模式 | 初始化方式 | 发版时 |
| --- | --- | --- |
| 本地 git（默认） | 未提供仓库地址：在 `03-src/` 内 `git init`，不配 remote | 自动提交 `03-src/` 的代码 |
| 远程 git | 提供了仓库地址：直接把该仓库克隆到 `03-src/`，不做本地 `git init` | 不自动提交，等用户发出提交指令 |

- 模式不写标记文件，以 `03-src/` 是否配置了 remote 判断（`git -C 03-src remote` 有输出即远程 git）。
- 克隆失败时 `03-src/` 保持为空并如实报告原因，不回退成 `git init`，也不自行更换地址。
- 只操作 `03-src/` 自己的仓库：不配新的 remote、不改全局 git 配置；提交身份从 `00-standards/git-accounts.json` 读取。

## 仓库内容

```
TIGER_HU/
├── README.md                 本文件
├── install-preset.ps1        把 agent 预设装进 DSH profile
├── install.ps1               生成项目骨架目录（可传 -GitUrl 克隆代码仓库）
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

**03-src 会自动提交代码吗？** 看模式：本地 git（没配 remote）发版时自动提交；远程 git（克隆来的仓库）不自动提交，等你明确说「提交」才提交，「推送」才 push。

**`install.ps1 -GitUrl` 会不会覆盖已有代码？** 不会。`03-src/` 里已经有内容时脚本直接跳过；克隆失败时保持 `03-src/` 为空并报错，不会退回本地 `git init`。

**凭据文件会不会被传上去？** 不会，`00-standards/git-accounts.json` 已被 `.gitignore` 排除。

更完整的项目约定见 [00-standards/PROJECT-STRUCTURE.md](00-standards/PROJECT-STRUCTURE.md)。
