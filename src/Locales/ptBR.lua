local _, addon = ...
local L = addon.Locale.ptBR

-- # Main Options screen #
-- used in FrameSort - 1.2.3 version header, %s is the version number
L["FrameSort - %s"] = "FrameSort - %s"
L["There are some issues that may prevent FrameSort from working correctly."] = "Há alguns problemas que podem impedir o FrameSort de funcionar corretamente."
L["Please go to the Health Check panel to view more details."] = "Acesse o painel de Diagnóstico para ver mais detalhes."
L["Role"] = "Função"
L["Spec"] = "Espec."
L["Group"] = "Grupo"
L["Alphabetical"] = "Alfabético"
L["Arena - 2v2"] = "Arena: 2x2"
L["Arena - 3v3"] = "Arena: 3x3"
L["Arena - 3v3 & 5v5"] = "Arena: 3x3 e 5x5"
L["Enemy Arena (see addons panel for supported addons)"] = "Arena inimiga (consulte o painel de addons para ver os addons compatíveis)"
L["Dungeon (mythics, 5-mans, delves)"] = "Masmorra (míticas, grupos de 5, sondagens)"
L["Raid (battlegrounds, raids)"] = "Raide (campos de batalha, raides)"
L["World (non-instance groups)"] = "Mundo (grupos fora de instância)"
L["Player"] = "Jogador"
L["Sort"] = "Ordenar"
L["Top"] = "Topo"
L["Middle"] = "Meio"
L["Bottom"] = "Base"
L["Hidden"] = "Oculto"
L["Group"] = "Grupo"
L["Reverse"] = "Inverter"

-- # Sorting Method screen #
L["Sorting Method"] = "Método de ordenação"
L["Secure"] = "Seguro"
L["SortingMethod_Secure_Description"] = [[
Ajusta a posição de cada quadro individualmente e não causa erros, travamentos nem taint na interface.
\n
Prós:
 - Consegue ordenar quadros de outros addons.
 - Consegue aplicar espaçamento entre quadros.
 - Sem taint (termo técnico para addons que interferem no código da interface da Blizzard).
\n
Contras:
 - Solução frágil, um castelo de cartas para contornar o espaguete da Blizzard.
 - Pode quebrar a cada patch do WoW e levar o desenvolvedor à loucura.
]]
L["Traditional"] = "Tradicional"
L["SortingMethod_Traditional_Description"] = [[
Este é o modo de ordenação padrão que addons e macros usam há mais de 10 anos.
Ele substitui o método de ordenação interno da Blizzard pelo nosso.
É o mesmo que o script 'SetFlowSortFunction', mas com a configuração do FrameSort.
\n
Prós:
 - Mais estável/confiável, pois aproveita os métodos de ordenação internos da Blizzard.
\n
Contras:
 - Ordena apenas os quadros de grupo da Blizzard, nada mais.
 - Vai causar erros de Lua, o que é normal e pode ser ignorado.
 - Não consegue aplicar espaçamento entre quadros.
]]
L["Please reload after changing these settings."] = "Recarregue a interface após alterar estas configurações."
L["Reload"] = "Recarregar"

-- # Ordering screen #
L["Ordering"] = "Ordenação"
L["Specify the ordering you wish to use when sorting by spec."] = "Especifique a ordem que deseja usar ao ordenar por especialização."
L["Tanks"] = "Tanques"
L["Healers"] = "Curandeiros"
L["Casters"] = "Conjuradores"
L["Hunters"] = "Caçadores"
L["Melee"] = "Corpo a corpo"

-- # Spec Priority screen # --
L["Spec Priority"] = "Prioridade espec."
L["Spec Type"] = "Tipo de especialização"
L["Choose a spec type, then drag and drop to control priority."] = "Escolha um tipo de especialização e arraste e solte para controlar a prioridade."
L["Tank"] = "Tanque"
L["Healer"] = "Curandeiro"
L["Caster"] = "Conjurador"
L["Hunter"] = "Caçador"
L["Melee"] = "Corpo a corpo"
L["Reset this type"] = "Redefinir este tipo"
L["Spec query note"] = [[
Observe que as informações de especialização são consultadas no servidor, o que leva de 1 a 2 segundos por jogador.
\n
Isso significa que pode demorar um pouco até conseguirmos ordenar com precisão.
]]

-- # Auto Leader screen #
L["Auto Leader"] = "Líder automático"
L["Auto promote healers to leader in solo shuffle."] = "Promover curandeiros a líder automaticamente no Solo Shuffle."
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] =
    "Por quê? Para que curandeiros possam configurar os ícones de marcação de alvo e reordenar party1/2 como preferirem."

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = "Seleção de alvo"
L["Target frame 1 (top frame)"] = "Selecionar o quadro 1 (quadro superior)"
L["Target frame 2"] = "Selecionar o quadro 2"
L["Target frame 3"] = "Selecionar o quadro 3"
L["Target frame 4"] = "Selecionar o quadro 4"
L["Target frame 5"] = "Selecionar o quadro 5"
L["Target bottom frame"] = "Selecionar o quadro inferior"
L["Target 1 frame above bottom"] = "Selecionar 1 quadro acima do inferior"
L["Target 2 frames above bottom"] = "Selecionar 2 quadros acima do inferior"
L["Target 3 frames above bottom"] = "Selecionar 3 quadros acima do inferior"
L["Target 4 frames above bottom"] = "Selecionar 4 quadros acima do inferior"
L["Target frame 1's pet"] = "Selecionar o mascote do quadro 1"
L["Target frame 2's pet"] = "Selecionar o mascote do quadro 2"
L["Target frame 3's pet"] = "Selecionar o mascote do quadro 3"
L["Target frame 4's pet"] = "Selecionar o mascote do quadro 4"
L["Target frame 5's pet"] = "Selecionar o mascote do quadro 5"
L["Target enemy frame 1"] = "Selecionar o quadro inimigo 1"
L["Target enemy frame 2"] = "Selecionar o quadro inimigo 2"
L["Target enemy frame 3"] = "Selecionar o quadro inimigo 3"
L["Target enemy frame 1's pet"] = "Selecionar o mascote do quadro inimigo 1"
L["Target enemy frame 2's pet"] = "Selecionar o mascote do quadro inimigo 2"
L["Target enemy frame 3's pet"] = "Selecionar o mascote do quadro inimigo 3"
L["Focus enemy frame 1"] = "Definir foco no quadro inimigo 1"
L["Focus enemy frame 2"] = "Definir foco no quadro inimigo 2"
L["Focus enemy frame 3"] = "Definir foco no quadro inimigo 3"
L["Target the next frame"] = "Selecionar o próximo quadro"
L["Target the previous frame"] = "Selecionar o quadro anterior"
L["Cycle to the next frame"] = "Alternar para o próximo quadro"
L["Cycle to the previous frame"] = "Alternar para o quadro anterior"
L["Cycle to the next dps"] = "Alternar para o próximo DPS"
L["Cycle to the previous dps"] = "Alternar para o DPS anterior"

-- # Keybindings screen #
L["Keybindings"] = "Atalhos de teclado"
L["Keybindings_Description"] = [[
Você encontra os atalhos de teclado do FrameSort na área padrão de atalhos do WoW.
\n
Para que servem os atalhos?
Eles servem para selecionar jogadores pela ordem visual em que aparecem, e não pela
posição no grupo (party1/2/3/etc.)
\n
Por exemplo, imagine um grupo de masmorra de 5 jogadores ordenado por função assim:
  - Tanque, party3
  - Curandeiro, player
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
Como você pode ver, a representação visual difere da posição real no grupo, o que
torna a seleção de alvos confusa.
Se você usasse /target party1, selecionaria o DPS na posição 3 em vez do tanque.
\n
Os atalhos do FrameSort selecionam com base na posição visual do quadro, não no número do grupo.
Assim, selecionar o 'Quadro 1' seleciona o tanque, o 'Quadro 2' o curandeiro, o 'Quadro 3' o DPS na posição 3, e assim por diante.
]]

-- # Macros screen # --
L["Macros"] = "Macros"
-- "|4macro:macros;" is a special command to pluralise the word "macro" to "macros" when %d is greater than 1
L["FrameSort has found %d |4macro:macros; to manage."] = "O FrameSort encontrou %d |4macro:macros; para gerenciar."
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] =
    'O FrameSort atualizará dinamicamente as variáveis dentro das macros que contiverem o cabeçalho "#FrameSort".'
L["Below are some examples on how to use this."] = "Veja abaixo alguns exemplos de como usar isso."

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
L["Example %d"] = "Exemplo %d"
L["Discord Bot Blurb"] = [[
Precisa de ajuda para criar uma macro?
\n
Entre no servidor do FrameSort no Discord e use nosso bot de macros com IA!
\n
Basta mencionar '@Macro Bot' com sua pergunta no canal #macro-bot-channel.
]]

-- # Macro Variables screen # --
L["Macro Variables"] = "Variáveis de macro"
L["The first DPS that's not you."] = "O primeiro DPS que não seja você."
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = "Adicione um número para escolher o enésimo alvo; por exemplo, DPS2 seleciona o 2º DPS."
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] =
    "As variáveis não diferenciam maiúsculas de minúsculas, então 'fRaMe1', 'Dps', 'enemyhealer', etc., funcionam igualmente."
L["Need to save on macro characters? Use abbreviations to shorten them:"] = "Precisa economizar caracteres na macro? Use abreviações para encurtá-las:"
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = 'Use "X" para dizer ao FrameSort que ignore um seletor @unit:'
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Spell;]]

-- # Spacing screen #
L["Spacing"] = "Espaçamento"
L["Add some spacing between party, raid, and arena frames."] = "Adicione espaçamento entre os quadros de grupo, raide e arena."
L["This only applies to Blizzard frames."] = "Isso se aplica apenas aos quadros da Blizzard."
L["Party"] = "Grupo"
L["Raid"] = "Raide"
L["Group"] = "Grupo"
L["Enemy Arena"] = "Arena inimiga"
L["Horizontal"] = "Horizontal"
L["Vertical"] = "Vertical"

-- # Addons screen #
L["Addons"] = "Addons"
L["Addons_Supported_Description"] = [[
O FrameSort é compatível com o seguinte:
\n
  - Blizzard: grupo, raide, arena.
\n
  - ElvUI: grupo, arena.
\n
  - sArena: arena.
\n
  - Gladius: arena.
\n
  - GladiusEx: grupo, arena.
\n
  - Cell: grupo, raide (apenas ao usar grupos combinados).
\n
  - Shadowed Unit Frames: grupo, arena.
\n
  - Grid2: grupo, raide.
\n
  - BattleGroundEnemies: grupo, arena.
\n
  - Gladdy: arena.
\n
  - Arena Core: 0.9.1.7+.
\n
]]

-- # Api screen #
L["Api"] = "API"
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = "Quer integrar o FrameSort aos seus addons, scripts e WeakAuras?"
L["Here are some examples."] = "Aqui estão alguns exemplos."
L["Retrieved an ordered array of party/raid unit tokens."] = "Obtém uma lista ordenada de tokens de unidade de grupo/raide."
L["Retrieved an ordered array of arena unit tokens."] = "Obtém uma lista ordenada de tokens de unidade de arena."
L["Register a callback function to run after FrameSort sorts frames."] = "Registra uma função de retorno para ser executada depois que o FrameSort ordenar os quadros."
L["Retrieve an ordered array of party frames."] = "Obtém uma lista ordenada de quadros de grupo."
L["Change a FrameSort setting."] = "Altera uma configuração do FrameSort."
L["Get the frame number of a unit."] = "Obtém o número do quadro de uma unidade."
L["View a full listing of all API methods on GitHub."] = "Veja a lista completa de todos os métodos da API no GitHub."

-- # Discord screen #
L["Discord"] = "Discord"
L["Need help with something?"] = "Precisa de ajuda com alguma coisa?"
L["Talk directly with the developer on Discord."] = "Fale diretamente com o desenvolvedor no Discord."

-- # Health Check screen -- #
L["Health Check"] = "Diagnóstico"
L["Try this"] = "Tente isto"
L["Any known issues with configuration or conflicting addons will be shown below."] = "Qualquer problema conhecido de configuração ou conflito entre addons será mostrado abaixo."
L["N/A"] = "N/D"
L["Passed!"] = "Aprovado!"
L["Failed"] = "Falhou"
L["(unknown)"] = "(desconhecido)"
L["(user macro)"] = "(macro do usuário)"
L["Using grouped layout for Cell raid frames"] = "Usando layout agrupado para os quadros de raide do Cell"
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = "Ative a opção 'Combined Groups (Raid)' em Cell -> Layouts"
L["Can detect frames"] = "Consegue detectar quadros"
L["FrameSort currently supports frames from these addons: %s"] = "Atualmente o FrameSort é compatível com quadros destes addons: %s"
L["Keep Groups Together setting disabled"] = "Configuração 'Manter grupos juntos' desativada"
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = "Altere o modo de exibição de raide para uma das opções 'Combined Groups' pelo Modo de edição"
L["Disable the 'Keep Groups Together' raid profile setting"] = "Desative a configuração 'Keep Groups Together' do perfil de raide"
L["Only using Blizzard frames with Traditional mode"] = "Usando apenas quadros da Blizzard com o modo Tradicional"
L["Traditional mode can't sort your other frame addons: '%s'"] = "O modo Tradicional não consegue ordenar seus outros addons de quadros: '%s'"
L["Using Secure sorting mode when spacing is being used"] = "Usando o modo de ordenação Seguro quando há espaçamento aplicado"
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] =
    "O modo Tradicional não consegue aplicar espaçamento; considere remover o espaçamento ou usar o método de ordenação Seguro"
L["Blizzard sorting functions not tampered with"] = "Funções de ordenação da Blizzard não modificadas"
L['"%s" may cause conflicts, consider disabling it'] = '"%s" pode causar conflitos; considere desativá-lo'
L["No conflicting addons"] = "Nenhum addon conflitante"

-- # Log Screen -- #
L["Log"] = "Registro"
L["Enable Logging"] = "Ativar registro"
L["FrameSort log to help with diagnosing issues."] = "Registro do FrameSort para ajudar a diagnosticar problemas."
L["Copy Log"] = "Copiar registro"

-- # Notifications -- #
L["Can't do that during combat."] = "Não é possível fazer isso durante o combate."

-- # Nameplates screen #
L["Nameplates"] = "Placas de nome"
L["Friendly Nameplates"] = "Placas de nome aliadas"
L["Enemy Nameplates"] = "Placas de nome inimigas"
L["NameplatesBlurb"] = [[
Substitui o texto das placas de nome da Blizzard e do Platynator por variáveis do FrameSort.
\n
Variáveis compatíveis:
  - $framenumber
  - $name
  - $unit
  - $spec
\n
Exemplos:
  - Quadro - $framenumber
  - $framenumber - $spec
  - $name - $spec
]]

-- # Miscellaneous screen #
L["Miscellaneous"] = "Diversos"
L["Various tweaks you can apply."] = "Vários ajustes que você pode aplicar."
L["Player top of role"] = "Jogador no topo da função"
L["Places you at the top of your corresponding role (healer/tank/dps)."] = "Coloca você no topo da sua função correspondente (curandeiro/tanque/DPS)."

-- # Language screen #
L["Language"] = "Idioma"
L["Auto"] = "Automático"
L["Specify the language we use."] = "Especifique o idioma que usamos."
