local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "deDE" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Es gibt einige Probleme, die verhindern könnten, dass FrameSort korrekt funktioniert."
L["Please go to the Health Check panel to view more details."] = "Bitte gehen Sie zum Gesundheitscheck-Panel, um mehr Details zu sehen."
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
L["Enemy Arena (see addons panel for supported addons)"] = "Feindliche Arena (siehe Addon-Panel für unterstützte Addons)"
L["Dungeon (mythics, 5-mans)"] = "Dungeon (Mythics, 5-Spieler)"
L["Raid (battlegrounds, raids)"] = "Schlachtzug (Schlachtfelder, Raids)"
L["World (non-instance groups)"] = "Welt (Nicht-Instanz-Gruppen)"
L["Player"] = "Spieler"
L["Sort"] = "Sortieren"
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
Passt die Position jedes einzelnen Rahmens an und stört/lockt/vergiftet nicht die UI.
\n
Vorteile:
 - Kann Rahmen von anderen Addons sortieren.
 - Kann Rahmenabstände anwenden.
 - Kein Taint (technischer Begriff für Addons, die in Blizzards UI-Code eingreifen).
\n
Nachteile:
 - Fragiles Kartenhaus, um Blizzards Spaghetti zu umgehen.
 - Kann bei WoW-Patches brechen und den Entwickler in den Wahnsinn treiben.
]]
L["Traditional"] = "Traditionell"
L["SortingMethod_Secure_Traditional"] = [[
Dies ist der Standard-Sortiermodus, den Addons und Makros seit über 10 Jahren verwenden.
Er ersetzt die interne Blizzard-Sortiermethode durch unsere eigene.
Dies ist dasselbe wie das 'SetFlowSortFunction'-Skript, jedoch mit FrameSort-Konfiguration.
\n
Vorteile:
 - Stabiler/zuverlässiger, da es Blizzards interne Sortiermethoden nutzt.
\n
Nachteile:
 - Sortiert nur Blizzards Partyrahmen, sonst nichts.
 - Wird Lua-Fehler verursachen, was normal ist und ignoriert werden kann.
 - Kann keine Rahmenabstände anwenden.
]]
L["Please reload after changing these settings."] = "Bitte laden Sie das UI nach dem Ändern dieser Einstellungen neu."
L["Reload"] = "Neu laden"

-- # Role Ordering screen #
L["Role Ordering"] = "Rollenreihenfolge"
L["Specify the ordering you wish to use when sorting by role."] = "Geben Sie die Reihenfolge an, die Sie beim Sortieren nach Rolle verwenden möchten."
L["Tank > Healer > DPS"] = "Tank > Heiler > DPS"
L["Healer > Tank > DPS"] = "Heiler > Tank > DPS"
L["Healer > DPS > Tank"] = "Heiler > DPS > Tank"

-- # Auto Leader screen #
L["Auto Leader"] = "Auto-Leader"
L["Auto promote healers to leader in solo shuffle."] = "Heiler im Solo-Mischen automatisch zum Anführer befördern."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Warum? Damit Heiler Zielmarkierungen konfigurieren und party1/2 nach ihren Wünschen neu ordnen können."
L["Enabled"] = "Aktiviert"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Zielauswahl"
L["Target frame 1 (top frame)"] = "Zielrahmen 1 (oberster Rahmen)"
L["Target frame 2"] = "Zielrahmen 2"
L["Target frame 3"] = "Zielrahmen 3"
L["Target frame 4"] = "Zielrahmen 4"
L["Target frame 5"] = "Zielrahmen 5"
L["Target bottom frame"] = "Zielrahmen unten"
L["Target frame 1's pet"] = "Zielrahmen 1's Begleiter"
L["Target frame 2's pet"] = "Zielrahmen 2's Begleiter"
L["Target frame 3's pet"] = "Zielrahmen 3's Begleiter"
L["Target frame 4's pet"] = "Zielrahmen 4's Begleiter"
L["Target frame 5's pet"] = "Zielrahmen 5's Begleiter"
L["Target enemy frame 1"] = "Ziel Feindrahmen 1"
L["Target enemy frame 2"] = "Ziel Feindrahmen 2"
L["Target enemy frame 3"] = "Ziel Feindrahmen 3"
L["Target enemy frame 1's pet"] = "Ziel Feindrahmen 1's Begleiter"
L["Target enemy frame 2's pet"] = "Ziel Feindrahmen 2's Begleiter"
L["Target enemy frame 3's pet"] = "Ziel Feindrahmen 3's Begleiter"
L["Focus enemy frame 1"] = "Fokussieren Feindrahmen 1"
L["Focus enemy frame 2"] = "Fokussieren Feindrahmen 2"
L["Focus enemy frame 3"] = "Fokussieren Feindrahmen 3"
L["Cycle to the next frame"] = "Zum nächsten Rahmen wechseln"
L["Cycle to the previous frame"] = "Zum vorherigen Rahmen wechseln"
L["Target the next frame"] = "Das nächste Ziel auswählen"
L["Target the previous frame"] = "Das vorherige Ziel auswählen"

-- # Keybindings screen #
L["Keybindings"] = "Tastenkombinationen"
L["Keybindings_Description"] = [[
Sie finden die FrameSort-Tastenkombinationen im Standardbereich der WoW-Tastenkombinationen.
\n
Wofür sind die Tastenkombinationen nützlich?
Sie sind nützlich, um Spieler nach ihrer visuellen Darstellung und nicht nach ihrer
Gruppenposition (party1/2/3/etc.) auszuwählen.
\n
Beispielsweise stellen Sie sich eine 5-Mann-Dungeon-Gruppe vor, die nach Rolle sortiert ist und folgendermaßen aussieht:
  - Tank, party3
  - Heiler, Spieler
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Wie Sie sehen, unterscheidet sich ihre visuelle Darstellung von ihrer tatsächlichen Gruppenposition, was
die Zielauswahl verwirrend macht.
Wenn Sie /target party1 eingeben, würde es den DPS-Spieler in Position 3 anvisieren, anstatt den Tank.
\n
Die FrameSort-Tastenkombinationen zielen basierend auf ihrer visuellen Rahmenposition anstatt auf die Gruppennummer.
Das Ziel 'Rahmen 1' ist also der Tank, 'Rahmen 2' der Heiler, 'Rahmen 3' der DPS an Position 3, und so weiter.
]]

-- # Macros screen # --
L["Macros"] = "Makros"
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort hat %d|4Makro:Makros; gefunden, um sie zu verwalten."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort wird Variablen in Makros dynamisch aktualisieren, die die "#FrameSort"-Kopfzeile enthalten.'
L["Below are some examples on how to use this."] = "Im Folgenden finden Sie einige Beispiele, wie Sie dies verwenden können."

L["Macro_Example1"] = [[#showtooltip


#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@heiler,exists] Segen des Refugiums]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@rahmen1][mod:shift,@rahmen2][mod:alt,@spieler][] Läuterung]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@istgleichgültig] Schattenschritt;
/cast [@platzhalter] Tritt;]]

L["Example %d"] = "Beispiel %d"
L["Supported variables:"] = "Unterstützte Variablen:"
L["The first DPS that's not you."] = "Der erste DPS, der nicht Sie selbst sind."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Fügen Sie eine Zahl hinzu, um das N-te Ziel auszuwählen, z.B. DPS2 wählt den 2. DPS aus."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Variablen sind nicht case-sensitiv, daher funktionieren 'fRaMe1', 'Dps', 'enemyhealer', usw. alle."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Müssen Sie Makrozeichen sparen? Verwenden Sie Abkürzungen, um sie zu verkürzen:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Verwenden Sie "X", um FrameSort zu sagen, einen @unit-Selektor zu ignorieren:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@fokus][@mouseover,schädlich][@feindlicherheiler,existiert][] Zauber;]]

-- # Spacing screen #
L["Spacing"] = "Abstand"
L["Add some spacing between party/raid frames."] = "Fügen Sie etwas Abstand zwischen Gruppen-/Schlachtzugsrahmen hinzu."
L["This only applies to Blizzard frames."] = "Dies gilt nur für Blizzard-Rahmen."
L["Party"] = "Gruppe"
L["Raid"] = "Schlachtzug"
L["Group"] = "Gruppe"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertikal"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
FrameSort unterstützt die folgenden:
\n
Blizzard
 - Gruppe: Ja
 - Schlachtzug: Ja
 - Arena: kaputt (wird irgendwann repariert).
\n
ElvUI
 - Gruppe: Ja
 - Schlachtzug: Nein
 - Arena: Nein
\n
sArena
 - Arena: Ja
\n
Gladius
 - Arena: Ja
 - Bicmex-Version: Ja
\n
GladiusEx
 - Gruppe: Ja
 - Arena: Ja
\n
Cell
 - Gruppe: Ja
 - Schlachtzug: Ja, nur bei Verwendung kombinierter Gruppen.
\n
Shadowed Unit Frames
 - Gruppe: ja
 - Arena: unsicher, muss getestet werden.
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Möchten Sie FrameSort in Ihre Addons, Skripte und Weak Auras integrieren?"
L["Here are some examples."] = "Hier sind einige Beispiele."
L["Retrieved an ordered array of party/raid unit tokens."] = "Abrufen eines geordneten Arrays von Gruppen-/Schlachtzugs-Token."
L["Retrieved an ordered array of arena unit tokens."] = "Abrufen eines geordneten Arrays von Arena-Token."
L["Register a callback function to run after FrameSort sorts frames."] = "Registrieren Sie eine Callback-Funktion, die nach der Sortierung der Rahmen durch FrameSort ausgeführt wird."
L["Retrieve an ordered array of party frames."] = "Abrufen eines geordneten Arrays von Gruppenrahmen."
L["Change a FrameSort setting."] = "Ändern Sie eine FrameSort-Einstellung."
L["View a full listing of all API methods on GitHub."] = "Sehen Sie eine vollständige Liste aller API-Methoden auf GitHub."

-- # Help screen #
L["Help"] = "Hilfe"
L["Discord"] = "Discord"
L["Need help with something?"] = "Brauchen Sie Hilfe bei etwas?"
L["Talk directly with the developer on Discord."] = "Sprechen Sie direkt mit dem Entwickler auf Discord."

-- # Health Check screen -- #
L["Health Check"] = "Gesundheitscheck"
L["Try this"] = "Versuchen Sie dies"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Alle bekannten Probleme mit der Konfiguration oder konfliktbehafteten Addons werden unten angezeigt."
L["N/A"] = "N/V"
L["Passed!"] = "Bestanden!"
L["Failed"] = "Fehlgeschlagen"
L["(unknown)"] = "(unbekannt)"
L["(user macro)"] = "(Benutzermakro)"
L["Using grouped layout for Cell raid frames"] = "Verwendung des gruppierten Layouts für Cell-Schlachtzugsrahmen"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Bitte überprüfen Sie die Option 'Kombinierte Gruppen (Schlachtzug)' in Cell -> Layouts."
L["Can detect frames"] = "Rahmen können erkannt werden"
L["FrameSort currently supports frames from these addons: %s."] = "FrameSort unterstützt derzeit Rahmen von diesen Addons: %s."
L["Using Raid-Style Party Frames"] = "Verwenden von Schlachtzug-Stil-Gruppenrahmen"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Bitte aktivieren Sie 'Schlachtzug-Stil-Gruppenrahmen verwenden' in den Blizzard-Einstellungen."
L["Keep Groups Together setting disabled"] = "Einstellung 'Gruppen zusammenhalten' deaktiviert"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Ändern Sie den Schlachtzug-Anzeigemodus zu einer der Optionen 'Kombinierte Gruppen' über den Bearbeitungsmodus."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Deaktivieren Sie die Einstellung 'Gruppen zusammenhalten' im Schlachtzugsprofil."
L["Only using Blizzard frames with Traditional mode"] = "Nur Blizzard-Rahmen mit traditionellem Modus verwenden"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Der traditionelle Modus kann Ihre anderen Rahmen-Addons nicht sortieren: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Sicherer Sortiermodus wird verwendet, wenn Abstände verwendet werden."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "Der traditionelle Modus kann keine Abstände anwenden, überlegen Sie, die Abstände zu entfernen oder die sichere Sortiermethode zu verwenden."
L["Blizzard sorting functions not tampered with"] = "Blizzard-Sortierfunktionen wurden nicht manipuliert"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" kann Konflikte verursachen, überlegen Sie, es zu deaktivieren.'
L["No conflicting addons"] = "Keine konfliktbehafteten Addons"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" kann Konflikte verursachen, überlegen Sie, es zu deaktivieren.'
L["Main tank and assist setting disabled"] = "Einstellung 'Haupttank und Assist' deaktiviert"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Bitte deaktivieren Sie die Option 'Haupttank und Assist anzeigen' in Optionen -> Benutzeroberfläche -> Schlachtzugsrahmen."
