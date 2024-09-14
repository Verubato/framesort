local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "koKR" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = nil
L["There are some issuse that may prevent FrameSort from working correctly."] = "프레임정렬이 정상적으로 작동하지 않도록 할 수 있는 몇 가지 문제가 있습니다."
L["Please go to the Health Check panel to view more details."] = "자세한 내용을 보려면 건강 점검 패널로 이동해 주세요."
L["Role"] = "역할"
L["Group"] = "그룹"
L["Alphabetical"] = "알파벳 순"
L["Arena - 2v2"] = "투기장 - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
L["Arena - %s"] = "투기장 - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "적의 투기장 (지원되는 애드온은 애드온 패널을 참조하세요)"
L["Dungeon (mythics, 5-mans)"] = "던전 (신화, 5인)"
L["Raid (battlegrounds, raids)"] = "레이드 (전장, 공격대)"
L["World (non-instance groups)"] = "월드 (비인스턴스 그룹)"
L["Player"] = "플레이어"
L["Sort"] = "정렬"
L["Top"] = "상단"
L["Middle"] = "중간"
L["Bottom"] = "하단"
L["Hidden"] = "숨김"
L["Group"] = "그룹"
L["Role"] = "역할"
L["Reverse"] = "역순"

-- # Sorting Method screen #
L["Sorting Method"] = "정렬 방법"
L["Secure"] = "안전한"
L["SortingMethod_Secure_Description"] = [[
각 개별 프레임의 위치를 조정하며 UI를 방해/잠금/변조하지 않습니다.
\n
장점:
 - 다른 애드온의 프레임도 정렬할 수 있습니다.
 - 프레임 간격을 적용할 수 있습니다.
 - 변조 없음 (Blizzard의 UI 코드와 간섭하는 애드온의 기술 용어).
\n
단점:
 - Blizzard의 복잡한 구조를 피하기 위한 여린 카드 집합 상황.
 - WoW 패치에 의해 파손될 수 있으며, 개발자를 미치게 만들 수 있습니다.
]]
L["Traditional"] = "전통적"
L["SortingMethod_Secure_Traditional"] = [[
10년 넘게 애드온과 매크로에서 사용해온 표준 정렬 모드입니다.
Blizzard의 내부 정렬 방법을 우리의 방법으로 대체합니다.
'SetFlowSortFunction' 스크립트와 동일하지만 FrameSort 구성과 함께 사용됩니다.
\n
장점:
 - Blizzard의 내부 정렬 방법을 활용하므로 더 안정적이고 신뢰할 수 있습니다.
\n
단점:
 - Blizzard 파티 프레임만 정렬하고 그 외에는 아닙니다.
 - Lua 오류가 발생하며 이는 정상이며 무시할 수 있습니다.
 - 프레임 간격을 적용할 수 없습니다.
]]
L["Please reload after changing these settings."] = "이 설정을 변경한 후 다시 로드해 주세요."
L["Reload"] = "다시 로드"

-- # Ordering screen #
L["Role"] = "역할"
L["Specify the ordering you wish to use when sorting by role."] = "역할로 정렬할 때 사용할 순서를 지정해 주세요."
L["Tanks"] = "탱커"
L["Healers"] = "힐러"
L["Casters"] = "시전자"
L["Hunters"] = "사냥꾼"
L["Melee"] = "근접"

-- # Auto Leader screen #
L["Auto Leader"] = "자동 리더"
L["Auto promote healers to leader in solo shuffle."] = "솔로 셔플에서 힐러를 자동으로 리더로 승격합니다."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "왜냐하면 힐러가 목표 마커 아이콘을 구성하고 파티 1/2의 순서를 자신의 선호에 맞게 재정렬할 수 있기 때문입니다."
L["Enabled"] = "활성화됨"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "대상 설정"
L["Target frame 1 (top frame)"] = "대상 프레임 1 (상단 프레임)"
L["Target frame 2"] = "대상 프레임 2"
L["Target frame 3"] = "대상 프레임 3"
L["Target frame 4"] = "대상 프레임 4"
L["Target frame 5"] = "대상 프레임 5"
L["Target bottom frame"] = "하단 대상 프레임"
L["Target frame 1's pet"] = "대상 프레임 1의 소환수"
L["Target frame 2's pet"] = "대상 프레임 2의 소환수"
L["Target frame 3's pet"] = "대상 프레임 3의 소환수"
L["Target frame 4's pet"] = "대상 프레임 4의 소환수"
L["Target frame 5's pet"] = "대상 프레임 5의 소환수"
L["Target enemy frame 1"] = "적 대상 프레임 1"
L["Target enemy frame 2"] = "적 대상 프레임 2"
L["Target enemy frame 3"] = "적 대상 프레임 3"
L["Target enemy frame 1's pet"] = "적 대상 프레임 1의 소환수"
L["Target enemy frame 2's pet"] = "적 대상 프레임 2의 소환수"
L["Target enemy frame 3's pet"] = "적 대상 프레임 3의 소환수"
L["Focus enemy frame 1"] = "적 대상 프레임 1에 초점"
L["Focus enemy frame 2"] = "적 대상 프레임 2에 초점"
L["Focus enemy frame 3"] = "적 대상 프레임 3에 초점"
L["Cycle to the next frame"] = "다음 프레임으로 전환"
L["Cycle to the previous frame"] = "이전 프레임으로 전환"
L["Target the next frame"] = "다음 프레임 선택"
L["Target the previous frame"] = "이전 프레임 선택"

-- # Keybindings screen #
L["Keybindings"] = "키 바인딩"
L["Keybindings_Description"] = [[
FrameSort 키 바인딩은 표준 WoW 키 바인딩 영역에서 찾을 수 있습니다.
\n
키 바인딩은 무엇을 위해 유용한가요?
시각적으로 정렬된 표현을 기준으로 플레이어를 겨냥하는 데 유용하며, 파티 위치 (파티1/2/3 등)를 기준으로 하지 않습니다.
\n
예를 들어, 역할에 따라 정렬된 5인 던전 그룹이 다음과 같이 보일 수 있습니다:
  - 탱커, 파티3
  - 힐러, 플레이어
  - DPS, 파티1
  - DPS, 파티4
  - DPS, 파티2
\n
보시다시피 그들의 시각적 표현이 실제 파티 위치와 다르기 때문에 겨냥하기가 혼란스러울 수 있습니다.
만약, /target party1을 입력한다면, 위치 3의 DPS 플레이어를 겨냥하게 됩니다.
\n
FrameSort 키 바인딩은 파티 번호가 아닌 시각적 프레임 위치를 기준으로 겨냥합니다.
따라서 '프레임 1'을 겨냥하면 탱커가 선택되고, '프레임 2'는 힐러가 선택되며, '프레임 3'은 위치 3의 DPS가 선택됩니다.
]]

-- # Macros screen # --
L["Macros"] = "매크로"
L["FrameSort has found %d|4macro:macros; to manage."] = "프레임정렬이 관리할 %d|4macro:macros;를 발견했습니다."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "프레임정렬은 '#FrameSort' 헤더가 포함된 매크로 내에서 변수를 동적으로 업데이트합니다."
L["Below are some examples on how to use this."] = "다음은 이를 사용하는 방법에 대한 몇 가지 예입니다."

L["Macro_Example1"] = [[#showtooltip
#FrameSort 마우스오버, 타겟, 힐러
/cast [@mouseover,help][@target,help][@healer,exists] 피난처의 축복]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort 프레임1, 프레임2, 플레이어
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] 해제]]

L["Macro_Example3"] = [[#FrameSort 적힐러, 적힐러
/cast [@상관없음] 그림자걸음;
/cast [@플레이스홀더] 차단;]]

L["Example %d"] = "예시 %d"
L["Supported variables:"] = "지원되는 변수:"
L["The first DPS that's not you."] = "당신이 아닌 첫 번째 DPS."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "숫자를 추가하여 N번째 대상을 선택하세요. 예: DPS2는 두 번째 DPS를 선택합니다."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "변수는 대소문자를 구분하지 않으므로 'fRaMe1', 'Dps', 'enemyhealer' 등 모두 작동합니다."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "매크로 문자에서 저장해야 하나요? 약어를 사용하여 줄이세요:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '프레임정렬에게 @unit 선택기를 무시하라고 지시하려면 "X"를 사용하세요:'
L["Skip_Example"] = [[
#FS X X 적힐러
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] 주문;]]

-- # Spacing screen #
L["Spacing"] = "간격"
L["Add some spacing between party/raid frames."] = "파티/레이드 프레임 사이에 간격을 추가합니다."
L["This only applies to Blizzard frames."] = "이것은 Blizzard 프레임에만 적용됩니다."
L["Party"] = "파티"
L["Raid"] = "레이드"
L["Group"] = "그룹"
L["Horizontal"] = "수평"
L["Vertical"] = "수직"

-- # Addons screen #
L["Addons"] = "애드온"
L["Addons_Supported_Description"] = [[
프레임정렬은 다음을 지원합니다:
\n
블리자드
 - 파티: 예
 - 레이드: 예
 - 투기장: 고장 (언젠가는 수정할 것입니다).
\n
ElvUI
 - 파티: 예
 - 레이드: 아니오
 - 투기장: 아니오
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
 - 레이드: 예, 단 결합된 그룹 사용 시.
\n
Shadowed Unit Frames
 - 파티: 예
 - 투기장: 예
\n
Grid2
 - 파티/레이드: 예
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "프레임정렬을 애드온, 스크립트 및 약한 오라에 통합하고 싶으신가요?"
L["Here are some examples."] = "여기 몇 가지 예가 있습니다."
L["Retrieved an ordered array of party/raid unit tokens."] = "파티/레이드 유닛 토큰의 정렬된 배열을 가져왔습니다."
L["Retrieved an ordered array of arena unit tokens."] = "투기장 유닛 토큰의 정렬된 배열을 가져왔습니다."
L["Register a callback function to run after FrameSort sorts frames."] = "프레임정렬이 프레임을 정렬한 후 실행할 콜백 함수를 등록하세요."
L["Retrieve an ordered array of party frames."] = "파티 프레임의 정렬된 배열을 가져옵니다."
L["Change a FrameSort setting."] = "프레임정렬 설정을 변경합니다."
L["View a full listing of all API methods on GitHub."] = "GitHub에서 모든 API 메서드의 전체 목록을 확인하세요."

-- # Help screen #
L["Help"] = "도움"
L["Discord"] = "디스코드"
L["Need help with something?"] = "무언가 도움이 필요하신가요?"
L["Talk directly with the developer on Discord."] = "디스코드에서 개발자와 직접 대화하세요."

-- # Health Check screen -- #
L["Health Check"] = "건강 점검"
L["Try this"] = "이렇게 해보세요"
L["Any known issues with configuration or conflicting addons will be shown below."] = "구성과 충돌하는 애드온에 관한 알려진 문제는 아래에 표시됩니다."
L["N/A"] = "해당 없음"
L["Passed!"] = "합격!"
L["Failed"] = "실패"
L["(unknown)"] = "(알 수 없음)"
L["(user macro)"] = "(사용자 매크로)"
L["Using grouped layout for Cell raid frames"] = "Cell 레이드 프레임을 그룹 레이아웃으로 사용 중"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Cell -> 레이아웃에서 '결합된 그룹(레이드)' 옵션을 확인해 주세요."
L["Can detect frames"] = "프레임 감지 가능"
L["FrameSort currently supports frames from these addons: %s."] = "프레임정렬은 현재 다음 애드온의 프레임을 지원합니다: %s."
L["Using Raid-Style Party Frames"] = "레이드 스타일 파티 프레임 사용 중"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "블리자드 설정에서 '레이드 스타일 파티 프레임 사용'을 활성화해 주세요."
L["Keep Groups Together setting disabled"] = "그룹 함께 유지 설정이 비활성화됨"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "편집 모드를 통해 레이드 표시 모드를 '결합된 그룹' 옵션 중 하나로 변경하세요."
L["Disable the 'Keep Groups Together' raid profile setting."] = "'그룹 함께 유지' 레이드 프로필 설정을 비활성화하세요."
L["Only using Blizzard frames with Traditional mode"] = "전통 모드에서만 블리자드 프레임 사용 중"
L["Traditional mode can't sort your other frame addons: '%s'"] = "전통 모드는 다른 프레임 애드온을 정렬할 수 없습니다: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "간격이 사용될 때 안전한 정렬 모드를 사용 중."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "전통 모드는 간격을 적용할 수 없습니다. 간격을 제거하거나 안전한 정렬 방법을 사용해 보세요."
L["Blizzard sorting functions not tampered with"] = "블리자드 정렬 기능이 변조되지 않았습니다."
L['"%s" may cause conflicts, consider disabling it.'] = '"%s"는 충돌을 일으킬 수 있으므로 비활성화하는 것을 고려하세요.'
L["No conflicting addons"] = "충돌하는 애드온 없음"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s"는 충돌을 일으킬 수 있으므로 비활성화하는 것을 고려하세요.'
L["Main tank and assist setting disabled"] = "주탱과 어시스트 설정이 비활성화됨"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "옵션 -> 인터페이스 -> 레이드 프레임에서 '주탱 및 어시스트 표시' 옵션을 비활성화해 주세요."
