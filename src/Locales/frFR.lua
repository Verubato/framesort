local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "frFR" then
    return
end

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Il y a des problèmes qui peuvent empêcher FrameSort de fonctionner correctement."
L["Please go to the Health Check panel to view more details."] = "Veuillez vous rendre dans le panneau de vérification de l'état pour voir plus de détails."
L["Role"] = "Rôle"
L["Group"] = "Groupe"
L["Alphabetical"] = "Alphabétique"
L["Arena - 2v2"] = "Arene - 2v2"
L["Arena - 3v3"] = "Arene - 3v3"
L["Arena - 3v3 & 5v5"] = "Arene - 3v3 & 5v5"
L["Enemy Arena (see addons panel for supported addons)"] = "Arene ennemie (voir le panneau des addons pour les addons pris en charge)"
L["Dungeon (mythics, 5-mans, delves)"] = "Donjon (mythiques, groupes de 5, explorations)"
L["Raid (battlegrounds, raids)"] = "Raid (champs de bataille, raids)"
L["World (non-instance groups)"] = "Monde (groupes non-instances)"
L["Player"] = "Joueur"
L["Sort"] = "Trier"
L["Top"] = "Haut"
L["Middle"] = "Milieu"
L["Bottom"] = "Bas"
L["Hidden"] = "Caché"
L["Group"] = "Groupe"
L["Reverse"] = "Inverse"

-- # Sorting Method screen #
L["Sorting Method"] = "Méthode de tri"
L["Secure"] = "Sécure"
L["SortingMethod_Secure_Description"] = [[
Ajuste la position de chaque cadre individuel et ne bugue/ verrouille/ endommage pas l'interface utilisateur.
\n
Avantages:
 - Peut trier des cadres d'autres addons.
 - Peut appliquer un espacement entre les cadres.
 - Pas de dommage (terme technique pour les addons interférant avec le code de l'interface utilisateur de Blizzard).
\n
Inconvénients:
 - Situation fragile à contourner le spaghetti de Blizzard.
 - Peut casser avec les mises à jour de WoW et rendre le développeur fou.
]]
L["Traditional"] = "Traditionnel"
L["SortingMethod_Traditional_Description"] = [[
C'est le mode de tri standard que les addons et macros ont utilisé depuis plus de 10 ans.
Il remplace la méthode de tri interne de Blizzard par la nôtre.
C'est le même que le script 'SetFlowSortFunction' mais avec la configuration de FrameSort.
\n
Avantages:
 - Plus stable/ fiable car il s'appuie sur les méthodes de tri internes de Blizzard.
\n
Inconvénients:
 - Trie uniquement les cadres de groupe de Blizzard, rien d'autre.
 - Provoquera des erreurs Lua, ce qui est normal et peut être ignoré.
 - Ne peut pas appliquer d’espacement entre les cadres.
]]
L["Please reload after changing these settings."] = "Veuillez recharger après avoir modifié ces paramètres."
L["Reload"] = "Recharger"

-- # Ordering screen #
L["Ordering"] = "Commande"
L["Specify the ordering you wish to use when sorting by role."] = "Spécifiez l'ordre que vous souhaitez utiliser lors du tri par rôle."
L["Tanks"] = "Tank"
L["Healers"] = "Soigneurs"
L["Casters"] = "Lanceurs de sorts"
L["Hunters"] = "Chasseurs"
L["Melee"] = "Mêlée"

-- # Auto Leader screen #
L["Auto Leader"] = "Leader automatique"
L["Auto promote healers to leader in solo shuffle."] = "Promotion automatique des soigneurs au poste de leader dans le shuffle en solo."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Pourquoi ? Pour que les soigneurs puissent configurer les icônes de marqueur de cible et réorganiser party1/2 selon leur préférence."
L["Enabled"] = "Activé"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Ciblage"
L["Target frame 1 (top frame)"] = "Cibler le cadre 1 (cadre supérieur)"
L["Target frame 2"] = "Cibler le cadre 2"
L["Target frame 3"] = "Cibler le cadre 3"
L["Target frame 4"] = "Cibler le cadre 4"
L["Target frame 5"] = "Cibler le cadre 5"
L["Target bottom frame"] = "Cibler le cadre inférieur"
L["Target 1 frame above bottom"] = "Cibler le cadre 1 au-dessus du bas"
L["Target 2 frames above bottom"] = "Cibler 2 cadres au-dessus du bas"
L["Target 3 frames above bottom"] = "Cibler 3 cadres au-dessus du bas"
L["Target 4 frames above bottom"] = "Cibler 4 cadres au-dessus du bas"
L["Target frame 1's pet"] = "Cibler le familier du cadre 1"
L["Target frame 2's pet"] = "Cibler le familier du cadre 2"
L["Target frame 3's pet"] = "Cibler le familier du cadre 3"
L["Target frame 4's pet"] = "Cibler le familier du cadre 4"
L["Target frame 5's pet"] = "Cibler le familier du cadre 5"
L["Target enemy frame 1"] = "Cibler le cadre ennemi 1"
L["Target enemy frame 2"] = "Cibler le cadre ennemi 2"
L["Target enemy frame 3"] = "Cibler le cadre ennemi 3"
L["Target enemy frame 1's pet"] = "Cibler le familier du cadre ennemi 1"
L["Target enemy frame 2's pet"] = "Cibler le familier du cadre ennemi 2"
L["Target enemy frame 3's pet"] = "Cibler le familier du cadre ennemi 3"
L["Focus enemy frame 1"] = "Cibler le cadre ennemi 1"
L["Focus enemy frame 2"] = "Cibler le cadre ennemi 2"
L["Focus enemy frame 3"] = "Cibler le cadre ennemi 3"
L["Cycle to the next frame"] = "Passer au cadre suivant"
L["Cycle to the previous frame"] = "Passer au cadre précédent"
L["Target the next frame"] = "Cibler le cadre suivant"
L["Target the previous frame"] = "Cibler le cadre précédent"

-- # Keybindings screen #
L["Keybindings"] = "Raccourcis"
L["Keybindings_Description"] = [[
Vous pouvez trouver les raccourcis de FrameSort dans la zone standard des raccourcis de WoW.
\n
À quoi servent les raccourcis ?
Ils sont utiles pour cibler les joueurs par leur représentation visuelle plutôt que par leur
position dans le groupe (party1/2/3/etc.)
\n
Par exemple, imaginez un groupe de donjon de 5 trié par rôle qui ressemble à ceci :
  - Tank, party3
  - Soigneur, joueur
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Comme vous pouvez le voir, leur représentation visuelle diffère de leur position réelle dans le groupe, ce qui
rend le ciblage déroutant.
Si vous deviez /target party1, cela ciblerait le joueur DPS en position 3 plutôt que le tank.
\n
Les raccourcis FrameSort cibleront en fonction de leur position visuelle dans le cadre plutôt que de leur numéro de groupe.
Cibler 'Cadre 1' ciblera le Tank, 'Cadre 2' le soigneur, 'Cadre 3' le DPS en position 3, et ainsi de suite.
]]

-- # Macros screen # --
L["Macros"] = "Macros"
L["FrameSort has found %d |4macro:macros; to manage."] = "FrameSort a trouvé %d |4macro:macros; à gérer."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "FrameSort mettra à jour dynamiquement les variables dans les macros contenant l'en-tête '#FrameSort'."
L["Below are some examples on how to use this."] = "Voici quelques exemples sur la façon de l'utiliser."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists]Bénédiction de sanctuaire]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Dissipation]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] Pas d'ombre;
/cast [@placeholder] Coup de pied;]]

L["Example %d"] = "Exemple %d"
L["Discord Bot Blurb"] = [[
Besoin d'aide pour créer une macro ? 
\n
Rendez-vous sur le serveur Discord de FrameSort et utilisez notre bot AI pour les macros !
\n
Il vous suffit de mentionner '@Macro Bot' avec votre question dans le canal du bot macro.
]]

-- # Macro Variables screen # --
L["Macro Variables"] = "Variables de macro"
L["The first DPS that's not you."] = "Le premier DPS qui n'est pas vous."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Ajoutez un numéro pour choisir la N-ième cible, par exemple, DPS2 sélectionne le 2ème DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Les variables ne tiennent pas compte de la casse, donc 'fRaMe1', 'Dps', 'enemyhealer', etc., fonctionneront tous."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Besoin de réduire le nombre de caractères dans les macros ? Utilisez des abréviations pour les raccourcir :"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = "Utilisez 'X' pour indiquer à FrameSort d'ignorer un sélecteur @unit :"
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Sort;]]

-- # Spacing screen #
L["Spacing"] = "Espacement"
L["Add some spacing between party, raid, and arena frames."] = "Ajoutez un espacement entre les cadres de groupe, de raid et d'arène."
L["This only applies to Blizzard frames."] = "Cela ne s'applique qu'aux cadres de Blizzard."
L["Party"] = "Groupe"
L["Raid"] = "Raid"
L["Group"] = "Groupe"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertical"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
FrameSort prend en charge les éléments suivants :
\n
  - Blizzard : groupe, raid, arène.
\n
  - ElvUI : groupe.
\n
  - sArena : arène.
\n
  - Gladius : arène.
\n
  - GladiusEx : groupe, arène.
\n
  - Cell : groupe, raid (uniquement lors de l'utilisation de groupes combinés).
\n
  - Shadowed Unit Frames : groupe, arène.
\n
  - Grid2 : groupe, raid.
\n
  - BattleGroundEnemies : groupe, arène.
\n
  - Gladdy : arène.
\n
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Vous souhaitez intégrer FrameSort dans vos addons, scripts et Weak Auras ?"
L["Here are some examples."] = "Voici quelques exemples."
L["Retrieved an ordered array of party/raid unit tokens."] = "Récupéré un tableau ordonné de jetons d'unités de groupe/raid."
L["Retrieved an ordered array of arena unit tokens."] = "Récupéré un tableau ordonné de jetons d'unités d'arène."
L["Register a callback function to run after FrameSort sorts frames."] = "Enregistrer une fonction de rappel à exécuter après que FrameSort trie les cadres."
L["Retrieve an ordered array of party frames."] = "Récupérer un tableau ordonné de cadres de groupe."
L["Change a FrameSort setting."] = "Modifier un paramètre de FrameSort."
L["View a full listing of all API methods on GitHub."] = "Voir une liste complète de toutes les méthodes API sur GitHub."

-- # Discord screen #
L["Discord"] = "Discord"
L["Need help with something?"] = "Besoin d'aide pour quelque chose ?"
L["Talk directly with the developer on Discord."] = "Parlez directement avec le développeur sur Discord."

-- # Health Check screen -- #
L["Health Check"] = "Vérification de l'état"
L["Try this"] = "Essayez ceci"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Tout problème connu avec la configuration ou des addons conflictuels sera affiché ci-dessous."
L["N/A"] = "N/A"
L["Passed!"] = "Réussi !"
L["Failed"] = "Échoué"
L["(unknown)"] = "(inconnu)"
L["(user macro)"] = "(macro utilisateur)"
L["Using grouped layout for Cell raid frames"] = "Utilisation d'une disposition groupée pour les cadres de raid Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = "Veuillez vérifier l'option 'Groupes combinés (Raid)' dans Cell -> Dispositions"
L["Can detect frames"] = "Peut détecter les cadres"
L["FrameSort currently supports frames from these addons: %s"] = "FrameSort prend actuellement en charge les cadres de ces addons : %s"
L["Using Raid-Style Party Frames"] = "Utilisation des cadres de groupe de style raid"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings"] = "Veuillez activer 'Utiliser des cadres de groupe de style raid' dans les paramètres de Blizzard"
L["Keep Groups Together setting disabled"] = "Paramètre 'Garder les groupes ensemble' désactivé"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = "Changer le mode d'affichage du raid à l'une des options de 'Groupes combinés' via le mode Édition"
L["Disable the 'Keep Groups Together' raid profile setting."] = "Désactiver le paramètre de profil de raid 'Garder les groupes ensemble'."
L["Only using Blizzard frames with Traditional mode"] = "Utilisation uniquement des cadres Blizzard avec le mode Traditionnel"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Le mode traditionnel ne peut pas trier vos autres addons de cadre : '%s'"
L["Using Secure sorting mode when spacing is being used"] = "Utilisation du mode de tri sécurisé lorsque l'espacement est utilisé"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] = "Le mode traditionnel ne peut pas appliquer d'espacement, envisagez de supprimer l'espacement ou d'utiliser la méthode de tri sécurisée"
L["Blizzard sorting functions not tampered with"] = "Les fonctions de tri de Blizzard n'ont pas été altérées"
L['"%s" may cause conflicts, consider disabling it'] = '"%s" peut provoquer des conflits, envisagez de le désactiver.'
L["No conflicting addons"] = "Aucun addon en conflit"
L["Main tank and assist setting disabled"] = "Paramètre de tank principal et d'assistance désactivé"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames"] = "Veuillez désactiver l'option 'Afficher le Tank Principal et l'Assistance' dans Options -> Interface -> Cadres de Raid"

-- # Log Screen -- #
L["Log"] = "Journal"
L["FrameSort log to help with diagnosing issues."] = "Journal FrameSort pour aider à diagnostiquer les problèmes."
