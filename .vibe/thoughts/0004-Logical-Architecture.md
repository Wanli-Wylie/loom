# 0004 - Loom Rust 应用逻辑架构设计（Draft）

本设计只讨论逻辑架构与运行时子系统，不讨论 source code layout。

## 1. 目标与边界
- 目标：把 `loom` 设计成可长期演进的 Rust CLI 应用，先覆盖 operator 元数据 CRUD，再平滑扩展到验证、解析、发布、索引等能力。
- 核心边界：`loom` 是 operator manager，不是 workflow orchestrator，不负责执行外部计算图调度。
- 一致性基线：数学语义以 `Lean4 + Mathlib` 为规范源，运行时实现（Fortran/C++/Rust 等）必须映射到同一数学定义。

## 2. 架构不变量
- 语义先于实现：先有数学定义与契约，再有具体实现定义。
- Functional Core / Imperative Shell：纯计算逻辑与 I/O、副作用完全解耦。
- Command-Query Separation：查询不改状态，写入不返回隐式派生状态。
- Deterministic I/O：同一输入与同一仓库状态下，CLI 输出和写入结果可复现。
- Typed Domain First：核心概念（OperatorId、SemVer、FieldPath、MathRef）必须有强类型边界。

## 3. 逻辑解耦层（不绑定目录）

## 3.1 Domain Core（纯逻辑）
- 责任：定义系统核心对象和不可变规则。
- 包含：Operator、Version、MathSpec、TheoremSet、Contract、ImplementationSpec、Provenance。
- 输出：领域对象、不可变约束检查结果。

## 3.2 Command Core（写路径纯逻辑）
- 责任：定义 `add/set/remove` 的语义、前置条件、冲突策略与变更计划（ChangeSet）。
- 输入：命令意图 + 当前领域快照。
- 输出：可提交的 ChangeSet，不直接触盘。

## 3.3 Query Core（读路径纯逻辑）
- 责任：定义 `info` 的字段路径解析、投影与渲染前结构。
- 输入：查询条件 + 领域快照。
- 输出：查询结果模型（可被 text/json renderer 消费）。

## 3.4 Validation Core（纯逻辑）
- 责任：执行 schema、跨文档引用、版本兼容性、数学映射一致性校验。
- 关键约束：实现定义必须绑定到 Lean 定义（例如 `math_ref` 指向 `spec.lean`/`theorems.lean` 中的符号）。

## 3.5 Compatibility & Policy Core（纯逻辑）
- 责任：判断变更的语义等级（patch/minor/major）与 breaking change。
- 输入：变更前后快照 + 兼容策略。
- 输出：兼容性判定与建议版本升级级别。

## 3.6 Formal Math Core（纯逻辑 + 工具桥接协议）
- 责任：维护 Lean4/Mathlib 相关的规范信息模型。
- 包含：Lean 目标模块、Mathlib pin、定理状态（declared/proved/assumed）元数据。
- 注意：该层只定义“需要什么”，不直接依赖进程执行。

## 3.7 Application Orchestrator（编排层）
- 责任：把 CLI 请求组织为稳定流水线（load -> compute -> validate -> commit）。
- 约束：仅负责编排，不承载领域规则。

## 3.8 Ports（抽象端口层）
- 责任：定义外部依赖接口（FS、序列化、索引、日志、Lean 工具、时钟）。
- 形式：trait 风格契约，避免领域层依赖具体实现。

## 3.9 Adapters（适配层）
- 责任：把 Ports 连接到具体运行时实现（本地文件系统、YAML/JSON codec、Lean 进程调用等）。
- 约束：可替换、可测试、可降级。

## 4. 运行时子系统划分

## 4.1 CLI Host 子系统
- 责任：参数解析、子命令路由、退出码映射、终端输出策略。
- 输入：argv/env。
- 输出：标准化命令请求。

## 4.2 Session & Context 子系统
- 责任：`--directory`/`--project` 解析、workspace 发现、配置装载、运行上下文构建。
- 输出：统一 `ExecutionContext`。

## 4.3 Storage 子系统
- 责任：读取与写入 operator 资产（YAML/Lean 文本等）、原子提交、回滚点。
- 关键能力：多文件一致提交（all-or-nothing）。

## 4.4 Index & Query 子系统
- 责任：构建/维护可查询索引，加速 `info` 与后续 `list/search`。
- 约束：索引是派生状态，可重建，不作为真相源。

## 4.5 Validation 子系统
- 责任：在写入前执行分层校验。
- 分层：结构校验、引用校验、兼容性校验、数学绑定校验。

## 4.6 Lean Bridge 子系统
- 责任：与 Lean4 工具链交互（版本探测、可解析性检查、可选定理检查）。
- 输入：`math/spec.lean`、`math/theorems.lean`、`math/mathlib.yaml`。
- 输出：结构化诊断，不泄漏底层工具细节到 Domain 层。

## 4.7 Transaction & Journal 子系统
- 责任：管理 ChangeSet 生命周期、提交日志、失败恢复。
- 语义：命令可追踪、可审计、可重放（至少逻辑上可重放）。

## 4.8 Observability 子系统
- 责任：结构化日志、错误分类、性能指标、调试事件。
- 约束：观测为旁路，不影响领域结果。

## 4.9 Extension/Plugin 子系统（后续）
- 责任：扩展命令、验证器、导入导出器。
- 边界：插件只能通过 Ports/Policy 暴露的稳定接口交互。

## 5. 子系统交互主流程

## 5.1 查询路径（`loom info`）
1. CLI Host 解析请求。
2. Session 构建上下文并定位 workspace。
3. Storage 读取快照。
4. Query Core 解析 FieldPath 并投影结果。
5. Renderer 输出 text/json。

## 5.2 写路径（`loom add/set/remove`）
1. CLI Host 解析命令。
2. Session 构建上下文。
3. Storage 读取基线快照。
4. Command Core 生成 ChangeSet。
5. Validation Core + Lean Bridge 执行校验。
6. Transaction 子系统原子提交并记录 journal。
7. Index 子系统增量更新或标记重建。
8. CLI Host 返回稳定输出与退出码。

## 6. 核心逻辑契约表

| 逻辑单元 | 输入 | 输出 | 不变量 | 错误语义 | 稳定性 |
|---|---|---|---|---|---|
| Domain Core | 原始文档模型 | 强类型领域对象 | 类型与约束完整 | `DomainError` | High |
| Command Core | 命令 + 领域快照 | ChangeSet | 不直接 I/O | `CommandError` | High |
| Query Core | 查询 + 领域快照 | QueryResult | 不修改状态 | `QueryError` | High |
| Validation Core | ChangeSet + 快照 | ValidationReport | 先校验后提交 | `ValidationError` | High |
| Compatibility Core | before/after | SemVerImpact | 判定可解释 | `PolicyError` | Medium |
| Lean Bridge | Lean 资产 + pin | LeanReport | 与 pin 一致 | `LeanError` | Medium |
| Storage Adapter | ChangeSet | CommitReceipt | 原子性 | `StorageError` | Medium |

## 7. Rust 最佳实践约束（架构级）
- Error Model：统一顶层错误枚举，子系统错误保留语义标签，避免字符串错误。
- Ownership Model：跨子系统传递不可变快照，写路径以 ChangeSet 驱动，减少共享可变状态。
- Trait-based DIP：Domain/Core 仅依赖 Ports trait，不依赖具体 I/O crate。
- Sync Core, Async Shell：核心逻辑保持同步纯函数；外部 I/O 适配器可按需要异步化。
- Serialization Stability：对外 JSON 输出版本化，避免脚本兼容性破坏。
- Feature Gating：Lean 校验、索引后端、插件能力通过 capability/feature 显式启用。

## 8. 主要风险与反模式
- 风险：把兼容性规则散落在 Adapter，导致规则不可审计。
- 风险：Command 与 Query 复用同一“万能服务”，引入隐式写入。
- 风险：直接以字符串路径操作文档，绕过强类型 FieldPath。
- 风险：Lean 工具调用结果直接耦合 CLI 文本，导致诊断协议不稳定。
- 反模式：把业务规则放进 CLI 参数解析层。

## 9. 分层测试策略
- Unit（Core）：Domain/Command/Query/Validation 纯逻辑测试，固定输入输出。
- Contract（Ports）：Storage/Lean/Index adapter 的契约测试，验证实现替换不破坏行为。
- Integration（Runtime）：CLI 到 commit 的端到端流程测试，覆盖退出码与原子提交。
- Golden（UX/API）：`--format json` 输出快照测试，保证脚本兼容。

## 10. 演进路线（面向扩展）
- Phase 1：CRUD + 基础校验 + 原子提交 + 稳定输出。
- Phase 2：`validate/list/diff/init`，补全兼容性策略与索引能力。
- Phase 3：插件化验证器、远端 registry 协议、跨项目依赖解析。
- Phase 4：多后端存储与分布式缓存，但仍保持 Domain/Core 不变。

## 11. 结论
该架构将 `loom` 拆分为“可验证的纯逻辑核心”与“可替换的运行时子系统”，满足 Rust 项目在可维护性、可测试性、可演进性上的最佳实践要求，并为 Lean4/Mathlib 统一数学表达提供长期稳定的扩展基座。
