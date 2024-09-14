local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhCN" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = nil
L["There are some issuse that may prevent FrameSort from working correctly."] = "存在一些问题可能会导致框架排序无法正常工作。"
L["Please go to the Health Check panel to view more details."] = "请前往健康检查面板以查看更多详情。"
L["Role"] = "角色"
L["Group"] = "小组"
L["Alphabetical"] = "字母顺序"
L["Arena - 2v2"] = "竞技场 - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
L["Arena - %s"] = "竞技场 - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "敌方竞技场（请参阅插件面板以查看支持的插件）"
L["Dungeon (mythics, 5-mans)"] = "地下城（神器，5人）"
L["Raid (battlegrounds, raids)"] = "团队（战场，副本）"
L["World (non-instance groups)"] = "世界（非副本小组）"
L["Player"] = "玩家"
L["Sort"] = "排序"
L["Top"] = "顶部"
L["Middle"] = "中间"
L["Bottom"] = "底部"
L["Hidden"] = "隐藏"
L["Group"] = "小组"
L["Role"] = "角色"
L["Reverse"] = "反向"

-- # Sorting Method screen #
L["Sorting Method"] = "排序方式"
L["Secure"] = "安全"
L["SortingMethod_Secure_Description"] = [[
调整每个单独框架的位置，不会导致UI出错/锁定/污染。
\n
优点：
 - 可以排序其他插件的框架。
 - 可以应用框架间距。
 - 无污染（技术术语，指插件干扰暴雪的UI代码）。
\n
缺点：
 - 承受暴雪意大利面条代码的脆弱平衡。
 - 可能会随着魔兽世界的补丁而破坏，导致开发者疯掉。
]]
L["Traditional"] = "传统"
L["SortingMethod_Secure_Traditional"] = [[
这是插件和宏使用了10年以上的标准排序模式。
它用我们自己的排序方法替代了暴雪的内部排序方法。
这是与'设定流程排序功能'脚本相同，但具有框架排序的配置。
\n
优点：
 - 更稳定/可靠，因为它利用了暴雪的内部排序方法。
\n
缺点：
 - 仅能排序暴雪的队伍框架，其他无能为力。
 - 会导致Lua错误，这很正常，可以忽略。
 - 不能应用框架间距。
]]
L["Please reload after changing these settings."] = "更改这些设置后请重新加载。"
L["Reload"] = "重新加载"

-- # Ordering screen #
L["Role"] = "角色"
L["Specify the ordering you wish to use when sorting by role."] = "指定按角色排序时希望使用的顺序。"
L["Tanks"] = "坦克"
L["Healers"] = "治疗"
L["Casters"] = "施法者"
L["Hunters"] = "猎人"
L["Melee"] = "近战"

-- # Auto Leader screen #
L["Auto Leader"] = "自动队长"
L["Auto promote healers to leader in solo shuffle."] = "在单人洗牌中自动提升治疗者为队长。"
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "为什么？这样治疗者可以配置目标标记图标，并按他们的喜好重新排序队伍1/2。"
L["Enabled"] = "启用"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "目标"
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
L["Keybindings"] = "按键绑定"
L["Keybindings_Description"] = [[
您可以在标准魔兽世界按键绑定区域找到框架排序的按键绑定。
\n
按键绑定有什么用？
它们用于根据玩家的视觉有序表示而不是他们的队伍位置（队伍1/2/3等）来锁定目标。
\n
例如，想象一个按角色排序的5人地下城小组，看起来如下：
  - 坦克，队伍3
  - 治疗，玩家
  - DPS，队伍1
  - DPS，队伍4
  - DPS，队伍2
\n
正如您所看到的，他们的视觉表示与实际的队伍位置不同，这使得锁定目标变得混淆。
如果您想/锁定队伍1，它会锁定位置3的DPS而不是坦克。
\n
框架排序的按键绑定将基于他们的视觉框架位置而不是队伍编号进行锁定。
因此，锁定'框架 1'将锁定坦克，'框架 2'为治疗，'框架 3'为位置3的DPS，依此类推。
]]

-- # Macros screen # --
L["Macros"] = "宏"
L["FrameSort has found %d|4macro:macros; to manage."] = "框架排序发现了%d个宏需要管理。"
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = '框架排序将动态更新包含"#FrameSort"头部的宏中的变量。'
L["Below are some examples on how to use this."] = "下面是一些如何使用此功能的示例。"

L["Macro_Example1"] = [[#showtooltip
#FrameSort 鼠标悬停，目标，治疗
/cast [@mouseover,help][@target,help][@healer,exists] 庇护祝福]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort 框架1，框架2，玩家
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] 驱散]]

L["Macro_Example3"] = [[#FrameSort 敌方治疗，敌方治疗
/cast [@doesntmatter] 影袭;
/cast [@placeholder] 拦截;]]

L["Example %d"] = "示例 %d"
L["Supported variables:"] = "支持的变量："
L["The first DPS that's not you."] = "第一个不是你的DPS。"
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "添加一个数字以选择第N个目标，例如，DPS2选择第2个DPS。"
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "变量不区分大小写，因此'fRaMe1'，'Dps'，'enemyhealer'等都有效。"
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "需要在宏字符上节省空间吗？使用缩写来缩短它们："
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '使用 "X" 告诉框架排序忽略一个@单位选择器：'
L["Skip_Example"] = [[
#FS X X 敌方治疗
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] 法术;]]

-- # Spacing screen #
L["Spacing"] = "间距"
L["Add some spacing between party/raid frames."] = "在小组/团队框架之间添加一些间距。"
L["This only applies to Blizzard frames."] = "这仅适用于暴雪框架。"
L["Party"] = "小组"
L["Raid"] = "团队"
L["Group"] = "小组"
L["Horizontal"] = "水平"
L["Vertical"] = "垂直"

-- # Addons screen #
L["Addons"] = "插件"
L["Addons_Supported_Description"] = [[
框架排序支持以下内容：
\n
暴雪
 - 小组：支持
 - 团队：支持
 - 竞技场：已损坏（最终会修复）
\n
ElvUI
 - 小组：支持
 - 团队：不支持
 - 竞技场：不支持
\n
sArena
 - 竞技场：支持
\n
Gladius
 - 竞技场：支持
 - Bicmex版本：支持
\n
GladiusEx
 - 小组：支持
 - 竞技场：支持
\n
Cell
 - 小组：支持
 - 团队：支持，仅在使用合并小组时
\n
Shadowed Unit Frames
 - 小组：支持
 - 竞技场：支持
\n
Grid2
 - 小组/团队：支持
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "想将框架排序集成到您的插件、脚本和弱光环中吗？"
L["Here are some examples."] = "这里是一些示例。"
L["Retrieved an ordered array of party/raid unit tokens."] = "检索到有序的队伍/团队单位标记数组。"
L["Retrieved an ordered array of arena unit tokens."] = "检索到有序的竞技场单位标记数组。"
L["Register a callback function to run after FrameSort sorts frames."] = "注册一个回调函数，在框架排序后执行。"
L["Retrieve an ordered array of party frames."] = "检索有序的队伍框架数组。"
L["Change a FrameSort setting."] = "更改一个框架排序设置。"
L["View a full listing of all API methods on GitHub."] = "在GitHub上查看所有API方法的完整列表。"

-- # Help screen #
L["Help"] = "帮助"
L["Discord"] = "Discord"
L["Need help with something?"] = "需要帮助吗？"
L["Talk directly with the developer on Discord."] = "直接与开发者在Discord上交谈。"

-- # Health Check screen -- #
L["Health Check"] = "健康检查"
L["Try this"] = "试试这个"
L["Any known issues with configuration or conflicting addons will be shown below."] = "任何已知的配置问题或冲突插件将显示在下面。"
L["N/A"] = "不适用"
L["Passed!"] = "通过！"
L["Failed"] = "失败"
L["(unknown)"] = "(未知)"
L["(user macro)"] = "(用户宏)"
L["Using grouped layout for Cell raid frames"] = "正在为Cell团队框架使用组合布局"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "请检查Cell -> 布局中的'组合小组（团队）'选项。"
L["Can detect frames"] = "可以检测框架"
L["FrameSort currently supports frames from these addons: %s."] = "框架排序当前支持来自这些插件的框架：%s。"
L["Using Raid-Style Party Frames"] = "使用团队风格的小组框架"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "请在暴雪设置中启用'使用团队风格的小组框架'。"
L["Keep Groups Together setting disabled"] = "禁用保持小组在一起设置"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "通过编辑模式更改团队显示模式为之一'组合小组'选项。"
L["Disable the 'Keep Groups Together' raid profile setting."] = "禁用'保持小组在一起'团队配置设置。"
L["Only using Blizzard frames with Traditional mode"] = "仅在传统模式下使用暴雪框架"
L["Traditional mode can't sort your other frame addons: '%s'"] = "传统模式无法对您的其他框架插件进行排序：'%s'"
L["Using Secure sorting mode when spacing is being used."] = "在使用间距时使用安全排序模式。"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "传统模式无法应用间距，考虑移除间距或使用安全排序方法。"
L["Blizzard sorting functions not tampered with"] = "未篡改暴雪排序功能"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s"可能会引起冲突，考虑禁用它。'
L["No conflicting addons"] = "没有冲突的插件"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s"可能会引起冲突，考虑禁用它。'
L["Main tank and assist setting disabled"] = "主坦克和助理设置已禁用"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "请在选项 -> 接口 -> 团队框架中禁用'显示主坦克和助理'选项。"
