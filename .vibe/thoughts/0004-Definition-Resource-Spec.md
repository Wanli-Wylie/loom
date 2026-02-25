# 0004 definition 资源定义（MVP：算子接口）

本文档给出 `definition` 资源的一版 MVP 定义。  
目标是先统一“算子接口”的表达方式，不涉及算子实现与资源内部布局细节。

## 1. 目标与范围

`definition` 资源用于描述算子的行为边界，可类比 EDA 中模块的行为模型（black-box）：
- 只定义输入/输出端口及其类型；
- 不描述算法过程；
- 不描述运行时、性能和部署信息；
- 不约束 `definition` 资源文件夹内部 `layout`。

本版聚焦：**强类型接口定义**，类型系统采用 Lean4 数学类型表达。

## 2. 核心抽象

一个 `definition` 资源在语义上可视为：

`OperatorInterface := TypedInputs -> TypedOutputs`

其中：
- `TypedInputs`：一组命名输入端口，每个端口有明确 Lean4 类型；
- `TypedOutputs`：一组命名输出端口，每个端口有明确 Lean4 类型。

接口是稳定契约；实现可替换，但必须满足该契约。

## 3. Lean4 类型约定（MVP）

### 3.1 类型表达

- 每个端口类型使用一个 `leanType` 字符串表示；
- `leanType` 必须是合法 Lean4 类型表达式（可被 Lean4 解析）；
- 可使用基础数学类型（如 `Nat`、`Int`、`Rat`、`Real`、`Bool`）；
- 可使用地学领域类型（如 `Geo.Raster Real`），前提是其来源模块已声明。

### 3.2 纯接口约束

MVP 默认将算子定义为纯计算接口，接口层不引入副作用类型：
- 不建议在接口端口中使用 `IO` 等执行态类型；
- 若后续存在必须的外部效应，另行在扩展规范中定义。

### 3.3 泛型与参数化

允许在接口中声明类型参数（如 `α : Type`），用于抽象复用。  
MVP 阶段仅要求参数可读、可解析，不要求证明自动化。

## 4. JSON 载荷模型（用于资源 CRUD）

为配合 `0003` 的资源管理 API，`definition` 资源可用如下 JSON 字符串表达：

```json
{
  "schemaVersion": "definition.m1",
  "operatorId": "eo.vegetation.ndvi",
  "displayName": "NDVI",
  "category": "definitions",
  "interface": {
    "module": "GeoOps.Vegetation",
    "name": "ndvi",
    "typeParams": [],
    "inputs": [
      {
        "name": "nir",
        "leanType": "Geo.Raster Real",
        "description": "近红外反射率栅格"
      },
      {
        "name": "red",
        "leanType": "Geo.Raster Real",
        "description": "红光反射率栅格"
      }
    ],
    "outputs": [
      {
        "name": "index",
        "leanType": "Geo.Raster Real",
        "description": "NDVI 结果栅格"
      }
    ],
    "signatureLean": "def ndvi (nir : Geo.Raster Real) (red : Geo.Raster Real) : Geo.Raster Real"
  },
  "docs": {
    "summary": "归一化植被指数接口定义（仅接口，不含实现）"
  }
}
```

说明：
- `payload` 是 JSON 字符串；以上结构是字符串内 JSON 的建议内容。
- `signatureLean` 是接口签名的可读主表达，`inputs/outputs` 提供结构化端口信息。

## 5. 字段最小要求（MVP）

以下字段建议作为最小必填：
- `schemaVersion`
- `operatorId`
- `interface.module`
- `interface.name`
- `interface.inputs[]`（每项至少含 `name`、`leanType`）
- `interface.outputs[]`（每项至少含 `name`、`leanType`）
- `interface.signatureLean`

## 6. 校验规则（MVP）

管理工具在 `create/update` 时至少执行以下校验：

1. `operatorId` 非空且在命名空间内唯一。  
2. 输入/输出端口名在各自集合内唯一。  
3. 每个 `leanType` 非空且可由 Lean4 语法解析。  
4. `signatureLean` 与 `inputs/outputs` 在参数数量和类型上保持一致。  
5. 不检查算法正确性，不检查定理证明，仅检查接口一致性。

## 7. 与 0002/0003 的关系

- 与 `0002` 一致：`definition` 资源作为 `resources/definitions/` 下的资源文件夹存在，内部布局后续定义。
- 与 `0003` 一致：本规范提供 `payload` 的语义模型，可直接被 `create/get/update/delete/list` 管理。

## 8. 后续扩展方向（非 MVP）

- 语义约束：前置条件、后置条件与不变量；
- 维度与单位系统（量纲检查）；
- 接口兼容性规则（版本升级时的 breaking/non-breaking 判定）；
- 与 Lean 定理证明对象联动（从“接口可解析”扩展到“接口可验证”）。
