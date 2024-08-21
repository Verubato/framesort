local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "esMX" then
    return
end

L["FrameSort"] = nil

-- # Main Options screen #
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Hay algunos problemas que podrían impedir que FrameSort funcione correctamente."
L["Please go to the Health Check panel to view more details."] = "Por favor, ve al panel de Verificación de Salud para ver más detalles."
L["Role"] = "Rol"
L["Group"] = "Grupo"
L["Alpha"] = "Alfa"
L["party1 > party2 > partyN > partyN+1"] = "grupo1 > grupo2 > grupoN > grupoN+1"
L["tank > healer > dps"] = "tanque > sanador > dps"
L["NameA > NameB > NameZ"] = "NombreA > NombreB > NombreZ"
L["healer > tank > dps"] = "sanador > tanque > dps"
L["healer > dps > tank"] = "sanador > dps > tanque"
L["tank > healer > dps"] = "tanque > sanador > dps"
L["Arena - 2v2"] = "Arena - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 y 5v5"
L["Arena - %s"] = "Arena - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "Arena enemiga (ver panel de addons para addons soportados)"
L["Dungeon (mythics, 5-mans)"] = "Mazmorra (míticas, grupos de 5)"
L["Raid (battlegrounds, raids)"] = "Banda (campos de batalla, bandas)"
L["World (non-instance groups)"] = "Mundo (grupos no instanciados)"
L["Player"] = "Jugador"
L["Sort"] = "Ordenar"
L["Top"] = "Arriba"
L["Middle"] = "Medio"
L["Bottom"] = "Abajo"
L["Hidden"] = "Oculto"
L["Group"] = "Grupo"
L["Role"] = "Rol"
L["Alpha"] = "Alfa"
L["Reverse"] = "Revertir"

-- # Sorting Method screen #
L["Sorting Method"] = "Método de ordenación"
L["Secure"] = "Seguro"
L["SortingMethod_Secure_Description"] = [[
Ajusta la posición de cada marco individual y no bloquea/interfiere con la IU.
\n
Pros:
 - Puede ordenar marcos de otros addons.
 - Puede aplicar espacios entre marcos.
 - Sin contaminación (término técnico para addons que interfieren con el código de la IU de Blizzard).
\n
Contras:
 - Situación frágil para evitar problemas con el código de Blizzard.
 - Puede romperse con parches de WoW y volver loco al desarrollador.
]]
L["Traditional"] = "Tradicional"
L["SortingMethod_Secure_Traditional"] = [[
Este es el modo de ordenación estándar que han utilizado los addons y macros durante más de 10 años.
Reemplaza el método de ordenación interno de Blizzard con el nuestro.
Esto es lo mismo que el script 'SetFlowSortFunction' pero con la configuración de FrameSort.
\n
Pros:
 - Más estable/confiable, ya que aprovecha los métodos de ordenación internos de Blizzard.
\n
Contras:
 - Solo ordena los marcos de grupo de Blizzard, nada más.
 - Causará errores de Lua, lo cual es normal y se puede ignorar.
 - No puede aplicar espacios entre marcos.
]]
L["Please reload after changing these settings."] = "Por favor, recarga la IU después de cambiar estas configuraciones."
L["Reload"] = "Recargar"

-- # Role Ordering screen #
L["Role Ordering"] = "Orden de roles"
L["Specify the ordering you wish to use when sorting by role."] = "Especifica el orden que deseas usar al ordenar por rol."
L["Tank > Healer > DPS"] = "Tanque > Sanador > DPS"
L["Healer > Tank > DPS"] = "Sanador > Tanque > DPS"
L["Healer > DPS > Tank"] = "Sanador > DPS > Tanque"

-- # Auto Leader screen #
L["Auto Leader"] = "Líder automático"
L["Auto promote healers to leader in solo shuffle."] = "Promover automáticamente a los sanadores a líderes en mezclas solitarias."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "¿Por qué? Para que los sanadores puedan configurar íconos de marcadores de objetivo y reorganizar grupo1/2 a su preferencia."
L["Enabled"] = "Habilitado"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Selección de objetivo"
L["Target frame 1 (top frame)"] = "Marco de objetivo 1 (marco superior)"
L["Target frame 2"] = "Marco de objetivo 2"
L["Target frame 3"] = "Marco de objetivo 3"
L["Target frame 4"] = "Marco de objetivo 4"
L["Target frame 5"] = "Marco de objetivo 5"
L["Target bottom frame"] = "Marco de objetivo inferior"
L["Target frame 1's pet"] = "Mascota del marco de objetivo 1"
L["Target frame 2's pet"] = "Mascota del marco de objetivo 2"
L["Target frame 3's pet"] = "Mascota del marco de objetivo 3"
L["Target frame 4's pet"] = "Mascota del marco de objetivo 4"
L["Target frame 5's pet"] = "Mascota del marco de objetivo 5"
L["Target enemy frame 1"] = "Marco de objetivo enemigo 1"
L["Target enemy frame 2"] = "Marco de objetivo enemigo 2"
L["Target enemy frame 3"] = "Marco de objetivo enemigo 3"
L["Target enemy frame 1's pet"] = "Mascota del marco de objetivo enemigo 1"
L["Target enemy frame 2's pet"] = "Mascota del marco de objetivo enemigo 2"
L["Target enemy frame 3's pet"] = "Mascota del marco de objetivo enemigo 3"
L["Focus enemy frame 1"] = "Fijar marco de objetivo enemigo 1"
L["Focus enemy frame 2"] = "Fijar marco de objetivo enemigo 2"
L["Focus enemy frame 3"] = "Fijar marco de objetivo enemigo 3"
L["Cycle to the next frame"] = "Cambiar al siguiente marco"
L["Cycle to the previous frame"] = "Cambiar al marco anterior"
L["Target the next frame"] = "Seleccionar el siguiente marco"
L["Target the previous frame"] = "Seleccionar el marco anterior"

-- # Keybindings screen #
L["Keybindings"] = "Atajos de teclado"
L["Keybindings_Description"] = [[
Puedes encontrar los atajos de teclado de FrameSort en el área estándar de atajos de teclado de WoW.
\n
¿Para qué son útiles los atajos de teclado?
Son útiles para seleccionar jugadores según su representación visual ordenada en lugar de su posición en el grupo (grupo1/2/3/etc.)
\n
Por ejemplo, imagina un grupo de mazmorra de 5 jugadores ordenado por rol que se ve de la siguiente manera:
  - Tanque, grupo3
  - Sanador, jugador
  - DPS, grupo1
  - DPS, grupo4
  - DPS, grupo2
\n
Como puedes ver, su representación visual difiere de su posición real en el grupo, lo que hace que la selección de objetivos sea confusa.
Si usas /target grupo1, seleccionará al jugador DPS en la posición 3 en lugar del tanque.
\n
Los atajos de teclado de FrameSort seleccionarán según su posición visual en el marco en lugar del número del grupo.
Entonces, seleccionar 'Marco 1' seleccionará al Tanque, 'Marco 2' al Sanador, 'Marco 3' al DPS en la posición 3, y así sucesivamente.
]]

-- # Macros screen # --
L["Macros"] = "Macros"
L["FrameSort has found %d|4macro:macros; to manage."] = "FrameSort ha encontrado %d|4macro:macros; para gestionar."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'FrameSort actualizará dinámicamente las variables dentro de los macros que contengan el encabezado "#FrameSort".'
L["Below are some examples on how to use this."] = "A continuación se presentan algunos ejemplos de cómo usar esto."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@sanador,exists] Bendición del Santuario]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@marco1][mod:shift,@marco2][mod:alt,@jugador][] Disipar]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@nodamalcuente] Paso de las sombras;
/cast [@reservado] Patada;]]

L["Example %d"] = "Ejemplo %d"
L["Supported variables:"] = "Variables soportadas:"
L["The first DPS that's not you."] = "El primer DPS que no eres tú."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Añade un número para elegir el objetivo N-ésimo, por ejemplo, DPS2 selecciona el 2.º DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Las variables no distinguen entre mayúsculas y minúsculas, por lo que 'fRaMe1', 'Dps', 'enemyhealer', etc., funcionarán."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "¿Necesitas ahorrar caracteres en macros? Usa abreviaturas para acortarlas:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Usa "X" para decirle a FrameSort que ignore un selector de @unidad:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@foco][@mouseover,enemy][@sanadorenemigo,exists][] Hechizo;]]

-- # Spacing screen #
L["Spacing"] = "Espaciado"
L["Add some spacing between party/raid frames."] = "Añadir algo de espacio entre los marcos de grupo/banda."
L["This only applies to Blizzard frames."] = "Esto solo se aplica a los marcos de Blizzard."
L["Party"] = "Grupo"
L["Raid"] = "Banda"
L["Group"] = "Grupo"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertical"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
FrameSort es compatible con lo siguiente:
\n
Blizzard
 - Grupo: sí
 - Banda: sí
 - Arena: roto (lo arreglaré eventualmente).
\n
ElvUI
 - Grupo: sí
 - Banda: no
 - Arena: no
\n
sArena
 - Arena: sí
\n
Gladius
 - Arena: sí
 - Versión Bicmex: sí
\n
GladiusEx
 - Grupo: sí
 - Arena: sí
\n
Cell
 - Grupo: sí
 - Banda: sí, solo al usar grupos combinados.
\n
Shadowed Unit Frames
 - Grupo: sí
 - Arena: sí
\n
Grid2
 - Grupo/banda: sí
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "¿Quieres integrar FrameSort en tus addons, scripts y Weak Auras?"
L["Here are some examples."] = "Aquí tienes algunos ejemplos."
L["Retrieved an ordered array of party/raid unit tokens."] = "Obtenido un array ordenado de tokens de unidad de grupo/banda."
L["Retrieved an ordered array of arena unit tokens."] = "Obtenido un array ordenado de tokens de unidad de arena."
L["Register a callback function to run after FrameSort sorts frames."] = "Registra una función de retorno que se ejecute después de que FrameSort ordene los marcos."
L["Retrieve an ordered array of party frames."] = "Obtenido un array ordenado de marcos de grupo."
L["Change a FrameSort setting."] = "Cambiar una configuración de FrameSort."
L["View a full listing of all API methods on GitHub."] = "Ver una lista completa de todos los métodos API en GitHub."

-- # Help screen #
L["Help"] = "Ayuda"
L["Discord"] = "Discord"
L["Need help with something?"] = "¿Necesitas ayuda con algo?"
L["Talk directly with the developer on Discord."] = "Habla directamente con el desarrollador en Discord."

-- # Health Check screen -- #
L["Health Check"] = "Verificación de Salud"
L["Try this"] = "Intenta esto"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Cualquier problema conocido con la configuración o addons conflictivos se mostrará a continuación."
L["N/A"] = "N/D"
L["Passed!"] = "¡Aprobado!"
L["Failed"] = "Fallido"
L["(unknown)"] = "(desconocido)"
L["(user macro)"] = "(macro del usuario)"
L["Using grouped layout for Cell raid frames"] = "Usando diseño agrupado para marcos de banda de Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Por favor, verifica la opción 'Grupos combinados (Banda)' en Cell -> Diseños."
L["Can detect frames"] = "Puede detectar marcos"
L["FrameSort currently supports frames from these addons: %s."] = "FrameSort actualmente soporta marcos de estos addons: %s."
L["Using Raid-Style Party Frames"] = "Usando marcos de grupo estilo banda"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Por favor, habilita 'Usar marcos de grupo estilo banda' en los ajustes de Blizzard."
L["Keep Groups Together setting disabled"] = "Ajuste 'Mantener grupos juntos' deshabilitado"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Cambia el modo de visualización de banda a una de las opciones 'Grupos combinados' a través del Modo de Edición."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Desactiva el ajuste 'Mantener grupos juntos' en el perfil de banda."
L["Only using Blizzard frames with Traditional mode"] = "Solo usando marcos de Blizzard con modo tradicional"
L["Traditional mode can't sort your other frame addons: '%s'"] = "El modo tradicional no puede ordenar tus otros addons de marcos: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Usando modo de ordenación seguro cuando se está utilizando espaciado."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "El modo tradicional no puede aplicar espaciado, considera eliminar el espaciado o usar el método de ordenación seguro."
L["Blizzard sorting functions not tampered with"] = "Funciones de ordenación de Blizzard no manipuladas"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" puede causar conflictos, considera deshabilitarlo.'
L["No conflicting addons"] = "No hay addons conflictivos"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" puede causar conflictos, considera deshabilitarlo.'
L["Main tank and assist setting disabled"] = "Ajuste de tanque principal y asistente deshabilitado"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Por favor, desactiva la opción 'Mostrar tanque principal y asistente' en Opciones -> Interfaz -> Marcos de Banda."

