local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "deDE" then
    return
end

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Es gibt einige Probleme, die verhindern können, dass FrameSort korrekt funktioniert."
L["Please go to the Health Check panel to view more details."] = "Bitte gehen Sie zum Gesundheitscheck-Panel, um weitere Details anzuzeigen."
L["Role"] = "Rolle"
L["Group"] = "Gruppe"
L["Alphabetical"] = "Alphabetisch"
L["Arena - 2v2"] = "Arena - 2v2"
L["Arena - 3v3"] = "Arena - 3v3"
L["Arena - 3v3 & 5v5"] = "Arena - 3v3 & 5v5"
L["Enemy Arena (see addons panel for supported addons)"] = "Feindliche Arena (siehe Addons-Panel für unterstützte Addons)"
L["Dungeon (mythics, 5-mans, delves)"] = "Dungeon (Mythics, 5-Männer, Erkundungen)"
L["Raid (battlegrounds, raids)"] = "Schlachtzug (Schlachtfelder, Raids)"
L["World (non-instance groups)"] = "Welt (nicht-instanzierte Gruppen)"
L["Player"] = "Spieler"
L["Sort"] = "Sortieren"
L["Top"] = "Oben"
L["Middle"] = "Mitte"
L["Bottom"] = "Unten"
L["Hidden"] = "Versteckt"
L["Group"] = "Gruppe"
L["Reverse"] = "Umkehren"

-- # Sorting Method screen #
L["Sorting Method"] = "Sortiermethode"
L["Secure"] = "Sicher"
L["SortingMethod_Secure_Description"] = [[
Passt die Position jedes einzelnen Frames an und verursacht keine Fehler/Lock/Verunreinigung der Benutzeroberfläche.
\n
Vorteile:
 - Kann Frames von anderen Addons sortieren.
 - Kann Abstand zwischen Frames anwenden.
 - Keine Verunreinigung (technischer Begriff für Addons, die mit Blizzards UI-Code interferieren).
\n
Nachteile:
 - Zerbrechliche Karten-Situation, um mit Blizzards Chaos umzugehen.
 - Kann mit WoW-Patches kaputtgehen und den Entwickler verrückt machen.
]]
L["Traditional"] = "Traditionell"
L["SortingMethod_Traditional_Description"] = [[
Dies ist der Standard-Sortiermodus, den Addons und Makros seit mehr als 10 Jahren verwenden.
Es ersetzt die interne Blizzards Sortiermethode durch unsere eigene.
Dies ist dasselbe wie das 'SetFlowSortFunction'-Skript, aber mit FrameSort-Konfiguration.
\n
Vorteile:
 - Stabiler/zuverlässiger, da es Blizzards interne Sortiermethoden nutzt.
\n
Nachteile:
 - Sortiert nur Blizzards Party-Frames, nichts anderes.
 - Führt zu Lua-Fehlern, die normal sind und ignoriert werden können.
 - Kann keinen Abstand zwischen Frames anwenden.
]]
L["Please reload after changing these settings."] = "Bitte laden Sie nach Änderungen dieser Einstellungen neu."
L["Reload"] = "Neu laden"

-- # Ordering screen #
L["Ordering"] = "Reihenfolge"
L["Specify the ordering you wish to use when sorting by role."] = "Geben Sie die Reihenfolge an, die Sie beim Sortieren nach Rolle verwenden möchten."
L["Tanks"] = "Tank"
L["Healers"] = "Heiler"
L["Casters"] = "Zauberer"
L["Hunters"] = "Jäger"
L["Melee"] = "Nahkämpfer"

-- # Auto Leader screen #
L["Auto Leader"] = "Automatischer Anführer"
L["Auto promote healers to leader in solo shuffle."] = "Heiler automatisch zum Anführer im Solo-Mix befördern."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Warum? Damit Heiler Zielmarkierungssymbole konfigurieren und party1/2 nach ihren Vorlieben neu anordnen können."
L["Enabled"] = "Aktiviert"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Zielauswahl"
L["Target frame 1 (top frame)"] = "Zielrahmen 1 (oberer Rahmen)"
L["Target frame 2"] = "Zielrahmen 2"
L["Target frame 3"] = "Zielrahmen 3"
L["Target frame 4"] = "Zielrahmen 4"
L["Target frame 5"] = "Zielrahmen 5"
L["Target bottom frame"] = "Zielunterer Rahmen"
L["Target 1 frame above bottom"] = "Zielrahmen 1 über dem unteren"
L["Target 2 frames above bottom"] = "Zielrahmen 2 über dem unteren"
L["Target 3 frames above bottom"] = "Zielrahmen 3 über dem unteren"
L["Target 4 frames above bottom"] = "Zielrahmen 4 über dem unteren"
L["Target frame 1's pet"] = "Zielraums 1's Begleiter"
L["Target frame 2's pet"] = "Zielraums 2's Begleiter"
L["Target frame 3's pet"] = "Zielraums 3's Begleiter"
L["Target frame 4's pet"] = "Zielraums 4's Begleiter"
L["Target frame 5's pet"] = "Zielraums 5's Begleiter"
L["Target enemy frame 1"] = "Ziel feindlichen Rahmens 1"
L["Target enemy frame 2"] = "Ziel feindlichen Rahmens 2"
L["Target enemy frame 3"] = "Ziel feindlichen Rahmens 3"
L["Target enemy frame 1's pet"] = "Ziel feindlichen Rahmens 1's Begleiter"
L["Target enemy frame 2's pet"] = "Ziel feindlichen Rahmens 2's Begleiter"
L["Target enemy frame 3's pet"] = "Ziel feindlichen Rahmens 3's Begleiter"
L["Focus enemy frame 1"] = "Fokus feindlichen Rahmens 1"
L["Focus enemy frame 2"] = "Fokus feindlichen Rahmens 2"
L["Focus enemy frame 3"] = "Fokus feindlichen Rahmens 3"
L["Cycle to the next frame"] = "Durch den nächsten Rahmen wechseln"
L["Cycle to the previous frame"] = "Durch den vorherigen Rahmen wechseln"
L["Target the next frame"] = "Ziel den nächsten Rahmen"
L["Target the previous frame"] = "Ziel den vorherigen Rahmen"

-- # Keybindings screen #
L["Keybindings"] = "Tastenbelegung"
L["Keybindings_Description"] = [[
Sie finden die FrameSort-Tastenbelegungen im standardmäßigen WoW-Tastenbelegungsbereich.
\n
Wozu sind die Tastenbelegungen nützlich?
Sie sind nützlich, um Spieler anhand ihrer visuell geordneten Darstellung anstelle ihrer
Gruppenposition (party1/2/3/etc.) zu zielen.
\n
Stellen Sie sich zum Beispiel eine 5-Mann-Dungeon-Gruppe vor, die nach Rolle sortiert ist und wie folgt aussieht:
  - Tank, party3
  - Heiler, Spieler
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Wie Sie sehen können, unterscheidet sich ihre visuelle Darstellung von ihrer tatsächlichen Gruppenposition, was
das Zielen verwirrend macht.
Wenn Sie /target party1 eingeben, würde es den DPS-Spieler in Position 3 anvisieren, anstatt den Tank.
\n
FrameSort-Tastenbelegungen zielen basierend auf ihrer visuellen Rahmenposition und nicht auf der Gruppenummer.
Das Zielen auf „Rahmen 1“ zielt auf den Tank, „Rahmen 2“ auf den Heiler, „Rahmen 3“ auf den DPS in Platz 3 und so weiter.
]]

-- # Macros screen # --
L["Macros"] = "Makros"
L["FrameSort has found %d |4macro:macros; to manage."] = "FrameSort hat %d |4macro:Makros; gefunden, die verwaltet werden müssen."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort wird Variablen innerhalb von Makros, die den "#FrameSort"-Header enthalten, dynamisch aktualisieren.'
L["Below are some examples on how to use this."] = "Hier sind einige Beispiele, wie man das verwendet."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists] Segen der Zuflucht]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Befreiung]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@ganzegal] Schattensturz;
/cast [@placeholder] Stoß;]]

L["Example %d"] = "Beispiel %d"
L["Discord Bot Blurb"] = [[
Brauchen Sie Hilfe beim Erstellen eines Makros? 
\n
Gehen Sie zum FrameSort Discord-Server und verwenden Sie unseren KI-unterstützten Makrobots!
\n
Einfach '@Makro Bot' mit Ihrer Frage im makrobots-Kanal.
]]

-- # Macro Variables screen # --
L["Macro Variables"] = "Makrovariablen"
L["The first DPS that's not you."] = "Der erste DPS, der nicht du bist."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Fügen Sie eine Nummer hinzu, um das N-te Ziel auszuwählen, z. B. wählt DPS2 den 2. DPS aus."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Variablen sind nicht groß-/kleinschreibungsempfindlich, daher funktionieren 'fRaMe1', 'Dps', 'enemyhealer' usw. alle."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Müssen Sie bei Makrozeichen sparen? Verwenden Sie Abkürzungen, um sie zu verkürzen:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Verwenden Sie "X", um FrameSort zu sagen, dass es einen @unit-Selektor ignorieren soll:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Zauber;]]

-- # Spacing screen #
L["Spacing"] = "Abstand"
L["Add some spacing between party, raid, and arena frames."] = "Fügen Sie etwas Abstand zwischen Party-, Raid- und Arena-Rahmen hinzu."
L["This only applies to Blizzard frames."] = "Dies gilt nur für Blizzard-Rahmen."
L["Party"] = "Gruppe"
L["Raid"] = "Raid"
L["Group"] = "Gruppe"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertikal"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
FrameSort unterstützt die folgenden:
\n
  - Blizzard: Gruppe, Raid, Arena.
\n
  - ElvUI: Gruppe.
\n
  - sArena: Arena.
\n
  - Gladius: Arena.
\n
  - GladiusEx: Gruppe, Arena.
\n
  - Cell: Gruppe, Raid (nur bei Verwendung kombinierter Gruppen).
\n
  - Shadowed Unit Frames: Gruppe, Arena.
\n
  - Grid2: Gruppe, Raid.
\n
  - BattleGroundEnemies: Gruppe, Arena.
\n
  - Gladdy: Arena.
\n
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Möchten Sie FrameSort in Ihre Addons, Skripte und Schwachen Auren integrieren?"
L["Here are some examples."] = "Hier sind einige Beispiele."
L["Retrieved an ordered array of party/raid unit tokens."] = "Abgerufenes geordnetes Array von Gruppen-/Raid-Einheitentoken."
L["Retrieved an ordered array of arena unit tokens."] = "Abgerufenes geordnetes Array von Arena-Einheitentoken."
L["Register a callback function to run after FrameSort sorts frames."] = "Registrieren Sie eine Rückruffunktion, die ausgeführt wird, nachdem FrameSort die Rahmen sortiert."
L["Retrieve an ordered array of party frames."] = "Rufen Sie ein geordnetes Array von Gruppenrahmen ab."
L["Change a FrameSort setting."] = "Ändern Sie eine FrameSort-Einstellung."
L["View a full listing of all API methods on GitHub."] = "Sehen Sie sich eine vollständige Liste aller API-Methoden auf GitHub an."

-- # Discord screen #
L["Discord"] = "Discord"
L["Need help with something?"] = "Brauchen Sie Hilfe bei etwas?"
L["Talk directly with the developer on Discord."] = "Sprechen Sie direkt mit dem Entwickler auf Discord."

-- # Health Check screen -- #
L["Health Check"] = "Gesundheitscheck"
L["Try this"] = "Versuche das"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Alle bekannten Probleme mit der Konfiguration oder konfliktierenden Addons werden unten angezeigt."
L["N/A"] = "Nicht Verfügbar"
L["Passed!"] = "Bestanden!"
L["Failed"] = "Gescheitert"
L["(unknown)"] = "(unbekannt)"
L["(user macro)"] = "(Benutzermakro)"
L["Using grouped layout for Cell raid frames"] = "Verwenden des gruppierten Layouts für Cell-Raidrahmen"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = "Bitte überprüfen Sie die Option 'Kombinierte Gruppen (Raid)' in Cell -> Layouts"
L["Can detect frames"] = "Kann Rahmen erkennen"
L["FrameSort currently supports frames from these addons: %s"] = "FrameSort unterstützt derzeit Rahmen von diesen Addons: %s"
L["Using Raid-Style Party Frames"] = "Verwendung von Raid-Style Party-Rahmen"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings"] = "Bitte aktivieren Sie 'Verwenden Sie Raid-Style Party-Rahmen' in den Blizzard-Einstellungen"
L["Keep Groups Together setting disabled"] = "Einstellung 'Gruppen zusammenhalten' deaktiviert"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = "Ändern Sie den Raid-Anzeigemodus in eine der 'Kombinierten Gruppen'-Optionen über den Bearbeitungsmodus"
L["Disable the 'Keep Groups Together' raid profile setting."] = "Deaktivieren Sie die Einstellung 'Gruppen zusammenhalten' im Raid-Profil."
L["Only using Blizzard frames with Traditional mode"] = "Verwendet nur Blizzard-Rahmen im traditionellen Modus"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Der traditionelle Modus kann Ihre anderen Rahmen-Addons nicht sortieren: '%s'"
L["Using Secure sorting mode when spacing is being used"] = "Verwenden des sicheren Sortiermodus, wenn Abstand verwendet wird"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] = "Der traditionelle Modus kann keinen Abstand anwenden. Erwägen Sie, den Abstand zu entfernen oder die sichere Sortiermethode zu verwenden."
L["Blizzard sorting functions not tampered with"] = "Blizzard-Sortierfunktionen nicht verändert"
L['"%s" may cause conflicts, consider disabling it'] = '"%s" könnte Konflikte verursachen. Erwägen Sie, es zu deaktivieren.'
L["No conflicting addons"] = "Keine konfliktierenden Addons"
L["Main tank and assist setting disabled"] = "Einstellung Haupttank und Unterstützung deaktiviert"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames"] = "Bitte deaktivieren Sie die Option 'Haupttank und Unterstützung anzeigen' in Optionen -> Benutzeroberfläche -> Raid-Rahmen"

-- # Log Screen -- #
L["Log"] = "Protokoll"
L["FrameSort log to help with diagnosing issues."] = "FrameSort-Protokoll zur Hilfe bei der Diagnose von Problemen."
