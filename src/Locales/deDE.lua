local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "deDE" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = nil
L["There are some issuse that may prevent FrameSort from working correctly."] = "Es gibt einige Probleme, die verhindern können, dass die Rahmensortierung korrekt funktioniert."
L["Please go to the Health Check panel to view more details."] = "Bitte gehen Sie zum Gesundheitscheck-Panel, um weitere Details zu sehen."
L["Role"] = "Rolle"
L["Group"] = "Gruppe"
L["Alphabetical"] = "Alphabetisch"
L["Arena - 2v2"] = "Arena - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
L["Arena - %s"] = "Arena - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "Feindliche Arena (siehe Addon-Panel für unterstützte Addons)"
L["Dungeon (mythics, 5-mans)"] = "Dungeon (Mythics, 5-Menschen)"
L["Raid (battlegrounds, raids)"] = "Raid (Schlachtfelder, Raids)"
L["World (non-instance groups)"] = "Welt (nicht-instanzierte Gruppen)"
L["Player"] = "Spieler"
L["Sort"] = "Sortieren"
L["Top"] = "Oben"
L["Middle"] = "Mitte"
L["Bottom"] = "Unten"
L["Hidden"] = "Versteckt"
L["Group"] = "Gruppe"
L["Role"] = "Rolle"
L["Reverse"] = "Umkehren"

-- # Sorting Method screen #
L["Sorting Method"] = "Sortiermethode"
L["Secure"] = "Sicher"
L["SortingMethod_Secure_Description"] = [[
Passt die Position jedes einzelnen Rahmens an und verursacht keinen Fehler/Lock/Beeinträchtigung der Benutzeroberfläche.
\n
Vorteile:
 - Kann Rahmen von anderen Addons sortieren.
 - Kann Rahmenabstände anwenden.
 - Keine Beeinträchtigung (technischer Begriff für Addons, die mit Blizzards UI-Code interferieren).
\n
Nachteile:
 - Fragile Situation, um Blizzards Spaghetti zu umgehen.
 - Kann bei WoW-Patches brechen und den Entwickler verrückt machen.
]]
L["Traditional"] = "Traditionell"
L["SortingMethod_Secure_Traditional"] = [[
Dies ist der Standard-Sortiermodus, den Addons und Makros seit über 10 Jahren verwenden.
Es ersetzt die interne Sortiermethode von Blizzard durch unsere eigene.
Dies ist dasselbe wie das 'SetFlowSortFunction'-Skript, aber mit der FrameSort-Konfiguration.
\n
Vorteile:
 - Stabiler/zuverlässiger, da es Blizzards interne Sortiermethoden nutzt.
\n
Nachteile:
 - Sortiert nur Blizzards Gruppenrahmen, nichts anderes.
 - Verursacht Lua-Fehler, was normal ist und ignoriert werden kann.
 - Kann keine Rahmenabstände anwenden.
]]
L["Please reload after changing these settings."] = "Bitte neu laden, nachdem Sie diese Einstellungen geändert haben."
L["Reload"] = "Neu laden"

-- # Ordering screen #
L["Role"] = "Rolle"
L["Specify the ordering you wish to use when sorting by role."] = "Geben Sie die Reihenfolge an, die Sie beim Sortieren nach Rolle verwenden möchten."
L["Tanks"] = "Tank"
L["Healers"] = "Heiler"
L["Casters"] = "Caster"
L["Hunters"] = "Jäger"
L["Melee"] = "Nahkämpfer"

-- # Auto Leader screen #
L["Auto Leader"] = "Automatischer Anführer"
L["Auto promote healers to leader in solo shuffle."] = "Heiler automatisch zum Anführer in Solo-Mischung befördern."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Warum? Damit Heiler Zielmarkierungssymbole konfigurieren und die Reihenfolge der Gruppe 1/2 nach ihren Wünschen anpassen können."
L["Enabled"] = "Aktiviert"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Zielauswahl"
L["Target frame 1 (top frame)"] = "Ziele Rahmen 1 (oberer Rahmen)"
L["Target frame 2"] = "Ziele Rahmen 2"
L["Target frame 3"] = "Ziele Rahmen 3"
L["Target frame 4"] = "Ziele Rahmen 4"
L["Target frame 5"] = "Ziele Rahmen 5"
L["Target bottom frame"] = "Ziele unteren Rahmen"
L["Target frame 1's pet"] = "Ziele das Haustier von Rahmen 1"
L["Target frame 2's pet"] = "Ziele das Haustier von Rahmen 2"
L["Target frame 3's pet"] = "Ziele das Haustier von Rahmen 3"
L["Target frame 4's pet"] = "Ziele das Haustier von Rahmen 4"
L["Target frame 5's pet"] = "Ziele das Haustier von Rahmen 5"
L["Target enemy frame 1"] = "Ziele feindlichen Rahmen 1"
L["Target enemy frame 2"] = "Ziele feindlichen Rahmen 2"
L["Target enemy frame 3"] = "Ziele feindlichen Rahmen 3"
L["Target enemy frame 1's pet"] = "Ziele das Haustier von feindlichem Rahmen 1"
L["Target enemy frame 2's pet"] = "Ziele das Haustier von feindlichem Rahmen 2"
L["Target enemy frame 3's pet"] = "Ziele das Haustier von feindlichem Rahmen 3"
L["Focus enemy frame 1"] = "Fokussiere feindlichen Rahmen 1"
L["Focus enemy frame 2"] = "Fokussiere feindlichen Rahmen 2"
L["Focus enemy frame 3"] = "Fokussiere feindlichen Rahmen 3"
L["Cycle to the next frame"] = "Zum nächsten Rahmen wechseln"
L["Cycle to the previous frame"] = "Zum vorherigen Rahmen wechseln"
L["Target the next frame"] = "Ziele den nächsten Rahmen"
L["Target the previous frame"] = "Ziele den vorherigen Rahmen"

-- # Keybindings screen #
L["Keybindings"] = "Tastenkombinationen"
L["Keybindings_Description"] = [[
Sie finden die FrameSort-Tastenkombinationen im Standard-WoW-Tastenkombinationsbereich.
\n
Wozu sind die Tastenkombinationen nützlich?
Sie sind nützlich, um Spieler nach ihrer visuell sortierten Darstellung auszuwählen, anstatt nach ihrer 
Gruppenposition (Gruppe 1/2/3/usw.)
\n
Zum Beispiel, stellen Sie sich eine 5-Mann-Dungeon-Gruppe vor, die nach Rolle sortiert ist und folgendermaßen aussieht:
  - Tank, Gruppe 3
  - Heiler, Spieler
  - DPS, Gruppe 1
  - DPS, Gruppe 4
  - DPS, Gruppe 2
\n
Wie Sie sehen können, unterscheidet sich ihre visuelle Darstellung von ihrer tatsächlichen Gruppenposition, was 
die Zielauswahl verwirrend macht.
Wenn Sie /target Gruppe 1 eingeben, würde es den DPS-Spieler in Position 3 anvisieren, anstatt den Tank.
\n
FrameSort-Tastenkombinationen wählen basierend auf ihrer visuellen Rahmenposition und nicht nach Gruppennummer aus.
Das Anvisieren von 'Rahmen 1' wird den Tank anvisieren, 'Rahmen 2' den Heiler, 'Rahmen 3' den DPS an Position 3 usw.
]]

-- # Macros screen # --
L["Macros"] = "Makros"
L["FrameSort has found %d|4macro:macros; to manage."] = "Die Rahmensortierung hat %d|4makro:makros; gefunden, die verwaltet werden müssen."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'Die Rahmensortierung wird Variablen innerhalb von Makros, die den "#FrameSort"-Header enthalten, dynamisch aktualisieren.'
L["Below are some examples on how to use this."] = "Hier sind einige Beispiele, wie man dies verwendet."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Ziel, Heiler
/cast [@mouseover,help][@target,help][@healer,exists] Segen der Zuflucht]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Rahmen1, Rahmen2, Spieler
/cast [mod:ctrl,@rahmen1][mod:shift,@rahmen2][mod:alt,@player][] Entfernen]]

L["Macro_Example3"] = [[#FrameSort FeindHeiler, FeindHeiler
/cast [@doesntmatter] Schatten Schritt;
/cast [@placeholder] Unterbrechen;]]

-- %d is the number for example 1/2/3
L["Example %d"] = "Beispiel %d"
L["Supported variables:"] = "Unterstützte Variablen:"
L["The first DPS that's not you."] = "Der erste DPS, der nicht Sie sind."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Fügen Sie eine Zahl hinzu, um das Nth-Ziel auszuwählen, z. B. wählt DPS2 den 2. DPS aus."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Variablen sind nicht fallempfindlich, daher funktionieren 'rahmen1', 'dps', 'feindheiler' usw. alle."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Müssen Sie bei Makrozeichenfolgen sparen? Verwenden Sie Abkürzungen, um sie zu verkürzen:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Verwenden Sie "X", um der Rahmensortierung zu sagen, dass sie einen @unit-Selector ignorieren soll:'
L["Skip_Example"] = [[
#FS X X FeindHeiler
/cast [mod:shift,@fokus][@mouseover,harm][@feindheiler,exists][] Zauber;]]

-- # Spacing screen #
L["Spacing"] = "Abstand"
L["Add some spacing between party/raid frames."] = "Fügen Sie etwas Abstand zwischen Gruppen/Raid-Rahmen hinzu."
L["This only applies to Blizzard frames."] = "Dies gilt nur für Blizzard-Rahmen."
L["Party"] = "Gruppe"
L["Raid"] = "Raid"
L["Group"] = "Gruppe"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertikal"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
Die Rahmensortierung unterstützt Folgendes:
\n
Blizzard
 - Gruppe: ja
 - Raid: ja
 - Arena: defekt (wird irgendwann behoben).
\n
ElvUI
 - Gruppe: ja
 - Raid: nein
 - Arena: nein
\n
sArena
 - Arena: ja
\n
Gladius
 - Arena: ja
 - Bicmex-Version: ja
\n
GladiusEx
 - Gruppe: ja
 - Arena: ja
\n
Cell
 - Gruppe: ja
 - Raid: ja, nur bei Verwendung kombinierter Gruppen.
\n
Shadowed Unit Frames
 - Gruppe: ja
 - Arena: ja
\n
Grid2
 - Gruppe/Raid: ja
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Möchten Sie die Rahmensortierung in Ihre Addons, Skripte und Schwache Auren integrieren?"
L["Here are some examples."] = "Hier sind einige Beispiele."
L["Retrieved an ordered array of party/raid unit tokens."] = "Abgerufen wurde ein geordnetes Array von Gruppen/Raid-Einheitentoken."
L["Retrieved an ordered array of arena unit tokens."] = "Abgerufen wurde ein geordnetes Array von Arena-Einheitentoken."
L["Register a callback function to run after FrameSort sorts frames."] = "Registrieren Sie eine Callback-Funktion, die ausgeführt wird, nachdem die Rahmensortierung Rahmen sortiert hat."
L["Retrieve an ordered array of party frames."] = "Ein geordnetes Array von Gruppenrahmen abrufen."
L["Change a FrameSort setting."] = "Ändern Sie eine FrameSort-Einstellung."
L["View a full listing of all API methods on GitHub."] = "Sehen Sie sich eine vollständige Liste aller API-Methoden auf GitHub an."

-- # Help screen #
L["Help"] = "Hilfe"
L["Discord"] = "Discord"
L["Need help with something?"] = "Brauchen Sie Hilfe bei etwas?"
L["Talk directly with the developer on Discord."] = "Sprechen Sie direkt mit dem Entwickler auf Discord."

-- # Health Check screen -- #
L["Health Check"] = "Gesundheitscheck"
L["Try this"] = "Versuchen Sie dies"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Alle bekannten Probleme mit der Konfiguration oder Konflikten mit Addons werden unten angezeigt."
L["N/A"] = "N/A"
L["Passed!"] = "Bestanden!"
L["Failed"] = "Fehlgeschlagen"
L["(unknown)"] = "(unbekannt)"
L["(user macro)"] = "(Benutzermakro)"
L["Using grouped layout for Cell raid frames"] = "Verwenden des gruppierten Layouts für Zellraid-Rahmen"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Bitte überprüfen Sie die Option 'Kombinierte Gruppen (Raid)' in Cell -> Layouts."
L["Can detect frames"] = "Kann Rahmen erkennen"
L["FrameSort currently supports frames from these addons: %s."] = "Die Rahmensortierung unterstützt derzeit Rahmen von diesen Addons: %s."
L["Using Raid-Style Party Frames"] = "Verwenden von Raid-Style Gruppenrahmen"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Bitte aktivieren Sie 'Raid-Style Gruppenrahmen verwenden' in den Blizzard-Einstellungen."
L["Keep Groups Together setting disabled"] = "Einstellung 'Gruppen zusammenhalten' deaktiviert"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Ändern Sie den Raid-Anzeigemodus zu einer der Optionen 'Kombinierte Gruppen' im Bearbeitungsmodus."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Deaktivieren Sie die Einstellung 'Gruppen zusammenhalten' im Raid-Profil."
L["Only using Blizzard frames with Traditional mode"] = "Verwenden nur der Blizzard-Rahmen im traditionellen Modus"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Der traditionelle Modus kann Ihre anderen Rahmenaddons nicht sortieren: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Verwenden des sicheren Sortiermodus, wenn Abstände verwendet werden."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "Der traditionelle Modus kann keine Abstände anwenden, ziehen Sie in Betracht, Abstände zu entfernen oder die sichere Sortiermethode zu verwenden."
L["Blizzard sorting functions not tampered with"] = "Blizzard-Sortierfunktionen nicht manipuliert"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" kann Konflikte verursachen, ziehen Sie in Betracht, es zu deaktivieren.'
L["No conflicting addons"] = "Keine konfliktreichen Addons"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" kann Konflikte verursachen, ziehen Sie in Betracht, es zu deaktivieren.'
L["Main tank and assist setting disabled"] = "Einstellung für Haupttank und Assist deaktiviert"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Bitte deaktivieren Sie die Option 'Haupttank und Assist anzeigen' in Optionen -> Schnittstelle -> Raid-Rahmen."
