# 0003 内置资源管理工具与 CRUD API

本文档定义一个内置管理工具，用于统一管理根目录下 `resources/` 的三类资源：
- `definitions`
- `implementations`
- `references`

本文档仅定义资源级别的增删改查（CRUD）能力，不定义资源文件夹内部 `layout`。

## 设计边界

- 管理对象：资源文件夹（而非资源内部文件结构）。
- 资源表达：可将每个资源抽象为一个 JSON 字符串。
- 存储细节：资源 JSON 如何落地到资源文件夹内部，由后续实现决定，不在本文件约束。

## 资源标识模型

为支持统一 CRUD，定义资源标识 `ResourceId`：

```json
{
  "kind": "definitions | implementations | references",
  "path": "相对于 kind 根目录的资源路径"
}
```

约束：
- `kind` 必须属于三类资源之一。
- `path` 为相对路径，不允许 `..` 越级，不允许绝对路径。
- 资源文件夹可位于不同层级的叶子节点，`path` 深度不受固定限制。

## 统一数据模型

### ResourceRecord

```json
{
  "id": {
    "kind": "definitions",
    "path": "earth-observation/atmosphere/aerosol-retrieval"
  },
  "payload": "{...JSON字符串...}",
  "version": 1,
  "createdAt": "2026-02-25T10:00:00Z",
  "updatedAt": "2026-02-25T10:00:00Z"
}
```

说明：
- `payload` 为 JSON 字符串（字符串内容本身是 JSON 文本）。
- `version` 用于并发更新控制（可选实现为乐观锁）。

## API 定义

以下为工具对外暴露的逻辑 API。可由 CLI、SDK 或服务接口进行映射。

### 1) Create（新增）

`createResource(input) -> ResourceRecord`

输入：

```json
{
  "id": {
    "kind": "definitions",
    "path": "earth-observation/atmosphere/aerosol-retrieval"
  },
  "payload": "{\"name\":\"Aerosol Retrieval\",\"tags\":[\"atmosphere\"]}",
  "ifNotExists": true
}
```

语义：
- 在 `resources/<kind>/<path>/` 创建资源。
- 当 `ifNotExists=true` 且资源已存在时，返回冲突错误。

### 2) Read（查询）

`getResource(id) -> ResourceRecord`

输入：

```json
{
  "kind": "definitions",
  "path": "earth-observation/atmosphere/aerosol-retrieval"
}
```

语义：
- 返回资源记录（含 `payload` JSON 字符串和元信息）。
- 不存在时返回未找到错误。

### 3) Update（更新）

`updateResource(input) -> ResourceRecord`

输入：

```json
{
  "id": {
    "kind": "definitions",
    "path": "earth-observation/atmosphere/aerosol-retrieval"
  },
  "payload": "{\"name\":\"Aerosol Retrieval v2\",\"tags\":[\"atmosphere\",\"remote-sensing\"]}",
  "expectedVersion": 1
}
```

语义：
- 全量替换资源的 `payload`。
- 当提供 `expectedVersion` 时执行乐观并发控制，版本不匹配返回冲突错误。

### 4) Delete（删除）

`deleteResource(input) -> { "deleted": true }`

输入：

```json
{
  "id": {
    "kind": "definitions",
    "path": "earth-observation/atmosphere/aerosol-retrieval"
  },
  "recursive": true
}
```

语义：
- 删除目标资源。
- `recursive` 表示是否允许删除资源目录下的全部内容（默认 `true`）。
- 不存在时返回未找到错误。

### 5) List（列举，Read 扩展）

`listResources(query) -> { "items": [ResourceRecord], "nextToken": "..." }`

输入：

```json
{
  "kind": "definitions",
  "prefix": "earth-observation/atmosphere",
  "limit": 50,
  "nextToken": null
}
```

语义：
- 按 `kind` 与 `prefix` 列举资源。
- 支持分页遍历。

## 错误模型

统一返回：

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "resource does not exist",
    "details": {}
  }
}
```

建议错误码：
- `INVALID_ARGUMENT`
- `RESOURCE_NOT_FOUND`
- `RESOURCE_ALREADY_EXISTS`
- `VERSION_CONFLICT`
- `PERMISSION_DENIED`
- `INTERNAL_ERROR`

## CLI 映射（建议）

内置工具可命名为 `loom resources`，映射如下：

- `loom resources create --kind <kind> --path <path> --payload '<json>'`
- `loom resources get --kind <kind> --path <path>`
- `loom resources update --kind <kind> --path <path> --payload '<json>' [--expected-version <n>]`
- `loom resources delete --kind <kind> --path <path> [--recursive]`
- `loom resources list --kind <kind> [--prefix <prefix>] [--limit <n>] [--next-token <token>]`

说明：
- CLI 只要求传入资源级参数，不暴露资源内部结构细节。
- 后续如需支持批量操作，可在此基础上增加 batch API。
