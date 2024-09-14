local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "esMX" then
    return
end

L["FrameSort"] = nil
-- # Main Options screen #
L["FrameSort - %s"] = nil
L["There are some issuse that may prevent FrameSort from working correctly."] = "Hay algunos problemas que pueden prevenir que Ordenar Marco funcione correctamente."
L["Please go to the Health Check panel to view more details."] = "Por favor, ve al panel de Verificación de Salud para ver más detalles."
L["Role"] = "Rol"
L["Group"] = "Grupo"
L["Alphabetical"] = "Alfabético"
L["Arena - 2v2"] = "Arena - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 y 5v5"
L["Arena - %s"] = "Arena - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "Arena Enemiga (consulta el panel de addons para addons soportados)"
L["Dungeon (mythics, 5-mans)"] = "Mazmorras (míticas, 5 personas)"
L["Raid (battlegrounds, raids)"] = "Incursión (campos de batalla, incursiones)"
L["World (non-instance groups)"] = "Mundo (grupos no instanciados)"
L["Player"] = "Jugador"
L["Sort"] = "Ordenar"
L["Top"] = "Arriba"
L["Middle"] = "Medio"
L["Bottom"] = "Abajo"
L["Hidden"] = "Oculto"
L["Group"] = "Grupo"
L["Role"] = "Rol"
L["Reverse"] = "Invertir"

-- # Sorting Method screen #
L["Sorting Method"] = "Método de Ordenación"
L["Secure"] = "Seguro"
L["SortingMethod_Secure_Description"] = [[
Ajusta la posición de cada marco individual y no provoca fallos/bloqueos/contaminación de la interfaz.
\n
Pros:
 - Puede ordenar marcos de otros addons.
 - Puede aplicar espaciado entre marcos.
 - Sin contaminación (término técnico para addons que interfieren con el código de la interfaz de Blizzard).
\n
Cons:
 - Situación frágil, evitando el desorden de Blizzard.
 - Puede romperse con parches de WoW y hacer que el desarrollador pierda la cordura.
]]
L["Traditional"] = "Tradicional"
L["SortingMethod_Secure_Traditional"] = [[
Este es el modo de ordenación estándar que addons y macros han utilizado durante más de 10 años.
Reemplaza el método de ordenación interno de Blizzard con el nuestro.
Esto es lo mismo que el script 'SetFlowSortFunction' pero con la configuración de Ordenar Marco.
\n
Pros:
 - Más estable/fiable ya que aprovecha los métodos de ordenación internos de Blizzard.
\n
Cons:
 - Solo ordena marcos de fiesta de Blizzard, nada más.
 - Provocará errores de Lua, lo cual es normal y se puede ignorar.
 - No se puede aplicar espaciado entre marcos.
]]
L["Please reload after changing these settings."] = "Por favor, recarga después de cambiar estos ajustes."
L["Reload"] = "Recargar"

-- # Ordering screen #
L["Role"] = "Rol"
L["Specify the ordering you wish to use when sorting by role."] = "Especifica el orden que deseas utilizar al ordenar por rol."
L["Tanks"] = "Tanques"
L["Healers"] = "Sanadores"
L["Casters"] = "Hechiceros"
L["Hunters"] = "Cazadores"
L["Melee"] = "Cuerpo a cuerpo"

-- # Auto Leader screen #
L["Auto Leader"] = "Líder Automático"
L["Auto promote healers to leader in solo shuffle."] = "Promover automáticamente a los sanadores como líderes en el modo de rotación en solitario."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "¿Por qué? Para que los sanadores puedan configurar íconos de marcadores de objetivo y reordenar party1/2 a su preferencia."
L["Enabled"] = "Habilitado"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Apuntando"
L["Target frame 1 (top frame)"] = "Marco de objetivo 1 (marco superior)"
L["Target frame 2"] = "Marco de objetivo 2"
L["Target frame 3"] = "Marco de objetivo 3"
L["Target frame 4"] = "Marco de objetivo 4"
L["Target frame 5"] = "Marco de objetivo 5"
L["Target bottom frame"] = "Marco inferior de objetivo"
L["Target frame 1's pet"] = "Mascota del marco de objetivo 1"
L["Target frame 2's pet"] = "Mascota del marco de objetivo 2"
L["Target frame 3's pet"] = "Mascota del marco de objetivo 3"
L["Target frame 4's pet"] = "Mascota del marco de objetivo 4"
L["Target frame 5's pet"] = "Mascota del marco de objetivo 5"
L["Target enemy frame 1"] = "Objetivo del marco enemigo 1"
L["Target enemy frame 2"] = "Objetivo del marco enemigo 2"
L["Target enemy frame 3"] = "Objetivo del marco enemigo 3"
L["Target enemy frame 1's pet"] = "Mascota del marco enemigo 1"
L["Target enemy frame 2's pet"] = "Mascota del marco enemigo 2"
L["Target enemy frame 3's pet"] = "Mascota del marco enemigo 3"
L["Focus enemy frame 1"] = "Enfocar marco enemigo 1"
L["Focus enemy frame 2"] = "Enfocar marco enemigo 2"
L["Focus enemy frame 3"] = "Enfocar marco enemigo 3"
L["Cycle to the next frame"] = "Ciclar al siguiente marco"
L["Cycle to the previous frame"] = "Ciclar al marco anterior"
L["Target the next frame"] = "Objetiva el siguiente marco"
L["Target the previous frame"] = "Objetiva el marco anterior"

-- # Keybindings screen #
L["Keybindings"] = "Vínculos de Teclas"
L["Keybindings_Description"] = [[
Puedes encontrar los vínculos de teclas de Ordenar Marco en el área estándar de vínculos de teclas de WoW.
\n
¿Para qué son útiles los vínculos de teclas?
Son útiles para apuntar a jugadores según su representación visual ordenada más que su
posición en la fiesta (party1/2/3/etc.)
\n
Por ejemplo, imagina un grupo de mazmorras de 5 personas ordenado por rol que se ve como lo siguiente:
  - Tanque, party3
  - Sanador, jugador
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Como puedes ver, su representación visual difiere de su posición real en la fiesta, lo que
hace que el apuntar sea confuso.
Si fueras a /target party1, apuntaría al jugador DPS en la posición 3 en lugar del tanque.
\n
Los vínculos de teclas de Ordenar Marco apuntarán según su posición visual en el marco más que por número de fiesta.
Así que apuntar a 'Marco 1' apuntará al Tanque, 'Marco 2' al sanador, 'Marco 3' al DPS en el puesto 3, y así sucesivamente.
]]

-- # Macros screen # --
L["Macros"] = "Macros"
L["FrameSort has found %d|4macro:macros; to manage."] = "Ordenar Marco ha encontrado %d|4macro:macros; para gestionar."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = 'Ordenar Marco actualizará dinámicamente las variables dentro de macros que contengan el encabezado "#FrameSort".'
L["Below are some examples on how to use this."] = "A continuación hay algunos ejemplos de cómo usar esto."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists] Bendición de Santuario]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Dispersar]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] Paso de sombra;
/cast [@placeholder] Patada;]]

L["Example %d"] = "Ejemplo %d"
L["Supported variables:"] = "Variables soportadas:"
L["The first DPS that's not you."] = "El primer DPS que no eres tú."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Agrega un número para elegir el N objetivo, por ejemplo, DPS2 selecciona el 2º DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Las variables no son sensibles a mayúsculas así que 'fRaMe1', 'Dps', 'enemyhealer', etc., funcionarán."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "¿Necesitas ahorrar en caracteres de macros? Usa abreviaturas para acortarlos:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Usa "X" para decirle a Ordenar Marco que ignore un selector @unit:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Hechizo;]]

-- # Spacing screen #
L["Spacing"] = "Espaciado"
L["Add some spacing between party/raid frames."] = "Agrega un espaciado entre los marcos de fiesta/incursión."
L["This only applies to Blizzard frames."] = "Esto solo se aplica a los marcos de Blizzard."
L["Party"] = "Fiesta"
L["Raid"] = "Incursión"
L["Group"] = "Grupo"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertical"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
Ordenar Marco soporta lo siguiente:
\n
Blizzard
 - Fiesta: sí
 - Incursión: sí
 - Arena: roto (se arreglará eventualmente).
\n
ElvUI
 - Fiesta: sí
 - Incursión: no
 - Arena: no
\n
sArena
 - Arena: sí
\n
Gladius
 - Arena: sí
 - Versión de Bicmex: sí
\n
GladiusEx
 - Fiesta: sí
 - Arena: sí
\n
Cell
 - Fiesta: sí
 - Incursión: sí, solo cuando se usan grupos combinados.
\n
Shadowed Unit Frames
 - Fiesta: sí
 - Arena: sí
\n
Grid2
 - Fiesta/incursión: sí
\n
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "¿Quieres integrar Ordenar Marco en tus addons, scripts y Auras Débiles?"
L["Here are some examples."] = "Aquí hay algunos ejemplos."
L["Retrieved an ordered array of party/raid unit tokens."] = "Recuperó un arreglo ordenado de tokens de unidad de fiesta/incursión."
L["Retrieved an ordered array of arena unit tokens."] = "Recuperó un arreglo ordenado de tokens de unidad de arena."
L["Register a callback function to run after FrameSort sorts frames."] = "Registra una función de callback para ejecutar después de que Ordenar Marco ordene los marcos."
L["Retrieve an ordered array of party frames."] = "Recupera un arreglo ordenado de marcos de fiesta."
L["Change a FrameSort setting."] = "Cambia un ajuste de Ordenar Marco."
L["View a full listing of all API methods on GitHub."] = "Consulta un listado completo de todos los métodos de la API en GitHub."

-- # Help screen #
L["Help"] = "Ayuda"
L["Discord"] = "Discord"
L["Need help with something?"] = "¿Necesitas ayuda con algo?"
L["Talk directly with the developer on Discord."] = "Habla directamente con el desarrollador en Discord."

-- # Health Check screen -- #
L["Health Check"] = "Verificación de Salud"
L["Try this"] = "Prueba esto"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Cualquier problema conocido con la configuración o addons en conflicto se mostrará a continuación."
L["N/A"] = "N/A"
L["Passed!"] = "¡Aprobado!"
L["Failed"] = "Fallido"
L["(unknown)"] = "(desconocido)"
L["(user macro)"] = "(macro de usuario)"
L["Using grouped layout for Cell raid frames"] = "Usando diseño agrupado para marcos de incursión de Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Por favor, verifica la opción 'Grupos Combinados (Incursión)' en Cell -> Diseño."
L["Can detect frames"] = "Puede detectar marcos"
L["FrameSort currently supports frames from these addons: %s."] = "Ordenar Marco actualmente soporta marcos de estos addons: %s."
L["Using Raid-Style Party Frames"] = "Usando Marcos de Fiesta al Estilo Incursión"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Por favor, habilita 'Usar Marcos de Fiesta al Estilo Incursión' en los ajustes de Blizzard."
L["Keep Groups Together setting disabled"] = "Configuración de Mantener Grupos Juntos deshabilitada"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Cambia el modo de visualización de incursiones a una de las opciones de 'Grupos Combinados' a través del Modo de Edición."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Deshabilita la configuración del perfil de incursión 'Mantener Grupos Juntos'."
L["Only using Blizzard frames with Traditional mode"] = "Solo usando marcos de Blizzard con modo Tradicional"
L["Traditional mode can't sort your other frame addons: '%s'"] = "El modo Tradicional no puede ordenar tus otros addons de marco: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Usando modo de ordenación Seguro cuando se está usando espaciado."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "El modo Tradicional no puede aplicar espaciado, considera eliminar el espaciado o usar el método de ordenación Seguro."
L["Blizzard sorting functions not tampered with"] = "Funciones de ordenación de Blizzard no alteradas"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" puede causar conflictos, considera deshabilitarlo.'
L["No conflicting addons"] = "No hay addons en conflicto"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" puede causar conflictos, considera deshabilitarlo.'
L["Main tank and assist setting disabled"] = "Configuración de tanque principal y asistente deshabilitada"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Por favor, deshabilita la opción 'Mostrar Tanque Principal y Asistente' en Opciones -> Interfaz -> Marcos de Incursión."
