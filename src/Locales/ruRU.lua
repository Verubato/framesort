local _, addon = ...
local L = addon.Locale

L["FrameSort"] = "СортировкаФреймов"

-- # Main Options screen #
L["FrameSort - %s"] = "СортировкаФреймов - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Есть проблемы, которые могут помешать правильной работе СортировкаФреймов."
L["Please go to the Health Check panel to view more details."] = "Пожалуйста, перейдите на панель проверки состояния, чтобы узнать больше деталей."
L["Role"] = "Роль"
L["Group"] = "Группа"
L["Alpha"] = "Альфа"
L["party1 > party2 > partyN > partyN+1"] = "party1 > party2 > partyN > partyN+1"
L["tank > healer > dps"] = "танк > хилер > дд"
L["NameA > NameB > NameZ"] = "ИмяA > ИмяB > ИмяZ"
L["healer > tank > dps"] = "хилер > танк > дд"
L["healer > dps > tank"] = "хилер > дд > танк"
L["tank > healer > dps"] = "танк > хилер > дд"
L["Arena - 2v2"] = "Арена - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 и 5v5"
L["Arena - %s"] = "Арена - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "Вражеская Арена (см. панель аддонов для поддерживаемых аддонов)"
L["Dungeon (mythics, 5-mans)"] = "Подземелье (мифики, 5-чел.)"
L["Raid (battlegrounds, raids)"] = "Рейд (поля сражений, рейды)"
L["World (non-instance groups)"] = "Мир (группы вне инстансов)"
L["Player:"] = "Игрок:"
L["Top"] = "Верх"
L["Middle"] = "Середина"
L["Bottom"] = "Низ"
L["Hidden"] = "Скрыто"
L["Group"] = "Группа"
L["Role"] = "Роль"
L["Alpha"] = "Альфа"
L["Reverse"] = "Обратный порядок"

-- # Sorting Method screen #
L["Sorting Method"] = "Метод сортировки"
L["Secure"] = "Безопасный"
L["SortingMethod_Secure_Description"] = [[
Настраивает положение каждого отдельного фрейма и не вызывает ошибок/блокировок/повреждений интерфейса.
\n
Плюсы:
 - Можно сортировать фреймы из других аддонов.
 - Можно настроить расстояние между фреймами.
 - Нет повреждений (технический термин для аддонов, мешающих коду интерфейса Blizzard).
\n
Минусы:
 - Сложная структура, которая может сломаться при обновлениях WoW и привести разработчика в бешенство.
 - Может сломаться с патчами WoW и вызвать безумие у разработчика.
]]
L["Traditional"] = "Традиционный"
L["SortingMethod_Secure_Traditional"] = [[
Это стандартный метод сортировки, который использовался аддонами и макросами более 10 лет.
Он заменяет внутренний метод сортировки Blizzard на наш собственный.
Это то же самое, что и скрипт 'SetFlowSortFunction', но с настройками СортировкаФреймов.
\n
Плюсы:
 - Более стабильный и надежный, так как использует внутренние методы сортировки Blizzard.
\n
Минусы:
 - Сортирует только фреймы группы Blizzard, больше ничего.
 - Может вызывать ошибки Lua, что нормально и их можно игнорировать.
 - Невозможно применить расстояние между фреймами.
]]
L["Please reload after changing these settings."] = "Пожалуйста, перезагрузите после изменения этих настроек."
L["Reload"] = "Перезагрузить"

-- # Role Ordering screen #
L["Role Ordering"] = "Порядок ролей"
L["Specify the ordering you wish to use when sorting by role."] = "Укажите порядок, который вы хотите использовать при сортировке по ролям."
L["Tank > Healer > DPS"] = "Танк > Хилер > ДД"
L["Healer > Tank > DPS"] = "Хилер > Танк > ДД"
L["Healer > DPS > Tank"] = "Хилер > ДД > Танк"

-- # Auto Leader screen #
L["Auto Leader"] = "Авто Лидер"
L["Auto promote healers to leader in solo shuffle."] = "Автоматически повышать хилеров до лидера в соло мешанине."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Зачем? Чтобы хилеры могли настраивать иконки целей и изменять порядок party1/2 по своему усмотрению."
L["Enabled"] = "Включено"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Целеполагание"
L["Target frame 1 (top frame)"] = "Целевой фрейм 1 (верхний фрейм)"
L["Target frame 2"] = "Целевой фрейм 2"
L["Target frame 3"] = "Целевой фрейм 3"
L["Target frame 4"] = "Целевой фрейм 4"
L["Target frame 5"] = "Целевой фрейм 5"
L["Target bottom frame"] = "Целевой нижний фрейм"
L["Target frame 1's pet"] = "Питомец целевого фрейма 1"
L["Target frame 2's pet"] = "Питомец целевого фрейма 2"
L["Target frame 3's pet"] = "Питомец целевого фрейма 3"
L["Target frame 4's pet"] = "Питомец целевого фрейма 4"
L["Target frame 5's pet"] = "Питомец целевого фрейма 5"
L["Target enemy frame 1"] = "Целевой вражеский фрейм 1"
L["Target enemy frame 2"] = "Целевой вражеский фрейм 2"
L["Target enemy frame 3"] = "Целевой вражеский фрейм 3"
L["Target enemy frame 1's pet"] = "Питомец целевого вражеского фрейма 1"
L["Target enemy frame 2's pet"] = "Питомец целевого вражеского фрейма 2"
L["Target enemy frame 3's pet"] = "Питомец целевого вражеского фрейма 3"
L["Focus enemy frame 1"] = "Фокус на вражеском фрейме 1"
L["Focus enemy frame 2"] = "Фокус на вражеском фрейме 2"
L["Focus enemy frame 3"] = "Фокус на вражеском фрейме 3"
L["Cycle to the next frame"] = "Переключиться на следующий фрейм"
L["Cycle to the previous frame"] = "Переключиться на предыдущий фрейм"
L["Target the next frame"] = "Целевой следующий фрейм"
L["Target the previous frame"] = "Целевой предыдущий фрейм"

-- # Keybindings screen #
L["Keybindings"] = "Назначение клавиш"
L["Keybindings_Description"] = [[
Вы можете найти назначения клавиш FrameSort в стандартной области назначения клавиш WoW.
\n
Для чего полезны назначения клавиш?
Они полезны для целеполагания по визуальному расположению игроков, а не по их позиции в группе (party1/2/3/и т.д.)
\n
Например, представьте 5-чел. группу подземелья, отсортированную по ролям следующим образом:
  - Танк, party3
  - Хилер, игрок
  - ДД, party1
  - ДД, party4
  - ДД, party2
\n
Как видите, их визуальное расположение отличается от их фактической позиции в группе, что делает целеполагание запутанным.
Если вы выберете /target party1, то будет выбран ДД на позиции 3, а не танк.
\n
Назначения клавиш FrameSort будут выбирать цели на основе их визуальной позиции фрейма, а не номера в группе.
Так, цель 'Фрейм 1' выберет танка, 'Фрейм 2' — хилера, 'Фрейм 3' — ДД на 3-й позиции и так далее.
]]

-- # Macros screen # --
L["Macros"] = "Макросы"
L

["FrameSort has found %d|4macro:macros; to manage."] = "СортировкаФреймов нашла %d|4макрос:макроса; для управления."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'СортировкаФреймов будет динамически обновлять переменные внутри макросов, содержащих заголовок "#FrameSort".'
L["Below are some examples on how to use this."] = "Ниже приведены примеры того, как это использовать."

L["Macro_Example1"] = [[#showtooltip
#FrameSort МышьНаведение, Цель, Хилер
/cast [@mouseover,help][@target,help][@healer,exists] Благословение святого покровителя]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Фрейм1, Фрейм2, Игрок
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Рассеивание магии]]

L["Macro_Example3"] = [[#FrameSort ВражескийХилер, ВражескийХилер
/cast [@неважно] Шаг сквозь тень;
/cast [@заменитель] Пинок;]]

L["Example %d"] = "Пример %d"
L["Supported variables:"] = "Поддерживаемые переменные:"
L["The first DPS that's not you."] = "Первый ДД, который не является вами."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Добавьте номер, чтобы выбрать N-ую цель, напр., DPS2 выбирает 2-го ДД."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Переменные не чувствительны к регистру, поэтому 'fRaMe1', 'Dps', 'enemyhealer' и т.д. будут работать."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Нужно сохранить символы макроса? Используйте сокращения для их сокращения:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Используйте "X", чтобы указать СортировкаФреймов игнорировать селектор @unit:'
L["Skip_Example"] = [[
#FS X X ВражескийХилер
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Заклинание;]]

-- # Spacing screen #
L["Spacing"] = "Расстояние"
L["Add some spacing between party/raid frames."] = "Добавьте немного расстояния между фреймами группы/рейда."
L["This only applies to Blizzard frames."] = "Это относится только к фреймам Blizzard."
L["Party"] = "Группа"
L["Raid"] = "Рейд"
L["Group"] = "Группа"
L["Horizontal"] = "Горизонтальное"
L["Vertical"] = "Вертикальное"

-- # Addons screen #
L["Addons"] = "Аддоны"
L["Addons_Supported_Description"] = [[
СортировкаФреймов поддерживает следующее:
\n
Blizzard
 - Группа: да
 - Рейд: да
 - Арена: сломано (исправлю в конечном итоге).
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
 - Рейд: да, только при использовании объединенных групп.
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Хотите интегрировать СортировкаФреймов в ваши аддоны, скрипты и Weak Auras?"
L["Here are some examples."] = "Вот несколько примеров."
L["Retrieved an ordered array of party/raid unit tokens."] = "Получен упорядоченный массив токенов группы/рейда."
L["Retrieved an ordered array of arena unit tokens."] = "Получен упорядоченный массив токенов арены."
L["Register a callback function to run after FrameSort sorts frames."] = "Зарегистрируйте функцию обратного вызова для запуска после того, как СортировкаФреймов отсортирует фреймы."
L["Retrieve an ordered array of party frames."] = "Получите упорядоченный массив фреймов группы."
L["Change a FrameSort setting."] = "Измените настройку СортировкаФреймов."
L["View a full listing of all API methods on GitHub."] = "Просмотрите полный список всех методов API на GitHub."

-- # Help screen #
L["Help"] = "Помощь"
L["Discord"] = "Discord"
L["Need help with something?"] = "Нужна помощь?"
L["Talk directly with the developer on Discord."] = "Общайтесь напрямую с разработчиком в Discord."

-- # Health Check screen -- #
L["Health Check"] = "Проверка состояния"
L["Try this"] = "Попробуйте это"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Любые известные проблемы с конфигурацией или конфликтующими аддонами будут показаны ниже."
L["N/A"] = "Н/Д"
L["Passed!"] = "Пройдено!"
L["Failed"] = "Неудача"
L["(unknown)"] = "(неизвестно)"
L["(user macro)"] = "(пользовательский макрос)"
L["Using grouped layout for Cell raid frames"] = "Использование сгруппированного макета для рейдовых фреймов Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Пожалуйста, проверьте опцию 'Объединенные группы (Рейд)' в Cell -> Макеты."
L["Can detect frames"] = "Может обнаруживать фреймы"
L["FrameSort currently supports frames from these addons: %s."] = "СортировкаФреймов в настоящее время поддерживает фреймы из этих аддонов: %s."
L["Using Raid-Style Party Frames"] = "Использование фреймов группы в стиле рейда"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Пожалуйста, включите 'Использовать фреймы группы в стиле рейда' в настройках Blizzard."
L["Keep Groups Together setting disabled"] = "Настройка 'Держать группы вместе' отключена"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Измените режим отображения рейда на один из вариантов 'Объединенные группы' через Режим редактирования."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Отключите настройку профиля рейда 'Держать группы вместе'."
L["Only using Blizzard frames with Traditional mode"] = "Используются только фреймы Blizzard в традиционном режиме"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Традиционный режим не может сортировать ваши другие аддоны фреймов: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Использование безопасного режима сортировки при использовании расстояния."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "Традиционный режим не может применить расстояние, рассмотрите возможность его удаления или использования безопасного метода сортировки."
L["Blizzard sorting functions not tampered with"] = "Функции сортировки Blizzard не были изменены"
L['"%s" may cause conflicts, consider disabling it.'] = '«%s» может вызвать конфликты, рассмотрите возможность его отключения.'
L["No conflicting addons"] = "Нет конфликтующих аддонов"
L['"%s" may cause conflicts, consider disabling it.'] = '«%s» может вызвать конфликты, рассмотрите возможность его отключения.'
L["Main tank and assist setting disabled"] = "Настройка главного танка и помощника отключена"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Пожалуйста, отключите опцию 'Отображать главного танка и помощника' в Опции -> Интерфейс -> Рейдовые фреймы."
