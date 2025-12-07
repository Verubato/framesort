local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "koKR" then
    return
end

-- # Main Options screen #
L["FrameSort - %s"] = "프레임 정렬 - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "프레임 정렬이 제대로 작동하지 않을 수 있는 문제가 있습니다."
L["Please go to the Health Check panel to view more details."] = "자세한 내용을 보려면 건강 체크 패널로 가십시오."
L["Role"] = "역할"
L["Group"] = "그룹"
L["Alphabetical"] = "알파벳순"
L["Arena - 2v2"] = "아레나 - 2v2"
L["Arena - 3v3"] = "아레나 - 3v3"
L["Arena - 3v3 & 5v5"] = "아레나 - 3v3 & 5v5"
L["Enemy Arena (see addons panel for supported addons)"] = "적 아레나 (지원되는 애드온은 애드온 패널을 확인하세요)"
L["Dungeon (mythics, 5-mans, delves)"] = "던전 (신화, 5인, 탐색)"
L["Raid (battlegrounds, raids)"] = "레이드 (전장, 레이드)"
L["World (non-instance groups)"] = "세계 (비인스턴스 그룹)"
L["Player"] = "플레이어"
L["Sort"] = "정렬"
L["Top"] = "상단"
L["Middle"] = "중간"
L["Bottom"] = "하단"
L["Hidden"] = "숨김"
L["Group"] = "그룹"
L["Reverse"] = "역순"

-- # Sorting Method screen #
L["Sorting Method"] = "정렬 방법"
L["Secure"] = "안전한"
L["SortingMethod_Secure_Description"] = [[
각 개별 프레임의 위치를 조정하며 UI를 버그/잠금/오염하지 않습니다.
\n
장점:
 - 다른 애드온의 프레임을 정렬할 수 있습니다.
 - 프레임 간격을 적용할 수 있습니다.
 - 오염 없음 (블리자드의 UI 코드에 간섭하는 애드온을 위한 기술적 용어).
\n
단점:
 - 블리자드의 스파게티를 피하기 위한 불안정한 카드 집합 상태입니다.
 - WoW 패치와 함께 깨질 수 있으며 개발자를 미치게 만들 수 있습니다.
]]
L["Traditional"] = "전통적인"
L["SortingMethod_Traditional_Description"] = [[
이것은 애드온과 매크로가 10년 이상 사용해 온 표준 정렬 모드입니다.
블리자드의 내부 정렬 방법을 우리의 것으로 대체합니다.
이것은 'SetFlowSortFunction' 스크립트와 동일하지만 FrameSort 구성이 추가된 것입니다.
\n
장점:
 - 블리자드의 내부 정렬 방법을 활용하므로 더 안정적이고 신뢰할 수 있습니다.
\n
단점:
 - 블리자드의 파티 프레임만 정렬하며, 그 외에는 정렬되지 않습니다.
 - Lua 오류가 발생할 수 있으며 이는 정상이며 무시할 수 있습니다.
 - 프레임 간격을 적용할 수 없습니다.
]]
L["Please reload after changing these settings."] = "이 설정을 변경한 후 다시 로드하십시오."
L["Reload"] = "다시 로드"

-- # Ordering screen #
L["Ordering"] = "정렬"
L["Specify the ordering you wish to use when sorting by role."] = "역할에 따라 정렬할 때 사용하려는 순서를 지정하십시오."
L["Tanks"] = "탱커"
L["Healers"] = "힐러"
L["Casters"] = "시전사"
L["Hunters"] = "사냥꾼"
L["Melee"] = "근접"

-- # Auto Leader screen #
L["Auto Leader"] = "자동 리더"
L["Auto promote healers to leader in solo shuffle."] = "솔로 셔플에서 힐러를 자동으로 리더로 승격합니다."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "왜냐하면 힐러가 목표 마커 아이콘을 구성하고 자신의 기호에 맞게 파티1/2를 재배열할 수 있기 때문입니다."
L["Enabled"] = "활성화"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "대상 지정"
L["Target frame 1 (top frame)"] = "대상 프레임 1 (상단 프레임)"
L["Target frame 2"] = "대상 프레임 2"
L["Target frame 3"] = "대상 프레임 3"
L["Target frame 4"] = "대상 프레임 4"
L["Target frame 5"] = "대상 프레임 5"
L["Target bottom frame"] = "하단 프레임을 대상으로 지정"
L["Target 1 frame above bottom"] = "하단 위의 1번 프레임을 대상으로 지정"
L["Target 2 frames above bottom"] = "하단 위의 2개의 프레임을 대상으로 지정"
L["Target 3 frames above bottom"] = "하단 위의 3개의 프레임을 대상으로 지정"
L["Target 4 frames above bottom"] = "하단 위의 4개의 프레임을 대상으로 지정"
L["Target frame 1's pet"] = "대상 프레임 1의 애완동물"
L["Target frame 2's pet"] = "대상 프레임 2의 애완동물"
L["Target frame 3's pet"] = "대상 프레임 3의 애완동물"
L["Target frame 4's pet"] = "대상 프레임 4의 애완동물"
L["Target frame 5's pet"] = "대상 프레임 5의 애완동물"
L["Target enemy frame 1"] = "적 프레임 1을 대상으로 지정"
L["Target enemy frame 2"] = "적 프레임 2를 대상으로 지정"
L["Target enemy frame 3"] = "적 프레임 3을 대상으로 지정"
L["Target enemy frame 1's pet"] = "적 프레임 1의 애완동물을 대상으로 지정"
L["Target enemy frame 2's pet"] = "적 프레임 2의 애완동물을 대상으로 지정"
L["Target enemy frame 3's pet"] = "적 프레임 3의 애완동물을 대상으로 지정"
L["Focus enemy frame 1"] = "적 프레임 1에 집중"
L["Focus enemy frame 2"] = "적 프레임 2에 집중"
L["Focus enemy frame 3"] = "적 프레임 3에 집중"
L["Cycle to the next frame"] = "다음 프레임으로 전환"
L["Cycle to the previous frame"] = "이전 프레임으로 전환"
L["Target the next frame"] = "다음 프레임을 대상으로 지정"
L["Target the previous frame"] = "이전 프레임을 대상으로 지정"

-- # Keybindings screen #
L["Keybindings"] = "키 바인딩"
L["Keybindings_Description"] = [[
프레임 정렬 키 바인딩을 표준 WoW 키 바인딩 영역에서 찾을 수 있습니다.
\n
키 바인딩은 무엇에 유용한가요?
비주얼적으로 정렬된 표현을 통해 플레이어를 타겟팅하는 데 유용합니다. 그들이 파티 위치 (파티1/2/3 등)로 지정되기보다는요.
\n
예를 들어, 역할에 따라 정렬된 5인 던전 그룹은 다음과 같습니다:
  - 탱커, 파티3
  - 힐러, 플레이어
  - DPS, 파티1
  - DPS, 파티4
  - DPS, 파티2
\n
보시다시피 그들의 시각적 표현은 실제 파티 위치와 다르기 때문에 타겟팅이 혼란스러워집니다.
파티1을 타겟팅하면 위치 3의 DPS 플레이어가 타겟팅됩니다. 탱커는 아닙니다.
\n
프레임 정렬 키 바인딩은 파티 번호가 아닌 시각적 프레임 위치에 따라 타겟팅합니다.
따라서 '프레임 1'을 타겟팅하면 탱커, '프레임 2'는 힐러, '프레임 3'은 위치 3의 DPS가 됩니다.
]]

-- # Macros screen # --
L["Macros"] = "매크로"
L["FrameSort has found %d |4macro:macros; to manage."] = "프레임 정렬에서 관리할 %d |4매크로:매크로;를 찾았습니다."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "프레임 정렬은 '#FrameSort' 헤더가 포함된 매크로 내의 변수를 동적으로 업데이트합니다."
L["Below are some examples on how to use this."] = "다음은 이를 사용하는 방법에 대한 몇 가지 예입니다."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists] 성역의 축복]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] 해제]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] 그림자 걸음;
/cast [@placeholder] 차단;]]

L["Example %d"] = "예시 %d"
L["Discord Bot Blurb"] = [[
매크로를 만드는 데 도움이 필요하신가요?
\n
프레임 정렬 디스코드 서버로 가서 우리의 AI 지원 매크로 봇을 사용하세요!
\n
매크로 봇 채널에서 '@매크로 봇'과 함께 질문을 입력하면 됩니다.
]]

-- # Macro Variables screen # --
L["Macro Variables"] = "매크로 변수"
L["The first DPS that's not you."] = "당신이 아닌 첫 번째 DPS."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "숫자를 추가하여 N번째 대상을 선택합니다. 예: DPS2는 두 번째 DPS를 선택합니다."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "변수는 대소문자를 구분하지 않으므로 'fRaMe1', 'Dps', 'enemyhealer' 등 모두 작동합니다."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "매크로 문자 수를 줄여야 하나요? 줄임말을 사용하여 줄이세요:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = '"X"를 사용하여 프레임 정렬에게 @unit 선택기를 무시하도록 지시하십시오:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] 주문;]]

-- # Spacing screen #
L["Spacing"] = "간격"
L["Add some spacing between party, raid, and arena frames."] = "파티, 레이드 및 아레나 프레임 사이에 간격을 추가합니다."
L["This only applies to Blizzard frames."] = "이것은 블리자드 프레임에만 적용됩니다."
L["Party"] = "파티"
L["Raid"] = "레이드"
L["Group"] = "그룹"
L["Horizontal"] = "수평"
L["Vertical"] = "수직"

-- # Addons screen #
L["Addons"] = "애드온"
L["Addons_Supported_Description"] = [[
프레임 정렬은 다음을 지원합니다:
\n
  - 블리자드: 파티, 레이드, 아레나.
\n
  - 엘뷰아이: 파티.
\n
  - sArena: 아레나.
\n
  - 글라디우스: 아레나.
\n
  - 글라디우스엑스: 파티, 아레나.
\n
  - 셀: 파티, 레이드 (결합된 그룹을 사용할 때만).
\n
  - 그림자 유닛 프레임: 파티, 아레나.
\n
  - 그리드2: 파티, 레이드.
\n
  - 배틀그라운드적 적들: 파티, 아레나.
\n
  - 글래디: 아레나.
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "프레임 정렬을 당신의 애드온, 스크립트 및 약한 오라에 통합하고 싶으신가요?"
L["Here are some examples."] = "여기 몇 가지 예시가 있습니다."
L["Retrieved an ordered array of party/raid unit tokens."] = "파티/레이드 유닛 토큰의 정렬된 배열을 가져왔습니다."
L["Retrieved an ordered array of arena unit tokens."] = "아레나 유닛 토큰의 정렬된 배열을 가져왔습니다."
L["Register a callback function to run after FrameSort sorts frames."] = "프레임 정렬이 프레임을 정렬한 후에 실행할 콜백 함수를 등록합니다."
L["Retrieve an ordered array of party frames."] = "파티 프레임의 정렬된 배열을 가져옵니다."
L["Change a FrameSort setting."] = "프레임 정렬 설정을 변경합니다."
L["View a full listing of all API methods on GitHub."] = "GitHub의 모든 API 메서드 목록을 보십시오."

-- # Discord screen #
L["Discord"] = "디스코드"
L["Need help with something?"] = "무언가 도움이 필요하신가요?"
L["Talk directly with the developer on Discord."] = "디스코드에서 개발자와 직접 대화하십시오."

-- # Health Check screen -- #
L["Health Check"] = "건강 체크"
L["Try this"] = "이것을 시도하십시오"
L["Any known issues with configuration or conflicting addons will be shown below."] = "구성 또는 충돌 애드온과 관련된 알려진 문제가 아래에 표시됩니다."
L["N/A"] = "해당 없음"
L["Passed!"] = "합격!"
L["Failed"] = "실패"
L["(unknown)"] = "(알 수 없음)"
L["(user macro)"] = "(사용자 매크로)"
L["Using grouped layout for Cell raid frames"] = "셀 레이드 프레임에 대해 그룹화된 레이아웃 사용 중"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = "셀 -> 레이아웃에서 '결합된 그룹 (레이드)' 옵션을 확인하십시오."
L["Can detect frames"] = "프레임을 감지할 수 있습니다"
L["FrameSort currently supports frames from these addons: %s"] = "프레임 정렬은 현재 다음 애드온의 프레임을 지원합니다: %s"
L["Using Raid-Style Party Frames"] = "레이드 스타일의 파티 프레임 사용 중"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings"] = "블리자드 설정에서 '레이드 스타일의 파티 프레임 사용'을 활성화하십시오"
L["Keep Groups Together setting disabled"] = "그룹을 함께 유지 설정이 비활성화됨"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = "편집 모드를 통해 레이드 디스플레이 모드를 '결합된 그룹' 옵션 중 하나로 변경하십시오"
L["Disable the 'Keep Groups Together' raid profile setting."] = "'그룹을 함께 유지' 레이드 프로필 설정을 비활성화하십시오."
L["Only using Blizzard frames with Traditional mode"] = "전통적인 모드에서 블리자드 프레임만 사용"
L["Traditional mode can't sort your other frame addons: '%s'"] = "전통적인 모드는 다른 프레임 애드온 '%s'을 정렬할 수 없습니다."
L["Using Secure sorting mode when spacing is being used"] = "간격이 사용될 때 안전한 정렬 모드 사용 중"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] = "전통적인 모드는 간격을 적용할 수 없으니 간격을 제거하거나 안전한 정렬 방법을 사용하는 것을 고려하십시오."
L["Blizzard sorting functions not tampered with"] = "블리자드 정렬 함수가 변경되지 않음"
L['"%s" may cause conflicts, consider disabling it'] = '"%s"가 충돌을 일으킬 수 있으니 비활성화하는 것을 고려하십시오.'
L["No conflicting addons"] = "충돌하는 애드온 없음"
L["Main tank and assist setting disabled"] = "주 탱커 및 도움 설정 비활성화됨"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames"] = "옵션 -> 인터페이스 -> 레이드 프레임에서 '주 탱커 및 도움 표시' 옵션을 비활성화하십시오."

-- # Log Screen -- #
L["Log"] = "로그"
L["FrameSort log to help with diagnosing issues."] = "문제 진단에 도움이 되는 프레임 정렬 로그."
