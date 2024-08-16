local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "esMX" then
    return
end

L["FrameSort"] = "OrdenarMarcos"

-- # Main Options screen #
L["FrameSort - %s"] = "OrdenarMarcos - %s"
L["There are some issuse that may prevent FrameSort from working correctly."] = "Hay algunos problemas que pueden impedir que OrdenarMarcos funcione correctamente."
L["Please go to the Health Check panel to view more details."] = "Por favor, ve al panel de Verificación de Salud para ver más detalles."
L["Role"] = "Rol"
L["Group"] = "Grupo"
L["Alpha"] = "Alpha"
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
L["Enemy Arena (see addons panel for supported addons)"] = "Arena enemiga (consulta el panel de addons para addons compatibles)"
L["Dungeon (mythics, 5-mans)"] = "Mazmorras (míticas, 5 jugadores)"
L["Raid (battlegrounds, raids)"] = "Banda (campos de batalla, bandas)"
L["World (non-instance groups)"] = "Mundo (grupos no instanciados)"
L["Player:"] = "Jugador:"
L["Top"] = "Superior"
L["Middle"] = "Medio"
L["Bottom"] = "Inferior"
L["Hidden"] = "Oculto"
L["Group"] = "Grupo"
L["Role"] = "Rol"
L["Alpha"] = "Alpha"
L["Reverse"] = "Invertir"

-- # Sorting Method screen #
L["Sorting Method"] = "Método de Ordenación"
L["Secure"] = "Seguro"
L["SortingMethod_Secure_Description"] = [[
Ajusta la posición de cada marco individualmente y bloquea/asegura el código de la interfaz de usuario de Blizzard.
\n
Ventajas:
 - Puede ordenar los marcos de otros addons.
 - Puede aplicar espaciado entre marcos.
 - Sin contaminación (término técnico para addons que afectan el código de la interfaz de Blizzard).
\n
Desventajas:
 - Situación frágil para evitar problemas con el código de Blizzard.
 - Puede romperse con parches de WoW y volver loco al desarrollador.
]]
L["Traditional"] = "Tradicional"
L["SortingMethod_Secure_Traditional"] = [[
Este es el modo de ordenación predeterminado que los addons y macros han usado durante más de 10 años.
Sustituye el método de ordenación interno de Blizzard por el nuestro.
Es lo mismo que el script 'SetFlowSortFunction', pero con la configuración de OrdenarMarcos.
\n
Ventajas:
 - Más estable/confiable, ya que usa los métodos de ordenación internos de Blizzard.
\n
Desventajas:
 - Solo ordena los marcos de grupo de Blizzard, nada más.
 - Puede causar errores Lua que son normales y pueden ser ignorados.
 - No puede aplicar espaciado entre marcos.
]]
L["Please reload after changing these settings."] = "Por favor, recarga después de cambiar estas configuraciones."
L["Reload"] = "Recargar"

-- # Role Ordering screen #
L["Role Ordering"] = "Ordenación de Roles"
L["Specify the ordering you wish to use when sorting by role."] = "Especifica el orden que deseas usar al ordenar por rol."
L["Tank > Healer > DPS"] = "Tanque > Sanador > DPS"
L["Healer > Tank > DPS"] = "Sanador > Tanque > DPS"
L["Healer > DPS > Tank"] = "Sanador > DPS > Tanque"

-- # Auto Leader screen #
L["Auto Leader"] = "Líder Automático"
L["Auto promote healers to leader in solo shuffle."] = "Promover automáticamente a los sanadores a líder en el orden aleatorio en solitario."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = "¿Por qué? Para que los sanadores puedan configurar los íconos de marcador de objetivo y reordenar party1/2 a su preferencia."
L["Enabled"] = "Habilitado"

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Objetivo"
L["Target frame 1 (top frame)"] = "Objetivo el marco 1 (marco superior)"
L["Target frame 2"] = "Objetivo el marco 2"
L["Target frame 3"] = "Objetivo el marco 3"
L["Target frame 4"] = "Objetivo el marco 4"
L["Target frame 5"] = "Objetivo el marco 5"
L["Target bottom frame"] = "Objetivo el marco inferior"
L["Target frame 1's pet"] = "Objetivo la mascota del marco 1"
L["Target frame 2's pet"] = "Objetivo la mascota del marco 2"
L["Target frame 3's pet"] = "Objetivo la mascota del marco 3"
L["Target frame 4's pet"] = "Objetivo la mascota del marco 4"
L["Target frame 5's pet"] = "Objetivo la mascota del marco 5"
L["Target enemy frame 1"] = "Objetivo el marco enemigo 1"
L["Target enemy frame 2"] = "Objetivo el marco enemigo 2"
L["Target enemy frame 3"] = "Objetivo el marco enemigo 3"
L["Target enemy frame 1's pet"] = "Objetivo la mascota del marco enemigo 1"
L["Target enemy frame 2's pet"] = "Objetivo la mascota del marco enemigo 2"
L["Target enemy frame 3's pet"] = "Objetivo la mascota del marco enemigo 3"
L["Focus enemy frame 1"] = "Enfocar el marco enemigo 1"
L["Focus enemy frame 2"] = "Enfocar el marco enemigo 2"
L["Focus enemy frame 3"] = "Enfocar el marco enemigo 3"
L["Cycle to the next frame"] = "Cambiar al siguiente marco"
L["Cycle to the previous frame"] = "Cambiar al marco anterior"
L["Target the next frame"] = "Objetivo el siguiente marco"
L["Target the previous frame"] = "Objetivo el marco anterior"

-- # Keybindings screen #
L["Keybindings"] = "Teclas de acceso rápido"
L["Keybindings_Description"] = [[
Encuentra las teclas de acceso rápido de OrdenarMarcos en la sección de teclas de acceso rápido estándar de WoW.
\n
¿Por qué son útiles las teclas de acceso rápido?
Son útiles para apuntar a los jugadores según sus representaciones visuales en lugar de su posición en el grupo (party1/2/3/etc.).
\n
Por ejemplo, imagina un grupo de mazmorras de 5 personas ordenado por rol y que se vea así:
  - Tanque, party3
  - Sanador, jugador
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Como puedes ver, su representación visual difiere de su posición real en el grupo, lo que puede resultar confuso para apuntar.
Si usas /target party1, apunta al DPS en la posición 3 en lugar del Tanque.
\n
Las teclas de acceso rápido de OrdenarMarcos apuntan basándose en la posición visual del marco en lugar de en el número del grupo.
Así que 'Marco 1' apunta al Tanque, 'Marco 2' al Sanador, 'Marco 3' al DPS en la posición 3, y así sucesivamente.
]]

-- # Macros screen # --
L["Macros"] = "Macros"
L["FrameSort has found %d|4macro:macros; to manage."] = "OrdenarMarcos ha encontrado %d|4macro:macros; para gestionar."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = "OrdenarMarcos actualizará dinámicamente las variables dentro de los macros que contengan el encabezado '#OrdenarMarcos'."
L["Below are some examples on how to use this."] = "A continuación, algunos ejemplos de cómo usar esto."
L["Macro Example"] = "Ejemplo de Macro"
L["Macro_Example1"] = [[
#showtooltip
#OrdenarMarcos Tanque, Sanador, DPS1
/cast [mod:shift,@tanque

][mod:alt,@sanador][mod:ctrl,@dps1][] Sanación]]
L["Macro_Example2"] = [[
#showtooltip
#OrdenarMarcos Marco1, Marco2, Jugador
/cast [mod:ctrl,@marco1][mod:shift,@marco2][mod:alt,@jugador][] Disipar]]
L["Macro_Example3"] = [[
#OrdenarMarcos EnemigoSanador, EnemigoSanador
/cast [@igual] Paso de Sombra;
/cast [@espacio] Mina Terrestre;]]
L["Example %d"] = "Ejemplo %d"
L["Supported variables:"] = "Variables soportadas:"
L["The first DPS that's not you."] = "El primer DPS que no eres tú."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Agrega un número para elegir el N-ésimo objetivo, por ejemplo, DPS2 selecciona el 2º DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = "Las variables no distinguen entre mayúsculas y minúsculas, por lo que 'fRaMe1', 'Dps', 'enemyhealer', etc., funcionarán."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "¿Necesitas guardar en caracteres de macro? Usa abreviaturas para acortarlos:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Usa "X" para indicar a OrdenarMarcos que ignore un selector @unit:'
L["Skip_Example"] = [[
#FS X X EnemigoSanador
/cast [mod:shift,@foco][@mouseover,harm][@enemigosanador,exists][] Hechizo;]]

-- # Spacing screen #
L["Spacing"] = "Espaciado"
L["Add some spacing between party/raid frames."] = "Agrega algo de espaciado entre los marcos de grupo/raid."
L["This only applies to Blizzard frames."] = "Esto solo se aplica a los marcos de Blizzard."
L["Party"] = "Grupo"
L["Raid"] = "Raid"
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
 - Raid: sí
 - Arena: roto (lo repararemos en algún momento).
\n
ElvUI
 - Grupo: sí
 - Raid: no
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
 - Raid: sí, solo cuando se usan grupos combinados.
]]

-- # Api screen #
L["Api"] = "Api"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "¿Quieres integrar OrdenarMarcos en tus addons, scripts y Weak Auras?"
L["Here are some examples."] = "Aquí tienes algunos ejemplos."
L["Retrieved an ordered array of party/raid unit tokens."] = "Se ha recuperado una matriz ordenada de tokens de unidades de grupo/raid."
L["Retrieved an ordered array of arena unit tokens."] = "Se ha recuperado una matriz ordenada de tokens de unidades de arena."
L["Register a callback function to run after FrameSort sorts frames."] = "Registra una función de retorno de llamada para ejecutar después de que OrdenarMarcos ordene los marcos."
L["Retrieve an ordered array of party frames."] = "Recupera una matriz ordenada de marcos de grupo."
L["Change a FrameSort setting."] = "Cambia una configuración de OrdenarMarcos."
L["View a full listing of all API methods on GitHub."] = "Consulta una lista completa de todos los métodos de API en GitHub."

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
L["(user macro)"] = "(macro del usuario)"
L["Using grouped layout for Cell raid frames"] = "Usando diseño agrupado para los marcos de raid de Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts."] = "Por favor, verifica la opción 'Grupos Combinados (Raid)' en Cell -> Diseños."
L["Can detect frames"] = "Puede detectar marcos"
L["FrameSort currently supports frames from these addons: %s."] = "OrdenarMarcos actualmente soporta marcos de estos addons: %s."
L["Using Raid-Style Party Frames"] = "Usando Marcos de Grupo al Estilo de Raid"
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings."] = "Por favor, habilita 'Usar Marcos de Grupo al Estilo de Raid' en la configuración de Blizzard."
L["Keep Groups Together setting disabled"] = "Configuración 'Mantener Grupos Juntos' desactivada"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."] = "Cambia el modo de visualización de la raid a una de las opciones 'Grupos Combinados' a través del Modo de Edición."
L["Disable the 'Keep Groups Together' raid profile setting."] = "Desactiva la configuración del perfil de raid 'Mantener Grupos Juntos'."
L["Only using Blizzard frames with Traditional mode"] = "Usando solo marcos de Blizzard con el modo Tradicional"
L["Traditional mode can't sort your other frame addons: '%s'"] = "El modo Tradicional no puede ordenar tus otros addons de marcos: '%s'"
L["Using Secure sorting mode when spacing is being used."] = "Usando el modo de ordenación Seguro cuando se está usando espaciado."
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method."] = "El modo Tradicional no puede aplicar espaciado, considera eliminar el espaciado o usar el método de ordenación Seguro."
L["Blizzard sorting functions not tampered with"] = "Funciones de ordenación de Blizzard no manipuladas"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" puede causar conflictos, considera desactivarlo.'
L["No conflicting addons"] = "Sin addons conflictivos"
L['"%s" may cause conflicts, consider disabling it.'] = '"%s" puede causar conflictos, considera desactivarlo.'
L["Main tank and assist setting disabled"] = "Configuración de tanque principal y asistente desactivada"
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames."] = "Por favor, desactiva la opción 'Mostrar Tanque Principal y Asistente' en Opciones -> Interfaz -> Marcos de Raid."
