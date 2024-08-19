local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhTW" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "有些問題可能會導致FrameSort無法正常運作。"
L["Please go to the Health Check panel to view more details."] = "請前往健康檢查面板查看更多詳情。"
L["Role"] = "角色"
L["Group"] = "隊伍"
L["Alpha"] = "字母排序"
L["party1 > party2 > partyN > partyN+1"] = "隊伍1 > 隊伍2 > 隊伍N > 隊伍N+1"
L["tank > healer > dps"] = "坦克 > 治療 > 輸出"
L["NameA > NameB > NameZ"] = "名稱A > 名稱B > 名稱Z"
L["healer > tank > dps"] = "治療 > 坦克 > 輸出"
L["healer > dps > tank"] = "治療 > 輸出 > 坦克"
L["tank > healer > dps"] = "坦克 > 治療 > 輸出"
L["Arena - 2v2"] = "競技場 - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 和 5v5"
L["Arena - %s"] = "競技場 - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "敵方競技場（請查看插件面板了解支持的插件）"
L["Dungeon (mythics, 5-mans)"] = "地城（傳奇，5人）"
L["Raid (battlegrounds, raids)"] = "團隊（戰場，團隊）"
L["World (non-instance groups)"] = "世界（非副本隊伍）"
L["Player"] = "玩家"
L["Sort"] = "排序"
L["Top"] = "頂部"
L["Middle"] = "中間"
L["Bottom"] = "底部"
L["Hidden"] = "隱藏"
L["Group"] = "隊伍"
L["Role"] = "角色"
L["Alpha"] = "字母排序"
L["Reverse"] = "反向"

-- # Sorting Method screen #
L["Sorting Method"] = "排序方法"
L["Secure"] = "安全"
L["SortingMethod_Secure_Description"] = [[
調整每個框架的位置，且不會錯誤/鎖定/污染UI。
\n
優點：
 - 可以排序來自其他插件的框架。
 - 可以應用框架間距。
 - 無污染（技術術語，指插件干擾暴雪的UI代碼）。
\n
缺點：
 - 脆弱的紙牌屋狀況，以繞過暴雪的複雜代碼。
 - 可能會隨著魔獸世界更新而中斷，並讓開發者陷入瘋狂。
]]
L["Traditional"] = "傳統"
L["SortingMethod_Secure_Traditional"] = [[
這是插件和巨集使用了10年以上的標準排序模式。
它將暴雪的內部排序方法替換為我們的。
這與 'SetFlowSortFunction' 腳本相同，但帶有FrameSort配置。
\n
優點：
 - 更加穩定/可靠，因為它利用了暴雪的內部排序方法。
\n
缺點：
 - 只排序暴雪的隊伍框架，其他都不行。
 - 會導致Lua錯誤，這是正常的，可以忽略。
 - 不能應用框架間距。
]]
L["Please reload after changing these settings."] = "更改這些設定後請重新加載界面。"
L["Reload"] = "重新加載"

-- # Role Ordering screen #
L["Role Ordering"] = "角色排序"
L["Specify the ordering you wish to use when sorting by role."] = "指定您希望按角色排序時使用的順序。"
L["Tank > Healer > DPS"] = "坦克 > 治療 > 輸出"
L["Healer > Tank > DPS"] = "治療 > 坦克 > 輸出"
L["Healer > DPS > Tank"] = "治療 > 輸出 > 坦克"

-- # Auto Leader screen #
L["Auto Leader"] = "自動隊長"
L["Auto promote healers to leader in solo shuffle."] = "在單人洗牌中自動提升治療為隊長。"
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "為什麼？這樣治療可以配置目標標記圖示，並根據他們的偏好重新排序隊伍1/2。"
L["Enabled"] = "啟用"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "目標"
L["Target frame 1 (top frame)"] = "目標框架1（頂部框架）"
L["Target frame 2"] = "目標框架2"
L["Target frame 3"] = "目標框架3"
L["Target frame 4"] = "目標框架4"
L["Target frame 5"] = "目標框架5"
L["Target bottom frame"] = "目標底部框架"
L["Target frame 1's pet"] = "目標框架1的寵物"
L["Target frame 2's pet"] = "目標框架2的寵物"
L["Target frame 3's pet"] = "目標框架3的寵物"
L["Target frame 4's pet"] = "目標框架4的寵物"
L["Target frame 5's pet"] = "目標框架5的寵物"
L["Target enemy frame 1"] = "目標敵方框架1"
L["Target enemy frame 2"] = "目標敵方框架2"
L["Target enemy frame 3"] = "目標敵方框架3"
L["Target enemy frame 1's pet"] = "目標敵方框架1的寵物"
L["Target enemy frame 2's pet"] = "目標敵方框架2的寵物"
L["Target enemy frame 3's pet"] = "目標敵方框架3的寵物"
L["Focus enemy frame 1"] = "焦點敵方框架1"
L["Focus enemy frame 2"] = "焦點敵方框架2"
L["Focus enemy frame 3"] = "焦點敵方框架3"
L["Cycle to the next frame"] = "切換到下一個框架"
L["Cycle to the previous frame"] = "切換到上一個框架"
L["Target the next frame"] = "目標下一個框架"
L["Target the previous frame"] = "目標上一個框架"

-- # Keybindings screen #
L["Keybindings"] = "按鍵綁定"
L["Keybindings_Description"] = [[
您可以在標準的WoW按鍵綁定區域中找到FrameSort的按鍵綁定。
\n
這些按鍵綁定有什麼用？
它們有助於根據玩家的視覺順序而不是隊伍位置（隊伍1/2/3等）來選擇目標。
\n
例如，想像一個按角色排序的5人地城隊伍如下：
  - 坦克，隊伍3
  - 治療，玩家
  - 輸出，隊伍1
  - 輸出，隊伍4
  - 輸出，隊伍2
\n
正如您所看到的，他們的視覺表示與實際的隊伍位置不同，這使得選擇目標變得混亂。
如果您使用 /目標 隊伍1，它會將目標鎖定為位置3的DPS玩家，而不是坦克。
\n
FrameSort按鍵綁定將根據他們在框架中的視覺位置而不是隊伍編號來選擇目標。
因此，選擇“框架1”將鎖定坦克，“框架2”將鎖定治療，“框架3”將鎖定位置3的輸出，依此類推。
]]

-- # Macros screen # --
L["Macros"] = "巨集"
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort找到了%d|4個巨集:多個巨集;來管理。"
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort會動態更新包含"#FrameSort"標頭的巨集中的變量。'
L["Below are some examples on how to use this."] = "以下是一些使用示例。"

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@治療,exists] 庇護祝福]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@框架1][mod:shift,@框架2][mod:alt,@玩家][] 驅散]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@不重要] 暗影步;
/cast [@佔位符] 腳踢;]]

L["Example %d"] = "範例 %d"
L["Supported variables:"] = "支持的變量："
L["The first DPS that's not you."] = "第一個不是你的DPS。"
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "添加一個數字來選擇第N個目標，例如，DPS2選擇第二個DPS。"
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "變量不區分大小寫，因此“fRaMe1”、“Dps”、“enemyhealer”等都可以使用。"
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "需要節省巨集字符？使用縮寫來縮短它們："
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '使用"X"告訴FrameSort忽略@unit選擇器：'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@敵治療,exists][] 法術;]]

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
FrameSort支持以下內容：
\n
暴雪
 - 隊伍：是
 - 團隊：是
 - 競技場：已損壞（最終會修復）。
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
 - Bicmex版本：是
\n
GladiusEx
 - 隊伍：是
 - 競技場：是
\n
Cell
 - 隊伍：是
 - 團隊：是，僅在使用組合隊伍時。
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "想將FrameSort集成到您的插件、腳本和Weak Auras中嗎？"
L["Here are some examples."] = "以下是一些範例。"
L["Retrieved an ordered array of party/raid unit tokens."] = "檢索了有序的隊伍/團隊單位標籤陣列。"
L["Retrieved an ordered array of arena unit tokens."] = "檢索了有序的競技場單位標籤陣列。"
L["Register a callback function to run after FrameSort sorts frames."] = "註冊一個回調函數，在FrameSort排序框架後運行。"
L["Retrieve an ordered array of party frames."] = "檢索有序的隊伍框架陣列。"
L["Change a FrameSort setting."] = "更改FrameSort設定。"
L["View a full listing of all API methods on GitHub."] = "在GitHub上查看所有API方法的完整列表。"

-- # Help screen #
L["Help"] = "幫助"
L["Discord"] = "Discord"
L["Need help with something?"] = "需要幫助嗎？"
L["Talk directly with the developer on Discord."] = "在Discord上直接與開發者交流。"

-- # Health Check screen -- #
L["Health Check"] = "健康檢查"
L["Try this"] = "嘗試此操作"
L["Any known issues with configuration or conflicting addons will be shown below."] = "配置或衝突插件的任何已知問題將在下方顯示。"
L["N/A"] = "不適用"
L["Passed!"] = "通過！"
L["Failed"] = "失敗"
L["(unknown)"] = "（未知）"
L["(user macro)"] = "（用戶巨集）"
L["Using grouped layout for Cell raid frames"] = "使用Cell團隊框架的分組佈局"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "請在Cell -> 佈局中檢查“組合隊伍（團隊）”選項。"
L["Can detect frames"] = "可以檢測到框架"
L["FrameSort currently supports frames from these addons: %s."] = "FrameSort當前支持這些插件的框架：%s。"
L["Using Raid-Style Party Frames"] = "使用團隊風格的隊伍框架"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "請在暴雪設定中啟用“使用團隊風格的隊伍框架”。"
L["Keep Groups Together setting disabled"] = "禁用“保持隊伍一起”設置"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "通過編輯模式將團隊顯示模式更改為“組合隊伍”選項之一。"
L["Disable the 'Keep Groups Together' raid profile setting."] = "禁用“保持隊伍一起”團隊設定文件設置。"
L["Only using Blizzard frames with Traditional mode"] = "僅在傳統模式下使用暴雪框架"
L["Traditional mode can't sort your other frame addons: '%s'"] = "傳統模式無法排序您的其他框架插件：“%s”"
L["Using Secure sorting mode when spacing is being used."] = "使用間距時使用安全排序模式。"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "傳統模式無法應用間距，請考慮刪除間距或使用安全排序方法。"
L["Blizzard sorting functions not tampered with"] = "暴雪的排序功能未被篡改"
L['"%s" may cause conflicts, consider disabling it.'] = '“%s”可能會導致衝突，請考慮禁用它。'
L["No conflicting addons"] = "沒有衝突的插件"
L['"%s" may cause conflicts, consider disabling it.'] = '“%s”可能會導致衝突，請考慮禁用它。'
L["Main tank and assist setting disabled"] = "主坦克和協助設置已禁用"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "請在選項 -> 介面 -> 團隊框架中禁用“顯示主坦克和協助”選項。"

