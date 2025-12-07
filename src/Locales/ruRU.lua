local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "ruRU" then
    return
end

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Есть некоторые проблемы, которые могут помешать правильной работе FrameSort."
L["Please go to the Health Check panel to view more details."] = "Пожалуйста, перейдите на панель проверки состояния, чтобы увидеть больше деталей."
L["Role"] = "Роль"
L["Group"] = "Группа"
L["Alphabetical"] = "Алфавитный"
L["Arena - 2v2"] = "Арена - 2 на 2"
L["Arena - 3v3"] = "Арена - 3 на 3"
L["Arena - 3v3 & 5v5"] = "Арена - 3 на 3 и 5 на 5"
L["Enemy Arena (see addons panel for supported addons)"] = "Враждебная арена (см. панель аддонов для поддерживаемых аддонов)"
L["Dungeon (mythics, 5-mans, delves)"] = "Подземелья (мифические, на 5 человек, погружения)"
L["Raid (battlegrounds, raids)"] = "Рейд (поля боя, рейды)"
L["World (non-instance groups)"] = "Мир (группы вне инстансов)"
L["Player"] = "Игрок"
L["Sort"] = "Сортировать"
L["Top"] = "Вверх"
L["Middle"] = "Средний"
L["Bottom"] = "Вниз"
L["Hidden"] = "Скрытый"
L["Group"] = "Группа"
L["Reverse"] = "Обратный"

-- # Sorting Method screen #
L["Sorting Method"] = "Метод сортировки"
L["Secure"] = "Безопасный"
L["SortingMethod_Secure_Description"] = [[
Регулирует позицию каждого отдельного фрейма и не вызывает сбоев/блокировок интерфейса.
\n
Плюсы:
 - Может сортировать фреймы от других аддонов.
 - Позволяет применять расстояние между фреймами.
 - Без сбоев (технический термин для аддонов, мешающих коду интерфейса Blizzard).
\n
Минусы:
 - Хрупкая ситуация, которую нужно обойти во избежание нареканий к коду Blizzard.
 - Может сломаться с патчами WoW и довести разработчика до безумия.
]]
L["Traditional"] = "Традиционный"
L["SortingMethod_Traditional_Description"] = [[
Это стандартный метод сортировки, который аддоны и макросы использовали более 10 лет.
Он заменяет внутренний метод сортировки Blizzard на наш собственный.
Это то же самое, что и скрипт 'SetFlowSortFunction', но с конфигурацией FrameSort.
\n
Плюсы:
 - Более стабильный/надежный, так как использует внутренние методы сортировки Blizzard.
\n
Минусы:
 - Сортирует только фреймы группы Blizzard, ничего больше.
 - Будет вызывать ошибки Lua, что нормально и может быть проигнорировано.
 - Нельзя применять расстояние между фреймами.
]]
L["Please reload after changing these settings."] = "Пожалуйста, перезагрузите после изменения этих настроек."
L["Reload"] = "Перезагрузить"

-- # Ordering screen #
L["Ordering"] = "Упорядочивание"
L["Specify the ordering you wish to use when sorting by role."] = "Укажите порядок, который вы хотите использовать при сортировке по роли."
L["Tanks"] = "Танки"
L["Healers"] = "Исцеляющие"
L["Casters"] = "Заклинатели"
L["Hunters"] = "Охотники"
L["Melee"] = "Ближний бой"

-- # Auto Leader screen #
L["Auto Leader"] = "Авто Лидер"
L["Auto promote healers to leader in solo shuffle."] = "Авто продвижение исцеляющих до лидера в соло шифте."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Почему? Чтобы исцелители могли настраивать значки маркера цели и переупорядочивать party1/2 по своему усмотрению."
L["Enabled"] = "Включено"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Прицеливание"
L["Target frame 1 (top frame)"] = "Целевой фрейм 1 (верхний фрейм)"
L["Target frame 2"] = "Целевой фрейм 2"
L["Target frame 3"] = "Целевой фрейм 3"
L["Target frame 4"] = "Целевой фрейм 4"
L["Target frame 5"] = "Целевой фрейм 5"
L["Target bottom frame"] = "Целевой нижний фрейм"
L["Target 1 frame above bottom"] = "Целевой 1 фрейм выше нижнего"
L["Target 2 frames above bottom"] = "Целевой 2 фрейма выше нижнего"
L["Target 3 frames above bottom"] = "Целевой 3 фрейма выше нижнего"
L["Target 4 frames above bottom"] = "Целевой 4 фрейма выше нижнего"
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
L["Focus enemy frame 1"] = "Фокус на вражеский фрейм 1"
L["Focus enemy frame 2"] = "Фокус на вражеский фрейм 2"
L["Focus enemy frame 3"] = "Фокус на вражеский фрейм 3"
L["Cycle to the next frame"] = "Переход к следующему фрейму"
L["Cycle to the previous frame"] = "Переход к предыдущему фрейму"
L["Target the next frame"] = "Целевой следующий фрейм"
L["Target the previous frame"] = "Целевой предыдущий фрейм"

-- # Keybindings screen #
L["Keybindings"] = "Назначения клавиш"
L["Keybindings_Description"] = [[
Вы можете найти назначения клавиш FrameSort в стандартной области назначений клавиш WoW.
\n
Для чего полезны назначения клавиш?
Они полезны для прицеливания на игроков по их визуально упорядоченному представлению, а не по их
позиции в группе (party1/2/3 и т.д.)
\n
Например, представьте группу подземелья на 5 человек, отсортированную по ролям, которая выглядит следующим образом:
  - Танки, party3
  - Исцелитель, игрок
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Как видно, их визуальное представление отличается от их фактической позиции в группе, что
делает прицеливание запутанным.
Если вы используете /target party1, то это будет целить в DPS игрока на позиции 3, а не в танка.
\n
Названия клавиш FrameSort будут прицеливаться на основе их визуального положения фрейма, а не номера группы.
Поэтому прицел на 'Фрейм 1' будет целить на Танка, 'Фрейм 2' на исцелителя, 'Фрейм 3' на DPS на месте 3 и так далее.
]]

-- # Macros screen # --
L["Macros"] = "Макросы"
L["FrameSort has found %d |4macro:macros; to manage."] = "FrameSort нашел %d |4макрос:макроса; для управления."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "FrameSort будет динамически обновлять переменные внутри макросов, которые содержат заголовок '#FrameSort'."
L["Below are some examples on how to use this."] = "Ниже приведены некоторые примеры, как это использовать."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists] Благословение укрытия]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Устранение]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] Шаг в тень;
/cast [@placeholder] Пинок;]]

L["Example %d"] = "Пример %d"
L["Discord Bot Blurb"] = [[
Нужна помощь с созданием макроса? 
\n
Загляните на сервер Discord FrameSort и воспользуйтесь нашим AI-ботом для макросов!
\n
Просто '@Macro Bot' с вашим вопросом в канале макробота.
]]

-- # Macro Variables screen # --
L["Macro Variables"] = "Переменные макросов"
L["The first DPS that's not you."] = "Первый DPS, который не вы."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Добавьте номер, чтобы выбрать N-ую цель, например, DPS2 выбирает 2-го DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Переменные не чувствительны к регистру, поэтому 'fRaMe1', 'Dps', 'enemyhealer' и т.д. будут работать."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Нужна экономия на символах макросов? Используйте сокращения, чтобы их укоротить:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Используйте "X", чтобы сказать FrameSort игнорировать селектор @unit:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Заклинание;]]

-- # Spacing screen #
L["Spacing"] = "Расстояние"
L["Add some spacing between party, raid, and arena frames."] = "Добавьте немного расстояния между фреймами группы, рейда и арены."
L["This only applies to Blizzard frames."] = "Это относится только к фреймам Blizzard."
L["Party"] = "Группа"
L["Raid"] = "Рейд"
L["Group"] = "Группа"
L["Horizontal"] = "Горизонтально"
L["Vertical"] = "Вертикально"

-- # Addons screen #
L["Addons"] = "Аддоны"
L["Addons_Supported_Description"] = [[
FrameSort поддерживает следующие аддоны:
\n
  - Blizzard: группа, рейд, арена.
\n
  - ElvUI: группа.
\n
  - sArena: арена.
\n
  - Gladius: арена.
\n
  - GladiusEx: группа, арена.
\n
  - Cell: группа, рейд (только при использовании объединенных групп).
\n
  - Shadowed Unit Frames: группа, арена.
\n
  - Grid2: группа, рейд.
\n
  - BattleGroundEnemies: группа, арена.
\n
  - Gladdy: арена.
\n
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Хотите интегрировать FrameSort в свои аддоны, скрипты и Weak Auras?"
L["Here are some examples."] = "Вот несколько примеров."
L["Retrieved an ordered array of party/raid unit tokens."] = "Получен упорядоченный массив токенов юнитов группы/рейда."
L["Retrieved an ordered array of arena unit tokens."] = "Получен упорядоченный массив токенов юнитов арены."
L["Register a callback function to run after FrameSort sorts frames."] = "Зарегистрируйте функцию обратного вызова для выполнения после того, как FrameSort отсортирует фреймы."
L["Retrieve an ordered array of party frames."] = "Получите упорядоченный массив фреймов группы."
L["Change a FrameSort setting."] = "Изменить настройку FrameSort."
L["View a full listing of all API methods on GitHub."] = "Просмотр полного списка всех методов API на GitHub."

-- # Discord screen #
L["Discord"] = "Discord"
L["Need help with something?"] = "Нужна помощь с чем-то?"
L["Talk directly with the developer on Discord."] = "Поговорите напрямую с разработчиком в Discord."

-- # Health Check screen -- #
L["Health Check"] = "Проверка состояния"
L["Try this"] = "Попробуйте это"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Любые известные проблемы с конфигурацией или конфликтующие аддоны будут показаны ниже."
L["N/A"] = "Не применимо"
L["Passed!"] = "Пройдено!"
L["Failed"] = "Неуспешно"
L["(unknown)"] = "(неизвестно)"
L["(user macro)"] = "(макрос пользователя)"
L["Using grouped layout for Cell raid frames"] = "Используется сгруппированная компоновка для фреймов рейда Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = "Пожалуйста, проверьте вариант 'Объединенные группы (рейд)' в Cell -> Макеты"
L["Can detect frames"] = "Может обнаружить фреймы"
L["FrameSort currently supports frames from these addons: %s"] = "FrameSort в настоящее время поддерживает фреймы от следующих аддонов: %s"
L["Using Raid-Style Party Frames"] = "Использование Рейд-стилевых фреймов группы"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings"] = "Пожалуйста, включите 'Использовать рейд-стилевые фреймы группы' в настройках Blizzard"
L["Keep Groups Together setting disabled"] = "Настройка 'Сохранять группы вместе' отключена"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = "Измените режим отображения рейда на один из вариантов 'Объединенные группы' через режим редактирования"
L["Disable the 'Keep Groups Together' raid profile setting."] = "Отключите настройку 'Сохранять группы вместе' для профиля рейда."
L["Only using Blizzard frames with Traditional mode"] = "Используются только фреймы Blizzard с традиционным режимом"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Традиционный режим не может сортировать ваши другие фреймы аддонов: '%s'"
L["Using Secure sorting mode when spacing is being used"] = "Используется безопасный режим сортировки, когда применяется расстояние"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] = "Традиционный режим не может применять расстояние, рассмотрите возможность удаления расстояния или использования безопасного метода сортировки"
L["Blizzard sorting functions not tampered with"] = "Функции сортировки Blizzard не были затронуты"
L['"%s" may cause conflicts, consider disabling it'] = '"%s" может вызвать конфликты, рассмотрите возможность отключения'
L["No conflicting addons"] = "Нет конфликтующих аддонов"
L["Main tank and assist setting disabled"] = "Настройка главного танка и ассистента отключена"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames"] = "Пожалуйста, отключите опцию 'Отображать главного танка и ассистента' в Опции -> Интерфейс -> Рейдовые фреймы"

-- # Log Screen -- #
L["Log"] = "Журнал"
L["FrameSort log to help with diagnosing issues."] = "Журнал FrameSort для помощи в диагностике проблем."
