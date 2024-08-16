local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhTW" then
    return
end

L["FrameSort"] = "框架排序"

-- # 主選項界面 #
-- 用於 FrameSort - 1.2.3 版本標題，%s 是版本號
L["FrameSort - %s"] = "框架排序 - %s"
L["There are some issues that may prevent FrameSort from working correctly."] = "有一些問題可能會阻止 FrameSort 正常工作。"
L["Please go to the Health Check panel to view more details."] = "請前往健康檢查面板以查看更多詳情。"
L["Role"] = "角色"
L["Group"] = "小隊"
L["Alpha"] = "透明度"
L["party1 > party2 > partyN > partyN+1"] = "隊伍1 > 隊伍2 > 隊伍N > 隊伍N+1"
L["tank > healer > dps"] = "坦克 > 治療 > DPS"
L["NameA > NameB > NameZ"] = "名字A > 名字B > 名字Z"
L["healer > tank > dps"] = "治療 > 坦克 > DPS"
L["healer > dps > tank"] = "治療 > DPS > 坦克"
L["tank > healer > dps"] = "坦克 > 治療 > DPS"
L["Arena - 2v2"] = "競技場 - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
-- %s 是 "3v3" 或 "3v3 & 5v5"
L["Arena - %s"] = "競技場 - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "敵方競技場（請參閱插件面板中的支持插件）"
L["Dungeon (mythics, 5-mans)"] = "地下城（大秘境，5人本）"
L["Raid (battlegrounds, raids)"] = "團隊（戰場，團隊副本）"
L["World (non-instance groups)"] = "世界（非副本隊伍）"
L["Player:"] = "玩家："
L["Top"] = "頂部"
L["Middle"] = "中間"
L["Bottom"] = "底部"
L["Hidden"] = "隱藏"
L["Group"] = "小隊"
L["Role"] = "角色"
L["Alpha"] = "透明度"
L["Reverse"] = "反轉"

-- # 排序方式界面 #
L["Sorting Method"] = "排序方式"
L["Secure"] = "安全"
L["SortingMethod_Secure_Description"] = [[
調整每個單獨框架的位置，不會導致UI錯誤/鎖定/汙染。
\n
優點：
 - 可以排序來自其他插件的框架。
 - 可以應用框架間距。
 - 無汙染（技術術語，指插件不會幹擾暴雪的UI代碼）。
\n
缺點：
 - 為了規避暴雪的代碼，可能會產生脆弱的解決方案。
 - 可能在魔獸更新時出錯，並導致開發者發瘋。
]]
L["Traditional"] = "傳統"
L["SortingMethod_Secure_Traditional"] = [[
這是插件和宏使用超過10年的標準排序模式。
它替換了暴雪的內部排序方法，使用我們自己的排序方式。
與 FrameSort 配置一樣，這與 'SetFlowSortFunction' 腳本相同。
\n
優點：
 - 更加穩定可靠，因為它利用了暴雪的內部排序方法。"
\n
缺點：
 - 僅能排序暴雪的小隊框架，其他框架無效。
 - 會導致Lua錯誤，這是正常的，可以忽略。
 - 無法應用框架間距。
]]
L["Please reload after changing these settings."] = "更改這些設置後請重載界面。"
L["Reload"] = "重載"

-- # 角色排序界面 #
L["Role Ordering"] = "角色排序"
L["Specify the ordering you wish to use when sorting by role."] = "指定按角色排序時要使用的排序順序。"
L["Tank > Healer > DPS"] = "坦克 > 治療 > DPS"
L["Healer > Tank > DPS"] = "治療 > 坦克 > DPS"
L["Healer > DPS > Tank"] = "治療 > DPS > 坦克"

-- # 自動隊長界面 #
L["Auto Leader"] = "自動隊長"
L["Auto promote healers to leader in solo shuffle."] = "在單排混戰中自動提升治療為隊長。"
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "為什麽？這樣治療可以配置目標標記圖標並重新排列小隊1/2。"
L["Enabled"] = "已啟用"

-- # 暴雪按鍵綁定界面（FrameSort部分） #
L["Targeting"] = "目標選擇"
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
L["Target the next frame"] = "選擇下一個框架"
L["Target the previous frame"] = "選擇上一個框架"

-- # 按鍵綁定界面 #
L["Keybindings"] = "按鍵綁定"
L["Keybindings_Description"] = [[
你可以在魔獸世界的標準按鍵綁定區域找到 FrameSort 的按鍵綁定。
\n
按鍵綁定有什麽用？
它們可以通過其視覺排列順序而不是隊伍位置（party1/2/3等）來選擇玩家。
\n
例如，想象一個按角色排序的5人地下城隊伍，如下所示：
  - 坦克，隊伍3
  - 治療，玩家
  - DPS，隊伍1
  - DPS，隊伍4
  - DPS，隊伍2
\n
如你所見，他們的視覺排列與他們的實際隊伍位置不同，這使得目標選擇變得混亂。
如果你使用 /target party1，它將選擇位置3的DPS玩家，而不是坦克。
\n
FrameSort 按鍵綁定將根據他們的視覺框架位置來選擇目標，而不是隊伍編號。
因此，選擇「框架1」將選擇坦克，「框架2」將選擇治療，「框架3」將選擇位置3的DPS，以此類推。
]]

-- # 宏界面 # --
L["Macros"] = "宏"
-- "|4macro:macros;" 是一個特殊命令，當 %d 大於1時，將單詞 "macro" 變為復數 "macros"
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort 發現了 %d 個|4宏:宏; 需要管理。"
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort 會動態更新包含 "#FrameSort" 標頭的宏中的變量。'
L["Below are some examples on how to use this."] = "以下是一些使用示例。"

L["Macro_Example1"] = [[#showtooltip
#FrameSort 鼠標懸停, 目標, 治療
/cast [@mouseover,help][@target,help][@healer,exists] 庇護祝福]]

L["Macro_Example2"] = [[#showtooltip
#Frame

Sort 框架1, 框架2, 玩家
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] 驅散]]

L["Macro_Example3"] = [[#FrameSort 敵方治療, 敵方治療
/cast [@doesntmatter] 暗影步;
/cast [@placeholder] 腳踢;]]

-- %d 是 示例1/2/3 的編號
L["Example %d"] = "示例 %d"
L["Supported variables:"] = "支持的變量："
L["The first DPS that's not you."] = "第一個不是你的DPS。"
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "添加一個數字來選擇第N個目標，例如，DPS2 選擇第2個DPS。"
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "變量不區分大小寫，因此 'fRaMe1'，'Dps'，'enemyhealer' 等都可以使用。"
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "需要節省宏字符？使用縮寫來縮短它們："
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '使用 "X" 告訴 FrameSort 忽略 @單位 選擇器：'
L["Skip_Example"] = [[
#FS X X 敵方治療
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] 法術;]]

-- # 間距界面 #
L["Spacing"] = "間距"
L["Add some spacing between party/raid frames."] = "在小隊/團隊框架之間添加一些間距。"
L["This only applies to Blizzard frames."] = "此選項僅適用於暴雪框架。"
L["Party"] = "小隊"
L["Raid"] = "團隊"
L["Group"] = "小隊"
L["Horizontal"] = "水平"
L["Vertical"] = "垂直"

-- # 插件界面 #
L["Addons"] = "插件"
L["Addons_Supported_Description"] = [[
FrameSort 支持以下插件：
\n
暴雪
 - 小隊：是
 - 團隊：是
 - 競技場：損壞（會盡快修復）。
\n
ElvUI
 - 小隊：是
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
 - 小隊：是
 - 競技場：是
\n
Cell
 - 小隊：是
 - 團隊：是，僅當使用組合組時。
]]

-- # API界面 #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "想將 FrameSort 集成到您的插件、腳本和 Weak Auras 中嗎？"
L["Here are some examples."] = "以下是一些示例。"
L["Retrieved an ordered array of party/raid unit tokens."] = "檢索到有序的小隊/團隊單位標記數組。"
L["Retrieved an ordered array of arena unit tokens."] = "檢索到有序的競技場單位標記數組。"
L["Register a callback function to run after FrameSort sorts frames."] = "註冊一個回調函數，以在 FrameSort 排序框架後運行。"
L["Retrieve an ordered array of party frames."] = "檢索到有序的小隊框架數組。"
L["Change a FrameSort setting."] = "更改 FrameSort 設置。"
L["View a full listing of all API methods on GitHub."] = "在 GitHub 上查看所有 API 方法的完整列表。"

-- # 幫助界面 #
L["Help"] = "幫助"
L["Discord"] = "Discord"
L["Need help with something?"] = "需要幫助嗎？"
L["Talk directly with the developer on Discord."] = "在 Discord 上直接與開發人員交談。"

-- # 健康檢查界面 -- #
L["Health Check"] = "健康檢查"
L["Try this"] = "嘗試這個"
L["Any known issues with configuration or conflicting addons will be shown below."] = "任何已知的配置問題或沖突的插件都會顯示在下方。"
L["N/A"] = "不適用"
L["Passed!"] = "通過！"
L["Failed"] = "失敗"
L["(unknown)"] = "(未知)"
L["(user macro)"] = "(用戶宏)"
L["Using grouped layout for Cell raid frames"] = "使用 Cell 團隊框架的組合布局"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "請檢查 Cell -> 布局中的「組合組（團隊）」選項。"
L["Can detect frames"] = "可以檢測到框架"
L["FrameSort currently supports frames from these addons: %s."] = "FrameSort 當前支持來自這些插件的框架：%s。"
L["Using Raid-Style Party Frames"] = "使用團隊風格的小隊框架"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "請在暴雪設置中啟用「使用團隊風格的小隊框架」。"
L["Keep Groups Together setting disabled"] = "「保持隊伍在一起」設置已禁用"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "通過編輯模式將團隊顯示模式更改為「組合組」選項之一。"
L["Disable the 'Keep Groups Together' raid profile setting."] = "禁用「保持隊伍在一起」的團隊配置文件設置。"
L["Only using Blizzard frames with Traditional mode"] = "僅在傳統模式下使用暴雪框架"
L["Traditional mode can't sort your other frame addons: '%s'"] = "傳統模式無法排序您的其他框架插件：'%s'"
L["Using Secure sorting mode when spacing is being used."] = "使用間距時使用安全排序模式。"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "傳統模式無法應用間距，請考慮移除間距或使用安全排序方式。"
L["Blizzard sorting functions not tampered with"] = "暴雪的排序功能未被篡改"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" 可能會引起沖突，建議禁用它。'
L["No conflicting addons"] = "沒有沖突的插件"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" 可能會引起沖突，建議禁用它。'
L["Main tank and assist setting disabled"] = "主坦克和助攻設置已禁用"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "請禁用 選項 -> 界面 -> 團隊框架中的「顯示主坦克和助攻」選項。"
