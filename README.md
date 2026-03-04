# Expense Tracker

一个使用 Flutter 构建的本地记账应用，数据存储在 SQLite 中，状态管理使用 Riverpod，图表展示使用 `fl_chart`。

## 项目功能

- 新增、编辑、删除支出记录
- 按月、按年、自定义时间范围筛选数据
- 按分类查看支出占比与总额
- 分类管理：新增、编辑、删除分类
- 数据备份与恢复
- 本地持久化，不依赖远程服务

## 技术栈

- Flutter
- Riverpod
- Drift + SQLite
- fl_chart
- intl
- share_plus
- file_picker

## 目录说明

```text
expense_tracker/
|- lib/
|  |- data/          数据层：数据库、provider、查询逻辑
|  |- ui/            页面与组件
|  |- main.dart      应用入口
|- test/             测试目录
|- android/ios/...   Flutter 平台工程
|- pubspec.yaml      依赖与项目配置
```

更多细节可看：

- [lib/README.md](lib/README.md)
- [lib/data/README.md](lib/data/README.md)
- [lib/ui/README.md](lib/ui/README.md)
- [test/README.md](test/README.md)

## 当前数据结构

### `categories`

- `id`: 自增主键
- `name`: 分类名称
- `icon`: Material Icon 的 code point 字符串，可为空
- `color`: 分类颜色值

### `expenses`

- `id`: 自增主键
- `amount`: 金额
- `date`: 支出时间
- `note`: 备注，可为空
- `categoryId`: 关联分类

项目首次创建数据库时会自动插入一个默认分类 `General`。

## 本地运行

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 生成代码

这个项目使用了 Drift 和 Riverpod 的代码生成：

```bash
dart run build_runner build --delete-conflicting-outputs
```

如果开发时需要持续监听：

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 3. 启动应用

```bash
flutter run
```

## 关键代码入口

- 应用入口：[lib/main.dart](lib/main.dart)
- 首页与筛选逻辑：[lib/ui/home_screen.dart](lib/ui/home_screen.dart)
- 新增/编辑支出：[lib/ui/add_expense_screen.dart](lib/ui/add_expense_screen.dart)
- 分类管理与备份恢复：[lib/ui/category_manager_screen.dart](lib/ui/category_manager_screen.dart)
- 数据库定义：[lib/data/local/database.dart](lib/data/local/database.dart)
- Provider 与查询：[lib/data/providers.dart](lib/data/providers.dart)

## 目前值得注意的点

- 数据库是本地 `db.sqlite`，运行后会放在应用文档目录，不是仓库根目录。
- `lib/data/providers.g.dart` 与 `lib/data/local/database.g.dart` 是生成文件，不建议手改。
- 当前 `test/widget_test.dart` 还是 Flutter 默认模板测试，和现有业务界面不匹配，后续应补成真实业务测试。
- 仓库根目录里有 `build/`、`.dart_tool/`、`db.sqlite`、`build_log*.txt` 这类开发产物，日常维护时建议区分清楚哪些是源码、哪些是运行产物。

## 后续建议

- 增加导入/恢复后的数据库重载处理，减少“建议重启应用”的依赖
- 补充分类删除时对关联支出的约束说明或迁移策略
- 补上针对筛选、增删改、备份恢复的测试
