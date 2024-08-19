local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "frFR" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Il y a des problèmes qui pourraient empêcher FrameSort de fonctionner correctement."
L["Please go to the Health Check panel to view more details."] = "Veuillez consulter le panneau de vérification de la santé pour plus de détails."
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
L["Dungeon (mythics, 5-mans)"] = "Donjon (mythiques, 5 joueurs)"
L["Raid (battlegrounds, raids)"] = "Raid (champs de bataille, raids)"
L["World (non-instance groups)"] = "Monde (groupes non instanciés)"
L["Player"] = "Joueur"
L["Sort"] = "Trier"
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
Ajuste la position de chaque cadre individuel et ne perturbe/pas l'interface utilisateur.
\n
Avantages:
 - Peut trier les cadres d'autres addons.
 - Peut appliquer un espacement entre les cadres.
 - Pas de contamination (terme technique pour les addons qui interfèrent avec le code UI de Blizzard).
\n
Inconvénients:
 - Situation fragile pour contourner le code complexe de Blizzard.
 - Peut se casser avec les mises à jour de WoW et rendre le développeur fou.
]]
L["Traditional"] = "Traditionnel"
L["SortingMethod_Secure_Traditional"] = [[
C'est le mode de tri standard utilisé par les addons et les macros depuis plus de 10 ans.
Il remplace la méthode de tri interne de Blizzard par la nôtre.
C'est la même chose que le script 'SetFlowSortFunction' mais avec la configuration de FrameSort.
\n
Avantages:
 - Plus stable/fiable car il utilise les méthodes de tri internes de Blizzard.
\n
Inconvénients:
 - Trie uniquement les cadres de groupe de Blizzard, rien d'autre.
 - Provoquera des erreurs Lua, ce qui est normal et peut être ignoré.
 - Ne peut pas appliquer d'espacement entre les cadres.
]]
L["Please reload after changing these settings."] = "Veuillez recharger l'interface après avoir modifié ces paramètres."
L["Reload"] = "Recharger"

-- # Role Ordering screen #
L["Role Ordering"] = "Ordre des rôles"
L["Specify the ordering you wish to use when sorting by role."] = "Spécifiez l'ordre que vous souhaitez utiliser lors du tri par rôle."
L["Tank > Healer > DPS"] = "Tank > Soigneur > DPS"
L["Healer > Tank > DPS"] = "Soigneur > Tank > DPS"
L["Healer > DPS > Tank"] = "Soigneur > DPS > Tank"

-- # Auto Leader screen #
L["Auto Leader"] = "Chef automatique"
L["Auto promote healers to leader in solo shuffle."] = "Promouvoir automatiquement les soigneurs au statut de chef dans les mélanges en solo."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "Pourquoi? Pour que les soigneurs puissent configurer les icônes de marqueurs de cible et réorganiser groupe1/2 selon leurs préférences."
L["Enabled"] = "Activé"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Ciblage"
L["Target frame 1 (top frame)"] = "Cible cadre 1 (cadre supérieur)"
L["Target frame 2"] = "Cible cadre 2"
L["Target frame 3"] = "Cible cadre 3"
L["Target frame 4"] = "Cible cadre 4"
L["Target frame 5"] = "Cible cadre 5"
L["Target bottom frame"] = "Cible cadre inférieur"
L["Target frame 1's pet"] = "Familiers du cadre 1"
L["Target frame 2's pet"] = "Familiers du cadre 2"
L["Target frame 3's pet"] = "Familiers du cadre 3"
L["Target frame 4's pet"] = "Familiers du cadre 4"
L["Target frame 5's pet"] = "Familiers du cadre 5"
L["Target enemy frame 1"] = "Cible cadre ennemi 1"
L["Target enemy frame 2"] = "Cible cadre ennemi 2"
L["Target enemy frame 3"] = "Cible cadre ennemi 3"
L["Target enemy frame 1's pet"] = "Familiers du cadre ennemi 1"
L["Target enemy frame 2's pet"] = "Familiers du cadre ennemi 2"
L["Target enemy frame 3's pet"] = "Familiers du cadre ennemi 3"
L["Focus enemy frame 1"] = "Focus cadre ennemi 1"
L["Focus enemy frame 2"] = "Focus cadre ennemi 2"
L["Focus enemy frame 3"] = "Focus cadre ennemi 3"
L["Cycle to the next frame"] = "Passer au cadre suivant"
L["Cycle to the previous frame"] = "Revenir au cadre précédent"
L["Target the next frame"] = "Cibler le cadre suivant"
L["Target the previous frame"] = "Cibler le cadre précédent"

-- # Keybindings screen #
L["Keybindings"] = "Raccourcis clavier"
L["Keybindings_Description"] = [[
Vous pouvez trouver les raccourcis clavier de FrameSort dans la section standard des raccourcis clavier de WoW.
\n
À quoi servent les raccourcis clavier?
Ils sont utiles pour cibler les joueurs selon leur représentation visuelle plutôt que leur position dans le groupe (groupe1/2/3/etc.)
\n
Par exemple, imaginez un groupe de donjon de 5 joueurs trié par rôle ressemblant à ceci :
  - Tank, groupe3
  - Soigneur, joueur
  - DPS, groupe1
  - DPS, groupe4
  - DPS, groupe2
\n
Comme vous pouvez le voir, leur représentation visuelle diffère de leur position réelle dans le groupe, ce qui rend le ciblage confus.
Si vous utilisez /cible groupe1, cela ciblera le joueur DPS en position 3 au lieu du tank.
\n
Les raccourcis clavier de FrameSort cibleront en fonction de leur position visuelle sur le cadre plutôt que du numéro du groupe.
Ainsi, cibler 'Cadre 1' ciblera le Tank, 'Cadre 2' le Soigneur, 'Cadre 3' le DPS en position 3, et ainsi de suite.
]]

-- # Macros screen # --
L["Macros"] = "Macros"
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort a trouvé %d|4macro:macros; à gérer."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort mettra à jour dynamiquement les variables dans les macros contenant l\'en-tête "#FrameSort".'
L["Below are some examples on how to use this."] = "Voici quelques exemples d'utilisation."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@soigneur,exists] Bénédiction de Sanctuaire]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@cadre1][mod:shift,@cadre2][mod:alt,@joueur][] Purification]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@pasdimportance] Pas de l'ombre;
/cast [@substitut] Coup de pied;]]

L["Example %d"] = "Exemple %d"
L["Supported variables:"] = "Variables supportées :"
L["The first DPS that's not you."] = "Le premier DPS qui n'est pas vous."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Ajoutez un numéro pour choisir la Nème cible, par exemple, DPS2 sélectionne le 2ème DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Les variables ne sont pas sensibles à la casse, donc 'fRaMe1', 'Dps', 'enemyhealer', etc., fonctionneront tous."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Besoin d'économiser des caractères de macro? Utilisez des abréviations pour les raccourcir :"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Utilisez "X" pour dire à FrameSort d\'ignorer un sélecteur @unité :'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,enemy][@soigneurennemi,exists][] Sort;]]

-- # Spacing screen #
L["Spacing"] = "Espacement"
L["Add some spacing between party/raid frames."] = "Ajoutez un peu d'espacement entre les cadres de groupe/raid."
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
Blizzard
 - Groupe : oui
 - Raid : oui
 - Arène : cassé (sera corrigé éventuellement).
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
 - Raid : oui, seulement lorsqu'on utilise des groupes combinés.
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Vous voulez intégrer FrameSort à vos addons, scripts, et Weak Auras?"
L["Here are some examples."] = "Voici quelques exemples."
L["Retrieved an ordered array of party/raid unit tokens."] = "Récupération d'un tableau ordonné de jetons d'unité de groupe/raid."
L["Retrieved an ordered array of arena unit tokens."] = "Récupération d'un tableau ordonné de jetons d'unité d'arène."
L["Register a callback function to run after FrameSort sorts frames."] = "Enregistrez une fonction de rappel à exécuter après le tri des cadres par FrameSort."
L["Retrieve an ordered array of party frames."] = "Récupération d'un tableau ordonné de cadres de groupe."
L["Change a FrameSort setting."] = "Modifier un paramètre FrameSort."
L["View a full listing of all API methods on GitHub."] = "Voir une liste complète de toutes les méthodes API sur GitHub."

-- # Help screen #
L["Help"] = "Aide"
L["Discord"] = "Discord"
L["Need help with something?"] = "Besoin d'aide pour quelque chose?"
L["Talk directly with the developer on Discord."] = "Parlez directement avec le développeur sur Discord."

-- # Health Check screen -- #
L["Health Check"] = "Vérification de santé"
L["Try this"] = "Essayez ceci"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Tout problème connu avec la configuration ou des addons en conflit sera affiché ci-dessous."
L["N/A"] = "N/A"
L["Passed!"] = "Réussi !"
L["Failed"] = "Échoué"
L["(unknown)"] = "(inconnu)"
L["(user macro)"] = "(macro utilisateur)"
L["Using grouped layout for Cell raid frames"] = "Utilisation de la mise en page groupée pour les cadres de raid Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Veuillez vérifier l'option 'Groupes combinés (Raid)' dans Cell -> Dispositions."
L["Can detect frames"] = "Peut détecter les cadres"
L["FrameSort currently supports frames from these addons: %s."] = "FrameSort prend actuellement en charge les cadres de ces addons : %s."
L["Using Raid-Style Party Frames"] = "Utilisation des cadres de groupe en style Raid"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Veuillez activer 'Utiliser les cadres de groupe en style Raid' dans les paramètres de Blizzard."
L["Keep Groups Together setting disabled"] = "Paramètre 'Garder les groupes ensemble' désactivé"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Changez le mode d'affichage du raid en une des options 'Groupes combinés' via le mode d'édition."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Désactivez le paramètre 'Garder les groupes ensemble' dans le profil du raid."
L["Only using Blizzard frames with Traditional mode"] = "Utilisation uniquement des cadres Blizzard avec le mode traditionnel"
L["Traditional mode can't sort your other frame addons: '%s'"] = "Le mode traditionnel ne peut pas trier vos autres addons de cadre : '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Utilisation du mode de tri sécurisé lorsque l'espacement est utilisé."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "Le mode traditionnel ne peut pas appliquer d'espacement, envisagez de supprimer l'espacement ou d'utiliser la méthode de tri sécurisé."
L["Blizzard sorting functions not tampered with"] = "Fonctions de tri de Blizzard non altérées"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" peut provoquer des conflits, envisagez de le désactiver.'
L["No conflicting addons"] = "Pas d'addons en conflit"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" peut provoquer des conflits, envisagez de le désactiver.'
L["Main tank and assist setting disabled"] = "Paramètre 'Tank principal et assistant' désactivé"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Veuillez désactiver l'option 'Afficher le tank principal et l'assistant' dans Options -> Interface -> Cadres de raid."

