local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "koKR" then
    return
end

L["FrameSort"] = "프레임정렬"

-- # Main Options screen #
L["FrameSort - %s"] = "프레임정렬 - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "프레임정렬이 올바르게 작동하지 않을 수 있는 문제가 있습니다."
L["Please go to the Health Check panel to view more details."] = "자세한 내용을 보려면 건강 점검 패널로 이동해 주세요."
L["Role"] = "역할"
L["Group"] = "그룹"
L["Alpha"] = "투명도"
L["party1 > party2 > partyN > partyN+1"] = "party1 > party2 > partyN > partyN+1"
L["tank > healer > dps"] = "탱커 > 힐러 > 딜러"
L["NameA > NameB > NameZ"] = "이름A > 이름B > 이름Z"
L["healer > tank > dps"] = "힐러 > 탱커 > 딜러"
L["healer > dps > tank"] = "힐러 > 딜러 > 탱커"
L["tank > healer > dps"] = "탱커 > 힐러 > 딜러"
L["Arena - 2v2"] = "투기장 - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
L["Arena - %s"] = "투기장 - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "적의 투기장 (지원되는 애드온은 애드온 패널을 참조하세요)"
L["Dungeon (mythics, 5-mans)"] = "던전 (신화, 5인)"
L["Raid (battlegrounds, raids)"] = "레이드 (전장, 레이드)"
L["World (non-instance groups)"] = "월드 (비인스턴스 그룹)"
L["Player:"] = "플레이어:"
L["Top"] = "상단"
L["Middle"] = "중간"
L["Bottom"] = "하단"
L["Hidden"] = "숨김"
L["Group"] = "그룹"
L["Role"] = "역할"
L["Alpha"] = "투명도"
L["Reverse"] = "반전"

-- # Sorting Method screen #
L["Sorting Method"] = "정렬 방법"
L["Secure"] = "보안"
L["SortingMethod_Secure_Description"] = [[
각 프레임의 위치를 개별적으로 조정하고 Blizzard UI 코드의 잠금을/보안을 적용합니다.
\n
장점:
 - 다른 애드온의 프레임도 정렬할 수 있습니다.
 - 프레임 간의 간격을 적용할 수 있습니다.
 - Blizzard의 코드에 대한 오염이 없습니다 (Blizzard 인터페이스와 관련된 기술적 용어).
\n
단점:
 - Blizzard 코드와의 문제를 피하기 위해 민감한 상황일 수 있습니다.
 - WoW 패치로 인해 깨질 수 있으며 개발자가 미쳐버릴 수도 있습니다.
]]
L["Traditional"] = "전통적인"
L["SortingMethod_Secure_Traditional"] = [[
이것은 10년 넘게 애드온과 매크로에서 사용해 온 기본 정렬 모드입니다.
Blizzard의 내부 정렬 방법을 우리의 것으로 대체합니다.
'SetFlowSortFunction' 스크립트와 동일하지만 FrameSort의 설정이 적용됩니다.
\n
장점:
 - Blizzard의 내부 정렬 방법을 사용하기 때문에 더 안정적입니다.
\n
단점:
 - Blizzard의 그룹 프레임만 정렬할 수 있습니다.
 - 정상적이며 무시할 수 있는 Lua 오류를 유발할 수 있습니다.
 - 프레임 간의 간격을 적용할 수 없습니다.
]]
L["Please reload after changing these settings."] = "이 설정을 변경한 후에 다시 로드해 주세요."
L["Reload"] = "다시 로드"

-- # Role Ordering screen #
L["Role Ordering"] = "역할 정렬"
L["Specify the ordering you wish to use when sorting by role."] = "역할에 따라 정렬할 때 사용할 순서를 지정해 주세요."
L["Tank > Healer > DPS"] = "탱커 > 힐러 > 딜러"
L["Healer > Tank > DPS"] = "힐러 > 탱커 > 딜러"
L["Healer > DPS > Tank"] = "힐러 > 딜러 > 탱커"

-- # Auto Leader screen #
L["Auto Leader"] = "자동 리더"
L["Auto promote healers to leader in solo shuffle."] = "솔로 셔플에서 힐러를 자동으로 리더로 승격시킵니다."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "왜냐하면 힐러가 대상 마커 아이콘을 설정하고 party1/2를 자신의 선호에 맞게 재정렬할 수 있도록 하기 위함입니다."
L["Enabled"] = "활성화됨"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "타겟 설정"
L["Target frame 1 (top frame)"] = "프레임 1 (상단 프레임) 설정"
L["Target frame 2"] = "프레임 2 설정"
L["Target frame 3"] = "프레임 3 설정"
L["Target frame 4"] = "프레임 4 설정"
L["Target frame 5"] = "프레임 5 설정"
L["Target bottom frame"] = "하단 프레임 설정"
L["Target frame 1's pet"] = "프레임 1의 애완동물 설정"
L["Target frame 2's pet"] = "프레임 2의 애완동물 설정"
L["Target frame 3's pet"] = "프레임 3의 애완동물 설정"
L["Target frame 4's pet"] = "프레임 4의 애완동물 설정"
L["Target frame 5's pet"] = "프레임 5의 애완동물 설정"
L["Target enemy frame 1"] = "적의 프레임 1 설정"
L["Target enemy frame 2"] = "적의 프레임 2 설정"
L["Target enemy frame 3"] = "적의 프레임 3 설정"
L["Target enemy frame 1's pet"] = "적의 프레임 1의 애완동물 설정"
L["Target enemy frame 2's pet"] = "적의 프레임 2의 애완동물 설정"
L["Target enemy frame 3's pet"] = "적의 프레임 3의 애완동물 설정"
L["Focus enemy frame 1"] = "적의 프레임 1 집중"
L["Focus enemy frame 2"] = "적의 프레임 2 집중"
L["Focus enemy frame 3"] = "적의 프레임 3 집중"
L["Cycle to the next frame"] = "다음 프레임으로 이동"
L["Cycle to the previous frame"] = "이전 프레임으로 이동"
L["Target the next frame"] = "다음 프레임을 타겟 설정"
L["Target the previous frame"] = "이전 프레임을 타겟 설정"

-- # Keybindings screen #
L["Keybindings"] = "단축키"
L["Keybindings_Description"] = [[
프레임정렬의 단축키를 WoW의 표준 단축키 섹션에서 확인할 수 있습니다.
\n
단축키가 유용한 이유는 프레임의 시각적 표현에 따라 플레이어를 타겟팅할 수 있기 때문입니다. 그룹 내 위치 대신 말이죠 (party1/2/3 등).
\n
예를 들어, 다음과 같은 역할별로 정렬된 5인 던전 그룹이 있다고 가정해 보겠습니다:
  - 탱커, party3
  - 힐러, 플레이어
  - 딜러, party1
  - 딜러, party4
  - 딜러, party2
\n
보시다시피, 시각적 표현이 그룹 내 위치와 다르기 때문에 타겟팅이 혼란스러울 수 있습니다.
'/target party1'을 사용하면 3번째 위치의 딜러를 타겟팅하게 됩니다.
\n
프레임정렬의 단축키는 그룹 내 숫자가 아닌 프레임의 시각적 위치에 따라 타겟팅합니다.
따라서 '프레임 1'은 탱커를 타겟팅하고, '프레임 2'는 힐러를 타겟팅하며, '프레임 3'은 3번째 위치의 딜러를

 타겟팅합니다.
]]
L["Macro Examples"] = "매크로 예시"
L["Macro_Example1"] = [[
#showtooltip
#프레임정렬 프레임1, 프레임2, 프레임3
/cast [mod:shift,@프레임1][mod:alt,@프레임2][mod:ctrl,@프레임3][] 치유]]
L["Macro_Example2"] = [[
#showtooltip
#프레임정렬 프레임1, 프레임2, 플레이어
/cast [mod:ctrl,@프레임1][mod:shift,@프레임2][mod:alt,@플레이어][] 해제]]
L["Macro_Example3"] = [[
#프레임정렬 적의힐러, 적의힐러
/cast [@같음] 그림자 걷기;
/cast [@공간] 지뢰;]]
L["Example %d"] = "예시 %d"
L["Supported variables:"] = "지원되는 변수:"
L["The first DPS that's not you."] = "당신이 아닌 첫 번째 딜러."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "숫자를 추가하여 N번째 대상을 선택합니다. 예를 들어, DPS2는 2번째 딜러를 선택합니다."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "변수는 대소문자를 구분하지 않으므로 'fRaMe1', 'Dps', 'enemyhealer' 등 모두 작동합니다."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "매크로 문자에서 저장할 필요가 있습니까? 축약어를 사용하여 줄이세요:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '프레임정렬이 @unit 선택기를 무시하도록 "X"를 사용하세요:'
L["Skip_Example"] = [[
#FS X X 적의힐러
/cast [mod:shift,@초점][@마우스오버,해로운][@적의힐러,존재][] 주문;]]

-- # Spacing screen #
L["Spacing"] = "간격"
L["Add some spacing between party/raid frames."] = "파티/레이드 프레임 간의 간격을 추가합니다."
L["This only applies to Blizzard frames."] = "이것은 Blizzard 프레임에만 적용됩니다."
L["Party"] = "파티"
L["Raid"] = "레이드"
L["Group"] = "그룹"
L["Horizontal"] = "수평"
L["Vertical"] = "수직"

-- # Addons screen #
L["Addons"] = "애드온"
L["Addons_Supported_Description"] = [[
프레임정렬은 다음 애드온을 지원합니다:
\n
Blizzard
 - 파티: 예
 - 레이드: 예
 - 아레나: 작동하지 않음 (언젠가 수정할 예정입니다).
\n
ElvUI
 - 파티: 예
 - 레이드: 아니오
 - 아레나: 아니오
\n
sArena
 - 아레나: 예
\n
Gladius
 - 아레나: 예
 - Bicmex 버전: 예
\n
GladiusEx
 - 파티: 예
 - 아레나: 예
\n
Cell
 - 파티: 예
 - 레이드: 예, 결합된 그룹을 사용할 때만.
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "프레임정렬을 애드온, 스크립트 및 Weak Auras에 통합하고 싶으신가요?"
L["Here are some examples."] = "여기 몇 가지 예시가 있습니다."
L["Retrieved an ordered array of party/raid unit tokens."] = "파티/레이드 유닛 토큰의 정렬된 배열을 가져왔습니다."
L["Retrieved an ordered array of arena unit tokens."] = "아레나 유닛 토큰의 정렬된 배열을 가져왔습니다."
L["Register a callback function to run after FrameSort sorts frames."] = "프레임정렬이 프레임을 정렬한 후 실행할 콜백 함수를 등록합니다."
L["Retrieve an ordered array of party frames."] = "파티 프레임의 정렬된 배열을 가져옵니다."
L["Change a FrameSort setting."] = "프레임정렬 설정을 변경합니다."
L["View a full listing of all API methods on GitHub."] = "GitHub에서 모든 API 메서드의 전체 목록을 확인하세요."

-- # Help screen #
L["Help"] = "도움말"
L["Discord"] = "디스코드"
L["Need help with something?"] = "무엇인가 도움이 필요하신가요?"
L["Talk directly with the developer on Discord."] = "디스코드에서 개발자와 직접 대화하세요."

-- # Health Check screen -- #
L["Health Check"] = "상태 점검"
L["Try this"] = "이것을 시도해 보세요"
L["Any known issues with configuration or conflicting addons will be shown below."] = "구성 또는 충돌하는 애드온에 대한 알려진 문제가 아래에 표시됩니다."
L["N/A"] = "해당 없음"
L["Passed!"] = "합격!"
L["Failed"] = "실패"
L["(unknown)"] = "(알 수 없음)"
L["(user macro)"] = "(사용자 매크로)"
L["Using grouped layout for Cell raid frames"] = "Cell 레이드 프레임에 대해 그룹화된 레이아웃을 사용합니다."
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Cell -> 레이아웃에서 '결합된 그룹 (레이드)' 옵션을 확인해 주세요."
L["Can detect frames"] = "프레임 감지 가능"
L["FrameSort currently supports frames from these addons: %s."] = "프레임정렬은 현재 다음 애드온의 프레임을 지원합니다: %s."
L["Using Raid-Style Party Frames"] = "레이드 스타일의 파티 프레임 사용"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Blizzard 설정에서 '레이드 스타일의 파티 프레임 사용'을 활성화해 주세요."
L["Keep Groups Together setting disabled"] = "'그룹 함께 유지' 설정 비활성화됨"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "편집 모드를 통해 레이드 표시 모드를 '결합된 그룹' 옵션 중 하나로 변경해 주세요."
L["Disable the 'Keep Groups Together' raid profile setting."] = "'그룹 함께 유지' 레이드 프로필 설정을 비활성화해 주세요."
L["Only using Blizzard frames with Traditional mode"] = "전통 모드로만 Blizzard 프레임 사용"
L["Traditional mode can't sort your other frame addons: '%s'"] = "전통 모드는 다른 프레임 애드온 '%s'을 정렬할 수 없습니다."
L["Using Secure sorting mode when spacing is being used."] = "간격이 사용될 때 보안 정렬 모드 사용 중."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "전통 모드는 간격을 적용할 수 없습니다. 간격을 제거하거나 보안 정렬 방법을 사용하는 것을 고려해 보세요."
L["Blizzard sorting functions not tampered with"] = "Blizzard 정렬 기능이 변경되지 않음"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s"는 충돌을 일으킬 수 있으며, 비활성화하는 것을 고려해 보세요.'
L["No conflicting addons"] = "충돌하는 애드온 없음"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s"는 충돌을 일으킬 수 있으며, 비활성화하는 것을 고려해 보세요.'
L["Main tank and assist setting disabled"] = "주탱커 및 보조 설정 비활성화됨"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "옵션 -> 인터페이스 -> 레이드 프레임에서 '주탱커 및 보조 표시' 옵션을 비활성화해 주세요."
