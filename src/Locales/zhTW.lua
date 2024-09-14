local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhTW" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = nil
L["There are some issuse that may prevent FrameSort from working correctly."] = "有一些問題可能會阻止框架排序正常工作。"
L["Please go to the Health Check panel to view more details."] = "請前往健康檢查面板以查看更多細節。"
L["Role"] = "角色"
L["Group"] = "隊伍"
L["Alphabetical"] = "按字母順序"
L["Arena - 2v2"] = "競技場 - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
-- %s is either "3v3" or "3v3 & 5v5"
L["Arena - %s"] = "競技場 - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "敵方競技場（請見插件面板以了解支持的插件）"
L["Dungeon (mythics, 5-mans)"] = "地城（傳奇，5人）"
L["Raid (battlegrounds, raids)"] = "團隊（戰場，副本）"
L["World (non-instance groups)"] = "世界（非副本小隊）"
L["Player"] = "玩家"
L["Sort"] = "排序"
L["Top"] = "上"
L["Middle"] = "中"
L["Bottom"] = "下"
L["Hidden"] = "隱藏"
L["Group"] = "隊伍"
L["Role"] = "角色"
L["Reverse"] = "反向"

-- # Sorting Method screen #
L["Sorting Method"] = "排序方式"
L["Secure"] = "安全"
L["SortingMethod_Secure_Description"] = [[
調整每個單獨框架的位置，不會影響/鎖定/污染 UI。
\n
優點：
 - 可以排序來自其他插件的框架。
 - 可以應用框架間距。
 - 無污染（插件干擾暴雪 UI 代碼的技術術語）。
\n
缺點：
 - 脆弱的紙牌屋情況來解決暴雪的雜湊問題。
 - 可能會在 WoW 修補程序更新後壞掉，導致開發者發瘋。
]]
L["Traditional"] = "傳統"
L["SortingMethod_Secure_Traditional"] = [[
這是插件和宏使用了 10 多年的標準排序模式。
它用我們自己的排序方法替代了內部的暴雪排序方法。
這與 'SetFlowSortFunction' 腳本相同，但使用框架排序配置。
\n
優點：
 - 更穩定/可靠，因為它利用了暴雪的內部排序方法。
\n
缺點：
 - 只能排序暴雪的隊伍框架，沒有其他。
 - 將引起 Lua 錯誤，這是正常的，可以忽略。
 - 無法應用框架間距。
]]
L["Please reload after changing these settings."] = "更改這些設置後請重新加載。"
L["Reload"] = "重新加載"

-- # Ordering screen #
L["Role"] = "角色"
L["Specify the ordering you wish to use when sorting by role."] = "指定排序時希望使用的順序。"
L["Tanks"] = "坦克"
L["Healers"] = "治療者"
L["Casters"] = "施法者"
L["Hunters"] = "獵人"
L["Melee"] = "近戰"

-- # Auto Leader screen #
L["Auto Leader"] = "自動領導"
L["Auto promote healers to leader in solo shuffle."] = "在單人隨機中自動提升治療者為領導。"
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "為什麼？這樣治療者可以配置目標標記圖標並按照他們的喜好重新排列隊伍1/2。"
L["Enabled"] = "啟用"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "目標指定"
L["Target frame 1 (top frame)"] = "目標框架 1（頂部框架）"
L["Target frame 2"] = "目標框架 2"
L["Target frame 3"] = "目標框架 3"
L["Target frame 4"] = "目標框架 4"
L["Target frame 5"] = "目標框架 5"
L["Target bottom frame"] = "目標底部框架"
L["Target frame 1's pet"] = "目標框架 1 的寵物"
L["Target frame 2's pet"] = "目標框架 2 的寵物"
L["Target frame 3's pet"] = "目標框架 3 的寵物"
L["Target frame 4's pet"] = "目標框架 4 的寵物"
L["Target frame 5's pet"] = "目標框架 5 的寵物"
L["Target enemy frame 1"] = "目標敵方框架 1"
L["Target enemy frame 2"] = "目標敵方框架 2"
L["Target enemy frame 3"] = "目標敵方框架 3"
L["Target enemy frame 1's pet"] = "目標敵方框架 1 的寵物"
L["Target enemy frame 2's pet"] = "目標敵方框架 2 的寵物"
L["Target enemy frame 3's pet"] = "目標敵方框架 3 的寵物"
L["Focus enemy frame 1"] = "聚焦敵方框架 1"
L["Focus enemy frame 2"] = "聚焦敵方框架 2"
L["Focus enemy frame 3"] = "聚焦敵方框架 3"
L["Cycle to the next frame"] = "循環到下一個框架"
L["Cycle to the previous frame"] = "循環到上一個框架"
L["Target the next frame"] = "目標下一個框架"
L["Target the previous frame"] = "目標上一個框架"

-- # Keybindings screen #
L["Keybindings"] = "快捷鍵綁定"
L["Keybindings_Description"] = [[
您可以在標準 WoW 快捷鍵綁定區域找到框架排序的快捷鍵。
\n
這些快捷鍵有什麼用？
它們方便根據玩家的可視排序表示而不是其隊伍位置（隊伍 1/2/3/等）進行目標選擇。
\n
例如，想像一個按角色排序的 5 人地城小隊，看起來是這樣的：
  - 坦克，隊伍 3
  - 治療者，玩家
  - DPS，隊伍 1
  - DPS，隊伍 4
  - DPS，隊伍 2
\n
正如你所見，他們的可視表示與實際隊伍位置不同，這使得目標選擇變得困惑。
如果你輸入 /target隊伍1，它會目標位置為 3 的 DPS 玩家而不是坦克。
\n
框架排序的快捷鍵將根據其可視的框架位置而不是隊伍號碼進行目標選擇。
因此目標'框架 1'將目標坦克，'框架 2'治療者，'框架 3'位置 3 的 DPS，等等。
]]

-- # Macros screen # --
L["Macros"] = "宏"
-- "|4macro:macros;" is a special command to pluralise the word "macro" to "macros" when %d is greater than 1
L["FrameSort has found %d|4macro:macros; to manage."] = "框架排序已找到 %d|4macro:macros; 進行管理。"
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "框架排序將動態更新包含 '#FrameSort' 標頭的宏中的變數。"
L["Below are some examples on how to use this."] = "以下是如何使用這個功能的一些範例。"

L["Macro_Example1"] = [[#showtooltip
#FrameSort 滑鼠懸停，目標，治療者
/cast [@mouseover,help][@target,help][@healer,exists] 庇護祝福]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort 框架1，框架2，玩家
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] 驅散]]

L["Macro_Example3"] = [[#FrameSort 敌方治疗者，敌方治疗者
/cast [@doesntmatter] 影子步;
/cast [@placeholder] 踢;]]

-- %d is the number for example 1/2/3
L["Example %d"] = "範例 %d"
L["Supported variables:"] = "支持的變數："
L["The first DPS that's not you."] = "第一個不是你的 DPS。"
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "添加編號以選擇第 N 個目標，例如，DPS2 選擇第二個 DPS。"
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "變數不區分大小寫，因此 'fRaMe1'、'Dps'、'enemyhealer' 等都可以使用。"
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "需要在宏字符上節省空間嗎？使用縮寫來縮短它們："
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '使用 "X" 告訴框架排序忽略 @unit 選擇器：'
L["Skip_Example"] = [[
#FS X X 敌方治疗者
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] 法術;]]

-- # Spacing screen #
L["Spacing"] = "間距"
L["Add some spacing between party/raid frames."] = "在隊伍/團隊框架之間添加一些間距。"
L["This only applies to Blizzard frames."] = "這僅適用於暴雪框架。"
L["Party"] = "隊伍"
L["Raid"] = "團隊"
L["Group"] = "隊伍"
L["Horizontal"] = "水平"
L["Vertical"] = "垂直"

-- # Addons screen #
L["Addons"] = "插件"
L["Addons_Supported_Description"] = [[
框架排序支持以下內容：
\n
暴雪
 - 隊伍：是
 - 團隊：是
 - 競技場：損壞（會最終修復）。
\n
ElvUI
 - 隊伍：是
 - 團隊：否
 - 競技場：否
\n
sArena
 - 競技場：是
\n
Gladius
 - 競技場：是
 - Bicmex 版本：是
\n
GladiusEx
 - 隊伍：是
 - 競技場：是
\n
Cell
 - 隊伍：是
 - 團隊：是，僅在使用聯合小組時。
\n
Shadowed Unit Frames
 - 隊伍：是
 - 競技場：是
\n
Grid2
 - 隊伍/團隊：是
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "想將框架排序整合到你的插件、腳本和弱光環中嗎？"
L["Here are some examples."] = "這裡有一些範例。"
L["Retrieved an ordered array of party/raid unit tokens."] = "檢索到已排序的隊伍/團隊單位標記數組。"
L["Retrieved an ordered array of arena unit tokens."] = "檢索到已排序的競技場單位標記數組。"
L["Register a callback function to run after FrameSort sorts frames."] = "註冊一個回調函數以在框架排序後執行。"
L["Retrieve an ordered array of party frames."] = "檢索已排序的隊伍框架數組。"
L["Change a FrameSort setting."] = "更改框架排序設置。"
L["View a full listing of all API methods on GitHub."] = "在 GitHub 上查看所有 API 方法的完整列表。"

-- # Help screen #
L["Help"] = "幫助"
L["Discord"] = "Discord"
L["Need help with something?"] = "需要幫助嗎？"
L["Talk directly with the developer on Discord."] = "在 Discord 上直接與開發者聯繫。"

-- # Health Check screen -- #
L["Health Check"] = "健康檢查"
L["Try this"] = "嘗試這個"
L["Any known issues with configuration or conflicting addons will be shown below."] = "下面將顯示任何配置或衝突插件的已知問題。"
L["N/A"] = "不適用"
L["Passed!"] = "通過！"
L["Failed"] = "失敗"
L["(unknown)"] = "(未知)"
L["(user macro)"] = "(用戶宏)"
L["Using grouped layout for Cell raid frames"] = "使用 Cell 團隊框架的分組佈局"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "請檢查 Cell -> 佈局中的 '綜合小組（團隊）' 選項。"
L["Can detect frames"] = "可以檢測框架"
L["FrameSort currently supports frames from these addons: %s."] = "框架排序目前支持來自這些插件的框架：%s。"
L["Using Raid-Style Party Frames"] = "使用團隊風格的隊伍框架"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "請在暴雪設置中啟用 '使用團隊風格隊伍框架'。"
L["Keep Groups Together setting disabled"] = "保持小組在一起的設置已禁用"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "通過編輯模式將團隊顯示模式更改為 '綜合小組' 選項之一。"
L["Disable the 'Keep Groups Together' raid profile setting."] = "禁用 '保持小組在一起' 的團隊配置設定。"
L["Only using Blizzard frames with Traditional mode"] = "僅在傳統模式下使用暴雪框架"
L["Traditional mode can't sort your other frame addons: '%s'"] = "傳統模式無法排序您的其他框架插件：'%s'"
L["Using Secure sorting mode when spacing is being used."] = "在使用間距時使用安全排序模式。"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "傳統模式無法應用間距，考慮移除間距或使用安全排序方法。"
L["Blizzard sorting functions not tampered with"] = "未篡改的暴雪排序函數"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" 可能會造成衝突，考慮禁用它。'
L["No conflicting addons"] = "無衝突插件"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" 可能會造成衝突，考慮禁用它。'
L["Main tank and assist setting disabled"] = "主坦和助手設定已禁用"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "請在選項 -> 介面 -> 團隊框架中禁用 '顯示主坦和助手' 選項。"
