local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "deDE" then
    return
end

L["FrameSort"] = "RahmenSortieren"

-- # Main Options screen #
L["FrameSort - %s"] = "RahmenSortieren - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Es gibt einige Probleme, die verhindern könnten, dass RahmenSortieren korrekt funktioniert."
L["Please go to the Health Check panel to view more details."] = "Bitte gehen Sie zum Gesundheitscheck-Panel, um weitere Details anzuzeigen."
L["Role"] = "Rolle"
L["Group"] = "Gruppe"
L["Alpha"] = "Alpha"
L["party1 > party2 > partyN > partyN+1"] = "party1 > party2 > partyN > partyN+1"
L["tank > healer > dps"] = "Tank > Heiler > DPS"
L["NameA > NameB > NameZ"] = "NameA > NameB > NameZ"
L["healer > tank > dps"] = "Heiler > Tank > DPS"
L["healer > dps > tank"] = "Heiler > DPS > Tank"
L["tank > healer > dps"] = "Tank > Heiler > DPS"
L["Arena - 2v2"] = "Arena - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
L["Arena - %s"] = "Arena - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "Feindliche Arena (siehe Addons-Panel für unterstützte Addons)"
L["Dungeon (mythics, 5-mans)"] = "Dungeon (Mythics, 5-Spieler)"
L["Raid (battlegrounds, raids)"] = "Schlachtzug (Schlachtfelder, Raids)"
L["World (non-instance groups)"] = "Welt (Nicht-Instanz-Gruppen)"
L["Player:"] = "Spieler:"
L["Top"] = "Oben"
L["Middle"] = "Mitte"
L["Bottom"] = "Unten"
L["Hidden"] = "Versteckt"
L["Group"] = "Gruppe"
L["Role"] = "Rolle"
L["Alpha"] = "Alpha"
L["Reverse"] = "Umkehren"

-- # Sorting Method screen #
L["Sorting Method"] = "Sortiermethode"
L["Secure"] = "Sicher"
L["SortingMethod_Secure_Description"] = [[
Passt die Position jedes einzelnen Rahmens an und blockiert/sperrt/nicht den Blizzard-UI-Code.
\n
Vorteile:
 - Kann Rahmen von anderen Addons sortieren.
 - Kann Abstände zwischen Rahmen anwenden.
 - Keine Verschmutzung (technischer Begriff für Addons, die den Blizzard-UI-Code beeinflussen).
\n
Nachteile:
 - Fragile Situation, um Probleme mit Blizzard-Code zu vermeiden.
 - Kann durch WoW-Patches kaputtgehen und den Entwickler verrückt machen.
]]
L["Traditional"] = "Traditionell"
L["SortingMethod_Secure_Traditional"] = [[
Dies ist der Standard-Sortiermodus, den Addons und Makros seit über 10 Jahren verwenden.
Ersetzt die interne Sortiermethode von Blizzard durch unsere.
Dies ist dasselbe wie das Skript 'SetFlowSortFunction', aber mit der RahmenSortieren-Einstellung.
\n
Vorteile:
 - Stabiler/zuverlässiger, da die internen Sortiermethoden von Blizzard genutzt werden.
\n
Nachteile:
 - Sortiert nur die Blizzard-Gruppenrahmen, nichts weiter.
 - Kann Lua-Fehler verursachen, die normal sind und ignoriert werden können.
 - Kann keine Abstände zwischen Rahmen anwenden.
]]
L["Please reload after changing these settings."] = "Bitte laden Sie die Benutzeroberfläche neu, nachdem Sie diese Einstellungen geändert haben."
L["Reload"] = "Neu laden"

-- # Role Ordering screen #
L["Role Ordering"] = "Rollenordnung"
L["Specify the ordering you wish to use when sorting by role."] = "Geben Sie die Reihenfolge an, die Sie beim Sortieren nach Rolle verwenden möchten."
L["Tank > Healer > DPS"] = "Tank > Heiler > DPS"
L["Healer > Tank > DPS"] = "Heiler > Tank > DPS"
L["Healer > DPS > Tank"] = "Heiler > DPS > Tank"

-- # Auto Leader screen #
L["Auto Leader"] = "Auto-Leder"
L["Auto promote healers to leader in solo shuffle."] = "Heiler automatisch zum Anführer im Solo-Sortieren erheben."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Warum? Damit Heiler Zielmarkierungs-Symbole konfigurieren und party1/2 nach ihren Wünschen neu anordnen können."
L["Enabled"] = "Aktiviert"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Zielen"
L["Target frame 1 (top frame)"] = "Ziele den Rahmen 1 (oberster Rahmen)"
L["Target frame 2"] = "Ziele den Rahmen 2"
L["Target frame 3"] = "Ziele den Rahmen 3"
L["Target frame 4"] = "Ziele den Rahmen 4"
L["Target frame 5"] = "Ziele den Rahmen 5"
L["Target bottom frame"] = "Ziele den unteren Rahmen"
L["Target frame 1's pet"] = "Ziele das Haustier von Rahmen 1"
L["Target frame 2's pet"] = "Ziele das Haustier von Rahmen 2"
L["Target frame 3's pet"] = "Ziele das Haustier von Rahmen 3"
L["Target frame 4's pet"] = "Ziele das Haustier von Rahmen 4"
L["Target frame 5's pet"] = "Ziele das Haustier von Rahmen 5"
L["Target enemy frame 1"] = "Ziele den feindlichen Rahmen 1"
L["Target enemy frame 2"] = "Ziele den feindlichen Rahmen 2"
L["Target enemy frame 3"] = "Ziele den feindlichen Rahmen 3"
L["Target enemy frame 1's pet"] = "Ziele das Haustier des feindlichen Rahmens 1"
L["Target enemy frame 2's pet"] = "Ziele das Haustier des feindlichen Rahmens 2"
L["Target enemy frame 3's pet"] = "Ziele das Haustier des feindlichen Rahmens 3"
L["Focus enemy frame 1"] = "Fokussiere den feindlichen Rahmen 1"
L["Focus enemy frame 2"] = "Fokussiere den feindlichen Rahmen 2"
L["Focus enemy frame 3"] = "Fokussiere den feindlichen Rahmen 3"
L["Cycle to the next frame"] = "Zum nächsten Rahmen wechseln"
L["Cycle to the previous frame"] = "Zum vorherigen Rahmen wechseln"
L["Target the next frame"] = "Ziele den nächsten Rahmen an"
L["Target the previous frame"] = "Ziele den vorherigen Rahmen an"

-- # Keybindings screen #
L["Keybindings"] = "Tastenkürzel"
L["Keybindings_Description"] = [[
Sie finden die Tastenkürzel von RahmenSortieren im Standardbereich der WoW-Tastenkürzel.
\n
Wozu sind Tastenkürzel nützlich?
Sie sind nützlich, um nach den visuellen Darstellungen der Spieler zu zielen, anstatt nach ihrer Position in der Gruppe (party1/2/3/etc.).
\n
Zum Beispiel, stellen Sie sich eine Dungeon-Gruppe mit 5 Personen vor, die nach Rolle sortiert ist und wie folgt aussieht:
  - Tank, party3
  - Heiler, Spieler
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Wie Sie sehen können, unterscheidet sich ihre visuelle Darstellung von ihrer tatsächlichen Position in der Gruppe, was das Zielen verwirrend macht.
Wenn Sie /target party1 verwenden, zielt es auf den DPS in Position 3 statt auf den Tank.
\n
Die Tastenkürzel von RahmenSortieren zielen basierend auf der visuellen Position des Rahmens statt auf der Gruppennummer.
Also zielt 'Rahmen 1' auf den Tank, 'Rahmen 2' auf den Heiler, 'Rahmen 3' auf den DPS in Position 3 und so weiter.
]]

-- # Macros screen # --
L["Macros"] = "Makros"
L["FrameSort has found %d|4macro:macros; to manage."] = "RahmenSortieren hat %d|4Makro:Makros; zum Verwalten gefunden."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "RahmenSortieren wird Variablen in Makros, die den Header '#RahmenSortieren' enthalten, dynamisch aktualisieren."
L["Below are some examples on how to use this."] = "Nachfolgend finden Sie einige Beispiele, wie dies verwendet werden kann."
L["Macro Example"] = "Makro Beispiel"
L["Macro_Example1"] = [[
#showtooltip
#FrameSort Tank, Heiler, DPS1
/cast [mod:shift,@tank][mod:alt,@healer][mod:ctrl,@dps1][] Heilung]]
L["Macro_Example2"] = [[
#showtooltip
#FrameSort Rahmen1, Rahmen2, Spieler
/cast [mod:ctrl,@rahmen1][mod:shift,@rahmen2][mod:alt,@spieler][] Dispel]]
L["Macro_Example3"] = [[
#FrameSort GegnerHeiler, GegnerHeiler
/cast [@egal] Schatten-Schritt;
/cast [@platzhalter] Tretmine;]]
L["Example %d"] = "Beispiel %d"
L["Supported variables:"] = "Unterstützte Variablen:"
L["The first DPS that's not you."] = "Der erste DPS, der nicht du bist."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Fügen Sie eine Zahl hinzu, um das N-te Ziel auszuwählen, z.B. DPS2 wählt den 2. DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Variablen sind nicht zwischen Groß- und Kleinschreibung unterschieden, daher funktionieren 'fRaMe1', 'Dps', 'enemyhealer' usw. alle."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Müssen Sie in Makro-Charakteren speichern? Verwenden Sie Abkürzungen, um sie zu verkürzen:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Verwenden Sie "X", um RahmenSortieren zu sagen, dass es einen @unit-Selektor ignorieren soll:'
L["Skip_Example"] = [[
#FS X X GegnerHeiler
/cast [mod:shift,@focus][@mouseover,harm][@gegnerheiler,exists][] Zauber;]]

-- # Spacing screen #
L["Spacing"] = "Abstand"
L["Add some spacing between party/raid frames."] = "Fügen Sie etwas Abstand zwischen den Gruppen-/Raid-Rahmen hinzu."
L["This only applies to Blizzard frames."] = "Dies gilt nur für Blizzard-Rahmen."
L["Party"] = "Gruppe"
L["Raid"] = "Schlachtzug"
L["Group"] = "Gruppe"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertikal"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
RahmenSortieren unterstützt die folgenden:
\n
Blizzard
 - Gruppe: ja
 - Raid: ja
 - Arena: kaputt (wir werden es irgendwann reparieren).
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
 - Raid: ja, nur bei Verwendung von kombinierten Gruppen.
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Möchten Sie RahmenSortieren in Ihre Addons, Skripte und Schwache Auren integrieren?"
L["Here are some examples."] = "Hier sind einige Beispiele."
L["Retrieved an ordered array of party/raid unit tokens."] = "Eine sortierte Reihe von Gruppen-/Raid-Einheitentoken abgerufen."
L["Retrieved an ordered array of arena unit tokens."] = "Eine sortierte Reihe von Arena-Einheitentoken abgerufen."
L["Register a callback function to run after FrameSort sorts frames."] = "Registrieren Sie eine Rückruffunktion, die ausgeführt wird, nachdem RahmenSortieren die Rahmen sortiert hat."
L["Retrieve an ordered array of party frames."] = "Eine sortierte Reihe von Gruppenrahmen abrufen."
L["Change a FrameSort setting."] = "Ändern Sie eine RahmenSortieren-Einstellung."
L["View a full listing of all API methods on GitHub."] = "Sehen Sie sich eine vollständige Liste aller API-Methoden auf GitHub an."

-- # Help screen #
L["Help"] = "Hilfe"
L["Discord"] = "Discord"
L["Need help with something?"] = "Brauchen Sie Hilfe bei etwas?"
L["Talk directly with the developer on Discord."] = "Sprechen Sie direkt mit dem Entwickler auf Discord."

-- # Health Check screen -- #
L["Health Check"] = "Gesundheitscheck"
L["Try this"] = "Versuchen Sie dies"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Bekannte Probleme mit der Konfiguration oder konfliktierenden Addons werden unten angezeigt."
L["N/A"] = "Nicht verfügbar"
L["Passed!"] = "Bestanden!"
L["Failed"] = "Fehlgeschlagen"
L["(unknown)"] = "(unbekannt)"
L["(user macro)"] = "(Benutzermakro)"
L["Using grouped layout for Cell raid frames"] = "Verwenden eines gruppierten Layouts für die Cell-Raid-Rahmen"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Bitte überprüfen Sie die Option 'Kombinierte Gruppen (Raid)' in Cell -> Layouts."
L["Can detect frames"] = "Kann Rahmen erkennen"
L["FrameSort currently supports frames from these addons: %s."] = "RahmenSortieren unterstützt derzeit Rahmen von diesen Addons: %s."
L["Using Raid-Style Party Frames"] = "Verwendung von Raid-Stil Gruppenrahmen"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Bitte aktivieren Sie 'Raid-Stil Gruppenrahmen verwenden' in den Blizzard-Einstellungen."
L["Keep Groups Together setting disabled"] = "Einstellung 'Gruppen zusammenhalten' deaktiviert"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Ändern Sie den Raid-Anzeigemodus auf eine der 'Kombinierten Gruppen'-Optionen über den Bearbeitungsmodus."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Deaktivieren Sie die Raid-Profil-Einstellung 'Gruppen zusammenhalten'."
L["Only using Blizzard frames with Traditional mode"] = "Verwendung von Blizzard-Rahmen nur im traditionellen Modus"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Der traditionelle Modus kann Ihre anderen Rahmen-Addons nicht sortieren: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Verwendung des sicheren Sortiermodus, wenn Abstand verwendet wird."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "Der traditionelle Modus kann Abstand nicht anwenden, ziehen Sie in Betracht, den Abstand zu entfernen oder die sichere Sortiermethode zu verwenden."
L["Blizzard sorting functions not tampered with"] = "Blizzard-Sortierfunktionen nicht manipuliert"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" kann Konflikte verursachen, ziehen Sie in Betracht, es zu deaktivieren.'
L["No conflicting addons"] = "Keine konfliktierenden Addons"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" kann Konflikte verursachen, ziehen Sie in Betracht, es zu deaktivieren.'
L["Main tank and assist setting disabled"] = "Einstellung für Haupttank und Assistent deaktiviert"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Bitte deaktivieren Sie die Option 'Haupttank und Assistent anzeigen' in Optionen -> Interface -> Raid-Rahmen."
