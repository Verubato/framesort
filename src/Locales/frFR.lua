local _, addon = ...
local L = addon.Locale

L["FrameSort"] = "TriCadre"

-- # Main Options screen #
L["FrameSort - %s"] = "TriCadre - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Il y a des problèmes qui peuvent empêcher TriCadre de fonctionner correctement."
L["Please go to the Health Check panel to view more details."] = "Veuillez aller sur le panneau de vérification de santé pour voir plus de détails."
L["Role"] = "Rôle"
L["Group"] = "Groupe"
L["Alpha"] = "Alpha"
L["party1 > party2 > partyN > partyN+1"] = "groupe1 > groupe2 > groupeN > groupeN+1"
L["tank > healer > dps"] = "tank > soigneur > dps"
L["NameA > NameB > NameZ"] = "NomA > NomB > NomZ"
L["healer > tank > dps"] = "soigneur > tank > dps"
L["healer > dps > tank"] = "soigneur > dps > tank"
L["tank > healer > dps"] = "tank > soigneur > dps"
L["Arena - 2v2"] = "Arène - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 et 5v5"
L["Arena - %s"] = "Arène - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "Arène ennemie (voir le panneau des addons pour les addons pris en charge)"
L["Dungeon (mythics, 5-mans)"] = "Donjon (mythiques, 5-personnes)"
L["Raid (battlegrounds, raids)"] = "Raid (champs de bataille, raids)"
L["World (non-instance groups)"] = "Monde (groupes hors instance)"
L["Player:"] = "Joueur :"
L["Top"] = "Haut"
L["Middle"] = "Milieu"
L["Bottom"] = "Bas"
L["Hidden"] = "Caché"
L["Group"] = "Groupe"
L["Role"] = "Rôle"
L["Alpha"] = "Alpha"
L["Reverse"] = "Inverser"

-- # Sorting Method screen #
L["Sorting Method"] = "Méthode de tri"
L["Secure"] = "Sécurisé"
L["SortingMethod_Secure_Description"] = [[
Ajuste la position de chaque cadre individuel et ne provoque pas de bugs/verrouillages/altérations de l'interface utilisateur.
\n
Avantages :
 - Peut trier les cadres d'autres addons.
 - Peut appliquer un espacement entre les cadres.
 - Pas d'altération (terme technique pour les addons qui interfèrent avec le code de l'interface Blizzard).
\n
Inconvénients :
 - Structure fragile, pouvant se casser lors des mises à jour de WoW et rendre le développeur fou.
 - Peut se briser avec les mises à jour de WoW et rendre le développeur fou.
]]
L["Traditional"] = "Traditionnel"
L["SortingMethod_Secure_Traditional"] = [[
C'est le mode de tri standard utilisé par les addons et les macros depuis plus de 10 ans.
Il remplace la méthode de tri interne de Blizzard par la nôtre.
C'est la même chose que le script 'SetFlowSortFunction' mais avec la configuration de TriCadre.
\n
Avantages :
 - Plus stable/fiable car il utilise les méthodes de tri internes de Blizzard.
\n
Inconvénients :
 - Ne trie que les cadres de groupe de Blizzard, rien d'autre.
 - Peut provoquer des erreurs Lua, ce qui est normal et peut être ignoré.
 - Impossible d'appliquer un espacement entre les cadres.
]]
L["Please reload after changing these settings."] = "Veuillez recharger après avoir modifié ces paramètres."
L["Reload"] = "Recharger"

-- # Role Ordering screen #
L["Role Ordering"] = "Ordre des rôles"
L["Specify the ordering you wish to use when sorting by role."] = "Spécifiez l'ordre que vous souhaitez utiliser lors du tri par rôle."
L["Tank > Healer > DPS"] = "Tank > Soigneur > DPS"
L["Healer > Tank > DPS"] = "Soigneur > Tank > DPS"
L["Healer > DPS > Tank"] = "Soigneur > DPS > Tank"

-- # Auto Leader screen #
L["Auto Leader"] = "Chef automatique"
L["Auto promote healers to leader in solo shuffle."] = "Promouvoir automatiquement les soigneurs en chef dans le mélange solo."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Pourquoi ? Pour que les soigneurs puissent configurer les icônes de marqueur de cible et réorganiser les groupes1/2 selon leurs préférences."
L["Enabled"] = "Activé"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Ciblage"
L["Target frame 1 (top frame)"] = "Cibler cadre 1 (cadre du haut)"
L["Target frame 2"] = "Cibler cadre 2"
L["Target frame 3"] = "Cibler cadre 3"
L["Target frame 4"] = "Cibler cadre 4"
L["Target frame 5"] = "Cibler cadre 5"
L["Target bottom frame"] = "Cibler cadre du bas"
L["Target frame 1's pet"] = "Cibler familier du cadre 1"
L["Target frame 2's pet"] = "Cibler familier du cadre 2"
L["Target frame 3's pet"] = "Cibler familier du cadre 3"
L["Target frame 4's pet"] = "Cibler familier du cadre 4"
L["Target frame 5's pet"] = "Cibler familier du cadre 5"
L["Target enemy frame 1"] = "Cibler cadre ennemi 1"
L["Target enemy frame 2"] = "Cibler cadre ennemi 2"
L["Target enemy frame 3"] = "Cibler cadre ennemi 3"
L["Target enemy frame 1's pet"] = "Cibler familier du cadre ennemi 1"
L["Target enemy frame 2's pet"] = "Cibler familier du cadre ennemi 2"
L["Target enemy frame 3's pet"] = "Cibler familier du cadre ennemi 3"
L["Focus enemy frame 1"] = "Focus cadre ennemi 1"
L["Focus enemy frame 2"] = "Focus cadre ennemi 2"
L["Focus enemy frame 3"] = "Focus cadre ennemi 3"
L["Cycle to the next frame"] = "Passer au cadre suivant"
L["Cycle to the previous frame"] = "Passer au cadre précédent"
L["Target the next frame"] = "Cibler le cadre suivant"
L["Target the previous frame"] = "Cibler le cadre précédent"

-- # Keybindings screen #
L["Keybindings"] = "Raccourcis clavier"
L["Keybindings_Description"] = [[
Vous pouvez trouver les raccourcis clavier de TriCadre dans la zone des raccourcis clavier standard de WoW.
\n
À quoi servent les raccourcis clavier ?
Ils sont utiles pour cibler les joueurs en fonction de leur représentation visuelle plutôt que de leur position dans le groupe (groupe1/2/3/etc.)
\n
Par exemple, imaginez un groupe de donjon à 5 joueurs trié par rôle qui ressemble à ceci :
  - Tank, groupe3
  - Soigneur, joueur
  - DPS, groupe1
  - DPS, groupe4
  - DPS, groupe2
\n
Comme vous pouvez le voir, leur représentation visuelle diffère de leur position réelle dans le groupe, ce qui rend le ciblage confus.
Si vous utilisez /target groupe1, cela ciblera le joueur DPS en position 3 au lieu du tank.
\n
Les raccourcis clavier de TriCadre cibleront en fonction de leur position visuelle plutôt que de leur numéro de groupe.
Ainsi, cibler 'Cadre 1' ciblera le Tank, 'Cadre 2' le soigneur, 'Cadre 3' le DPS en position 3, et ainsi de suite.
]]

-- # Macros screen # --
L["Macros"] = "Macros"
L["FrameSort has found %d|4macro:macros; to manage."] = "TriCadre a trouvé %d|4macro:macros; à gérer."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'TriCadre mettra à jour dynamiquement les variables dans les macros contenant l’en-tête "#FrameSort".'
L["Below are some examples on how to use this."] = "Vous trouverez ci-dessous des exemples sur la façon de l'utiliser."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Survol, Cible, Soigneur
/cast [@mouseover,help][@target,help][@healer

,exists] Bénédiction de sanctuaire]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Cadre1, Cadre2, Joueur
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Dissipation]]

L["Macro_Example3"] = [[#FrameSort SoigneurEnnemi, SoigneurEnnemi
/cast [@peuimporte] Pas de l'ombre;
/cast [@remplaçant] Coup de pied;]]

L["Example %d"] = "Exemple %d"
L["Supported variables:"] = "Variables prises en charge :"
L["The first DPS that's not you."] = "Le premier DPS qui n'est pas vous."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Ajoutez un nombre pour choisir la Nième cible, par ex., DPS2 sélectionne le 2ème DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Les variables ne sont pas sensibles à la casse, donc 'fRaMe1', 'Dps', 'enemyhealer', etc., fonctionneront toutes."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Besoin de gagner des caractères dans un macro? Utilisez des abréviations pour les raccourcir :"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Utilisez "X" pour dire à TriCadre d’ignorer un sélecteur @unit :'
L["Skip_Example"] = [[
#FS X X SoigneurEnnemi
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Sort;]]

-- # Spacing screen #
L["Spacing"] = "Espacement"
L["Add some spacing between party/raid frames."] = "Ajoutez un espacement entre les cadres de groupe/raid."
L["This only applies to Blizzard frames."] = "Cela ne s'applique qu'aux cadres Blizzard."
L["Party"] = "Groupe"
L["Raid"] = "Raid"
L["Group"] = "Groupe"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertical"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
TriCadre prend en charge les éléments suivants :
\n
Blizzard
 - Groupe : oui
 - Raid : oui
 - Arène : cassé (sera réparé éventuellement).
\n
ElvUI
 - Groupe : oui
 - Raid : non
 - Arène : non
\n
sArena
 - Arène : oui
\n
Gladius
 - Arène : oui
 - Version Bicmex : oui
\n
GladiusEx
 - Groupe : oui
 - Arène : oui
\n
Cell
 - Groupe : oui
 - Raid : oui, uniquement lors de l'utilisation de groupes combinés.
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Vous souhaitez intégrer TriCadre dans vos addons, scripts et Weak Auras ?"
L["Here are some examples."] = "Voici quelques exemples."
L["Retrieved an ordered array of party/raid unit tokens."] = "Tableau ordonné des jetons d'unité de groupe/raid récupéré."
L["Retrieved an ordered array of arena unit tokens."] = "Tableau ordonné des jetons d'unité d'arène récupéré."
L["Register a callback function to run after FrameSort sorts frames."] = "Enregistrez une fonction de rappel à exécuter après que TriCadre ait trié les cadres."
L["Retrieve an ordered array of party frames."] = "Récupérer un tableau ordonné des cadres de groupe."
L["Change a FrameSort setting."] = "Modifier un paramètre de TriCadre."
L["View a full listing of all API methods on GitHub."] = "Voir une liste complète de toutes les méthodes API sur GitHub."

-- # Help screen #
L["Help"] = "Aide"
L["Discord"] = "Discord"
L["Need help with something?"] = "Besoin d'aide pour quelque chose ?"
L["Talk directly with the developer on Discord."] = "Parlez directement avec le développeur sur Discord."

-- # Health Check screen -- #
L["Health Check"] = "Vérification de santé"
L["Try this"] = "Essayez ceci"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Tous les problèmes connus de configuration ou de conflits avec des addons seront affichés ci-dessous."
L["N/A"] = "N/D"
L["Passed!"] = "Réussi !"
L["Failed"] = "Échec"
L["(unknown)"] = "(inconnu)"
L["(user macro)"] = "(macro utilisateur)"
L["Using grouped layout for Cell raid frames"] = "Utilisation de la disposition groupée pour les cadres de raid Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Veuillez vérifier l'option 'Groupes combinés (Raid)' dans Cell -> Dispositions."
L["Can detect frames"] = "Peut détecter les cadres"
L["FrameSort currently supports frames from these addons: %s."] = "TriCadre prend actuellement en charge les cadres de ces addons : %s."
L["Using Raid-Style Party Frames"] = "Utilisation des cadres de groupe en style Raid"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Veuillez activer 'Utiliser les cadres de groupe en style Raid' dans les paramètres de Blizzard."
L["Keep Groups Together setting disabled"] = "Paramètre 'Garder les groupes ensemble' désactivé"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Changez le mode d'affichage du raid pour l'une des options 'Groupes combinés' via le Mode Édition."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Désactivez le paramètre de profil de raid 'Garder les groupes ensemble'."
L["Only using Blizzard frames with Traditional mode"] = "Utilisation uniquement des cadres Blizzard avec le mode Traditionnel"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Le mode Traditionnel ne peut pas trier vos autres addons de cadre : '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Utilisation du mode de tri Sécurisé lorsque l'espacement est utilisé."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "Le mode Traditionnel ne peut pas appliquer d'espacement, envisagez de supprimer l'espacement ou d'utiliser la méthode de tri Sécurisée."
L["Blizzard sorting functions not tampered with"] = "Fonctions de tri Blizzard non altérées"
L['"%s" may cause conflicts, consider disabling it.'] = '« %s » peut provoquer des conflits, envisagez de le désactiver.'
L["No conflicting addons"] = "Pas d'addons en conflit"
L['"%s" may cause conflicts, consider disabling it.'] = '« %s » peut provoquer des conflits, envisagez de le désactiver.'
L["Main tank and assist setting disabled"] = "Paramètre du tank principal et de l'assistant désactivé"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Veuillez désactiver l'option 'Afficher le tank principal et l'assistant' dans Options -> Interface -> Cadres de raid."
