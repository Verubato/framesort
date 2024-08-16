local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhCN" then
    return
end

L["FrameSort"] = "框架排序"

-- # 主选项界面 #
-- 用于 FrameSort - 1.2.3 版本标题，%s 是版本号
L["FrameSort - %s"] = "框架排序 - %s"
L["There are some issues that may prevent FrameSort from working correctly."] = "有一些问题可能会阻止 FrameSort 正常工作。"
L["Please go to the Health Check panel to view more details."] = "请前往健康检查面板以查看更多详情。"
L["Role"] = "角色"
L["Group"] = "小队"
L["Alpha"] = "透明度"
L["party1 > party2 > partyN > partyN+1"] = "队伍1 > 队伍2 > 队伍N > 队伍N+1"
L["tank > healer > dps"] = "坦克 > 治疗 > DPS"
L["NameA > NameB > NameZ"] = "名字A > 名字B > 名字Z"
L["healer > tank > dps"] = "治疗 > 坦克 > DPS"
L["healer > dps > tank"] = "治疗 > DPS > 坦克"
L["tank > healer > dps"] = "坦克 > 治疗 > DPS"
L["Arena - 2v2"] = "竞技场 - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
-- %s 是 "3v3" 或 "3v3 & 5v5"
L["Arena - %s"] = "竞技场 - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "敌方竞技场（请参阅插件面板中的支持插件）"
L["Dungeon (mythics, 5-mans)"] = "地下城（大秘境，5人本）"
L["Raid (battlegrounds, raids)"] = "团队（战场，团队副本）"
L["World (non-instance groups)"] = "世界（非副本队伍）"
L["Player:"] = "玩家："
L["Top"] = "顶部"
L["Middle"] = "中间"
L["Bottom"] = "底部"
L["Hidden"] = "隐藏"
L["Group"] = "小队"
L["Role"] = "角色"
L["Alpha"] = "透明度"
L["Reverse"] = "反转"

-- # 排序方式界面 #
L["Sorting Method"] = "排序方式"
L["Secure"] = "安全"
L["SortingMethod_Secure_Description"] = [[
调整每个单独框架的位置，不会导致UI错误/锁定/污染。
\n
优点：
 - 可以排序来自其他插件的框架。
 - 可以应用框架间距。
 - 无污染（技术术语，指插件不会干扰暴雪的UI代码）。
\n
缺点：
 - 为了规避暴雪的代码，可能会产生脆弱的解决方案。
 - 可能在魔兽更新时出错，并导致开发者发疯。
]]
L["Traditional"] = "传统"
L["SortingMethod_Secure_Traditional"] = [[
这是插件和宏使用超过10年的标准排序模式。
它替换了暴雪的内部排序方法，使用我们自己的排序方式。
与 FrameSort 配置一样，这与 'SetFlowSortFunction' 脚本相同。
\n
优点：
 - 更加稳定可靠，因为它利用了暴雪的内部排序方法。"
\n
缺点：
 - 仅能排序暴雪的小队框架，其他框架无效。
 - 会导致Lua错误，这是正常的，可以忽略。
 - 无法应用框架间距。
]]
L["Please reload after changing these settings."] = "更改这些设置后请重载界面。"
L["Reload"] = "重载"

-- # 角色排序界面 #
L["Role Ordering"] = "角色排序"
L["Specify the ordering you wish to use when sorting by role."] = "指定按角色排序时要使用的排序顺序。"
L["Tank > Healer > DPS"] = "坦克 > 治疗 > DPS"
L["Healer > Tank > DPS"] = "治疗 > 坦克 > DPS"
L["Healer > DPS > Tank"] = "治疗 > DPS > 坦克"

-- # 自动队长界面 #
L["Auto Leader"] = "自动队长"
L["Auto promote healers to leader in solo shuffle."] = "在单排混战中自动提升治疗为队长。"
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "为什么？这样治疗可以配置目标标记图标并重新排列小队1/2。"
L["Enabled"] = "已启用"

-- # 暴雪按键绑定界面（FrameSort部分） #
L["Targeting"] = "目标选择"
L["Target frame 1 (top frame)"] = "目标框架1（顶部框架）"
L["Target frame 2"] = "目标框架2"
L["Target frame 3"] = "目标框架3"
L["Target frame 4"] = "目标框架4"
L["Target frame 5"] = "目标框架5"
L["Target bottom frame"] = "目标底部框架"
L["Target frame 1's pet"] = "目标框架1的宠物"
L["Target frame 2's pet"] = "目标框架2的宠物"
L["Target frame 3's pet"] = "目标框架3的宠物"
L["Target frame 4's pet"] = "目标框架4的宠物"
L["Target frame 5's pet"] = "目标框架5的宠物"
L["Target enemy frame 1"] = "目标敌方框架1"
L["Target enemy frame 2"] = "目标敌方框架2"
L["Target enemy frame 3"] = "目标敌方框架3"
L["Target enemy frame 1's pet"] = "目标敌方框架1的宠物"
L["Target enemy frame 2's pet"] = "目标敌方框架2的宠物"
L["Target enemy frame 3's pet"] = "目标敌方框架3的宠物"
L["Focus enemy frame 1"] = "焦点敌方框架1"
L["Focus enemy frame 2"] = "焦点敌方框架2"
L["Focus enemy frame 3"] = "焦点敌方框架3"
L["Cycle to the next frame"] = "切换到下一个框架"
L["Cycle to the previous frame"] = "切换到上一个框架"
L["Target the next frame"] = "选择下一个框架"
L["Target the previous frame"] = "选择上一个框架"

-- # 按键绑定界面 #
L["Keybindings"] = "按键绑定"
L["Keybindings_Description"] = [[
你可以在魔兽世界的标准按键绑定区域找到 FrameSort 的按键绑定。
\n
按键绑定有什么用？
它们可以通过其视觉排列顺序而不是队伍位置（party1/2/3等）来选择玩家。
\n
例如，想象一个按角色排序的5人地下城队伍，如下所示：
  - 坦克，队伍3
  - 治疗，玩家
  - DPS，队伍1
  - DPS，队伍4
  - DPS，队伍2
\n
如你所见，他们的视觉排列与他们的实际队伍位置不同，这使得目标选择变得混乱。
如果你使用 /target party1，它将选择位置3的DPS玩家，而不是坦克。
\n
FrameSort 按键绑定将根据他们的视觉框架位置来选择目标，而不是队伍编号。
因此，选择“框架1”将选择坦克，“框架2”将选择治疗，“框架3”将选择位置3的DPS，以此类推。
]]

-- # 宏界面 # --
L["Macros"] = "宏"
-- "|4macro:macros;" 是一个特殊命令，当 %d 大于1时，将单词 "macro" 变为复数 "macros"
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort 发现了 %d 个|4宏:宏; 需要管理。"
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort 会动态更新包含 "#FrameSort" 标头的宏中的变量。'
L["Below are some examples on how to use this."] = "以下是一些使用示例。"

L["Macro_Example1"] = [[#showtooltip
#FrameSort 鼠标悬停, 目标, 治疗
/cast [@mouseover,help][@target,help][@healer,exists] 庇护祝福]]

L["Macro_Example2"] = [[#showtooltip
#Frame

Sort 框架1, 框架2, 玩家
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] 驱散]]

L["Macro_Example3"] = [[#FrameSort 敌方治疗, 敌方治疗
/cast [@doesntmatter] 暗影步;
/cast [@placeholder] 脚踢;]]

-- %d 是 示例1/2/3 的编号
L["Example %d"] = "示例 %d"
L["Supported variables:"] = "支持的变量："
L["The first DPS that's not you."] = "第一个不是你的DPS。"
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "添加一个数字来选择第N个目标，例如，DPS2 选择第2个DPS。"
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "变量不区分大小写，因此 'fRaMe1'，'Dps'，'enemyhealer' 等都可以使用。"
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "需要节省宏字符？使用缩写来缩短它们："
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '使用 "X" 告诉 FrameSort 忽略 @单位 选择器：'
L["Skip_Example"] = [[
#FS X X 敌方治疗
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] 法术;]]

-- # 间距界面 #
L["Spacing"] = "间距"
L["Add some spacing between party/raid frames."] = "在小队/团队框架之间添加一些间距。"
L["This only applies to Blizzard frames."] = "此选项仅适用于暴雪框架。"
L["Party"] = "小队"
L["Raid"] = "团队"
L["Group"] = "小队"
L["Horizontal"] = "水平"
L["Vertical"] = "垂直"

-- # 插件界面 #
L["Addons"] = "插件"
L["Addons_Supported_Description"] = [[
FrameSort 支持以下插件：
\n
暴雪
 - 小队：是
 - 团队：是
 - 竞技场：损坏（会尽快修复）。
\n
ElvUI
 - 小队：是
 - 团队：否
 - 竞技场：否
\n
sArena
 - 竞技场：是
\n
Gladius
 - 竞技场：是
 - Bicmex 版本：是
\n
GladiusEx
 - 小队：是
 - 竞技场：是
\n
Cell
 - 小队：是
 - 团队：是，仅当使用组合组时。
]]

-- # API界面 #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "想将 FrameSort 集成到您的插件、脚本和 Weak Auras 中吗？"
L["Here are some examples."] = "以下是一些示例。"
L["Retrieved an ordered array of party/raid unit tokens."] = "检索到有序的小队/团队单位标记数组。"
L["Retrieved an ordered array of arena unit tokens."] = "检索到有序的竞技场单位标记数组。"
L["Register a callback function to run after FrameSort sorts frames."] = "注册一个回调函数，以在 FrameSort 排序框架后运行。"
L["Retrieve an ordered array of party frames."] = "检索到有序的小队框架数组。"
L["Change a FrameSort setting."] = "更改 FrameSort 设置。"
L["View a full listing of all API methods on GitHub."] = "在 GitHub 上查看所有 API 方法的完整列表。"

-- # 帮助界面 #
L["Help"] = "帮助"
L["Discord"] = "Discord"
L["Need help with something?"] = "需要帮助吗？"
L["Talk directly with the developer on Discord."] = "在 Discord 上直接与开发人员交谈。"

-- # 健康检查界面 -- #
L["Health Check"] = "健康检查"
L["Try this"] = "尝试这个"
L["Any known issues with configuration or conflicting addons will be shown below."] = "任何已知的配置问题或冲突的插件都会显示在下方。"
L["N/A"] = "不适用"
L["Passed!"] = "通过！"
L["Failed"] = "失败"
L["(unknown)"] = "(未知)"
L["(user macro)"] = "(用户宏)"
L["Using grouped layout for Cell raid frames"] = "使用 Cell 团队框架的组合布局"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "请检查 Cell -> 布局中的“组合组（团队）”选项。"
L["Can detect frames"] = "可以检测到框架"
L["FrameSort currently supports frames from these addons: %s."] = "FrameSort 当前支持来自这些插件的框架：%s。"
L["Using Raid-Style Party Frames"] = "使用团队风格的小队框架"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "请在暴雪设置中启用“使用团队风格的小队框架”。"
L["Keep Groups Together setting disabled"] = "“保持队伍在一起”设置已禁用"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "通过编辑模式将团队显示模式更改为“组合组”选项之一。"
L["Disable the 'Keep Groups Together' raid profile setting."] = "禁用“保持队伍在一起”的团队配置文件设置。"
L["Only using Blizzard frames with Traditional mode"] = "仅在传统模式下使用暴雪框架"
L["Traditional mode can't sort your other frame addons: '%s'"] = "传统模式无法排序您的其他框架插件：'%s'"
L["Using Secure sorting mode when spacing is being used."] = "使用间距时使用安全排序模式。"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "传统模式无法应用间距，请考虑移除间距或使用安全排序方式。"
L["Blizzard sorting functions not tampered with"] = "暴雪的排序功能未被篡改"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" 可能会引起冲突，建议禁用它。'
L["No conflicting addons"] = "没有冲突的插件"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" 可能会引起冲突，建议禁用它。'
L["Main tank and assist setting disabled"] = "主坦克和助攻设置已禁用"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "请禁用 选项 -> 界面 -> 团队框架中的“显示主坦克和助攻”选项。"
