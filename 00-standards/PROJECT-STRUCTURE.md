# 项目结构说明

本文件说明 TIGER_HU 项目的目录约定、版本号规则、发版规则与 git 规则。项目内所有内容均按本文件放置。

## 目录树

```
TIGER_HU/
├── 00-standards/     本项目的开发标准与版本号
├── 01-tmp/           临时文件与一次性测试脚本
├── 02-output/        任务产出的文件
├── 03-src/           正式代码（本地 git 仓库，或克隆的远程仓库）
├── 04-templates/     模板文件
├── 05-release/       发布的正式文件
├── 06-references/    参考应用（通过模板创建需求的那类应用）
└── 07-tasks/         用户写的任务说明
```

## 获取与安装

本仓库是 TIGER_HU 的项目脚手架（模板），不是某个具体业务代码。

1. 克隆到本地：`git clone <仓库地址> TIGER_HU`
2. 进入目录并安装，按 03-src/ 的 git 模式二选一：
   - 本地 git：`powershell -ExecutionPolicy Bypass -File .\install.ps1`
   - 远程 git：`powershell -ExecutionPolicy Bypass -File .\install.ps1 -GitUrl <代码仓库地址>`（把该仓库直接克隆到 03-src/）
3. 在 DeepSeek Harness（DSH）中把该目录作为项目打开，即可按本文件的约定工作。

说明：

- git 不跟踪空目录，所以 01-tmp/、02-output/、03-src/、04-templates/、05-release/、06-references/、07-tasks/ 在仓库里不存在，必须由 install.ps1 创建；脚本可重复执行，不会覆盖已有内容。
- 不传 `-GitUrl` 时，install.ps1 在 03-src/ 内执行 git init（仅当尚未初始化且本机有 git）；传入 `-GitUrl` 时，改为把该远程仓库克隆到 03-src/，若 03-src/ 已有内容则跳过，不覆盖。
- 00-standards/git-accounts.json 属于本机凭据，已被 .gitignore 排除，不会随仓库分发；克隆后请自行创建并填写。

## 各目录用途

| 目录 | 用途 | 说明 |
| --- | --- | --- |
| 00-standards/ | 开发标准 | 编码规范、命名与目录约定、评审与验收要求、流程说明，以及版本号文件 VERSION 与 git 账号文件 git-accounts.json（本机凭据，不随仓库分发）。其中的约定约束其他目录里的内容；标准优先，与本文档冲突时按 00-standards/ 执行。标准文件由用户提供，不存在时不由助手自行编写。 |
| 01-tmp/ | 临时区 | 临时文件与一次性测试脚本，可随时清理，不做长期保存。 |
| 02-output/ | 任务产出 | 生成的报表、文档、中间结果等任务产出文件。 |
| 03-src/ | 正式代码 | 正式源码目录。未提供远程仓库地址时为本地 git 仓库；提供了地址时直接克隆该远程仓库到本目录（不再另做本地 git）。 |
| 04-templates/ | 模板 | 模板文件存放处，供创建参考应用时使用。 |
| 05-release/ | 发布 | 发布的正式文件。每次发布放入 05-release/v<大>.<小>/（如 05-release/v1.3/），旧版本保留不覆盖。 |
| 06-references/ | 参考应用 | 通过模板创建需求的那类应用的存放处（模板与应用的落地实现），不是用户提供的输入资料。 |
| 07-tasks/ | 任务说明 | 用户撰写的任务说明文件。 |

补充规则：

- 只在新建项目时创建这 8 个目录；对已有项目不擅自新建、移动或重排目录。
- 新增目录沿用“两位流水号-小写名称”的规则编号，追加在末尾。
- 存放文件时按上表分类放置，不写 README、.gitkeep、示例文件或其他占位文件。

## 版本号规则

- 版本文件为 00-standards/VERSION，只存一行“大.小”（如 `1.3`），不带前缀、不带额外文字。项目创建时写入 `1.0`。
- 小版本自动流水：每完成一次任务级修改（代码、文档、目录或标准的变更），把 VERSION 的小版本 +1 并写回，并在回复中说明当前版本。
- 大版本只能由用户确认：用户明确同意后大版本 +1、小版本归 0（如 1.7 → 2.0）；未经确认不得改动大版本。

## 发版规则

- 发布时按当前 VERSION 建立 05-release/v<大>.<小>/ 目录（如当前版本 1.3 对应 05-release/v1.3/），将发布物放入该目录。
- 旧版本目录保留，不覆盖、不删除。
- 若目标版本目录已存在，先与用户确认版本号，确认后再发布，不覆盖旧版本内容。
- 发版时的 git 行为按 03-src/ 的 git 模式区分（见“git 规则”）：
  - 本地 git（03-src/ 无 remote）：发布时直接提交 03-src/ 的代码（`git -C 03-src add -A` 后 `git commit`，提交信息写明版本与本次改动），不需要用户额外下指令；没有可提交的改动就跳过并说明。
  - 远程 git（03-src/ 有 remote）：发布时不自动执行 `git add` / `git commit` / `git push`，等用户明确发出提交指令后再提交；用户要求推送时再 `push`。没有收到提交指令时只发布文件，并在回复里提示代码尚未提交。

## git 规则

- 03-src/ 有两种互斥的 git 模式，以该目录是否配置了 remote 为准（`git -C 03-src remote` 有输出即远程 git，无输出即本地 git）；不额外写模式标记文件。
- 本地 git（默认）：未提供远程仓库地址时，在 03-src/ 内执行 `git init`，不配置 remote；发版时自动提交本地代码。
- 远程 git：提供了仓库地址时，不在 03-src/ 内做本地 git，而是把该远程仓库克隆到 03-src/（`git clone <地址> 03-src`，目标目录需为空）；发版时不自动提交。
- 克隆失败时保留 03-src/ 为空并如实报告原因，不回退成 `git init`，也不自行更换地址。
- 只操作 03-src/ 自己的仓库：不配置新的 remote，不修改全局 git 配置；提交需要的作者身份从 00-standards/git-accounts.json 读取（存在时，可用 `git -c user.name=... -c user.email=...` 临时指定），不要把令牌写进 03-src/ 或任何被跟踪的文件。
- install.ps1 接受 `-GitUrl <地址>`：传入时按远程 git 克隆，未传时按本地 git init；03-src/ 已有内容时一律跳过，不覆盖。

## git 账号信息（凭据）

- 账号信息统一存放在 00-standards/git-accounts.json，用于提交代码时的作者身份（user.name / user.email）与下载代码时的远端地址、认证方式。
- 该文件位于 03-src 的 git 仓库之外，不会被提交；不要把其中的令牌复制进 03-src 或任何被跟踪的文件。
- 结构：顶层 `default` 指定默认账号的 `id`；`accounts` 为账号数组，每个账号含 `id`、`platform`、`host`、`protocol`、`userName`、`displayName`、`email`、`auth`（method / token / tokenEnvVar）、`repos`（如 origin）。
- 认证方式优先 `helper`（Windows 凭据管理器，文件内不留密码）或 `tokenEnvVar`（令牌放环境变量）；只有在无其他方式时才把 token 明文写入，且该文件不得外传。
- 新增账号时在 `accounts` 追加一项并保持 `id` 唯一；切换默认账号只需改 `default`。
- 该文件由用户维护，属于配置而非标准；00-standards 中的编码与流程标准优先于它。
