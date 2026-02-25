# 0002 基本资源组织方式

本文档定义系统中基础资源的文件系统组织约定。

## 根目录结构

在项目根目录下，统一使用 `resources/` 作为资源总入口，并包含以下三个子目录：

- `resources/definitions/`
- `resources/implementations/`
- `resources/references/`

三者分别对应三类资源：定义资源、实现资源、参考资源。

## 层次化资源定义

每个子目录及其文件系统层级共同构成该类资源的层次化定义空间。  
也即，目录层级不仅用于存储文件，也用于表达资源在领域、主题、版本或其他维度上的组织关系。

## 资源表示约定

每个具体资源使用一个文件夹来表示与刻画。  
该资源文件夹内部的详细 `layout` 当前暂不在本文件中固定，后续另行定义。

## 叶子节点放置规则

代表资源的文件夹可以出现在叶子节点的各个层级。  
换言之，不要求所有资源必须位于统一深度；允许根据实际组织语义，在不同层级的叶子节点放置资源文件夹。

## 示例（仅用于说明层次，不约束内部 layout）

```text
resources/
  definitions/
    earth-observation/
      atmosphere/
        aerosol-retrieval/
      hydrology/
        surface-water-extraction/
  implementations/
    earth-observation/
      atmosphere/
        aerosol-retrieval-gf6/
      hydrology/
        surface-water-extraction-s1/
  references/
    earth-observation/
      atmosphere/
        aerosol-retrieval-paper-set/
      hydrology/
        surface-water-extraction-benchmark/
```
