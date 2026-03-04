# `lib/data` 目录说明

这里负责应用的数据读写和状态提供。

## 文件职责

- `providers.dart`
  - 暴露数据库 provider
  - 暴露分类与支出流
  - 定义 `ExpenseWithCategory` 聚合模型

- `providers.g.dart`
  - Riverpod 生成文件
  - 不要手动修改

- `local/database.dart`
  - Drift 表定义
  - 数据库实例与迁移策略
  - SQLite 文件连接逻辑

- `local/database.g.dart`
  - Drift 生成文件
  - 不要手动修改

## 当前实现重点

- `expensesProvider` 已经在 SQL 层按时间范围过滤，不是把所有数据取出后再在 Dart 层过滤。
- 分类和支出通过 join 查询组合成 `ExpenseWithCategory`，这样 UI 层不需要自己再次查分类。
- 数据库首次创建时会预置一个 `General` 分类。
- 启动数据库时会执行 `PRAGMA foreign_keys = ON`。

## 维护注意

- 如果修改了表结构，记得同步更新 `schemaVersion` 和迁移逻辑。
- 如果新增 provider，优先复用已有数据库 provider，不要重复创建数据库实例。
- 恢复备份后目前是通过 `invalidate` 刷新 provider，但实际体验上仍提示重启，后续可进一步完善。
