local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhCN" then
    return
end

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "有一些问题可能会阻止 FrameSort 正常工作。"
L["Please go to the Health Check panel to view more details."] = "请前往健康检查面板查看更多详细信息。"
L["Role"] = "角色"
L["Group"] = "小组"
L["Alphabetical"] = "字母顺序"
L["Arena - 2v2"] = "竞技场 - 2v2"
L["Arena - 3v3"] = "竞技场 - 3v3"
L["Arena - 3v3 & 5v5"] = "竞技场 - 3v3 & 5v5"
L["Enemy Arena (see addons panel for supported addons)"] = "敌方竞技场（请查看插件面板以获取支持的插件）"
L["Dungeon (mythics, 5-mans, delves)"] = "地下城（神话、5人、深入）"
L["Raid (battlegrounds, raids)"] = "团队（战场、团队）"
L["World (non-instance groups)"] = "世界（非副本小组）"
L["Player"] = "玩家"
L["Sort"] = "排序"
L["Top"] = "上"
L["Middle"] = "中"
L["Bottom"] = "下"
L["Hidden"] = "隐藏"
L["Group"] = "小组"
L["Reverse"] = "反向"

-- # Sorting Method screen #
L["Sorting Method"] = "排序方法"
L["Secure"] = "安全"
L["SortingMethod_Secure_Description"] = [[
调整每个单独框架的位置，不会干扰/锁定/污染用户界面。
\n
优点：
 - 可以对其他插件的框架进行排序。
 - 可以应用框架间距。
 - 无污染（技术术语，指插件干扰暴雪的用户界面代码）。
\n
缺点：
 - 脆弱的卡片屋结构，以便绕过暴雪的混乱代码。
 - 在魔兽世界补丁中可能会中断并使开发者发疯。
]]
L["Traditional"] = "传统"
L["SortingMethod_Traditional_Description"] = [[
这是插件和宏使用了10年以上的标准排序模式。
它用我们自己的方法替换了暴雪的内部排序方法。
这与“SetFlowSortFunction”脚本相同，但使用了 FrameSort 配置。
\n
优点：
 - 更稳定/可靠，因为它利用了暴雪的内部排序方法。
\n
缺点：
 - 仅对暴雪的队伍框架进行排序，没有其他。
 - 会导致 Lua 错误，这是正常的，可以忽略。
 - 无法应用框架间距。
]]
L["Please reload after changing these settings."] = "更改这些设置后，请重新加载。"
L["Reload"] = "重新加载"

-- # Ordering screen #
L["Ordering"] = "排序"
L["Specify the ordering you wish to use when sorting by role."] = "指定在按角色排序时希望使用的顺序。"
L["Tanks"] = "坦克"
L["Healers"] = "治疗"
L["Casters"] = "施法者"
L["Hunters"] = "猎人"
L["Melee"] = "近战"

-- # Auto Leader screen #
L["Auto Leader"] = "自动首领"
L["Auto promote healers to leader in solo shuffle."] = "在单人洗牌中自动提升治疗者为首领。"
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "为什么？这样治疗者可以配置目标标记图标并重新排序 party1/2 以符合他们的偏好。"
L["Enabled"] = "启用"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "目标选择"
L["Target frame 1 (top frame)"] = "目标框架 1（顶部框架）"
L["Target frame 2"] = "目标框架 2"
L["Target frame 3"] = "目标框架 3"
L["Target frame 4"] = "目标框架 4"
L["Target frame 5"] = "目标框架 5"
L["Target bottom frame"] = "目标底部框架"
L["Target 1 frame above bottom"] = "目标底部上方的框架 1"
L["Target 2 frames above bottom"] = "目标底部上方的框架 2"
L["Target 3 frames above bottom"] = "目标底部上方的框架 3"
L["Target 4 frames above bottom"] = "目标底部上方的框架 4"
L["Target frame 1's pet"] = "目标框架 1 的宠物"
L["Target frame 2's pet"] = "目标框架 2 的宠物"
L["Target frame 3's pet"] = "目标框架 3 的宠物"
L["Target frame 4's pet"] = "目标框架 4 的宠物"
L["Target frame 5's pet"] = "目标框架 5 的宠物"
L["Target enemy frame 1"] = "目标敌方框架 1"
L["Target enemy frame 2"] = "目标敌方框架 2"
L["Target enemy frame 3"] = "目标敌方框架 3"
L["Target enemy frame 1's pet"] = "目标敌方框架 1 的宠物"
L["Target enemy frame 2's pet"] = "目标敌方框架 2 的宠物"
L["Target enemy frame 3's pet"] = "目标敌方框架 3 的宠物"
L["Focus enemy frame 1"] = "专注敌方框架 1"
L["Focus enemy frame 2"] = "专注敌方框架 2"
L["Focus enemy frame 3"] = "专注敌方框架 3"
L["Cycle to the next frame"] = "切换到下一个框架"
L["Cycle to the previous frame"] = "切换到上一个框架"
L["Target the next frame"] = "目标下一个框架"
L["Target the previous frame"] = "目标上一个框架"

-- # Keybindings screen #
L["Keybindings"] = "按键绑定"
L["Keybindings_Description"] = [[
您可以在标准的魔兽世界按键绑定区域找到 FrameSort 的按键绑定。
\n
按键绑定有什么用？
它们对于根据视觉排序表示而不是通过队伍位置（如 party1/2/3 等）来选择玩家非常有用。
\n
例如，想象以下按角色排序的5人地下城小组：
  - 坦克，party3
  - 治疗者，玩家
  - DPS，party1
  - DPS，party4
  - DPS，party2
\n
如您所见，它们的视觉表示与实际的队伍位置不同，这使得目标选择变得困惑。
如果您输入 /target party1，它将选择位置 3 的 DPS 玩家，而不是坦克。
\n
FrameSort 的按键绑定将基于它们的视觉框架位置而不是队伍编号进行目标选择。
因此，目标“框架 1”将目标坦克，“框架 2”将目标治疗者，“框架 3”将目标位置 3 的 DPS，等等。
]]

-- # Macros screen # --
L["Macros"] = "宏"
L["FrameSort has found %d |4macro:macros; to manage."] = "FrameSort 找到了 %d 个 |4宏:宏; 需要管理。"
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "FrameSort 将动态更新包含 '#FrameSort' 头的宏中的变量。"
L["Below are some examples on how to use this."] = "以下是一些使用示例。"

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists] 圣殿祝福]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] 驱散]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] 影遁;
/cast [@placeholder] 断击;]]

L["Example %d"] = "示例 %d"
L["Discord Bot Blurb"] = [[
需要帮助创建宏吗？ 
\n
请访问 FrameSort Discord 服务器，使用我们的 AI 驱动的宏机器人！
\n
只需在宏机器人频道中和 '@Macro Bot' 谈谈您的问题。
]]

-- # Macro Variables screen # --
L["Macro Variables"] = "宏变量"
L["The first DPS that's not you."] = "第一个不是你的 DPS。"
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "添加一个数字来选择第 N 个目标，例如 DPS2 选择第 2 个 DPS。"
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "变量不区分大小写，因此 'fRaMe1'、'Dps'、'enemyhealer' 等都可以使用。"
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "需要节省宏字符吗？使用缩写来缩短它们："
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '使用 "X" 告诉 FrameSort 忽略 @unit 选择器：'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] 法术;]]

-- # Spacing screen #
L["Spacing"] = "间距"
L["Add some spacing between party, raid, and arena frames."] = "在小组、团队和竞技场框架之间添加一些间距。"
L["This only applies to Blizzard frames."] = "这仅适用于暴雪框架。"
L["Party"] = "小组"
L["Raid"] = "团队"
L["Group"] = "组"
L["Horizontal"] = "水平"
L["Vertical"] = "垂直"

-- # Addons screen #
L["Addons"] = "插件"
L["Addons_Supported_Description"] = [[
FrameSort 支持以下内容：
\n
  - 暴雪：小组、团队、竞技场。
\n
  - ElvUI：小组。
\n
  - sArena：竞技场。
\n
  - Gladius：竞技场。
\n
  - GladiusEx：小组、竞技场。
\n
  - Cell：小组、团队（仅在使用组合小组时）。
\n
  - Shadowed Unit Frames：小组、竞技场。
\n
  - Grid2：小组、团队。
\n
  - BattleGroundEnemies：小组、竞技场。
\n
  - Gladdy：竞技场。
\n
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "想要将 FrameSort 集成到您的插件、脚本和弱光环中吗？"
L["Here are some examples."] = "以下是一些示例。"
L["Retrieved an ordered array of party/raid unit tokens."] = "检索到一个排序的小组/团队单位令牌数组。"
L["Retrieved an ordered array of arena unit tokens."] = "检索到一个排序的竞技场单位令牌数组。"
L["Register a callback function to run after FrameSort sorts frames."] = "注册一个回调函数，在 FrameSort 排序框架后运行。"
L["Retrieve an ordered array of party frames."] = "检索一个排序的小组框架数组。"
L["Change a FrameSort setting."] = "更改 FrameSort 设置。"
L["View a full listing of all API methods on GitHub."] = "在 GitHub 上查看所有 API 方法的完整列表。"

-- # Discord screen #
L["Discord"] = "Discord"
L["Need help with something?"] = "需要帮助吗？"
L["Talk directly with the developer on Discord."] = "直接在 Discord 上与开发者交谈。"

-- # Health Check screen -- #
L["Health Check"] = "健康检查"
L["Try this"] = "尝试这个"
L["Any known issues with configuration or conflicting addons will be shown below."] = "任何已知的配置问题或冲突插件将在下方显示。"
L["N/A"] = "不适用"
L["Passed!"] = "通过！"
L["Failed"] = "失败"
L["(unknown)"] = "(未知)"
L["(user macro)"] = "(用户宏)"
L["Using grouped layout for Cell raid frames"] = "正在使用 Cell 团队框架的组合布局"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = "请在 Cell -> 布局中检查 '组合小组（团队）' 选项"
L["Can detect frames"] = "能够检测到框架"
L["FrameSort currently supports frames from these addons: %s"] = "FrameSort 当前支持来自以下插件的框架：%s"
L["Using Raid-Style Party Frames"] = "使用团队风格的小组框架"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings"] = "请在暴雪设置中启用 '使用团队风格的小组框架'"
L["Keep Groups Together setting disabled"] = "禁用 '保持小组在一起' 设置"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = "通过编辑模式将团队显示模式更改为 '组合小组' 选项之一"
L["Disable the 'Keep Groups Together' raid profile setting."] = "禁用 '保持小组在一起' 团队配置设置。"
L["Only using Blizzard frames with Traditional mode"] = "仅使用传统模式的暴雪框架"
L["Traditional mode can't sort your other frame addons: '%s'"] = "传统模式无法对您的其他框架插件进行排序：'%s'"
L["Using Secure sorting mode when spacing is being used"] = "使用安全排序模式时正在使用间距"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] = "传统模式无法应用间距，请考虑移除间距或使用安全排序方法"
L["Blizzard sorting functions not tampered with"] = "暴雪排序功能未被篡改"
L['"%s" may cause conflicts, consider disabling it'] = '"%s" 可能会导致冲突，请考虑禁用它'
L["No conflicting addons"] = "没有冲突的插件"
L["Main tank and assist setting disabled"] = "主坦克和协助设置已禁用"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames"] = "请在选项 -> 界面 -> 团队框架中禁用 '显示主坦克和协助' 选项"

-- # Log Screen -- #
L["Log"] = "日志"
L["FrameSort log to help with diagnosing issues."] = "FrameSort 日志，用于帮助诊断问题。"
