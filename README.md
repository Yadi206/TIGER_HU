# TIGER_HU

一套固定目录结构的项目脚手架：**下载 → 运行一个脚本 → 得到可以直接开工的项目骨架**。适合把「标准、任务说明、代码、发布物」分开放的长期项目，也适合交给 DSH（DeepSeek Harness）作为工作目录。

本仓库是模板，不含任何业务代码。

## 快速开始

```powershell
git clone https://github.com/Yadi206/TIGER_HU.git TIGER_HU
cd TIGER_HU
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

执行完会得到 8 个目录、`00-standards/VERSION`，并在 `03-src/` 内自动执行 `git init`。脚本可重复运行，已存在的目录、版本号和 git 仓库不会被覆盖。

然后把该目录用 DSH 打开，或者直接用自己的编辑器开始工作。

## 目录结构

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

| 目录 | 用途 | 说明 |
| --- | --- | --- |
| `00-standards/` | 开发标准 | 编码规范、命名与目录约定、评审与验收要求、流程说明，以及版本号文件 `VERSION`。其中的约定约束其他目录里的内容；标准优先。 |
| `01-tmp/` | 临时区 | 临时文件与一次性测试脚本，可随时清理。 |
| `02-output/` | 任务产出 | 生成的报表、文档、中间结果等。 |
| `03-src/` | 正式代码 | 正式源码，目录内初始化为独立的本地 git 仓库。 |
| `04-templates/` | 模板 | 模板文件，供创建参考应用时使用。 |
| `05-release/` | 发布 | 每次发布放进 `05-release/v<大>.<小>/`，旧版本保留不覆盖。 |
| `06-references/` | 参考应用 | 通过模板创建需求的那类应用的落地实现，不是输入资料。 |
| `07-tasks/` | 任务说明 | 用户撰写的任务说明文件。 |

文件按上表分类放置，不额外放 README、`.gitkeep` 之类的占位文件（本 README 是唯一的例外，由使用者在仓库根目录要求添加）。

## 版本号规则

- 版本文件是 `00-standards/VERSION`，只存一行「大.小」，例如 `1.2`。
- 新项目从 `1.0` 开始（`install.ps1` 在文件缺失时写入）。
- **小版本自动流水**：每完成一次任务级修改（代码、文档、目录或标准），小版本 +1。
- **大版本必须由人确认**：确认后大版本 +1、小版本归 0（如 1.7 → 2.0）。

## 发版规则

- 按当前 `VERSION` 建 `05-release/v<大>.<小>/` 目录，把发布物放进去。
- 旧版本目录保留，不覆盖、不删除。
- 目标版本目录已存在时，先确认版本号再发布。

## git 约定

- 本仓库跟踪脚手架文件（`.gitignore`、`00-standards/`、`install.ps1`、`README.md`）。
- `03-src/` 是独立的仓库，不跟随本仓库提交。
- 本机凭据文件 `00-standards/git-accounts.json` 已被 `.gitignore` 排除，不会外传；克隆后请自行创建并填写（字段说明见 `00-standards/PROJECT-STRUCTURE.md` 的「git 账号信息」一节）。
- `01-tmp/`、`02-output/` 同样不纳入版本管理。

## 为什么目录要由脚本创建

git 不跟踪空目录，所以仓库里没有那 7 个空目录，只有脚本。`install.ps1` 负责补齐它们，这样克隆下来的人是「干净的一份」，也不会把别人的临时文件和产出带走。

## 在 DSH 中使用

用 DSH 打开安装后的目录即可。DSH 会读取 `00-standards/PROJECT-STRUCTURE.md` 作为项目约定：新增目录沿用「两位流水号-小写名称」，改完东西自动维护 `VERSION`，发版按 `05-release/v<大>.<小>/` 归档。

更完整的约定见 [00-standards/PROJECT-STRUCTURE.md](00-standards/PROJECT-STRUCTURE.md)。
