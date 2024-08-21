local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "koKR" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "FrameSort가 올바르게 작동하지 못하게 하는 몇 가지 문제가 있습니다."
L["Please go to the Health Check panel to view more details."] = "자세한 내용을 보려면 건강 확인 패널로 이동하세요."
L["Role"] = "역할"
L["Group"] = "그룹"
L["Alpha"] = "알파"
L["party1 > party2 > partyN > partyN+1"] = "파티1 > 파티2 > 파티N > 파티N+1"
L["tank > healer > dps"] = "탱커 > 힐러 > 딜러"
L["NameA > NameB > NameZ"] = "이름A > 이름B > 이름Z"
L["healer > tank > dps"] = "힐러 > 탱커 > 딜러"
L["healer > dps > tank"] = "힐러 > 딜러 > 탱커"
L["tank > healer > dps"] = "탱커 > 힐러 > 딜러"
L["Arena - 2v2"] = "투기장 - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
L["Arena - %s"] = "투기장 - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "적 투기장 (지원되는 애드온은 애드온 패널에서 확인하세요)"
L["Dungeon (mythics, 5-mans)"] = "던전 (신화, 5인)"
L["Raid (battlegrounds, raids)"] = "공격대 (전장, 공격대)"
L["World (non-instance groups)"] = "세계 (비인스턴스 그룹)"
L["Player"] = "플레이어"
L["Sort"] = "정렬"
L["Top"] = "위"
L["Middle"] = "중간"
L["Bottom"] = "아래"
L["Hidden"] = "숨김"
L["Group"] = "그룹"
L["Role"] = "역할"
L["Alpha"] = "알파"
L["Reverse"] = "역순"

-- # Sorting Method screen #
L["Sorting Method"] = "정렬 방법"
L["Secure"] = "안전"
L["SortingMethod_Secure_Description"] = [[
각 프레임의 위치를 ​​조정하며 UI를 버그/잠금/오염시키지 않습니다.
\n
장점:
 - 다른 애드온의 프레임도 정렬할 수 있습니다.
 - 프레임 간격을 적용할 수 있습니다.
 - 오염 없음 (블리자드의 UI 코드에 간섭하는 애드온에 대한 기술 용어).
\n
단점:
 - 블리자드의 스파게티 코드를 우회하려는 불안정한 상황.
 - WoW 패치로 인해 깨지며 개발자를 미치게 할 수 있습니다.
]]
L["Traditional"] = "전통적인"
L["SortingMethod_Secure_Traditional"] = [[
이것은 10년 이상 동안 애드온과 매크로에서 사용해 온 표준 정렬 모드입니다.
내부 블리자드 정렬 방법을 우리의 것으로 교체합니다.
이것은 FrameSort 구성을 사용한 'SetFlowSortFunction' 스크립트와 동일합니다.
\n
장점:
 - 블리자드의 내부 정렬 방법을 활용하여 더 안정적/신뢰할 수 있습니다.
\n
단점:
 - 블리자드 파티 프레임만 정렬하며 다른 것은 아무 것도 정렬하지 않습니다.
 - Lua 오류를 일으킬 수 있으며 이는 정상이며 무시할 수 있습니다.
 - 프레임 간격을 적용할 수 없습니다.
]]
L["Please reload after changing these settings."] = "이 설정을 변경한 후에는 UI를 다시 로드하십시오."
L["Reload"] = "다시 로드"

-- # Role Ordering screen #
L["Role Ordering"] = "역할 순서"
L["Specify the ordering you wish to use when sorting by role."] = "역할별로 정렬할 때 사용하려는 순서를 지정하세요."
L["Tank > Healer > DPS"] = "탱커 > 힐러 > 딜러"
L["Healer > Tank > DPS"] = "힐러 > 탱커 > 딜러"
L["Healer > DPS > Tank"] = "힐러 > 딜러 > 탱커"

-- # Auto Leader screen #
L["Auto Leader"] = "자동 리더"
L["Auto promote healers to leader in solo shuffle."] = "솔로 셔플에서 힐러를 자동으로 리더로 승급합니다."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "왜요? 힐러가 대상 마커 아이콘을 구성하고 파티1/2를 선호하는 대로 다시 정렬할 수 있도록 합니다."
L["Enabled"] = "활성화됨"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "대상 설정"
L["Target frame 1 (top frame)"] = "대상 프레임 1 (상단 프레임)"
L["Target frame 2"] = "대상 프레임 2"
L["Target frame 3"] = "대상 프레임 3"
L["Target frame 4"] = "대상 프레임 4"
L["Target frame 5"] = "대상 프레임 5"
L["Target bottom frame"] = "하단 프레임 대상"
L["Target frame 1's pet"] = "프레임 1의 소환수 대상"
L["Target frame 2's pet"] = "프레임 2의 소환수 대상"
L["Target frame 3's pet"] = "프레임 3의 소환수 대상"
L["Target frame 4's pet"] = "프레임 4의 소환수 대상"
L["Target frame 5's pet"] = "프레임 5의 소환수 대상"
L["Target enemy frame 1"] = "적 프레임 1 대상"
L["Target enemy frame 2"] = "적 프레임 2 대상"
L["Target enemy frame 3"] = "적 프레임 3 대상"
L["Target enemy frame 1's pet"] = "적 프레임 1의 소환수 대상"
L["Target enemy frame 2's pet"] = "적 프레임 2의 소환수 대상"
L["Target enemy frame 3's pet"] = "적 프레임 3의 소환수 대상"
L["Focus enemy frame 1"] = "적 프레임 1 집중"
L["Focus enemy frame 2"] = "적 프레임 2 집중"
L["Focus enemy frame 3"] = "적 프레임 3 집중"
L["Cycle to the next frame"] = "다음 프레임으로 전환"
L["Cycle to the previous frame"] = "이전 프레임으로 전환"
L["Target the next frame"] = "다음 프레임 대상"
L["Target the previous frame"] = "이전 프레임 대상"

-- # Keybindings screen #
L["Keybindings"] = "단축키 설정"
L["Keybindings_Description"] = [[
FrameSort 단축키는 WoW의 표준 단축키 설정에서 찾을 수 있습니다.
\n
단축키는 어떤 용도로 사용됩니까?
이들은 파티 위치 (파티1/2/3/등)보다는 시각적으로 정렬된 표시를 통해 플레이어를 대상으로 하는 데 유용합니다.
\n
예를 들어, 역할별로 정렬된 5인 던전 그룹이 다음과 같은 모양을 하고 있다고 가정해 보십시오:
  - 탱커, 파티3
  - 힐러, 플레이어
  - 딜러, 파티1
  - 딜러, 파티4
  - 딜러, 파티2
\n
보시다시피 시각적 표현이 실제 파티 위치와 다르기 때문에 타겟팅이 혼란스러워집니다.
만약 /타겟 파티1을 사용하면, 탱커 대신 위치 3의 딜러를 타겟팅하게 됩니다.
\n
FrameSort 단축키는 파티 번호가 아닌 시각적 프레임 위치를 기반으로 타겟팅합니다.
따라서 '프레임 1'을 타겟팅하면 탱커를, '프레임 2'를 타겟팅하면 힐러를, '프레임 3'을 타겟팅하면 위치 3의 딜러를 타겟팅합니다.
]]

-- # Macros screen # --
L["Macros"] = "매크로"
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort가 관리할 %d|4매크로:매크로;를 찾았습니다."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort는 "#FrameSort" 헤더를 포함하는 매크로 내에서 변수를 동적으로 업데이트합니다.'
L["Below are some examples on how to use this."] = "사용 예는 다음과 같습니다."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@힐러,exists] 성역의 축복]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@프레임1][mod:shift,@프레임2][mod:alt,@플레이어][] 정화]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@상관없음] 그림자 밟기;
/cast [@자리채움] 발차기;]]

L["Example %d"] = "예제 %d"
L["Supported variables:"] = "지원되는 변수:"
L["The first DPS that's not you."] = "자신이 아닌 첫 번째 딜러."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "숫자를 추가하여 N번째 대상을 선택합니다. 예: DPS2는 두 번째 딜러를 선택합니다."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "변수는 대소문자를 구분하지 않으므로 'fRaMe1', 'Dps', 'enemyhealer' 등은 모두 작동합니다."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "매크로 문자 수를 줄여야 합니까? 약어를 사용하여 줄이세요:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'FrameSort에 @unit 선택기를 무시하도록 지시하려면 "X"를 사용하세요:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@적힐러,exists][] 주문;]]

-- # Spacing screen #
L["Spacing"] = "간격"
L["Add some spacing between party/raid frames."] = "파티/레이드 프레임 사이에 간격을 추가합니다."
L["This only applies to Blizzard frames."] = "이는 블리자드 프레임에만 적용됩니다."
L["Party"] = "파티"
L["Raid"] = "레이드"
L["Group"] = "그룹"
L["Horizontal"] = "수평"
L["Vertical"] = "수직"

-- # Addons screen #
L["Addons"] = "애드온"
L["Addons_Supported_Description"] = [[
FrameSort는 다음을 지원합니다:
\n
블리자드
 - 파티: 예
 - 공격대: 예
 - 투기장: 고장 (나중에 수정 예정).
\n
ElvUI
 - 파티: 예
 - 공격대: 아니요
 - 투기장: 아니요
\n
sArena
 - 투기장: 예
\n
Gladius
 - 투기장: 예
 - Bicmex 버전: 예
\n
GladiusEx
 - 파티: 예
 - 투기장: 예
\n
Cell
 - 파티: 예
 - 공격대: 예, 결합된 그룹 사용 시에만.
\n
Shadowed Unit Frames
 - 파티: 예
 - 투기장: 예
\n
Grid2
 - 파티/공격대: 예
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "FrameSort를 애드온, 스크립트 및 약한 오라에 통합하시겠습니까?"
L["Here are some examples."] = "여기에 몇 가지 예가 있습니다."
L["Retrieved an ordered array of party/raid unit tokens."] = "정렬된 파티/레이드 유닛 토큰 배열을 가져옴."
L["Retrieved an ordered array of arena unit tokens."] = "정렬된 투기장 유닛 토큰 배열을 가져옴."
L["Register a callback function to run after FrameSort sorts frames."] = "FrameSort가 프레임을 정렬한 후 실행할 콜백 함수를 등록하세요."
L["Retrieve an ordered array of party frames."] = "정렬된 파티 프레임 배열을 가져옴."
L["Change a FrameSort setting."] = "FrameSort 설정을 변경합니다."
L["View a full listing of all API methods on GitHub."] = "GitHub에서 모든 API 메서드의 전체 목록을 봅니다."

-- # Help screen #
L["Help"] = "도움말"
L["Discord"] = "디스코드"
L["Need help with something?"] = "무엇이 필요합니까?"
L["Talk directly with the developer on Discord."] = "디스코드에서 개발자와 직접 이야기하세요."

-- # Health Check screen -- #
L["Health Check"] = "건강 확인"
L["Try this"] = "이거 해보세요"
L["Any known issues with configuration or conflicting addons will be shown below."] = "구성이나 충돌하는 애드온과 관련된 알려진 문제가 아래에 표시됩니다."
L["N/A"] = "해당 없음"
L["Passed!"] = "통과!"
L["Failed"] = "실패"
L["(unknown)"] = "(알 수 없음)"
L["(user macro)"] = "(사용자 매크로)"
L["Using grouped layout for Cell raid frames"] = "Cell 레이드 프레임에 그룹화된 레이아웃 사용"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Cell -> 레이아웃에서 '통합 그룹 (레이드)' 옵션을 확인하세요."
L["Can detect frames"] = "프레임을 감지할 수 있음"
L["FrameSort currently supports frames from these addons: %s."] = "FrameSort는 현재 다음 애드온의 프레임을 지원합니다: %s."
L["Using Raid-Style Party Frames"] = "레이드 스타일 파티 프레임 사용"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "블리자드 설정에서 '레이드 스타일 파티 프레임 사용'을 활성화하세요."
L["Keep Groups Together setting disabled"] = "'그룹 함께 유지' 설정 비활성화됨"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "편집 모드를 통해 '통합 그룹' 옵션 중 하나로 레이드 표시 모드를 변경하세요."
L["Disable the 'Keep Groups Together' raid profile setting."] = "'그룹 함께 유지' 레이드 프로필 설정을 비활성화하세요."
L["Only using Blizzard frames with Traditional mode"] = "전통 모드에서만 블리자드 프레임 사용"
L["Traditional mode can't sort your other frame addons: '%s'"] = "전통 모드는 다른 프레임 애드온을 정렬할 수 없습니다: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "간격이 사용 중일 때 안전한 정렬 모드를 사용."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "전통 모드는 간격을 적용할 수 없습니다. 간격을 제거하거나 안전한 정렬 방법을 사용하는 것을 고려하세요."
L["Blizzard sorting functions not tampered with"] = "블리자드 정렬 기능이 변경되지 않음"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s"가 충돌을 일으킬 수 있으므로 비활성화하는 것을 고려하세요.'
L["No conflicting addons"] = "충돌하는 애드온 없음"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s"가 충돌을 일으킬 수 있으므로 비활성화하는 것을 고려하세요.'
L["Main tank and assist setting disabled"] = "'주 탱커 및 지원 설정' 비활성화됨"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "옵션 -> 인터페이스 -> 레이드 프레임에서 '주 탱커 및 지원 표시' 옵션을 비활성화하세요."

