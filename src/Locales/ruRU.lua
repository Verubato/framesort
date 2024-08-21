local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "ruRU" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Есть проблемы, которые могут помешать корректной работе FrameSort."
L["Please go to the Health Check panel to view more details."] = "Пожалуйста, перейдите на панель проверки состояния, чтобы узнать подробности."
L["Role"] = "Роль"
L["Group"] = "Группа"
L["Alpha"] = "Альфа"
L["party1 > party2 > partyN > partyN+1"] = "группа1 > группа2 > группаN > группаN+1"
L["tank > healer > dps"] = "танк > хилер > дд"
L["NameA > NameB > NameZ"] = "ИмяА > ИмяБ > ИмяЯ"
L["healer > tank > dps"] = "хилер > танк > дд"
L["healer > dps > tank"] = "хилер > дд > танк"
L["tank > healer > dps"] = "танк > хилер > дд"
L["Arena - 2v2"] = "Арена - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 и 5v5"
L["Arena - %s"] = "Арена - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "Вражеская арена (см. панель аддонов для поддерживаемых аддонов)"
L["Dungeon (mythics, 5-mans)"] = "Подземелье (мифики, группы по 5)"
L["Raid (battlegrounds, raids)"] = "Рейд (поля боя, рейды)"
L["World (non-instance groups)"] = "Мир (неинстансные группы)"
L["Player"] = "Игрок"
L["Sort"] = "Сортировка"
L["Top"] = "Верх"
L["Middle"] = "Середина"
L["Bottom"] = "Низ"
L["Hidden"] = "Скрыто"
L["Group"] = "Группа"
L["Role"] = "Роль"
L["Alpha"] = "Альфа"
L["Reverse"] = "Обратный"

-- # Sorting Method screen #
L["Sorting Method"] = "Метод сортировки"
L["Secure"] = "Безопасный"
L["SortingMethod_Secure_Description"] = [[
Настраивает положение каждого отдельного кадра и не вызывает сбоев/зависаний/ошибок интерфейса.
\n
Преимущества:
 - Может сортировать кадры из других аддонов.
 - Может применять интервалы между кадрами.
 - Без ошибок (технический термин для аддонов, которые мешают коду интерфейса Blizzard).
\n
Недостатки:
 - Хрупкое состояние обхода сложного кода Blizzard.
 - Может сломаться при обновлениях WoW и свести разработчика с ума.
]]
L["Traditional"] = "Традиционный"
L["SortingMethod_Secure_Traditional"] = [[
Это стандартный режим сортировки, используемый аддонами и макросами более 10 лет.
Он заменяет внутренний метод сортировки Blizzard на наш.
Это то же самое, что и сценарий 'SetFlowSortFunction', но с настройками FrameSort.
\n
Преимущества:
 - Более стабильный/надежный, так как использует внутренние методы сортировки Blizzard.
\n
Недостатки:
 - Сортирует только кадры группы Blizzard, ничего больше.
 - Может вызывать ошибки Lua, что нормально и может быть проигнорировано.
 - Не может применять интервалы между кадрами.
]]
L["Please reload after changing these settings."] = "Пожалуйста, перезагрузите интерфейс после изменения этих настроек."
L["Reload"] = "Перезагрузить"

-- # Role Ordering screen #
L["Role Ordering"] = "Порядок ролей"
L["Specify the ordering you wish to use when sorting by role."] = "Укажите порядок, который вы хотите использовать при сортировке по ролям."
L["Tank > Healer > DPS"] = "Танк > Хилер > ДД"
L["Healer > Tank > DPS"] = "Хилер > Танк > ДД"
L["Healer > DPS > Tank"] = "Хилер > ДД > Танк"

-- # Auto Leader screen #
L["Auto Leader"] = "Автолидер"
L["Auto promote healers to leader in solo shuffle."] = "Автоматически назначать хилеров лидерами в соло-смешивании."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Почему? Чтобы хилеры могли настроить иконки меток цели и упорядочить группу1/2 по своему предпочтению."
L["Enabled"] = "Включено"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Наведение"
L["Target frame 1 (top frame)"] = "Целевой кадр 1 (верхний кадр)"
L["Target frame 2"] = "Целевой кадр 2"
L["Target frame 3"] = "Целевой кадр 3"
L["Target frame 4"] = "Целевой кадр 4"
L["Target frame 5"] = "Целевой кадр 5"
L["Target bottom frame"] = "Целевой нижний кадр"
L["Target frame 1's pet"] = "Питомец целевого кадра 1"
L["Target frame 2's pet"] = "Питомец целевого кадра 2"
L["Target frame 3's pet"] = "Питомец целевого кадра 3"
L["Target frame 4's pet"] = "Питомец целевого кадра 4"
L["Target frame 5's pet"] = "Питомец целевого кадра 5"
L["Target enemy frame 1"] = "Целевой кадр врага 1"
L["Target enemy frame 2"] = "Целевой кадр врага 2"
L["Target enemy frame 3"] = "Целевой кадр врага 3"
L["Target enemy frame 1's pet"] = "Питомец целевого кадра врага 1"
L["Target enemy frame 2's pet"] = "Питомец целевого кадра врага 2"
L["Target enemy frame 3's pet"] = "Питомец целевого кадра врага 3"
L["Focus enemy frame 1"] = "Фокус кадра врага 1"
L["Focus enemy frame 2"] = "Фокус кадра врага 2"
L["Focus enemy frame 3"] = "Фокус кадра врага 3"
L["Cycle to the next frame"] = "Переключиться на следующий кадр"
L["Cycle to the previous frame"] = "Переключиться на предыдущий кадр"
L["Target the next frame"] = "Цель следующий кадр"
L["Target the previous frame"] = "Цель предыдущий кадр"

-- # Keybindings screen #
L["Keybindings"] = "Назначение клавиш"
L["Keybindings_Description"] = [[
Вы можете найти назначение клавиш для FrameSort в стандартном разделе назначения клавиш WoW.
\n
Для чего полезно назначение клавиш?
Они полезны для нацеливания на игроков по их визуальному порядку, а не по их положению в группе (группа1/2/3 и т.д.)
\n
Например, представьте себе группу из 5 человек в подземелье, отсортированную по ролям, которая выглядит следующим образом:
  - Танк, группа3
  - Хилер, игрок
  - ДД, группа1
  - ДД, группа4
  - ДД, группа2
\n
Как видите, их визуальное представление отличается от их реального положения в группе, что делает наведение путаным.
Если вы используете /цель группа1, она нацелится на ДД игрока в позиции 3, а не на танка.
\n
Клавиши FrameSort будут нацеливаться в соответствии с их визуальным положением на кадре, а не номером группы.
Таким образом, прицел 'Кадр 1' будет нацеливаться на Танка, 'Кадр 2' - на Хилера, 'Кадр 3' - на ДД в позиции 3, и так далее.
]]

-- # Macros screen # --
L["Macros"] = "Макросы"
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort нашел %d|4макрос:макроса; для управления."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort будет динамически обновлять переменные в макросах, содержащих заголовок "#FrameSort".'
L["Below are some examples on how to use this."] = "Ниже приведены несколько примеров того, как это использовать."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@хилер,exists] Благословение убежища]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@кадр1][mod:shift,@кадр2][mod:alt,@игрок][] Рассеивание]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@неважно] Шаг сквозь тень;
/cast [@замена] Пинок;]]

L["Example %d"] = "Пример %d"
L["Supported variables:"] = "Поддерживаемые переменные:"
L["The first DPS that's not you."] = "Первый ДД, который не вы."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Добавьте номер, чтобы выбрать N-ю цель, например, DPS2 выбирает второго ДД."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Переменные нечувствительны к регистру, поэтому 'fRaMe1', 'Dps', 'enemyhealer' и другие будут работать."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Нужно сохранить символы в макросе? Используйте сокращения для их сокращения:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Используйте "X", чтобы сказать FrameSort игнорировать селектор @единицы:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@вражескийхилер,exists][] Заклинание;]]

-- # Spacing screen #
L["Spacing"] = "Интервалы"
L["Add some spacing between party/raid frames."] = "Добавить интервалы между кадрами группы/рейда."
L["This only applies to Blizzard frames."] = "Это применяется только к кадрам Blizzard."
L["Party"] = "Группа"
L["Raid"] = "Рейд"
L["Group"] = "Группа"
L["Horizontal"] = "Горизонтально"
L["Vertical"] = "Вертикально"

-- # Addons screen #
L["Addons"] = "Аддоны"
L["Addons_Supported_Description"] = [[
FrameSort поддерживает следующее:
\n
Blizzard
 - Группа: да
 - Рейд: да
 - Арена: сломано (будет исправлено в будущем).
\n
ElvUI
 - Группа: да
 - Рейд: нет
 - Арена: нет
\n
sArena
 - Арена: да
\n
Gladius
 - Арена: да
 - Версия Bicmex: да
\n
GladiusEx
 - Группа: да
 - Арена: да
\n
Cell
 - Группа: да
 - Рейд: да, только при использовании комбинированных групп.
\n
Shadowed Unit Frames
 - Группа: да
 - Арена: да
\n
Grid2
 - Группа/рейд: да
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Хотите интегрировать FrameSort в свои аддоны, скрипты и Weak Auras?"
L["Here are some examples."] = "Вот несколько примеров."
L["Retrieved an ordered array of party/raid unit tokens."] = "Получен упорядоченный массив токенов группы/рейда."
L["Retrieved an ordered array of arena unit tokens."] = "Получен упорядоченный массив токенов арены."
L["Register a callback function to run after FrameSort sorts frames."] = "Зарегистрируйте функцию обратного вызова, которая будет выполнена после сортировки кадров FrameSort."
L["Retrieve an ordered array of party frames."] = "Получение упорядоченного массива кадров группы."
L["Change a FrameSort setting."] = "Изменить настройку FrameSort."
L["View a full listing of all API methods on GitHub."] = "Просмотреть полный список всех методов API на GitHub."

-- # Help screen #
L["Help"] = "Помощь"
L["Discord"] = "Дискорд"
L["Need help with something?"] = "Нужна помощь?"
L["Talk directly with the developer on Discord."] = "Общайтесь напрямую с разработчиком на Discord."

-- # Health Check screen -- #
L["Health Check"] = "Проверка состояния"
L["Try this"] = "Попробуйте это"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Любые известные проблемы с конфигурацией или конфликтующими аддонами будут показаны ниже."
L["N/A"] = "Н/Д"
L["Passed!"] = "Пройдено!"
L["Failed"] = "Неудачно"
L["(unknown)"] = "(неизвестно)"
L["(user macro)"] = "(пользовательский макрос)"
L["Using grouped layout for Cell raid frames"] = "Использование сгруппированного макета для рейдовых кадров Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Пожалуйста, проверьте опцию 'Объединенные группы (Рейд)' в Cell -> Макеты."
L["Can detect frames"] = "Может обнаруживать кадры"
L["FrameSort currently supports frames from these addons: %s."] = "FrameSort в настоящее время поддерживает кадры из этих аддонов: %s."
L["Using Raid-Style Party Frames"] = "Использование групповых кадров в стиле рейда"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Пожалуйста, включите 'Использовать групповые кадры в стиле рейда' в настройках Blizzard."
L["Keep Groups Together setting disabled"] = "Настройка 'Держать группы вместе' отключена"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Измените режим отображения рейда на одну из опций 'Объединенные группы' через режим редактирования."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Отключите настройку профиля рейда 'Держать группы вместе'."
L["Only using Blizzard frames with Traditional mode"] = "Использование только кадров Blizzard в традиционном режиме"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Традиционный режим не может сортировать ваши другие аддоны кадров: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Использование безопасного режима сортировки при использовании интервалов."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "Традиционный режим не может применять интервалы, рассмотрите возможность удаления интервалов или использования безопасного метода сортировки."
L["Blizzard sorting functions not tampered with"] = "Функции сортировки Blizzard не изменены"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" может вызвать конфликты, рассмотрите возможность его отключения.'
L["No conflicting addons"] = "Нет конфликтующих аддонов"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" может вызвать конфликты, рассмотрите возможность его отключения.'
L["Main tank and assist setting disabled"] = "Настройка 'Главный танк и ассист' отключена"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Пожалуйста, отключите опцию 'Отображать главного танка и ассиста' в Опции -> Интерфейс -> Рейдовые кадры."

