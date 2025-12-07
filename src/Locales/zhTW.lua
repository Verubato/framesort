local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhTW" then
    return
end

-- # Main Options screen #
L["FrameSort - %s"] = "框架排序 - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "有一些問題可能會阻止框架排序正常運作。"
L["Please go to the Health Check panel to view more details."] = "請前往健康檢查面板以查看詳細信息。"
L["Role"] = "角色"
L["Group"] = "小隊"
L["Alphabetical"] = "字母順序"
L["Arena - 2v2"] = "競技場 - 2對2"
L["Arena - 3v3"] = "競技場 - 3對3"
L["Arena - 3v3 & 5v5"] = "競技場 - 3對3 & 5對5"
L["Enemy Arena (see addons panel for supported addons)"] = "敵方競技場（請查看插件面板以獲取支援的插件）"
L["Dungeon (mythics, 5-mans, delves)"] = "地下城（神話、5人、探索）"
L["Raid (battlegrounds, raids)"] = "團隊（戰場、團隊）"
L["World (non-instance groups)"] = "世界（非副本小隊）"
L["Player"] = "玩家"
L["Sort"] = "排序"
L["Top"] = "上方"
L["Middle"] = "中間"
L["Bottom"] = "下方"
L["Hidden"] = "隱藏"
L["Group"] = "小隊"
L["Reverse"] = "反向"

-- # Sorting Method screen #
L["Sorting Method"] = "排序方法"
L["Secure"] = "安全"
L["SortingMethod_Secure_Description"] = [[
調整每個單獨框架的位置，不會擾亂/鎖定/污染UI。
\n
優點：
 - 可以對其他插件的框架進行排序。
 - 可以應用框架間距。
 - 無污染（技術術語，表示插件干擾與暴雪的UI代碼）。
\n
缺點：
 - 在突破暴雪的錯綜複雜結構上容易出現脆弱的卡片房屋情況。
 - 可能會隨著魔獸世界的更新而中斷，並使開發者發瘋。
]]
L["Traditional"] = "傳統"
L["SortingMethod_Traditional_Description"] = [[
這是插件和宏已使用超過10年的標準排序模式。
它用我們自己的排序方法取代暴雪的內部排序方法。
這與“SetFlowSortFunction”腳本相同，但使用框架排序配置。
\n
優點：
 - 更穩定/可靠，因為它利用了暴雪的內部排序方法。
\n
缺點：
 - 只對暴雪的小隊框架進行排序，其他的無法。
 - 會導致Lua錯誤，這是正常的，可以忽略。
 - 無法應用框架間距。
]]
L["Please reload after changing these settings."] = "更改這些設置後請重新加載。"
L["Reload"] = "重新加載"

-- # Ordering screen #
L["Ordering"] = "排序"
L["Specify the ordering you wish to use when sorting by role."] = "指定按角色排序時要使用的順序。"
L["Tanks"] = "坦克"
L["Healers"] = "治療者"
L["Casters"] = "施法者"
L["Hunters"] = "獵人"
L["Melee"] = "近戰"

-- # Auto Leader screen #
L["Auto Leader"] = "自動隊長"
L["Auto promote healers to leader in solo shuffle."] = "在單人隨機中自動將治療者提升為隊長。"
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "為什麼？這樣治療者可以配置目標標記圖標並按他們的喜好重新排序小隊1/2。"
L["Enabled"] = "已啟用"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "選擇目標"
L["Target frame 1 (top frame)"] = "目標框架1（上方框架）"
L["Target frame 2"] = "目標框架2"
L["Target frame 3"] = "目標框架3"
L["Target frame 4"] = "目標框架4"
L["Target frame 5"] = "目標框架5"
L["Target bottom frame"] = "目標下方框架"
L["Target 1 frame above bottom"] = "目標下方框架的1個框架"
L["Target 2 frames above bottom"] = "目標下方框架的2個框架"
L["Target 3 frames above bottom"] = "目標下方框架的3個框架"
L["Target 4 frames above bottom"] = "目標下方框架的4個框架"
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
L["Focus enemy frame 1"] = "集中敵方框架1"
L["Focus enemy frame 2"] = "集中敵方框架2"
L["Focus enemy frame 3"] = "集中敵方框架3"
L["Cycle to the next frame"] = "切換到下一個框架"
L["Cycle to the previous frame"] = "切換到上一個框架"
L["Target the next frame"] = "目標下一個框架"
L["Target the previous frame"] = "目標上一個框架"

-- # Keybindings screen #
L["Keybindings"] = "按鍵設定"
L["Keybindings_Description"] = [[
您可以在標準魔獸世界按鍵設定區域找到框架排序的按鍵設定。
\n
這些按鍵設定有什麼用？
它們有助於根據視覺排序的表示法而不是小隊位置（小隊1/2/3等）來選擇玩家。
\n
例如，想像一個按角色排序的5人地下城小隊，如下所示：
  - 坦克，小隊3
  - 治療者，玩家
  - DPS，小隊1
  - DPS，小隊4
  - DPS，小隊2
\n
如您所見，他們的視覺表示與實際小隊位置不同，這使得目標選擇變得混亂。
如果您使用 /target 小隊1，則會目標小隊位置3的DPS玩家，而不是坦克。
\n
框架排序的按鍵設定將根據其視覺框架位置而不是小隊編號進行目標選擇。
因此，目標“框架1”將目標坦克，“框架2”目標治療者，“框架3”目標位置3的DPS，如此類推。
]]

-- # Macros screen # --
L["Macros"] = "宏"
L["FrameSort has found %d |4macro:macros; to manage."] = "框架排序已找到%d |4宏:宏;可管理。"
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "框架排序將動態更新包含'#FrameSort'標題的宏中的變數。"
L["Below are some examples on how to use this."] = "以下是一些如何使用它的例子。"

L["Macro_Example1"] = [[#showtooltip
#FrameSort 滑鼠懸停、目標、治療者
/cast [@mouseover,help][@target,help][@healer,exists] 其他庇護]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort 框架1、框架2、玩家
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] 驅散]]

L["Macro_Example3"] = [[#FrameSort 敌方治療者、敌方治療者
/cast [@doesntmatter] 影步;
/cast [@placeholder] 踢;]]

L["Example %d"] = "範例 %d"
L["Discord Bot Blurb"] = [[
需要創建宏的幫助嗎？ 
\n
前往框架排序的Discord伺服器並使用我們的AI驅動的宏機器人！
\n
只需在宏機器人頻道中標註'@Macro Bot'並附上您的問題。
]]

-- # Macro Variables screen # --
L["Macro Variables"] = "宏變數"
L["The first DPS that's not you."] = "第一個不是你的DPS。"
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "添加數字以選擇第N個目標，例如，DPS2選擇第二個DPS。"
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "變數不區分大小寫，因此'fRaMe1'，'Dps'，'enemyhealer'等都可以使用。"
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "需要節省宏字符嗎？使用縮寫來縮短它們："
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '使用"X"告訴框架排序忽略@unit選擇器：'
L["Skip_Example"] = [[
#FS X X 敌方治療者
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] 法術;]]

-- # Spacing screen #
L["Spacing"] = "間距"
L["Add some spacing between party, raid, and arena frames."] = "在小隊、團隊和競技場框架之間添加一些間距。"
L["This only applies to Blizzard frames."] = "這僅適用於暴雪框架。"
L["Party"] = "小隊"
L["Raid"] = "團隊"
L["Group"] = "小隊"
L["Horizontal"] = "水平"
L["Vertical"] = "垂直"

-- # Addons screen #
L["Addons"] = "插件"
L["Addons_Supported_Description"] = [[
框架排序支持以下插件：
\n
  - 暴雪：小隊，團隊，競技場。
\n
  - ElvUI：小隊。
\n
  - sArena：競技場。
\n
  - Gladius：競技場。
\n
  - GladiusEx：小隊，競技場。
\n
  - Cell：小隊，團隊（僅在使用組合小隊時）。
\n
  - Shadowed Unit Frames：小隊，競技場。
\n
  - Grid2：小隊，團隊。
\n
  - BattleGroundEnemies：小隊，競技場。
\n
  - Gladdy：競技場。
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "想將框架排序集成到您的插件、腳本和弱光環中嗎？"
L["Here are some examples."] = "這裡有一些例子。"
L["Retrieved an ordered array of party/raid unit tokens."] = "檢索到按順序排列的小隊/團隊單位令牌陣列。"
L["Retrieved an ordered array of arena unit tokens."] = "檢索到按順序排列的競技場單位令牌陣列。"
L["Register a callback function to run after FrameSort sorts frames."] = "註冊回調函數以在框架排序後運行。"
L["Retrieve an ordered array of party frames."] = "檢索按順序排列的小隊框架。"
L["Change a FrameSort setting."] = "更改框架排序的設置。"
L["View a full listing of all API methods on GitHub."] = "在GitHub上查看所有API方法的完整列表。"

-- # Discord screen #
L["Discord"] = "Discord"
L["Need help with something?"] = "需要某方面的幫助嗎？"
L["Talk directly with the developer on Discord."] = "在Discord上直接與開發者交談。"

-- # Health Check screen -- #
L["Health Check"] = "健康檢查"
L["Try this"] = "試試這個"
L["Any known issues with configuration or conflicting addons will be shown below."] = "任何已知的配置問題或衝突的插件將顯示在下面。"
L["N/A"] = "不適用"
L["Passed!"] = "通過！"
L["Failed"] = "失敗"
L["(unknown)"] = "(未知)"
L["(user macro)"] = "(用戶宏)"
L["Using grouped layout for Cell raid frames"] = "對Cell團隊框架使用組合佈局"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = "請檢查Cell -> 佈局中的'組合小組（團隊）'選項"
L["Can detect frames"] = "可以檢測到框架"
L["FrameSort currently supports frames from these addons: %s"] = "框架排序目前支持來自以下插件的框架：%s"
L["Using Raid-Style Party Frames"] = "使用團隊式小隊框架"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings"] = "請在暴雪設置中啟用'使用團隊式小隊框架'"
L["Keep Groups Together setting disabled"] = "保持小隊在一起的設置已禁用"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = "通過編輯模式將團隊顯示模式更改為'組合小組'選項之一"
L["Disable the 'Keep Groups Together' raid profile setting."] = "禁用'保持小隊在一起'的團隊配置文件設置。"
L["Only using Blizzard frames with Traditional mode"] = "僅在傳統模式下使用暴雪框架"
L["Traditional mode can't sort your other frame addons: '%s'"] = "傳統模式無法對其他框架插件進行排序：'%s'"
L["Using Secure sorting mode when spacing is being used"] = "在使用間距時使用安全排序模式"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] = "傳統模式無法應用間距，考慮移除間距或使用安全排序方法"
L["Blizzard sorting functions not tampered with"] = "未篡改暴雪排序函數"
L['"%s" may cause conflicts, consider disabling it'] = '"%s"可能會導致衝突，考慮禁用它'
L["No conflicting addons"] = "沒有衝突的插件"
L["Main tank and assist setting disabled"] = "主坦和助攻設置已禁用"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames"] = "請在選項 -> 界面 -> 團隊框架中禁用'顯示主坦和助攻'選項"

-- # Log Screen -- #
L["Log"] = "日誌"
L["FrameSort log to help with diagnosing issues."] = "框架排序日誌有助於診斷問題。"
