local _, addon = ...
local L = addon.Locale.itIT

-- # Main Options screen #
-- used in FrameSort - 1.2.3 version header, %s is the version number
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issues that may prevent FrameSort from working correctly."] = "Ci sono alcuni problemi che potrebbero impedire a FrameSort di funzionare correttamente."
L["Please go to the Health Check panel to view more details."] = "Vai al pannello Diagnostica per vedere maggiori dettagli."
L["Role"] = "Ruolo"
L["Spec"] = "Spec."
L["Group"] = "Gruppo"
L["Alphabetical"] = "Alfabetico"
L["Arena - 2v2"] = "Arena: 2c2"
L["Arena - 3v3"] = "Arena: 3c3"
L["Arena - 3v3 & 5v5"] = "Arena: 3c3 e 5c5"
L["Enemy Arena (see addons panel for supported addons)"] = "Arena nemica (consulta il pannello degli addon per quelli supportati)"
L["Dungeon (mythics, 5-mans, delves)"] = "Spedizione (mitiche, gruppi da 5, anfratti)"
L["Raid (battlegrounds, raids)"] = "Incursione (campi di battaglia, incursioni)"
L["World (non-instance groups)"] = "Mondo (gruppi fuori istanza)"
L["Player"] = "Giocatore"
L["Sort"] = "Ordina"
L["Top"] = "In alto"
L["Middle"] = "Al centro"
L["Bottom"] = "In basso"
L["Hidden"] = "Nascosto"
L["Group"] = "Gruppo"
L["Reverse"] = "Inverti"
L["Sort your frames while in 2v2 arena matches."] = "Ordina i tuoi riquadri durante le partite in arena 2c2."
L["Sort your frames while in arena matches larger than 2v2."] = "Ordina i tuoi riquadri durante le partite in arena più grandi di 2c2."
L["Sort the enemy frames created by supported arena addons."] = "Ordina i riquadri nemici creati dagli addon per arena supportati."
L["Sort your frames while in dungeons, mythic+, and delves."] = "Ordina i tuoi riquadri in spedizioni, mitiche+ e anfratti."
L["Sort your frames while in raids and battlegrounds."] = "Ordina i tuoi riquadri nelle incursioni e nei campi di battaglia."
L["Sort your frames while in a group out in the world."] = "Ordina i tuoi riquadri quando sei in un gruppo fuori dalle istanze."
L["Place your own frame at the top of the group."] = "Posiziona il tuo riquadro in cima al gruppo."
L["Place your own frame in the middle of the group."] = "Posiziona il tuo riquadro al centro del gruppo."
L["Place your own frame at the bottom of the group."] = "Posiziona il tuo riquadro in fondo al gruppo."
L["Hide your own frame, leaving only your group members."] = "Nasconde il tuo riquadro, lasciando solo i membri del gruppo."
L["Sort by the unit id, e.g. party1 > party2 > party3."] = "Ordina per id unità, ad es. party1 > party2 > party3."
L["Sort by role and spec, using the order from the Ordering panel."] = "Ordina per ruolo e specializzazione, usando l’ordine del pannello Ordinamento."
L["Sort by role (tank, healer, dps), using the order from the Ordering panel."] = "Ordina per ruolo (tank, guaritore, dps), usando l’ordine del pannello Ordinamento."
L["Sort by name in alphabetical order."] = "Ordina per nome in ordine alfabetico."
L["Reverse the sort order, so the last frame becomes the first."] = "Inverte l’ordinamento: l’ultimo riquadro diventa il primo."

-- # Sorting Method screen #
L["Sorting Method"] = "Metodo ordinamento"
L["Secure"] = "Sicuro"
L["SortingMethod_Secure_Description"] = [[
Regola la posizione di ogni singolo riquadro e non causa errori, blocchi o taint nell'interfaccia.
\n
Pro:
 - Può ordinare i riquadri di altri addon.
 - Può applicare la spaziatura tra i riquadri.
 - Nessun taint (termine tecnico per gli addon che interferiscono con il codice dell'interfaccia di Blizzard).
\n
Contro:
 - Soluzione fragile, un castello di carte per aggirare gli spaghetti di Blizzard.
 - Può rompersi a ogni patch di WoW e far impazzire lo sviluppatore.
]]
L["Traditional"] = "Tradizionale"
L["SortingMethod_Traditional_Description"] = [[
Questa è la modalità di ordinamento standard usata da addon e macro da oltre 10 anni.
Sostituisce il metodo di ordinamento interno di Blizzard con il nostro.
È lo stesso dello script 'SetFlowSortFunction', ma con la configurazione di FrameSort.
\n
Pro:
 - Più stabile e affidabile, perché sfrutta i metodi di ordinamento interni di Blizzard.
\n
Contro:
 - Ordina solo i riquadri del gruppo di Blizzard, nient'altro.
 - Causerà errori Lua: è normale e possono essere ignorati.
 - Non può applicare la spaziatura tra i riquadri.
]]
L["Please reload after changing these settings."] = "Ricarica l'interfaccia dopo aver modificato queste impostazioni."
L["Reload"] = "Ricarica"

-- # Ordering screen #
L["Ordering"] = "Ordinamento"
L["Specify the ordering you wish to use when sorting by spec."] = "Specifica l'ordine che vuoi usare quando ordini per specializzazione."
L["Tanks"] = "Tank"
L["Healers"] = "Guaritori"
L["Casters"] = "Incantatori"
L["Hunters"] = "Cacciatori"
L["Melee"] = "Corpo a corpo"

-- # Spec Priority screen # --
L["Spec Priority"] = "Priorità spec."
L["Spec Type"] = "Tipo di specializzazione"
L["Choose a spec type, then drag and drop to control priority."] = "Scegli un tipo di specializzazione, poi trascina e rilascia per gestire la priorità."
L["Tank"] = "Tank"
L["Healer"] = "Guaritore"
L["Caster"] = "Incantatore"
L["Hunter"] = "Cacciatore"
L["Melee"] = "Corpo a corpo"
L["Reset this type"] = "Reimposta questo tipo"
L["Spec query note"] = [[
Nota che le informazioni sulla specializzazione vengono richieste al server, il che richiede 1-2 secondi per giocatore.
\n
Questo significa che potrebbe volerci un momento prima di poter ordinare in modo accurato.
]]

-- # Auto Leader screen #
L["Auto Leader"] = "Capogruppo auto."
L["Auto promote healers to leader in solo shuffle."] = "Promuovi automaticamente i guaritori a capogruppo nel Solo Shuffle."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] =
    "Perché? Così i guaritori possono configurare le icone dei bersagli e riordinare party1/2 come preferiscono."

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Selezione bersaglio"
L["Target frame 1 (top frame)"] = "Seleziona il riquadro 1 (riquadro superiore)"
L["Target frame 2"] = "Seleziona il riquadro 2"
L["Target frame 3"] = "Seleziona il riquadro 3"
L["Target frame 4"] = "Seleziona il riquadro 4"
L["Target frame 5"] = "Seleziona il riquadro 5"
L["Target bottom frame"] = "Seleziona il riquadro inferiore"
L["Target 1 frame above bottom"] = "Seleziona 1 riquadro sopra l'ultimo"
L["Target 2 frames above bottom"] = "Seleziona 2 riquadri sopra l'ultimo"
L["Target 3 frames above bottom"] = "Seleziona 3 riquadri sopra l'ultimo"
L["Target 4 frames above bottom"] = "Seleziona 4 riquadri sopra l'ultimo"
L["Target frame 1's pet"] = "Seleziona il famiglio del riquadro 1"
L["Target frame 2's pet"] = "Seleziona il famiglio del riquadro 2"
L["Target frame 3's pet"] = "Seleziona il famiglio del riquadro 3"
L["Target frame 4's pet"] = "Seleziona il famiglio del riquadro 4"
L["Target frame 5's pet"] = "Seleziona il famiglio del riquadro 5"
L["Target enemy frame 1"] = "Seleziona il riquadro nemico 1"
L["Target enemy frame 2"] = "Seleziona il riquadro nemico 2"
L["Target enemy frame 3"] = "Seleziona il riquadro nemico 3"
L["Target enemy frame 1's pet"] = "Seleziona il famiglio del riquadro nemico 1"
L["Target enemy frame 2's pet"] = "Seleziona il famiglio del riquadro nemico 2"
L["Target enemy frame 3's pet"] = "Seleziona il famiglio del riquadro nemico 3"
L["Focus enemy frame 1"] = "Metti in focus il riquadro nemico 1"
L["Focus enemy frame 2"] = "Metti in focus il riquadro nemico 2"
L["Focus enemy frame 3"] = "Metti in focus il riquadro nemico 3"
L["Target the next frame"] = "Seleziona il riquadro successivo"
L["Target the previous frame"] = "Seleziona il riquadro precedente"
L["Cycle to the next frame"] = "Passa al riquadro successivo"
L["Cycle to the previous frame"] = "Passa al riquadro precedente"
L["Cycle to the next dps"] = "Passa al DPS successivo"
L["Cycle to the previous dps"] = "Passa al DPS precedente"

-- # Keybindings screen #
L["Keybindings"] = "Scorciatoie"
L["Keybindings_Description"] = [[
Puoi trovare le scorciatoie di FrameSort nella sezione standard delle scorciatoie da tastiera di WoW.
\n
A cosa servono le scorciatoie?
Servono a selezionare i giocatori in base al loro ordine visivo anziché alla loro
posizione nel gruppo (party1/2/3/ecc.)
\n
Per esempio, immagina un gruppo da 5 in spedizione ordinato per ruolo, così:
  - Tank, party3
  - Guaritore, player
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Come puoi vedere, la rappresentazione visiva è diversa dalla posizione reale nel gruppo,
il che rende confusa la selezione dei bersagli.
Se usassi /target party1, selezioneresti il DPS in posizione 3 invece del tank.
\n
Le scorciatoie di FrameSort selezionano in base alla posizione visiva del riquadro, non al numero del gruppo.
Quindi selezionare 'Riquadro 1' sceglie il tank, 'Riquadro 2' il guaritore, 'Riquadro 3' il DPS in terza posizione, e così via.
]]

-- # Macros screen # --
L["Macros"] = "Macro"
-- "|4macro:macros;" is a special command to pluralise the word "macro" to "macros" when %d is greater than 1
L["FrameSort has found %d |4macro:macros; to manage."] = "FrameSort ha trovato %d |4macro:macros; da gestire."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] =
    'FrameSort aggiornerà dinamicamente le variabili nelle macro con intestazione "#FrameSort".'
L["Below are some examples on how to use this."] = "Di seguito alcuni esempi su come usarlo."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists] Blessing of Sanctuary]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Dispel]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] Shadowstep;
/cast [@placeholder] Kick;]]

-- %d is the number for example 1/2/3
L["Example %d"] = "Esempio %d"
L["Discord Bot Blurb"] = [[
Ti serve aiuto per creare una macro?
\n
Fai un salto sul server Discord di FrameSort e usa il nostro bot di aiuto basato su IA!
\n
Basta menzionare '@help' con la tua domanda nel canale #bot.
]]

-- # Macro Variables screen # --
L["Macro Variables"] = "Variabili macro"
L["The first DPS that's not you."] = "Il primo DPS che non sei tu."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Aggiungi un numero per scegliere l'ennesimo bersaglio, ad es. DPS2 seleziona il 2° DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] =
    "Le variabili non fanno distinzione tra maiuscole e minuscole, quindi 'fRaMe1', 'Dps', 'enemyhealer', ecc. funzionano tutte."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Devi risparmiare caratteri nella macro? Usa le abbreviazioni per accorciarle:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Usa "X" per dire a FrameSort di ignorare un selettore @unit:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Spell;]]

-- # Spacing screen #
L["Spacing"] = "Spaziatura"
L["Add some spacing between party, raid, and arena frames."] = "Aggiungi spaziatura tra i riquadri di gruppo, incursione e arena."
L["This only applies to Blizzard frames."] = "Questo vale solo per i riquadri di Blizzard."
L["Party"] = "Gruppo"
L["Raid"] = "Incursione"
L["Group"] = "Gruppo"
L["Enemy Arena"] = "Arena nemica"
L["Horizontal"] = "Orizzontale"
L["Vertical"] = "Verticale"

-- # Addons screen #
L["Addons"] = "Addon"
L["Addons_Supported_Description"] = [[
FrameSort supporta quanto segue:
\n
  - Blizzard: gruppo, incursione, arena.
\n
  - ElvUI: gruppo, arena.
\n
  - sArena: arena.
\n
  - Gladius: arena.
\n
  - GladiusEx: gruppo, arena.
\n
  - Cell: gruppo, incursione (solo con i gruppi combinati).
\n
  - Shadowed Unit Frames: gruppo, arena.
\n
  - Grid2: gruppo, incursione.
\n
  - BattleGroundEnemies: gruppo, arena.
\n
  - Gladdy: arena.
\n
  - Arena Core: 0.9.1.7+.
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Vuoi integrare FrameSort nei tuoi addon, script e WeakAuras?"
L["Here are some examples."] = "Ecco alcuni esempi."
L["Retrieved an ordered array of party/raid unit tokens."] = "Restituisce un elenco ordinato di token unità di gruppo/incursione."
L["Retrieved an ordered array of arena unit tokens."] = "Restituisce un elenco ordinato di token unità dell'arena."
L["Register a callback function to run after FrameSort sorts frames."] = "Registra una funzione di callback da eseguire dopo che FrameSort ha ordinato i riquadri."
L["Retrieve an ordered array of party frames."] = "Restituisce un elenco ordinato di riquadri del gruppo."
L["Change a FrameSort setting."] = "Modifica un'impostazione di FrameSort."
L["Get the frame number of a unit."] = "Ottieni il numero di riquadro di un'unità."
L["View a full listing of all API methods on GitHub."] = "Consulta l'elenco completo di tutti i metodi API su GitHub."

-- # Discord screen #
L["Discord"] = "Discord"
L["Need help with something?"] = "Ti serve aiuto con qualcosa?"
L["Talk directly with the developer on Discord."] = "Parla direttamente con lo sviluppatore su Discord."

-- # Health Check screen -- #
L["Health Check"] = "Diagnostica"
L["Try this"] = "Prova questo"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Eventuali problemi noti di configurazione o conflitti tra addon verranno mostrati qui sotto."
L["N/A"] = "N/D"
L["Passed!"] = "Superato!"
L["Failed"] = "Fallito"
L["(unknown)"] = "(sconosciuto)"
L["(user macro)"] = "(macro dell'utente)"
L["Using grouped layout for Cell raid frames"] = "Layout raggruppato in uso per i riquadri incursione di Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = "Attiva l'opzione 'Combined Groups (Raid)' in Cell -> Layouts"
L["Can detect frames"] = "Riesce a rilevare i riquadri"
L["FrameSort currently supports frames from these addons: %s"] = "Attualmente FrameSort supporta i riquadri di questi addon: %s"
L["Keep Groups Together setting disabled"] = "Impostazione 'Mantieni i gruppi uniti' disattivata"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = "Cambia la modalità di visualizzazione incursione con una delle opzioni 'Combined Groups' tramite la Modalità Modifica"
L["Disable the 'Keep Groups Together' raid profile setting"] = "Disattiva l'impostazione 'Keep Groups Together' del profilo incursione"
L["Only using Blizzard frames with Traditional mode"] = "Solo riquadri di Blizzard in uso con la modalità Tradizionale"
L["Traditional mode can't sort your other frame addons: '%s'"] = "La modalità Tradizionale non può ordinare gli altri addon di riquadri: '%s'"
L["Using Secure sorting mode when spacing is being used"] = "Modalità di ordinamento Sicuro in uso mentre è applicata la spaziatura"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] =
    "La modalità Tradizionale non può applicare la spaziatura: valuta di rimuoverla o di usare il metodo di ordinamento Sicuro"
L["Blizzard sorting functions not tampered with"] = "Funzioni di ordinamento di Blizzard non alterate"
L['"%s" may cause conflicts, consider disabling it'] = '"%s" potrebbe causare conflitti, valuta di disattivarlo'
L["No conflicting addons"] = "Nessun addon in conflitto"

-- # Log Screen -- #
L["Log"] = "Registro"
L["Enable Logging"] = "Abilita registro"
L["FrameSort log to help with diagnosing issues."] = "Registro di FrameSort per aiutare a diagnosticare i problemi."
L["Copy Log"] = "Copia registro"

-- # Notifications -- #
L["Can't do that during combat."] = "Non puoi farlo durante il combattimento."

-- # Nameplates screen #
L["Nameplates"] = "Barre dei nomi"
L["Friendly Nameplates"] = "Barre dei nomi alleate"
L["Enemy Nameplates"] = "Barre dei nomi nemiche"
L["NameplatesBlurb"] = [[
Sostituisce il testo delle barre dei nomi di Blizzard e Platynator con le variabili di FrameSort.
\n
Variabili supportate:
  - $framenumber
  - $name
  - $unit
  - $spec
\n
Esempi:
  - Riquadro - $framenumber
  - $framenumber - $spec
  - $name - $spec
]]

-- # Miscellaneous screen #
L["Miscellaneous"] = "Varie"
L["Various tweaks you can apply."] = "Vari ritocchi che puoi applicare."
L["Player top of role"] = "Giocatore in cima al ruolo"
L["Places you at the top of your corresponding role (healer/tank/dps)."] = "Ti posiziona in cima al tuo ruolo corrispondente (guaritore/tank/DPS)."

-- # Language screen #
L["Language"] = "Lingua"
L["Auto"] = "Automatico"
L["Specify the language we use."] = "Specifica la lingua da usare."
