# `lib` 目录说明

`lib` 是应用核心源码目录，主要分成入口、数据层、界面层三部分。

## 结构

```text
lib/
|- main.dart
|- data/
|  |- local/
|  |- providers.dart
|  |- providers.g.dart
|- ui/
```

## 主要职责

- `main.dart`
  - 应用入口
  - 初始化 `ProviderScope`
  - 配置 `MaterialApp` 主题与首页

- `data/`
  - 数据库表结构
  - 本地 SQLite 连接
  - Riverpod provider
  - 支出与分类查询逻辑

- `ui/`
  - 页面
  - 可复用 UI 组件
  - 用户交互逻辑

## 维护建议

- 新业务优先按“数据层 / 页面层”拆分，不要把数据库操作直接散落到多个页面中。
- 生成文件如 `*.g.dart` 不要手改，应通过 `build_runner` 重新生成。
- 如果后续功能继续增加，建议把 `ui/` 再拆成 `screens/`、`widgets/`，把页面和组件分开。
