local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "esES" then
    return
end

L["FrameSort"] = "OrdenarMarcos"

-- # Main Options screen #
L["FrameSort - %s"] = "OrdenarMarcos - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Hay algunos problemas que pueden impedir que OrdenarMarcos funcione correctamente."
L["Please go to the Health Check panel to view more details."] = "Por favor, dirígete al panel de Verificación de Salud para ver más detalles."
L["Role"] = "Rol"
L["Group"] = "Grupo"
L["Alpha"] = "Alfa"
L["party1 > party2 > partyN > partyN+1"] = "party1 > party2 > partyN > partyN+1"
L["tank > healer > dps"] = "tanque > sanador > dps"
L["NameA > NameB > NameZ"] = "NombreA > NombreB > NombreZ"
L["healer > tank > dps"] = "sanador > tanque > dps"
L["healer > dps > tank"] = "sanador > dps > tanque"
L["tank > healer > dps"] = "tanque > sanador > dps"
L["Arena - 2v2"] = "Arena - 2v2"
L["3v3"] = "3v3"
L["3v3 & 5v5"] = "3v3 & 5v5"
L["Arena - %s"] = "Arena - %s"
L["Enemy Arena (see addons panel for supported addons)"] = "Arena enemiga (ver el panel de addons para addons compatibles)"
L["Dungeon (mythics, 5-mans)"] = "Mazmorras (miticas, 5 jugadores)"
L["Raid (battlegrounds, raids)"] = "Banda (campos de batalla, incursiones)"
L["World (non-instance groups)"] = "Mundo (grupos no instanciados)"
L["Player:"] = "Jugador:"
L["Top"] = "Superior"
L["Middle"] = "Medio"
L["Bottom"] = "Inferior"
L["Hidden"] = "Oculto"
L["Group"] = "Grupo"
L["Role"] = "Rol"
L["Alpha"] = "Alfa"
L["Reverse"] = "Invertir"

-- # Sorting Method screen #
L["Sorting Method"] = "Método de Ordenación"
L["Secure"] = "Seguro"
L["SortingMethod_Secure_Description"] = [[
Ajusta la posición de cada marco individual y no bloquea/bloquea/contamina la interfaz de usuario.
\n
Pros:
 - Puede ordenar marcos de otros addons.
 - Puede aplicar espaciado entre marcos.
 - Sin contaminación (término técnico para addons que interfieren con el código de la UI de Blizzard).
\n
Contras:
 - Situación frágil para evitar los problemas del código de Blizzard.
 - Puede romperse con los parches de WoW y hacer que el desarrollador se vuelva loco.
]]
L["Traditional"] = "Tradicional"
L["SortingMethod_Secure_Traditional"] = [[
Este es el modo de ordenación estándar que los addons y macros han utilizado durante más de 10 años.
Reemplaza el método interno de ordenación de Blizzard con el nuestro.
Esto es lo mismo que el script 'SetFlowSortFunction' pero con la configuración de OrdenarMarcos.
\n
Pros:
 - Más estable/confiable ya que aprovecha los métodos internos de ordenación de Blizzard.
\n
Contras:
 - Solo ordena los marcos de grupo de Blizzard, nada más.
 - Puede causar errores de Lua, lo cual es normal y puede ser ignorado.
 - No puede aplicar espaciado entre marcos.
]]
L["Please reload after changing these settings."] = "Por favor, recarga después de cambiar estas configuraciones."
L["Reload"] = "Recargar"

-- # Role Ordering screen #
L["Role Ordering"] = "Ordenación por Rol"
L["Specify the ordering you wish to use when sorting by role."] = "Especifica el orden que deseas usar al ordenar por rol."
L["Tank > Healer > DPS"] = "Tanque > Sanador > DPS"
L["Healer > Tank > DPS"] = "Sanador > Tanque > DPS"
L["Healer > DPS > Tank"] = "Sanador > DPS > Tanque"

-- # Auto Leader screen #
L["Auto Leader"] = "Líder Automático"
L["Auto promote healers to leader in solo shuffle."] = "Promover automáticamente a los sanadores a líder en el sorteo en solitario."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "¿Por qué? Para que los sanadores puedan configurar los íconos de marcador de objetivo y reorganizar party1/2 a su preferencia."
L["Enabled"] = "Habilitado"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Apuntar"
L["Target frame 1 (top frame)"] = "Apuntar al marco 1 (marco superior)"
L["Target frame 2"] = "Apuntar al marco 2"
L["Target frame 3"] = "Apuntar al marco 3"
L["Target frame 4"] = "Apuntar al marco 4"
L["Target frame 5"] = "Apuntar al marco 5"
L["Target bottom frame"] = "Apuntar al marco inferior"
L["Target frame 1's pet"] = "Apuntar a la mascota del marco 1"
L["Target frame 2's pet"] = "Apuntar a la mascota del marco 2"
L["Target frame 3's pet"] = "Apuntar a la mascota del marco 3"
L["Target frame 4's pet"] = "Apuntar a la mascota del marco 4"
L["Target frame 5's pet"] = "Apuntar a la mascota del marco 5"
L["Target enemy frame 1"] = "Apuntar al marco enemigo 1"
L["Target enemy frame 2"] = "Apuntar al marco enemigo 2"
L["Target enemy frame 3"] = "Apuntar al marco enemigo 3"
L["Target enemy frame 1's pet"] = "Apuntar a la mascota del marco enemigo 1"
L["Target enemy frame 2's pet"] = "Apuntar a la mascota del marco enemigo 2"
L["Target enemy frame 3's pet"] = "Apuntar a la mascota del marco enemigo 3"
L["Focus enemy frame 1"] = "Enfocar el marco enemigo 1"
L["Focus enemy frame 2"] = "Enfocar el marco enemigo 2"
L["Focus enemy frame 3"] = "Enfocar el marco enemigo 3"
L["Cycle to the next frame"] = "Ciclar al siguiente marco"
L["Cycle to the previous frame"] = "Ciclar al marco anterior"
L["Target the next frame"] = "Apuntar al siguiente marco"
L["Target the previous frame"] = "Apuntar al marco anterior"

-- # Keybindings screen #
L["Keybindings"] = "Atajos de Teclado"
L["Keybindings_Description"] = [[
Puedes encontrar los atajos de teclado de OrdenarMarcos en el área estándar de atajos de teclado de WoW.
\n
¿Para qué son útiles los atajos de teclado?
Son útiles para apuntar a los jugadores según su representación visual ordenada en lugar de su
posición en el grupo (party1/2/3/etc.)
\n
Por ejemplo, imagina un grupo de mazmorras de 5 personas ordenado por rol que se ve de la siguiente manera:
  - Tanque, party3
  - Sanador, jugador
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Como puedes ver, su representación visual difiere de su posición real en el grupo, lo que
hace que apuntar sea confuso.
Si fueras a /target party1, apuntaría al jugador DPS en la posición 3 en lugar del tanque.
\n
Los atajos de teclado de OrdenarMarcos apuntarán según la posición visual del marco en lugar del número del grupo.
Así que apuntar al 'Marco 1' apuntará al Tanque, 'Marco 2' al sanador, 'Marco 3' al DPS en la posición 3, y así sucesivamente.
]]

-- # Macros screen # --
L["Macros"] = "Macros"
L["FrameSort has found %d|4macro:macros; to manage."] = "OrdenarMarcos ha encontrado %d|4macro:macros; para gestionar."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "OrdenarMarcos actualizará dinámicamente las variables dentro de los macros que contienen el encabezado '#FrameSort'."
L["Below are some examples on how to use this."] = "A continuación se muestran algunos ejemplos de cómo usar esto."

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][

@healer,exists] Bendición de Santuario]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Disipar]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] Paso de Sombra;
/cast [@placeholder] Patada;]]

L["Example %d"] = "Ejemplo %d"
L["Supported variables:"] = "Variables soportadas:"
L["The first DPS that's not you."] = "El primer DPS que no eres tú."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Añade un número para elegir el N objetivo, por ejemplo, DPS2 selecciona el 2º DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Las variables no distinguen entre mayúsculas y minúsculas, por lo que 'fRaMe1', 'Dps', 'enemyhealer', etc., funcionarán."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "¿Necesitas guardar en personajes de macros? Usa abreviaciones para acortarlas:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Usa "X" para decirle a OrdenarMarcos que ignore un selector @unit:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Hechizo;]]

-- # Spacing screen #
L["Spacing"] = "Espaciado"
L["Add some spacing between party/raid frames."] = "Añadir un espaciado entre los marcos de grupo/raid."
L["This only applies to Blizzard frames."] = "Esto solo se aplica a los marcos de Blizzard."
L["Party"] = "Grupo"
L["Raid"] = "Incursión"
L["Group"] = "Grupo"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertical"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
OrdenarMarcos soporta los siguientes:
\n
Blizzard
 - Grupo: sí
 - Banda: sí
 - Arena: roto (lo arreglaremos eventualmente).
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
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "¿Quieres integrar OrdenarMarcos en tus addons, scripts y Auras Débiles?"
L["Here are some examples."] = "Aquí hay algunos ejemplos."
L["Retrieved an ordered array of party/raid unit tokens."] = "Recuperó una matriz ordenada de tokens de unidades de grupo/incursión."
L["Retrieved an ordered array of arena unit tokens."] = "Recuperó una matriz ordenada de tokens de unidades de arena."
L["Register a callback function to run after FrameSort sorts frames."] = "Registra una función de retorno de llamada para ejecutar después de que OrdenarMarcos ordene los marcos."
L["Retrieve an ordered array of party frames."] = "Recuperar una matriz ordenada de marcos de grupo."
L["Change a FrameSort setting."] = "Cambiar una configuración de OrdenarMarcos."
L["View a full listing of all API methods on GitHub."] = "Ver una lista completa de todos los métodos de API en GitHub."

-- # Help screen #
L["Help"] = "Ayuda"
L["Discord"] = "Discord"
L["Need help with something?"] = "¿Necesitas ayuda con algo?"
L["Talk directly with the developer on Discord."] = "Habla directamente con el desarrollador en Discord."

-- # Health Check screen -- #
L["Health Check"] = "Verificación de Salud"
L["Try this"] = "Prueba esto"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Cualquier problema conocido con la configuración o addons conflictivos se mostrará a continuación."
L["N/A"] = "N/A"
L["Passed!"] = "¡Aprobado!"
L["Failed"] = "Fallido"
L["(unknown)"] = "(desconocido)"
L["(user macro)"] = "(macro de usuario)"
L["Using grouped layout for Cell raid frames"] = "Usando diseño agrupado para los marcos de raid de Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Por favor, revisa la opción 'Grupos Combinados (Raid)' en Cell -> Diseños."
L["Can detect frames"] = "Puede detectar marcos"
L["FrameSort currently supports frames from these addons: %s."] = "OrdenarMarcos actualmente soporta marcos de estos addons: %s."
L["Using Raid-Style Party Frames"] = "Usando marcos de grupo estilo Raid"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Por favor, habilita 'Usar marcos de grupo estilo Raid' en la configuración de Blizzard."
L["Keep Groups Together setting disabled"] = "Configuración de Mantener Grupos Juntos desactivada"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Cambia el modo de visualización de raid a una de las opciones de 'Grupos Combinados' a través del Modo de Edición."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Desactiva la configuración del perfil de raid 'Mantener Grupos Juntos'."
L["Only using Blizzard frames with Traditional mode"] = "Solo se usan marcos de Blizzard con el modo Tradicional"
L["Traditional mode can't sort your other frame addons: '%s'"] = "El modo Tradicional no puede ordenar tus otros addons de marcos: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Usando el modo de ordenación Seguro cuando se está usando espaciado."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "El modo Tradicional no puede aplicar espaciado, considera eliminar el espaciado o usar el método de ordenación Seguro."
L["Blizzard sorting functions not tampered with"] = "Funciones de ordenación de Blizzard no manipuladas"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" puede causar conflictos, considera desactivarlo.'
L["No conflicting addons"] = "Sin addons conflictivos"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" puede causar conflictos, considera desactivarlo.'
L["Main tank and assist setting disabled"] = "Configuración de tanque principal y asistente desactivada"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Por favor, desactiva la opción 'Mostrar Tanque Principal y Asistente' en Opciones -> Interfaz -> Marcos de Raid."
