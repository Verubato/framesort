local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhCN" then
    return
end

-- # Main Options screen #
-- used in FrameSort - 1.2.3 version header, %s is the version number
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "可能存在一些问题，导致FrameSort无法正常工作。"
L["Please go to the Health Check panel to view more details."] = "请前往健康检查面板查看更多详情。"
L["Role/spec"] = "角色/专精"
L["Group"] = "团队"
L["Alphabetical"] = "字母顺序"
L["Arena - 2v2"] = "竞技场 - 2对2"
L["Arena - 3v3"] = "竞技场 - 3对3"
L["Arena - 3v3 & 5v5"] = "竞技场 - 3对3 & 5对5"
L["Enemy Arena (see addons panel for supported addons)"] = "敌方竞技场（请查看插件面板了解支持的插件）"
L["Dungeon (mythics, 5-mans, delves)"] = "地下城（神话、5人组、深入）"
L["Raid (battlegrounds, raids)"] = "团队（战场、团队）"
L["World (non-instance groups)"] = "世界（非副本团队）"
L["Player"] = "玩家"
L["Sort"] = "排序"
L["Top"] = "顶部"
L["Middle"] = "中间"
L["Bottom"] = "底部"
L["Hidden"] = "隐藏"
L["Group"] = "组"
L["Reverse"] = "反向"

-- # Sorting Method screen #
L["Sorting Method"] = "排序方式"
L["Secure"] = "安全"
L["SortingMethod_Secure_Description"] = [[
调整每个独立框架的位置，并不会产生错误/锁定/损坏用户界面。
\n
优点：
 - 可以对其他插件的框架进行排序。
 - 可以应用框架间距。
 - 没有损坏（技术术语，指插件干扰暴雪的用户界面代码）。
\n
缺点：
 - 解决暴雪复杂代码的脆弱情况。
 - 可能会在魔兽世界的补丁中破坏，让开发者感到抓狂。
]]
L["Traditional"] = "传统"
L["SortingMethod_Secure_Traditional"] = [[
这是插件和宏使用了10年以上的标准排序模式。
它用我们自己的排序方法替代了暴雪内部的排序方法。
这与'设置流排序功能'脚本相同，但使用FrameSort进行配置。
\n
优点：
 - 更稳定/可靠，因为它利用了暴雪的内部排序方法。
\n
缺点：
 - 仅能对暴雪的队伍框架进行排序，其他无效。
 - 会产生Lua错误，这是正常的，可以忽略。
 - 无法应用框架间距。
]]
L["Please reload after changing these settings."] = "更改这些设置后，请重新加载。"
L["Reload"] = "重新加载"

-- # Ordering screen #
L["Ordering"] = "排序"
L["Specify the ordering you wish to use when sorting by role."] = "指定你希望在按角色排序时使用的顺序。"
L["Tanks"] = "坦克"
L["Healers"] = "治疗"
L["Casters"] = "施法者"
L["Hunters"] = "猎人"
L["Melee"] = "近战"

-- # Auto Leader screen #
L["Auto Leader"] = "自动队长"
L["Auto promote healers to leader in solo shuffle."] = "在单人洗牌中自动提升治疗者为队长。"
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "为什么？这样治疗者可以配置目标标记图标，并根据他们的偏好重新排序队伍1/2。"
L["Enabled"] = "启用"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "目标选择"
L["Target frame 1 (top frame)"] = "目标框架 1（顶部框架）"
L["Target frame 2"] = "目标框架 2"
L["Target frame 3"] = "目标框架 3"
L["Target frame 4"] = "目标框架 4"
L["Target frame 5"] = "目标框架 5"
L["Target bottom frame"] = "目标底部框架"
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
L["Focus enemy frame 1"] = "聚焦敌方框架 1"
L["Focus enemy frame 2"] = "聚焦敌方框架 2"
L["Focus enemy frame 3"] = "聚焦敌方框架 3"
L["Cycle to the next frame"] = "切换到下一个框架"
L["Cycle to the previous frame"] = "切换到上一个框架"
L["Target the next frame"] = "目标下一个框架"
L["Target the previous frame"] = "目标上一个框架"

-- # Keybindings screen #
L["Keybindings"] = "快捷键绑定"
L["Keybindings_Description"] = [[
你可以在标准的魔兽世界快捷键绑定区域找到FrameSort的快捷键绑定。
\n
快捷键绑定有什么用？
它们对于根据视觉排序表示而不是队伍位置（队伍1/2/3等）来选择玩家是有用的。
\n
例如，想象一个按角色排序的5人地下城团队，顺序如下：
  - 坦克，队伍3
  - 治疗，玩家
  - DPS，队伍1
  - DPS，队伍4
  - DPS，队伍2
\n
如你所见，它们的视觉表示与其实际队伍位置不同，这使得选择目标混乱。
如果你使用/target队伍1，它将选择位置3的DPS玩家而不是坦克。
\n
FrameSort的快捷键绑定将根据它们的视觉框架位置而不是队伍编号进行目标选择。
所以选择“框架1”将选择坦克，“框架2”选择治疗，“框架3”选择位置3的DPS，依此类推。
]]

-- # Macros screen # --
L["Macros"] = "宏"
-- "|4macro:macros;" is a special command to pluralise the word "macro" to "macros" when %d is greater than 1
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort发现了%d个|4宏:宏;需要管理。"
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort将动态更新包含"#FrameSort"头的宏中的变量。'
L["Below are some examples on how to use this."] = "以下是一些使用示例。"

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists] 庇护祝福]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] 驱散]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] 影遁;
/cast [@placeholder] 断脚；]]

-- %d is the number for example 1/2/3
L["Example %d"] = "示例 %d"
L["Supported variables:"] = "支持的变量："
L["The first DPS that's not you."] = "第一个不是你的DPS。"
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "添加一个数字以选择第N个目标，例如，DPS2选择第二个DPS。"
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "变量不区分大小写，所以'fRaMe1'，'Dps'，'enemyhealer'，等等，全部有效。"
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "需要在宏字符上进行节省吗？使用缩写来缩短它们："
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '使用 "X" 告诉FrameSort忽略一个@unit选择器：'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] 法术;]]

-- # Spacing screen #
L["Spacing"] = "间距"
L["Add some spacing between party/raid frames."] = "在队伍/团队框架之间添加一些间距。"
L["This only applies to Blizzard frames."] = "这仅适用于暴雪框架。"
L["Party"] = "队伍"
L["Raid"] = "团队"
L["Group"] = "组"
L["Horizontal"] = "水平"
L["Vertical"] = "垂直"

-- # Addons screen #
L["Addons"] = "插件"
L["Addons_Supported_Description"] = [[
FrameSort支持以下内容：
\n
暴雪
 - 队伍：是
 - 团队：是
 - 竞技场：损坏（最终会修复）。
\n
ElvUI
 - 队伍：是
 - 团队：否
 - 竞技场：否
\n
sArena
 - 竞技场：是
\n
Gladius
 - 竞技场：是
 - Bicmex版本：是
\n
GladiusEx
 - 队伍：是
 - 竞技场：是
\n
Cell
 - 队伍：是
 - 团队：是，仅在使用组合组时。
\n
Shadowed Unit Frames
 - 队伍：是
 - 竞技场：是
\n
Grid2
 - 队伍/团队：是
\n
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "想将FrameSort集成到你的插件、脚本和弱光环中吗？"
L["Here are some examples."] = "以下是一些示例。"
L["Retrieved an ordered array of party/raid unit tokens."] = "获取一个已排序的队伍/团队单位令牌数组。"
L["Retrieved an ordered array of arena unit tokens."] = "获取一个已排序的竞技场单位令牌数组。"
L["Register a callback function to run after FrameSort sorts frames."] = "注册一个回调函数，以在FrameSort排序框架后运行。"
L["Retrieve an ordered array of party frames."] = "获取一个已排序的队伍框架数组。"
L["Change a FrameSort setting."] = "更改FrameSort的设置。"
L["View a full listing of all API methods on GitHub."] = "在GitHub上查看所有API方法的完整列表。"

-- # Help screen #
L["Help"] = "帮助"
L["Discord"] = "Discord"
L["Need help with something?"] = "需要帮助吗？"
L["Talk directly with the developer on Discord."] = "在Discord上直接与开发人员交谈。"

-- # Health Check screen -- #
L["Health Check"] = "健康检查"
L["Try this"] = "尝试此项"
L["Any known issues with configuration or conflicting addons will be shown below."] = "任何已知的配置或冲突插件的问题将在下面显示。"
L["N/A"] = "不适用"
L["Passed!"] = "通过！"
L["Failed"] = "失败"
L["(unknown)"] = "(未知的)"
L["(user macro)"] = "(用户宏)"
L["Using grouped layout for Cell raid frames"] = "使用组合布局的Cell团队框架"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = "请检查Cell -> 布局中的'组合组（团队）'选项"
L["Can detect frames"] = "可以检测框架"
L["FrameSort currently supports frames from these addons: %s"] = "FrameSort当前支持来自这些插件的框架：%s"
L["Using Raid-Style Party Frames"] = "使用团队风格的队伍框架"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings"] = "请在暴雪设置中启用'使用团队风格的队伍框架'"
L["Keep Groups Together setting disabled"] = "保持组在一起设置已禁用"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = "通过编辑模式将团队显示模式更改为'组合组'选项之一"
L["Disable the 'Keep Groups Together' raid profile setting."] = "禁用'保持组在一起'团队配置设置。"
L["Only using Blizzard frames with Traditional mode"] = "仅使用传统模式的暴雪框架"
L["Traditional mode can't sort your other frame addons: '%s'"] = "传统模式无法对你的其他框架插件进行排序：'%s'"
L["Using Secure sorting mode when spacing is being used."] = "在使用间距时使用安全排序模式。"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] = "传统模式无法应用间距，考虑去除间距或使用安全排序方法"
L["Blizzard sorting functions not tampered with"] = "暴雪排序功能未被干扰"
L['"%s" may cause conflicts, consider disabling it'] = '"%s" 可能会导致冲突，请考虑禁用它'
L["No conflicting addons"] = "没有冲突插件"
L["Main tank and assist setting disabled"] = "主坦克和助理设置已禁用"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames"] = "请在选项 -> 界面 -> 团队框架中禁用'显示主坦克和助理'选项"
