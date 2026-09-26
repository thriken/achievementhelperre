# AchievementHelperRe

<div align="center">

**魔兽世界 · 成就物品提示插件**

`Version 12.0.1-20260926` · `Interface 120100` · 简体中文 / 繁體中文 / English

[CurseForge {正式版}](https://www.curseforge.com/wow/addons/achievementhelperre)  · 
[原插件 Achievement Helper \[已断更\]](https://www.curseforge.com/wow/addons/achievement-helper)

Author:Thriken @[Github](https://github.com/thriken/achievementhelperre)
</div>

---

## 简介

在物品鼠标提示（Tooltip）中标记成就所需的 **食物 / 饮料 / 装备**，并直接显示当前状态：

- 红色 = 尚未使用（还可用于完成成就）
- 绿色 = 已使用（该成就条件已完成）

无需再翻成就面板对照清单，鼠标划过物品即可判断该不该吃、该不该喝。

## 功能特性

| 特性 | 说明 |
| :--- | :--- |
| 物品提示标记 | 在 Tooltip 中追加成就名与「可使用 / 已使用」状态 |
| 状态配色 | 未使用显示红色，已使用显示绿色 |
| 多语言支持 | 简体中文、繁体中文、美国英语（其余语言自动回退英文） |
| 轻量无配置 | 装上即用，无设置界面，不占用额外内存常驻开销 |
| 数据自动扫描 | 登录时自动构建成就物品数据库，可手动重扫 |

## 安装

1. 下载或克隆本仓库。
2. 将文件夹重命名为 `AchievementHelperRe`。
3. 放入 World of Warcraft 安装目录：

   ```text
   _retail_\Interface\AddOns\AchievementHelperRe\
   ```

4. 完全退出并重新启动游戏客户端，在角色选择界面左下角确认插件已勾选启用。

## 使用

插件无需任何配置，登录即自动生效。把鼠标移到食物、饮料或装备上即可看到提示。

### 命令

在游戏聊天框输入：

| 命令 | 作用 |
| :--- | :--- |
| `/ahre` | 输出当前已收录物品条目数与各成就的收录情况 |
| `/ahre scan` | 重新扫描并构建成就物品数据库，随后输出状态 |
| `/ahre debug` | 输出调试信息：数据库统计 + 各成就前 3 条条件明细 |
| `/ahre <物品ID>` | 查询指定物品：所属成就 ID、条件序号、是否已完成 |

> 所有输出统一以 `[AHRE]` 前缀标识。

## 文件结构

```text
AchievementHelperRe/
├─ AchievementHelperRe.toc   # 插件描述文件（版本、标题、加载顺序）
├─ AchievementHelperRe.lua   # 主逻辑：数据扫描与 Tooltip 注入
├─ Locales.lua               # 多语言文本包
├─ LICENSE
└─ README.md
```

### 新增语言

在 `Locales.lua` 的 `LOCALES` 表中照抄一份即可，key 使用 `GetLocale()` 的返回值（如 `enUS`、`zhCN`、`zhTW`）。未收录的语言会自动回退到 `enUS`。

## 更新日志

### 12.0 更新

1. 完全重新编写了新插件。
2. 目前没有发现 BUG。
3. 支持多语言，目前仅简体中文、繁体中文、美国英语。
4. 未使用提示颜色为红色，已使用提示颜色为绿色。

> 作者自 9.0 前夕已 AFK，维护频率有限。

## 版权与致谢

- 版权归原作者所有，本项目为修改版（Author: `Timmy2250`）。
- 原插件：[Achievement Helper](https://www.curseforge.com/wow/addons/achievement-helper)
- 许可条款详见 [LICENSE](./LICENSE)。
