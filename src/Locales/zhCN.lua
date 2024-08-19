local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhCN" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "有些问题可能会导致FrameSort无法正常工作。"
L["Please go to the Health Check panel to view more details."] = "请前往健康检查面板查看更多详情。"
L["Role"] = "角色"
L["Group"] = "组"
L["Alpha"] = "字母顺序"
L["party1 > party2 > partyN > partyN+1"] = "队伍1 > 队伍2 > 队伍N > 队伍N+1"
L["tank > healer > dps"] = "坦克 > 治疗 > 输出"
L["NameA > NameB > NameZ"] = "名字A > 名字B > 名字Z"
L["healer > tank > dps"] = "治疗 > 坦克 > 输出"
L["healer > dps > tank"] = "治疗 > 输出 > 坦克"
L["tank > healer > dps"] = "坦克 > 治疗 > 输出"
L["Arena - 2v2"] = "竞技场 - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 和 5v5"
L["Arena - %s"] = "竞技场 - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "敌方竞技场（请查看插件面板了解支持的插件）"
L["Dungeon (mythics, 5-mans)"] = "地下城（史诗，5人）"
L["Raid (battlegrounds, raids)"] = "团队（战场，团队）"
L["World (non-instance groups)"] = "世界（非副本队伍）"
L["Player"] = "玩家"
L["Sort"] = "排序"
L["Top"] = "顶部"
L["Middle"] = "中间"
L["Bottom"] = "底部"
L["Hidden"] = "隐藏"
L["Group"] = "组"
L["Role"] = "角色"
L["Alpha"] = "字母顺序"
L["Reverse"] = "反向"

-- # Sorting Method screen #
L["Sorting Method"] = "排序方法"
L["Secure"] = "安全"
L["SortingMethod_Secure_Description"] = [[
调整每个框架的位置，并且不会错误/锁定/污染UI。
\n
优点：
 - 可以排序来自其他插件的框架。
 - 可以应用框架间距。
 - 无污染（技术术语，指插件干扰暴雪的UI代码）。
\n
缺点：
 - 脆弱的卡片屋状况，以绕过暴雪的复杂代码。
 - 可能会随着魔兽世界补丁而中断，并让开发者陷入疯狂。
]]
L["Traditional"] = "传统"
L["SortingMethod_Secure_Traditional"] = [[
这是插件和宏使用了10年以上的标准排序模式。
它将暴雪的内部排序方法替换为我们的。
这与 'SetFlowSortFunction' 脚本相同，但带有FrameSort配置。
\n
优点：
 - 更加稳定/可靠，因为它利用了暴雪的内部排序方法。
\n
缺点：
 - 只排序暴雪的队伍框架，其他都不行。
 - 会导致Lua错误，这是正常的，可以忽略。
 - 不能应用框架间距。
]]
L["Please reload after changing these settings."] = "更改这些设置后请重新加载界面。"
L["Reload"] = "重新加载"

-- # Role Ordering screen #
L["Role Ordering"] = "角色排序"
L["Specify the ordering you wish to use when sorting by role."] = "指定您希望按角色排序时使用的顺序。"
L["Tank > Healer > DPS"] = "坦克 > 治疗 > 输出"
L["Healer > Tank > DPS"] = "治疗 > 坦克 > 输出"
L["Healer > DPS > Tank"] = "治疗 > 输出 > 坦克"

-- # Auto Leader screen #
L["Auto Leader"] = "自动队长"
L["Auto promote healers to leader in solo shuffle."] = "在单人洗牌中自动提升治疗为队长。"
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "为什么？这样治疗可以配置目标标记图标，并根据他们的偏好重新排序队伍1/2。"
L["Enabled"] = "启用"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "目标"
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
L["Target the next frame"] = "目标下一个框架"
L["Target the previous frame"] = "目标上一个框架"

-- # Keybindings screen #
L["Keybindings"] = "按键绑定"
L["Keybindings_Description"] = [[
您可以在标准的WoW按键绑定区域中找到FrameSort的按键绑定。
\n
这些按键绑定有什么用？
它们有助于根据玩家的视觉顺序而不是队伍位置（队伍1/2/3等）来选择目标。
\n
例如，想象一个按角色排序的5人地下城队伍如下：
  - 坦克，队伍3
  - 治疗，玩家
  - 输出，队伍1
  - 输出，队伍4
  - 输出，队伍2
\n
正如您所看到的，他们的视觉表示与实际的队伍位置不同，这使得选择目标变得混乱。
如果您使用 /目标 队伍1，它会将目标锁定为位置3的DPS玩家，而不是坦克。
\n
FrameSort按键绑定将根据他们在框架中的视觉位置而不是队伍编号来选择目标。
因此，选择“框架1”将锁定坦克，“框架2”将锁定治疗，“框架3”将锁定位置3的输出，依此类推。
]]

-- # Macros screen # --
L["Macros"] = "宏"
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort找到了%d|4个宏:多个宏;来管理。"
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort会动态更新包含"#FrameSort"标头的宏中的变量。'
L["Below are some examples on how to use this."] = "以下是一些使用示例。"

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@治疗,exists] 庇护祝福]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@框架1][mod:shift,@框架2][mod:alt,@玩家][] 驱散]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@不重要] 暗影步;
/cast [@占位符] 脚踢;]]

L["Example %d"] = "示例 %d"
L["Supported variables:"] = "支持的变量："
L["The first DPS that's not you."] = "第一个不是你的DPS。"
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "添加一个数字来选择第N个目标，例如，DPS2选择第二个DPS。"
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "变量不区分大小写，因此“fRaMe1”、“Dps”、“enemyhealer”等都可以使用。"
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "需要节省宏字符？使用缩写来缩短它们："
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '使用"X"告诉FrameSort忽略@unit选择器：'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@敌治疗,exists][] 法术;]]

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
 - 竞技场：已损坏（最终会修复）。
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
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "想将FrameSort集成到您的插件、脚本和Weak Auras中吗？"
L["Here are some examples."] = "以下是一些示例。"
L["Retrieved an ordered array of party/raid unit tokens."] = "检索了有序的队伍/团队单位标记数组。"
L["Retrieved an ordered array of arena unit tokens."] = "检索了有序的竞技场单位标记数组。"
L["Register a callback function to run after FrameSort sorts frames."] = "注册一个回调函数，在FrameSort排序框架后运行。"
L["Retrieve an ordered array of party frames."] = "检索有序的队伍框架数组。"
L["Change a FrameSort setting."] = "更改FrameSort设置。"
L["View a full listing of all API methods on GitHub."] = "在GitHub上查看所有API方法的完整列表。"

-- # Help screen #
L["Help"] = "帮助"
L["Discord"] = "Discord"
L["Need help with something?"] = "需要帮助吗？"
L["Talk directly with the developer on Discord."] = "在Discord上直接与开发者交流。"

-- # Health Check screen -- #
L["Health Check"] = "健康检查"
L["Try this"] = "尝试此操作"
L["Any known issues with configuration or conflicting addons will be shown below."] = "配置或冲突插件的任何已知问题将在下方显示。"
L["N/A"] = "不适用"
L["Passed!"] = "通过！"
L["Failed"] = "失败"
L["(unknown)"] = "（未知）"
L["(user macro)"] = "（用户宏）"
L["Using grouped layout for Cell raid frames"] = "使用Cell团队框架的分组布局"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "请在Cell -> 布局中检查“组合组（团队）”选项。"
L["Can detect frames"] = "可以检测到框架"
L["FrameSort currently supports frames from these addons: %s."] = "FrameSort当前支持这些插件的框架：%s。"
L["Using Raid-Style Party Frames"] = "使用团队风格的队伍框架"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "请在暴雪设置中启用“使用团队风格的队伍框架”。"
L["Keep Groups Together setting disabled"] = "禁用“保持组一起”设置"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "通过编辑模式将团队显示模式更改为“组合组”选项之一。"
L["Disable the 'Keep Groups Together' raid profile setting."] = "禁用“保持组一起”团队配置文件设置。"
L["Only using Blizzard frames with Traditional mode"] = "仅在传统模式下使用暴雪框架"
L["Traditional mode can't sort your other frame addons: '%s'"] = "传统模式无法排序您的其他框架插件：“%s”"
L["Using Secure sorting mode when spacing is being used."] = "使用间距时使用安全排序模式。"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "传统模式无法应用间距，请考虑删除间距或使用安全排序方法。"
L["Blizzard sorting functions not tampered with"] = "暴雪的排序功能未被篡改"
L['"%s" may cause conflicts, consider disabling it.'] = '“%s”可能会导致冲突，请考虑禁用它。'
L["No conflicting addons"] = "没有冲突的插件"
L['"%s" may cause conflicts, consider disabling it.'] = '“%s”可能会导致冲突，请考虑禁用它。'
L["Main tank and assist setting disabled"] = "主坦克和协助设置已禁用"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "请在选项 -> 界面 -> 团队框架中禁用“显示主坦克和协助”选项。"

