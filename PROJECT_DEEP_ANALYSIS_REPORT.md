# ZEROON 项目深度分析报告

> 分析日期：2026-07-12  
> 分析范围：`ZEROON_PROJECT/10_TECH/zeroon` 当前工作区（含未提交改动）  
> 分析方法：优先阅读 README、PRD、架构 ADR、CURRENT_STATE、Sprint 计划/验收报告和 OpenAPI，再与后端、Flutter、React、迁移、测试及本地运行状态交叉验证。  
> 重要说明：当前 `main` 的最后提交停留在 Sprint 05，但工作区已有未提交的 Sprint 06 代码和 Sprint 07 草案；本文以“当前磁盘代码”为事实基线，不把草案中的 Pending 项目视为完成。

---

## 1. 项目概览

### 1.1 项目名称与核心目标

项目名称为 **ZEROON（归零）**，是围绕原创 IP “来自山海缓存的数据旅人 ZEROON”构建的长期 AI 陪伴产品。

核心目标不是提供通用问答或效率工具，而是形成以下长期闭环：

```text
感知此刻状态
  → 完成一次低负担归零记录
  → 私密沉淀到山海缓存
  → 获得克制、非诊断式的 AI 反思
  → 回看变化与长期模式
  → 建立与个人 ZEROON 的连续陪伴关系
```

### 1.2 产品定位与目标用户

| 维度 | 分析 |
|---|---|
| 产品定位 | 长期陪伴 + 私密记忆 + 自我理解的数字生命体 |
| 明确不是 | 社交平台、公开日记、任务管理器、心理诊断工具、泛 AI 聊天机器人、强激励习惯产品 |
| 核心用户 | 25–45 岁开发者、产品经理、设计师、创作者、创业者、独立工作者 |
| 主要痛点 | 日常经历无法持续沉淀；私人感受缺少安静容器；成长轨迹难以看见；AI 工具缺乏长期连续性与温度 |
| 隐性竞争对象 | 日记/情绪记录 App、个人知识库、AI 陪伴产品、习惯追踪工具、通用 AI 对话产品 |

### 1.3 技术栈

| 层次 | 技术与版本 | 当前用途 |
|---|---|---|
| 移动/Web 客户端 | Flutter、Dart `>=3.6 <4.0`、Riverpod 2.6.1、Dio 5.8、GoRouter 15.1、flutter_secure_storage 9.2 | 用户登录、状态、归零、缓存、成长、资料、相遇流程 |
| 后端 | Java 21、Spring Boot 3.4.5、Spring Web/Security/Data JPA/Validation/Actuator | 模块化单体 REST API、认证、业务服务、AI 适配 |
| AI | 自研 `LlmProvider` 抽象 + JDK HttpClient 的 OpenAI-compatible adapter | 同步聊天补全、降级回复、使用日志、安全边界 |
| 数据库 | PostgreSQL 16、Flyway、H2（local/test） | 用户、状态会话、记录、会话消息、记忆、Prompt、AI 使用日志等 |
| 缓存/基础设施 | Redis 7、Docker Compose | Redis 已配置但业务代码尚未使用 |
| 管理端 | React 19.1、Ant Design 5.25、Vite 6.3、TypeScript 5.8 | Prompt 模板只读查看；其他菜单为占位 |
| API/质量 | OpenAPI 3、Redocly、JUnit/Spring Test、Flutter Test、ESLint | 合同与自动化验证；管理端 lint 配置缺失 |

文档仍多处写“Spring AI”，但当前代码并未依赖 Spring AI，而是轻量 OpenAI-compatible 适配器。此差异已被 Sprint 07 草案识别，尚未完成架构文档统一。

### 1.4 项目规模

统计排除了 `.git`、`build`、`.gradle`、`.dart_tool`、`node_modules`、`dist`、`.run` 等生成目录。

| 指标 | 数量 |
|---|---:|
| 有效文件总数 | 256 |
| Java | 97 文件 / 5,578 行 |
| Dart | 36 文件 / 5,268 行 |
| Markdown | 36 文件 / 4,933 行 |
| SQL | 9 文件 / 514 行 |
| TypeScript/TSX | 4 文件 / 300 行 |
| Shell | 3 文件 / 448 行 |
| 后端代码 | 108 文件 / 6,030 行 |
| 移动端代码 | 38 文件 / 5,299 行 |
| 管理端代码 | 6 文件 / 384 行 |

项目属于**中小型、跨端、文档较完整的早期产品工程**。后端与移动端已经形成可运行 MVP，管理端和长期记忆/真实 AI 运营能力仍处于基础阶段。

### 1.5 整体架构类型与成熟度阶段

- 架构类型：**模块化单体后端 + 多客户端 + 单关系数据库 + 外部 LLM provider**。
- 产品阶段：**MVP 主闭环已跑通，正在从 Sprint 05/06 向可验证真实 AI 的 V1.1 过渡**。
- 工程成熟度：约 **Level 2.5/5**——有清晰文档、迁移、合同、自动化测试和本地脚本，但尚缺 CI 证据、生产环境、安全运营、可观测性、长期记忆写入和完整管理后台。
- 架构选择总体合理：当前体量使用微服务会增加成本；模块化单体更适合快速验证，但模块边界主要靠包结构和约定维持，尚无 ArchUnit 等自动约束。

---

## 2. 功能地图（Feature Map）

### 2.1 全量功能树

```text
ZEROON
├── 核心 MVP
│   ├── 认证与会话                  [已完成，生产化不足]
│   │   ├── 手机验证码申请/登录
│   │   ├── Access Token + Refresh Token rotation
│   │   ├── 安全存储与 401 自动刷新
│   │   └── 登出
│   ├── 此刻 Now                   [已完成]
│   │   ├── 当前状态展示
│   │   ├── 六种状态选择
│   │   ├── 状态会话与持续时间
│   │   ├── 连续归零与近七日入口
│   │   └── 今日缓存摘要
│   ├── 归零 Reset                 [已完成]
│   │   ├── 当前状态继承
│   │   ├── 目标/一句话内容
│   │   ├── 10 秒重复保存保护
│   │   ├── 状态会话结束并关联记录
│   │   └── 完成页
│   ├── 山海缓存 Archive           [已完成/部分实现]
│   │   ├── 记录分页列表与日期过滤
│   │   ├── 记录详情
│   │   ├── 状态时长展示
│   │   └── 独立 memory_entries    [仅查询；无生产写入]
│   └── 基础陪伴                   [部分实现]
│       ├── AI 对话 API
│       ├── Prompt 模板选择
│       ├── 最近 3 条记录上下文
│       ├── 安全拒绝与静态降级
│       └── 真实 provider 验证     [待开发/待验收]
├── V1.1 扩展
│   ├── Growth                     [已完成基础版]
│   │   ├── 陪伴天数、缓存总数、首次记录日期
│   │   ├── 连续归零天数
│   │   └── 近 1–90 天状态分布与非诊断观察
│   ├── 私人资料 Settings          [已完成表单；AI 权限未闭环]
│   │   ├── 昵称、头像预设、年龄段、职业、自我描述
│   │   └── AI 使用资料开关        [已存储，未被 Companion 使用]
│   └── My ZEROON                  [代码已实现，计划文档未更新状态]
│       ├── 首次登录相遇门禁
│       ├── 幂等创建
│       ├── 私人稳定铭牌
│       └── 个人 ZEROON 展示
├── 管理与运营
│   ├── Prompt 模板列表/详情       [已完成只读]
│   ├── Prompt 新建/启停/版本化 UI [待开发]
│   ├── 用户管理                  [占位/待开发]
│   ├── 内容管理                  [待开发]
│   ├── 系统配置                  [占位/待开发]
│   ├── 分析看板                  [占位/待开发]
│   └── RBAC/管理员鉴权/审计       [待开发；当前普通用户可访问管理 API]
├── 中长期能力
│   ├── 月度/年度总结             [待开发]
│   ├── 语义检索/RAG              [待开发且 Sprint 07 明确不做]
│   ├── 记录模板/写给未来          [待开发]
│   ├── 私密导出卡/报告            [待开发]
│   ├── 数据导出与账号删除         [OpenAPI 有草案，代码未实现]
│   ├── 自定义模型设置             [待开发]
│   └── Emotion Light / BLE / NFC [路线图]
└── 遗留/不一致
    ├── OpenAPI 的 /users/me、删除、admin users/create prompt 无实现
    ├── README/CURRENT_STATE/Sprint 文档状态不同步
    ├── Spring AI 文档与实际 adapter 架构不一致
    └── Redis 配置存在但未接入
```

### 2.2 状态与范围矩阵

| 功能 | 范围 | 状态 | 证据与判断 |
|---|---|---|---|
| 手机验证码登录 | MVP | 部分实现 | API、移动端、测试齐全；验证码仅内存 + 固定本地码，无生产短信/限流 |
| Token 会话 | MVP | 已完成 | Access JWT、refresh hash、rotation、logout、secure storage、自动刷新 |
| Now 状态 | MVP | 已完成 | 状态历史 + 活跃 session + UI 实时计时 |
| Reset 记录 | MVP | 已完成 | 状态关联、记录保存、重复保护、完成页、测试 |
| Archive/详情 | MVP | 已完成 | 分页、所有权隔离、详情和 UI |
| 独立 Memory | 扩展 | 部分实现 | 只有查询 API；没有生产写入或由记录生成 memory 的流程 |
| AI Reflection/Chat | MVP 扩展 | 部分实现 | provider、fallback、safety、usage log 已有；真实模型未验证，profile consent 未接入 |
| Growth | 扩展 | 已完成基础版 | 真实数据统计和非标签化文案；长历史查询存在性能隐患 |
| Profile | V1.1 | 部分实现 | CRUD 与 UI 已有；AI 使用许可开关尚未产生行为差异 |
| My ZEROON | V1.1 | 代码已完成/未正式验收 | 迁移、API、移动门禁和测试均存在；Sprint 文档仍全 Pending |
| Admin Prompt | 运营 | 部分实现 | 列表与详情；无专用管理员角色，token 存 localStorage |
| 用户/内容/分析管理 | 运营 | 待开发 | 菜单/文档占位，无实际模块 |
| 硬件 | V2+ | 待开发 | 仅路线图 |

---

## 3. 产品与业务分析

### 3.1 核心价值主张

ZEROON 最有价值的不是单次“记录心情”，而是**把用户确认过的当下、私人记录、状态轨迹和 AI 反思连成可回看的长期记忆**。其产品护城河应来自：

1. 长期连续上下文，而非单轮 AI 回答；
2. 用户拥有、可控、私密的记忆，而非公开表达；
3. 克制、不诊断、不贴标签的陪伴语气；
4. 原创 ZEROON IP 带来的稳定陪伴载体；
5. 从数字端自然延展到 Emotion Light 等低侵入硬件。

当前实现已经较好建立“记录容器”，但“长期记忆智能”尚弱，因此价值主张完成度高于普通情绪日记、低于真正具备时间连续性的陪伴系统。

### 3.2 主要用户流程与关键路径

```text
首次用户
请求验证码 → 登录/注册 → 与 ZEROON 相遇 → 获得私人铭牌 → 进入此刻

每日核心闭环
打开此刻 → 选择状态并开始计时 → 进入归零 → 写目标/片段
→ 保存记录并结束状态会话 → 完成反馈 → Archive 回看

理解与陪伴闭环
记录/状态历史 → Growth 状态分布 → 非诊断式观察
→ AI companion（最近 3 条记录上下文）→ 会话与使用日志
```

关键路径优点：

- 归零输入非强制长文，符合“30 秒完成”的低摩擦目标。
- 状态会话从选择开始、由记录结束，比单点 mood 更能表达时间过程。
- 数据所有权查询普遍带 `userId`，私密性边界较明确。
- My ZEROON 相遇使 IP 从品牌装饰转为产品内关系载体。

关键路径问题：

- 初次相遇被设为强制门禁，若接口失败会阻塞全部主功能；这与“可恢复”体验原则存在冲突，应提供温和重试和可延后策略评估。
- Home 主导航为“此刻 / 缓存 / 成长”，与 Roadmap 文档“Now / Reset / Archive，Growth 不作为早期主导航”的决策不一致，需要明确这是产品决策变化还是实现漂移。
- AI 反思没有真正使用用户授权资料，也没有长期 memory 检索，连续陪伴感目前主要来自话术而非数据能力。
- Memory API 与 Archive 记录形成两个数据域，但缺少写入/映射策略，用户概念上可能无法理解二者区别。

### 3.3 产品亮点与差异化

| 亮点 | 评价 |
|---|---|
| 状态 session 生命周期 | 从“选一个状态”升级到“记录这段状态持续多久”，有利于长期模式理解 |
| 私密、非社交默认 | 与公开日记/内容社区明确区隔，符合敏感个人数据场景 |
| 非诊断式观察 | 明确说明数据来源并拒绝固定标签，产品伦理方向正确 |
| AI 失败可降级 | provider 不可用仍返回平静文案，不破坏记录主链路 |
| 私人 ZEROON 铭牌 | 能增强身份连续性，同时避免等级、稀有度和社交比较 |
| 文档化产品护栏 | 对“礼物、情侣、治疗、泛聊天、强打卡”等漂移有明确约束 |

### 3.4 产品问题与改进空间

#### P0：价值闭环尚未真正形成“长期记忆”

`memory_entries` 没有生产写入；AI 只读取最近 3 条 zero records。这意味着“山海缓存”和“长期陪伴”更多是 UI/命名层成立，数据智能尚未成立。

建议先定义统一的 Memory Pipeline：哪些内容进入记忆、由谁确认、如何删除、AI 何时可读、如何追溯来源。不要直接上向量库；先完成可见、可删、可禁用的结构化记忆。

#### P0：隐私承诺与 AI 行为未闭环

资料页允许设置 `aiProfileContextEnabled`，但 Companion prompt 并未查询资料。因此当前开关是“无效控制项”。短期应完成授权开关的正反测试，并在 Prompt 组装处显式隔离资料上下文。

#### P1：产品信息架构发生无文档变化

Growth 已成为底部主 Tab，而规划明确它应是 Now/My 的二级能力。这会让产品更像数据追踪工具。建议进行一次正式 IA 决策：若保留主 Tab，证明它承载的是长期陪伴/回看而非指标看板；否则回归少入口结构。

#### P1：连续归零存在轻度打卡压力

“连续归零”虽没有惩罚，但 streak 本身会自然产生断签压力。建议弱化连续天数的主视觉权重，更强调“这些时刻被保存了”，并提供非连续的“本月留下 X 个时刻”。

#### P1：真实 AI 仍未形成可运营能力

需要完成 provider 成功/失败/拒绝的可观测验证、延迟体验、成本上限、Prompt 版本回溯和质量样本审查。不要把 provider 名称或模型设置推到用户中心。

#### P2：文案局部偏系统说明

如 AI 卡片中的“边界说明”及 Growth 的数据源说明在合规上正确，但视觉上可能压过陪伴语气。建议将边界与来源做成次级可展开信息，主内容保持安静自然；高风险询问时再明确展示安全边界。

---

## 4. 项目结构与技术架构

### 4.1 核心目录树

```text
zeroon/
├── README.md                         # 开发入口与 Sprint 1 MVP 说明
├── CURRENT_STATE.md                  # 交接状态（当前已滞后）
├── AGENTS.md                         # 工程约定与验证命令
├── backend/                          # Spring Boot 模块化单体
│   ├── build.gradle                  # Java 21 / Spring Boot 3.4.5
│   └── src/
│       ├── main/java/ai/zeroon/
│       │   ├── auth/                 # 验证码、登录、refresh session
│       │   ├── security/             # Bearer filter、自制 HS256 token
│       │   ├── user/                 # 用户聚合与状态枚举
│       │   ├── state/                # 状态历史和状态会话
│       │   ├── record/               # Zero Record 核心记录
│       │   ├── memory/               # Memory 查询（缺写入链路）
│       │   ├── growth/               # 成长与状态分布统计
│       │   ├── companion/            # 对话、安全边界、上下文组装
│       │   ├── ai/                   # LLM provider 与 usage logs
│       │   ├── prompt/               # Prompt 版本选择和管理查询
│       │   ├── profile/              # 私人资料与 AI 授权开关
│       │   ├── myzeroon/             # 私人 ZEROON 与铭牌
│       │   ├── config/               # Security、Clock
│       │   └── common/               # 异常处理、系统健康
│       ├── main/resources/
│       │   ├── application*.yml
│       │   └── db/migration/V1..V7   # Flyway 演进
│       └── test/                      # 15 类后端测试，61 个 @Test
├── mobile/                           # Flutter 用户端
│   ├── lib/
│   │   ├── auth/ common/ home/
│   │   ├── state/ record/ growth/
│   │   ├── companion/ profile/
│   │   └── my_zeroon/
│   ├── test/widget_test.dart          # 9 个 widget/integration-style tests
│   └── web/                           # Flutter Web 外壳
├── admin/                            # React + Ant Design 管理端
│   └── src/App.tsx                   # 单文件承载菜单和 Prompt 页面
├── docs/
│   ├── 01_PRD/ 02_Architecture/ 03_Database/
│   ├── 04_API/ 05_Engineering/ 06_AI/
│   ├── 07_Sprints/ 08_Roadmap/
│   └── 04_API/OpenAPI_V1.yaml         # 合同（部分超前于代码）
├── deployment/compose.yaml           # PostgreSQL + Redis
├── scripts/                          # 服务、快照、验证脚本
└── ui-prototype/                     # 原始视觉原型与参考图
```

### 4.2 模块职责与技术决策

| 模块 | 职责 | 决策评价 |
|---|---|---|
| Backend modular monolith | 聚合业务与数据事务 | 对当前规模最合适，部署简单、事务清晰；需加强边界约束 |
| State + Record | 状态过程与归零结果 | 分成 session/history/record 是领域建模亮点；并发与幂等仍需数据库级策略 |
| Companion + AI + Prompt | 业务对话、provider、模板分层 | 分层方向正确；Prompt context 构建仍硬编码在 service，后续应抽象 ContextAssembler |
| Memory | 私有长期记忆 | 当前是孤立读模型，没有事件生产、生命周期和 consent policy |
| Flutter feature folders | 按业务特性组织 Riverpod repository/controller/screen | 清晰易扩展；`main.dart`/部分 screen 开始承担过多路由与组合职责 |
| Admin | 运营入口 | 目前是原型级单页；尚无真正后台权限模型，不宜暴露到公网 |
| OpenAPI | 跨端合同 | lint 通过，但合同包含未实现接口，缺少 contract-to-code 自动差异检测 |
| Flyway | 数据库演进 | V1–V7 顺序清楚，索引基础良好；test `schema.sql` 需持续人工同步，存在双维护风险 |

### 4.3 运行拓扑

```text
Flutter Mobile/Web             React Admin
       │ Bearer JWT                 │ Bearer JWT（当前无 ADMIN 角色约束）
       └──────────────┬─────────────┘
                      ▼
             Spring Boot Modular Monolith
        ┌─────────────┼──────────────────┐
        ▼             ▼                  ▼
   PostgreSQL      Redis（未使用）   OpenAI-compatible LLM
   Flyway/JPA                         同步 HTTP + fallback
```

---

## 5. 核心代码与业务逻辑

### 5.1 最核心的 8 个文件/模块

| 文件/模块 | 核心作用 | 评价 |
|---|---|---|
| `backend/.../auth/AuthService.java` | 登录、用户创建、refresh rotation、登出 | 会话逻辑紧凑；缺设备级撤销/全局登出/限流 |
| `backend/.../security/TokenService.java` | 自制 HS256 JWT 与 refresh token hash | 实现简单可控，但生产上更建议使用成熟 JOSE 库并做 secret 强度启动校验 |
| `backend/.../state/StateService.java` | 活跃状态 session、短会话合并、历史写入 | 是领域模型核心；需并发竞争测试 |
| `backend/.../record/RecordService.java` | 创建/分页/详情、10 秒幂等保护、结束 session | 闭环清晰；幂等基于内容+时间窗口，不是请求级 idempotency key |
| `backend/.../companion/CompanionService.java` | 对话持久化、安全判断、Prompt、LLM、降级、usage log | 分层意识好；事务内同步外部调用、隐私开关未接入是主要问题 |
| `backend/.../growth/GrowthService.java` | 陪伴/连续归零/状态分布 | 时区处理和非诊断文案较好；连续天数读取全量记录，规模化后性能下降 |
| `mobile/lib/common/api_client.dart` | API base URL、Bearer 注入、401 refresh/retry | 客户端基础设施完整；并发 401 可能触发多次 refresh rotation 竞争 |
| `mobile/lib/main.dart` + `home/home_shell.dart` | 登录态、首次相遇门禁、主导航 | 用户路径直观；路由未真正采用已声明的 GoRouter，深链和 Web URL 状态弱 |

### 5.2 主要业务流程实现

#### A. 登录与刷新

```text
POST /auth/codes
  → VerificationCodeService 内存保存固定本地码
POST /auth/login
  → 校验并消费验证码
  → find-or-create User
  → 签发 HS256 access token
  → 生成随机 refresh token，仅保存 SHA-256 hash
Flutter secure storage 保存 session
401 → Dio interceptor 调 refresh → 旧 refresh revoke → 新 session → 原请求重放
```

亮点是 refresh rotation 和服务端 hash 存储；不足是验证码无发送商、频率限制、尝试次数、IP/设备风控，且多实例部署时内存验证码不共享。

#### B. 状态与归零

```text
选择状态
  → 若同状态 active session：幂等返回
  → 若 30 秒内未记录的旧 session：删除
  → 否则结束旧 session
  → 写 StateHistory + 新 StateSession + 更新 User.currentState

保存记录
  → 取 active session 状态，否则使用 request.state
  → 10 秒内同状态/目标/内容返回已有记录
  → 写 ZeroRecord
  → 结束 active session 并写 ended_by_record_id
```

这是项目完成度最高的业务闭环。潜在问题是 service 级查重无法完全抵抗并发重复请求；建议在 API 层增加 `Idempotency-Key` 或客户端生成 request ID，并建立唯一约束/幂等表。

#### C. AI 陪伴

```text
保存 USER message
  → SafetyBoundaryService 判断高风险请求
  ├── blocked：记录 REFUSAL，不调用 LLM
  └── allowed：选择 Prompt 模板
       → 拼当前 state + 用户消息 + 最近 3 条 record
       → 同步调用 OpenAI-compatible /chat/completions
       ├── success：记录 SUCCESS
       └── unavailable：返回静态 calm fallback，记录 FALLBACK
  → 保存 ASSISTANT message
```

亮点：安全拒绝优先、失败不破坏用户流程、Prompt 有版本选择、日志不保存完整 prompt 内容。主要不足：

- 外部 HTTP 在 `@Transactional` 事务内，长延迟会占用数据库连接和事务资源；
- 没有异步/流式输出、重试/熔断/并发控制；
- 没有 token budget、prompt 长度截断和输出内容二次安全检查；
- profile consent 未读取；
- 最近 3 条原文会发送给第三方 provider，用户侧缺少清晰的数据使用控制说明；
- 对话没有列表/历史 API，持久化价值没有对用户开放。

### 5.3 设计模式与架构评价

**已采用的良好模式**

- Controller → Service → Repository 分层。
- feature/package based modular monolith。
- DTO 与 Entity 分离。
- Strategy/Adapter：`LlmProvider` / `OpenAiCompatibleLlmProvider`。
- Graceful degradation：AI provider 失败回退。
- Repository ownership query：`findByIdAndUserId` 防越权。
- 版本化数据库迁移与 Prompt 模板。
- Flutter Repository + Riverpod Controller/Provider。

**不足**

- 领域事件缺失：Record 保存后没有可靠地产生 Memory、Summary 或 AI observation。
- AI context、consent、memory policy 没有独立策略层。
- 管理端 API 名称是 admin，但安全层没有 RBAC；“命名边界”并非安全边界。
- Exception handler 返回自定义 `{error,message}`，与工程约定的 RFC 9457 `application/problem+json` 不一致。
- 已声明 GoRouter 但主导航用 `MaterialPageRoute`，路由技术决策未落实。
- Admin 所有逻辑集中在 `App.tsx`，随着功能增长会快速失控。

---

## 6. 依赖、配置与技术债

### 6.1 主要依赖与风险

| 依赖 | 当前版本 | 风险/建议 |
|---|---:|---|
| Spring Boot | 3.4.5 | 稳定但非当前最新线；建立 Dependabot/Renovate 和季度升级节奏，勿盲目追新 |
| Java | 21 | LTS，选择正确 |
| Flutter SDK constraint | `>=3.6 <4.0` | README 要求 Flutter 3.44.2/Dart 3.12，与 pubspec 约束描述不一致 |
| Riverpod | 2.6.1 | 可用；未来升级 3.x 需评估 provider API 变化 |
| GoRouter | 15.1.2 | 依赖已装但未实际建立 router，属于无效/半落实依赖 |
| React | 19.1 | 新主版本，生态兼容需持续验证 |
| Vite | 声明 `^6.3.5`，锁定构建显示 6.4.3 | 正常 semver 浮动；CI 应以 lockfile 为准 |
| ESLint | 声明 `^9.26`，实际运行 9.39.4 | 缺 `eslint.config.*`，lint 命令直接失败 |
| Ant Design | 5.25 | 打包后主 JS 1,013 KB（gzip 320 KB），需按需拆包/懒加载 |
| PostgreSQL/Redis 镜像 | `16-alpine` / `7-alpine` | 使用浮动 minor tag，生产应固定 digest 或至少固定 patch |

本报告不依赖网络漏洞数据库，因此不对 CVE 做无证据断言；上线前应在 CI 增加 Gradle、npm、Flutter 的依赖漏洞扫描和 SBOM。

### 6.2 配置文件分析

**优点**

- 数据库、JWT、LLM 均支持环境变量覆盖。
- JPA `ddl-auto=validate` + Flyway，生产数据结构控制正确。
- `open-in-view=false`，减少隐式查询和长 session。
- Actuator 只暴露 health/info。
- Compose 有 PostgreSQL/Redis 健康检查和持久卷。
- 本地 H2 profile 方便快速开发。

**风险**

- 默认数据库密码 `change-me`、默认 JWT secret 和固定验证码可让误用默认配置的部署直接暴露。
- 应增加生产 profile 启动校验：默认 secret/password/local code 时拒绝启动。
- CORS 只允许本地端口，没有环境化生产 origins。
- Redis 配置了密码但应用完全未连接，增加运维面而无业务价值。
- H2 `create-drop` 与 PostgreSQL/Flyway 存在方言和迁移差异风险；至少增加 Testcontainers PostgreSQL 集成测试。
- `.env.example` 在当前有效文件清单中未见，而 README 要求复制它，开发入口不完整。

### 6.3 代码质量评估

| 维度 | 评价 |
|---|---|
| 规范性 | 后端和 Flutter 命名/分层一致；Admin 工程配置不完整；错误格式不符合自身 RFC 9457 约定 |
| 可维护性 | 核心业务代码短小明确；文档状态漂移和 test schema 双维护降低可信度 |
| 可测试性 | 后端 61 测试、Flutter 9 测试且全部通过；管理端无测试，真实 PostgreSQL/LLM/端到端测试不足 |
| 可读性 | DTO、service、repository 职责总体清楚；部分 Flutter screen 较长，需拆分视觉组件与 view model |
| 合同一致性 | OpenAPI lint 通过，但 `/users/me`、账号删除、admin users、create prompt 等没有代码实现 |
| 自动化 | 本地脚本实用；未看到 GitHub Actions 工作流，CI/CD 仍是文档目标而非工程事实 |

### 6.4 当前验证结果

| 命令 | 结果 |
|---|---|
| `backend ./gradlew test` | **通过**，61 个 `@Test`，BUILD SUCCESSFUL |
| `flutter analyze` | **通过**，No issues found |
| `flutter test` | **通过**，9/9 tests |
| `npm run build` | **通过**；主 chunk 1,013 KB，触发 >500 KB 警告 |
| `npm run lint` | **失败**；ESLint 9 找不到 `eslint.config.js/mjs/cjs` |
| Redocly OpenAPI lint | **通过** |
| `git diff --check` | **通过** |
| 本地服务 | backend 8080、mobile 4173、admin 5173 均在运行 |

---

## 7. 性能、安全、可扩展性与产品可靠性

### 7.1 性能瓶颈与建议

| 优先级 | 问题 | 影响 | 建议 |
|---|---|---|---|
| P0 | LLM HTTP 调用位于数据库事务中 | provider 8–10 秒延迟会长期占连接/锁 | 用户消息短事务提交后调用 LLM，再用独立短事务保存回复；或采用 outbox/job |
| P1 | `continuousResetDays` 读取用户全部记录 | 长期用户数据线性增长 | 只查询最近连续日期范围、按日聚合表或 SQL recursive/window 方案 |
| P1 | Admin 单 chunk 1 MB | 首屏加载与弱网体验差 | route lazy load、AntD 按模块拆分、manualChunks |
| P1 | 每个 API 请求都异步读 secure storage | 移动端额外 IO | 在 auth state 中缓存 access token，持久层只用于恢复/更新 |
| P1 | 并发 401 可多次 refresh | refresh rotation 互相撤销导致登出 | single-flight refresh mutex + 请求队列 |
| P2 | Prompt 列表无分页 | 版本增多后全表读 | 按 code/状态分页和只取最新版视图 |
| P2 | AI 上下文直接拼接原文 | 长记录时 prompt 不可控 | 字符/token budget、截断策略、来源 ID、脱敏与授权过滤 |

### 7.2 安全风险检查

#### 高风险

1. **Admin API 无管理员授权**：SecurityConfig 仅要求 authenticated，TokenService 对所有用户固定签发 `USER`；因此任何登录用户理论上可访问 `/api/v1/admin/prompts` 并读取完整系统 Prompt。应增加角色模型、`hasRole("ADMIN")`、管理员登录/审计和测试。
2. **生产默认密钥/验证码风险**：默认 JWT secret、数据库密码和 `000000` 验证码必须在非 local 环境禁用并启动失败。
3. **验证码无防滥用**：没有手机号/IP/设备限流、尝试计数、冷却时间、验证码随机生成和真实 sender；不可直接生产上线。

#### 中风险

4. Admin access token 存 `localStorage`，一旦发生 XSS 容易泄露；应使用更严格 CSP，并考虑内存或 HttpOnly cookie 的后台认证方案。
5. 自制 JWT 未验证 `alg`、issuer、audience、not-before，密钥轮换和 key id 不支持；建议迁移 Spring Security OAuth2 Resource Server/Nimbus JOSE JWT。
6. Companion 会把最近记录原文发给第三方 LLM；需明确授权、provider 数据政策、区域、保留策略和可关闭能力。
7. 目前只做输入关键词式安全边界（从类结构与测试推断），还应有输出安全策略、危机响应文案和误判审查机制。
8. API 错误可能直接返回异常 message，需避免暴露内部实体/provider 细节。
9. 无账号删除/数据导出实现，和隐私控制承诺不匹配。

#### 已有正向措施

- Refresh token 只存 hash，且支持 rotation/revoke。
- 移动 token 使用 secure storage。
- 资源查询普遍绑定 authenticated user ID。
- Prompt/AI usage 日志设计上避免记录完整私密消息。
- CORS 非通配、CSRF 与 stateless bearer 使用场景匹配。

### 7.3 可扩展性评估

| 新增能力 | 难度 | 原因 |
|---|---:|---|
| 新增普通 CRUD 功能 | 低 | 模块模板和跨端模式清晰 |
| 新增记录模板/导出 | 中 | 需扩展 Record DTO/UI/权限，但不改核心模型 |
| 新增真实 AI provider | 中 | 已有 adapter；需运营验证、重试、成本和隐私治理 |
| 新增长期记忆/RAG | 高 | 当前 Memory 无写入策略，需先建立 consent、生命周期、来源追溯和评估体系 |
| 新增管理员能力 | 中高 | 首先补 RBAC、审计和 Admin 架构拆分 |
| 多实例部署 | 中高 | 验证码内存态、无分布式限流、同步 AI、缺可观测性 |
| 硬件连接 | 高 | 需 BLE/NFC、设备身份、固件、隐私边界和跨端状态同步 |

模块化单体足以支撑未来 12–18 个月的产品验证。扩展瓶颈不是“是否拆微服务”，而是**事件流、隐私权限、可观测性和数据生命周期**。除非出现独立团队/独立伸缩需求，不建议现在拆服务。

### 7.4 产品可靠性

当前可靠性基础是“记录主链路不依赖 AI”，这是正确决策。但仍需补齐：

- AI 成功、回退、拒绝的端到端 SLI/SLO；
- Postgres 备份恢复演练和迁移回滚方案；
- record 保存的请求级幂等；
- 网络离线/弱网下的草稿保存和重试；
- 首次相遇接口失败时不永久阻塞主应用；
- 数据删除/导出/AI 禁用的一致性测试；
- crash/exception/latency 指标，且不采集私密正文。

---

## 8. 总体评估与评分（10 分制）

| 维度 | 评分 | 说明 |
|---|---:|---|
| 产品维度 | **8.1** | 主线、目标用户、语气和反漂移护栏清楚，原创 IP 与私密记忆定位有差异化；长期记忆能力尚未兑现 |
| 功能完整性 | **6.8** | 状态—归零—Archive 主闭环完整，Growth/Profile/My ZEROON 有基础；Memory 写入、真实 AI、隐私控制、Admin 未闭环 |
| 技术架构 | **7.6** | 模块化单体、迁移、分层、provider adapter 均合理；同步 AI 事务、RBAC、事件管线和生产化不足 |
| 代码质量 | **7.4** | 后端与 Flutter 测试/静态检查良好；Admin lint/测试缺失、合同与文档漂移、部分技术决策未落实 |
| 安全与可靠性 | **5.8** | 所有权与 token 基础不错，但 admin 越权、默认密钥、验证码和数据删除是上线阻断项 |
| **综合评分** | **7.2 / 10** | 一个产品方向成熟、MVP 工程基础扎实，但尚未达到公开生产发布标准的早期 V1 项目 |

综合判断：ZEROON 已经不是“概念原型”，而是**可本地运行、核心闭环可验证的 MVP**。它最强的部分是产品边界和状态/记录领域模型；最弱的部分是长期记忆真实性、AI 权限闭环、后台安全和生产运营能力。下一阶段不应扩张大量功能，而应把“私密记忆真的可控、AI 真的可靠、系统真的可上线”做实。

---

## 9. 行动建议与路线图

### 9.1 短期（1–2 周）

#### P0：上线阻断项

| ID | 事项 | 可执行动作 | 完成标准 |
|---|---|---|---|
| P0-1 | 修复 Admin 越权 | 建立 ADMIN 角色/权限；`/admin/**` 使用 hasRole；补普通用户 403、管理员 200 测试 | 普通 app 用户无法读取 Prompt；审计记录访问人 |
| P0-2 | 生产配置 fail-fast | 新增 prod profile 校验默认 JWT secret、DB password、local code、LLM key | 使用默认值时 prod 启动失败；秘密不进入日志/仓库 |
| P0-3 | 验证码生产化边界 | local fake sender 仅 local；增加随机码、TTL、单次消费、手机号/IP 限流、尝试上限 | 具备滥用测试；多实例状态使用 Redis/外部服务 |
| P0-4 | AI profile consent 闭环 | 独立 ContextAssembler；仅开关 true 时读取允许字段；补 on/off prompt 测试 | 关闭时 provider 请求不含资料；开启时仅含明确字段 |
| P0-5 | 合同与代码对齐 | 对未实现 OpenAPI 接口标记 planned/remove，或完成最必要的 `/users/me`、删除请求；加入差异检查 | 文档不再把待开发接口呈现为可用接口 |

#### P1：核心价值与工程门禁

| ID | 事项 | 可执行动作 | 完成标准 |
|---|---|---|---|
| P1-1 | 定义 Memory V1 | 写 ADR：来源、确认、可见、删除、过期、AI 读取权限；Record 事件生成可追溯 memory | 新记忆可见、可删、可禁用；每条有 source/type |
| P1-2 | AI 事务解耦 | 将外部 LLM 调用移出长事务；保存 message 使用短事务；设 timeout/circuit breaker | provider 超时不占用长 DB 事务；fallback 仍可用 |
| P1-3 | Admin 工程修复 | 添加 ESLint flat config、组件拆分、至少一组 Vitest/RTL 测试 | lint/build/test 全通过 |
| P1-4 | 更新事实文档 | CURRENT_STATE 改到 Sprint 06/07；Sprint 06 状态按代码更新；统一 Spring AI vs adapter 描述 | README、CURRENT_STATE、架构、Sprint 对当前代码无关键矛盾 |
| P1-5 | CI 基线 | GitHub Actions 执行 backend test、Flutter analyze/test、admin lint/build/test、OpenAPI lint、diff check | PR 必须全绿；缓存依赖并发布测试报告 |
| P1-6 | 真实 AI smoke | 用系统级 provider 验证 SUCCESS/FALLBACK/REFUSAL、延迟和 usage log | 三路径均有自动/可重复验证，不暴露 prompt 正文 |

#### P2：体验收口

- 正式评审 Growth 是否继续作为主 Tab，并更新 IA 决策。
- 给首次相遇失败提供温和、局部、可重试状态；评估允许稍后进入的策略。
- AI “边界说明/数据来源”改为次级展开信息，保留必要可访问性。
- 为 Reset 增加本地草稿与网络失败后的可恢复重试，避免私人内容丢失。
- 避免 streak 成为压力中心，增加“本月留下的时刻”等非连续指标。

### 9.2 中长期优化（1–3 个月）

#### 产品能力

1. **结构化长期记忆**：先支持用户确认、编辑、删除的 Memory V1，再评估 embedding/RAG。
2. **周期反思**：月度/年度回顾必须展示来源、允许隐藏，不给人格标签或诊断结论。
3. **表达模板**：以“写给未来/保存未说完的片段”等抽象能力承载，不做礼物/情侣专用模式。
4. **私密导出**：从保存个人记忆出发，默认本地、不公开、不带社交增长暗示。
5. **陪伴连续性**：My ZEROON 在关键时刻出现即可，不引入养成、货币、稀有度或压力任务。
6. **用户控制中心**：数据导出、账号删除、AI 使用范围、记忆可见/删除/禁用成为 V1 必备能力。

#### 技术路线

```text
阶段 A：生产安全基线
RBAC + secrets fail-fast + OTP/限流 + CI + PostgreSQL 集成测试

阶段 B：可靠 AI 与记忆
ContextAssembler + consent policy + Memory events/outbox
+ LLM timeout/circuit breaker + quality/usage metrics

阶段 C：可观测与规模化
structured logs + metrics/tracing + backup/restore + SLO
+ Growth 聚合查询 + cache（有明确收益后再使用 Redis）

阶段 D：产品扩展
周期反思 + 私密导出 + 设备连接试验
```

具体技术建议：

- 继续保持模块化单体，不进行“为架构而架构”的微服务拆分。
- 用领域事件/outbox 连接 Record → Memory → Reflection，而不是 service 间直接耦合。
- 引入 Testcontainers PostgreSQL 覆盖 Flyway、索引、唯一约束和 PostgreSQL 特有行为。
- 使用成熟 JWT/JOSE 组件，增加 issuer/audience/key rotation。
- AI provider 增加熔断、并发上限、成本预算、模型/Prompt 版本和响应质量抽样。
- 管理端按 feature/router 拆分并使用 HttpOnly 管理会话或更严谨的 token 策略。
- 建立不含私密正文的可观测数据：request ID、user surrogate ID、latency、outcome、provider/model/prompt version。

### 9.3 产品功能扩展方向与护栏

| 方向 | Roadmap 决策 | 抽象能力 | 验收护栏 |
|---|---|---|---|
| 月度/年度回顾 | 接受，Memory V1 后 | 跨时间反思 | 可追溯、可删除、不诊断、不贴标签 |
| 写给未来 | 重塑后接受 | 有意图的未来记忆 | 不限定情侣/礼物/表白，不强推分享 |
| AI 个性画像 | 当前拒绝 | 用户确认的上下文偏好 | 不自动生成固定人格标签 |
| 连续打卡/等级 | 拒绝强激励版本 | 温和展示陪伴时间 | 无惩罚、排名、羞耻、强 streak |
| 社交广场 | 拒绝进入近期主线 | 私密导出（如确有需求） | 默认私密，分享不是增长主路径 |
| Emotion Light | 延后到 V2 | 低侵入状态表达与陪伴 | 默认不显示私密文本，可随时断开/删除设备数据 |
| RAG/向量记忆 | 延后 | 可控长期检索 | 先有显式 consent、来源、删除传播和评估集 |

### 9.4 建议里程碑

| 里程碑 | 目标 | 出口标准 |
|---|---|---|
| V1.0 Release Candidate | 安全可发布的记录主闭环 | P0 全清、CI 全绿、备份恢复、删除/导出最小能力 |
| V1.1 Private Memory | 真正可控的长期记忆 | Memory 可写可删可追溯，AI consent 闭环 |
| V1.2 Reflective Companion | 稳定真实 AI 与周期反思 | provider SLO、质量评估、月度回顾、fallback 成熟 |
| V2 Device Experiment | 数字陪伴向低侵入硬件延伸 | 设备隐私模型、BLE/NFC 原型、断联/删除机制 |

---

## 附录 A：本次分析的关键事实边界

- 当前分支：`main`；最后提交 `b823660 Add mobile profile settings screen`。
- 当前存在大量用户未提交改动，包括 My ZEROON、Sprint 06/07、OpenAPI、移动 UI、测试与脚本；本报告未修改这些文件。
- 本地 backend/mobile/admin 三个服务均在运行，但本次没有改变或重启服务。
- 测试通过不等于生产就绪；真实短信、真实 LLM、真实 PostgreSQL 多实例、CI 和备份恢复尚未得到本报告验证。
- 评分以 2026-07-12 当前工作区为准；若只按 Git HEAD，Sprint 06 完成度应下调。

## 附录 B：最高优先级结论摘要

```text
1. 先堵住 Admin 普通用户可访问、默认密钥/验证码这类上线阻断风险。
2. 让 AI profile consent 真正生效，让 Memory 真正能写入、可见、可删。
3. 把 LLM 调用移出长数据库事务，完成真实 provider 的三路径验证。
4. 修复 Admin lint/测试并建立统一 CI 质量门禁。
5. 统一 README、CURRENT_STATE、Sprint、架构和 OpenAPI 的事实状态。
6. 暂不拆微服务，也不急于上 RAG；先把私密长期记忆的控制模型做对。
```
