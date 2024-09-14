local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "ruRU" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = nil
L["There are some issuse that may prevent FrameSort from working correctly."] = "Есть некоторые проблемы, которые могут помешать корректной работе СортировкаФреймов."
L["Please go to the Health Check panel to view more details."] = "Пожалуйста, перейдите на панель проверки состояния, чтобы просмотреть дополнительные сведения."
L["Role"] = "Роль"
L["Group"] = "Группа"
L["Alphabetical"] = "Алфавитный"
L["Arena - 2v2"] = "Арена - 2 на 2"
L["3v3"] = "3 на 3"
L["3v3 & 5v5"] = "3 на 3 и 5 на 5"
-- %s is either "3v3" or "3v3 & 5v5"
L["Arena - %s"] = "Арена - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "Вражеская арена (см. панель дополнений для поддерживаемых дополнений)"
L["Dungeon (mythics, 5-mans)"] = "Подземелье (мифические, 5-ка)"
L["Raid (battlegrounds, raids)"] = "Рейд (поля боя, рейды)"
L["World (non-instance groups)"] = "Мир (группы вне инстансов)"
L["Player"] = "Игрок"
L["Sort"] = "Сортировать"
L["Top"] = "Верх"
L["Middle"] = "Середина"
L["Bottom"] = "Низ"
L["Hidden"] = "Скрыто"
L["Group"] = "Группа"
L["Role"] = "Роль"
L["Reverse"] = "Обратный"

-- # Sorting Method screen #
L["Sorting Method"] = "Метод сортировки"
L["Secure"] = "Защищенный"
L["SortingMethod_Secure_Description"] = [[
Регулирует положение каждого отдельного фрейма и не вызывает ошибок/блокировки/вмешательства в интерфейс.
\n
Плюсы:
 - Может сортировать фреймы от других дополнений.
 - Может применять интервалы между фреймами.
 - Без вмешательства (технический термин для дополнений, влияющих на код интерфейса Blizzard).
\n
Минусы:
 - Хрупкая конструкция, чтобы обойти сложности кода Blizzard.
 - Может ломаться с патчами WoW и вызывать сумасшествие у разработчика.
]]
L["Traditional"] = "Традиционный"
L["SortingMethod_Secure_Traditional"] = [[
Это стандартный режим сортировки, который дополнения и макросы используют более 10 лет.
Он заменяет внутренний метод сортировки Blizzard на наш собственный.
Это то же самое, что и скрипт 'SetFlowSortFunction', но с конфигурацией СортировкаФреймов.
\n
Плюсы:
 - Более стабильный/надежный, так как использует внутренние методы сортировки Blizzard."] = nil
\n
Минусы:
 - Сортирует только фреймы группы Blizzard, ничего больше.
 - Будет вызывать ошибки Lua, что нормально и можно игнорировать.
 - Не может применять интервалы между фреймами.
]]
L["Please reload after changing these settings."] = "Пожалуйста, перезагрузите после изменения этих настроек."
L["Reload"] = "Перезагрузить"

-- # Ordering screen #
L["Role"] = "Роль"
L["Specify the ordering you wish to use when sorting by role."] = "Укажите порядок, который вы хотите использовать при сортировке по роли."
L["Tanks"] = "Танки"
L["Healers"] = "Целители"
L["Casters"] = "Заклинатели"
L["Hunters"] = "Охотники"
L["Melee"] = "Ближний бой"

-- # Auto Leader screen #
L["Auto Leader"] = "Авто Лидер"
L["Auto promote healers to leader in solo shuffle."] = "Автоматически повышать целителей до лидеров в одиночном перемешивании."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Почему? Чтобы целители могли настраивать значки меток цели и изменять порядок party1/2 по своему усмотрению."
L["Enabled"] = "Включено"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Целеполагание"
L["Target frame 1 (top frame)"] = "Цель фрейма 1 (верхний фрейм)"
L["Target frame 2"] = "Цель фрейма 2"
L["Target frame 3"] = "Цель фрейма 3"
L["Target frame 4"] = "Цель фрейма 4"
L["Target frame 5"] = "Цель фрейма 5"
L["Target bottom frame"] = "Цель нижнего фрейма"
L["Target frame 1's pet"] = "Цель питомца фрейма 1"
L["Target frame 2's pet"] = "Цель питомца фрейма 2"
L["Target frame 3's pet"] = "Цель питомца фрейма 3"
L["Target frame 4's pet"] = "Цель питомца фрейма 4"
L["Target frame 5's pet"] = "Цель питомца фрейма 5"
L["Target enemy frame 1"] = "Цель вражеского фрейма 1"
L["Target enemy frame 2"] = "Цель вражеского фрейма 2"
L["Target enemy frame 3"] = "Цель вражеского фрейма 3"
L["Target enemy frame 1's pet"] = "Цель питомца вражеского фрейма 1"
L["Target enemy frame 2's pet"] = "Цель питомца вражеского фрейма 2"
L["Target enemy frame 3's pet"] = "Цель питомца вражеского фрейма 3"
L["Focus enemy frame 1"] = "Фокус на вражеский фрейм 1"
L["Focus enemy frame 2"] = "Фокус на вражеский фрейм 2"
L["Focus enemy frame 3"] = "Фокус на вражеский фрейм 3"
L["Cycle to the next frame"] = "Переключиться на следующий фрейм"
L["Cycle to the previous frame"] = "Переключиться на предыдущий фрейм"
L["Target the next frame"] = "Цель на следующий фрейм"
L["Target the previous frame"] = "Цель на предыдущий фрейм"

-- # Keybindings screen #
L["Keybindings"] = "Привязка клавиш"
L["Keybindings_Description"] = [[
Вы можете найти привязки клавиш СортировкаФреймов в стандартной области привязок клавиш WoW.
\n
Для чего полезны привязки клавиш?
Они полезны для целеполагания на игроков по их визуально упорядоченному представлению, а не по их
позиции в группе (party1/2/3 и т. д.)
\n
Например, представьте, что 5-ка в подземелье сортируется по ролям и выглядит следующим образом:
  - Танки, party3
  - Целитель, игрок
  - ДПС, party1
  - ДПС, party4
  - ДПС, party2
\n
Как вы видите, их визуальное представление отличается от их фактической позиции в группе, что
делает целеполагание запутанным.
Если вы напечатаете /target party1, то это будет целеустремление к ДПС игроку на позиции 3, а не к танку.
\n
Привязки клавиш СортировкаФреймов будут цель по их визуальной позиции фрейма, а не по номеру группы.
Поэтому целеустремление к 'Фрейму 1' будет целеустремлением к Танку, к 'Фрейму 2' к целителю, к 'Фрейму 3' к ДПС на позиции 3 и так далее.
]]

-- # Macros screen # --
L["Macros"] = "Макросы"
-- "|4macro:macros;" is a special command to pluralise the word "macro" to "macros" when %d is greater than 1
L["FrameSort has found %d|4macro:macros; to manage."] = "СортировкаФреймов нашла %d|4macro:macros; для управления."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "СортировкаФреймов будет динамически обновлять переменные в макросах, содержащих заголовок \"#СортировкаФреймов\"."
L["Below are some examples on how to use this."] = "Ниже приведены некоторые примеры, как это использовать."

L["Macro_Example1"] = [[#showtooltip
#FrameSort КурсорНаведения, Цель, Целитель
/cast [@mouseover,help][@target,help][@healer,exists] Благословение Убежища]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Фрейм1, Фрейм2, Игрок
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Рассеивание]]

L["Macro_Example3"] = [[#FrameSort ВражескийЦелитель, ВражескийЦелитель
/cast [@doesntmatter] ТеневоеШагание;
/cast [@placeholder] Удар;]]

-- %d is the number for example 1/2/3
L["Example %d"] = "Пример %d"
L["Supported variables:"] = "Поддерживаемые переменные:"
L["The first DPS that's not you."] = "Первый ДПС, который не вы."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Добавьте номер, чтобы выбрать N-ю цель, напр. ДПС2 выбирает 2-го ДПС."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Переменные не чувствительны к регистру, поэтому такие как 'fRaMe1', 'Dps', 'вражескийцелитель' и т. д. будут работать."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Нужно сэкономить на символах макроса? Используйте сокращения, чтобы сократить их:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = "Используйте \"X\", чтобы указать СортировкаФреймов игнорировать селектор @unit:"

L["Skip_Example"] = [[
#FS X X ВражескийЦелитель
/cast [mod:shift,@focus][@mouseover,harm][@вражескийцелитель,exists][] Заклинание;]]

-- # Spacing screen #
L["Spacing"] = "Интервал"
L["Add some spacing between party/raid frames."] = "Добавьте немного пространства между фреймами группы/рейда."
L["This only applies to Blizzard frames."] = "Это применимо только к рамкам Blizzard."
L["Party"] = "Группа"
L["Raid"] = "Рейд"
L["Group"] = "Группа"
L["Horizontal"] = "Горизонтально"
L["Vertical"] = "Вертикально"

-- # Addons screen #
L["Addons"] = "Дополнения"
L["Addons_Supported_Description"] = [[
СортировкаФреймов поддерживает следующие:
\n
Blizzard
 - Группа: да
 - Рейд: да
 - Арена: сломано (в конечном итоге починим).
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
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Хотите интегрировать СортировкаФреймов в ваши дополнения, скрипты и Слабые Ауры?"
L["Here are some examples."] = "Вот несколько примеров."
L["Retrieved an ordered array of party/raid unit tokens."] = "Получен упорядоченный массив токенов юнитов группы/рейда."
L["Retrieved an ordered array of arena unit tokens."] = "Получен упорядоченный массив токенов юнитов арены."
L["Register a callback function to run after FrameSort sorts frames."] = "Зарегистрируйте функцию обратного вызова для выполнения после сортировки фреймов СортировкаФреймов."
L["Retrieve an ordered array of party frames."] = "Получите упорядоченный массив фреймов группы."
L["Change a FrameSort setting."] = "Измените настройку СортировкаФреймов."
L["View a full listing of all API methods on GitHub."] = "Посмотрите полный список всех методов API на GitHub."

-- # Help screen #
L["Help"] = "Помощь"
L["Discord"] = "Дискорд"
L["Need help with something?"] = "Нужна помощь с чем-то?"
L["Talk directly with the developer on Discord."] = "Поговорите напрямую с разработчиком в Дискорде."

-- # Health Check screen -- #
L["Health Check"] = "Проверка состояния"
L["Try this"] = "Попробуйте это"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Любые известные проблемы с конфигурацией или конфликтующими дополнениями будут показаны ниже."
L["N/A"] = "Нет данных"
L["Passed!"] = "Пройдено!"
L["Failed"] = "Неудача"
L["(unknown)"] = "(неизвестно)"
L["(user macro)"] = "(пользовательский макрос)"
L["Using grouped layout for Cell raid frames"] = "Используется сгруппированный макет для рейдовых фреймов Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Пожалуйста, проверьте опцию 'Комбинированные группы (рейд)' в Cell -> Макеты."
L["Can detect frames"] = "Может обнаруживать фреймы"
L["FrameSort currently supports frames from these addons: %s."] = "СортировкаФреймов в настоящее время поддерживает фреймы от этих дополнений: %s."
L["Using Raid-Style Party Frames"] = "Используются рейдовые фреймы группы"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Пожалуйста, включите 'Использовать рейдовые фреймы группы' в настройках Blizzard."
L["Keep Groups Together setting disabled"] = "Настройка 'Держать группы вместе' отключена"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Измените режим отображения рейда на один из опций 'Комбинированные группы' через Режим редактирования."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Отключите настройку профиля рейда 'Держать группы вместе'."
L["Only using Blizzard frames with Traditional mode"] = "Используются только фреймы Blizzard с традиционным режимом"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Традиционный режим не может сортировать ваши другие дополнения для фреймов: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Используется защищенный режим сортировки, когда используется интервал."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "Традиционный режим не может применять интервалы, рассмотрите возможность удаления интервалов или использования защищенного метода сортировки."
L["Blizzard sorting functions not tampered with"] = "Функции сортировки Blizzard не нарушены"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" может вызывать конфликты, рассмотрите возможность его отключения.'
L["No conflicting addons"] = "Нет конфликтующих дополнений"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" может вызывать конфликты, рассмотрите возможность его отключения.'
L["Main tank and assist setting disabled"] = "Настройка основного танка и помощника отключена"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Пожалуйста, отключите опцию 'Показать основного танка и помощника' в Настройки -> Интерфейс -> Рейдовые фреймы."
