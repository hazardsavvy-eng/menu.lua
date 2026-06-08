if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(...) return ... end
end

function isProtected()
    return GetResourceState('PL_PROTECT') == 'started'
        or GetResourceState('ThnAC') == 'started'
        or GetResourceState('likizao_ac') == 'started'
        or GetResourceState('MQCU') == 'started'
end

-- RESOLVER ERRO: Função debugPrint global para evitar erros do recurso monitor
if not debugPrint then
    debugPrint = function(...)
        -- Função de debug global que não faz nada (evita erros)
        return
    end
end

local ScreenX, ScreenY = GetActiveScreenResolution()
local menuWidth = 843
local menuHeight = 600
local YGZ = {
    x = math.ceil(ScreenX / 2 - menuWidth / 2),
    y = math.ceil(ScreenY / 2 - menuHeight / 2),
    width = menuWidth,
    height = menuHeight,
    screenW = ScreenX,
    screenH = ScreenY,
    RenderMenu = true,
    showMenu = true,

    SelectedPlayer = nil,
    SelectedVehicle = nil,

    scroll = {},
    sliders = {},
    comboboxes = {},

    MenuKey = {
        key = 157,
        Text = '1'
    },

    drag = {
        isDragging = false,
        offsetX = 0,
        offsetY = 0,
    },

    tabs = {
        active = 'Jogador',
        y = 0,
        addY = 0
    },
    subtabs = {
        active = 'Jogador',
        y = 0,
    },
    buttons = {
        x1 = 175,
        y1 = 0,
        x2 = 502,
        y2 = 0,
    },
    toggles = {
        state = {}
    },

    inputs = {},
    savedPositions = {},
    changingHotkey = nil,
    removeHotkeyMode = nil,

    -- SISTEMA DE BINDING DE FUNÇÕES (IGUAL AOS OUTROS MENUS)
    key_binds = {},
    vars = {
        cooldown = {}
    },
    vkCodes = {
        -- Letras
        ["A"] = 0x41, ["B"] = 0x42, ["C"] = 0x43, ["D"] = 0x44, ["E"] = 0x45, ["F"] = 0x46,
        ["G"] = 0x47, ["H"] = 0x48, ["I"] = 0x49, ["J"] = 0x4A, ["K"] = 0x4B, ["L"] = 0x4C,
        ["M"] = 0x4D, ["N"] = 0x4E, ["O"] = 0x4F, ["P"] = 0x50, ["Q"] = 0x51, ["R"] = 0x52,
        ["S"] = 0x53, ["T"] = 0x54, ["U"] = 0x55, ["V"] = 0x56, ["W"] = 0x57, ["X"] = 0x58,
        ["Y"] = 0x59, ["Z"] = 0x5A,
        -- Números
        ["0"] = 0x30, ["1"] = 0x31, ["2"] = 0x32, ["3"] = 0x33, ["4"] = 0x34, 
        ["5"] = 0x35, ["6"] = 0x36, ["7"] = 0x37, ["8"] = 0x38, ["9"] = 0x39,
        -- Teclas de função
        ["F1"] = 0x70, ["F2"] = 0x71, ["F3"] = 0x72, ["F4"] = 0x73, ["F5"] = 0x74, ["F6"] = 0x75,
        ["F7"] = 0x76, ["F8"] = 0x77, ["F9"] = 0x78, ["F10"] = 0x79, ["F11"] = 0x7A, ["F12"] = 0x7B,
        -- Teclas especiais
        ["SPACE"] = 0x20, ["ENTER"] = 0x0D, ["ESC"] = 0x1B, ["TAB"] = 0x09, 
        ["SHIFT"] = 0x10, ["CTRL"] = 0x11, ["ALT"] = 0x12, ["BACKSPACE"] = 0x08, 
        ["DELETE"] = 0x2E, ["INSERT"] = 0x2D, ["HOME"] = 0x24, ["END"] = 0x23, 
        ["PAGEUP"] = 0x21, ["PAGEDOWN"] = 0x22, ["UP"] = 0x26, ["DOWN"] = 0x28, 
        ["LEFT"] = 0x25, ["RIGHT"] = 0x27,
        -- Numpad
        ["NUMPAD0"] = 0x60, ["NUMPAD1"] = 0x61, ["NUMPAD2"] = 0x62, ["NUMPAD3"] = 0x63, 
        ["NUMPAD4"] = 0x64, ["NUMPAD5"] = 0x65, ["NUMPAD6"] = 0x66, ["NUMPAD7"] = 0x67, 
        ["NUMPAD8"] = 0x68, ["NUMPAD9"] = 0x69, ["MULTIPLY"] = 0x6A, ["ADD"] = 0x6B,
        ["SUBTRACT"] = 0x6D, ["DECIMAL"] = 0x6E, ["DIVIDE"] = 0x6F
    },

    animColors = {},
    capacidade = 137,
    
    -- SISTEMA DE TEMAS CUSTOMIZÁVEIS
    themes = {
        default = {
            primary = {255, 0, 0, 255},      -- Vermelho
            secondary = {25, 25, 25, 255},   -- Cinza escuro
            background = {8, 8, 8, 255},     -- Preto
            text = {255, 255, 255, 255},     -- Branco
            accent = {35, 35, 35, 255}       -- Cinza
        },
        blue = {
            primary = {0, 150, 255, 255},    -- Azul
            secondary = {15, 25, 35, 255},   -- Azul escuro
            background = {5, 10, 15, 255},   -- Azul muito escuro
            text = {255, 255, 255, 255},     -- Branco
            accent = {25, 35, 45, 255}       -- Azul médio
        },
        green = {
            primary = {0, 255, 100, 255},    -- Verde
            secondary = {15, 35, 25, 255},   -- Verde escuro
            background = {5, 15, 10, 255},   -- Verde muito escuro
            text = {255, 255, 255, 255},     -- Branco
            accent = {25, 45, 35, 255}       -- Verde médio
        },
        purple = {
            primary = {150, 0, 255, 255},    -- Roxo
            secondary = {35, 15, 45, 255},   -- Roxo escuro
            background = {15, 5, 20, 255},   -- Roxo muito escuro
            text = {255, 255, 255, 255},     -- Branco
            accent = {45, 25, 55, 255}       -- Roxo médio
        },
        orange = {
            primary = {255, 150, 0, 255},    -- Laranja
            secondary = {45, 35, 15, 255},   -- Laranja escuro
            background = {20, 15, 5, 255},   -- Laranja muito escuro
            text = {255, 255, 255, 255},     -- Branco
            accent = {55, 45, 25, 255}       -- Laranja médio
        },
        pink = {
            primary = {255, 100, 150, 255},  -- Rosa
            secondary = {45, 25, 35, 255},   -- Rosa escuro
            background = {20, 10, 15, 255},  -- Rosa muito escuro
            text = {255, 255, 255, 255},     -- Branco
            accent = {55, 35, 45, 255}       -- Rosa médio
        }
    },
    
    currentTheme = 'default',
    themeNames = {'default', 'blue', 'green', 'purple', 'orange', 'pink'},
    currentThemeIndex = 1,
    
    
    
    -- DETECÇÃO DE SERVIDOR
    groupcity = "NENHUM",
    cityAC = "NENHUM",
    
    -- Função para detectar servidor
    DetectServer = function(self)
        local resources = {
            ["SANTA"] = {"santa_radio", "santa_hud"},
            ["FLUXO"] = {"fluxo_skinweapons", "fluxo_hud"},
            ["NEXUS"] = {"nxgroup-script", "nexus_hud"},
            ["FUSION"] = {"relikiashop-fusiongroup", "favelaskillua"},
            ["MQCU"] = {"MQCU", "mqcu_ac"},
            ["LIKIZAO"] = {"likizao_ac", "likizao_hud"}
        }
        
        for group, resourceList in pairs(resources) do
            for _, resource in ipairs(resourceList) do
                if GetResourceState(resource) == "started" then
                    self.groupcity = group
                    self.cityAC = group
                    return group
                end
            end
        end
        
        return "NENHUM"
    end,
    
    -- CONFIGURAÇÕES AVANÇADAS
    advancedConfig = {
        ui = {
            menuKey = 157,
            theme = 'default',
            position = {x = 0, y = 0},
            opacity = 255,
            scale = 1.0,
            animations = true
        },
        performance = {
            maxFPS = 60,
            espUpdateRate = 100,
            cacheTime = 1000,
            lowPerformanceMode = false
        },
        security = {
            autoHide = true,
            panicKey = 112,
            logActions = false,
            stealthMode = false
        },
        features = {
            noclipSpeed = 2.0,
            noclipInvisible = false,
            espDistance = 250,
            espShowNames = true,
            espShowBoxes = false,
            espShowSkeleton = false,
            aimbotFOV = 30,
            aimbotSmooth = 5,
            aimbotBone = 1,
            autoRepair = false,
            spawnInVehicle = true,
            vehicleGodmode = false
        }
    },

    colors = {
        theme = {255, 0, 0, 255},
        ColorTab = {55, 55, 55, 255},
        icontab = {
            colors = {
                ['Jogador'] = {35, 35, 35, 255},
                ['Armas'] = {35, 35, 35, 255},
                ['Veículos'] = {35, 35, 35, 255},
                ['Online'] = {35, 35, 35, 255},
                ['Visual'] = {35, 35, 35, 255},
                ['Exploits'] = {35, 35, 35, 255},
                ['Config'] = {35, 35, 35, 255},
            }
        },
    },
    notify = function(self, message, message_type)
        message_type = message_type or "info"
        print('[YGZ Notify] ' .. message_type .. ': ' .. message)
    end,
    
    -- Funções auxiliares para ESP Skeleton (CROCK Menu)
    Visual_Dist = function(pos)
        local cc = GetFinalRenderedCamCoord()
        local hray, hit, coords, surfaceNormal, ent = GetShapeTestResult(StartShapeTestRay(cc.x, cc.y, cc.z, pos.x, pos.y, pos.z, -1, PlayerPedId(), 0))
        if hit then
            return #(cc - coords) / #(cc - pos) * 0.83
        end
    end,
    
    Coords_Soup = function(vec, factor)
        local c = GetFinalRenderedCamCoord()
        factor = (not factor or factor >= 1) and 1 / 1.2 or factor
        return vector3(c.x + (vec.x - c.x) * factor, c.y + (vec.y - c.y) * factor, c.z + (vec.z - c.z) * factor)
    end,
}

Citizen.CreateThread(function()
    local sprites = {
        ['cursor'] = {'https://ratinhofivem.github.io/ImgMenu/index?image=cursor', 50, 50},
        ['circle'] = {'https://gregarious-seahorse-1307f0.netlify.app/circle.svg', 150, 150},
        ['checked'] = {'https://gregarious-seahorse-1307f0.netlify.app/check.svg', 50, 50},
        ['Jogador'] = {'https://gorgeous-sopapillas-26a6a1.netlify.app/person_running.svg', 50, 50},
        ['Armas'] = {'https://gorgeous-sopapillas-26a6a1.netlify.app/weapon.svg', 50, 50},
        ['Veiculos'] = {'https://gorgeous-sopapillas-26a6a1.netlify.app/vehicle.svg', 55, 50},
        ['Online'] = {'https://gorgeous-sopapillas-26a6a1.netlify.app/globe.svg', 50, 50},
        ['Visual'] = {'https://gorgeous-sopapillas-26a6a1.netlify.app/eye.svg', 50, 50},
        ['Exploits'] = {'https://famous-ganache-f965ee.netlify.app', 50, 50},
        ['Config'] = {'https://gorgeous-sopapillas-26a6a1.netlify.app/gear.svg', 50, 50},
        ['DragonLogo'] = {'https://iili.io/KnmqiX9.webp', 120, 110},
        ["ListAdm"] = {"https://farinha21.github.io/farinha-menu-sigma/index?image=AdminList", 310, 51},
    }

    local sprite = {}
    local dict = GlobalState['Dict-Sprite']
    if not dict then
        for sp, create in pairs(sprites) do
            sprite[sp] = YGZ:CreateSprite(sp, create[1], {create[2], create[3]})
        end
        GlobalState['Dict-Sprite'] = YGZ.DictSprite
    else
        YGZ.DictSprite = dict
    end
    
    print('')
    print('')
    print('')
    print('^1[YGZ Menu]: ^2MENU INJETADO COM SUCESSO!')
    print('^1[YGZ Menu]: ^2TECLA DO MENU: '..YGZ.MenuKey.Text)
    
    -- Inicializar sistema de binding
    Citizen.CreateThread(function()
        Wait(2000)
        print('^1[YGZ Menu]: ^2Sistema de Binding ativo!')
        print('^1[YGZ Menu]: ^2Clique direito em botões/checkboxes para bindar teclas')
        print('^1[YGZ Menu]: ^2Pressione tecla, depois ENTER para confirmar')
        print('^1[YGZ Menu]: ^2BACKSPACE para remover bind existente')
    end)
            
    local value = 0
    while not YGZ.menuLoaded do
        local rendered = true
        for _, duis in pairs(sprite) do
            if not IsDuiAvailable(duis) then
                rendered = false
            end
        end
        if rendered then
            Wait(350)
            YGZ.menuLoaded = rendered
        else
            value = value + 1
        end
        Wait(10)
    end
    
    if YGZ.menuLoaded then
        print('^1[YGZ Menu]: ^2Menu Carregado Com Sucesso!')
        print('')
        print('')
        print('')
    end
end)

YGZ.functions = {
    lerp = function(valorInicial, valorFinal, tempo)
        if valorInicial > 1 then
            return tempo
        end
        if valorInicial < 0 then
            return valorFinal
        end
        return valorFinal + (tempo - valorFinal) * valorInicial
    end
}

-- FUNÇÕES DE TEMA
YGZ.ApplyTheme = function(self, themeName)
    if self.themes[themeName] then
        self.colors.theme = self.themes[themeName].primary
        self.colors.ColorTab = self.themes[themeName].secondary
        self.currentTheme = themeName
        
        -- Atualizar cores dos ícones das abas
        for tabName, _ in pairs(self.colors.icontab.colors) do
            if self.tabs.active == tabName then
                self.colors.icontab.colors[tabName] = self.themes[themeName].primary
            else
                self.colors.icontab.colors[tabName] = self.themes[themeName].accent
            end
        end
        
        self:notify('Tema alterado para: ' .. themeName:upper(), 'sucesso')
    end
end

YGZ.NextTheme = function(self)
    self.currentThemeIndex = self.currentThemeIndex + 1
    if self.currentThemeIndex > #self.themeNames then
        self.currentThemeIndex = 1
    end
    
    local newTheme = self.themeNames[self.currentThemeIndex]
    self:ApplyTheme(newTheme)
end

-- FUNÇÕES DE CONFIGURAÇÃO AVANÇADA
YGZ.SaveAdvancedConfig = function(self)
    local configData = {
        version = "2.0",
        timestamp = os.time(),
        config = self.advancedConfig,
        toggles = self.toggles,
        sliders = self.sliders,
        hotkeys = self.hotkeys,
        theme = self.currentTheme,
        savedPositions = self.savedPositions
    }
    
    local json = json.encode(configData)
    SaveResourceFile(GetCurrentResourceName(), 'ygz_advanced_config.json', json, #json)
    self:notify('Configuração avançada salva!', 'sucesso')
end

YGZ.LoadAdvancedConfig = function(self)
    local json = LoadResourceFile(GetCurrentResourceName(), 'ygz_advanced_config.json')
    if json then
        local data = json.decode(json)
        if data and data.config then
            self.advancedConfig = data.config
            self.toggles = data.toggles or {}
            self.sliders = data.sliders or {}
            self.hotkeys = data.hotkeys or self.hotkeys
            self.savedPositions = data.savedPositions or {}
            
            -- Aplicar tema carregado
            if data.theme then
                self:ApplyTheme(data.theme)
            end
            
            -- Aplicar configurações
            self.MenuKey.key = self.advancedConfig.ui.menuKey
            
            self:notify('Configuração avançada carregada!', 'sucesso')
            return true
        end
    end
    return false
end

YGZ.GetDefaultConfig = function(self)
    return {
        ui = {
            menuKey = 157,
            theme = 'default',
            position = {x = 0, y = 0},
            opacity = 255,
            scale = 1.0,
            animations = true
        },
        performance = {
            maxFPS = 60,
            espUpdateRate = 100,
            cacheTime = 1000,
            lowPerformanceMode = false
        },
        security = {
            autoHide = true,
            panicKey = 112,
            logActions = false,
            stealthMode = false
        },
        features = {
            noclipSpeed = 2.0,
            noclipInvisible = false,
            espDistance = 250,
            espShowNames = true,
            espShowBoxes = false,
            espShowSkeleton = false,
            aimbotFOV = 30,
            aimbotSmooth = 5,
            aimbotBone = 1,
            autoRepair = false,
            spawnInVehicle = true,
            vehicleGodmode = false
        }
    }
end
-- SISTEMA DE HOTKEYS
YGZ.ExecuteHotkey = function(self, action)
    if isProtected and isProtected() then
        YGZ:notify('Função bloqueada por proteção ativa!', 'erro')
        return
    end
    local ped = PlayerPedId()
    
    if action == 'toggleMenu' then
        YGZ.showMenu = not YGZ.showMenu
        
    elseif action == 'godmode' then
        YGZ.toggles['Godmode'] = not YGZ.toggles['Godmode']
        if YGZ.toggles['Godmode'] then
            -- Implementação robusta baseada no Vanta Menu
            Citizen.CreateThread(function()
                while YGZ.toggles['Godmode'] do
                    if SetEntityOnlyDamagedByRelationshipGroup then
                        SetEntityOnlyDamagedByRelationshipGroup(ped, true, "PLAYER")
                    end
                    SetEntityInvincible(ped, true)
                    SetPlayerInvincible(PlayerId(), true)
                    SetEntityCanBeDamaged(ped, false)
                    StopEntityFire(ped)
                    SetEntityProofs(ped, true, true, true, true, true, true, true, true)
                    SetPedDiesInWater(ped, false)
                    Wait(0)
                end
                -- Restaurar quando desativado
                if SetEntityOnlyDamagedByRelationshipGroup then
                    if SetEntityOnlyDamagedByRelationshipGroup then
                SetEntityOnlyDamagedByRelationshipGroup(ped, false, nil)
            end
                end
                SetEntityProofs(ped, false, false, false, false, false, false, false, false)
                SetPedDiesInWater(ped, true)
            end)
            YGZ:notify('Godmode: ON', 'sucesso')
        else
            YGZ.toggles['Godmode'] = false
            if SetEntityOnlyDamagedByRelationshipGroup then
                SetEntityOnlyDamagedByRelationshipGroup(ped, false, nil)
            end
            SetEntityInvincible(ped, false)
            SetPlayerInvincible(PlayerId(), false)
            SetEntityCanBeDamaged(ped, true)
            SetEntityProofs(ped, false, false, false, false, false, false, false, false)
            SetPedDiesInWater(ped, true)
            YGZ:notify('Godmode: OFF', 'info')
        end
        
    elseif action == 'noclip' then
        YGZ.toggles['Noclip'] = not YGZ.toggles['Noclip']
        YGZ:notify('Noclip: ' .. (YGZ.toggles['Noclip'] and 'ON' or 'OFF'), 
                  YGZ.toggles['Noclip'] and 'sucesso' or 'info')
        
    elseif action == 'repair' then
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            SetVehicleFixed(veh)
            SetVehicleEngineHealth(veh, 1000.0)
            SetVehicleBodyHealth(veh, 1000.0)
            SetVehiclePetrolTankHealth(veh, 1000.0)
            YGZ:notify('Veículo reparado!', 'sucesso')
        else
            YGZ:notify('Entre em um veículo!', 'erro')
        end
        
    elseif action == 'teleportWaypoint' then
        local waypointBlip = GetFirstBlipInfoId(8)
        if DoesBlipExist(waypointBlip) then
            local coords = GetBlipCoords(waypointBlip)
            SetEntityCoords(ped, coords.x, coords.y, coords.z + 1.0)
            YGZ:notify('Teleportado para waypoint!', 'sucesso')
        else
            YGZ:notify('Marque um ponto no mapa!', 'erro')
        end
        
    elseif action == 'savePosition' then
        local coords = GetEntityCoords(ped)
        table.insert(YGZ.savedPositions, {
            x = coords.x, 
            y = coords.y, 
            z = coords.z,
            name = 'Posição ' .. (#YGZ.savedPositions + 1)
        })
        YGZ:notify('Posição salva! (' .. #YGZ.savedPositions .. ')', 'sucesso')
        
    elseif action == 'freecam' then
        YGZ.toggles['freecam_toggle'] = not YGZ.toggles['freecam_toggle']
        YGZ:notify('Freecam: ' .. (YGZ.toggles['freecam_toggle'] and 'ON' or 'OFF'), 
                  YGZ.toggles['freecam_toggle'] and 'sucesso' or 'info')
        
    elseif action == 'leaveVehicle' then
        -- Remover do veículo com F - Implementação baseada no Zenix Menu (com proteção)
        pcall(function()
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                
                -- Verificar se há tarefa ativa e limpar (método mais seguro)
                if GetIsTaskActive and GetIsTaskActive(ped, 2) then
                    ClearPedTasksImmediately(ped)
                end
                
                -- Método principal do Zenix Menu
                TaskLeaveVehicle(ped, vehicle, 16)
                Wait(100)
                
                -- Verificar se ainda está no veículo
                if IsPedInAnyVehicle(ped, false) then
                    -- Método alternativo
                    TaskLeaveAnyVehicle(ped)
                    Wait(100)
                    
                    -- Se ainda estiver no veículo, forçar saída
                    if IsPedInAnyVehicle(ped, false) then
                        local coords = GetEntityCoords(vehicle)
                        SetEntityCoordsNoOffset(ped, coords.x + 2.0, coords.y, coords.z, false, false, false)
                        ClearPedTasksImmediately(ped)
                    end
                end
                
                YGZ:notify('Removido do veículo!', 'sucesso')
            else
                YGZ:notify('Você não está em um veículo!', 'erro')
            end
        end)
        
    elseif action == 'panicButton' then
        -- Desligar tudo rapidamente
        YGZ.toggles['Godmode'] = false
        YGZ.toggles['Noclip'] = false
        YGZ.toggles['ESPNome'] = false
        YGZ.toggles['ESPHealth'] = false
        YGZ.toggles['aimbot_enabled'] = false
        YGZ.showMenu = false
        
        -- Restaurar proteções do godmode
        local ped = PlayerPedId()
        SetEntityOnlyDamagedByRelationshipGroup(ped, false, nil)
        SetEntityInvincible(ped, false)
        SetPlayerInvincible(PlayerId(), false)
        SetEntityCanBeDamaged(ped, true)
        SetEntityProofs(ped, false, false, false, false, false, false, false, false)
        SetPedDiesInWater(ped, true)
        SetEntityVisible(ped, true, false)
        YGZ:notify('PÂNICO: Tudo desligado!', 'aviso')
    end
end

YGZ.Hovered = function(self, posX, posY, width, height)
    local cursorX, cursorY = GetNuiCursorPosition()
    if posX <= cursorX and cursorX <= posX + width and posY <= cursorY and cursorY <= posY + height then
        return true
    end
    return false
end

local textWidthCache = {}
YGZ.GetTextWidthSize = function(self, text, size, font)
    local screenWidth = YGZ.screenW
    local screenHeight = YGZ.screenH
    local cacheKey = text .. size .. font .. screenWidth .. screenHeight
    local cachedWidth = textWidthCache[cacheKey]
    if cachedWidth then
        return cachedWidth
    end
    local textSizeX = size * 10 / screenWidth
    local textSizeY = size * 10 / screenHeight    
    BeginTextCommandWidth('STRING')
    AddTextComponentString(text)
    SetTextFont(font)
    SetTextScale(textSizeX * 10, textSizeY * 10)
    local textWidth = EndTextCommandGetWidth(true) * screenWidth
    textWidthCache[cacheKey] = textWidth
    return textWidth
end

YGZ.DrawText = function(self, name, posX, posY, width, height, isoutline, color, order)
    local scaleX = 1 / YGZ.screenW
    local scaleY = 1 / YGZ.screenH
    local screenPosX = scaleX * posX
    local screenPosY = scaleY * posY
    local screenScaleX = scaleX * width
    local screenScaleY = scaleY * height
    if isoutline then
        SetTextOutline()
    end
    SetTextScale(screenScaleX, screenScaleY)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextFont(0)
    SetTextProportional(1)
    SetTextCentre(false)
    SetTextEntry('STRING')
    AddTextComponentString(name)
    SetScriptGfxDrawOrder(order or 10)
    DrawText(screenPosX, screenPosY)
end

YGZ.DrawText2 = function(self, name, posX, posY, width, height, isoutline, color, justify, order)
    SetScriptGfxDrawOrder(order or 10)
    local scaleX = 1 / YGZ.screenW
    local scaleY = 1 / YGZ.screenH
    local screenPosX = scaleX * posX
    local screenPosY = scaleY * posY
    local screenScaleX = scaleX * width
    local screenScaleY = scaleY * height
    if isoutline then
        SetTextOutline()
    end
    
    SetTextJustification(justify or 0)
    SetTextScale(screenScaleX, screenScaleY)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextFont(0)
    SetTextProportional(1)
    SetTextCentre(false)
    SetTextEntry('STRING')
    AddTextComponentString(name)
    DrawText(screenPosX, screenPosY)
end

YGZ.CreateSprite = function(self, spriteName, textureWidth, duiProperties)
    local dictString = tostring(YGZ.DictSprite)
    local posX, posY = table.unpack(duiProperties)
    local duiHandle = CreateDui(textureWidth, posX, posY)
    CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(dictString .. spriteName), dictString .. spriteName .. '_rtn', GetDuiHandle(duiHandle))
    return duiHandle
end

YGZ.GetSprite = function(self, spriteName)
    local dictString = tostring(YGZ.DictSprite)
    return dictString .. spriteName, dictString .. spriteName .. '_rtn'
end

YGZ.DrawSprite = function(self, textureDict, textureName, posX, posY, width, height, heading, color, drawOrder)
    local scaleX = 1 / YGZ.screenW
    local scaleY = 1 / YGZ.screenH
    local screenPosX = scaleX * posX
    local screenPosY = scaleY * posY
    local screenScaleX = scaleX * width
    local screenScaleY = scaleY * height
    SetScriptGfxDrawOrder(drawOrder or 3)
    DrawSprite(textureDict, textureName, screenPosX + screenScaleX / 2, screenPosY + screenScaleY / 2, screenScaleX, screenScaleY, heading, color[1], color[2], color[3], color[4] or 255)
end

YGZ.DrawRect = function(self, posX, posY, width, height, color, drawOrder)
    local screenPosX = posX / YGZ.screenW + width / YGZ.screenW / 2
    local screenPosY = posY / YGZ.screenH + height / YGZ.screenH / 2
    SetScriptGfxDrawOrder(drawOrder or 3)
    DrawRect(screenPosX, screenPosY, width / YGZ.screenW, height / YGZ.screenH, color[1], color[2], color[3], color[4] or 255)
end
YGZ.DrawRoundedRect = function(self, x, y, width, height, radius, r, g, b, a, order)
    if radius > height then
        radius = height
    end
    local dict, name = YGZ:GetSprite('circle')
    YGZ:DrawRect(x + radius / 2, y, width - radius, height, r, g, b, a, order)
    YGZ:DrawRect(x, y + radius / 2, width, height - radius, r, g, b, a, order)
    YGZ:DrawSprite(dict, name, x, y, radius, radius, 0, r, g, b, a, order)
    YGZ:DrawSprite(dict, name, x + width - radius, y, radius, radius, 0, r, g, b, a, order)
    YGZ:DrawSprite(dict, name, x, y + height - radius, radius, radius, 0, r, g, b, a, order)
    YGZ:DrawSprite(dict, name, x + width - radius, y + height - radius, radius, radius, 0, r, g, b, a, order)
end

YGZ.Tab = function(self, tabName, callback)
    local currentY = YGZ.tabs.y
    local isActive = YGZ.tabs.active == tabName
    local hovered = YGZ:Hovered(YGZ.x, YGZ.y + 80 + currentY + 50, 150, 40)
    if isActive then
        if not YGZ.tabs.addY then
            YGZ.tabs.addY = currentY
        end
        YGZ.tabs.addY = YGZ.functions.lerp(0.15, YGZ.tabs.addY, currentY)
    end

    if currentY >= 0 then
        YGZ:DrawRoundedRect(YGZ.x + 13, YGZ.y + 90 + math.ceil(YGZ.tabs.addY) + 50, 150, 40, 15, {25, 25, 25, 255}, 4)
    end

    if tabName == YGZ.tabs.active then
        YGZ.colors.ColorTab = {255, 255, 255, 255}
    else
        YGZ.colors.ColorTab = {55, 55, 55, 255}
    end

    if YGZ.tabs.active == tabName then
        YGZ.colors.icontab.colors[tabName] = YGZ.colors.theme
    elseif YGZ.tabs.active ~= tabName then
        YGZ.colors.icontab.colors[tabName] = {35, 35, 35, 255}
    end

    YGZ:DrawText(tabName or '', YGZ.x + 75, YGZ.y + 100 + currentY + 50, 240, 240, false, YGZ.colors.ColorTab)

    if hovered and IsDisabledControlJustPressed(0, 24) then
        YGZ.tabs.active = tabName
        if callback then
            callback()
        end
    end
    YGZ.tabs.y = currentY + 50
end

--YGZ:SubTab('Teleportes')
YGZ.SubTab = function(self, subtabName)
    local subtabY = YGZ.subtabs.y
    local isActive = YGZ.subtabs.active == subtabName
    local textWidth = YGZ:GetTextWidthSize(subtabName, 3, 8)
    local hovered = YGZ:Hovered(YGZ.x + 210 + subtabY, YGZ.y + 5, textWidth, 30)
        
    if isActive then
        if not YGZ.subtabs.addY then
            YGZ.subtabs.addY = subtabY
        end
        if not YGZ.subtabs.addW then
            YGZ.subtabs.addW = textWidth
        end
        YGZ.subtabs.addY = YGZ.functions.lerp(0.15, YGZ.subtabs.addY, subtabY)
        YGZ.subtabs.addW = YGZ.functions.lerp(0.15, YGZ.subtabs.addW, textWidth)
    end

    if subtabY >= 0 then
        YGZ:DrawRoundedRect(YGZ.x + 211 + math.ceil(YGZ.subtabs.addY), YGZ.y + 12, math.ceil(YGZ.subtabs.addW) - 3, 35, 15, {25, 25, 25, 255}, 11)
    end
    
    if YGZ.subtabs.active == subtabName then
        YGZ:DrawText(subtabName, YGZ.x + 215 + subtabY, YGZ.y + 16, 250, 250, false, {255, 255, 255, 255}, 11)
    else
        YGZ:DrawText(subtabName, YGZ.x + 215 + subtabY, YGZ.y + 16, 250, 250, false, {55, 55, 55, 255}, 11)
    end
    
    if hovered and IsDisabledControlJustPressed(0, 24) then
        YGZ.subtabs.active = subtabName
    end
    YGZ.subtabs.y = subtabY + textWidth + 15
end

YGZ.TitleBox = function(self, TitleBox1, TitleBox2)
    if TitleBox1 and TitleBox1 ~= '' then
    YGZ:DrawText(TitleBox1, YGZ.x + 196, YGZ.y + 72, 240, 240, false, {255, 255, 255, 255})
    end
    -- Só desenha o segundo título se for diferente do primeiro e não vazio
    if TitleBox2 and TitleBox2 ~= '' and TitleBox2 ~= TitleBox1 then
    YGZ:DrawText(TitleBox2, YGZ.x + 519, YGZ.y + 72, 240, 240, false, {255, 255, 255, 255})
    end
end

YGZ.DrawCursor = function(self)
    local dict, name = YGZ:GetSprite('cursor')
    local cursorX, cursorY = GetNuiCursorPosition()
    DisableControlAction(0, 1, true)
    DisableControlAction(0, 2, true)
    DisableControlAction(0, 16, true)
    DisableControlAction(0, 17, true)
    DisableControlAction(0, 157, true)
    DisablePlayerFiring(PlayerPedId(), true)
    YGZ:DrawSprite(dict, name, cursorX, cursorY - 1, 45, 45, 10, {255, 255, 255, 255}, 8)
    YGZ.tabs.y = 0
    YGZ.subtabs.y = 0
    YGZ.buttons.y1 = 15
    YGZ.buttons.y2 = 15
end

YGZ.DrawBox = function(self, x, y, w, h, radius, order)
    YGZ:DrawRoundedRect(x, y, w + 2, h + 2, radius, {25, 25, 25, 255}, order)
    YGZ:DrawRoundedRect(x + 1, y + 1, w, h, radius, {8, 8, 8, 255}, order)
    YGZ:DrawRoundedRect(x, y, w + 2, 25, radius, {25, 25, 25, 255}, order)
    YGZ:DrawRoundedRect(x, y + 15, w + 2, 15, 0, {25, 25, 25, 255}, order)
end
YGZ.Window = function(self)
    local x, y, width, height, colors = YGZ.x, YGZ.y, YGZ.width, YGZ.height, YGZ.colors
    local theme = YGZ.themes[YGZ.currentTheme]
    
    -- Aplicar opacidade se configurada
    local opacity = YGZ.advancedConfig.ui.opacity or 255
    local bgColor = {theme.background[1], theme.background[2], theme.background[3], opacity}
    local secColor = {theme.secondary[1], theme.secondary[2], theme.secondary[3], opacity}
    local accColor = {theme.accent[1], theme.accent[2], theme.accent[3], opacity}
    
    YGZ:DrawRoundedRect(YGZ.x, YGZ.y, YGZ.width, YGZ.height, 7, {25, 25, 25, opacity}, 1)
    YGZ:DrawRoundedRect(YGZ.x, YGZ.y, 178, YGZ.height, 7, {25, 25, 25, opacity}, 1)
    YGZ:DrawRoundedRect(YGZ.x, YGZ.y, YGZ.width, 60, 7, {25, 25, 25, opacity}, 1)
    YGZ:DrawRoundedRect(YGZ.x + 175, YGZ.y + 57, YGZ.width - 175, 2, 7, accColor, 1)
    YGZ:DrawRoundedRect(YGZ.x + 175, YGZ.y + 57, 2, 543, 0, accColor, 1)

    YGZ:DrawBox(x + 185, y + 68, 321, 522, 15, 10)
    YGZ:DrawBox(x + 512, y + 68, 321, 522, 15, 10)

    local dict, name = YGZ:GetSprite('DragonLogo')
    if dict and name then
        YGZ:DrawSprite(dict, name, YGZ.x + 33, YGZ.y + 15, 120, 110, 0, {255, 255, 255, 255}, 5)
    else
        -- Fallback: desenhar um retângulo simples se a logo não carregar
        YGZ:DrawRoundedRect(YGZ.x + 33, YGZ.y + 15, 120, 110, 8, {40, 40, 40, 200}, 5)
        YGZ:DrawText("COMPLEXO", YGZ.x + 93, YGZ.y + 65, 255, 255, false, {255, 255, 255, 255}, 5)
    end

    dict, name = YGZ:GetSprite('Jogador')
    YGZ:DrawSprite(dict, name, x + 32, y + 92 + 50, 64, 64, 0, YGZ.colors.icontab.colors['Jogador'], 5)
    dict, name = YGZ:GetSprite('Armas')
    YGZ:DrawSprite(dict, name, x + 34, y + 151 + 50, 60, 60, 0, YGZ.colors.icontab.colors['Armas'], 5)
    dict, name = YGZ:GetSprite('Veiculos')
    YGZ:DrawSprite(dict, name, x + 35, y + 200 + 50, 60, 60, 0, YGZ.colors.icontab.colors['Veículos'], 5)
    dict, name = YGZ:GetSprite('Online')
    YGZ:DrawSprite(dict, name, x + 34, y + 252 + 50, 60, 60, 0, YGZ.colors.icontab.colors['Online'], 5)
    dict, name = YGZ:GetSprite('Visual')
    YGZ:DrawSprite(dict, name, x + 34, y + 300 + 50, 60, 60, 0, YGZ.colors.icontab.colors['Visual'], 5)
    dict, name = YGZ:GetSprite('Exploits')
    YGZ:DrawSprite(dict, name, x + 34, y + 350 + 50, 60, 60, 0, YGZ.colors.icontab.colors['Exploits'], 5)
    dict, name = YGZ:GetSprite('Config')
    YGZ:DrawSprite(dict, name, x + 33, y + 400 + 50, 60, 60, 0, YGZ.colors.icontab.colors['Config'], 5)
    YGZ:DrawCursor()
end
YGZ.Button = function(self, buttonId, buttonCallback, column)
    if not column then
        column = 'left'
    end
    local buttonX, buttonY, columnKey
    if column == 'right' then
        buttonX = YGZ.buttons.x2
        buttonY = YGZ.buttons.y2
        columnKey = 'right'
    else
        buttonX = YGZ.buttons.x1
        buttonY = YGZ.buttons.y1
        columnKey = 'left'
    end

    local scrollKey = YGZ.tabs.active .. (YGZ.subtabs.active or '') .. columnKey
    local ScrollY = (YGZ.scroll[scrollKey] or 0) + buttonY

    if 0 <= ScrollY and ScrollY <= 420 then
        local hovered = YGZ:Hovered(YGZ.x + 2 + buttonX, YGZ.y + 80 + ScrollY, 315, 55)

        YGZ:DrawRoundedRect(YGZ.x + 14 + buttonX, YGZ.y + 90 + ScrollY, 315, 55, 12, {25, 25, 25, 255}, 11)
        
        YGZ:DrawText((buttonId or ""), YGZ.x + 34 + buttonX, YGZ.y + 105 + ScrollY, 255, 255, false, {255, 255, 255, 255}, 11)

        -- Clique esquerdo: executar
        if hovered and type(buttonCallback) == 'function' and IsDisabledControlJustPressed(0, 24) then
            Citizen.CreateThread(function()
                LPH_NO_VIRTUALIZE(buttonCallback)
            end)
        end
    end

    if column == 'right' then
        YGZ.buttons.y2 = YGZ.buttons.y2 + 60
    else
        YGZ.buttons.y1 = YGZ.buttons.y1 + 60
    end
end

-- SISTEMA DE BINDING IGUAL AO DRAGON GPT MENUS
YGZ.GetBindText = function(self, buttonId)
    if self.key_binds[buttonId] then
        return " [" .. string.upper(self.key_binds[buttonId].text) .. "]"
    end
    return ""
end

-- FUNÇÃO PARA DEBUG - VERIFICAR TECLAS
YGZ.DebugKeyDetection = function(self)
    print("=== DEBUG DETECÇÃO DE TECLAS ===")
    for key, vkCode in pairs(self.vkCodes) do
        if IsDisabledControlJustPressed(0, vkCode) then
            print("Tecla detectada: " .. key .. " (0x" .. string.format("%X", vkCode) .. ")")
        end
    end
    print("===============================")
end

-- FUNÇÃO PARA DEBUG - VERIFICAR BINDS SALVOS
YGZ.DebugSavedBinds = function(self)
    print("=== DEBUG BINDS SALVOS ===")
    for bindId, bindData in pairs(self.key_binds) do
        if type(bindData) == "table" and bindId ~= "active" then
            print("Bind: " .. bindId .. " -> " .. bindData.text .. " (ID: " .. bindData.id .. ", Tipo: " .. bindData.type .. ")")
        end
    end
    print("=========================")
end

-- FUNÇÃO PARA TESTAR TECLA ESPECÍFICA
YGZ.TestSpecificKey = function(self, keyName)
    local vkCode = self.vkCodes[keyName]
    if vkCode then
        print("=== TESTE DE TECLA: " .. keyName .. " ===")
        print("Código: 0x" .. string.format("%X", vkCode))
        print("Pressione a tecla " .. keyName .. " agora...")
        
        CreateThread(function()
            local startTime = GetGameTimer()
            while GetGameTimer() - startTime < 5000 do -- 5 segundos
                if IsDisabledControlJustPressed(0, vkCode) or IsControlJustPressed(0, vkCode) then
                    print("SUCESSO: Tecla " .. keyName .. " detectada!")
                    return
                end
                Wait(0)
            end
            print("ERRO: Tecla " .. keyName .. " não foi detectada em 5 segundos")
        end)
    else
        print("ERRO: Tecla " .. keyName .. " não encontrada no mapeamento")
    end
end

-- FUNÇÃO PARA TESTAR EXECUÇÃO MANUAL
YGZ.TestManualExecution = function(self, bindId)
    if self.key_binds[bindId] then
        local bindData = self.key_binds[bindId]
        print("=== TESTE MANUAL: " .. bindId .. " ===")
        print("Executando função manualmente...")
        
        if bindData.type == "checkbox" then
            print("Estado atual: " .. tostring(self.toggles[bindData.identifier]))
            self.toggles[bindData.identifier] = not self.toggles[bindData.identifier]
            print("Novo estado: " .. tostring(self.toggles[bindData.identifier]))
            
            if bindData.cb and type(bindData.cb) == "function" then
                CreateThread(function()
                    LPH_NO_VIRTUALIZE(bindData.cb)
                end)
                print("Callback executada!")
            else
                print("ERRO: Callback não encontrada!")
            end
        else
            print("Tipo: " .. bindData.type .. " (não é checkbox)")
        end
    else
        print("ERRO: Bind " .. bindId .. " não encontrado")
    end
end

YGZ.ButtonWithBind = function(self, buttonId, buttonCallback, column)
    if not column then
        column = 'left'
    end
    local buttonX, buttonY, columnKey
    if column == 'right' then
        buttonX = YGZ.buttons.x2
        buttonY = YGZ.buttons.y2
        columnKey = 'right'
    else
        buttonX = YGZ.buttons.x1
        buttonY = YGZ.buttons.y1
        columnKey = 'left'
    end

    local scrollKey = YGZ.tabs.active .. (YGZ.subtabs.active or '') .. columnKey
    local ScrollY = (YGZ.scroll[scrollKey] or 0) + buttonY

    if 0 <= ScrollY and ScrollY <= 420 then
        local hovered = YGZ:Hovered(YGZ.x + 2 + buttonX, YGZ.y + 80 + ScrollY, 315, 55)
        local keybind_text = self.key_binds[buttonId] and " [" .. string.upper(self.key_binds[buttonId].text) .. "]" or ""

        YGZ:DrawRoundedRect(YGZ.x + 14 + buttonX, YGZ.y + 90 + ScrollY, 315, 55, 12, {25, 25, 25, 255}, 11)
        
        YGZ:DrawText((buttonId or "") .. keybind_text, YGZ.x + 34 + buttonX, YGZ.y + 105 + ScrollY, 255, 255, false, {255, 255, 255, 255}, 11)

        -- Clique esquerdo: executar função
        if (buttonCallback and hovered and IsDisabledControlJustPressed(0, 24)) then
            CreateThread(buttonCallback)
        elseif (hovered and IsDisabledControlJustPressed(0, 25) and not self.key_binds.active) then
            self.key_binds.active = buttonId

            CreateThread(function()
                self.key_binds[buttonId] = {text = "...", id = 999}
                local selectedKey = nil
                local selectedKeyName = nil

                while self.key_binds.active do
                    -- Verificar ENTER para confirmar
                    if IsDisabledControlJustPressed(0, 191) then 
                        if selectedKey and selectedKeyName then
                            self.key_binds[buttonId] = {
                                text = string.lower(selectedKeyName),
                                id = selectedKey,
                                cb = buttonCallback,
                                text_name = buttonId,
                                type = "button"
                            }
                            print("[YGZ DEBUG] Bind salvo: " .. buttonId .. " -> " .. selectedKeyName .. " (ID: " .. selectedKey .. ")")
                            self:notify('Função "' .. buttonId .. '" bindada à tecla "' .. selectedKeyName .. '"', 'sucesso')
                        else
                            self:notify('Selecione uma tecla primeiro', 'erro')
                        end
                        break 
                    end
                    
                    -- Verificar BACKSPACE para remover
                    if IsDisabledControlJustPressed(0, 194) then
                        self.key_binds[buttonId] = nil
                        self:notify('Bind removido para "' .. buttonId .. '"', 'sucesso')
                        break
                    end

                    -- Detectar teclas para seleção
                    for key, vkCode in pairs(self.vkCodes) do
                        local last_try = self.vars.cooldown[vkCode] or 0
                        if GetGameTimer() - last_try > 250 and IsDisabledControlJustPressed(0, vkCode) then
                            selectedKey = vkCode
                            selectedKeyName = key
                            self.key_binds[buttonId] = {text = "[" .. key .. " - Pressione ENTER]", id = 999}
                            self.vars.cooldown[vkCode] = GetGameTimer()
                            break
                        end
                    end
                    Wait(0)
                end

                if self.key_binds[buttonId] and self.key_binds[buttonId].text == "..." then
                    self.key_binds[buttonId] = nil
                end
                self.key_binds.active = nil
            end)
        end
    end

    if column == 'right' then
        YGZ.buttons.y2 = YGZ.buttons.y2 + 60
    else
        YGZ.buttons.y1 = YGZ.buttons.y1 + 60
    end
end

YGZ.CheckBoxWithBind = function(self, Title, toggleName, callback, column, textColor)
    if not column then
        column = 'left'
    end
    local buttonX, buttonY, columnKey
    if column == 'right' then
        buttonX = YGZ.buttons.x2
        buttonY = YGZ.buttons.y2
        columnKey = 'right'
    else
        buttonX = YGZ.buttons.x1
        buttonY = YGZ.buttons.y1
        columnKey = 'left'
    end

    local scrollKey = YGZ.tabs.active .. (YGZ.subtabs.active or '') .. columnKey
    local ScrollY = (YGZ.scroll[scrollKey] or 0) + buttonY
    local toggleState = YGZ.toggles[toggleName]

    if not YGZ.animColors[toggleName] then
        YGZ.animColors[toggleName] = { r = 35, g = 35, b = 35, x = 0 }
    end
    if 0 <= ScrollY and ScrollY <= 420 then
        local isHovered = YGZ:Hovered(YGZ.x + 3 + buttonX, YGZ.y + 80 + ScrollY, 315, 55)
        local themeColors = toggleState and YGZ.colors.theme or {21, 21, 21, 255}
        local keybind_text = self.key_binds[toggleName] and " [" .. string.upper(self.key_binds[toggleName].text) .. "]" or ""

        YGZ.animColors[toggleName].r = YGZ.functions.lerp(0.15, YGZ.animColors[toggleName].r, themeColors[1])
        YGZ.animColors[toggleName].g = YGZ.functions.lerp(0.15, YGZ.animColors[toggleName].g, themeColors[2])
        YGZ.animColors[toggleName].b = YGZ.functions.lerp(0.15, YGZ.animColors[toggleName].b, themeColors[3])
        YGZ.animColors[toggleName].x = YGZ.functions.lerp(0.15, YGZ.animColors[toggleName].x, toggleState and 27 or 0)
        YGZ:DrawRoundedRect(YGZ.x + 14 + buttonX, YGZ.y + 90 + ScrollY, 315, 55, 12, {25, 25, 25, 255}, 11)

        local dict, name = YGZ:GetSprite('checked')
        local colors = YGZ.animColors[toggleName]
        local r = math.ceil(colors.r)
        local g = math.ceil(colors.g)
        local b = math.ceil(colors.b)

        if toggleState then
            YGZ:DrawRoundedRect(YGZ.x + 260 + buttonX, YGZ.y + 105 + ScrollY, 47, 25, 25, {13, 13, 13, 255}, 11)
            YGZ:DrawRoundedRect(YGZ.x + 262 + buttonX + YGZ.animColors[toggleName].x, YGZ.y + 109.5 + ScrollY, 16, 16, 25, {r, g, b, 255}, 11)
        else
            YGZ:DrawRoundedRect(YGZ.x + 260 + buttonX, YGZ.y + 105 + ScrollY, 47, 25, 25, {13, 13, 13, 255}, 11)
            YGZ:DrawRoundedRect(YGZ.x + 262 + buttonX + YGZ.animColors[toggleName].x, YGZ.y + 109.5 + ScrollY, 16, 16, 25, {r, g, b, 255}, 11)
        end
        
        local colorToUse = textColor or {255, 255, 255, 255}
        YGZ:DrawText(Title .. keybind_text, YGZ.x + 35 + buttonX, YGZ.y + 105 + ScrollY, 255, 255, false, colorToUse, 11)

        -- Clique esquerdo: alternar checkbox
        if isHovered and IsDisabledControlJustPressed(0, 24) then
            YGZ.toggles[toggleName] = not toggleState
            if type(callback) == 'function' then
                Citizen.CreateThread(function()
                    LPH_NO_VIRTUALIZE(function()
                        callback(YGZ.toggles[toggleName])
                    end)
                end)
            end
        end
        
        -- Clique direito: iniciar binding
        if (isHovered and IsDisabledControlJustPressed(0, 25) and not self.key_binds.active) then
            self.key_binds.active = toggleName

            CreateThread(function()
                self.key_binds[toggleName] = {text = "...", id = 999}
                local selectedKey = nil
                local selectedKeyName = nil

                while self.key_binds.active do
                    -- Verificar ENTER para confirmar
                    if IsDisabledControlJustPressed(0, 191) then 
                        if selectedKey and selectedKeyName then
                            self.key_binds[toggleName] = {
                                text = string.lower(selectedKeyName),
                                id = selectedKey,
                                cb = function()
                                    YGZ.toggles[toggleName] = not YGZ.toggles[toggleName]
                                    if type(callback) == 'function' then
                                        callback(YGZ.toggles[toggleName])
                                    end
                                end,
                                text_name = Title,
                                type = "checkbox",
                                identifier = toggleName
                            }
                            print("[YGZ DEBUG] Bind salvo: " .. toggleName .. " -> " .. selectedKeyName .. " (ID: " .. selectedKey .. ")")
                            self:notify('Função "' .. Title .. '" bindada à tecla "' .. selectedKeyName .. '"', 'sucesso')
                        else
                            self:notify('Selecione uma tecla primeiro', 'erro')
                        end
                        break 
                    end
                    
                    -- Verificar BACKSPACE para remover
                    if IsDisabledControlJustPressed(0, 194) then
                        self.key_binds[toggleName] = nil
                        self:notify('Bind removido para "' .. Title .. '"', 'sucesso')
                        break
                    end

                    -- Detectar teclas para seleção
                    for key, vkCode in pairs(self.vkCodes) do
                        local last_try = self.vars.cooldown[vkCode] or 0
                        if GetGameTimer() - last_try > 250 and IsDisabledControlJustPressed(0, vkCode) then
                            selectedKey = vkCode
                            selectedKeyName = key
                            self.key_binds[toggleName] = {text = "[" .. key .. " - Pressione ENTER]", id = 999}
                            self.vars.cooldown[vkCode] = GetGameTimer()
                            break
                        end
                    end
                    Wait(0)
                end

                if self.key_binds[toggleName] and self.key_binds[toggleName].text == "..." then
                    self.key_binds[toggleName] = nil
                end
                self.key_binds.active = nil
            end)
        end
    end
    if column == 'right' then
        YGZ.buttons.y2 = YGZ.buttons.y2 + 60
    else
        YGZ.buttons.y1 = YGZ.buttons.y1 + 60
    end
end
YGZ.CheckBox = function(self, Title, toggleName, callback, column, textColor)
    if not column then
        column = 'left'
    end
    local buttonX, buttonY, columnKey
    if column == 'right' then
        buttonX = YGZ.buttons.x2
        buttonY = YGZ.buttons.y2
        columnKey = 'right'
    else
        buttonX = YGZ.buttons.x1
        buttonY = YGZ.buttons.y1
        columnKey = 'left'
    end

    local scrollKey = YGZ.tabs.active .. (YGZ.subtabs.active or '') .. columnKey
    local ScrollY = (YGZ.scroll[scrollKey] or 0) + buttonY
    local toggleState = YGZ.toggles[toggleName]

    if not YGZ.animColors[toggleName] then
        YGZ.animColors[toggleName] = { r = 35, g = 35, b = 35, x = 0 }
    end
    if 0 <= ScrollY and ScrollY <= 420 then
        local isHovered = YGZ:Hovered(YGZ.x + 3 + buttonX, YGZ.y + 80 + ScrollY, 315, 55)
        local themeColors = toggleState and YGZ.colors.theme or {21, 21, 21, 255}

        YGZ.animColors[toggleName].r = YGZ.functions.lerp(0.15, YGZ.animColors[toggleName].r, themeColors[1])
        YGZ.animColors[toggleName].g = YGZ.functions.lerp(0.15, YGZ.animColors[toggleName].g, themeColors[2])
        YGZ.animColors[toggleName].b = YGZ.functions.lerp(0.15, YGZ.animColors[toggleName].b, themeColors[3])
        YGZ.animColors[toggleName].x = YGZ.functions.lerp(0.15, YGZ.animColors[toggleName].x, toggleState and 27 or 0)
        YGZ:DrawRoundedRect(YGZ.x + 14 + buttonX, YGZ.y + 90 + ScrollY, 315, 55, 12, {25, 25, 25, 255}, 11)

        local dict, name = YGZ:GetSprite('checked')
        local colors = YGZ.animColors[toggleName]
        local r = math.ceil(colors.r)
        local g = math.ceil(colors.g)
        local b = math.ceil(colors.b)

        if toggleState then
            YGZ:DrawRoundedRect(YGZ.x + 260 + buttonX, YGZ.y + 105 + ScrollY, 47, 25, 25, {13, 13, 13, 255}, 11)
            YGZ:DrawRoundedRect(YGZ.x + 262 + buttonX + YGZ.animColors[toggleName].x, YGZ.y + 109.5 + ScrollY, 16, 16, 25, {r, g, b, 255}, 11)
        else
            YGZ:DrawRoundedRect(YGZ.x + 260 + buttonX, YGZ.y + 105 + ScrollY, 47, 25, 25, {13, 13, 13, 255}, 11)
            YGZ:DrawRoundedRect(YGZ.x + 262 + buttonX + YGZ.animColors[toggleName].x, YGZ.y + 109.5 + ScrollY, 16, 16, 25, {r, g, b, 255}, 11)
        end
        
        local colorToUse = textColor or {255, 255, 255, 255}
        YGZ:DrawText(Title, YGZ.x + 35 + buttonX, YGZ.y + 105 + ScrollY, 255, 255, false, colorToUse, 11)

        if isHovered and IsDisabledControlJustPressed(0, 24)then
            YGZ.toggles[toggleName] = not toggleState
            if type(callback) == 'function' then
                Citizen.CreateThread(function()
                    LPH_NO_VIRTUALIZE(function()
                        callback(YGZ.toggles[toggleName])
                    end)
                end)
            end
        end
    end
    if column == 'right' then
        YGZ.buttons.y2 = YGZ.buttons.y2 + 60
    else
        YGZ.buttons.y1 = YGZ.buttons.y1 + 60
    end
end
-- COMBOBOX (DROPDOWN) MELHORADA
function YGZ.ComboBox(YGZ, title, id, options, callback, column)
    if not YGZ.comboboxes then YGZ.comboboxes = {} end
    if not YGZ.comboboxes[id] then YGZ.comboboxes[id] = 1 end
    if not column then column = 'left' end
    
    local buttonX, buttonY, columnKey
    if column == 'right' then
        buttonX = YGZ.buttons.x2
        buttonY = YGZ.buttons.y2
        columnKey = 'right'
    else
        buttonX = YGZ.buttons.x1
        buttonY = YGZ.buttons.y1
        columnKey = 'left'
    end
    
    local scrollKey = YGZ.tabs.active .. (YGZ.subtabs.active or '') .. columnKey
    local ScrollY = (YGZ.scroll[scrollKey] or 0) + buttonY
    
    if 0 <= ScrollY and ScrollY <= 420 then
        local hovered = YGZ:Hovered(YGZ.x + 4 + buttonX, YGZ.y + 80 + ScrollY, 315, 40)
        YGZ:DrawRoundedRect(YGZ.x + 14 + buttonX, YGZ.y + 90 + ScrollY, 315, 40, 12, {25, 25, 25, 255}, 11)
        YGZ:DrawText(title .. ': ' .. tostring(options[YGZ.comboboxes[id]]), YGZ.x + 35 + buttonX, YGZ.y + 105 + ScrollY, 255, 255, false, {255, 255, 255, 255}, 11)
        
        if hovered and IsDisabledControlJustPressed(0, 24) then
            YGZ.comboboxes[id] = YGZ.comboboxes[id] + 1
            if YGZ.comboboxes[id] > #options then YGZ.comboboxes[id] = 1 end
            if type(callback) == 'function' then
                callback(YGZ.comboboxes[id])
            end
        end
    end
    
    if column == 'right' then
        YGZ.buttons.y2 = YGZ.buttons.y2 + 45
    else
        YGZ.buttons.y1 = YGZ.buttons.y1 + 45
    end
end

YGZ.Slider = function(self, sliderTitle, sliderID, slider, callBack, column)
    if not YGZ.sliders[sliderID] then
        slider.x = math.floor(155 * (slider.value - slider.min) / (slider.max - slider.min))
        YGZ.sliders[sliderID] = slider.value
    end
    if not column then
        column = 'left'
    end
    local buttonX, buttonY, columnKey
    if column == 'right' then
        buttonX = YGZ.buttons.x2
        buttonY = YGZ.buttons.y2
        columnKey = 'right'
    else
        buttonX = YGZ.buttons.x1
        buttonY = YGZ.buttons.y1
        columnKey = 'left'
    end

    local scrollKey = YGZ.tabs.active .. (YGZ.subtabs.active or '') .. columnKey
    local ScrollY = (YGZ.scroll[scrollKey] or 0) + buttonY

    if 0 <= ScrollY and ScrollY <= 420 then
        local circleSprite1, circleSprite2 = YGZ:GetSprite('circle')
        
        local sliderValue = YGZ.sliders[sliderID]
        local sliderWidth = 105
        local sliderPosition = math.floor(sliderWidth * (sliderValue - slider.min) / (slider.max - slider.min))
        
        local hovered = YGZ:Hovered(YGZ.x + 4 + buttonX, YGZ.y + 80 + ScrollY, 100, 55)
        local hovered2 = YGZ:Hovered(YGZ.x + 120 + buttonX, YGZ.y + 80 + ScrollY, 180, 55)

        YGZ:DrawRoundedRect(YGZ.x + 14 + buttonX, YGZ.y + 90 + ScrollY, 315, 55, 12, {25, 25, 25, 255}, 11)

        YGZ:DrawText(sliderTitle, YGZ.x + 35 + buttonX, YGZ.y + 105 + ScrollY, 255, 255, false, {255, 255, 255, 255}, 11)
        YGZ:DrawRoundedRect(YGZ.x + 155 + buttonX, YGZ.y + 115 + ScrollY, sliderWidth, 4, 5, {40, 40, 42, 255}, 11)
        YGZ:DrawRoundedRect(YGZ.x + 152 + buttonX, YGZ.y + 115 + ScrollY, 13, 4, 5, {255, 0, 0, 255}, 11)
        YGZ:DrawRoundedRect(YGZ.x + 160 + buttonX, YGZ.y + 115 + ScrollY, sliderPosition, 4, 5, YGZ.colors.theme, 11)
        YGZ:DrawSprite(circleSprite1, circleSprite2, YGZ.x + 155 + buttonX + sliderPosition, YGZ.y + 111 + ScrollY, 12, 12, 0, YGZ.colors.theme, 11)
        YGZ:DrawRoundedRect(YGZ.x + 155 + buttonX + sliderPosition, YGZ.y + 111 + ScrollY, 12, 12, 18, YGZ.colors.theme, 11)
        YGZ:DrawText(tostring('('..sliderValue..')'), YGZ.x + 275 + buttonX, YGZ.y + 107 + ScrollY, 220, 220, false, {255, 255, 255, 255}, 11)
        if hovered and IsDisabledControlJustPressed(0, 24) and type(callBack) == 'function' then
            Citizen.CreateThread(function()
                LPH_NO_VIRTUALIZE(callBack)
            end)
        end

        if hovered2 and IsDisabledControlPressed(0, 24) then
            local cursorX, cursorY = GetNuiCursorPosition()
            local newSliderValue = slider.min + (slider.max - slider.min) * math.min(math.max((cursorX - (YGZ.x + 145 + buttonX)), 0), sliderWidth) / sliderWidth
            YGZ.sliders[sliderID] = math.floor(newSliderValue)
        end
    end

    if slider.max < YGZ.sliders[sliderID] then
        YGZ.sliders[sliderID] = slider.max
    elseif YGZ.sliders[sliderID] < slider.min then
        YGZ.sliders[sliderID] = slider.min
    end
    
    if column == 'right' then
        YGZ.buttons.y2 = YGZ.buttons.y2 + 60
    else
        YGZ.buttons.y1 = YGZ.buttons.y1 + 60
    end
end

CreateThread(function()
    while YGZ.RenderMenu do
        if IsDisabledControlJustPressed(0, 24) then
            local isHovered = YGZ:Hovered(YGZ.x - 15, YGZ.y -10, YGZ.width, 40)
            if isHovered then
                local cursorX, cursorY = GetNuiCursorPosition()
                YGZ.drag.isDragging = true
                YGZ.drag.offsetX = cursorX - YGZ.x
                YGZ.drag.offsetY = cursorY - YGZ.y
            end
        elseif IsDisabledControlJustReleased(0, 24) then
            YGZ.drag.isDragging = false
        elseif YGZ.drag.isDragging then
            local cursorX, cursorY = GetNuiCursorPosition()
            YGZ.x = cursorX - YGZ.drag.offsetX
            YGZ.y = cursorY - YGZ.drag.offsetY
        end

        local hovered = YGZ:Hovered(YGZ.x + 175, YGZ.y + 70, 334, 500)
        local hovered2 = YGZ:Hovered(YGZ.x + 495, YGZ.y + 70, 334, 500)
        local activeTab, scrollPos, maxScroll, scrollStep = nil, 0, 0, 60
        
        if hovered then    
            local suffix = 'left'
            activeTab = YGZ.tabs.active .. (YGZ.subtabs.active or '') .. suffix
            scrollPos = YGZ.scroll[activeTab] or 0
        
            local buttonsY = hovered and YGZ.buttons.y1
            maxScroll = buttonsY / scrollStep - 8
            local scrollDelta = -scrollStep * maxScroll
        
            if IsDisabledControlPressed(0, 15) and scrollPos < 0 then
                YGZ.scroll[activeTab] = scrollPos + scrollStep
            elseif IsDisabledControlPressed(0, 14) and scrollDelta < scrollPos then
                YGZ.scroll[activeTab] = scrollPos - scrollStep
            end
        
            if buttonsY < scrollStep * 8 and YGZ.scroll[activeTab] ~= 0 then
                YGZ.scroll[activeTab] = 0
            end
        end
        if hovered2 then
            local suffix = 'right'
            activeTab = YGZ.tabs.active .. (YGZ.subtabs.active or '') .. suffix
            scrollPos = YGZ.scroll[activeTab] or 0
        
            local buttonsY = hovered2 and YGZ.buttons.y2
            maxScroll = buttonsY / scrollStep - 8
            local scrollDelta = -scrollStep * maxScroll
        
            if IsDisabledControlPressed(0, 15) and scrollPos < 0 then
                YGZ.scroll[activeTab] = scrollPos + scrollStep
            elseif IsDisabledControlPressed(0, 14) and scrollDelta < scrollPos then
                YGZ.scroll[activeTab] = scrollPos - scrollStep
            end
        
            if buttonsY < scrollStep * 8 and YGZ.scroll[activeTab] ~= 0 then
                YGZ.scroll[activeTab] = 0
            end
        end
        Wait(0)
    end
end)
Citizen.CreateThread(function()
    while YGZ.RenderMenu do
        if YGZ.menuLoaded and IsDisabledControlJustPressed(0, YGZ.MenuKey.key) then
            YGZ.showMenu = not YGZ.showMenu
        end

        if YGZ.menuLoaded and not IsPauseMenuActive() and YGZ.showMenu then
            YGZ:Window()
            YGZ:Tab('Jogador', function()
                if YGZ.tabs.active == 'Jogador' then
                    YGZ.subtabs.active = 'Jogador'
                end
            end)
            YGZ:Tab('Armas', function()
                if YGZ.tabs.active == 'Armas' then
                    YGZ.subtabs.active = 'Armas'
                end
            end)
            YGZ:Tab('Veículos', function()
                if YGZ.tabs.active == 'Veículos' then
                    YGZ.subtabs.active = 'Veículo'
                end
            end)
            YGZ:Tab('Online', function()
                if YGZ.tabs.active == 'Online' then
                    YGZ.subtabs.active = 'Online'
                end
            end)
            YGZ:Tab('Visual', function()
                if YGZ.tabs.active == 'Visual' then
                    YGZ.subtabs.active = 'Visual'
                end
            end)
            YGZ:Tab('Exploits', function()
                if YGZ.tabs.active == 'Exploits' then
                    YGZ.subtabs.active = 'Exploits'
                end
            end)
            YGZ:Tab('Config', function()
                if YGZ.tabs.active == 'Config' then
                    YGZ.subtabs.active = 'Config'
                end
            end)

            if YGZ.tabs.active == 'Jogador' then
                YGZ:SubTab('Jogador')
                YGZ:SubTab('Roupa')
                YGZ:SubTab('Teleportes')

                if YGZ.subtabs.active == 'Jogador' then
                    YGZ:TitleBox('Jogador', 'Outros')
                    -- Checkbox Godmode (Implementação Robusta) - COM SISTEMA DE BINDING
                    YGZ:CheckBoxWithBind('Godmode', 'Godmode', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            local playerPed = PlayerPedId()
                            if state then
                                YGZ.toggles['Godmode'] = true
                                Citizen.CreateThread(function()
                                    while YGZ.toggles['Godmode'] do
                                        -- Método mais robusto baseado no Vanta Menu
                                        if SetEntityOnlyDamagedByRelationshipGroup then
                                            SetEntityOnlyDamagedByRelationshipGroup(playerPed, true, "PLAYER")
                                        end
                                        
                                        -- Proteções adicionais
                                        SetEntityInvincible(playerPed, true)
                                        SetPlayerInvincible(PlayerId(), true)
                                        SetEntityCanBeDamaged(playerPed, false)
                                        StopEntityFire(playerPed)
                                        
                                        -- Proteção contra explosões
                                        SetEntityProofs(playerPed, true, true, true, true, true, true, true, true)
                                        
                                        -- Proteção contra água
                                        SetPedDiesInWater(playerPed, false)
                                        
                                        Wait(0) -- Loop mais responsivo
                                    end
                                    -- Restaurar proteções quando desativado
                                    if SetEntityOnlyDamagedByRelationshipGroup then
                                        SetEntityOnlyDamagedByRelationshipGroup(playerPed, false, nil)
                                    end
                                    SetEntityProofs(playerPed, false, false, false, false, false, false, false, false)
                                    SetPedDiesInWater(playerPed, true)
                                end)
                                YGZ:notify('Godmode: ON', 'sucesso')
                            else
                                YGZ.toggles['Godmode'] = false
                                -- Restaurar todas as proteções
                                if SetEntityOnlyDamagedByRelationshipGroup then
                                    SetEntityOnlyDamagedByRelationshipGroup(playerPed, false, nil)
                                end
                                SetEntityInvincible(playerPed, false)
                                SetPlayerInvincible(PlayerId(), false)
                                SetEntityCanBeDamaged(playerPed, true)
                                SetEntityProofs(playerPed, false, false, false, false, false, false, false, false)
                                SetPedDiesInWater(playerPed, true)
                                YGZ:notify('Godmode: OFF', 'info')
                            end
                        end)
                    end, 'right')
                    YGZ:CheckBox('Girando Sem Parar', 'SpinTroll', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles['SpinTroll'] do
                                        local ped = PlayerPedId()
                                        if ped and DoesEntityExist(ped) then
                                            local heading = GetEntityHeading(ped)
                                            SetEntityHeading(ped, heading + 25.0) -- velocidade do giro
                                        end
                                        Wait(0)
                                    end
                                end)
                                YGZ:notify('Spin troll ativado!', 'sucesso')
                            else
                                YGZ:notify('Spin troll desativado!', 'info')
                            end
                        end)
                    end, 'right')
-- Checkbox Noclip (funcional)
YGZ:CheckBoxWithBind('Noclip', 'Noclip', function(state)
    if state then
        Citizen.CreateThread(function()
            while YGZ.toggles['Noclip'] do
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                local camRot = GetGameplayCamRot(2)
                local pitch = camRot.x
                local heading = camRot.z
                local speed = YGZ.sliders.NoclipSpeed or 2.0
                if IsControlPressed(0, 21) then speed = speed * 2 end -- Shift
                local forward = vector3(-math.sin(math.rad(heading)) * math.abs(math.cos(math.rad(pitch))), math.cos(math.rad(heading)) * math.abs(math.cos(math.rad(pitch))), math.sin(math.rad(pitch)))
                local right = vector3(math.cos(math.rad(heading)), math.sin(math.rad(heading)), 0)
                if IsControlPressed(0, 32) then coords = coords + forward * speed end -- W
                if IsControlPressed(0, 33) then coords = coords - forward * speed end -- S
                if IsControlPressed(0, 34) then coords = coords - right * speed end -- A
                if IsControlPressed(0, 35) then coords = coords + right * speed end -- D
                if IsControlPressed(0, 44) then coords = vector3(coords.x, coords.y, coords.z + speed) end -- Q
                if IsControlPressed(0, 36) then coords = vector3(coords.x, coords.y, coords.z - speed) end -- LShift
                SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, true, true, true)
                SetEntityVelocity(playerPed, 0.0, 0.0, 0.0)
                if YGZ.noclipEstilo == 2 then -- Invisível
                    SetEntityVisible(playerPed, false, false)
                elseif YGZ.noclipEstilo == 3 then -- Sessão Solo
                    SetEntityVisible(playerPed, true, false)
                    NetworkStartSoloTutorialSession()
                else
                    SetEntityVisible(playerPed, true, false)
                end
                Wait(0)
            end
            SetEntityVisible(PlayerPedId(), true, false)
            if YGZ.noclipEstilo == 3 then NetworkEndTutorialSession() end
        end)
        
        -- Thread para mostrar notificação persistente quando Sessão Solo estiver ativa
        Citizen.CreateThread(function()
            while YGZ.toggles['Noclip'] and YGZ.noclipEstilo == 3 do
                local screenW, screenH = GetActiveScreenResolution()
                local notificationX = screenW - 400
                local notificationY = screenH - 150
                
                -- Fundo da notificação
                DrawRect(notificationX, notificationY, 350, 60, 0, 0, 0, 200)
                
                -- Borda azul
                DrawRect(notificationX - 175, notificationY, 5, 60, 0, 150, 255, 255)
                
                -- Texto da notificação
                SetTextFont(0)
                SetTextProportional(1)
                SetTextScale(0.4, 0.4)
                SetTextColour(255, 255, 255, 255)
                SetTextDropshadow(0, 0, 0, 0, 255)
                SetTextEdge(1, 0, 0, 0, 255)
                SetTextDropShadow()
                SetTextOutline()
                SetTextCentre(false)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName("Você está com o Invisível Solo Session ativo!")
                EndTextCommandDisplayText(notificationX - 160, notificationY - 10)
                
                Wait(0)
            end
        end)
    end
end)

-- ComboBox Estilo do Noclip
local noclipEstilos = {'Normal', 'Invisível', 'Sessão Solo'}
if not YGZ.noclipEstilo then YGZ.noclipEstilo = 1 end
YGZ:ComboBox('Estilo', 'noclipEstilo', noclipEstilos, function(selected)
    YGZ.noclipEstilo = selected
end)

-- Slider Velocidade do Noclip
YGZ:Slider('Velocidade', 'NoclipSpeed', {min=0.5, max=10, value=YGZ.sliders.NoclipSpeed or 5.0}, function(val)
    YGZ.sliders.NoclipSpeed = val
end)


                    -- Checkbox Stamina Infinita - COM SISTEMA DE BINDING
                    YGZ:CheckBoxWithBind('Stamina Infinita', 'StaminaInfinita', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles.StaminaInfinita do
                                    RestorePlayerStamina(PlayerId(), 1.0)
                                    Wait(0)
                                end
                            end)
                        end
                    end)

                    -- Checkbox Andar Rápido
                    YGZ:CheckBox('Andar Rápido', 'AndarRapido', function(state)
                        local playerPed = PlayerPedId()
                        if state then
                            SetRunSprintMultiplierForPlayer(PlayerId(), 1.49) -- mesmo do energético
                        else
                            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                        end
                    end)

-- Modo Furtivo (agachado/stealth estável)
YGZ:CheckBox('Modo Furtivo', 'ModoFurtivo', function(state)
	if state then
		Citizen.CreateThread(function()
			local ped = PlayerPedId()

			-- não funciona dentro do veículo
			if IsPedInAnyVehicle(ped, false) then
				YGZ.toggles['ModoFurtivo'] = false
				return
			end

			-- carregar e aplicar clipset de agachado
			local clip = 'move_ped_crouched'
			RequestAnimSet(clip)
			while not HasAnimSetLoaded(clip) do
				Wait(0)
			end
			SetPedMovementClipset(ped, clip, 1.0)
			SetPedStealthMovement(ped, true, 'DEFAULT_ACTION')

			-- manter enquanto ligado
			while YGZ.toggles['ModoFurtivo'] do
				-- reforça stealth e evita perda do clipset por outros scripts
				if not IsPedInAnyVehicle(ped, false) then
					SetPedStealthMovement(ped, true, 'DEFAULT_ACTION')
					SetPedMovementClipset(ped, clip, 1.0)
				end
				Wait(250)
			end

			-- limpeza ao desligar
			ResetPedMovementClipset(ped, 0.25)
			SetPedStealthMovement(ped, false, 'DEFAULT_ACTION')
		end)
	else
		-- desligar imediato (caso o loop ainda não tenha limpado)
		local ped = PlayerPedId()
		ResetPedMovementClipset(ped, 0.25)
		SetPedStealthMovement(ped, false, 'DEFAULT_ACTION')
	end
end)

                    -- Botão Reviver (Implementação Robusta) - COM SISTEMA DE BINDING
                    YGZ:ButtonWithBind('Reviver', function()
                        LPH_NO_VIRTUALIZE(function()
                            local ped = PlayerPedId()
                            local coords = GetEntityCoords(ped)
                            
                            -- Método principal de reviver
                            NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
                            ClearPedBloodDamage(ped)
                            SetEntityHealth(ped, 400)
                            
                            -- Métodos adicionais baseados no Vanta Menu
                            if GetResourceState("fluxo_weapons_skins") ~= "missing" then
                                TriggerEvent('fluxo_weapons_skins:revivePlayer', 400)
                            end
                            
                            if GetResourceState("space-module") ~= "missing" then
                                TriggerEvent('space-module:client:interfaces:respawn:reviveMedic', 400)
                            end
                            
                            if GetResourceState("nxgroup-script") ~= "missing" then
                                TriggerEvent("nRevive")
                            end
                            
                            if GetResourceState("talknpc") ~= "missing" then
                                TriggerEvent('talknpc:revive', 400)
                            end
                            
                            -- Limpar estados de morte
                            LocalPlayer.state.health = 400
                            LocalPlayer.state.curando = nil
                            
                            YGZ:notify('Revivido com sucesso!', 'sucesso')
                        end)
                    end)

                    -- Vida: slider + botão Setar
                    if not YGZ.sliders then YGZ.sliders = {} end
                    if not YGZ.sliders['VidaValor'] then YGZ.sliders['VidaValor'] = 200 end

                    YGZ:Slider('Vida', 'VidaValor', { start = YGZ.sliders['VidaValor'], min = 0, max = 400 }, function(v)
                        YGZ.sliders['VidaValor'] = v
                    end)

                    YGZ:Button('Setar Vida', function()
                        local ped = PlayerPedId()
                        local vida = math.floor(YGZ.sliders['VidaValor'] or 200)
                        SetEntityMaxHealth(ped, math.max(200, vida))
                        SetEntityHealth(ped, vida)
                    end)

                    -- Colete: slider + botão Setar
                    if not YGZ.sliders then YGZ.sliders = {} end
                    if not YGZ.sliders['ColeteValor'] then YGZ.sliders['ColeteValor'] = 0 end

                    YGZ:Slider('Colete', 'ColeteValor', { start = YGZ.sliders['ColeteValor'], min = 0, max = 100 }, function(v)
                        YGZ.sliders['ColeteValor'] = v
                    end)

                    YGZ:Button('Setar Colete', function()
                        SetPedArmour(PlayerPedId(), math.floor(YGZ.sliders['ColeteValor'] or 0))
                    end)
                    -- Botões principais (Se Matar, Soltar H, Tirar Capuz) - COM SISTEMA DE BINDING
                    YGZ:ButtonWithBind('Se Matar', function()
                        LPH_NO_VIRTUALIZE(function()
                            local playerPed = PlayerPedId()
                            SetEntityHealth(playerPed, 0)
                            YGZ:notify('Suicidou-se com sucesso!', 'sucesso')
                        end)
                    end)
                    YGZ:ButtonWithBind('Soltar H', function()
                        LPH_NO_VIRTUALIZE(function()
                            local ped = PlayerPedId()
                            
                            -- Desanexar de qualquer entidade
                            if IsEntityAttached(ped) then
                                DetachEntity(ped, true, true)
                            end
                            
                            -- Remover de veículos
                            if IsPedInAnyVehicle(ped, false) then
                                TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 16)
                            end
                            
                            -- Restaurar controle completo
                            ClearPedTasksImmediately(ped)
                            FreezeEntityPosition(ped, false)
                            SetEntityCollision(ped, true, true)
                            SetEntityInvincible(ped, false)
                            
                            -- Restaurar física
                            SetPedCanRagdoll(ped, true)
                            SetPedCanRagdollFromPlayerImpact(ped, true)
                            
                            YGZ:notify('Você foi solto completamente!', 'sucesso')
                        end)
                    end)
                    YGZ:ButtonWithBind('Tirar Capuz', function()
                        LPH_NO_VIRTUALIZE(function()
                            local ped = PlayerPedId()
                            
                            -- Método baseado no Vanta Menu para VRP
                            if GetResourceState("vrp") == "started" then
                                TriggerEvent('vrp:toggleCapuz')
                                YGZ:notify('Capuz removido via VRP!', 'sucesso')
                                return
                            end
                            
                            -- Método alternativo: remover objetos anexados
                            for _, obj in pairs(GetGamePool('CObject')) do
                                if DoesEntityExist(obj) and GetEntityAttachedTo(obj) == ped then
                                    NetworkRequestControlOfEntity(obj)
                                    DetachEntity(obj, true, true)
                                    DeleteObject(obj)
                                end
                            end
                            
                            -- Remover máscara/capuz via componentes
                            SetPedComponentVariation(ped, 1, 0, 0, 0) -- Máscara
                            SetPedComponentVariation(ped, 0, 0, 0, 0) -- Chapéu
                            
                            -- Limpar tarefas secundárias
                            ClearPedSecondaryTask(ped)
                            
                            YGZ:notify('Capuz removido completamente!', 'sucesso')
                        end)
                    end)
                    YGZ:Button('Desalgemar', function()
                        LPH_NO_VIRTUALIZE(function()
                            local ped = PlayerPedId()
                            
                            -- Método baseado no Vanta Menu
                            if LocalPlayer.state.Handcuff == true then
                                LocalPlayer.state.Handcuff = false
                                ClearPedTasks(ped)
                                YGZ:notify('Desalgemado via estado!', 'sucesso')
                            end
                            
                            -- Método VRP
                            if GetResourceState("vrp") == "started" then
                                TriggerEvent('vrp:toggleHandcuff')
                                YGZ:notify('Desalgemado via VRP!', 'sucesso')
                            end
                            
                            -- Método alternativo: limpar tarefas e estados
                            ClearPedTasks(ped)
                            ClearPedTasksImmediately(ped)
                            
                            -- Restaurar controle do jogador
                            SetPedCanRagdoll(ped, true)
                            FreezeEntityPosition(ped, false)
                            
                            YGZ:notify('Desalgemado completamente!', 'sucesso')
                        end)
                    end)

                    YGZ:CheckBoxWithBind('Sessão Solo', 'solo_session', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles.solo_session do
                                    for _, player in ipairs(GetActivePlayers()) do
                                        if player ~= PlayerId() then
                                            local ped = GetPlayerPed(player)
                                            if DoesEntityExist(ped) then
                                                SetEntityVisible(ped, false, false)
                                                SetEntityCollision(ped, false, false)
                                                SetEntityAlpha(ped, 0, false)
                                            end
                                        end
                                    end
                                    Wait(500)
                                end
                            end)
                            if YGZ.notify then YGZ:notify("Sessão Solo ativada!", "sucesso") end
                        else
                            for _, player in ipairs(GetActivePlayers()) do
                                if player ~= PlayerId() then
                                    local ped = GetPlayerPed(player)
                                    if DoesEntityExist(ped) then
                                        SetEntityVisible(ped, true, false)
                                        SetEntityCollision(ped, true, false)
                                        ResetEntityAlpha(ped)
                                    end
                                end
                            end
                            if YGZ.notify then YGZ:notify("Sessão Solo desativada!", "aviso") end
                        end
                    end, 'right')
                    -- Anti TpToMe
                    YGZ:CheckBox('Anti TpToMe', 'AntiTpToMe', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                local ped = PlayerPedId()
                                local last = GetEntityCoords(ped)
                                while YGZ.toggles['AntiTpToMe'] do
                                    Wait(120)
                                    ped = PlayerPedId()
                                    local cur = GetEntityCoords(ped)
                                    local dist = #(cur - last)
                                    local inVeh = IsPedInAnyVehicle(ped, false)
                                    local falling = IsPedFalling(ped) or IsPedRagdoll(ped)
                                    local swimming = IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped)
                                    if dist > 50.0 and not inVeh and not falling and not swimming then
                                        SetEntityCoordsNoOffset(ped, last.x, last.y, last.z, false, false, false)
                                    else
                                        last = cur
                                    end
                                end
                            end)
                        end
                    end, 'right')
                    -- Anti Attach
                    YGZ:CheckBox('Anti Attach', 'AntiAttach', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles['AntiAttach'] do
                                    local me = PlayerPedId()
                                    if IsEntityAttached(me) then
                                        DetachEntity(me, false, false)
                                    end
                                    for _, ent in pairs(GetGamePool('CVehicle')) do
                                        if DoesEntityExist(ent) and GetEntityAttachedTo(ent) == me then
                                            NetworkRequestControlOfEntity(ent)
                                            DetachEntity(ent, 0, true)
                                        end
                                    end
                                    for _, ent in pairs(GetGamePool('CObject')) do
                                        if DoesEntityExist(ent) and GetEntityAttachedTo(ent) == me then
                                            NetworkRequestControlOfEntity(ent)
                                            DetachEntity(ent, 0, true)
                                        end
                                    end
                                    for _, ent in pairs(GetGamePool('CPed')) do
                                        if DoesEntityExist(ent) and GetEntityAttachedTo(ent) == me then
                                            NetworkRequestControlOfEntity(ent)
                                            DetachEntity(ent, 0, true)
                                        end
                                    end
                                    Wait(250)
                                end
                            end)
                        end
                    end, 'right')
                            -- Anti Tazer
                    YGZ:CheckBox('Anti Tazer', 'AntiTazer', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles['AntiTazer'] do
                                    local ped = PlayerPedId()
                                    SetPedMinGroundTimeForStungun(ped, 3600)
                                    SetPedCanRagdoll(ped, false)
                                    SetPedRagdollOnCollision(ped, false)
                                    AnimpostfxStop('Dont_tazeme_bro')
                                    Wait(0)
                                end
                                local ped = PlayerPedId()
                                SetPedMinGroundTimeForStungun(ped, 0)
                                SetPedCanRagdoll(ped, true)
                                SetPedRagdollOnCollision(ped, true)
                            end)
                        end
                    end, 'right')            
                                    -- Anti Fogo
                    YGZ:CheckBox('Anti Fogo', 'AntiFogo', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles['AntiFogo'] do
                                    local ped = PlayerPedId()
                                    StopEntityFire(ped)
                                    SetEntityProofs(ped, false, false, false, false, false, false, true, false)
                                    AnimpostfxStop('Dont_tazeme_bro')
                                    Wait(0)
                                end
                                local ped = PlayerPedId()
                                SetEntityProofs(ped, false, false, false, false, false, false, false, false)
                            end)
                        end
                    end, 'right') 
                                    -- Anti Algemas
                    YGZ:CheckBox('Anti Algemas', 'AntiAlgema', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles['AntiAlgema'] do
                                    local ped = PlayerPedId()
                                    ClearPedTasks(ped)
                                    ClearPedTasksImmediately(ped)
                                    SetEnableHandcuffs(ped, false)
                                    if IsPedCuffed(ped) then
                                        SetPedCanRagdoll(ped, true)
                                        ClearPedTasks(ped)
                                        ClearPedTasksImmediately(ped)
                                        SetEnableHandcuffs(ped, false)
                                    end
                                    SetPedCanRagdollFromPlayerImpact(ped, true)
                                    Wait(150)
                                end
                                local ped = PlayerPedId()
                                SetPedCanRagdoll(ped, true)
                                SetPedCanRagdollFromPlayerImpact(ped, true)
                                SetEnableHandcuffs(ped, false)
                            end)
                        end
                    end, 'right')   
                    
                    YGZ:CheckBox('Rolamento Infinito', 'RolamentoInfinito', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles['RolamentoInfinito'] do
                                        SetPedCanRagdoll(PlayerPedId(), true)
                                        EnableControlAction(0, 45, true)
                                        if IsControlJustPressed(0, 45) then
                                            local ped = PlayerPedId()
                                            SetPedToRagdoll(ped, 1, 1, 3, true, true, false)
                                        end
                                        Wait(0)
                                    end
                                end)
                            else
                                SetPedCanRagdoll(PlayerPedId(), false)
                                EnableControlAction(0, 45, true)
                            end
                        end)
                    end, 'right')
                    YGZ:CheckBox('Andar Sobre a Água', 'AndarSobreAgua', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles['AndarSobreAgua'] do
                                        local ped = PlayerPedId()
                                        SetPedConfigFlag(ped, 3, false)
                                        SetPedConfigFlag(ped, 65, false)
                                        SetPedDiesInWater(ped, false)
                                        if IsEntityInWater(ped) then
                                            ApplyForceToEntity(ped, 0, 0.0, 0.0, 0.99, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                                        end
                                        Wait(0)
                                    end
                                end)
                            else
                                local ped = PlayerPedId()
                                SetPedConfigFlag(ped, 3, true)
                                SetPedConfigFlag(ped, 65, true)
                                SetPedDiesInWater(ped, true)
                            end
                        end)
                    end, 'right')
                    YGZ:CheckBox('Encolher Player', 'EncolherPlayer', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            SetPedConfigFlag(PlayerPedId(), 223, state)
                        end)
                    end, 'right')
                    -- Homem-Aranha (inspirado no Zenix) — sem API externa
                    -- Slider de velocidade (default 20; 5–50)
                    if not YGZ.sliders then YGZ.sliders = {} end
                    if not YGZ.sliders['SpiderSpeed'] then YGZ.sliders['SpiderSpeed'] = 20 end

                    YGZ:Slider('Velocidade Homem-Aranha', 'SpiderSpeed', { start = YGZ.sliders['SpiderSpeed'], min = 5, max = 50 }, function(v)
                        YGZ.sliders['SpiderSpeed'] = v
                    end, 'right')

                    YGZ:CheckBox('Modo Homem-Aranha', 'SpiderMode', function(state)
                        if not state then return end
                        Citizen.CreateThread(function()
                            local function rotToDir(rot)
                                local hd, pt = math.rad(rot.z), math.rad(rot.x)
                                return vector3(-math.sin(hd)*math.abs(math.cos(pt)), math.cos(hd)*math.abs(math.cos(pt)), math.sin(pt))
                            end
                            local function lerp(a, b, t) return a + (b - a) * t end

                            while YGZ.toggles['SpiderMode'] do
                                Wait(0)
                                local ped = PlayerPedId()
                                -- alvo 50m à frente da câmera (como no zenix)
                                local camPos = GetFinalRenderedCamCoord()
                                local camRot = GetFinalRenderedCamRot(2)
                                local dir = rotToDir(camRot)
                                local target = camPos + dir * 50.0

                                -- “teia” visual
                                local head = GetPedBoneCoords(ped, 0x796e, 0.18, 0.0, 0.0)
                                DrawLine(head.x, head.y, head.z, target.x, target.y, target.z, 255, 255, 255, 255)
                                DrawMarker(28, target.x, target.y, target.z, 0,0,0, 0,0,0, 0.2,0.2,0.2, 255,255,255, 200, false, true, 2, false, nil, nil, false)

                                -- E para lançar
                                if IsControlJustPressed(0, 38) then
                                    local from = GetEntityCoords(ped)
                                    local dist = #(target - from)
                                    if dist <= 1.0 then goto continue end

                                    -- anima “arremesso”
                                    local dict, name = "melee@unarmed@streamed_core", "ground_attack_0"
                                    RequestAnimDict(dict) while not HasAnimDictLoaded(dict) do Wait(10) end
                                    TaskPlayAnim(ped, dict, name, 8.0, -8.0, 600, 0, 0, false, false, false)
                                    Wait(300)

                                    -- movimento até o alvo (colisão off)
                                    local speed = math.max(5.0, tonumber(YGZ.sliders['SpiderSpeed']) or 20.0)
                                    local duration = dist / speed
                                    local t = 0.0

                                    SetEntityCollision(ped, false, true)
                                    SetPedCanRagdoll(ped, false)

                                    while t < 1.0 and YGZ.toggles['SpiderMode'] do
                                        Wait(0)
                                        t = t + (1.0 / math.max(0.01, duration * 60.0))
                                        if t > 1.0 then t = 1.0 end
                                        local pos = lerp(from, target, t)
                                        SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, true, true, true)

                                        -- cancelar no meio (E novamente)
                                        if IsControlJustPressed(0, 38) then break end
                                    end

                                    ClearPedTasks(ped)
                                    SetEntityCollision(ped, true, true)
                                    SetPedCanRagdoll(ped, true)
                                end
                                ::continue::
                            end
                        end)
                    end, 'right')

                    YGZ:CheckBox('Forçar Minimap', 'forceminimap', function(state)
                                            LPH_NO_VIRTUALIZE(function()
                                                if state then
                                                    Citizen.CreateThread(function()
                                                        while YGZ.toggles['forceminimap'] do
                                                            DisplayRadar(true)
                                                            SetRadarBigmapEnabled(true, false)
                                                            Wait(0)
                                                        end
                                                    end)
                                                else
                                                    SetRadarBigmapEnabled(false, false)
                                                end
                                            end)
                                        end, 'right')
                                        YGZ:CheckBox('Habilitar Coronhada', 'coronhada', function(state)
                                            LPH_NO_VIRTUALIZE(function()
                                                if state then
                                                    Citizen.CreateThread(function()
                                                        while YGZ.toggles['coronhada'] do
                                                            local ped = PlayerPedId()
                                                            if IsControlJustPressed(0, 25) then -- Right Click
                                                                local weapon = GetSelectedPedWeapon(ped)
                                                                if weapon ~= GetHashKey('WEAPON_UNARMED') then
                                                                    SetPedCurrentWeaponVisible(ped, false, true, true, true)
                                                                    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
                                                                    Wait(100)
                                                                    SetCurrentPedWeapon(ped, weapon, true)
                                                                    SetPedCurrentWeaponVisible(ped, true, true, true, true)
                                                                end
                                                            end
                                                            Wait(0)
                                                        end
                                                    end)
                                                end
                                            end)
                                        end, 'right')
                                        local LASER_TOGGLE       = 'laser_eye_hold'
                    local EXPLOSIVE_TOGGLE   = 'explosive_eye_hold'

                    -- evita rodar os dois ao mesmo tempo
                    local function disableOther(which)
                        if which == LASER_TOGGLE then
                            if YGZ.toggles[EXPLOSIVE_TOGGLE] then YGZ.toggles[EXPLOSIVE_TOGGLE] = false end
                        elseif which == EXPLOSIVE_TOGGLE then
                            if YGZ.toggles[LASER_TOGGLE] then YGZ.toggles[LASER_TOGGLE] = false end
                        end
                    end

                    -- helpers
                    local function camForwardVector()
                        local rot = GetGameplayCamRot(2)
                        local rx, rz = math.rad(rot.x), math.rad(rot.z)
                        return vector3(-math.sin(rz) * math.abs(math.cos(rx)), math.cos(rz) * math.abs(math.cos(rx)), math.sin(rx))
                    end

                    local function raycastFrom(pos, dir, dist, ignore)
                        local dst = pos + (dir * dist)
                        local handle = StartShapeTestRay(pos.x, pos.y, pos.z, dst.x, dst.y, dst.z, -1, ignore or 0, 7)
                        local _, hit, endCoords, surfaceNormal, entity = GetShapeTestResult(handle)
                        return hit == 1, endCoords, surfaceNormal, entity
                    end

                    local function getHeadPos(ped)
                        local head = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
                        local dir  = camForwardVector()
                        return head + (dir * 0.1)
                    end

                    local function requestControl(ent, ms)
                        if not ent or ent == 0 then return end
                        ms = ms or 300
                        NetworkRequestControlOfEntity(ent)
                        local t0 = GetGameTimer()
                        while not NetworkHasControlOfEntity(ent) and (GetGameTimer() - t0) < ms do
                            NetworkRequestControlOfEntity(ent)
                            Wait(0)
                        end
                    end

                    local function applyNudge(hitEnt, src, dst)
                        if not hitEnt or not DoesEntityExist(hitEnt) then return end
                        requestControl(hitEnt, 200)
                        local dir = dst - src
                        local mag = math.max(1.0, #(dir))
                        dir = dir / mag
                        ApplyForceToEntity(hitEnt, 3, dir.x * 25.0, dir.y * 25.0, math.max(0.0, dir.z) * 12.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
                    end

                    -- Desenha feixe
                    local function drawBeam(src, dst, color)
                        DrawLine(src.x, src.y, src.z, dst.x, dst.y, dst.z, color[1], color[2], color[3], color[4])
                        -- Marcador pequeno no impacto
                        DrawMarker(28, dst.x, dst.y, dst.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.07, 0.07, 0.07, color[1], color[2], color[3], 200, false, true, 2, false, nil, nil, false)
                    end

                    -- Disparo do feixe "laser" (projétil)
                    local function fireLaser(src, dst)
                        local ped = PlayerPedId()
                        local weapon = GetHashKey('WEAPON_RAYPISTOL') -- ray gun = “laser”
                        ShootSingleBulletBetweenCoords(src.x, src.y, src.z, dst.x, dst.y, dst.z, 250, true, weapon, ped, true, false, 1000.0)
                    end

                    -- Disparo do feixe explosivo (explosão pequena)
                    local function fireExplosive(dst)
                        AddExplosion(dst.x, dst.y, dst.z, 2, 0.4, true, false, 1.0)
                    end

                    -- Olho Laser (sem arma atual - usa pistola fixa)
                    if not YGZ.sliders then YGZ.sliders = {} end
                    if not YGZ.sliders['LaserRange'] then YGZ.sliders['LaserRange'] = 100 end

                    YGZ:Slider('Alcance do Laser', 'LaserRange', { start = YGZ.sliders['LaserRange'], min = 50, max = 500 }, function(v)
                        YGZ.sliders['LaserRange'] = v
                    end, 'right')

                    YGZ:CheckBox('Olho Laser (Sem Arma)', 'LaserEyesNoWeapon', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles['LaserEyesNoWeapon'] do
                                    Wait(0)
                                    local playerPed = PlayerPedId()
                                    local boneIndex = GetPedBoneIndex(playerPed, 31086) -- osso do olho
                                    local eyePos = GetWorldPositionOfEntityBone(playerPed, boneIndex)

                                    local camCoords = GetGameplayCamCoord()
                                    local camRot = GetGameplayCamRot(2)

                                    local direction = (function(rotation)
                                        local z = math.rad(rotation.z)
                                        local x = math.rad(rotation.x)
                                        local num = math.abs(math.cos(x))
                                        return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
                                    end)(camRot)

                                    local range = tonumber(YGZ.sliders['LaserRange']) or 100.0
                                    local atirar = vector3(
                                        camCoords.x + direction.x * range,
                                        camCoords.y + direction.y * range,
                                        camCoords.z + direction.z * range
                                    )

                                    -- Desenha as linhas laser (duas para efeito)
                                    DrawLine(eyePos.x, eyePos.y, eyePos.z, atirar.x, atirar.y, atirar.z, 255, 0, 0, 255)
                                    DrawLine(eyePos.x, eyePos.y, eyePos.z - 0.02, atirar.x, atirar.y, atirar.z, 255, 0, 0, 255)

                                    -- Dispara com E (usa pistola fixa)
                                    if IsControlPressed(0, 38) then
                                        local weaponHash = GetHashKey("WEAPON_PISTOL") -- pistola fixa
                                        ShootSingleBulletBetweenCoords(
                                            eyePos.x, eyePos.y, eyePos.z,
                                            atirar.x, atirar.y, atirar.z,
                                            50, true, weaponHash, playerPed, true, false, 1000.0
                                        )
                                    end
                                end
                            end)
                        end
                    end, 'right')

                    -- Olho Explosivo (segurar E)
                    YGZ:CheckBox('Olho Explosivo (segurar E)', EXPLOSIVE_TOGGLE, function(state)
                        YGZ.toggles[EXPLOSIVE_TOGGLE] = state
                        if state then disableOther(EXPLOSIVE_TOGGLE) end
                        if state and not YGZ._explosiveEyeLoop then
                            YGZ._explosiveEyeLoop = true
                            Citizen.CreateThread(function()
                                local lastBoom = 0
                                while YGZ.toggles[EXPLOSIVE_TOGGLE] do
                                    -- só funciona enquanto segurar E
                                    if IsControlPressed(0, 38) then
                                        local ped = PlayerPedId()
                                        local src = getHeadPos(ped)
                                        local dir = camForwardVector()
                                        local hit, hitPos, _, hitEnt = raycastFrom(src, dir, 150.0, ped)
                                        local dst = hit and hitPos or (src + dir * 150.0)

                                        -- linha laranja
                                        drawBeam(src, dst, {255, 140, 0, 255})

                                        -- explosões cadenciadas
                                        local now = GetGameTimer()
                                        if now - lastBoom > 140 then
                                            fireExplosive(dst)
                                            applyNudge(hit and hitEnt or 0, src, dst)
                                            lastBoom = now
                                        end
                                    end
                                    Wait(0) -- para imediatamente ao soltar
                                end
                                YGZ._explosiveEyeLoop = nil
                            end)
                        end
                    end, 'right')
                    YGZ:CheckBox('Olho Molotov', 'OlhoMolotov', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles['OlhoMolotov'] do
                                        if IsControlPressed(1, 38) then
                                            local playerPed = PlayerPedId()
                                            local camRot = GetGameplayCamRot(2)
                                            local camCoord = GetGameplayCamCoord()
                                            local direction = vector3(
                                                -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                                                math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                                                math.sin(math.rad(camRot.x))
                                            )
                                            local endCoords = camCoord + (direction * 50.0)
                                            local weaponHash = GetHashKey("weapon_molotov")
                                            RequestWeaponAsset(weaponHash, true, true)
                                            while not HasWeaponAssetLoaded(weaponHash) do
                                                Wait(0)
                                            end
                                            ShootSingleBulletBetweenCoords(
                                                camCoord.x, camCoord.y, camCoord.z,
                                                endCoords.x, endCoords.y, endCoords.z,
                                                0,
                                                true,
                                                weaponHash,
                                                playerPed,
                                                true,
                                                false,
                                                -1.0,
                                                true
                                            )
                                        end
                                        Wait(0)
                                    end
                                end)
                            end
                        end)
                    end, 'right')
                elseif YGZ.subtabs.active == 'Roupa' then
                    YGZ:TitleBox('Roupa', 'Customização')
                    -- Sliders de roupas e aparência
                    YGZ:Slider('Chapéu', 'hat_variation', {value = 0, min = 0, max = 100}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedPropIndex(PlayerPedId(), 0, YGZ.sliders.hat_variation, 0, true)
                        end)
                    end)
                    YGZ:Slider('Óculos', 'glasses_variation', {value = 0, min = 0, max = 100}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedPropIndex(PlayerPedId(), 1, YGZ.sliders.glasses_variation, 0, true)
                        end)
                    end)
                    YGZ:Slider('Máscara', 'mask_variation', {value = 0, min = 0, max = 100}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedComponentVariation(PlayerPedId(), 1, YGZ.sliders.mask_variation, 0, 0)
                        end)
                    end)
                    YGZ:Slider('Camiseta', 'undershirt_variation', {value = 0, min = 0, max = 100}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedComponentVariation(PlayerPedId(), 8, YGZ.sliders.undershirt_variation, 0, 0)
                        end)
                    end)
                    YGZ:Slider('Calça', 'leg_variation', {value = 0, min = 0, max = 100}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedComponentVariation(PlayerPedId(), 4, YGZ.sliders.leg_variation, 0, 0)
                        end)
                    end)
                    YGZ:Slider('Sapato', 'shoes_variation', {value = 0, min = 0, max = 100}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedComponentVariation(PlayerPedId(), 6, YGZ.sliders.shoes_variation, 0, 0)
                        end)
                    end)
                    YGZ:Slider('Cabelo', 'hair_variation', {value = 0, min = 0, max = 73}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedComponentVariation(PlayerPedId(), 2, YGZ.sliders.hair_variation, 0, 0)
                        end)
                    end)
                    YGZ:Slider('Barba', 'beard_variation', {value = 0, min = 0, max = 28}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedHeadOverlay(PlayerPedId(), 1, YGZ.sliders.beard_variation, 1.0)
                        end)
                    end)
                    YGZ:Slider('Cor dos Olhos', 'eye_color', {value = 0, min = 0, max = 31}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedEyeColor(PlayerPedId(), YGZ.sliders.eye_color)
                        end)
                    end)
                    YGZ:Slider('Cor da Pele', 'skin_color', {value = 0, min = 0, max = 45}, function()
                        LPH_NO_VIRTUALIZE(function()
                            SetPedHeadBlendData(PlayerPedId(), YGZ.sliders.skin_color, YGZ.sliders.skin_color, 0, YGZ.sliders.skin_color, YGZ.sliders.skin_color, 0, 0.5, 0.5, 0.0, false)
                        end)
                    end)

                    -- Peds padrão (lado direito)
                    local function spawnped(model)
                        LPH_NO_VIRTUALIZE(function()
                            local hash = GetHashKey(model)
                            RequestModel(hash)
                            while not HasModelLoaded(hash) do Wait(0) end
                            SetPlayerModel(PlayerId(), hash)
                            SetModelAsNoLongerNeeded(hash)
                            SetPedDefaultComponentVariation(PlayerPedId())
                            ClearAllPedProps(PlayerPedId())
                        end)
                    end
                    YGZ:Button('Masculino Padrão', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('mp_m_freemode_01')
                        end)
                    end, 'right')
                    YGZ:Button('Feminino Padrão', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('mp_f_freemode_01')
                        end)
                    end, 'right')
                    YGZ:Button('Feminino Plus Size', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('a_f_m_fatcult_01')
                        end)
                    end, 'right')
                    YGZ:Button('Travesti', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('a_m_m_tranvest_01')
                        end)
                    end, 'right')

                    -- Peds customizados (lado direito)
                    YGZ:Button('Chucky', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('chucky')
                        end)
                    end, 'right')
                    YGZ:Button('Crocodilo', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('crocodilo')
                        end)
                    end, 'right')
                    YGZ:Button('Lobo', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('LoboSirius')
                        end)
                    end, 'right')
                    YGZ:Button('Zumbi', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('zombie_argonix')
                        end)
                    end, 'right')
                    YGZ:Button('Gato', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('sphynx')
                        end)
                    end, 'right')
                    YGZ:Button('T-Rex', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('trex')
                        end)
                    end, 'right')
                    YGZ:Button('Mickey', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('mickey')
                        end)
                    end, 'right')
                    YGZ:Button('Neymar', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('Neymar')
                        end)
                    end, 'right')
                    YGZ:Button('Anao muie', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('a_f_m_fatcult_01')
                        end)
                    end, 'right')
                    YGZ:Button('Amarelao', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('a_m_m_mexcntry_01')
                        end)
                    end, 'right')
                    YGZ:Button('Anao', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('a_m_m_mexcntry_01')
                        end)
                    end, 'right')
                    YGZ:Button('Anao Ben10', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('a_m_m_mexcntry_01')
                        end)
                    end, 'right')
                    YGZ:Button('Special5', function()
                        LPH_NO_VIRTUALIZE(function()
                            spawnped('a_m_m_mexcntry_01')
                        end)
                    end, 'right')
                elseif YGZ.subtabs.active == 'Teleportes' then
                    YGZ:TitleBox('Teleportes', 'Locais')
                    -- Teleportar para Waypoint
                    YGZ:Button('Teleportar para Waypoint', function()
                        LPH_NO_VIRTUALIZE(function()
                            local ped = PlayerPedId()
                            local waypointBlip = GetFirstBlipInfoId(8)
                            if DoesBlipExist(waypointBlip) then
                                local x, y, z = table.unpack(GetBlipCoords(waypointBlip))
                                -- Encontrar o solo
                                for height = 1, 1000 do
                                    SetEntityCoordsNoOffset(ped, x, y, height + 0.0, false, false, false)
                                    local foundGround, groundZ = GetGroundZFor_3dCoord(x, y, height + 0.0, true)
                                    if foundGround then
                                        SetEntityCoordsNoOffset(ped, x, y, groundZ + 1.0, false, false, false)
                                        break
                                    end
                                    Wait(5)
                                end
                            end
                        end)
                    end)
                    -- Teleportar para o veículo mais próximo
                    YGZ:Button('Teleportar para a Praça', function()
                        LPH_NO_VIRTUALIZE(function()
                            SetEntityCoords(PlayerPedId(), 165.2, -988.2, 30.1)
                        end)
                    end)
                    YGZ:Button('Teleportar para a Prisão', function()
                        LPH_NO_VIRTUALIZE(function()
                            SetEntityCoords(PlayerPedId(), 1851.6, 2585.3, 45.6)
                        end)
                    end)
                    YGZ:Button('Teleportar para o Aeroporto', function()
                        LPH_NO_VIRTUALIZE(function()
                            SetEntityCoords(PlayerPedId(), -1034.9, -2732.9, 20.1)
                        end)
                    end)
                end
            elseif YGZ.tabs.active == 'Armas' then
                YGZ:SubTab('Armas')
                YGZ:SubTab('Aimbot')

                if YGZ.subtabs.active == 'Armas' then
                    YGZ:TitleBox('Armas', 'Gerenciar')
                    -- Spawnar todas as armas principais
                    YGZ:Button('Spawnar Todas as Armas', function()
                        LPH_NO_VIRTUALIZE(function()
                            local armas = {
                                'WEAPON_PISTOL', 'WEAPON_COMBATPISTOL', 'WEAPON_APPISTOL',
                                'WEAPON_MICROSMG', 'WEAPON_SMG', 'WEAPON_ASSAULTRIFLE',
                                'WEAPON_CARBINERIFLE', 'WEAPON_PUMPSHOTGUN', 'WEAPON_SNIPERRIFLE',
                                'WEAPON_MG', 'WEAPON_COMBATMG', 'WEAPON_GRENADE', 'WEAPON_MOLOTOV'
                            }
                            for _, arma in ipairs(armas) do
                                GiveWeaponToPed(PlayerPedId(), GetHashKey(arma), 250, false, true)
                            end
                        end)
                    end)
                    -- Remover arma atual
                    YGZ:Button('Remover Arma Atual', function()
                        LPH_NO_VIRTUALIZE(function()
                            local ped = PlayerPedId()
                            local currentWeapon = GetSelectedPedWeapon(ped)
                            if currentWeapon and currentWeapon ~= GetHashKey('WEAPON_UNARMED') then
                                RemoveWeaponFromPed(ped, currentWeapon)
                            end
                        end)
                    end)
                    -- Remover todas as armas
                    YGZ:Button('Remover Todas as Armas', function()
                        LPH_NO_VIRTUALIZE(function()
                            RemoveAllPedWeapons(PlayerPedId(), true)
                        end)
                    end)
                    -- Slider para modificar munição da arma atual
                    YGZ:Slider('Munição', 'ammo_slider', {value = 250, min = 0, max = 999}, function()
                        LPH_NO_VIRTUALIZE(function()
                            local ped = PlayerPedId()
                            local currentWeapon = GetSelectedPedWeapon(ped)
                            if currentWeapon and currentWeapon ~= GetHashKey('WEAPON_UNARMED') then
                                SetPedAmmo(ped, currentWeapon, YGZ.sliders.ammo_slider)
                            end
                        end)
                    end)

                    -- Groupbox da direita para Gerenciar armas
                    local armas = {
                        {nome = 'Pistola', hash = 'WEAPON_PISTOL'},
                        {nome = 'Pistola de Combate', hash = 'WEAPON_COMBATPISTOL'},
                        {nome = 'SMG', hash = 'WEAPON_SMG'},
                        {nome = 'Micro SMG', hash = 'WEAPON_MICROSMG'},
                        {nome = 'Rifle de Assalto', hash = 'WEAPON_ASSAULTRIFLE'},
                        {nome = 'Carabina', hash = 'WEAPON_CARBINERIFLE'},
                        {nome = 'Escopeta', hash = 'WEAPON_PUMPSHOTGUN'},
                        {nome = 'Sniper', hash = 'WEAPON_SNIPERRIFLE'},
                        {nome = 'Metralhadora', hash = 'WEAPON_MG'},
                        {nome = 'Metralhadora de Combate', hash = 'WEAPON_COMBATMG'},
                        {nome = 'Granada', hash = 'WEAPON_GRENADE'},
                        {nome = 'Molotov', hash = 'WEAPON_MOLOTOV'}
                    }
                    for _, arma in ipairs(armas) do
                        YGZ:Button(arma.nome, function()
                            LPH_NO_VIRTUALIZE(function()
                                GiveWeaponToPed(PlayerPedId(), GetHashKey(arma.hash), 250, false, true)
                            end)
                        end, 'right')
                    end
                    -- Adicionar RPG e Arma Laser na lista de armas da direita
                    YGZ:Button('RPG', function()
                        LPH_NO_VIRTUALIZE(function()
                            GiveWeaponToPed(PlayerPedId(), GetHashKey('WEAPON_RPG'), 10, false, true)
                        end)
                    end, 'right')
                    YGZ:Button('Minigun Laser', function()
                        LPH_NO_VIRTUALIZE(function()
                            GiveWeaponToPed(PlayerPedId(), GetHashKey('WEAPON_RAYMINIGUN'), 250, false, true)
                        end)
                    end, 'right')

                elseif YGZ.subtabs.active == 'Aimbot' then
                    YGZ:TitleBox('Aimbot', 'Outros')

                    if YGZ.tabs.active == 'Armas' and YGZ.subtabs.active == 'Aimbot' then

                        -- Munição Infinita
                        YGZ:CheckBox('Munição Infinita', 'MunicaoInfinita', function(state)
                            local ped = PlayerPedId()
                            local weapon = GetSelectedPedWeapon(ped)
                            if state then
                                SetPedInfiniteAmmo(ped, true, weapon)
                                SetPedInfiniteAmmoClip(ped, true)
                            else
                                SetPedInfiniteAmmo(ped, false, weapon)
                                SetPedInfiniteAmmoClip(ped, false)
                            end
                        end, 'right')

                        -- Não Recarregar
                        YGZ:CheckBox('Não Recarregar', 'NoReload', function(state)
                            if state then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.NoReload do
                                        local ped = PlayerPedId()
                                        PedSkipNextReloading(ped)
                                        Wait(0)
                                    end
                                end)
                            end
                        end, 'right')

                        -- Atirar Rápido
                        YGZ:CheckBox('Atirar Rápido', 'AtirarRapido', function(state)
                            if state then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.AtirarRapido do
                                        Wait(0)
                                        if IsDisabledControlPressed(0, 24) then
                                            local ped = PlayerPedId()
                                            local weapon = GetSelectedPedWeapon(ped)
                                            local weaponEntity = GetCurrentPedWeaponEntityIndex(ped)
                                            if DoesEntityExist(weaponEntity) then
                                                local launchPos = GetEntityCoords(weaponEntity)
                                                local aimPos = GetGameplayCamCoord()
                                                local direction = vector3(
                                                    math.sin(math.rad(-GetGameplayCamRot(2).z)),
                                                    math.cos(math.rad(-GetGameplayCamRot(2).z)),
                                                    math.sin(math.rad(GetGameplayCamRot(2).x))
                                                )
                                                local targetPos = aimPos + (direction * 200.0)
                                                ShootSingleBulletBetweenCoords(
                                                    launchPos.x, launchPos.y, launchPos.z,
                                                    targetPos.x, targetPos.y, targetPos.z,
                                                    1, true, weapon, ped, true, false, 1000.0
                                                )
                                            end
                                        end
                                    end
                                end)
                            end
                        end, 'right')

                        -- No Recoil
                        YGZ:CheckBox('No Recoil', 'NoRecoil', function(state)
                            if state then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.NoRecoil do
                                        local weapon = GetSelectedPedWeapon(PlayerPedId())
                                        SetWeaponRecoilShakeAmplitude(weapon, 0.000001)
                                        Wait(0)
                                    end
                                end)
                            else
                                local weapon = GetSelectedPedWeapon(PlayerPedId())
                                SetWeaponRecoilShakeAmplitude(weapon, 1.0)
                            end
                        end, 'right')

                        -- Tiro Explosivo
                        YGZ:CheckBox('Tiro Explosivo', 'TiroExplosivo', function(state)
                            if state then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.TiroExplosivo do
                                        local ped = PlayerPedId()
                                        if IsPedShooting(ped) then
                                            local coords = GetPedBoneCoords(ped, 57005, 0, 0, 0)
                                            local camRot = GetGameplayCamRot(2)
                                            local direction = vector3(
                                                -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                                                math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                                                math.sin(math.rad(camRot.x))
                                            )
                                            local destination = coords + (direction * 1000.0)
                                            local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
                                                coords.x, coords.y, coords.z,
                                                destination.x, destination.y, destination.z,
                                                1, ped, 4
                                            )
                                            local retval, hit, endCoords = GetShapeTestResult(rayHandle)
                                            if hit == 1 then
                                                AddOwnedExplosion(
                                                    ped,
                                                    endCoords.x, endCoords.y, endCoords.z,
                                                    4, 100.0, true, false, false
                                                )
                                            end
                                        end
                                        Wait(0)
                                    end
                                end)
                            end
                        end, 'right')
                    end

                    local AB_ENABLE, AB_FOV, AB_SMOOTH = 'aimbot_enabled', 'aimbot_fov', 'aimbot_smooth'
                    local AB_SILENT, AB_SILENTF = 'silent_aim', 'silent_fov'
                    if YGZ.toggles[AB_ENABLE]==nil then YGZ.toggles[AB_ENABLE]=false end
                    if YGZ.sliders[AB_FOV]==nil then YGZ.sliders[AB_FOV]=30 end
                    if YGZ.sliders[AB_SMOOTH]==nil then YGZ.sliders[AB_SMOOTH]=5 end
                    if YGZ.toggles[AB_SILENT]==nil then YGZ.toggles[AB_SILENT]=false end
                    if YGZ.sliders[AB_SILENTF]==nil then YGZ.sliders[AB_SILENTF]=10 end

                    local function ab_head(p) return GetPedBoneCoords(p, 31086, 0.0,0.0,0.0) end
                    local function ab_angleTo(pos)
                        local camPos = GetGameplayCamCoord(); local camRot = GetGameplayCamRot(2)
                        local dir = vector3(-math.sin(math.rad(camRot.z))*math.cos(math.rad(camRot.x)), math.cos(math.rad(camRot.z))*math.cos(math.rad(camRot.x)), math.sin(math.rad(camRot.x)))
                        local to = pos-camPos; local dot=(dir.x*to.x+dir.y*to.y+dir.z*to.z)/(#dir*#to)
                        return math.deg(math.acos(math.max(-1.0, math.min(1.0, dot))))
                    end
                    local function ab_find(maxFov)
                        local me=PlayerPedId(); local best,bAng=nil,maxFov
                        for _,id in ipairs(GetActivePlayers()) do
                            if id~=PlayerId() then
                                local p=GetPlayerPed(id)
                                if DoesEntityExist(p) and not IsPedDeadOrDying(p) and HasEntityClearLosToEntity(me,p,17) then
                                    local ang=ab_angleTo(ab_head(p)); if ang<=bAng then bAng=ang; best=p end
                                end
                            end
                        end; return best
                    end
                    local function ab_aimAt(pos,smooth)
                        local camPos=GetGameplayCamCoord(); local camRot=GetGameplayCamRot(2)
                        local dx,dy,dz=pos.x-camPos.x,pos.y-camPos.y,pos.z-camPos.z
                        local distXY=math.sqrt(dx*dx+dy*dy)
                        local dp=-math.deg(math.atan2(dz,distXY)) local dh=math.deg(math.atan2(dy,dx))
                        local dH=(dh-camRot.z+540.0)%360.0-180.0 local dP=(dp-camRot.x)
                        local step=math.max(1.0, smooth or 5.0)
                        SetGameplayCamRelativeHeading(camRot.z + dH/step)
                        SetGameplayCamRelativePitch(camRot.x + dP/step, 1.0)
                    end
                    local function ab_drawFovCircle(fov,color)
                        color=color or {255,0,0,120}; local ped=PlayerPedId(); local pos=GetEntityCoords(ped)
                        DrawMarker(28,pos.x,pos.y,pos.z+0.8,0.0,0.0,0.0,0.0,0.0,0.0,fov/2.0,fov/2.0,0.01,color[1],color[2],color[3],color[4],false,false,2,false,nil,nil,false)
                    end

                    YGZ:CheckBox('Ativar Aimbot', AB_ENABLE, function(s) YGZ.toggles[AB_ENABLE]=s end)
                    YGZ:Slider('Aimbot FOV', AB_FOV, {min=5,max=100,value=YGZ.sliders[AB_FOV]}, function(v) YGZ.sliders[AB_FOV]=v end)
                    YGZ:Slider('Aimbot Smooth', AB_SMOOTH, {min=1,max=20,value=YGZ.sliders[AB_SMOOTH]}, function(v) YGZ.sliders[AB_SMOOTH]=v end)
                    YGZ:CheckBox('Silent Aim', AB_SILENT, function(s) YGZ.toggles[AB_SILENT]=s end)
                    YGZ:Slider('Silent FOV', AB_SILENTF, {min=5,max=50,value=YGZ.sliders[AB_SILENTF]}, function(v) YGZ.sliders[AB_SILENTF]=v end)

                    if not YGZ._aimbotLoop then
                        YGZ._aimbotLoop=true
                        Citizen.CreateThread(function()
                            while true do
                                if YGZ.toggles[AB_ENABLE] then
                                    local t=ab_find(YGZ.sliders[AB_FOV] or 30)
                                    if t then ab_drawFovCircle(YGZ.sliders[AB_FOV] or 30); ab_aimAt(ab_head(t), YGZ.sliders[AB_SMOOTH] or 5) end
                                end
                                Wait(0)
                            end
                        end)
                    end

                    if not YGZ._silentAimLoop then
                        YGZ._silentAimLoop=true
                        Citizen.CreateThread(function()
                            while true do
                                if YGZ.toggles[AB_SILENT] and IsDisabledControlPressed(0,24) then
                                    local ped=PlayerPedId(); local weapon=GetSelectedPedWeapon(ped)
                                    if weapon and weapon~=GetHashKey('WEAPON_UNARMED') then
                                        local t=ab_find(YGZ.sliders[AB_SILENTF] or 10)
                                        if t then
                                            local src=GetPedBoneCoords(ped,0x6F06,0.0,0.0,0.0) -- mão direita
                                            local dst=ab_head(t)
                                            ShootSingleBulletBetweenCoords(src.x,src.y,src.z,dst.x,dst.y,dst.z,0,true,weapon,ped,true,false,2000.0)
                                        end
                                    end
                                end
                                Wait(0)
                            end
                        end)
                    end

                end
            elseif YGZ.tabs.active == 'Veículos' then
                YGZ:SubTab('Veículo')
                YGZ:SubTab('Tunagem')
                YGZ:SubTab('Radar')

                if YGZ.subtabs.active == 'Veículo' then
                    YGZ:TitleBox('Spawn de Veiculos', 'Outros')

                    -- Spawn de Veiculos (Coluna Esquerda)
                    YGZ:Button("Nome do Carro", function()
                        LPH_NO_VIRTUALIZE(function()
                            local current_value = YGZ.inputs["carName"] or ""
                            local val = KeyboardInput("Nome do Carro", current_value, 50)
                            if val ~= nil then
                                YGZ.inputs["carName"] = val
                            end
                        end)
                    end)
                    -- Display current input value
                    if YGZ.inputs and YGZ.inputs["carName"] then
                        YGZ:DrawText('Valor: ' .. YGZ.inputs["carName"], YGZ.x + YGZ.buttons.x1 + 35, YGZ.y + YGZ.buttons.y1 - 30, 200, 200, false, {255, 255, 255, 150})
                    end
                    YGZ.buttons.y1 = YGZ.buttons.y1 + 20 -- Adjust space for displayed value

                    YGZ:Button("Spawnar Carro", function()
                        LPH_NO_VIRTUALIZE(function()
                            local carName = YGZ.inputs["carName"] or ""
                            if carName ~= "" then
                                local carHash = GetHashKey(carName)
                                if not HasModelLoaded(carHash) then
                                    RequestModel(carHash)
                                    while not HasModelLoaded(carHash) do
                                        Wait(0)
                                    end
                                end
                                local ped = PlayerPedId()
                                local pos = GetEntityCoords(ped)
                                local head = GetEntityHeading(ped)
                                local vehicle = CreateVehicle(carHash, pos.x + 2.0, pos.y, pos.z, head, true, false)
                                if DoesEntityExist(vehicle) then
                                    SetEntityAsMissionEntity(vehicle, true, true)
                                    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
                                    -- Aplicar modo SAFE caso toggle ativo
                                    if YGZ.toggles and YGZ.toggles.spawnSafeCar then
                                        SetVehicleOnGroundProperly(vehicle)
                                        SetVehicleDoorsLocked(vehicle, 1)
                                        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                                        SetVehicleTyresCanBurst(vehicle, false)
                                    end
                                    -- Aplicar mods caso toggle ativo
                                    if YGZ.toggles and YGZ.toggles.spawnModifiedCar then
                                        SetVehicleModKit(vehicle, 0)
                                        for i = 0, 48 do
                                            if GetNumVehicleMods(vehicle, i) > 0 then
                                                SetVehicleMod(vehicle, i, GetNumVehicleMods(vehicle, i) - 1, false)
                                            end
                                        end
                                        for i = 18, 22 do
                                            ToggleVehicleMod(vehicle, i, true)
                                        end
                                        SetVehicleWindowTint(vehicle, 1)
                                        SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
                                        SetVehicleCustomSecondaryColour(vehicle, 0, 0, 0)
                                    end
                                    -- Entrar no carro se preferir
                                    if YGZ.toggles and YGZ.toggles.spawnInCar then
                                        SetPedIntoVehicle(ped, vehicle, -1)
                                    end
                                    SetModelAsNoLongerNeeded(carHash)
                                end
                            else
                                YGZ:notify("Nome do carro inválido.", "erro")
                            end
                        end)
                    end)
                    YGZ:Button("Spawnar Carro Safe", function()
                        LPH_NO_VIRTUALIZE(function()
                            local carName = YGZ.inputs["carName"] or ""
                            if carName ~= "" then
                                Citizen.CreateThread(function()
                                    local carHash = GetHashKey(carName)
                                    if IsModelInCdimage(carHash) and IsModelAVehicle(carHash) then
                                        RequestModel(carHash)
                                        while not HasModelLoaded(carHash) do
                                            Wait(0)
                                        end
                                        local ped = PlayerPedId()
                                        local pos = GetEntityCoords(ped)
                                        local head = GetEntityHeading(ped)
                                        local vehicle = CreateVehicle(carHash, pos.x + 2, pos.y, pos.z, head, false, false)
                                        if DoesEntityExist(vehicle) then
                                            SetPedIntoVehicle(ped, vehicle, -1)
                                            SetEntityAsMissionEntity(vehicle, true, true)
                                            SetVehicleHasBeenOwnedByPlayer(vehicle, true)
                                            SetModelAsNoLongerNeeded(carHash)
                                        end
                                    end
                                end)
                            end
                        end)
                    end)

                    -- Checkboxes de Spawn de Veiculos (Coluna Direita)
                    YGZ:CheckBox("Spawnar Dentro do Carro", "spawnInCar", function(state)
                        LPH_NO_VIRTUALIZE(function()
                            local playerPed = PlayerPedId()
                            local vehicle = GetVehiclePedIsUsing(playerPed, false)
                            if vehicle ~= 0 and state then
                                SetPedIntoVehicle(playerPed, vehicle, -1)
                            end
                        end)
                    end, 'right')
                    YGZ:CheckBox("Spawnar Modificado", "spawnModifiedCar", function(state)
                        LPH_NO_VIRTUALIZE(function()
                            YGZ.toggles.spawnModifiedCar = state
                            YGZ:notify('Spawn Modificado: '..(state and 'ON' or 'OFF'), 'info')
                        end)
                    end, 'right')
                    YGZ:CheckBox("Spawn de carro safe", "spawnSafeCar", function(state)
                        LPH_NO_VIRTUALIZE(function()
                            YGZ.toggles.spawnSafeCar = state
                            YGZ:notify('Spawn Safe: '..(state and 'ON' or 'OFF'), 'info')
                        end)
                    end, 'right')

                    -- Veiculos Presetados (Coluna Esquerda)
                    YGZ:Button("Spawnar T20", function()
                        LPH_NO_VIRTUALIZE(function()
                            local carHash = GetHashKey('t20')
                            if not HasModelLoaded(carHash) then
                                RequestModel(carHash)
                                while not HasModelLoaded(carHash) do
                                    Wait(100)
                                end
                            end
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local vehicle = CreateVehicle(carHash, coords.x, coords.y, coords.z, 0.0, true, true)
                            SetPedIntoVehicle(playerPed, vehicle, -1)
                        end)
                    end)
                    YGZ:Button("Spawnar Kuruma", function()
                        LPH_NO_VIRTUALIZE(function()
                            local carHash = GetHashKey('kuruma')
                            if not HasModelLoaded(carHash) then
                                RequestModel(carHash)
                                while not HasModelLoaded(carHash) do
                                    Wait(100)
                                end
                            end
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local vehicle = CreateVehicle(carHash, coords.x, coords.y, coords.z, 0.0, true, true)
                            SetPedIntoVehicle(playerPed, vehicle, -1)
                        end)
                    end)
                    YGZ:Button('Spawnar Moto (Bati 801)', function()
                        Citizen.CreateThread(function()
                            local ped = PlayerPedId()
                            local model = GetHashKey('bati')
                            RequestModel(model)
                            while not HasModelLoaded(model) do
                                Wait(0)
                            end
                    
                            local coords = GetEntityCoords(ped)
                            local forward = GetEntityForwardVector(ped)
                            local heading = GetEntityHeading(ped)
                            local x = coords.x + forward.x * 3.0
                            local y = coords.y + forward.y * 3.0
                            local z = coords.z
                    
                            local veh = CreateVehicle(model, x, y, z, heading, true, false)
                            SetEntityAsMissionEntity(veh, true, true)
                            SetVehicleOnGroundProperly(veh)
                            SetVehicleNumberPlateText(veh, 'YGZ')
                            TaskWarpPedIntoVehicle(ped, veh, -1)
                    
                            SetModelAsNoLongerNeeded(model)
                        end)
                    end)
                    YGZ:Button("Spawnar Elegy", function()
                        LPH_NO_VIRTUALIZE(function()
                            local carHash = GetHashKey('elegy')
                            if not HasModelLoaded(carHash) then
                                RequestModel(carHash)
                                while not HasModelLoaded(carHash) do
                                    Wait(100)
                                end
                            end
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local vehicle = CreateVehicle(carHash, coords.x, coords.y, coords.z, 0.0, true, true)
                            SetPedIntoVehicle(playerPed, vehicle, -1)
                        end)
                    end)
                    YGZ:Button("Spawnar SultanI", function()
                        LPH_NO_VIRTUALIZE(function()
                            local carHash = GetHashKey('sultan')
                            if not HasModelLoaded(carHash) then
                                RequestModel(carHash)
                                while not HasModelLoaded(carHash) do
                                    Wait(100)
                                end
                            end
                            local playerPed = PlayerPedId()
                            local coords = GetEntityCoords(playerPed)
                            local vehicle = CreateVehicle(carHash, coords.x, coords.y, coords.z, 0.0, true, true)
                            SetPedIntoVehicle(playerPed, vehicle, -1)
                        end)
                    end)

                    -- Seu Veiculo (Coluna Esquerda)
                    YGZ:Button('Full Tune (Tunar Tudo)', function()
                        LPH_NO_VIRTUALIZE(function()
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                SetVehicleModKit(vehicle, 0)
                                SetVehicleWheelType(vehicle, 7) -- Set wheel type to custom/sport for more mods

                                -- Apply all available mods
                                for i = 0, 48 do -- Iterate through common mod types
                                    if GetNumVehicleMods(vehicle, i) > 0 then
                                        SetVehicleMod(vehicle, i, GetNumVehicleMods(vehicle, i) - 1, false)
                                    end
                                end

                                -- Specific toggles and other visual mods
                                ToggleVehicleMod(vehicle, 18, true) -- Turbo
                                ToggleVehicleMod(vehicle, 20, true) -- Xenon Lights (example, adjust if needed)
                                SetVehicleTyresCanBurst(vehicle, false) -- Bulletproof tires
                                SetVehicleWindowTint(vehicle, 1) -- Darkest tint (adjust as needed)

                                -- Repair vehicle after tuning
                                SetVehicleDeformationFixed(vehicle)
                                SetVehicleFixed(vehicle)
                                SetVehicleBodyHealth(vehicle, 1000.0)
                                SetVehicleEngineHealth(vehicle, 1000.0)
                                SetVehiclePetrolTankHealth(vehicle, 1000.0)
                                SetVehicleUndriveable(vehicle, false)
                                SetVehicleOnGroundProperly(vehicle)

                                YGZ:notify("Veículo tunado ao máximo e reparado!", "sucesso")
                            else
                                YGZ:notify("Você precisa estar em um veículo para tunar!", "erro")
                            end
                        end)
                    end)

                    local SUPER_SOCO = 'super_soco_veh'

                    YGZ:CheckBox('Super Soco (Veículo)', SUPER_SOCO, function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles[SUPER_SOCO] do
                                    --  Punch controles default:  Punch = 140/141/142 (melee attack light/heavy/alt) dependendo do bind
                                    if IsControlJustPressed(0, 142) or IsControlJustPressed(0, 141) or IsControlJustPressed(0, 140) then
                                        local ped = PlayerPedId()
                                        local pos = GetEntityCoords(ped)
                                        local veh = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 70)
                                        if veh ~= 0 and DoesEntityExist(veh) then
                                            NetworkRequestControlOfEntity(veh)
                                            local camRot = GetGameplayCamRot(2)
                                            local dir = vector3(
                                                -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                                                math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                                                math.sin(math.rad(camRot.x))
                                            )
                                            local force = 200.0 -- ajuste de força do soco no veículo
                                            ApplyForceToEntity(veh, 3, dir.x * force, dir.y * force, math.max(0.0, dir.z) * (force * 0.5), 0.0, 0.0, 0.0, false, false, true, true, false, true)
                                            if YGZ.notify then YGZ:notify('Soco no carro!', 'sucesso') end
                                        end
                                    end
                                    Wait(0)
                                end
                            end)
                        end
                    end)
                    -- Destrancar veículos próximos
                    YGZ:CheckBox('Destrancar Veículos Próximos', 'DestrancarVeiculos', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles.DestrancarVeiculos do
                                    local ped = PlayerPedId()
                                    local veh = GetVehiclePedIsIn(ped, false)
                                    if veh == 0 then veh = GetClosestVehicle(GetEntityCoords(ped), 8.0, 0, 70) end
                                    if DoesEntityExist(veh) then
                                        SetVehicleDoorsLocked(veh, 1)
                                        SetVehicleDoorsLockedForAllPlayers(veh, false)
                                    end
                                    Wait(100)
                                end
                            end)
                        end
                    end)

                    -- Trancar veículos próximos
                    YGZ:CheckBox('Trancar Veículos Próximos', 'TrancarVeiculos', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles.TrancarVeiculos do
                                    local ped = PlayerPedId()
                                    local veh = GetVehiclePedIsIn(ped, false)
                                    if veh == 0 then veh = GetClosestVehicle(GetEntityCoords(ped), 8.0, 0, 70) end
                                    if DoesEntityExist(veh) then
                                        SetVehicleDoorsLocked(veh, 2)
                                        SetVehicleDoorsLockedForAllPlayers(veh, true)
                                    end
                                    Wait(100)
                                end
                            end)
                        end
                    end)
                    -- Vehicles Ocean: teleporta APENAS o veículo (nunca o player junto)
                    local OCEAN_TOGGLE = 'vehicles_ocean'

                    YGZ:CheckBox('Vehicles Ocean', OCEAN_TOGGLE, function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles[OCEAN_TOGGLE] do
                                    local ped = PlayerPedId()
                                    if IsPedInAnyVehicle(ped, false) then
                                        local veh = GetVehiclePedIsIn(ped, false)
                                        if veh ~= 0 and DoesEntityExist(veh) then
                                            -- Salva posição do player e tira ele do veículo
                                            local px,py,pz = table.unpack(GetEntityCoords(ped))
                                            TaskLeaveVehicle(ped, veh, 16) -- sair imediatamente
                                            local t0 = GetGameTimer()
                                            while IsPedInAnyVehicle(ped, false) and GetGameTimer() - t0 < 800 do
                                                Wait(0)
                                            end
                                            if IsPedInAnyVehicle(ped, false) then
                                                -- força caso não tenha saído
                                                ClearPedTasksImmediately(ped)
                                                SetEntityCoords(ped, px, py, pz, false, false, false, false)
                                            end

                                            -- Garante controle do veículo e teleporta SÓ ele
                                            NetworkRequestControlOfEntity(veh)
                                            local t1 = GetGameTimer()
                                            while not NetworkHasControlOfEntity(veh) and GetGameTimer() - t1 < 600 do
                                                NetworkRequestControlOfEntity(veh)
                                                Wait(0)
                                            end
                                            SetEntityAsMissionEntity(veh, true, true)

                                            -- Coordenadas no oceano (ajuste se quiser)
                                            SetEntityCoords(veh, 3203.767, -4039.129, 201.3459, false, false, false, false)

                                            -- Garante que o player permaneça onde estava
                                            SetEntityCoords(ped, px, py, pz, false, false, false, false)
                                        end
                                    end
                                    Wait(0)
                                end
                            end)
                        end
                    end)
                    YGZ:Button("Reparar Veiculo", function()
                        LPH_NO_VIRTUALIZE(function()
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle == 0 then
                                vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 8.0, 0, 70)
                            end
                            if DoesEntityExist(vehicle) then
                                SetVehicleDeformationFixed(vehicle)
                                SetVehicleFixed(vehicle)
                                SetVehicleBodyHealth(vehicle, 1000.0)
                                SetVehicleEngineHealth(vehicle, 1000.0)
                                SetVehiclePetrolTankHealth(vehicle, 1000.0)
                                SetVehicleUndriveable(vehicle, false)
                                SetVehicleOnGroundProperly(vehicle)
                            end
                        end)
                    end)
                    YGZ:Button("Reparar Motor", function()
                        LPH_NO_VIRTUALIZE(function()
                            local veiculo = GetVehiclePedIsIn(PlayerPedId(), false)
                            if DoesEntityExist(veiculo) then
                                SetVehicleEngineHealth(veiculo, 1000.0)
                                SetEntityHealth(veiculo, 1000.0)
                            else
                                YGZ:notify("Entre em um veículo primeiro!", "erro")
                            end
                        end)
                    end)

                    -- Checkboxes de Seu Veiculo (Coluna Direita)
                    YGZ:CheckBox("Modo Tesla", "piloto_automatico", function(v)
                        LPH_NO_VIRTUALIZE(function()
                            if v then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles["piloto_automatico"] do
                                        local ped = PlayerPedId()
                                        if IsPedInAnyVehicle(ped, false) then
                                            local veiculo = GetVehiclePedIsIn(ped, false)
                                            if DoesBlipExist(GetFirstBlipInfoId(8)) then -- Waypoint blip ID is 8
                                                local blip = GetFirstBlipInfoId(8)
                                                local wp = GetBlipInfoIdCoord(blip)
                                                TaskVehicleDriveToCoord(ped, veiculo, wp.x, wp.y, wp.z, 50.0, 156, veiculo, 2883621, 5.5, true)
                                                SetDriveTaskDrivingStyle(ped, 2883621)
                                            else
                                                YGZ:notify("Defina um destino no mapa primeiro!", "erro")
                                                break
                                            end
                                        else
                                            YGZ:notify("Entre em um veiculo primeiro!", "erro")
                                            break
                                        end
                                        Wait(1000)
                                    end
                                    local ped = PlayerPedId()
                                    if IsPedInAnyVehicle(ped) then
                                        ClearPedTasks(ped)
                                    end
                                end)
                            else
                                -- No specific action for toggling off other than clearing tasks, which is done in the thread's end.
                            end
                        end)
                    end, 'right')
                    YGZ:Button("Deletar Veículo", function()
                        LPH_NO_VIRTUALIZE(function()
                            local ped = PlayerPedId()
                            local vehicle = GetVehiclePedIsIn(ped, false)
                            
                            -- Se não estiver em veículo, procurar o mais próximo
                            if vehicle == 0 then
                                vehicle = GetClosestVehicle(GetEntityCoords(ped), 8.0, 0, 70)
                            end
                            
                            if DoesEntityExist(vehicle) then
                                -- Verificar se há jogadores no veículo e removê-los
                                local pedP1 = GetPedInVehicleSeat(vehicle, -1)
                                local pedP2 = GetPedInVehicleSeat(vehicle, 0)
                                local pedP3 = GetPedInVehicleSeat(vehicle, 1)
                                local pedP4 = GetPedInVehicleSeat(vehicle, 2)
                                
                                -- Remover todos os passageiros
                                if pedP1 and pedP1 ~= 0 then
                                    TaskLeaveVehicle(pedP1, vehicle, 16)
                                    Wait(100)
                                end
                                if pedP2 and pedP2 ~= 0 then
                                    TaskLeaveVehicle(pedP2, vehicle, 16)
                                    Wait(100)
                                end
                                if pedP3 and pedP3 ~= 0 then
                                    TaskLeaveVehicle(pedP3, vehicle, 16)
                                    Wait(100)
                                end
                                if pedP4 and pedP4 ~= 0 then
                                    TaskLeaveVehicle(pedP4, vehicle, 16)
                                    Wait(100)
                                end
                                
                                -- Solicitar controle do veículo
                                NetworkRequestControlOfEntity(vehicle)
                                local tries = 0
                                while not NetworkHasControlOfEntity(vehicle) and tries < 50 do
                                    NetworkRequestControlOfEntity(vehicle)
                                    tries = tries + 1
                                    Wait(100)
                                end
                                
                                if NetworkHasControlOfEntity(vehicle) then
                                    -- Definir como entidade de missão
                                    SetEntityAsMissionEntity(vehicle, true, true)
                                    
                                    -- Deletar o veículo
                                    DeleteVehicle(vehicle)
                                    DeleteEntity(vehicle)
                                    
                                    YGZ:notify("Veículo deletado com sucesso!", "sucesso")
                                else
                                    YGZ:notify("Não foi possível controlar o veículo!", "erro")
                                end
                            else
                                YGZ:notify("Nenhum veículo encontrado próximo!", "erro")
                            end
                        end)
                    end)
                    -- Habilitar Chute na Moto
                    YGZ:CheckBox('Habilitar Chute na Moto', 'ChuteMoto', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles['ChuteMoto'] do
                                    SetPlayerCanDoDriveBy(PlayerId(), true)
                                    EnableControlAction(0, 140, true)
                                    EnableControlAction(0, 141, true)
                                    EnableControlAction(0, 142, true)
                                    EnableControlAction(0, 158, true)
                                    EnableControlAction(0, 263, true)
                                    EnableControlAction(0, 264, true)
                                    EnableControlAction(0, 345, true)
                                    Wait(0)
                                end
                                SetPlayerCanDoDriveBy(PlayerId(), false)
                            end)
                        end
                    end)
                    YGZ:CheckBox("Nao cair da moto", "nao_cair_da_moto", function(v)
                        LPH_NO_VIRTUALIZE(function()
                            if v then
                                SetPedCanBeKnockedOffVehicle(PlayerPedId(), 1)
                            else
                                SetPedCanBeKnockedOffVehicle(PlayerPedId(), 0)
                            end
                        end)
                    end, 'right')
                    YGZ:CheckBox("Super Velocidade", "super_velocidade", function(state)
                        LPH_NO_VIRTUALIZE(function()
                            local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                            if DoesEntityExist(veh) then
                                if state then
                                    SetVehicleGravityAmount(veh, 30.0)
                                    local sliderValue = YGZ.sliders["super_velocidade"] or 100
                                    SetVehicleForwardSpeed(veh, sliderValue)
                                else
                                    SetVehicleGravityAmount(veh, 9.8)
                                    SetVehicleForwardSpeed(veh, 1.0)
                                end
                            else
                                YGZ:notify("Entre em um veículo primeiro!", "erro")
                            end
                        end)
                    end, 'right')
                    
                elseif YGZ.subtabs.active == 'Tunagem' then
                    YGZ:TitleBox('Tunagem', 'Outros')

                    -- Tunagem Full
                    YGZ:Button('Tunagem Full', function()
                        LPH_NO_VIRTUALIZE(function()
                            local playerPed = PlayerPedId()
                            local vehicle = GetVehiclePedIsIn(playerPed)
                            if IsPedInAnyVehicle(playerPed) then
                                SetVehicleModKit(vehicle, 0)
                                SetVehicleWheelType(vehicle, 7)
                                for i = 0, 16 do
                                    if GetNumVehicleMods(vehicle, i) > 0 then
                                        SetVehicleMod(vehicle, i, GetNumVehicleMods(vehicle, i) - 1, false)
                                    end
                                end
                                for i = 18, 22 do
                                    ToggleVehicleMod(vehicle, i, true)
                                end
                                SetVehicleXenonLightsColor(vehicle, 2)
                                SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
                                SetVehicleCustomSecondaryColour(vehicle, 0, 0, 0)
                                SetVehicleWindowTint(vehicle, 1)
                                SetVehicleTyresCanBurst(vehicle, false)
                                YGZ:notify('Veículo tunado ao máximo!', 'sucesso')
                            else
                                YGZ:notify('Entre em um veículo primeiro!', 'erro')
                            end
                        end)
                    end, 'right')

                    -- Tunagem Aleatória
                    YGZ:Button('Tunagem Aleatória', function()
                        LPH_NO_VIRTUALIZE(function()
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                for i = 0, 16 do
                                    local numMods = GetNumVehicleMods(vehicle, i)
                                    if numMods > 0 then
                                        SetVehicleMod(vehicle, i, math.random(0, numMods-1), false)
                                    end
                                end
                                SetVehicleCustomPrimaryColour(vehicle, math.random(0,255), math.random(0,255), math.random(0,255))
                                SetVehicleCustomSecondaryColour(vehicle, math.random(0,255), math.random(0,255), math.random(0,255))
                                YGZ:notify('Tunagem aleatória aplicada!', 'sucesso')
                            else
                                YGZ:notify('Entre em um veículo primeiro!', 'erro')
                            end
                        end)
                    end, 'right')

                    -- Sliders para mods comuns
                    local modNames = {
                        [0] = 'Spoiler', [1] = 'Para-choque dianteiro', [2] = 'Para-choque traseiro', [3] = 'Saia', [4] = 'Escapamento',
                        [5] = 'Santo Antônio', [6] = 'Grade', [7] = 'Capô', [8] = 'Para-lama', [9] = 'Rodas',
                        [10] = 'Sistema de som', [11] = 'Banco', [12] = 'Volante', [13] = 'Câmbio', [15] = 'Suspensão', [16] = 'Blindagem'
                    }
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if vehicle ~= 0 then
                        for modType, modLabel in pairs(modNames) do
                            local numMods = GetNumVehicleMods(vehicle, modType)
                            if numMods > 0 then
                                YGZ:Slider(
                                    modLabel,
                                    'mod_'..modType,
                                    {value = -1, min = -1, max = numMods-1},
                                    function(value)
                                        LPH_NO_VIRTUALIZE(function()
                                            if value == -1 then
                                                RemoveVehicleMod(vehicle, modType)
                                            else
                                                SetVehicleMod(vehicle, modType, value, false)
                                            end
                                            YGZ:notify(modLabel..' modificado!', 'sucesso')
                                        end)
                                    end,
                                    'right'
                                )
                            end
                        end
                    else
                        YGZ:notify('Entre em um veículo primeiro!', 'erro')
                    end

                    -- Checkbox Turbo
                    YGZ:CheckBox('Turbo', 'turbo_enabled', function(v)
                        LPH_NO_VIRTUALIZE(function()
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            if vehicle ~= 0 then
                                ToggleVehicleMod(vehicle, 18, v)
                                YGZ:notify('Turbo '..(v and 'ativado' or 'desativado')..'!', 'sucesso')
                            else
                                YGZ:notify('Entre em um veículo primeiro!', 'erro')
                            end
                        end)
                    end, 'right')
                elseif YGZ.subtabs.active == 'Radar' then
                    YGZ:TitleBox('Radar', 'Outros')

					-- Coleta e ordena veículos por distância (mais perto primeiro)
					LPH_NO_VIRTUALIZE(function()
						local player = GetEntityCoords(PlayerPedId())
						local radarList = {}
						for _, veh in pairs(GetGamePool('CVehicle')) do
							if veh ~= 0 and DoesEntityExist(veh) then
								local vx, vy, vz = table.unpack(GetEntityCoords(veh))
								local dist = tonumber(string.format('%.0f', GetDistanceBetweenCoords(player.x, player.y, player.z, vx, vy, vz, true)))
								if dist and dist < 250 then
									table.insert(radarList, { veh = veh, dist = dist })
								end
							end
						end
						table.sort(radarList, function(a, b)
							if not a or not b then return false end
							return (a.dist or 1e9) < (b.dist or 1e9)
						end)
						for _, entry in ipairs(radarList) do
							local veh = entry.veh
							if veh ~= 0 and DoesEntityExist(veh) then
								local dist = entry.dist
								local nomeveh = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
								local vidaveh = GetEntityHealth(veh)
								local status = (GetPedInVehicleSeat(veh, -1) == 0) and 'Livre' or 'Ocupado'
								local isSelected = YGZ.SelectedVehicle == veh
								local SelecTionText = isSelected and 'Sim' or 'Não'
								local Title = nomeveh .. ' | ' .. dist .. 'm'
								local SubTitle = 'Vida: ' .. vidaveh .. ' | ' .. status .. ' | Selecionado: ' .. SelecTionText
								if isSelected then
									YGZ.toggles[nomeveh..veh] = true
								else
									YGZ.toggles[nomeveh..veh] = false
								end
								local textColor = {255, 255, 255, 255}
								if status == 'Ocupado' then
									textColor = {255, 0, 0, 255}
								end
								if YGZ.SelectedVehicle == veh then
									YGZ:CheckBox(Title, nomeveh..veh, function()
										YGZ.SelectedVehicle = not YGZ.SelectedVehicle
									end, 'left', textColor)
								else
									YGZ:CheckBox(Title, nomeveh..veh, function()
										YGZ.SelectedVehicle = veh
									end, 'left', textColor)
								end
							end
						end
					end)

                    -- Groupbox da direita: Funções de veículo
                    YGZ:Button('Teleportar até Veículo Selecionado', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedVehicle and DoesEntityExist(YGZ.SelectedVehicle) then
                                local veh = YGZ.SelectedVehicle
                                local vehicleCoords = GetEntityCoords(veh)
                                local playerPed = PlayerPedId()
                                SetEntityCoordsNoOffset(playerPed, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
                            else
                                YGZ:notify('Selecione um veículo válido!', 'erro')
                            end
                        end)
                    end, 'right')
                    YGZ:Button('Puxar Veículo Selecionado até Mim', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedVehicle and DoesEntityExist(YGZ.SelectedVehicle) then
                                local playerPed = PlayerPedId()
                                local playerCoords = GetEntityCoords(playerPed)
                                local veh = YGZ.SelectedVehicle
                    
                                -- Se o veículo estiver ocupado, tenta remover o motorista
                                local pedP1 = GetPedInVehicleSeat(veh, -1)
                                if pedP1 and pedP1 ~= 0 then
                                    NetworkRequestControlOfEntity(pedP1)
                                    local tries = 0
                                    while not NetworkHasControlOfEntity(pedP1) and tries < 30 do
                                        NetworkRequestControlOfEntity(pedP1)
                                        tries = tries + 1
                                        Wait(50)
                                    end
                                    TaskLeaveVehicle(pedP1, veh, 16)
                                    Wait(300)
                                    if IsPedInVehicle(pedP1, veh, false) then
                                        if not IsPedAPlayer(pedP1) then
                                            DeleteEntity(pedP1)
                                        else
                                            ClearPedTasksImmediately(pedP1)
                                        end
                                    end
                                end
                    
                                -- Controle do veículo
                                NetworkRequestControlOfEntity(veh)
                                local tries = 0
                                while not NetworkHasControlOfEntity(veh) and tries < 50 do
                                    NetworkRequestControlOfEntity(veh)
                                    tries = tries + 1
                                    Wait(100)
                                end
                    
                                if NetworkHasControlOfEntity(veh) then
                                    SetEntityCoordsNoOffset(veh, playerCoords.x + 2.0, playerCoords.y, playerCoords.z, false, false, false)
                                    Wait(100)
                                    SetVehicleOnGroundProperly(veh)
                                    SetVehicleDoorsLocked(veh, 1)
                                    SetVehicleDoorsLockedForAllPlayers(veh, false)
                                    YGZ:notify('Veículo puxado com sucesso!', 'sucesso')
                                else
                                    YGZ:notify('Não foi possível controlar o veículo!', 'erro')
                                end
                            else
                                YGZ:notify('Selecione um veículo válido!', 'erro')
                            end
                        end)
                    end, 'right')
                    
                    -- Função Remover Rodas (baseada no zenixmenu)
                    YGZ:Button('Remover Rodas do Veículo', function()
                        LPH_NO_VIRTUALIZE(function()
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            
                            if vehicle and vehicle ~= 0 then
                                -- Remover todas as rodas (0-3)
                                for i = 0, 3 do
                                    BreakOffVehicleWheel(vehicle, i, false, false, false, false)
                                end
                                YGZ:notify('Rodas removidas com sucesso!', 'sucesso')
                            else
                                YGZ:notify('Você precisa estar em um veículo!', 'erro')
                            end
                        end)
                    end, 'right')
                    
                    YGZ:Button('Clonar Veículo Selecionado', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedVehicle and DoesEntityExist(YGZ.SelectedVehicle) then
                                local playerPed = PlayerPedId()
                                local playerCoords = GetEntityCoords(playerPed)
                                local originalVeh = YGZ.SelectedVehicle
                                
                                -- Obter informações do veículo original
                                local vehModel = GetEntityModel(originalVeh)
                                local vehCoords = GetEntityCoords(originalVeh)
                                local vehHeading = GetEntityHeading(originalVeh)
                                
                                -- Criar uma cópia do veículo
                                local clonedVeh = CreateVehicle(vehModel, playerCoords.x + 2.0, playerCoords.y, playerCoords.z, vehHeading, true, false)
                                
                                if DoesEntityExist(clonedVeh) then
                                    -- Copiar propriedades do veículo original
                                    SetVehicleColours(clonedVeh, GetVehicleColours(originalVeh))
                                    SetVehicleExtraColours(clonedVeh, GetVehicleExtraColours(originalVeh))
                                    SetVehicleModKit(clonedVeh, 0)
                                    
                                    -- Copiar modificações
                                    for i = 0, 48 do
                                        local modType = GetVehicleMod(originalVeh, i)
                                        if modType ~= -1 then
                                            SetVehicleMod(clonedVeh, i, modType, false)
                                        end
                                    end
                                    
                                    -- Copiar cores personalizadas
                                    local primaryColor, secondaryColor = GetVehicleColours(originalVeh)
                                    local pearlescentColor, wheelColor = GetVehicleExtraColours(originalVeh)
                                    SetVehicleColours(clonedVeh, primaryColor, secondaryColor)
                                    SetVehicleExtraColours(clonedVeh, pearlescentColor, wheelColor)
                                    
                                    -- Definir propriedades do veículo clonado
                                    SetVehicleOnGroundProperly(clonedVeh)
                                    SetVehicleDoorsLocked(clonedVeh, 1)
                                    SetVehicleDoorsLockedForAllPlayers(clonedVeh, false)
                                    SetVehicleHasBeenOwnedByPlayer(clonedVeh, true)
                                    SetEntityAsMissionEntity(clonedVeh, true, true)
                                    
                                    -- Se spawnar dentro do carro estiver ativado
                                    if YGZ.toggles.spawnInVehicle then
                                        SetPedIntoVehicle(playerPed, clonedVeh, -1)
                                    end
                                    
                                    YGZ:notify('Veículo clonado com sucesso!', 'sucesso')
                                else
                                    YGZ:notify('Erro ao criar o veículo clonado!', 'erro')
                                end
                            else
                                YGZ:notify('Selecione um veículo válido!', 'erro')
                            end
                        end)
                    end, 'right')
-- TP para P1 do Veículo Selecionado (CORRIGIDO - fica no P1)
YGZ:Button('TP para P1 do Veículo Selecionado', function()
    LPH_NO_VIRTUALIZE(function()
        if YGZ.SelectedVehicle and DoesEntityExist(YGZ.SelectedVehicle) then
            local player = PlayerPedId()
            local vehicle = YGZ.SelectedVehicle
            
            -- Verificar se o veículo está ocupado
            local driver = GetPedInVehicleSeat(vehicle, -1)
            local isOccupied = driver ~= nil and driver ~= 0 and not IsEntityDead(driver)
            
            if isOccupied then
                -- Remover o motorista atual
                if not IsPedAPlayer(driver) then
                    DeleteEntity(driver)
                else
                    TaskLeaveVehicle(driver, vehicle, 16)
                    ClearPedTasksImmediately(driver)
                end
                Wait(300)
            end
            
            -- Solicitar controle do veículo
            NetworkRequestControlOfEntity(vehicle)
            local tries = 0
            while not NetworkHasControlOfEntity(vehicle) and tries < 25 do
                NetworkRequestControlOfEntity(vehicle)
                tries = tries + 1
                Wait(100)
            end
            
            if NetworkHasControlOfEntity(vehicle) then
                -- Teleportar para o veículo e colocar no P1
                SetEntityCoordsNoOffset(player, GetEntityCoords(vehicle))
                Wait(100)
                SetPedIntoVehicle(player, vehicle, -1)
                
                -- Garantir que está no P1
                SetVehicleDoorsLocked(vehicle, 1)
                SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                SetVehicleHasBeenOwnedByPlayer(vehicle, true)
                
                YGZ:notify('Você agora está no P1 do veículo!', 'sucesso')
            else
                YGZ:notify('Não foi possível controlar o veículo!', 'erro')
            end
        else
            YGZ:notify('Selecione um veículo primeiro!', 'erro')
        end
    end)
end, 'right')
                    YGZ:CheckBox('Spectar Veículo Selecionado', 'spectate_vehicle', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state then
                                if YGZ.SelectedVehicle and DoesEntityExist(YGZ.SelectedVehicle) then
                                    local veh = YGZ.SelectedVehicle
                                    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
                                    local offset = {x = 0.0, y = -8.0, z = 3.0}
                                    local function updateCam()
                                        if DoesEntityExist(veh) then
                                            local vehCoords = GetEntityCoords(veh)
                                            SetCamCoord(cam, vehCoords.x + offset.x, vehCoords.y + offset.y, vehCoords.z + offset.z)
                                            PointCamAtEntity(cam, veh, 0.0, 0.0, 0.0, true)
                                        end
                                    end
                                    SetCamActive(cam, true)
                                    RenderScriptCams(true, false, 0, true, true)
                                    YGZ:notify('Spectando veículo selecionado! Desative a checkbox para sair.', 'sucesso')
                                    Citizen.CreateThread(function()
                                        while YGZ.toggles['spectate_vehicle'] do
                                            Wait(0)
                                            if not DoesEntityExist(veh) then
                                                YGZ.toggles['spectate_vehicle'] = false
                                                break
                                            end
                                            updateCam()
                                        end
                                        RenderScriptCams(false, false, 0, true, true)
                                        DestroyCam(cam, false)
                                        YGZ:notify('Saiu do modo spectate do veículo.', 'sucesso')
                                    end)
                                else
                                    YGZ.toggles['spectate_vehicle'] = false
                                    YGZ:notify('Selecione um veículo válido!', 'erro')
                                end
                            end
                        end)
                    end, 'right')
                end
            elseif YGZ.subtabs.active == 'Online' then
                YGZ:SubTab('Online')
                if YGZ.subtabs.active == 'Online' then
                    YGZ:TitleBox('Online', 'Outros')
                    -- Listagem de jogadores (esquerda)
                    for _, player in pairs(GetActivePlayers()) do
                        local meplayerPed = PlayerPedId()
                        local meposs = GetEntityCoords(meplayerPed)
                        local playerped = GetPlayerPed(player)
                        local posallp = GetEntityCoords(playerped, true)
                        local playerName = GetPlayerName(player)                
                        local vasco = GetEntityHealth(playerped)
                        local dist = tonumber(string.format('%.0f', GetDistanceBetweenCoords(meposs, posallp), true))
                        local Visible = not IsEntityVisibleToScript(playerped)
                        local staff = Visible and 'Adm: [ADM]' or 'Adm: Não'
                        local isSelected = YGZ.SelectedPlayer == player
                        local SelecTionText = isSelected and 'Sim' or 'Não'
                        local Title = playerName..' | '..dist..'m'
                        local SubTitle = ''..staff..' | Vida: '..vasco..' | Sel: '..SelecTionText
                        if dist < 400 then
                            if isSelected then
                                YGZ.toggles[playerName..playerped] = true
                            else
                                YGZ.toggles[playerName..playerped] = false
                            end
                            
                            -- Determinar cor baseada na vida do jogador
                            local textColor = {255, 255, 255, 255} -- Branco por padrão
                            if vasco <= 0 then
                                textColor = {255, 0, 0, 255} -- Vermelho quando morto
                            end
                            
                            if YGZ.SelectedPlayer == player then
                                YGZ:CheckBox(Title, playerName..playerped, function()
                                    YGZ.SelectedPlayer = not YGZ.SelectedPlayer
                                end, 'left', textColor)
                            else
                                YGZ:CheckBox(Title, playerName..playerped, function()
                                    YGZ.SelectedPlayer = player
                                end, 'left', textColor)
                            end
                        end
                    end
                    -- Botões de ação (direita)
                    YGZ:Button('Teleportar até Jogador', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedPlayer then
                                local playerPed = GetPlayerPed(YGZ.SelectedPlayer)
                                local pos = GetEntityCoords(playerPed)
                                SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z + 1.0)
                            end
                        end)
                    end, 'right')
                    YGZ:Button('Puxar Jogador até Você', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedPlayer then
                                local myPed = PlayerPedId()
                                local myPos = GetEntityCoords(myPed)
                                local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                local targetCoords = GetEntityCoords(targetPed)
                                
                                -- Verificar se o jogador está em um veículo
                                local targetVehicle = GetVehiclePedIsIn(targetPed, false)
                                local isInVehicle = (targetVehicle and targetVehicle ~= 0)
                                
                                if isInVehicle then
                                    -- Se estiver em veículo, puxar o veículo também
                                    NetworkRequestControlOfEntity(targetVehicle)
                                    local tries = 0
                                    while not NetworkHasControlOfEntity(targetVehicle) and tries < 25 do
                                        NetworkRequestControlOfEntity(targetVehicle)
                                        tries = tries + 1
                                        Wait(50)
                                    end
                                    
                                    if NetworkHasControlOfEntity(targetVehicle) then
                                        SetEntityCoordsNoOffset(targetVehicle, myPos.x + 3.0, myPos.y, myPos.z, false, false, false)
                                        SetVehicleOnGroundProperly(targetVehicle)
                                        Wait(100)
                                        -- Garantir que o jogador continue no veículo
                                        SetPedIntoVehicle(targetPed, targetVehicle, -1)
                                    end
                                else
                                    -- Se não estiver em veículo, puxar apenas o jogador
                                    SetEntityCoordsNoOffset(targetPed, myPos.x, myPos.y, myPos.z + 1.0, false, false, false)
                                    Wait(100)
                                    -- Verificar se há colisão e ajustar posição
                                    local groundZ = GetGroundZFor_3dCoord(myPos.x, myPos.y, myPos.z + 10.0)
                                    if groundZ then
                                        SetEntityCoordsNoOffset(targetPed, myPos.x, myPos.y, groundZ + 1.0, false, false, false)
                                    end
                                end
                                
                                YGZ:notify('Jogador puxado com sucesso!', 'sucesso')
                            else
                                YGZ:notify('Selecione um jogador válido!', 'erro')
                            end
                        end)
                    end, 'right')
                    YGZ:CheckBox('Espectar Jogador', 'SpectatePlayer', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedPlayer then
                                if state then
                                    local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
                                    AttachCamToEntity(cam, targetPed, 0.0, 0.0, 1.0, true)
                                    SetCamActive(cam, true)
                                    RenderScriptCams(true, false, 0, true, true)
                                    YGZ.spectateCam = cam
                                else
                                    if YGZ.spectateCam then
                                        DestroyCam(YGZ.spectateCam, false)
                                        RenderScriptCams(false, false, 0, true, false)
                                        YGZ.spectateCam = nil
                                    end
                                end
                            end
                        end)
                    end, 'right')
                    YGZ:Button('Matar Todos os Jogadores', function()
                        LPH_NO_VIRTUALIZE(function()
                            Citizen.CreateThread(function()
                                for _, playerId in ipairs(GetActivePlayers()) do
                                    local ped = GetPlayerPed(playerId)
                                    if ped ~= PlayerPedId() then
                                        -- Método baseado no Vanta Menu
                                        SetEntityHealth(ped, 0)
                                        -- Alternativa: usar ragdoll
                                        -- SetPedToRagdoll(ped, 10000, 10000, 0, 0, 0, 0)
                                    end
                                end
                                YGZ:notify('Todos os jogadores foram mortos!', 'sucesso')
                            end)
                        end)
                    end, 'right')
                    YGZ:Button('Jogar Veículo no Mar', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedVehicle and DoesEntityExist(YGZ.SelectedVehicle) then
                                local playerPed = PlayerPedId()
                                local playerCoords = GetEntityCoords(playerPed)
                                local veh = YGZ.SelectedVehicle
                                
                                -- Coordenadas do mar (baseadas no Vanta Menu)
                                local oceanCoords = vector3(3203.767, -4039.129, 201.3459)
                                
                                -- Solicitar controle do veículo
                                NetworkRequestControlOfEntity(veh)
                                local tries = 0
                                while not NetworkHasControlOfEntity(veh) and tries < 25 do
                                    NetworkRequestControlOfEntity(veh)
                                    tries = tries + 1
                                    Wait(50)
                                end
                                
                                if NetworkHasControlOfEntity(veh) then
                                    -- Entrar no veículo temporariamente
                                    SetPedIntoVehicle(playerPed, veh, -1)
                                    Wait(100)
                                    
                                    -- Limpar tarefas do jogador
                                    ClearPedTasksImmediately(playerPed)
                                    
                                    -- Teleportar o veículo para o mar
                                    SetEntityCoordsNoOffset(veh, oceanCoords.x, oceanCoords.y, oceanCoords.z, false, false, false)
                                    
                                    -- Restaurar posição original do jogador
                                    SetEntityCoordsNoOffset(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
                                    
                                    YGZ:notify('Veículo jogado no mar!', 'sucesso')
                                else
                                    YGZ:notify('Não foi possível controlar o veículo!', 'erro')
                                end
                            else
                                YGZ:notify('Selecione um veículo válido!', 'erro')
                            end
                        end)
                    end, 'right')
                    YGZ:Button('Jogar Veículo no Mt. Chilliad', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedVehicle and DoesEntityExist(YGZ.SelectedVehicle) then
                                local playerPed = PlayerPedId()
                                local playerCoords = GetEntityCoords(playerPed)
                                local veh = YGZ.SelectedVehicle
                                
                                -- Coordenadas do Mt. Chilliad (baseadas no Vanta Menu)
                                local mountainCoords = vector3(504.6576, 5603.875, 797.9095)
                                
                                -- Solicitar controle do veículo
                                NetworkRequestControlOfEntity(veh)
                                local tries = 0
                                while not NetworkHasControlOfEntity(veh) and tries < 25 do
                                    NetworkRequestControlOfEntity(veh)
                                    tries = tries + 1
                                    Wait(50)
                                end
                                
                                if NetworkHasControlOfEntity(veh) then
                                    -- Entrar no veículo temporariamente
                                    SetPedIntoVehicle(playerPed, veh, -1)
                                    Wait(100)
                                    
                                    -- Limpar tarefas do jogador
                                    ClearPedTasksImmediately(playerPed)
                                    
                                    -- Teleportar o veículo para o Mt. Chilliad
                                    SetEntityCoordsNoOffset(veh, mountainCoords.x, mountainCoords.y, mountainCoords.z, false, false, false)
                                    
                                    -- Restaurar posição original do jogador
                                    SetEntityCoordsNoOffset(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
                                    
                                    YGZ:notify('Veículo jogado no Mt. Chilliad!', 'sucesso')
                                else
                                    YGZ:notify('Não foi possível controlar o veículo!', 'erro')
                                end
                            else
                                YGZ:notify('Selecione um veículo válido!', 'erro')
                            end
                        end)
                    end, 'right')
                    -- After existing buttons in TitleBox 'Ações', add:
                    YGZ:CheckBox('Rebolar no Player', 'RebolarPlayer', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state and YGZ.SelectedPlayer and YGZ.SelectedPlayer ~= PlayerId() then
                                Citizen.CreateThread(function()
                                    local playerPed = PlayerPedId()
                                    local playerPos = GetEntityCoords(playerPed)
                                    local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                    
                                    if not DoesEntityExist(targetPed) then
                                        YGZ:notify("Jogador alvo não encontrado!", "erro")
                                        return
                                    end
                                    
                                    -- Usar a mesma animação do Dragon GPT MENUS.lua
                                    local animDict = 'switch@trevor@mocks_lapdance'
                                    local animName = '001443_01_trvs_28_idle_stripper'
                                    
                                    RequestAnimDict(animDict)
                                    while not HasAnimDictLoaded(animDict) do Wait(10) end
                                    
                                    -- Implementação mais sofisticada com attachment
                                    local targetCoords = GetEntityCoords(targetPed)
                                    local boneIndex = GetEntityBoneIndexByName(targetPed, 'SKEL_ROOT')
                                    
                                    SetEntityCoords(playerPed, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, false)
                                    AttachEntityToEntity(playerPed, targetPed, boneIndex, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, true, true, 0, true)
                                    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
                                    SetPedKeepTask(playerPed, true)
                                    
                                    YGZ:notify("Rebolando no jogador!", "sucesso")
                                    
                                    -- Aguardar até desativar
                                    while YGZ.toggles.RebolarPlayer do
                                        Wait(100)
                                    end
                                    
                                    -- Limpar quando desativado
                                    ClearPedTasks(playerPed)
                                    DetachEntity(playerPed, true, false)
                                    SetEntityCoords(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false, false)
                                end)
                            else
                                local playerPed = PlayerPedId()
                                ClearPedTasks(playerPed)
                                DetachEntity(playerPed, true, false)
                            end
                        end)
                    end, 'right')

                    YGZ:CheckBox('Botar para Mamar', 'MamarPlayer', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state and YGZ.SelectedPlayer and YGZ.SelectedPlayer ~= PlayerId() then
                                Citizen.CreateThread(function()
                                    local playerPed = PlayerPedId()
                                    local playerPos = GetEntityCoords(playerPed)
                                    local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                    
                                    if not DoesEntityExist(targetPed) then
                                        YGZ:notify("Jogador alvo não encontrado!", "erro")
                                        return
                                    end
                                    
                                    -- Animações mais realistas
                                    local animDict1 = 'mini@prostitutes@sexlow_veh'
                                    local animName1 = 'low_car_bj_to_plyr'
                                    local animDict2 = 'mini@prostitutes@sexlow_veh'
                                    local animName2 = 'low_car_bj_plyr'
                                    
                                    RequestAnimDict(animDict1)
                                    RequestAnimDict(animDict2)
                                    while not HasAnimDictLoaded(animDict1) or not HasAnimDictLoaded(animDict2) do Wait(10) end
                                    
                                    -- Posicionar o jogador alvo
                                    local targetCoords = GetEntityCoords(targetPed)
                                    local boneIndex = GetEntityBoneIndexByName(targetPed, 'SKEL_Pelvis')
                                    
                                    -- Fazer o player alvo ajoelhar
                                    SetEntityCoords(targetPed, targetCoords.x, targetCoords.y - 0.5, targetCoords.z - 0.8, false, false, false, false)
                                    SetEntityHeading(targetPed, GetEntityHeading(playerPed))
                                    TaskPlayAnim(targetPed, animDict1, animName1, 8.0, -8.0, -1, 1, 0, false, false, false)
                                    
                                    -- Posicionar o player principal
                                    TaskPlayAnim(playerPed, animDict2, animName2, 8.0, -8.0, -1, 1, 0, false, false, false)
                                    SetPedKeepTask(targetPed, true)
                                    SetPedKeepTask(playerPed, true)
                                    
                                    YGZ:notify("Forçando ação no jogador!", "sucesso")
                                    
                                    -- Manter animações sincronizadas
                                    while YGZ.toggles.MamarPlayer and DoesEntityExist(targetPed) do
                                        -- Reforçar animações se pararem
                                        if not IsEntityPlayingAnim(targetPed, animDict1, animName1, 3) then
                                            TaskPlayAnim(targetPed, animDict1, animName1, 8.0, -8.0, -1, 1, 0, false, false, false)
                                        end
                                        if not IsEntityPlayingAnim(playerPed, animDict2, animName2, 3) then
                                            TaskPlayAnim(playerPed, animDict2, animName2, 8.0, -8.0, -1, 1, 0, false, false, false)
                                        end
                                        Wait(500)
                                    end
                                    
                                    -- Limpar quando desativado
                                    ClearPedTasks(targetPed)
                                    ClearPedTasks(playerPed)
                                    SetEntityCoords(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false, false)
                                end)
                            else
                                if YGZ.SelectedPlayer then
                                    local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                    local playerPed = PlayerPedId()
                                    ClearPedTasks(targetPed)
                                    ClearPedTasks(playerPed)
                                end
                            end
                        end)
                    end, 'right')

                    YGZ:CheckBox('Comer Player', 'ComerPlayer', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state and YGZ.SelectedPlayer and YGZ.SelectedPlayer ~= PlayerId() then
                                Citizen.CreateThread(function()
                                    local playerPed = PlayerPedId()
                                    local playerPos = GetEntityCoords(playerPed)
                                    local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                    
                                    if not DoesEntityExist(targetPed) then
                                        YGZ:notify("Jogador alvo não encontrado!", "erro")
                                        return
                                    end
                                    
                                    -- Múltiplas animações para variedade
                                    local animations = {
                                        {dict = "rcmpaparazzo_2", anim = "shag_loop_a"},
                                        {dict = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_player"},
                                        {dict = "timetable@trevor@skull_loving_bear", anim = "skull_loving_bear"}
                                    }
                                    
                                    local selectedAnim = animations[math.random(#animations)]
                                    
                                    RequestAnimDict(selectedAnim.dict)
                                    while not HasAnimDictLoaded(selectedAnim.dict) do Wait(10) end
                                    
                                    -- Posicionamento mais preciso
                                    local targetCoords = GetEntityCoords(targetPed)
                                    local targetHeading = GetEntityHeading(targetPed)
                                    
                                    -- Fazer o alvo deitar
                                    TaskPlayAnim(targetPed, "amb@world_human_sunbathe@male@back@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
                                    SetPedKeepTask(targetPed, true)
                                    
                                    Wait(1000)
                                    
                                    -- Posicionar o player principal
                                    SetEntityCoords(playerPed, targetCoords.x, targetCoords.y, targetCoords.z + 0.1, false, false, false, false)
                                    SetEntityHeading(playerPed, targetHeading)
                                    AttachEntityToEntity(playerPed, targetPed, -1, 0.0, -0.3, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                                    TaskPlayAnim(playerPed, selectedAnim.dict, selectedAnim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
                                    SetPedKeepTask(playerPed, true)
                                    
                                    YGZ:notify("Dominando jogador!", "sucesso")
                                    
                                    -- Manter animações
                                    while YGZ.toggles.ComerPlayer and DoesEntityExist(targetPed) do
                                        if not IsEntityPlayingAnim(playerPed, selectedAnim.dict, selectedAnim.anim, 3) then
                                            TaskPlayAnim(playerPed, selectedAnim.dict, selectedAnim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
                                        end
                                        if not IsEntityPlayingAnim(targetPed, "amb@world_human_sunbathe@male@back@base", "base", 3) then
                                            TaskPlayAnim(targetPed, "amb@world_human_sunbathe@male@back@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
                                        end
                                        Wait(1000)
                                    end
                                    
                                    -- Limpar
                                    DetachEntity(playerPed, true, false)
                                    ClearPedTasks(playerPed)
                                    ClearPedTasks(targetPed)
                                    SetEntityCoords(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false, false)
                                end)
                            else
                                local playerPed = PlayerPedId()
                                if IsEntityAttached(playerPed) then
                                    DetachEntity(playerPed, true, false)
                                    ClearPedTasks(playerPed)
                                end
                                if YGZ.SelectedPlayer then
                                    local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                    ClearPedTasks(targetPed)
                                end
                            end
                        end)
                    end, 'right')

                    YGZ:CheckBox('Fazer Sexo Duplo', 'SexoDuplo', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state and YGZ.SelectedPlayer and YGZ.SelectedPlayer ~= PlayerId() then
                                Citizen.CreateThread(function()
                                    local playerPed = PlayerPedId()
                                    local playerPos = GetEntityCoords(playerPed)
                                    local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                    
                                    if not DoesEntityExist(targetPed) then
                                        YGZ:notify("Jogador alvo não encontrado!", "erro")
                                        return
                                    end
                                    
                                    -- Animações sincronizadas
                                    local animDict1 = "rcmpaparazzo_2"
                                    local animName1 = "shag_loop_a"
                                    local animDict2 = "rcmpaparazzo_2" 
                                    local animName2 = "shag_loop_poppy"
                                    
                                    RequestAnimDict(animDict1)
                                    RequestAnimDict(animDict2)
                                    while not HasAnimDictLoaded(animDict1) or not HasAnimDictLoaded(animDict2) do Wait(10) end
                                    
                                    -- Posicionar ambos os players
                                    local targetCoords = GetEntityCoords(targetPed)
                                    local boneIndex = GetEntityBoneIndexByName(targetPed, 'SKEL_ROOT')
                                    
                                    -- Player alvo em posição
                                    TaskPlayAnim(targetPed, animDict2, animName2, 8.0, -8.0, -1, 1, 0, false, false, false)
                                    SetPedKeepTask(targetPed, true)
                                    
                                    -- Player principal
                                    SetEntityCoords(playerPed, targetCoords.x, targetCoords.y - 0.5, targetCoords.z, false, false, false, false)
                                    AttachEntityToEntity(playerPed, targetPed, boneIndex, 0.0, -0.5, 0.0, 0.0, 0.0, 180.0, true, true, true, true, 0, true)
                                    TaskPlayAnim(playerPed, animDict1, animName1, 8.0, -8.0, -1, 1, 0, false, false, false)
                                    SetPedKeepTask(playerPed, true)
                                    
                                    YGZ:notify("Iniciando sexo duplo!", "sucesso")
                                    
                                    -- Manter animações sincronizadas
                                    while YGZ.toggles.SexoDuplo and DoesEntityExist(targetPed) do
                                        -- Verificar e reforçar animações
                                        if not IsEntityPlayingAnim(targetPed, animDict2, animName2, 3) then
                                            TaskPlayAnim(targetPed, animDict2, animName2, 8.0, -8.0, -1, 1, 0, false, false, false)
                                        end
                                        if not IsEntityPlayingAnim(playerPed, animDict1, animName1, 3) then
                                            TaskPlayAnim(playerPed, animDict1, animName1, 8.0, -8.0, -1, 1, 0, false, false, false)
                                        end
                                        Wait(800)
                                    end
                                    
                                    -- Limpar
                                    DetachEntity(playerPed, true, false)
                                    ClearPedTasks(playerPed)
                                    ClearPedTasks(targetPed)
                                    SetEntityCoords(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false, false)
                                end)
                            else
                                local playerPed = PlayerPedId()
                                DetachEntity(playerPed, true, false)
                                ClearPedTasks(playerPed)
                                if YGZ.SelectedPlayer then
                                    local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                    ClearPedTasks(targetPed)
                                end
                            end
                        end)
                    end, 'right')

                    YGZ:Button('Saquear Jogador', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedPlayer ~= 'Nenhum' then
                                local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                if GetEntityHealth(targetPed) <= 110 then -- Verifica se a vida do jogador selecionado é menor ou igual a 110
                                    AttachEntityToEntity(targetPed, PlayerPedId(), 11816, 0.6, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                                    ExecuteCommand('saquear')
                                    ExecuteCommand('roubar')
                                    ExecuteCommand('revistar')
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    Citizen.SetTimeout(5000, function()
                                        DetachEntity(targetPed, true, false)
                                        FreezeEntityPosition(PlayerPedId(), false)
                                    end)
                                else
                                    YGZ:notify("O jogador selecionado não está ferido o suficiente para saquear.", "erro")
                                end
                            else
                                YGZ:notify("Selecione um jogador primeiro!", "erro")
                            end
                        end)
                    end, 'right')

                    YGZ:Button('Copiar Roupa', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedPlayer then
                                local srcPed = GetPlayerPed(YGZ.SelectedPlayer)
                                local destPed = PlayerPedId()
                                for i = 0, 11 do
                                    local drawable = GetPedDrawableVariation(srcPed, i)
                                    local texture = GetPedTextureVariation(srcPed, i)
                                    SetPedComponentVariation(destPed, i, drawable, texture, 0)
                                end
                                for i = 0, 2 do
                                    local prop = GetPedPropIndex(srcPed, i)
                                    local propTex = GetPedPropTextureIndex(srcPed, i)
                                    SetPedPropIndex(destPed, i, prop, propTex, true)
                                end
                            end
                        end)
                    end, 'right')
                    YGZ:Button('Deletar Veículo do Player', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedPlayer then
                                local veh = GetVehiclePedIsIn(GetPlayerPed(YGZ.SelectedPlayer), false)
                                if veh and veh ~= 0 then
                                    NetworkRequestControlOfEntity(veh)
                                    DeleteEntity(veh)
                                end
                            end
                        end)
                    end, 'right')

                    YGZ:Button('Chuva de Veículos', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedPlayer then
                                local pos = GetEntityCoords(GetPlayerPed(YGZ.SelectedPlayer))
                                for i = 1, 10 do
                                    local hash = GetHashKey('adder')
                                    RequestModel(hash); while not HasModelLoaded(hash) do Wait(0) end
                                    local veh = CreateVehicle(hash, pos.x, pos.y, pos.z + 50 + i*5, 0.0, true, true)
                                    SetEntityVelocity(veh, 0.0, 0.0, -10.0)
                                end
                            end
                        end)
                    end, 'right')
                    YGZ:CheckBox('Chuva de Veículos Loop', 'ChuvaVeicLoop', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state and YGZ.SelectedPlayer then
                                Citizen.CreateThread(function()
                                    local hash = GetHashKey('adder'); RequestModel(hash); while not HasModelLoaded(hash) do Wait(0) end
                                    while YGZ.toggles.ChuvaVeicLoop do
                                        local pos = GetEntityCoords(GetPlayerPed(YGZ.SelectedPlayer))
                                        local veh = CreateVehicle(hash, pos.x + math.random(-5,5), pos.y + math.random(-5,5), pos.z + 50, 0.0, true, true)
                                        SetEntityVelocity(veh, 0.0, 0.0, -10.0)
                                        Wait(500)
                                    end
                                end)
                            end
                        end)
                    end, 'right')

                    YGZ:Button('Chuva de Anti RP', function()
                        LPH_NO_VIRTUALIZE(function()
                            if YGZ.SelectedPlayer then
                                local pos = GetEntityCoords(GetPlayerPed(YGZ.SelectedPlayer))
                                for i = 1, 20 do
                                    AddExplosion(pos.x + math.random(-10,10), pos.y + math.random(-10,10), pos.z + 10 + i*2, 2, 100.0, true, false, 1.0)
                                end
                            end
                        end)
                    end, 'right')

                    YGZ:CheckBox('Molestar Jogador', 'MolestarJogador', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state and YGZ.SelectedPlayer then
                                Citizen.CreateThread(function()
                                    local myPed = PlayerPedId()
                                    local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
                                    while YGZ.toggles.MolestarJogador and DoesEntityExist(targetPed) do
                                        local targetPos = GetEntityCoords(targetPed)
                                        SetEntityCoords(myPed, targetPos.x, targetPos.y, targetPos.z - 0.5, false, false, false, false)
                                        ApplyDamageToPed(targetPed, 2, false)
                                        Wait(200)
                                    end
                                end)
                            end
                        end)
                    end, 'right')
                end
            elseif YGZ.tabs.active == 'Visual' then
                
                YGZ:TitleBox('ESP', 'Outros')

                -- Slider de distância ESP
                if not YGZ.sliders.ESPDistancia then
                    YGZ.sliders.ESPDistancia = 300
                end
                YGZ:Slider('Distância ESP', 'ESPDistancia', {value = YGZ.sliders.ESPDistancia, min = 0, max = 500}, function() end)

                -- ESP Nome (Fenix Menu Style)
                YGZ:CheckBox('ESP Nome', 'ESPNome', function(state)
                    if state then
                        Citizen.CreateThread(function()
                            while YGZ.toggles.ESPNome do
                                Citizen.Wait(0)
                                for _, playerId in ipairs(GetActivePlayers()) do
                                    local playerPed = GetPlayerPed(playerId)
                                    if DoesEntityExist(playerPed) and playerPed ~= PlayerPedId() then
                                        local playerCoords = GetEntityCoords(playerPed)
                                        local myCoords = GetEntityCoords(PlayerPedId())
                                        local distance = #(myCoords - playerCoords)
                                        if distance < YGZ.sliders.ESPDistancia then
                                            local onScreen, screenX, screenY = World3dToScreen2d(playerCoords.x, playerCoords.y, playerCoords.z - 0.9)
                                            if onScreen then
                                                local name = GetPlayerName(playerId)
                                                local text = string.format("%s - [%.1fm]", name, distance)
                                                SetTextFont(0)
                                                SetTextScale(0.24, 0.24)
                                                SetTextColour(255, 255, 255, 255)
                                                SetTextOutline()
                                                SetTextEntry("STRING")
                                                AddTextComponentString(text)
                                                DrawText(screenX, screenY + 0.025)
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)

                -- ESP Health (CROCK Menu Original - Funcional)
                YGZ:CheckBox('ESP Health', 'ESPHealth', function(state)
                    if state then
                        Citizen.CreateThread(function()
                            while YGZ.toggles.ESPHealth do
                                Citizen.Wait(0)
                                local jogadorLocal = PlayerId()
                                local pedLocal = PlayerPedId()
                                for _, jogador in ipairs(GetActivePlayers()) do
                                    if jogador ~= jogadorLocal then
                                        local pedAlvo = GetPlayerPed(jogador)
                                        if DoesEntityExist(pedAlvo) and IsEntityOnScreen(pedAlvo) then
                                            local incluirProprio = false
                                            local referencia = incluirProprio and nil or pedLocal
                                            local distancia = GetDistanceBetweenCoords(GetEntityCoords(referencia), GetEntityCoords(pedAlvo), true)
                                            if distancia < YGZ.sliders.ESPDistancia then
                                                local pedCoords = GetEntityCoords(pedAlvo)
                                                local dist = GetDistanceBetweenCoords(GetFinalRenderedCamCoord(), pedCoords, true)
                                                
                                                -- Converter coordenadas 3D para 2D
                                                local onScreen, screenX, screenY = World3dToScreen2d(pedCoords.x, pedCoords.y, pedCoords.z + 1.0)
                                            if onScreen then
                                                    local health = GetEntityHealth(pedAlvo)
                                                    local maxHealth = 200
                                                    local healthPercent = health / maxHealth
                                                    
                                                    -- Barra de fundo (preta)
                                                    local barWidth = 0.05
                                                    local barHeight = 0.008
                                                    local barX = screenX - barWidth/2
                                                    local barY = screenY - 0.05
                                                    
                                                    -- Desenhar fundo da barra
                                                    DrawRect(barX, barY, barWidth, barHeight, 0, 0, 0, 150)
                                                    
                                                    -- Desenhar barra de vida (verde)
                                                    local healthWidth = barWidth * healthPercent
                                                    local healthColor = healthPercent > 0.5 and {30, 255, 30} or (healthPercent > 0.25 and {255, 255, 30} or {255, 30, 30})
                                                    DrawRect(barX - barWidth/2 + healthWidth/2, barY, healthWidth, barHeight, healthColor[1], healthColor[2], healthColor[3], 255)
                                                    
                                                    -- Texto da vida
                                                    SetTextFont(0)
                                                    SetTextScale(0.2, 0.2)
                                                    SetTextColour(255, 255, 255, 255)
                                                    SetTextOutline()
                                                    SetTextEntry("STRING")
                                                    AddTextComponentString(math.floor(health) .. "/" .. maxHealth)
                                                    DrawText(barX, barY - 0.02)
                                            end
                                        end
                                    end
                                end
                                end
                            end
                        end)
                    end
                end)

                -- ESP Skeleton (CROCK Menu Original - Funcional)
                YGZ:CheckBox('ESP Skeleton', 'ESPSkeleton', function(state)
                    if state then
                        Citizen.CreateThread(function()
                            while YGZ.toggles.ESPSkeleton do
                                Citizen.Wait(0)
                                for _, jogador in ipairs(GetActivePlayers()) do
                                    local ped = GetPlayerPed(jogador)
                                    if ped ~= PlayerPedId() then
                                        local distMinima = YGZ.Visual_Dist(GetPedBoneCoords(ped, 0x0, 0.0, 0.0, 0.0))
                                        local direitaJoelho = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0x3FCF, 0.0, 0.0, 0.0), distMinima)
                                        local esquerdaJoelho = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0xB3FE, 0.0, 0.0, 0.0), distMinima)
                                        local pescoco = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0x9995, 0.0, 0.0, 0.0), distMinima)
                                        local cabeca = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0x796E, 0.0, 0.0, 0.0), distMinima)
                                        local pelve = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0x2E28, 0.0, 0.0, 0.0), distMinima)
                                        local peDireito = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0xCC4D, 0.0, 0.0, 0.0), distMinima)
                                        local peEsquerdo = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0x3779, 0.0, 0.0, 0.0), distMinima)
                                        local bracoSuperiorDireito = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0x9D4D, 0.0, 0.0, 0.0), distMinima)
                                        local bracoSuperiorEsquerdo = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0xB1C5, 0.0, 0.0, 0.0), distMinima)
                                        local antebracoDireito = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0x6E5C, 0.0, 0.0, 0.0), distMinima)
                                        local antebracoEsquerdo = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0xEEEB, 0.0, 0.0, 0.0), distMinima)
                                        local maoDireita = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0xDEAD, 0.0, 0.0, 0.0), distMinima)
                                        local maoEsquerda = YGZ.Coords_Soup(GetPedBoneCoords(ped, 0x49D9, 0.0, 0.0, 0.0), distMinima)
                                        local r, g, b = 255, 255, 255
                                        DrawLine(cabeca, pescoco, r, g, b, 255)
                                        DrawLine(pescoco, pelve, r, g, b, 255)
                                        DrawLine(pelve, direitaJoelho, r, g, b, 255)
                                        DrawLine(pelve, esquerdaJoelho, r, g, b, 255)
                                        DrawLine(direitaJoelho, peDireito, r, g, b, 255)
                                        DrawLine(esquerdaJoelho, peEsquerdo, r, g, b, 255)
                                        DrawLine(pescoco, bracoSuperiorDireito, r, g, b, 255)
                                        DrawLine(pescoco, bracoSuperiorEsquerdo, r, g, b, 255)
                                        DrawLine(bracoSuperiorDireito, antebracoDireito, r, g, b, 255)
                                        DrawLine(bracoSuperiorEsquerdo, antebracoEsquerdo, r, g, b, 255)
                                        DrawLine(antebracoDireito, maoDireita, r, g, b, 255)
                                        DrawLine(antebracoEsquerdo, maoEsquerda, r, g, b, 255)
                                    end
                                end
                            end
                        end)
                    end
                end)

                -- ESP Objetos (Melhorado)
                YGZ:CheckBox('ESP Objetos', 'ESPObjetos', function(state)
                    if state then
                        Citizen.CreateThread(function()
                            while YGZ.toggles.ESPObjetos do
                                Citizen.Wait(0)
                                local playerCoords = GetEntityCoords(PlayerPedId())
                                local maxDistance = YGZ.sliders.ESPDistancia
                                
                                for _, obj in pairs(GetGamePool('CObject')) do
                                    if DoesEntityExist(obj) then
                                        local objCoords = GetEntityCoords(obj)
                                        local distance = #(playerCoords - objCoords)
                                        
                                        if distance <= maxDistance then
                                            local onScreen, screenX, screenY = World3dToScreen2d(objCoords.x, objCoords.y, objCoords.z)
                                            if onScreen then
                                                local objHash = GetEntityModel(obj)
                                                local text = string.format("Objeto [%.1fm]", distance)
                                                
                                                SetTextFont(0)
                                                SetTextScale(0.25, 0.25)
                                                SetTextColour(255, 255, 255, 255)
                                                SetTextOutline()
                                                SetTextEntry("STRING")
                                                AddTextComponentString(text)
                                                DrawText(screenX, screenY)
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)

                -- ESP Veículos (Melhorado)
                YGZ:CheckBox('ESP Veículos', 'ESPVeiculos', function(state)
                    if state then
                        Citizen.CreateThread(function()
                            while YGZ.toggles.ESPVeiculos do
                                Citizen.Wait(0)
                                local playerCoords = GetEntityCoords(PlayerPedId())
                                local maxDistance = YGZ.sliders.ESPDistancia
                                
                                for _, veh in pairs(GetGamePool('CVehicle')) do
                                    if DoesEntityExist(veh) then
                                        local vehCoords = GetEntityCoords(veh)
                                        local distance = #(playerCoords - vehCoords)
                                        
                                        if distance <= maxDistance then
                                            local onScreen, screenX, screenY = World3dToScreen2d(vehCoords.x, vehCoords.y, vehCoords.z)
                                            if onScreen then
                                            local vmodel = GetEntityModel(veh)
                                            local vname = GetDisplayNameFromVehicleModel(vmodel)
                                            local vlabel = GetLabelText(vname)
                                            local displayName = vlabel ~= "NULL" and vlabel or vname
                                                local text = string.format("%s [%.1fm]", displayName, distance)
                                                
                                                SetTextFont(0)
                                                SetTextScale(0.25, 0.25)
                                                SetTextColour(255, 255, 255, 255)
                                                SetTextOutline()
                                                SetTextEntry("STRING")
                                                AddTextComponentString(text)
                                                DrawText(screenX, screenY)
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)


                if not YGZ.sliders.ESPAdminDistancia then YGZ.sliders.ESPAdminDistancia = 500 end
                YGZ:Slider('Distância ESP Admin', 'ESPAdminDistancia', {value = YGZ.sliders.ESPAdminDistancia, min = 1, max = 1000}, function() end, 'right')
                if YGZ.toggles == nil then YGZ.toggles = {} end
                if YGZ.vars == nil then YGZ.vars = {} end
                YGZ:CheckBox('Lista Administradores', 'ESPAdmin', function(state)
                    if state then
                        if not YGZ.vars.lista_admin_pos then
                            YGZ.vars.lista_admin_pos = {x = 300, y = 200}
                        end
                        Citizen.CreateThread(function()
                            while YGZ.toggles.ESPAdmin do
                                local mouseX, mouseY = GetNuiCursorPosition()
                                -- Desenhar fundo com imagem personalizada
                                local dict, name = YGZ:GetSprite('ListAdm')
                                YGZ:DrawSprite(dict, name, YGZ.vars.lista_admin_pos.x, YGZ.vars.lista_admin_pos.y, 197, 52, 0, {255,255,255,255}, 10)
                                -- Título
                                SetTextFont(0)
                                SetTextScale(0.3, 0.3)
                                SetTextColour(255,255,255,255)
                                SetTextCentre(false)
                                SetTextEntry("STRING")
                                AddTextComponentString("Administradores")
                                DrawText((YGZ.vars.lista_admin_pos.x + 50) / YGZ.screenW, (YGZ.vars.lista_admin_pos.y + 22) / YGZ.screenH)
                                -- Buscar admins
                                local admins = {}
                                local playerPed = PlayerPedId()
                                local playerChestCoords = GetPedBoneCoords(playerPed, 24818, 0.0, 0.0, 0.0)
                                local maxDistance = YGZ.sliders.ESPAdminDistancia or 500
                                for _, id in ipairs(GetActivePlayers()) do
                                    if id ~= PlayerId() then
                                        local ped = GetPlayerPed(id)
                                        local pedChestCoords = GetPedBoneCoords(ped, 24818, 0.0, 0.0, 0.0)
                                        local distance = #(playerChestCoords - pedChestCoords)
                                        local isAdmin = false
                                        if GetPlayerInvincible(id) then isAdmin = true end
                                        if not IsEntityTouchingEntity(ped, GetEntityAttachedTo(ped)) and not IsPedFalling(ped) and not IsPedRagdoll(ped) and (GetEntityHeightAboveGround(ped) > 5.0) then isAdmin = true end
                                        if distance <= maxDistance and isAdmin then
                                            table.insert(admins, {
                                                nome = GetPlayerName(id),
                                                distancia = math.floor(distance),
                                                ped = ped
                                            })
                                        end
                                    end
                                end
                                -- Arrastar janela
                                if IsDisabledControlPressed(0, 24) and mouseX >= YGZ.vars.lista_admin_pos.x and mouseX <= YGZ.vars.lista_admin_pos.x + 197 and mouseY >= YGZ.vars.lista_admin_pos.y and mouseY <= YGZ.vars.lista_admin_pos.y + 63 then
                                    if not YGZ.vars.dragging_admin then
                                        YGZ.vars.drag_offset_admin = {x = mouseX - YGZ.vars.lista_admin_pos.x, y = mouseY - YGZ.vars.lista_admin_pos.y}
                                        YGZ.vars.dragging_admin = true
                                    end
                                end
                                if YGZ.vars.dragging_admin then
                                    if IsDisabledControlPressed(0, 24) then
                                        YGZ.vars.lista_admin_pos.x = mouseX - YGZ.vars.drag_offset_admin.x
                                        YGZ.vars.lista_admin_pos.y = mouseY - YGZ.vars.drag_offset_admin.y
                                    else
                                        YGZ.vars.dragging_admin = false
                                    end
                                end
                                -- Listar admins
                                local listY = YGZ.vars.lista_admin_pos.y + 50
                                local itemHeight = 30
                                if #admins > 0 then
                                    for i, admin in ipairs(admins) do
                                        local itemY = listY + (i-1) * itemHeight
                                        DrawRect((YGZ.vars.lista_admin_pos.x + 98.5) / YGZ.screenW, (itemY + 15) / YGZ.screenH, 197 / YGZ.screenW, itemHeight / YGZ.screenH, 25, 25, 25, 180)
                                        
                                        -- Nome do admin
                                        SetTextFont(0)
                                        SetTextScale(0.25, 0.25)
                                        SetTextColour(255,255,255,255)
                                        SetTextCentre(false)
                                        SetTextEntry("STRING")
                                        AddTextComponentString(admin.nome)
                                        DrawText((YGZ.vars.lista_admin_pos.x + 10) / YGZ.screenW, (itemY + 7) / YGZ.screenH)
                                        
                                        -- Distância (menor e melhor posicionada)
                                        SetTextFont(0)
                                        SetTextScale(0.2, 0.2)
                                        SetTextColour(200,200,200,255)
                                        SetTextCentre(false)
                                        SetTextEntry("STRING")
                                        AddTextComponentString(admin.distancia .. "m")
                                        DrawText((YGZ.vars.lista_admin_pos.x + 160) / YGZ.screenW, (itemY + 7) / YGZ.screenH)
                                    end
                                else
                                    DrawRect((YGZ.vars.lista_admin_pos.x + 98.5) / YGZ.screenW, (listY + 15) / YGZ.screenH, 197 / YGZ.screenW, 30 / YGZ.screenH, 25, 25, 25, 180)
                                    SetTextFont(0)
                                    SetTextScale(0.3, 0.3)
                                    SetTextColour(255,255,255,255)
                                    SetTextCentre(false)
                                    SetTextEntry("STRING")
                                    AddTextComponentString("Nenhum admin próximo")
                                    DrawText((YGZ.vars.lista_admin_pos.x + 10) / YGZ.screenW, (listY + 7) / YGZ.screenH)
                                end
                                Wait(0)
                            end
                        end)
                    end
                end, 'right')
            elseif YGZ.tabs.active == 'Exploits' then
                YGZ:SubTab('Exploits')
                YGZ:SubTab('Troll')
                YGZ:SubTab('Farm')
                YGZ:SubTab('Armas')
                if YGZ.subtabs.active == 'Troll' then
                    YGZ:TitleBox('Troll Functions', 'Spawn de Props')
                    
                    -- SPAWNAR TUBO
                    YGZ:Button('Spawnar Tubo', function()
                        LPH_NO_VIRTUALIZE(function()
                            local p = PlayerPedId()
                            if p then
                                -- Identificar o ped (jogador)
                                local playerPed = p
                        
                                -- Modelo do prop
                                local propModel = "stt_prop_stunt_tube_l"
                                local modelHash = GetHashKey(propModel)
                        
                                -- Solicitar e carregar o modelo do prop
                                RequestModel(modelHash)
                                while not HasModelLoaded(modelHash) do
                                    Wait(10)
                                end
                        
                                -- Reproduzir animação de retirando o paraquedas
                                local animDict = "amb@world_human_clipboard@male@idle_a"
                                local animName = "idle_c"
                        
                                -- Solicitar e carregar o dicionário de animações
                                RequestAnimDict(animDict)
                                while not HasAnimDictLoaded(animDict) do
                                    Wait(10)
                                end
                        
                                -- Reproduzir a animação
                                TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 2000, 49, 0, false, false, false)
                        
                                -- Esperar até que a animação termine
                                Wait(2000)
                        
                                -- Obter as coordenadas do jogador e ajustar a altura
                                local x, y, z = table.unpack(GetEntityCoords(playerPed))
                                local groundZ = z
                                local foundGround, groundZPosition = GetGroundZFor_3dCoord(x, y, z, false)
                                if foundGround then
                                    groundZ = groundZPosition
                                end
                        
                                -- Criar o prop manualmente
                                local prop = CreateEntityManually(modelHash, vector3(x, y, groundZ))
                                if prop then
                                    -- Configurações do prop
                                    PlaceObjectOnGroundProperly(prop)
                                    SetEntityCollision(prop, false, false)
                                    FreezeEntityPosition(prop, false)
                        
                                    -- Sincronizar estado do prop com State Bags
                                    Entity(prop).state.isVisible = true
                                    Entity(prop).state.canPassThrough = true
                        
                                    -- Liberar o modelo da memória
                                    SetModelAsNoLongerNeeded(modelHash)
                                    YGZ:notify('🧱 Tubo spawnado com sucesso!', 'sucesso')
                                else
                                    YGZ:notify('❌ Falha ao criar o tubo!', 'erro')
                                end
                        
                                -- Limpar a animação do jogador
                                ClearPedTasks(playerPed)
                            end
                        end)
                    end, 'right')
                    
                    -- SPAWNAR PISTA
                    YGZ:Button('Spawnar Pista', function()
                        LPH_NO_VIRTUALIZE(function()
                            local p = PlayerPedId()
                            if p then
                                -- Identificar o ped (jogador)
                                local playerPed = p
                    
                                -- Modelo do prop
                                local propModel = "stt_prop_track_block_01"
                                local modelHash = GetHashKey(propModel)
                    
                                -- Solicitar e carregar o modelo do prop
                                RequestModel(modelHash)
                                while not HasModelLoaded(modelHash) do
                                    Wait(10)
                                end
                    
                                -- Reproduzir animação de retirando o paraquedas
                                local animDict = "amb@world_human_clipboard@male@idle_a"
                                local animName = "idle_c"
                    
                                -- Solicitar e carregar o dicionário de animações
                                RequestAnimDict(animDict)
                                while not HasAnimDictLoaded(animDict) do
                                    Wait(10)
                                end
                    
                                -- Reproduzir a animação
                                TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 2000, 49, 0, false, false, false)
                    
                                -- Esperar até que a animação termine
                                Wait(2000)
                    
                                -- Obter as coordenadas do jogador e ajustar a altura
                                local x, y, z = table.unpack(GetEntityCoords(playerPed))
                                local groundZ = z
                                local foundGround, groundZPosition = GetGroundZFor_3dCoord(x, y, z, false)
                                if foundGround then
                                    groundZ = groundZPosition
                                end
                    
                                -- Criar o prop manualmente
                                local prop = CreateEntityManually(modelHash, vector3(x, y, groundZ))
                                if prop then
                                    -- Configurações do prop
                                    PlaceObjectOnGroundProperly(prop)
                                    SetEntityCollision(prop, false, false)
                                    FreezeEntityPosition(prop, false)
                    
                                    -- Sincronizar estado do prop com State Bags
                                    Entity(prop).state.isVisible = true
                                    Entity(prop).state.canPassThrough = true
                    
                                    -- Liberar o modelo da memória
                                    SetModelAsNoLongerNeeded(modelHash)
                                    YGZ:notify('🏁 Pista spawnada com sucesso!', 'sucesso')
                                else
                                    YGZ:notify('❌ Falha ao criar a pista!', 'erro')
                                end
                    
                                -- Limpar a animação do jogador
                                ClearPedTasks(playerPed)
                            end
                        end)
                    end, 'right')
                    
                    -- SPAWNAR PAREDE
                    YGZ:Button('Spawnar Parede', function()
                        LPH_NO_VIRTUALIZE(function()
                            local p = PlayerPedId()
                            if p then
                                -- Identificar o ped (jogador)
                                local playerPed = p
                        
                                -- Modelo do prop
                                local propModel = "stt_prop_stunt_track_straightice"
                                local modelHash = GetHashKey(propModel)
                        
                                -- Solicitar e carregar o modelo do prop
                                RequestModel(modelHash)
                                while not HasModelLoaded(modelHash) do
                                    Wait(10)
                                end
                        
                                -- Reproduzir animação de retirando o paraquedas
                                local animDict = "amb@world_human_clipboard@male@idle_a"
                                local animName = "idle_c"
                        
                                -- Solicitar e carregar o dicionário de animações
                                RequestAnimDict(animDict)
                                while not HasAnimDictLoaded(animDict) do
                                    Wait(10)
                                end
                        
                                -- Reproduzir a animação
                                TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 2000, 49, 0, false, false, false)
                        
                                -- Esperar até que a animação termine
                                Wait(2000)
                        
                                -- Obter as coordenadas do jogador e ajustar a altura
                                local x, y, z = table.unpack(GetEntityCoords(playerPed))
                                local groundZ = z
                                local foundGround, groundZPosition = GetGroundZFor_3dCoord(x, y, z, false)
                                if foundGround then
                                    groundZ = groundZPosition
                                end
                        
                                -- Criar o prop manualmente
                                local prop = CreateEntityManually(modelHash, vector3(x, y, groundZ))
                                if prop then
                                    -- Configurações do prop
                                    PlaceObjectOnGroundProperly(prop)
                                    SetEntityCollision(prop, false, false)
                                    FreezeEntityPosition(prop, false)
                        
                                    -- Sincronizar estado do prop com State Bags
                                    Entity(prop).state.isVisible = true
                                    Entity(prop).state.canPassThrough = true
                        
                                    -- Liberar o modelo da memória
                                    SetModelAsNoLongerNeeded(modelHash)
                                    YGZ:notify('🧊 Parede spawnada com sucesso!', 'sucesso')
                                else
                                    YGZ:notify('❌ Falha ao criar a parede!', 'erro')
                                end
                        
                                -- Limpar a animação do jogador
                                ClearPedTasks(playerPed)
                            end
                        end)
                    end, 'right')
                    
                    -- SPAWNAR BANANA
                    YGZ:Button('Spawnar Banana', function()
                        LPH_NO_VIRTUALIZE(function()
                            local p = PlayerPedId()
                            if p then
                                local playerPed = p
                    
                                local propModel = "stt_prop_banana"
                                local modelHash = GetHashKey(propModel)
                    
                                RequestModel(modelHash)
                                while not HasModelLoaded(modelHash) do
                                    Wait(10)
                                end
                    
                                local animDict = "amb@world_human_clipboard@male@idle_a"
                                local animName = "idle_c"
                    
                                RequestAnimDict(animDict)
                                while not HasAnimDictLoaded(animDict) do
                                    Wait(10)
                                end
                    
                                TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 2000, 49, 0, false, false, false)
                    
                                Wait(2000)
                    
                                local x, y, z = table.unpack(GetEntityCoords(playerPed))
                                local groundZ = z
                                local foundGround, groundZPosition = GetGroundZFor_3dCoord(x, y, z, false)
                                if foundGround then
                                    groundZ = groundZPosition
                                end
                    
                                local prop = CreateEntityManually(modelHash, vector3(x, y, groundZ))
                                if prop then
                                    PlaceObjectOnGroundProperly(prop)
                                    SetEntityCollision(prop, false, false)
                                    FreezeEntityPosition(prop, false)
                    
                                    Entity(prop).state.isVisible = true
                                    Entity(prop).state.canPassThrough = true
                    
                                    SetModelAsNoLongerNeeded(modelHash)
                                    YGZ:notify('🍌 Banana spawnada com sucesso!', 'sucesso')
                                else
                                    YGZ:notify('❌ Falha ao criar a banana!', 'erro')
                                end
                    
                                ClearPedTasks(playerPed)
                            end
                        end)
                    end, 'right')
                    
                elseif YGZ.subtabs.active == 'Exploits' then
                    YGZ:TitleBox('Exploits', 'Outros')
                    -- Funções Exploits já existentes...
                    -- Bypass Safezone
                    YGZ:Button('Liberar Tab (Santa)', function()
                        LPH_NO_VIRTUALIZE(function()
                            -- AstraAPI['StopResource']('player') -- Esta funcionalidade depende da AstraAPI e não será mais incluída.
                            EnableControlAction(1, 37, true)
                            NetworkResurrectLocalPlayer(GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), 0, 0)
                            YGZ:notify("Tab liberada (funcionalidade parcial), recurso 'player' pode não ter sido parado. Pressione TAB novamente se necessário.", "sucesso")
                        end)
                    end, 'right')
                    YGZ:CheckBox('Anti Mundo Solo', 'antimundosolo_toggle', function(state)
                        LPH_NO_VIRTUALIZE(function()
                            if state then
                                StopResource("hud")
                                YGZ:notify("Recurso 'hud' parado para anti mundo solo.", "info")
                            else
                                YGZ:notify("Anti Mundo Solo desativado. Reinicie o script ou o servidor para restaurar o HUD, se necessário.", "aviso")
                            end
                        end)
                    end, 'right')
                    YGZ:CheckBox('Bypass Safezone', 'BypassSafezone', function(state)
                        if state then
                            TriggerServerEvent('safezone:tunnel_req', false)
                            if YGZ.notify then YGZ:notify('Bypass Safezone ativado!', 'sucesso') end
                        else
                            TriggerServerEvent('safezone:tunnel_req', true)
                            if YGZ.notify then YGZ:notify('Safezone restaurada!', 'info') end
                        end
                    end)
                    -- Botão para ativar/desativar bloqueio de log de anticheat
                    if YGZ.toggles.RemoverLogAnticheat == nil then YGZ.toggles.RemoverLogAnticheat = false end
                    YGZ:CheckBox('Remover Log de Anticheat', 'RemoverLogAnticheat', function(state)
                        if state then
                            if not YGZ._anticheatLogBlockActive then
                                YGZ._anticheatLogBlockActive = true
                                local acEvents = {
                                    'anticheat:ban', 'anticheat:kick', 'ac:ban', 'ac:kick',
                                    'banPlayer', 'kickPlayer',
                                }
                                for _, eventName in ipairs(acEvents) do
                                    RegisterNetEvent(eventName)
                                    AddEventHandler(eventName, function(...)
                                        CancelEvent()
                                        print('Evento de anticheat bloqueado:', eventName)
                                    end)
                                end
                                print('Bloqueio de log de anticheat ATIVADO!')
                            end
                        else
                            print('Bloqueio de log de anticheat DESATIVADO! (recarregue o script para remover handlers)')
                        end
                    end)
                    YGZ:Button('Remover Modo Novato (Fusion Group)', function()
                        LPH_NO_VIRTUALIZE(function()
                            if LocalPlayer and LocalPlayer.state then
                                LocalPlayer.state["NovatMode"] = false
                                YGZ:notify('Modo novato removido (Fusion)!', 'sucesso')
                            else
                                YGZ:notify('StateBags não disponível!', 'erro')
                            end
                        end)
                    end)
                    -- Outras funções Exploits já existentes...
                    YGZ:Button('Pular WL', function()
                        LPH_NO_VIRTUALIZE(function()
                            if RegisterNUICallback then
                                RegisterNUICallback('CheckWhitelist', function(_, cb)
                                    cb(true)
                                end)
                            end
                            TriggerServerEvent("vRPcli:playerSpawned")
                            if vSERVER and vSERVER.CheckWhitelist then
                                vSERVER.CheckWhitelist = function()
                                    return true
                                end
                            end
                            if framework and framework.notify then
                                framework:notify("Tentativa de pular whitelist enviada!", "sucesso")
                            elseif YGZ and YGZ.notify then
                                YGZ:notify("Tentativa de pular whitelist enviada!", "sucesso")
                            else
                                print("Tentativa de pular whitelist enviada!")
                            end
                        end)
                    end, 'right')
                    -- AUDIO FUCKER (Baseado no message 3.txt)
                    if YGZ.toggles.AudioFucker == nil then YGZ.toggles.AudioFucker = false end
                    YGZ:CheckBox('Audio Fucker', 'AudioFucker', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles.AudioFucker do
                                    for _, player in pairs(GetActivePlayers()) do
                                        -- Spawn de múltiplos sons para crashar o áudio
                                        PlaySound(-1, 'Whoosh_1s_L_to_R', 'MP_LOBBY_SOUNDS', true)
                                        PlaySound(-1, 'Checkpoint_Hit', 'GTAO_FM_Events_Soundset', true)
                                        PlaySound(-1, 'Boss_Blipped', 'GTAO_Magnate_Hunt_Boss_SoundSet', true)
                                        PlaySound(-1, 'Bomb_Disarmed', 'GTAO_Speed_Convoy_Soundset', true)
                                        PlaySound(-1, 'SELECT', 'HUD_MINI_GAME_SOUNDSET', true)
                                        PlaySound(-1, 'Beep_Green', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true)
                                        PlaySound(-1, 'Start_Squelch', 'CB_RADIO_SFX', true)
                                        PlaySound(-1, 'End_Squelch', 'CB_RADIO_SFX', true)
                                        PlaySound(-1, 'Beep_Red', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true)
                                        PlaySound(-1, 'Hack_Success', 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', true)
                                    end
                                    Wait(50) -- Delay mínimo para máxima eficiência
                                end
                            end)
                            YGZ:notify('audio Fucker ATIVADO!', 'sucesso')
                        else
                            YGZ:notify('Audio Fucker DESATIVADO!', 'aviso')
                        end
                    end, 'right')
                    
                    -- FALAR COM TODOS (Baseado no message 3.txt)
                    if YGZ.toggles.FalarComTodos == nil then YGZ.toggles.FalarComTodos = false end
                    YGZ:CheckBox('Falar Com Todos', 'FalarComTodos', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles.FalarComTodos do
                                    -- Define proximidade de voz para 1000 metros (máximo)
                                    NetworkSetTalkerProximity(1000.0)
                                    Wait(1000) -- Atualiza a cada segundo
                                end
                            end)
                            YGZ:notify('🗣️ Falar Com Todos ATIVADO! (1000m)', 'sucesso')
                        else
                            -- Volta para proximidade normal (8 metros)
                            NetworkSetTalkerProximity(8.0)
                            YGZ:notify('🗣️ Falar Com Todos DESATIVADO! (8m)', 'aviso')
                        end
                    end, 'right')
                    YGZ:CheckBox("Freecam", "freecam_toggle", function(v)
                        LPH_NO_VIRTUALIZE(function()
                            if v then
                                YGZ:notify("Freecam ativado!", "sucesso")
                                local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                                local playerPed = PlayerPedId()
                                local playerCoords = GetEntityCoords(playerPed)
                                local playerRot = GetGameplayCamRot(2)
                                SetCamCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 1.0)
                                SetCamRot(cam, playerRot.x, playerRot.y, playerRot.z, 2)
                                RenderScriptCams(true, false, 1000, true, false)
                                Citizen.CreateThread(function()
                                    local rotX = playerRot.x
                                    local rotZ = playerRot.z
                                    while YGZ.toggles["freecam_toggle"] do
                                        DisableControlAction(0, 30, true)
                                        DisableControlAction(0, 31, true)
                                        DisableControlAction(0, 32, true)
                                        DisableControlAction(0, 33, true)
                                        DisableControlAction(0, 34, true)
                                        DisableControlAction(0, 35, true)
                                        DisableControlAction(0, 36, true)
                                        DisableControlAction(0, 21, true)
                                        DisableControlAction(0, 24, true)
                                        DisableControlAction(0, 25, true)
                                        DisableControlAction(0, 37, true)
                                        local moveSpeed = YGZ.sliders.freecamSpeed or 1.0
                                        if IsDisabledControlPressed(0, 21) then
                                            moveSpeed = moveSpeed * 2.0
                                        elseif IsDisabledControlPressed(0, 36) then
                                            moveSpeed = moveSpeed * 0.5
                                        end
                                        rotX = rotX - (GetDisabledControlNormal(1, 2) * 8.0)
                                        rotZ = rotZ - (GetDisabledControlNormal(1, 1) * 8.0)
                                        if rotX > 89.0 then rotX = 89.0 elseif rotX < -89.0 then rotX = -89.0 end
                                        local camCoords = GetCamCoord(cam)
                                        local r = rotZ * math.pi / 180.0
                                        local dx = -math.sin(r)
                                        local dy = math.cos(r)
                                        local direction = vector3(dx, dy, math.sin(rotX * math.pi / 180.0))
                                        if IsDisabledControlPressed(0, 32) then
                                            camCoords = camCoords + direction * moveSpeed
                                        end
                                        if IsDisabledControlPressed(0, 33) then
                                            camCoords = camCoords - direction * moveSpeed
                                        end
                                        if IsDisabledControlPressed(0, 34) then
                                            camCoords = vector3(
                                                camCoords.x - (dy * moveSpeed),
                                                camCoords.y + (dx * moveSpeed),
                                                camCoords.z
                                            )
                                        end
                                        if IsDisabledControlPressed(0, 35) then
                                            camCoords = vector3(
                                                camCoords.x + (dy * moveSpeed),
                                                camCoords.y - (dx * moveSpeed),
                                                camCoords.z
                                            )
                                        end
                                        if IsDisabledControlPressed(0, 22) then
                                            camCoords = vector3(
                                                camCoords.x,
                                                camCoords.y,
                                                camCoords.z + moveSpeed
                                            )
                                        end
                                        if IsDisabledControlPressed(0, 36) then
                                            camCoords = vector3(
                                                camCoords.x,
                                                camCoords.y,
                                                camCoords.z - (moveSpeed * 2.0)
                                            )
                                        end
                                        SetCamCoord(cam, camCoords)
                                        SetCamRot(cam, rotX, 0.0, rotZ, 2)
                                        local resX, resY = GetActiveScreenResolution()
                                        local crosshairSize = 20.0
                                        YGZ:DrawRect(resX/2 - crosshairSize /2, resY/2, crosshairSize, 2, {255, 255, 255, 255}, 1)
                                        YGZ:DrawRect(resX/2, resY/2 - crosshairSize/2, 2, crosshairSize, {255, 255, 255, 255}, 2)
                                        local w, h = GetActiveScreenResolution()
                                        local distance = math.floor(#(GetEntityCoords(PlayerPedId()) - GetCamCoord(cam)))
                                        YGZ:DrawText("Freecam - Distância: " .. distance .. "m", w/2, h - 20.0, 20, 255, false, {255, 255, 255, 255}, 4)
                                        
                                        -- SISTEMA DE MENU DA FREECAM
                                        if not YGZ.freecamMenu then
                                            YGZ.freecamMenu = {
                                                selected = 1,
                                                options = {
                                                    "Teleporte",
                                                    "Atirar",
                                                    "Atirar Veículo",
                                                    "Spawn Avião",
                                                    "Spawn Navio",
                                                    "Explosão",
                                                    "Fogo",
                                                    "Chuva de Veículos"
                                                }
                                            }
                                        end
                                        
                                        -- NAVEGAÇÃO DO MENU
                                        if IsDisabledControlJustPressed(0, 15) then -- SETA PARA CIMA
                                            YGZ.freecamMenu.selected = YGZ.freecamMenu.selected - 1
                                            if YGZ.freecamMenu.selected < 1 then
                                                YGZ.freecamMenu.selected = #YGZ.freecamMenu.options
                                            end
                                        elseif IsDisabledControlJustPressed(0, 14) then -- SETA PARA BAIXO
                                            YGZ.freecamMenu.selected = YGZ.freecamMenu.selected + 1
                                            if YGZ.freecamMenu.selected > #YGZ.freecamMenu.options then
                                                YGZ.freecamMenu.selected = 1
                                            end
                                        end
                                        
                                        -- EXECUTAR FUNÇÃO SELECIONADA COM ENTER
                                        if IsDisabledControlJustPressed(0, 18) then -- ENTER
                                            local camCoords = GetCamCoord(cam)
                                            local direction = vector3(dx, dy, math.sin(rotX * math.pi / 180.0))
                                            
                                            if YGZ.freecamMenu.selected == 1 then -- TELEPORTE
                                                SetEntityCoords(PlayerPedId(), camCoords.x, camCoords.y, camCoords.z + 0.5)
                                                YGZ:notify("Teleportado!", "sucesso")
                                                
                                            elseif YGZ.freecamMenu.selected == 2 then -- ATIRAR
                                                local endCoords = camCoords + (direction * 100.0)
                                                ShootSingleBulletBetweenCoords(
                                                    camCoords.x, camCoords.y, camCoords.z,
                                                    endCoords.x, endCoords.y, endCoords.z,
                                                    50, true, GetHashKey("WEAPON_HEAVYSNIPER"),
                                                    PlayerPedId(), true, false, 1000.0
                                                )
                                                YGZ:notify("Tiro disparado!", "sucesso")
                                                
                                            elseif YGZ.freecamMenu.selected == 3 then -- ATIRAR VEÍCULO
                                                local endCoords = camCoords + (direction * 50.0)
                                                local closestVehicle = nil
                                                local closestDistance = 999.0
                                                for _, vehicle in pairs(GetGamePool('CVehicle')) do
                                                    if DoesEntityExist(vehicle) then
                                                        local vehicleCoords = GetEntityCoords(vehicle)
                                                        local distance = #(camCoords - vehicleCoords)
                                                        if distance < closestDistance and distance <= 20.0 then
                                                            closestDistance = distance
                                                            closestVehicle = vehicle
                                                        end
                                                    end
                                                end
                                                
                                                if closestVehicle then
                                                    NetworkRequestControlOfEntity(closestVehicle)
                                                    local attempts = 0
                                                    while not NetworkHasControlOfEntity(closestVehicle) and attempts < 50 do
                                                        NetworkRequestControlOfEntity(closestVehicle)
                                                        attempts = attempts + 1
                                                        Wait(0)
                                                    end
                                                    if NetworkHasControlOfEntity(closestVehicle) then
                                                        local vehicleCoords = GetEntityCoords(closestVehicle)
                                                        local direction = endCoords - vehicleCoords
                                                        local distance = #(direction)
                                                        local normalizedDir = direction / distance
                                                        local force = normalizedDir * 100.0
                                                        ApplyForceToEntity(closestVehicle, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                                                        YGZ:notify("Veículo atirado!", "sucesso")
                                                    end
                                                else
                                                    YGZ:notify("Nenhum veículo próximo!", "aviso")
                                                end
                                                
                                            elseif YGZ.freecamMenu.selected == 4 then -- SPAWN AVIÃO
                                                local airplanes = {"luxor", "shamal", "velum", "cuban800", "stunt"}
                                                local randomPlane = airplanes[math.random(#airplanes)]
                                                local hash = GetHashKey(randomPlane)
                                                RequestModel(hash)
                                                while not HasModelLoaded(hash) do Wait(0) end
                                                local plane = CreateVehicle(hash, camCoords.x, camCoords.y, camCoords.z + 5.0, 0.0, true, true)
                                                if DoesEntityExist(plane) then
                                                    SetEntityRotation(plane, 0.0, 0.0, rotZ, 2, true)
                                                    YGZ:notify("Avião spawnado!", "sucesso")
                                                end
                                                
                                            elseif YGZ.freecamMenu.selected == 5 then -- SPAWN NAVIO
                                                local boats = {"speeder", "jetmax", "seashark", "toro", "marquis"}
                                                local randomBoat = boats[math.random(#boats)]
                                                local hash = GetHashKey(randomBoat)
                                                RequestModel(hash)
                                                while not HasModelLoaded(hash) do Wait(0) end
                                                local boat = CreateVehicle(hash, camCoords.x, camCoords.y, camCoords.z, 0.0, true, true)
                                                if DoesEntityExist(boat) then
                                                    SetEntityRotation(boat, 0.0, 0.0, rotZ, 2, true)
                                                    YGZ:notify("Navio spawnado!", "sucesso")
                                                end
                                                
                                            elseif YGZ.freecamMenu.selected == 6 then -- EXPLOSÃO
                                                AddExplosion(camCoords.x, camCoords.y, camCoords.z, 1, 100.0, true, false, 1.0)
                                                YGZ:notify("Explosão criada!", "sucesso")
                                                
                                            elseif YGZ.freecamMenu.selected == 7 then -- FOGO
                                                StartEntityFire(camCoords.x, camCoords.y, camCoords.z, 10.0, true)
                                                YGZ:notify("Fogo criado!", "sucesso")
                                                
                                            elseif YGZ.freecamMenu.selected == 8 then -- CHUVA DE VEÍCULOS
                                                local vehicles = {"adder", "zentorno", "t20", "kuruma", "insurgent"}
                                                for i = 1, 5 do
                                                    local randomVeh = vehicles[math.random(#vehicles)]
                                                    local hash = GetHashKey(randomVeh)
                                                    RequestModel(hash)
                                                    while not HasModelLoaded(hash) do Wait(0) end
                                                    CreateVehicle(hash,
                                                        camCoords.x + math.random(-5, 5),
                                                        camCoords.y + math.random(-5, 5),
                                                        camCoords.z + 20.0,
                                                        0.0, true, true)
                                                end
                                                YGZ:notify("Chuva de veículos!", "sucesso")
                                            end
                                        end
                                        
                                        -- DESENHAR MENU
                                        local menuX = w - 300
                                        local menuY = 100
                                        local menuWidth = 280
                                        local menuHeight = 30
                                        
                                        -- Fundo do menu
                                        YGZ:DrawRect(menuX, menuY, menuWidth, (#YGZ.freecamMenu.options * 35) + 20, {0, 0, 0, 150}, 0)
                                        
                                        -- Título
                                        YGZ:DrawText("🎮 FREECAM MENU", menuX + 10, menuY + 5, 20, 255, false, {255, 255, 255, 255}, 7)
                                        
                                        -- Opções do menu
                                        for i, option in ipairs(YGZ.freecamMenu.options) do
                                            local optionY = menuY + 30 + (i - 1) * 35
                                            local color = {255, 255, 255, 255}
                                            
                                            if i == YGZ.freecamMenu.selected then
                                                -- Opção selecionada
                                                YGZ:DrawRect(menuX + 5, optionY - 5, menuWidth - 10, 30, {255, 255, 255, 50}, 0)
                                                color = {0, 255, 0, 255}
                                            end
                                            
                                            YGZ:DrawText(option, menuX + 15, optionY, 18, 255, false, color, 8 + i)
                                        end
                                        
                                        -- Instruções
                                        YGZ:DrawText("↑↓ = Navegar | ENTER = Executar", menuX + 10, menuY + (#YGZ.freecamMenu.options * 35) + 25, 16, 255, false, {200, 200, 200, 255}, 9)
                                        
                                        Wait(0)
                                    end
                                    RenderScriptCams(false, false, 1000, true, false)
                                    DestroyCam(cam, false)
                                end)
                            else
                                YGZ:notify("Freecam desativado!", "info")
                            end
                        end)
                    end, 'right')
                    YGZ:Slider('Velocidade Freecam', 'freecamSpeed', {value = 1.0, min = 0.1, max = 5.0}, function(val)
                        YGZ.sliders.freecamSpeed = val
                    end, 'right')
                    YGZ:CheckBox("Magnetto", "Magnetto", function(state)
                        LPH_NO_VIRTUALIZE(function()
                            YGZ.toggles["Magnetto"] = state
                            if state then
                                Citizen.CreateThread(function()
                                    local range = 18.0
                                    while YGZ.toggles["Magnetto"] do
                                        local playerPed = PlayerPedId()
                                        local camCoords = GetGameplayCamCoord()
                                        local camRot = GetGameplayCamRot(2)
                                        local direction = vector3(
                                            -math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                                            math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                                            math.sin(math.rad(camRot.x))
                                        )
                                        local targetPos = camCoords + direction * range
                                        DrawMarker(28, targetPos.x, targetPos.y, targetPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 60, false, false, 2, nil, nil, false)
                                        if IsControlPressed(0, 38) then
                                            for _, vehicle in pairs(GetGamePool('CVehicle')) do
                                                if DoesEntityExist(vehicle) and #(GetEntityCoords(vehicle) - targetPos) <= range and GetVehiclePedIsIn(playerPed, false) ~= vehicle then
                                                    NetworkRequestControlOfEntity(vehicle)
                                                    local vehiclePos = GetEntityCoords(vehicle)
                                                    local forceDir = targetPos - vehiclePos
                                                    local distance = #forceDir
                                                    if distance > 0.1 then
                                                        local force = forceDir * (5.0 / distance)
                                                        ApplyForceToEntity(vehicle, 3, force.x, force.y, force.z + 0, 0, 0, 0, false, false, true, true, false, true)
                                                    end
                                                end
                                            end
                                        end
                                        Wait(0)
                                    end
                                end)
                            end
                        end)
                    end, 'right')
                    
                    if YGZ.toggles.RemoverLogKills == nil then YGZ.toggles.RemoverLogKills = false end
                    YGZ:CheckBox('Remover Log de Kills', 'RemoverLogKills', function(state)
                        if state then
                            if not YGZ._killLogBlockActive then
                                YGZ._killLogBlockActive = true
                                local killLogEvents = {
                                    'playerDied', 'playerKilled', 'logKill', 'sendDeathLog', 'killLog', 'deathLog',
                                    'discord:logKill', 'discord:logDeath', 'anticheat:logKill', 'anticheat:logDeath',
                                }
                                for _, eventName in ipairs(killLogEvents) do
                                    RegisterNetEvent(eventName)
                                    AddEventHandler(eventName, function(...)
                                        CancelEvent()
                                        print('Evento de log de kill bloqueado:', eventName)
                                    end)
                                end
                                print('Bloqueio de log de kills ATIVADO!')
                            end
                        else
                            print('Bloqueio de log de kills DESATIVADO! (recarregue o script para remover handlers)')
                        end
                    end)
                    ---- Weapon Size Scale (1..50) contínuo, SEM API
                    local TOGGLE_KEY = 'weapon_size_on'
                    local SLIDER_KEY = 'weapon_size_scale'
                    
                    if YGZ.toggles[TOGGLE_KEY] == nil then YGZ.toggles[TOGGLE_KEY] = false end
                    if not YGZ.sliders[SLIDER_KEY] then YGZ.sliders[SLIDER_KEY] = 5 end
                    
                    if YGZ.supportsEntityScale == nil then
                        YGZ.supportsEntityScale = (type(SetEntityScale) == 'function')
                    end
                    
                    local function getWeaponEntity()
                        local ped = PlayerPedId()
                        local ent = GetCurrentPedWeaponEntityIndex(ped)
                        if ent and ent ~= 0 and DoesEntityExist(ent) then return ent end
                        return nil
                    end
                    
                    local function mapScaleIntToEntity(valInt)
                        local v = tonumber(valInt) or 5
                        return math.max(0.2, math.min(5.0, v / 5.0)) -- 1..50 -> 0.2..5.0
                    end
                    
                    local function applyWeaponSize(scaleInt)
                        if not YGZ.supportsEntityScale then return end
                        local ent = getWeaponEntity()
                        if not ent then return end
                        local s = mapScaleIntToEntity(scaleInt)
                        SetEntityScale(ent, s, s, s, false)
                    end
                    
                    local function resetWeaponSize()
                        if not YGZ.supportsEntityScale then return end
                        local ent = getWeaponEntity()
                        if ent then SetEntityScale(ent, 1.0, 1.0, 1.0, false) end
                    end
                    
                    YGZ:CheckBox('Enable Weapon Size', TOGGLE_KEY, function(state)
                        YGZ.toggles[TOGGLE_KEY] = state
                        if state then
                            if not YGZ.supportsEntityScale and YGZ.notify then
                                YGZ:notify('Seu build não suporta SetEntityScale. Use sv_enforceGameBuild 3258.', 'aviso')
                            end
                            if not YGZ._weaponSizeThread then
                                YGZ._weaponSizeThread = true
                                Citizen.CreateThread(function()
                                    while YGZ.toggles[TOGGLE_KEY] do
                                        applyWeaponSize(YGZ.sliders[SLIDER_KEY] or 5)
                                        Wait(0) -- contínuo
                                    end
                                    resetWeaponSize()
                                    YGZ._weaponSizeThread = nil
                                end)
                            end
                        else
                            resetWeaponSize()
                        end
                    end)
                    
                    if YGZ.toggles[TOGGLE_KEY] then
                        YGZ:Slider('Tamanho da Arma', SLIDER_KEY, { start = YGZ.sliders[SLIDER_KEY], min = 1, max = 50 }, function(val)
                            YGZ.sliders[SLIDER_KEY] = val
                            applyWeaponSize(val)
                        end)
                    end
-- Segurar Veículo no Y (SatzX-style) - sem API
-- Recursos: mira no veículo, pega com Y, animação mãos para cima, arremessa com Y
-- Slider ajusta a força do arremesso. Usa BMX invisível para estabilidade do attach.

local segurandoVeh = false
local vehSegurado = nil
local bmxSeg = nil

-- Aux: converte rotação da câmera em direção
local function RotationToDirection(rot)
	local heading = math.rad(rot.z)
	local pitch = math.rad(rot.x)
	local x = -math.sin(heading) * math.cos(pitch)
	local y =  math.cos(heading) * math.cos(pitch)
	local z =  math.sin(pitch)
	return vector3(x, y, z)
end

-- Slider de força de arremesso (1-500; padrão 50)
if not YGZ.sliders then YGZ.sliders = {} end
if YGZ.sliders['SatzXHoldThrow'] == nil then YGZ.sliders['SatzXHoldThrow'] = 50 end
YGZ:Slider('Força do Arremesso (Segurar Y)', 'SatzXHoldThrow', { start = YGZ.sliders['SatzXHoldThrow'], min = 1, max = 500 }, function(v)
	YGZ.sliders['SatzXHoldThrow'] = v
end, 'right')

YGZ:CheckBox('Segurar Veículo no Y (SatzX)', 'SatzXHoldVeh', function(state)
	if state then
		YGZ:notify('Mire em um veículo e pressione [Y] para segurar. [Y] novamente para arremessar.', 'sucesso')

		Citizen.CreateThread(function()
			while YGZ.toggles['SatzXHoldVeh'] do
				Wait(1)
				local playerPed = PlayerPedId()
				local camPos = GetGameplayCamCoord()
				local camRot = GetGameplayCamRot(2)
				local direction = RotationToDirection(camRot)
				local dest = vector3(camPos.x + direction.x * 10.0, camPos.y + direction.y * 10.0, camPos.z + direction.z * 10.0)

				-- Raycast sob a mira
				local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, playerPed, 0)
				local _, hit, endPos, surfaceNormal, entityHit = GetShapeTestResult(ray)

				-- UI dica
				if hit == 1 and entityHit ~= 0 and GetEntityType(entityHit) == 2 and not segurandoVeh then
					local vehCoords = GetEntityCoords(entityHit)
					if World3dToScreen2d(vehCoords.x, vehCoords.y, vehCoords.z + 2.0) then
						SetDrawOrigin(vehCoords.x, vehCoords.y, vehCoords.z + 0.5, 0)
						SetTextFont(0)
						SetTextScale(0.3, 0.3)
						SetTextColour(255, 255, 255, 255)
						SetTextOutline()
						SetTextCentre(1)
						SetTextEntry('STRING')
						AddTextComponentString('Pressione [Y] para segurar o veículo')
						DrawText(0.0, -0.01)
						ClearDrawOrigin()
					end
				end

				-- Pressionar Y: pegar ou arremessar
				if IsControlJustReleased(0, 246) then
					if not segurandoVeh then
						-- Pegar veículo sob a mira
						if hit == 1 and entityHit ~= 0 and GetEntityType(entityHit) == 2 then
							local veh = entityHit
							NetworkRequestControlOfEntity(veh)
							local tries = 0
							while not NetworkHasControlOfEntity(veh) and tries < 40 do
								NetworkRequestControlOfEntity(veh)
								tries = tries + 1
								Wait(25)
							end
							if not NetworkHasControlOfEntity(veh) then
								YGZ:notify('Não consegui controlar o veículo.', 'erro')
							else
								-- Preparar BMX invisível e anexar
								local myPos = GetEntityCoords(playerPed)
								local model = GetHashKey('bmx')
								RequestModel(model)
								while not HasModelLoaded(model) do Wait(10) end
								bmxSeg = CreateVehicle(model, myPos.x, myPos.y, myPos.z, 0.0, false, false)
								SetEntityVisible(bmxSeg, false, false)
								SetEntityAsMissionEntity(bmxSeg, true, true)
								NetworkRequestControlOfEntity(bmxSeg)

								vehSegurado = veh
								-- Attach veículo ao BMX (à frente/acima do player)
								AttachEntityToEntity(vehSegurado, bmxSeg, -1, 0.0, 1.0, 4.0, 0.0, 0.0, 240.0, true, true, false, true, 1, true)
								Wait(10)
								-- Attach BMX ao player (nas costas/abaixo para estabilidade)
								AttachEntityToEntity(bmxSeg, playerPed, 0, 0.0, 0.0, -2.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

								-- Animação de mãos para cima (como no SatzX)
								local animDict = 'anim@mp_rollarcoaster'
								RequestAnimDict(animDict)
								while not HasAnimDictLoaded(animDict) do Wait(10) end
								TaskPlayAnim(playerPed, animDict, 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)

								-- Estado ativo
								segurandoVeh = true
								YGZ:notify('Veículo segurado! Pressione [Y] novamente para arremessar.', 'sucesso')
							end
						else
							YGZ:notify('Mire em um veículo válido.', 'aviso')
						end
					else
						-- Arremessar
						if vehSegurado and DoesEntityExist(vehSegurado) then
							local throwSpeed = (YGZ.sliders['SatzXHoldThrow'] or 50) / 100.0
							local force = throwSpeed * 100.0
							local camRot2 = GetGameplayCamRot(2)
							local dir2 = RotationToDirection(camRot2)

							DetachEntity(vehSegurado, true, true)
							Wait(80)
							ApplyForceToEntity(vehSegurado, 3, dir2.x * force, dir2.y * force, dir2.z * force, 0.0, 0.0, 0.0, false, false, true, true, false, true)
						end
						ClearPedTasks(playerPed)

						-- Limpeza
						segurandoVeh = false
						if vehSegurado and DoesEntityExist(vehSegurado) then
							SetEntityNoCollisionEntity(vehSegurado, playerPed, false)
							vehSegurado = nil
						end
						if bmxSeg and DoesEntityExist(bmxSeg) then
							DeleteEntity(bmxSeg)
							bmxSeg = nil
						end
					end
				end
			end

			-- Limpeza ao desativar checkbox
			if segurandoVeh then
				local ped = PlayerPedId()
				if vehSegurado and DoesEntityExist(vehSegurado) then
					DetachEntity(vehSegurado, true, true)
					SetEntityNoCollisionEntity(vehSegurado, ped, false)
					vehSegurado = nil
				end
				if bmxSeg and DoesEntityExist(bmxSeg) then
					DeleteEntity(bmxSeg)
					bmxSeg = nil
				end
				ClearPedTasks(ped)
				segurandoVeh = false
			end
		end)
	else
		-- Desativado manualmente
		if segurandoVeh then
			local ped = PlayerPedId()
			if vehSegurado and DoesEntityExist(vehSegurado) then
				DetachEntity(vehSegurado, true, true)
				SetEntityNoCollisionEntity(vehSegurado, ped, false)
				vehSegurado = nil
			end
			if bmxSeg and DoesEntityExist(bmxSeg) then
				DeleteEntity(bmxSeg)
				bmxSeg = nil
			end
			ClearPedTasks(ped)
			segurandoVeh = false
		end
	end
end, 'right')
-- Remover do Veículo [F] (flags de ped)
YGZ:CheckBox('Remover do Veículo [F]', 'Removerf', function(state)
	if state then
		Citizen.CreateThread(function()
			local flags = {
				[342] = false,
				[252] = true,
				[141] = true,
				[144] = true
			}

			while YGZ.toggles['Removerf'] do
				local ped = PlayerPedId()
				for flagId, value in pairs(flags) do
					SetPedConfigFlag(ped, flagId, value)
				end
				Wait(0)
			end

			local ped = PlayerPedId()
			for flagId, _ in pairs({ [342]=true, [252]=true, [141]=true, [144]=true }) do
				SetPedConfigFlag(ped, flagId, false)
			end
		end)
	end
end)
-- Physic Gun: segurar/girar/congelar entidades
local PG_TOGGLE = 'physic_gun'
local PG_DIST   = 'physic_gun_dist'
if YGZ.toggles[PG_TOGGLE] == nil then YGZ.toggles[PG_TOGGLE] = false end
if not YGZ.sliders[PG_DIST] then YGZ.sliders[PG_DIST] = 5.0 end

local held, frozen = nil, false

local function camForward()
    local rot = GetGameplayCamRot(2)
    local rx, rz = math.rad(rot.x), math.rad(rot.z)
    return vector3(-math.sin(rz)*math.abs(math.cos(rx)), math.cos(rz)*math.abs(math.cos(rx)), math.sin(rx))
end

local function rayFromCam(dist)
    local cam = GetGameplayCamCoord()
    local dir = camForward()
    local dst = cam + (dir*dist)
    local ray = StartShapeTestRay(cam.x,cam.y,cam.z,dst.x,dst.y,dst.z,-1,PlayerPedId(),7)
    local _, hit, endPos, _, ent = GetShapeTestResult(ray)
    if hit==1 and DoesEntityExist(ent) then return ent,endPos end
end

local function reqCtl(ent)
    if not ent then return end
    NetworkRequestControlOfEntity(ent)
    local t = GetGameTimer()
    while not NetworkHasControlOfEntity(ent) and (GetGameTimer()-t) < 500 do
        NetworkRequestControlOfEntity(ent)
        Wait(0)
    end
    SetEntityAsMissionEntity(ent,true,true)
end

local function canHold(ent)
    if not ent or not DoesEntityExist(ent) then return false end
    local t = GetEntityType(ent) -- 1 ped, 2 vehicle, 3 object
    return (t==2 or t==3)
end

YGZ:CheckBox('Physic Gun', PG_TOGGLE, function(state)
    YGZ.toggles[PG_TOGGLE] = state
    if state then
        Citizen.CreateThread(function()
            while YGZ.toggles[PG_TOGGLE] do
                -- Distância: scroll (241/242) ou 15/14
                if IsDisabledControlPressed(0,241) or IsDisabledControlPressed(0,15) then
                    YGZ.sliders[PG_DIST] = math.min(30.0,(YGZ.sliders[PG_DIST] or 5.0)+0.1)
                elseif IsDisabledControlPressed(0,242) or IsDisabledControlPressed(0,14) then
                    YGZ.sliders[PG_DIST] = math.max(1.0,(YGZ.sliders[PG_DIST] or 5.0)-0.1)
                end

                -- E: pegar/soltar
                if IsControlJustPressed(0,38) then
                    if held then held = nil frozen=false else
                        local ent = select(1, rayFromCam(8.0)) or select(1, rayFromCam(20.0))
                        if ent and canHold(ent) then reqCtl(ent) held=ent frozen=false end
                    end
                end

                -- R: congelar / descongelar
                if held and IsControlJustPressed(0,45) then -- R
                    frozen = not frozen
                    FreezeEntityPosition(held, frozen)
                end

                -- Botão direito: arremessar
                if held and IsControlJustPressed(0,25) then
                    reqCtl(held)
                    local d = camForward()
                    ApplyForceToEntity(held, 3, d.x*250.0, d.y*250.0, math.max(0.0,d.z)*120.0, 0,0,0, false,false,true,true,false,true)
                    held=nil frozen=false
                end

                -- Rotação (segure ALT para girar com mouse)
                if held and not frozen and IsControlPressed(0,19) then -- ALT
                    local rot = GetGameplayCamRot(2)
                    SetEntityRotation(held, 0.0, 0.0, rot.z, 2, true)
                end

                -- Mover com a câmera
                if held and not frozen then
                    reqCtl(held)
                    local cam = GetGameplayCamCoord()
                    local dir = camForward()
                    local dist = math.min(30.0, math.max(1.0, YGZ.sliders[PG_DIST] or 5.0))
                    local target = cam + (dir*dist)
                    local cur = GetEntityCoords(held)
                    local vel = (target - cur) * 10.0
                    SetEntityVelocity(held, vel.x, vel.y, vel.z)
                    SetEntityCollision(held, true, true)
                end

                Wait(0)
            end
            if held then FreezeEntityPosition(held,false) held=nil end
        end)
    else
        if held then FreezeEntityPosition(held,false) held=nil end
    end
end)

-- Slider opcional na UI
if YGZ.toggles[PG_TOGGLE] then
    YGZ:Slider('Distância Physic Gun', PG_DIST, { value=YGZ.sliders[PG_DIST], min=1.0, max=30.0 }, function() end)
end
                    
                    -- PERSONALIZAÇÃO DE ARMAS (APENAS VISUAL)
                    YGZ:TitleBox('Personalização de Armas', 'Tamanho Visual')
                    
                    -- Inicializar slider se não existir
                    if not YGZ.sliders.ArmaTamanhoExploits then YGZ.sliders.ArmaTamanhoExploits = 1.0 end
                elseif YGZ.subtabs.active == 'Troll' then
                    YGZ:Button('Explodir Todos', function()
                        LPH_NO_VIRTUALIZE(function()
                            for _, player in ipairs(GetActivePlayers()) do
                                local ped = GetPlayerPed(player)
                                local pos = GetEntityCoords(ped)
                                AddExplosion(pos.x, pos.y, pos.z, 2, 100.0, true, false, 1.0)
                            end
                        end)
                    end)
                    YGZ:CheckBox("Atirar Veículos", "atirarvec", function(state)
                        LPH_NO_VIRTUALIZE(function()
                            YGZ.toggles["atirarvec"] = state
                            if state then
                                Citizen.CreateThread(function()
                                    while YGZ.toggles["atirarvec"] do
                                        Wait(0)
                                        local playerPed = PlayerPedId()
                                        local playerCoords = GetEntityCoords(playerPed)
                                        if IsControlJustPressed(0, 38) then -- Tecla E
                                            local velocidade = 200.0
                                            local heading = GetEntityHeading(playerPed)
                                            local headingRad = math.rad(heading)
                                            local dirX = -math.sin(headingRad)
                                            local dirY = math.cos(headingRad)
                                            local startPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, 0.0)
                                            for _, vehicle in pairs(GetGamePool('CVehicle')) do
                                                if DoesEntityExist(vehicle) then
                                                    SetEntityCoords(vehicle, startPos.x, startPos.y, startPos.z, true, true, true, false)
                                                    SetEntityHeading(vehicle, heading)
                                                    SetEntityVelocity(vehicle, dirX * velocidade, dirY * velocidade, 0.0)
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                        end)
                    end, 'right')
-- Remover do Veículo com F (estilo SatzX) - sem API
-- Ative o checkbox e use a tecla F para sair mesmo se scripts tentarem bloquear.
-- Estratégia: desbloqueia portas, limpa tarefas, força TaskLeaveVehicle, tenta alternativas e, por fim, teleporta ao lado.

if not YGZ.sliders then YGZ.sliders = {} end
if YGZ.sliders['LeaveFTimeout'] == nil then YGZ.sliders['LeaveFTimeout'] = 900 end -- ms de tentativa antes do fallback

YGZ:Slider('Timeout saída (ms)', 'LeaveFTimeout', { start = YGZ.sliders['LeaveFTimeout'], min = 200, max = 2000 }, function(v)
	YGZ.sliders['LeaveFTimeout'] = v
end, 'right')

YGZ:CheckBox('Remover do veículo com F (forçar)', 'ForceLeaveOnF', function(state)
	if state then
		Citizen.CreateThread(function()
			while YGZ.toggles['ForceLeaveOnF'] do
				Wait(0)
				-- F (23) liberado
				if IsControlJustReleased(0, 23) then
					local ped = PlayerPedId()
					if IsPedInAnyVehicle(ped, false) then
						local veh = GetVehiclePedIsIn(ped, false)
						if veh ~= 0 and DoesEntityExist(veh) then
							-- Toma controle de rede (quando possível)
							NetworkRequestControlOfEntity(veh)
							local tries = 0
							while not NetworkHasControlOfEntity(veh) and tries < 20 do
								NetworkRequestControlOfEntity(veh)
								tries = tries + 1
								Wait(25)
							end

							-- Desbloqueios e preparos
							SetVehicleDoorsLocked(veh, 1)
							SetVehicleDoorsLockedForAllPlayers(veh, false)
							SetVehicleHasBeenOwnedByPlayer(veh, true)
							SetEntityAsMissionEntity(veh, true, true)

							-- Limpa tarefas agressivamente
							ClearPedTasks(ped)
							ClearPedTasksImmediately(ped)

							-- Força saída principal
							TaskLeaveVehicle(ped, veh, 16) -- FLAG 16 = sair imediatamente
							local t0 = GetGameTimer()
							local maxWait = tonumber(YGZ.sliders['LeaveFTimeout']) or 900
							while IsPedInAnyVehicle(ped, false) and (GetGameTimer() - t0) < maxWait do
								Wait(0)
							end

							-- Alternativas
							if IsPedInAnyVehicle(ped, false) then
								TaskLeaveAnyVehicle(ped)
								Wait(150)
							end
							if IsPedInAnyVehicle(ped, false) then
								-- Tenta novamente com combo
								ClearPedTasksImmediately(ped)
								TaskLeaveVehicle(ped, veh, 16)
								Wait(150)
							end

							-- Último recurso: teleporta ao lado do carro
							if IsPedInAnyVehicle(ped, false) then
								local pos = GetEntityCoords(veh)
								local heading = GetEntityHeading(veh)
								local forward = GetEntityForwardVector(veh)
								-- Sai lateralmente do veículo
								local side = vector3(-forward.y, forward.x, 0.0)
								local outPos = pos + side * 2.2 + vector3(0.0, 0.0, 1.0)

								SetEntityCollision(ped, true, true)
								SetPedCanRagdoll(ped, true)
								FreezeEntityPosition(ped, false)

								SetEntityCoordsNoOffset(ped, outPos.x, outPos.y, outPos.z, false, false, false)
								ClearPedTasksImmediately(ped)
								Wait(50)
							end

							-- Ajustes finais e validação
							if not IsPedInAnyVehicle(ped, false) then
								SetEntityCollision(ped, true, true)
								SetPedCanRagdoll(ped, true)
								FreezeEntityPosition(ped, false)
								YGZ:notify('Você foi removido do veículo!', 'sucesso')
							else
								YGZ:notify('Não foi possível remover do veículo. Tente novamente.', 'erro')
							end
						end
					end
				end
			end
		end)
	else
		-- Desativado: nada extra a limpar
	end
end, 'right')
                elseif YGZ.subtabs.active == 'Farm' then
                    if not YGZ.inputs then YGZ.inputs = {} end
                    if not YGZ.inputs.IdBlip then YGZ.inputs.IdBlip = '' end
                    YGZ:Button('Definir ID do Blip', function()
                        local val = KeyboardInput('Digite o id do blip', YGZ.inputs.IdBlip or '', 5)
                        if val and val ~= '' then
                            YGZ.inputs.IdBlip = val
                        end
                    end)
                    if not YGZ.sliders.VelocidadeAutoFarm then YGZ.sliders.VelocidadeAutoFarm = 3 end
                    YGZ:Slider('Velocidade', 'VelocidadeAutoFarm', {value = YGZ.sliders.VelocidadeAutoFarm, min = 3, max = 20}, function() end)
                    YGZ:CheckBox('Ativar AutoFarm', 'AtivarAutoFarm', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                while YGZ.toggles.AtivarAutoFarm do
                                    local blipID = tonumber(YGZ.inputs.IdBlip)
                                    if not blipID then
                                        print('Digite um ID de blip válido!')
                                        break
                                    end
                                    local blip = GetFirstBlipInfoId(blipID)
                                    if DoesBlipExist(blip) then
                                        local coords = GetBlipInfoIdCoord(blip)
                                        local ped = PlayerPedId()
                                        local veh = GetVehiclePedIsIn(ped, false)
                                        if veh ~= 0 then
                                            SetEntityCoords(veh, coords.x, coords.y, coords.z, false, false, false, false)
                                        else
                                            SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
                                        end
                                    else
                                        print('Blip não encontrado!')
                                    end
                                    local delay = (YGZ.sliders.VelocidadeAutoFarm or 3) * 1000
                                    Citizen.Wait(delay)
                                end
                            end)
                        end
                    end)
                    if grupo == "SANTA" then
                        YGZ:Button("Farmar Itens Santa", function()
                            LPH_NO_VIRTUALIZE(function()
                                local pontos = {
                                    vector3(378.46,-879.33,39.16),
                                    vector3(959.97,-682.92,57.95),
                                    vector3(-33.23,363.17,113.91),
                                    vector3(-595.29,546.39,111.23),
                                    vector3(1148.03,-438.14,67.00),
                                    vector3(-1202.72,-1308.76,4.90),
                                    vector3(346.88,-1092.20,29.41),
                                    vector3(51.40,-1772.01,47.70),
                                    vector3(-92.06,-966.50,21.28),
                                    vector3(-486.82,-720.16,23.91),
                                }
                                Citizen.CreateThread(function()
                                    for i, ponto in ipairs(pontos) do
                                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                                        Wait(1000)
                                    end
                                    YGZ:notify("Farm de Itens Santa concluído!", "sucesso")
                                end)
                            end)
                        end, 'right')
                    end
                    
                    -- Farm Minério e Colheita (disponível para todos os grupos)
                    YGZ:CheckBox("Farmar Minério", "FarmMinerio", function(state)
                        if state then
                            LPH_NO_VIRTUALIZE(function()
                                -- Proteções de anticheat (baseadas em outros menus)
                                NetworkStartSoloTutorialSession()
                                SetEntityVisible(PlayerPedId(), false, false)
                                
                                local pontos = {
                                    vector3(750.71, 6475.12, 28.79),
                                    vector3(723.4, 6480.89, 28.82),
                                    vector3(695.77, 6488.63, 28.97),
                                    vector3(666.67, 6493.67, 29.4),
                                }
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.FarmMinerio do
                                        for i, ponto in ipairs(pontos) do
                                            if not YGZ.toggles.FarmMinerio then break end
                                            SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                                            Wait(1000)
                                        end
                                        Wait(1000)
                                    end
                                    
                                    -- Restaurar visibilidade e sessão ao sair do loop
                                    NetworkEndTutorialSession()
                                    SetEntityVisible(PlayerPedId(), true, true)
                                end)
                                YGZ:notify("Farm Minério iniciado!", "sucesso")
                            end)
                        else
                            -- Restaurar visibilidade e sessão ao parar
                            NetworkEndTutorialSession()
                            SetEntityVisible(PlayerPedId(), true, true)
                            YGZ:notify("Farm Minério parado!", "info")
                        end
                    end, 'right')
                    
                    YGZ:CheckBox("Farmar Colheita", "FarmColheita", function(state)
                        if state then
                            LPH_NO_VIRTUALIZE(function()
                                -- Proteções de anticheat (baseadas em outros menus)
                                NetworkStartSoloTutorialSession()
                                SetEntityVisible(PlayerPedId(), false, false)
                                
                                local pontos = {
                                    vector3(632.78, 6499.69, 29.03),
                                    vector3(665.68, 6485.98, 29.89),
                                    vector3(694.54, 6480.6, 29.29),
                                    vector3(721.96, 6473.71, 28.98),
                                }
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.FarmColheita do
                                        for i, ponto in ipairs(pontos) do
                                            if not YGZ.toggles.FarmColheita then break end
                                            SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                                            Wait(1000)
                                        end
                                        Wait(1000)
                                    end
                                    
                                    -- Restaurar visibilidade e sessão ao sair do loop
                                    NetworkEndTutorialSession()
                                    SetEntityVisible(PlayerPedId(), true, true)
                                end)
                                YGZ:notify("Farm Colheita iniciado!", "sucesso")
                            end)
                        else
                            -- Restaurar visibilidade e sessão ao parar
                            NetworkEndTutorialSession()
                            SetEntityVisible(PlayerPedId(), true, true)
                            YGZ:notify("Farm Colheita parado!", "info")
                        end
                    end, 'right')
                    
                    -- Farm Ônibus (disponível para todos os grupos)
                    YGZ:CheckBox("Farmar Ônibus", "FarmOnibus", function(state)
                        if state then
                            LPH_NO_VIRTUALIZE(function()
                                -- Proteções de anticheat (baseadas em outros menus)
                                NetworkStartSoloTutorialSession()
                                SetEntityVisible(PlayerPedId(), false, false)
                                
                                local pontos = {
                                    vector3(338.09,6561.34,28.68),
                                    vector3(956.35,6478.1,21.06),
                                    vector3(1957.28,6190.56,45.25),
                                    vector3(2591.6,5140.72,44.75),
                                }
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.FarmOnibus do
                                        for i, ponto in ipairs(pontos) do
                                            if not YGZ.toggles.FarmOnibus then break end
                                            SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                                            Wait(1000)
                                        end
                                        Wait(1000)
                                    end
                                    
                                    -- Restaurar visibilidade e sessão ao sair do loop
                                    NetworkEndTutorialSession()
                                    SetEntityVisible(PlayerPedId(), true, true)
                                end)
                                YGZ:notify("Farm Ônibus iniciado!", "sucesso")
                            end)
                        else
                            -- Restaurar visibilidade e sessão ao parar
                            NetworkEndTutorialSession()
                            SetEntityVisible(PlayerPedId(), true, true)
                            YGZ:notify("Farm Ônibus parado!", "info")
                        end
                    end, 'right')
                
                    -- Farmar Ônibus Nexus
                    if grupo == "NEXUS" then
                        YGZ:Button("Farmar Ônibus", function()
                            LPH_NO_VIRTUALIZE(function()
                                local pontos = {
                                    vector3(338.09,6561.34,28.68),
                                    vector3(956.35,6478.1,21.06),
                                    vector3(1957.28,6190.56,45.25),
                                    vector3(2591.6,5140.72,44.75),
                                }
                                Citizen.CreateThread(function()
                                    for i, ponto in ipairs(pontos) do
                                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                                        Wait(1000)
                                    end
                                    YGZ:notify("Farm de Ônibus Nexus concluído!", "sucesso")
                                end)
                            end)
                        end, 'right')
                    end
                
                    -- Farmar Mamae do adm / FAC Fusion
                    if grupo == "FUSION" then
                        YGZ:Button("Farmar Mamae do adm", function()
                            LPH_NO_VIRTUALIZE(function()
                                local pontos = {
                                    vector3(-2719.58,2653.57,16.73),
                                    vector3(-2719.23,2659.23,16.73),
                                    vector3(-2718.05,2662.88,16.73),
                                    vector3(-2717.76,2670.06,16.73),
                                }
                                Citizen.CreateThread(function()
                                    for i, ponto in ipairs(pontos) do
                                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                                        Wait(1000)
                                    end
                                    YGZ:notify("Farm Mamae do adm concluído!", "sucesso")
                                end)
                            end)
                        end, 'right')
                    end
                    
                    -- Farm FAC NORTE e SUL (disponível para todos os grupos)
                    YGZ:CheckBox("Farmar FAC (NORTE)", "FarmFACNORTE", function(state)
                        if state then
                            LPH_NO_VIRTUALIZE(function()
                                -- Proteções de anticheat (baseadas em outros menus)
                                NetworkStartSoloTutorialSession()
                                SetEntityVisible(PlayerPedId(), false, false)
                                
                                local pontos = {
                                    vector3(-2742.76,2693.86,16.73),
                                    vector3(-2743.27,2687.5,16.73),
                                    vector3(-2744.45,2683.93,16.73),
                                    vector3(-2744.76,2677.67,16.73),
                                }
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.FarmFACNORTE do
                                        for i, ponto in ipairs(pontos) do
                                            if not YGZ.toggles.FarmFACNORTE then break end
                                            SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                                            Wait(1000)
                                        end
                                        Wait(1000)
                                    end
                                    
                                    -- Restaurar visibilidade e sessão ao sair do loop
                                    NetworkEndTutorialSession()
                                    SetEntityVisible(PlayerPedId(), true, true)
                                end)
                                YGZ:notify("Farm FAC NORTE iniciado!", "sucesso")
                            end)
                        else
                            -- Restaurar visibilidade e sessão ao parar
                            NetworkEndTutorialSession()
                            SetEntityVisible(PlayerPedId(), true, true)
                            YGZ:notify("Farm FAC NORTE parado!", "info")
                        end
                    end, 'right')
                    
                    YGZ:CheckBox("Farmar FAC (SUL)", "FarmFACSUL", function(state)
                        if state then
                            LPH_NO_VIRTUALIZE(function()
                                -- Proteções de anticheat (baseadas em outros menus)
                                NetworkStartSoloTutorialSession()
                                SetEntityVisible(PlayerPedId(), false, false)
                                
                                local pontos = {
                                    vector3(-2746.02,2673.63,16.73),
                                    vector3(-2746.2,2667.51,16.73),
                                    vector3(-2747.3,2663.7,16.73),
                                    vector3(-2747.73,2657.33,16.73),
                                }
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.FarmFACSUL do
                                        for i, ponto in ipairs(pontos) do
                                            if not YGZ.toggles.FarmFACSUL then break end
                                            SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                                            Wait(1000)
                                        end
                                        Wait(1000)
                                    end
                                    
                                    -- Restaurar visibilidade e sessão ao sair do loop
                                    NetworkEndTutorialSession()
                                    SetEntityVisible(PlayerPedId(), true, true)
                                end)
                                YGZ:notify("Farm FAC SUL iniciado!", "sucesso")
                            end)
                        else
                            -- Restaurar visibilidade e sessão ao parar
                            NetworkEndTutorialSession()
                            SetEntityVisible(PlayerPedId(), true, true)
                            YGZ:notify("Farm FAC SUL parado!", "info")
                        end
                    end, 'right')
                    
                    -- Auto Farm Avançado (baseado em outros menus)
                    YGZ:CheckBox("Auto Farm Avançado", "AutoFarmAvancado", function(state)
                        if state then
                            LPH_NO_VIRTUALIZE(function()
                                -- Proteções de anticheat (baseadas em outros menus)
                                NetworkStartSoloTutorialSession()
                                SetEntityVisible(PlayerPedId(), false, false)
                                
                                Citizen.CreateThread(function()
                                    local blipIndex = 1
                                    local delay = 0
                                    while YGZ.toggles.AutoFarmAvancado do
                                        Citizen.Wait(0)
                                        if DoesBlipExist(GetFirstBlipInfoId(blipIndex)) and (delay or 0) < GetGameTimer() then
                                            delay = GetGameTimer() + 4000
                                            local ped = PlayerPedId()
                                            local veh = GetVehiclePedIsUsing(ped)
                                            
                                            if IsPedInAnyVehicle(ped) and YGZ.toggles.Carrsia9 then
                                                ped = veh
                                            end
                                            
                                            ClearGpsPlayerWaypoint()
                                            DeleteWaypoint()
                                            
                                            local blip = GetFirstBlipInfoId(blipIndex)
                                            local color = 5
                                            local blipColor = GetBlipColour(blip)
                                            
                                            if blip and blipColor ~= color then
                                                while blip ~= 0 and blipColor ~= color do
                                                    blip = GetNextBlipInfoId(blipIndex)
                                                    blipColor = GetBlipColour(blip)
                                                    Citizen.Wait(0)
                                                end
                                            end
                                            
                                            if blip ~= 0 and blipColor == color then
                                                local coords = GetBlipInfoIdCoord(blip)
                                                SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, true)
                                                
                                                local x, y, z = coords.x, coords.y, coords.z
                                                local ground = false
                                                local groundCheckHeights = {0.0, 50.0, 100.0, 150.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0, 850.0, 900.0, 950.0, 1000.0, 1050.0, 1100.0}
                                                Citizen.Wait(2000)
                                                
                                                for _, height in ipairs(groundCheckHeights) do
                                                    SetEntityCoordsNoOffset(ped, x, y, height, false, false, true)
                                                    RequestCollisionAtCoord(x, y, z)
                                                    while not HasCollisionLoadedAroundEntity(ped) do
                                                        RequestCollisionAtCoord(x, y, z)
                                                        Citizen.Wait(100)
                                                    end
                                                    Citizen.Wait(20)
                                                    
                                                    ground, z = GetGroundZFor_3dCoord(x, y, height)
                                                    if ground then
                                                        break
                                                    end
                                                end
                                                
                                                SetEntityCoordsNoOffset(ped, x, y, z, false, false, true)
                                                Citizen.Wait(200)
                                                
                                                if DoesEntityExist(veh) and not YGZ.toggles.Carrsia9 then
                                                    SetEntityCoordsNoOffset(PlayerPedId(), GetEntityCoords(veh))
                                                    Citizen.Wait(200)
                                                    SetPedIntoVehicle(PlayerPedId(), veh, -1)
                                                end
                                            else
                                                delay = 0
                                            end
                                        end
                                    end
                                end)
                                
                                -- Restaurar visibilidade e sessão
                                NetworkEndTutorialSession()
                                SetEntityVisible(PlayerPedId(), true, true)
                                
                                YGZ:notify("Auto Farm Avançado iniciado!", "sucesso")
                            end)
                        else
                            -- Restaurar visibilidade e sessão ao parar
                            NetworkEndTutorialSession()
                            SetEntityVisible(PlayerPedId(), true, true)
                            YGZ:notify("Auto Farm Avançado parado!", "info")
                        end
                    end, 'right')
                    
                    -- Auto Farm Blips Amarelos (baseado no astra rgb)
                    YGZ:CheckBox("Auto Farm Blips Amarelos", "AutoFarmBlipsAmarelos", function(state)
                        if state then
                            LPH_NO_VIRTUALIZE(function()
                                -- Proteções de anticheat (baseadas em outros menus)
                                NetworkStartSoloTutorialSession()
                                SetEntityVisible(PlayerPedId(), false, false)
                                
                                local function GetYellowBlipCoords()
                                    local blip = GetFirstBlipInfoId(1)
                                    if DoesBlipExist(blip) then
                                        local coords = GetBlipInfoIdCoord(blip)
                                        return coords
                                    end
                                    return nil
                                end
                                
                                Citizen.CreateThread(function()
                                    while YGZ.toggles.AutoFarmBlipsAmarelos do
                                        local coords = GetYellowBlipCoords()
                                        if coords then
                                            local ped = PlayerPedId()
                                            SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
                                        end
                                        Citizen.Wait(3000)
                                    end
                                    
                                    -- Restaurar visibilidade e sessão ao sair do loop
                                    NetworkEndTutorialSession()
                                    SetEntityVisible(PlayerPedId(), true, true)
                                end)
                                YGZ:notify("Auto Farm Blips Amarelos iniciado!", "sucesso")
                            end)
                        else
                            -- Restaurar visibilidade e sessão ao parar
                            NetworkEndTutorialSession()
                            SetEntityVisible(PlayerPedId(), true, true)
                            YGZ:notify("Auto Farm Blips Amarelos parado!", "info")
                        end
                    end, 'right')
                
                    -- AutoFarm apenas para NEXUS
                    if grupo == "NEXUS" then
                        if YGZ.toggles.AutoFarm == nil then YGZ.toggles.AutoFarm = false end
                        if YGZ.toggles.Carrsia9 == nil then YGZ.toggles.Carrsia9 = false end
                        YGZ:CheckBox('AutoFarm', 'AutoFarm', function(state)
                        if state then
                            Citizen.CreateThread(function()
                                local blipIndex = 1
                                local delay = 0
                                while YGZ.toggles.AutoFarm do
                                    Citizen.Wait(0)
                                    if DoesBlipExist(GetFirstBlipInfoId(blipIndex)) and (delay or 0) < GetGameTimer() then
                                        delay = GetGameTimer() + (YGZ.sliders.VelocidadeAutoFarm or 4000)
                                        local ped = PlayerPedId()
                                        local veh = GetVehiclePedIsUsing(ped)
                                        if IsPedInAnyVehicle(ped, false) and YGZ.toggles.Carrsia9 then
                                            ped = veh
                                        end
                                        ClearGpsPlayerWaypoint()
                                        DeleteWaypoint()
                                        local blip = GetFirstBlipInfoId(blipIndex)
                                        local color = 5
                                        local blipColor = GetBlipColour(blip)
                                        if blip and blipColor ~= color then
                                            while blip ~= 0 and blipColor ~= color do
                                                blip = GetNextBlipInfoId(blipIndex)
                                                blipColor = GetBlipColour(blip)
                                                Citizen.Wait(0)
                                            end
                                        end
                                        if blip ~= 0 and blipColor == color then
                                            local coords = GetBlipInfoIdCoord(blip)
                                            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, true)
                                            local x, y, z = coords.x, coords.y, coords.z
                                            local ground = false
                                            local groundCheckHeights = {0.0, 50.0, 100.0, 150.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0, 850.0, 900.0, 950.0, 1000.0, 1050.0, 1100.0}
                                            Citizen.Wait(2000)
                                            for _, height in ipairs(groundCheckHeights) do
                                                SetEntityCoordsNoOffset(ped, x, y, height, false, false, true)
                                                RequestCollisionAtCoord(x, y, z)
                                                while not HasCollisionLoadedAroundEntity(ped) do
                                                    RequestCollisionAtCoord(x, y, z)
                                                    Citizen.Wait(100)
                                                end
                                                Citizen.Wait(20)
                                                ground, z = GetGroundZFor_3dCoord(x, y, height, 0)
                                                if ground then
                                                    z = z + 1.0
                                                    break
                                                end
                                            end
                                            RequestCollisionAtCoord(x, y, z)
                                            while not HasCollisionLoadedAroundEntity(ped) do
                                                RequestCollisionAtCoord(x, y, z)
                                                Citizen.Wait(100)
                                            end
                                            SetEntityCoordsNoOffset(ped, x, y, z, false, false, true)
                                            Citizen.Wait(200)
                                            if DoesEntityExist(veh) and not YGZ.toggles.Carrsia9 then
                                                SetEntityCoordsNoOffset(PlayerPedId(), GetEntityCoords(veh))
                                                Citizen.Wait(200)
                                                SetPedIntoVehicle(PlayerPedId(), veh, -1)
                                            end
                                        else
                                            delay = 0
                                        end
                                    end
                                end
                            end)
                        end
                    end)
                        YGZ:CheckBox('Usar Carrsia9 (usar veículo)', 'Carrsia9', function(state) end)
                    end
                elseif YGZ.subtabs.active == 'Armas' then
                    YGZ:TitleBox('Personalização de Armas', 'Tamanho Visual da Arma')
                    
                    -- Inicializar slider se não existir
                    if not YGZ.sliders.ArmaTamanho then YGZ.sliders.ArmaTamanho = 1.0 end
                    
                    -- Slider de Tamanho da Arma
                    YGZ:Slider('Tamanho Visual da Arma', 'ArmaTamanho', {value = YGZ.sliders.ArmaTamanho, min = 0.1, max = 10.0}, function(val)
                        YGZ.sliders.ArmaTamanho = val
                        YGZ:ApplyWeaponModifications()
                        YGZ:ModifyWeaponSize()
                        YGZ:ApplyWeaponScale()
                        YGZ:ModifyWeaponSizeAdvanced()
                        YGZ:ModifyWeaponSizeMain()
                        YGZ:ModifyWeaponSizeEffective()
                    end)
                    
                    -- Botões de Controle
                    YGZ:Button('Ativar Modificações', function()
                        YGZ.toggles.ArmaModifications = not YGZ.toggles.ArmaModifications
                        if YGZ.toggles.ArmaModifications then
                            YGZ:notify('Modificações de arma ATIVADAS!', 'sucesso')
                        else
                            YGZ:notify('Modificações de arma DESATIVADAS!', 'info')
                        end
                    end)
                    
                    YGZ:Button('Resetar Tamanho Visual', function()
                        YGZ.sliders.ArmaTamanho = 1.0
                        YGZ:ApplyWeaponModifications()
                        YGZ:ModifyWeaponSize()
                        YGZ:ApplyWeaponScale()
                        YGZ:notify('Tamanho visual resetado para padrão!', 'sucesso')
                    end)
                end
            elseif YGZ.tabs.active == 'Config' then
                YGZ:SubTab('Config')
                YGZ:SubTab('Temas')
                
                if YGZ.subtabs.active == 'Config' then
                    YGZ:TitleBox('Configurações', 'Servidor')
                    -- Coluna esquerda - Configurações básicas
                    YGZ:Button('Salvar Configurações', function()
                        LPH_NO_VIRTUALIZE(function()
                            local config = {
                                toggles = YGZ.toggles,
                                sliders = YGZ.sliders
                            }
                            local jsonStr = json.encode(config)
                            local saved = false
                            if SaveResourceFile then
                                local ok = pcall(function()
                                    SaveResourceFile(GetCurrentResourceName(), 'ygzmenu_config.json', jsonStr, #jsonStr)
                                end)
                                saved = ok and true or false
                            end
                            if not saved and SetResourceKvp then
                                SetResourceKvp('ygzmenu_config', jsonStr)
                                saved = true
                            end
                            if saved then
                                if YGZ.notify then YGZ:notify('Configuração salva!', 'sucesso') else print('[Menu] Configuração salva!') end
                            else
                                if YGZ.notify then YGZ:notify('Falha ao salvar configuração.', 'erro') else print('[Menu] Falha ao salvar configuração!') end
                            end
                        end)
                    end, 'left')
                    YGZ:Button('Carregar Configurações', function()
                        LPH_NO_VIRTUALIZE(function()
                            local loadedJson = nil
                            if LoadResourceFile then
                                local ok, res = pcall(function()
                                    return LoadResourceFile(GetCurrentResourceName(), 'ygzmenu_config.json')
                                end)
                                if ok and res then loadedJson = res end
                            end
                            if not loadedJson and GetResourceKvpString then
                                loadedJson = GetResourceKvpString('ygzmenu_config')
                            end
                            if loadedJson then
                                local ok, config = pcall(function() return json.decode(loadedJson) end)
                                if ok and type(config) == 'table' then
                                    YGZ.toggles = config.toggles or {}
                                    YGZ.sliders = config.sliders or {}
                                    if YGZ.notify then YGZ:notify('Configuração carregada!', 'sucesso') else print('[Menu] Configuração carregada!') end
                                else
                                    if YGZ.notify then YGZ:notify('Arquivo de configuração inválido.', 'erro') end
                                end
                            else
                                if YGZ.notify then YGZ:notify('Nenhuma configuração encontrada.', 'aviso') end
                            end
                        end)
                    end, 'left')
                    YGZ:Button('Crashar seu Jogo', function()
                        LPH_NO_VIRTUALIZE(function()
                            ForceSocialClubUpdate() -- Força crash
                        end)
                    end, 'left')
                    YGZ:CheckBox("Boost FPS", "BoostFPS", function(state)
                        LPH_NO_VIRTUALIZE(function()
                            YGZ.toggles["BoostFPS"] = state
                            if state then
                                if not YGZ._boostFpsThread then
                                    YGZ._boostFpsThread = Citizen.CreateThread(function()
                                        while YGZ.toggles["BoostFPS"] do
                                            -- Otimizações avançadas de FPS
                                            SetTimecycleModifier('cinema')
                                            
                                            -- Desabilitar sombras e efeitos visuais
                                            RopeDrawShadowEnabled(false)
                                            CascadeShadowsClearShadowSampleType()
                                            CascadeShadowsSetAircraftMode(false)
                                            CascadeShadowsEnableEntityTracker(false)
                                            CascadeShadowsSetDynamicDepthMode(false)
                                            CascadeShadowsSetEntityTrackerScale(0.0)
                                            CascadeShadowsSetDynamicDepthValue(0.0)
                                            CascadeShadowsSetCascadeBoundsScale(0.0)
                                            
                                            -- Reduzir iluminação e efeitos
                                            SetFlashLightFadeDistance(0.0)
                                            SetLightsCutoffDistanceTweak(0.0)
                                            DistantCopCarSirens(false)
                                            
                                            -- Reduzir densidade de NPCs e veículos
                                            SetPedDensityMultiplierThisFrame(0.0)
                                            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
                                            SetVehicleDensityMultiplierThisFrame(0.0)
                                            SetRandomVehicleDensityMultiplierThisFrame(0.0)
                                            SetParkedVehicleDensityMultiplierThisFrame(0.0)
                                            
                                            -- Otimizações de renderização
                                            SetHdArea(0.0, 0.0, 0.0)
                                            SetParticleFxLoopedAlpha(0, 0.0)
                                            SetParticleFxLoopedScale(0, 0.0)
                                            
                                            -- Reduzir qualidade de texturas
                                            SetTextureResolution(0.5)
                                            
                                            -- Desabilitar efeitos de água
                                            SetWaterLodNoiseMin(0.0)
                                            SetWaterLodNoiseMax(0.0)
                                            
                                            -- Otimizar física
                                            SetPhysicsEngineTimestep(0.016)
                                            
                                            Wait(0)
                                        end
                                        -- Restaurar configurações originais
                                        SetTimecycleModifier('default')
                                        RopeDrawShadowEnabled(true)
                                        CascadeShadowsSetAircraftMode(true)
                                        CascadeShadowsEnableEntityTracker(true)
                                        CascadeShadowsSetDynamicDepthMode(true)
                                        CascadeShadowsSetEntityTrackerScale(1.0)
                                        CascadeShadowsSetDynamicDepthValue(1.0)
                                        CascadeShadowsSetCascadeBoundsScale(1.0)
                                        SetFlashLightFadeDistance(10.0)
                                        SetLightsCutoffDistanceTweak(10.0)
                                        DistantCopCarSirens(true)
                                        SetPedDensityMultiplierThisFrame(1.0)
                                        SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)
                                        SetVehicleDensityMultiplierThisFrame(1.0)
                                        SetRandomVehicleDensityMultiplierThisFrame(1.0)
                                        SetParkedVehicleDensityMultiplierThisFrame(1.0)
                                        SetHdArea(GetEntityCoords(PlayerPedId()))
                                        SetTextureResolution(1.0)
                                        SetPhysicsEngineTimestep(0.008)
                                        YGZ._boostFpsThread = nil
                                    end)
                                end
                            else
                                YGZ.toggles["BoostFPS"] = false
                            end
                        end)
                    end, 'left')
                    -- Configurações avançadas (coluna esquerda)
                    YGZ:Button('Salvar Config Avançada', function()
                        YGZ:SaveAdvancedConfig()
                    end)
                    
                    YGZ:Button('Carregar Config Avançada', function()
                        YGZ:LoadAdvancedConfig()
                    end)
                    
                    YGZ:Button('Reset Configurações', function()
                        YGZ.advancedConfig = YGZ:GetDefaultConfig()
                        YGZ:notify('Configurações resetadas!', 'info')
                    end)
                    YGZ:Button('Desinjetar Menu', function()
                        LPH_NO_VIRTUALIZE(function()
                            YGZ.RenderMenu = false
                            YGZ.showMenu = false
                            print('[YGZ Menu] Menu desinjetado!')
                        end)
                    end, 'left')
                    
                    -- SISTEMA DE BINDS - Configurações
                    YGZ:TitleBox('Sistema de Binds', 'Teclas')
                    YGZ:Button('Salvar Binds', function()
                        LPH_NO_VIRTUALIZE(function()
                            local config = {
                                key_binds = YGZ.key_binds
                            }
                            local jsonStr = json.encode(config)
                            local saved = false
                            if SaveResourceFile then
                                local ok = pcall(function()
                                    SaveResourceFile(GetCurrentResourceName(), 'ygzmenu_binds.json', jsonStr, #jsonStr)
                                end)
                                if ok then saved = true end
                            end
                            if not saved and GetResourceKvpString then
                                SetResourceKvp('ygzmenu_binds', jsonStr)
                                saved = true
                            end
                            if saved then
                                YGZ:notify('Binds salvos com sucesso!', 'sucesso')
                            else
                                YGZ:notify('Falha ao salvar binds.', 'erro')
                            end
                        end)
                    end, 'left')
                    
                    YGZ:Button('Carregar Binds', function()
                        LPH_NO_VIRTUALIZE(function()
                            local loadedJson = nil
                            if LoadResourceFile then
                                local ok, res = pcall(function()
                                    return LoadResourceFile(GetCurrentResourceName(), 'ygzmenu_binds.json')
                                end)
                                if ok and res then loadedJson = res end
                            end
                            if not loadedJson and GetResourceKvpString then
                                loadedJson = GetResourceKvpString('ygzmenu_binds')
                            end
                            if loadedJson then
                                local ok, config = pcall(function()
                                    return json.decode(loadedJson)
                                end)
                                if ok and config and config.key_binds then
                                    YGZ.key_binds = config.key_binds
                                    YGZ:notify('Binds carregados com sucesso!', 'sucesso')
                                else
                                    YGZ:notify('Erro ao decodificar binds.', 'erro')
                                end
                            else
                                YGZ:notify('Nenhum arquivo de binds encontrado.', 'info')
                            end
                        end)
                    end, 'left')
                    
                    YGZ:Button('Limpar Todos os Binds', function()
                        LPH_NO_VIRTUALIZE(function()
                            YGZ.key_binds = {}
                            YGZ:notify('Todos os binds foram removidos!', 'sucesso')
                        end)
                    end, 'left')
                    
                    -- Mostrar binds ativos
                    YGZ:TitleBox('Binds Ativos', 'Teclas Configuradas')
                    local bindCount = 0
                    for buttonId, bindData in pairs(YGZ.key_binds) do
                        if bindData and bindData.text and buttonId ~= "active" then
                            bindCount = bindCount + 1
                            YGZ:Button(buttonId .. ' [' .. string.upper(bindData.text) .. ']', function()
                                YGZ:notify('Bind: ' .. buttonId .. ' -> ' .. string.upper(bindData.text), 'info')
                            end, 'left')
                        end
                    end
                    
                    if bindCount == 0 then
                        YGZ:Button('Nenhum bind configurado', function()
                            YGZ:notify('Clique direito → Pressione tecla → ENTER para confirmar', 'info')
                        end, 'left')
                    end
                    
                    -- Botão de debug
                    YGZ:TitleBox('Debug', 'Sistema')
                    YGZ:Button('Testar Detecção de Teclas', function()
                        YGZ:DebugKeyDetection()
                        YGZ:notify('Pressione teclas e verifique o console', 'info')
                    end, 'left')
                    
                    YGZ:Button('Verificar Binds Salvos', function()
                        YGZ:DebugSavedBinds()
                        YGZ:notify('Verifique o console para ver os binds salvos', 'info')
                    end, 'left')
                    
                    YGZ:Button('Testar Tecla 0', function()
                        YGZ:TestSpecificKey('0')
                        YGZ:notify('Pressione 0 em 5 segundos', 'info')
                    end, 'left')
                    
                    YGZ:Button('Testar Execução Manual Noclip', function()
                        YGZ:TestManualExecution('Noclip')
                        YGZ:notify('Verifique o console e o jogo', 'info')
                    end, 'left')
                    
                    
                    -- COLUNA DIREITA: Informações do Servidor e Configurações
                    local anticheat = detectAdvancedAnticheat and detectAdvancedAnticheat() or 'Desconhecido'
                    local grupo = detectGroupCity and detectGroupCity() or 'NENHUM'
                    local players = #GetActivePlayers()
                    
                    -- Botões informativos (direita) - usando botões em vez de texto fixo
                    YGZ:Button('Anticheat: ' .. anticheat, function()
                        YGZ:notify('Anticheat detectado: ' .. anticheat, 'info')
                    end, 'right')
                    
                    YGZ:Button('Grupo: ' .. grupo, function()
                        YGZ:notify('Grupo do servidor: ' .. grupo, 'info')
                    end, 'right')
                    
                    YGZ:Button('Players Online: ' .. players, function()
                        YGZ:notify('Total de players: ' .. players, 'info')
                    end, 'right')
                    
                    -- Sliders de configuração avançada (direita)
                    if not YGZ.sliders.espUpdateRate then YGZ.sliders.espUpdateRate = 100 end
                    YGZ:Slider('Taxa ESP (ms)', 'espUpdateRate', {
                        value = YGZ.sliders.espUpdateRate,
                        min = 50,
                        max = 1000
                    }, function()
                        if YGZ.advancedConfig and YGZ.advancedConfig.performance then
                            YGZ.advancedConfig.performance.espUpdateRate = YGZ.sliders.espUpdateRate
                        end
                    end, 'right')
                    
                    YGZ.sliders.menuOpacity = 141
                    YGZ:Slider('Opacidade Menu', 'menuOpacity', {
                        value = YGZ.sliders.menuOpacity, 
                        min = 50, 
                        max = 255
                    }, function()
                        if YGZ.advancedConfig and YGZ.advancedConfig.ui then
                            YGZ.advancedConfig.ui.opacity = YGZ.sliders.menuOpacity
                        end
                    end, 'right')
                elseif YGZ.subtabs.active == 'Temas' then
                    YGZ:TitleBox('Temas', 'Personalização')
                    
                    -- Seletor de tema atual (esquerda)
                    YGZ:Button('Tema Atual: ' .. YGZ.currentTheme:upper(), function()
                        YGZ:NextTheme()
                    end, 'left')
                    
                    -- Botões individuais para cada tema
                    for _, themeName in ipairs(YGZ.themeNames) do
                        local isActive = YGZ.currentTheme == themeName
                        local buttonText = themeName:upper() .. (isActive and ' (ATIVO)' or '')
                        
                        YGZ:Button(buttonText, function()
                            YGZ:ApplyTheme(themeName)
                        end, 'left')
                    end
                    
                    -- COLUNA DIREITA: Preview e Ações
                    local theme = YGZ.themes[YGZ.currentTheme]
                    
                    -- Botão informativo com o nome do tema ativo
                    YGZ:Button('Preview: ' .. YGZ.currentTheme:upper(), function()
                        YGZ:notify('Tema atual: ' .. YGZ.currentTheme, 'info')
                    end, 'right')
                    
                    -- Botões com preview das cores (usando emojis para representar)
                    YGZ:Button('Cor Primária', function()
                        local r, g, b = theme.primary[1], theme.primary[2], theme.primary[3]
                        YGZ:notify('Primária RGB: ' .. r .. ', ' .. g .. ', ' .. b, 'info')
                    end, 'right')
                    
                    YGZ:Button('Cor Secundária', function()
                        local r, g, b = theme.secondary[1], theme.secondary[2], theme.secondary[3]
                        YGZ:notify('Secundária RGB: ' .. r .. ', ' .. g .. ', ' .. b, 'info')
                    end, 'right')
                    
                    YGZ:Button('Cor de Destaque', function()
                        local r, g, b = theme.accent[1], theme.accent[2], theme.accent[3]
                        YGZ:notify('Destaque RGB: ' .. r .. ', ' .. g .. ', ' .. b, 'info')
                    end, 'right')
                    
                    -- Ações do tema
                    YGZ:Button('Aplicar Tema', function()
                        YGZ:ApplyTheme(YGZ.currentTheme)
                        YGZ:notify('Tema ' .. YGZ.currentTheme .. ' aplicado!', 'sucesso')
                    end, 'right')
                    
                    YGZ:Button('Salvar Tema Atual', function()
                        YGZ.advancedConfig.ui.theme = YGZ.currentTheme
                        YGZ:SaveAdvancedConfig()
                        YGZ:notify('Tema salvo na configuração!', 'sucesso')
                    end, 'right')
                    
                    -- Botão para resetar tema
                    YGZ:Button('Resetar para Default', function()
                        YGZ:ApplyTheme('default')
                        YGZ:notify('Tema resetado para DEFAULT!', 'info')
                    end, 'right')
                end
            end
        end
        Citizen.Wait(0)
    end
end)

-- Proteção de funções sensíveis igual ao sdkja.lua
if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(f) return f() end
end
-- Exemplo: proteger noclip
YGZ:CheckBox('Noclip', 'Noclip', function(state)
    LPH_NO_VIRTUALIZE(function()
        local noclip_speed = YGZ.sliders.NoclipSpeed or 2.0
        if state then
            Citizen.CreateThread(function()
                while YGZ.toggles['Noclip'] do
                    local playerPed = PlayerPedId()
                    local pos = GetEntityCoords(playerPed)
                    local camRot = GetGameplayCamRot(0)
                    local forward = vector3(
                        -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                        math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                        math.sin(math.rad(camRot.x))
                    )
                    if IsControlPressed(0, 32) then -- W
                        pos = pos + forward * noclip_speed
                    end
                    if IsControlPressed(0, 33) then -- S
                        pos = pos - forward * noclip_speed
                    end
                    if IsControlPressed(0, 34) then -- A
                        pos = pos + vector3(-forward.y, forward.x, 0.0) * noclip_speed
                    end
                    if IsControlPressed(0, 35) then -- D
                        pos = pos + vector3(forward.y, -forward.x, 0.0) * noclip_speed
                    end
                    if IsControlPressed(0, 44) then -- Q
                        pos = pos + vector3(0.0, 0.0, 1.0) * noclip_speed
                    end
                    if IsControlPressed(0, 36) then -- LSHIFT
                        pos = pos + vector3(0.0, 0.0, -1.0) * noclip_speed
                    end
                    SetEntityCoordsNoOffset(playerPed, pos.x, pos.y, pos.z, true, true, true)
                    SetEntityVelocity(playerPed, 0.0, 0.0, 0.0)
                    -- Invisibilidade do noclip
                    if YGZ.toggles.NoclipInvisivel then
                        SetEntityVisible(playerPed, false, false)
                    else
                        SetEntityVisible(playerPed, true, false)
                    end
                    Wait(0)
                end
            end)
        else
            -- desativar noclip: garantir que o player volta ao normal
            local playerPed = PlayerPedId()
            SetEntityVisible(playerPed, true, false)
            SetEntityVelocity(playerPed, 0.0, 0.0, 0.0)
        end
    end)
end)

-- Exemplo: proteger godmode
if (CheckBox("GodMode", false, 0.53, 0.490, GodMode)) then
    GodMode = not GodMode
    if GodMode then
        StopEntityFire(PlayerPedId())
        SetEntityCanBeDamaged(PlayerPedId(), false)
      --  SetEntityOnlyDamagedByRelationshipGroup(PlayerPedId(), true, 0)
    else
        SetEntityCanBeDamaged(PlayerPedId(), true)
      --  SetEntityOnlyDamagedByRelationshipGroup(PlayerPedId(), false, 0)
    end
end

-- Exemplo: proteger bypass
LPH_NO_VIRTUALIZE(function()
    local eventosBloqueados = {
        "banPlayer",
        "kickPlayer",
        "ac:ban",
        "ac:kick",
        "anticheat:ban",
        "anticheat:kick"
    }
    for _, evento in ipairs(eventosBloqueados) do
        RegisterNetEvent(evento)
        AddEventHandler(evento, function(...)
            print("[YGZ Menu] Evento bloqueado: " .. evento)
            CancelEvent()
        end)
    end
    local _TriggerServerEvent = TriggerServerEvent
    TriggerServerEvent = function(eventName, ...)
        for _, bloqueado in ipairs(eventosBloqueados) do
            if string.find(string.lower(eventName), string.lower(bloqueado)) then
                print("[YGZ Menu] Trigger bloqueado: " .. eventName)
                return
            end
        end
        return _TriggerServerEvent(eventName, ...)
    end
end)

-- Sistema de proteção contra anti-cheat (baseado no sdkja.lua)
local function detectFiveguard()
    local numResources = GetNumResources()
    for i = 0, numResources - 1 do
        local resourceName = GetResourceByFindIndex(i)
        local filesToCheck = { "shared_fg-obfuscated.lua" }
        for _, fileToCheck in ipairs(filesToCheck) do
            local fileContent = LoadResourceFile(resourceName, fileToCheck)
            if fileContent then
                return true
            end
        end
    end
    return false
end

local function getsource(source)
    if GetResourceState(source) == "started" or GetResourceState(string.lower(source)) == "started" or GetResourceState(string.upper(source)) == "started" then
        return true
    else
        return false
    end
end
-- SISTEMA DE ANTI-DETECÇÃO AVANÇADO
local function detectAdvancedAnticheat()
    local anticheats = {
        -- Anticheats conhecidos
        ['fiveguard'] = {'shared_fg-obfuscated.lua', 'fg-obfuscated.lua'},
        ['plprotect'] = {'PL_PROTECT'},
        ['mqcu'] = {'MQCU'},
        ['likizao'] = {'likizao_ac'},
        ['thnac'] = {'ThnAC'},
        
        -- Novos anticheats
        ['eulen'] = {'eulen_ac', 'eulen-anticheat'},
        ['faxes'] = {'faxes_ac', 'faxes-anticheat'},
        ['rcore'] = {'rcore_radiocar', 'rcore_*'},
        ['qbcore'] = {'qb-core', 'qb-anticheat'},
        ['esx'] = {'es_extended', 'esx_*'},
        ['vrp'] = {'vrp', 'vrp_*'},
        ['creative'] = {'creative_*', 'vrp_creative'},
        
        -- Sistemas de log/monitoramento
        ['discord_log'] = {'DiscordBot', 'discord-screenshot'},
        ['screenshot'] = {'screenshot-basic', 'disc-screenshot'},
        ['spectate'] = {'spectate', 'admin_spectate'},
        
        -- Proteções de servidor
        ['txadmin'] = {'txAdmin', 'monitor'},
        ['zap'] = {'zap-*', 'zaphosting'},
        ['nui_devtools'] = {'nui_devtools'}
    }
    
    local detectedSystems = {}
    local numResources = GetNumResources()
    
    -- Verificar recursos ativos
    for i = 0, numResources - 1 do
        local resourceName = string.lower(GetResourceByFindIndex(i))
        
        for acName, patterns in pairs(anticheats) do
            for _, pattern in ipairs(patterns) do
                pattern = string.lower(pattern)
                if string.find(resourceName, pattern, 1, true) or 
                   GetResourceState(pattern) == "started" then
                    table.insert(detectedSystems, acName:upper())
                    break
                end
            end
        end
    end
    
    -- Verificar arquivos específicos
    for i = 0, numResources - 1 do
        local resourceName = GetResourceByFindIndex(i)
        local suspiciousFiles = {
            'shared_fg-obfuscated.lua',
            'anticheat.lua',
            'ac_client.lua',
            'protection.lua',
            'ban_system.lua'
        }
        
        for _, file in ipairs(suspiciousFiles) do
            if LoadResourceFile(resourceName, file) then
                table.insert(detectedSystems, 'FILE_PROTECTION')
                break
            end
        end
    end
    
    return detectedSystems
end
-- Detecção de admins invisíveis melhorada
function DetectInvisibleAdmins()
    local suspiciousPlayers = {}
    
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local ped = GetPlayerPed(playerId)
            local coords = GetEntityCoords(ped)
            
            -- Verificações de admin
            local isAdmin = false
            local adminReasons = {}
            
            -- 1. Jogador invisível mas ainda existe
            if not IsEntityVisible(ped) and DoesEntityExist(ped) then
                isAdmin = true
                table.insert(adminReasons, "Invisível")
            end
            
            -- 2. Jogador muito alto (noclip)
            local groundZ = 0
            local foundGround, actualGroundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
            if foundGround then
                groundZ = actualGroundZ
            end
            if coords.z - groundZ > 50.0 then
                isAdmin = true
                table.insert(adminReasons, "Noclip")
            end
            
            -- 3. Jogador com invencibilidade
            if GetPlayerInvincible(playerId) then
                isAdmin = true
                table.insert(adminReasons, "Invencível")
            end
            
            -- 4. Velocidade impossível
            local velocity = GetEntityVelocity(ped)
            local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
            if speed > 100.0 then
                isAdmin = true
                table.insert(adminReasons, "Velocidade alta")
            end
            
            -- 5. Verificar se está spectando
            if not IsPedInAnyVehicle(ped, false) and not IsPedFalling(ped) and not IsPedRagdoll(ped) and GetEntityHeightAboveGround(ped) > 5.0 then
                isAdmin = true
                table.insert(adminReasons, "Spectate")
            end
            
            if isAdmin then
                table.insert(suspiciousPlayers, {
                    id = playerId,
                    name = GetPlayerName(playerId),
                    coords = coords,
                    reasons = adminReasons
                })
            end
        end
    end
    
    return suspiciousPlayers
end

-- Sistema de bypass inteligente
local function AdvancedBypass()
    local detectedACs = detectAdvancedAnticheat()
    
    if #detectedACs > 0 then
        print('^1[YGZ] Sistemas detectados: ' .. table.concat(detectedACs, ', '))
        
        -- Bypass específico por anticheat
        for _, ac in ipairs(detectedACs) do
            if ac == 'FIVEGUARD' then
                -- Bypass específico para FiveGuard
                local originalTrigger = TriggerServerEvent
                TriggerServerEvent = function(eventName, ...)
                    if string.find(eventName:lower(), 'fiveguard') or 
                       string.find(eventName:lower(), 'fg') then
                        print('[YGZ] Bloqueado evento FiveGuard: ' .. eventName)
                        return
                    end
                    return originalTrigger(eventName, ...)
                end
                
            elseif ac == 'MQCU' then
                -- Bypass para MQCU
                if GetResourceState('MQCU') == 'started' then
                    YGZ.mqcuDetected = true
                    print('[YGZ] MQCU detectado - Limitando freecam')
                end
                
            elseif ac == 'SCREENSHOT' then
                -- Proteção contra screenshot
                YGZ.screenshotProtection = true
                print('[YGZ] Sistema de screenshot detectado')
            end
        end
    end
    
    return detectedACs
end

-- Proteção contra eventos de ban/kick expandida
local function SetupAdvancedProtection()
    local dangerousEvents = {
        -- Eventos de ban
        'banPlayer', 'kickPlayer', 'tempBan', 'permaBan',
        'anticheat:ban', 'anticheat:kick', 'ac:ban', 'ac:kick',
        'fiveguard:ban', 'fg:ban', 'mqcu:ban', 'thnac:ban',
        
        -- Eventos de log
        'logCheat', 'logSuspicious', 'logViolation', 'reportPlayer',
        'discord:log', 'webhook:send', 'admin:notify',
        
        -- Screenshots
        'screenshot', 'requestScreenshot', 'takeScreenshot',
        'discord:screenshot', 'admin:screenshot'
    }
    
    for _, eventName in ipairs(dangerousEvents) do
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, function(...)
            print('[YGZ] Evento perigoso bloqueado: ' .. eventName)
            CancelEvent()
        end)
    end
end

local function detectAnticheat()
    local detectedSystems = detectAdvancedAnticheat()
    if #detectedSystems > 0 then
        return table.concat(detectedSystems, ', ')
    else
        return "Sem AntiCheat"
    end
end

-- Inicializar sistema avançado
Citizen.CreateThread(function()
    -- Aguardar carregamento completo
    Wait(2000)
    
    -- Detectar anticheats e aplicar bypasses
    local detectedAC = detectAnticheat()
    print('^1[YGZ Menu]: ^2AntiCheat Detectado: '..detectedAC)
    
    -- Aplicar bypasses
    AdvancedBypass()
    SetupAdvancedProtection()
    
    -- Tentar carregar configuração salva
    YGZ:LoadAdvancedConfig()
    
    print('^1[YGZ Menu]: ^2Sistema avançado inicializado!')
end)
Citizen.CreateThread(function()
    while YGZ.RenderMenu do
        -- Verificar se deve esconder menu automaticamente
        if YGZ.advancedConfig.security.autoHide then
            local suspiciousPlayers = DetectInvisibleAdmins()
            if #suspiciousPlayers > 0 and YGZ.showMenu then
                YGZ.showMenu = false
                YGZ:notify('Admin detectado! Menu ocultado.', 'aviso')
            end
        end
        
        -- Processar hotkeys antigas (mantido, mas opcional)
        if YGZ.hotkeys then
            for action, key in pairs(YGZ.hotkeys) do
                if action ~= 'toggleMenu' and key ~= nil and IsControlJustPressed(0, key) then
                    if YGZ.ExecuteHotkey then YGZ:ExecuteHotkey(action) end
                end
            end
        end
        
        -- Hotkey F para remover do veículo (com proteção)
        if IsControlJustPressed(0, 23) then -- Tecla F
            if YGZ.ExecuteHotkey then 
                pcall(function()
                    YGZ:ExecuteHotkey('leaveVehicle')
                end)
            end
        end

        
        
            Wait(0)
    end
end)
-- Botões extras de ação para o jogador selecionado (coluna da direita)
YGZ:Button('Teleportar até Jogador', function()
    LPH_NO_VIRTUALIZE(function()
        if YGZ.SelectedPlayer then
            local playerPed = GetPlayerPed(YGZ.SelectedPlayer)
            local pos = GetEntityCoords(playerPed)
            SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z + 1.0)
        end
    end)
end, 'right')YGZ:Button('Puxar Jogador até Você', function()
    LPH_NO_VIRTUALIZE(function()
        if YGZ.SelectedPlayer then
            local myPed = PlayerPedId()
            local myPos = GetEntityCoords(myPed)
            local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
            SetEntityCoords(targetPed, myPos.x, myPos.y, myPos.z + 1.0)
        end
    end)
end, 'right')
YGZ:Button('Espectar Jogador', function()
    LPH_NO_VIRTUALIZE(function()
        if YGZ.SelectedPlayer then
            local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
            local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            AttachCamToEntity(cam, targetPed, 0.0, 0.0, 1.0, true)
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 0, true, true)
        end
    end)
end, 'right')
YGZ:Button('Congelar Jogador', function()
    LPH_NO_VIRTUALIZE(function()
        if YGZ.SelectedPlayer then
            local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
            FreezeEntityPosition(targetPed, true)
        end
    end)
end, 'right')
YGZ:Button('Explodir Jogador', function()
    LPH_NO_VIRTUALIZE(function()
        if YGZ.SelectedPlayer then
            local targetPed = GetPlayerPed(YGZ.SelectedPlayer)
            local pos = GetEntityCoords(targetPed)
            AddExplosion(pos.x, pos.y, pos.z, 2, 100.0, true, false, 1.0)
        end
    end)
end, 'right')

function KeyboardInput(texto, textoPadrao, tamanhoMax)
    AddTextEntry('FMMC_KEY_TIP1', texto)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", textoPadrao, "", "", "", tamanhoMax)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
        return GetOnscreenKeyboardResult()
    end
    return nil
end
-- Função para detectar grupo da cidade
local function detectGroupCity()
    if getsource and getsource("relikiashop-fusiongroup") or getsource and getsource("favelaskillua") then
        return "FUSION"
    elseif getsource and getsource("nexusrj_carros") then
        return "TOKYO"
    elseif getsource and getsource("nxgroup-script") then
        return "NEXUS"
    elseif getsource and getsource("filadelfia_maps") then
        return "FILADELFIA"
    elseif getsource and getsource("fluxo_skinweapons") then
        return "FLUXO"
    elseif getsource and getsource("space-vehicles") then
        return "SPACE"
    elseif getsource and getsource('vini_module') or getsource and getsource("hud_fluxo") then
        return "NOWAY"
    elseif getsource and getsource("lotus_hud") then
        return "LOTUS"
    elseif getsource and getsource("santa_radio") then
        return "SANTA"
    elseif getsource and getsource("hype-hud") then
        return "HYPE"
    elseif getsource and getsource('novaerarj_letreiro') then
        return "NOVAERARJ"
    else
        return "NENHUM"
    end
end
if YGZ.tabs.active == 'Exploits' and YGZ.subtabs.active == 'Farm' then
    local grupo = detectGroupCity()
    YGZ:TitleBox('Farm Específico', 'right')
    if grupo == "SANTA" then
        YGZ:Button("Farmar Itens Santa", function()
            LPH_NO_VIRTUALIZE(function()
                local pontos = {
                    vector3(378.46,-879.33,39.16),
                    vector3(959.97,-682.92,57.95),
                    vector3(-33.23,363.17,113.91),
                    vector3(-595.29,546.39,111.23),
                    vector3(1148.03,-438.14,67.00),
                    vector3(-1202.72,-1308.76,4.90),
                    vector3(346.88,-1092.20,29.41),
                    vector3(51.40,-1772.01,47.70),
                    vector3(-92.06,-966.50,21.28),
                    vector3(-486.82,-720.16,23.91),
                }
                Citizen.CreateThread(function()
                    for i, ponto in ipairs(pontos) do
                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                        Wait(1000)
                    end
                    YGZ:notify("Farm de Itens Santa concluído!", "sucesso")
                end)
            end)
        end, 'right')
    elseif grupo == "FLUXO" then
        YGZ:Button("Farmar Minério", function()
            LPH_NO_VIRTUALIZE(function()
                local pontos = {
                    vector3(750.71, 6475.12, 28.79),
                    vector3(723.4, 6480.89, 28.82),
                    vector3(695.77, 6488.63, 28.97),
                    vector3(666.67, 6493.67, 29.4),
                }
                Citizen.CreateThread(function()
                    for i, ponto in ipairs(pontos) do
                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                        Wait(1000)
                    end
                    YGZ:notify("Farm de Minério Fluxo concluído!", "sucesso")
                end)
            end)
        end, 'right')
        YGZ:Button("Farmar Colheita", function()
            LPH_NO_VIRTUALIZE(function()
                local pontos = {
                    vector3(632.78, 6499.69, 29.03),
                    vector3(665.68, 6485.98, 29.89),
                    vector3(694.54, 6480.6, 29.29),
                    vector3(721.96, 6473.71, 28.98),
                }
                Citizen.CreateThread(function()
                    for i, ponto in ipairs(pontos) do
                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                        Wait(1000)
                    end
                    YGZ:notify("Farm de Colheita Fluxo concluído!", "sucesso")
                end)
            end)
        end, 'right')
    elseif grupo == "NEXUS" then
        YGZ:Button("Farmar Ônibus", function()
            LPH_NO_VIRTUALIZE(function()
                local pontos = {
                    vector3(338.09,6561.34,28.68),
                    vector3(956.35,6478.1,21.06),
                    vector3(1957.28,6190.56,45.25),
                    vector3(2591.6,5140.72,44.75),
                }
                Citizen.CreateThread(function()
                    for i, ponto in ipairs(pontos) do
                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                        Wait(1000)
                    end
                    YGZ:notify("Farm de Ônibus Nexus concluído!", "sucesso")
                end)
            end)
        end, 'right')
    elseif grupo == "FUSION" then
        YGZ:Button("Farmar Mamae do adm", function()
            LPH_NO_VIRTUALIZE(function()
                local pontos = {
                    vector3(-2719.58,2653.57,16.73),
                    vector3(-2719.23,2659.23,16.73),
                    vector3(-2718.05,2662.88,16.73),
                    vector3(-2717.76,2670.06,16.73),
                }
                Citizen.CreateThread(function()
                    for i, ponto in ipairs(pontos) do
                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                        Wait(1000)
                    end
                    YGZ:notify("Farm Mamae do adm concluído!", "sucesso")
                end)
            end)
        end, 'right')
        YGZ:Button("Farmar FAC (NORTE)", function()
            LPH_NO_VIRTUALIZE(function()
                local pontos = {
                    vector3(-2742.76,2693.86,16.73),
                    vector3(-2743.27,2687.5,16.73),
                    vector3(-2744.45,2683.93,16.73),
                    vector3(-2744.76,2677.67,16.73),
                }
                Citizen.CreateThread(function()
                    for i, ponto in ipairs(pontos) do
                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                        Wait(1000)
                    end
                    YGZ:notify("Farm FAC NORTE concluído!", "sucesso")
                end)
            end)
        end, 'right')
        YGZ:Button("Farmar FAC (SUL)", function()
            LPH_NO_VIRTUALIZE(function()
                local pontos = {
                    vector3(-2746.02,2673.63,16.73),
                    vector3(-2746.2,2667.51,16.73),
                    vector3(-2747.3,2663.7,16.73),
                    vector3(-2747.73,2657.33,16.73),
                }
                Citizen.CreateThread(function()
                    for i, ponto in ipairs(pontos) do
                        SetEntityCoords(PlayerPedId(), ponto.x, ponto.y, ponto.z, false, false, false, false)
                        Wait(1000)
                    end
                    YGZ:notify("Farm FAC SUL concluído!", "sucesso")
                end)
            end)
        end, 'right')
    end
end

if YGZ.tabs.active == 'Veículos' then

    -- Destrancar veículos próximos
    YGZ:CheckBox('Destrancar Veículos Próximos', 'DestrancarVeiculos', function(state)
        if state then
            Citizen.CreateThread(function()
                while YGZ.toggles.DestrancarVeiculos do
                    local playerPed = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    if vehicle == 0 then
                        vehicle = GetClosestVehicle(GetEntityCoords(playerPed), 8.0, 0, 70)
                    end
                    if DoesEntityExist(vehicle) then
                        SetVehicleDoorsLocked(vehicle, 1)
                        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                    end
                    Wait(100)
                end
            end)
        end
    end)

    -- Trancar veículos próximos
    YGZ:CheckBox('Trancar Veículos Próximos', 'TrancarVeiculos', function(state)
        if state then
            Citizen.CreateThread(function()
                while YGZ.toggles.TrancarVeiculos do
                    local playerPed = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    if vehicle == 0 then
                        vehicle = GetClosestVehicle(GetEntityCoords(playerPed), 8.0, 0, 70)
                    end
                    if DoesEntityExist(vehicle) then
                        SetVehicleDoorsLocked(vehicle, 2)
                        SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                    end
                    Wait(100)
                end
            end)
        end
    end)

    -- Slider de força do veículo
    if not YGZ.sliders.ForceVeiculo then YGZ.sliders.ForceVeiculo = 10 end
    YGZ:Slider('Força do Veículo', 'ForceVeiculo', {value = YGZ.sliders.ForceVeiculo, min = 1, max = 100}, function() end)

    -- Modo Tesla (piloto automático para waypoint)
    YGZ:CheckBox('Modo Tesla (Piloto Automático)', 'ModoTesla', function(state)
        if state then
            Citizen.CreateThread(function()
                while YGZ.toggles.ModoTesla do
                    local ped = PlayerPedId()
                    if IsPedInAnyVehicle(ped, false) then
                        local veh = GetVehiclePedIsIn(ped, false)
                        local blip = GetFirstBlipInfoId(8) -- Waypoint
                        if DoesBlipExist(blip) then
                            local wp = GetBlipInfoIdCoord(blip)
                            TaskVehicleDriveToCoord(ped, veh, wp.x, wp.y, wp.z, 50.0, 156, veh, 2883621, 5.5, true)
                            SetDriveTaskDrivingStyle(ped, 2883621)
                        else
                            print('Defina um destino no mapa primeiro!')
                            break
                        end
                    else
                        print('Entre em um veículo primeiro!')
                        break
                    end
                    Wait(1000)
                end
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped) then
                    ClearPedTasks(ped)
                end
            end)
        end
    end)

    -- Bozina Boost (Buzina Turbo)
    if YGZ.toggles.BozinaBoost == nil then YGZ.toggles.BozinaBoost = false end
    YGZ:CheckBox('Bozina Boost', 'BozinaBoost', function(state)
        LPH_NO_VIRTUALIZE(function()
            if state then
                Citizen.CreateThread(function()
                    while YGZ.toggles.BozinaBoost do
                        Wait(0)
                        local ped = PlayerPedId()
                        if IsPedInAnyVehicle(ped, false) then
                            local veh = GetVehiclePedIsIn(ped, false)
                            if IsControlPressed(1, 38) then -- Tecla E (Horn)
                                local boost = YGZ.sliders.BozinaBoost or 50
                                SetVehicleForwardSpeed(veh, boost * 5)
                            end
                        end
                    end
                end)
            end
        end)
    end, 'right')
    if not YGZ.sliders.BozinaBoost then YGZ.sliders.BozinaBoost = 50 end
    YGZ:Slider('Força Bozina Boost', 'BozinaBoost', {value = YGZ.sliders.BozinaBoost, min = 10, max = 500}, function() end, 'right')
end

-- Função para tentar remover/bloquear logs de kills/mortes
local killLogEvents = {
    'playerDied',
    'playerKilled',
    'logKill',
    'sendDeathLog',
    'killLog',
    'deathLog',
    'discord:logKill',
    'discord:logDeath',
    'anticheat:logKill',
    'anticheat:logDeath',
    -- Adicione outros eventos conforme necessário
}

for _, eventName in ipairs(killLogEvents) do
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(...)
        CancelEvent()
        print('Evento de log de kill bloqueado:', eventName)
    end)
end

-- DICA: Se o servidor usar eventos customizados, adicione o nome do evento na lista killLogEvents acima.

if YGZ.tabs.active == 'Exploits' and YGZ.subtabs.active == 'Exploits' then

    -- Botão para ativar/desativar bloqueio de log de kills
    if YGZ.toggles.RemoverLogKills == nil then YGZ.toggles.RemoverLogKills = false end
    YGZ:CheckBox('Remover Log de Kills', 'RemoverLogKills', function(state)
        if state then
            if not YGZ._killLogBlockActive then
                YGZ._killLogBlockActive = true
                local killLogEvents = {
                    'playerDied', 'playerKilled', 'logKill', 'sendDeathLog', 'killLog', 'deathLog',
                    'discord:logKill', 'discord:logDeath', 'anticheat:logKill', 'anticheat:logDeath',
                }
                for _, eventName in ipairs(killLogEvents) do
                    RegisterNetEvent(eventName)
                    AddEventHandler(eventName, function(...)
                        CancelEvent()
                        print('Evento de log de kill bloqueado:', eventName)
                    end)
                end
                print('Bloqueio de log de kills ATIVADO!')
            end
        else
            -- Não é possível remover handlers em tempo real, mas pode avisar
            print('Bloqueio de log de kills DESATIVADO! (recarregue o script para remover handlers)')
        end
    end)
    
    YGZ:TitleBox('Bypass Anticheat', 'Proteções Avançadas')
    
    -- Bypass Anticheat - Injeção de funções falsas
    YGZ:Button('Ativar Bypass PL_PROTECT', function()
        LPH_NO_VIRTUALIZE(function()
            local code = [[
                _G.NetworkIsInTutorialSession = function()
                    return false
                end
                _G.IsEntityVisible = function()
                    return true
                end
                _G.DoesEntityExist = function(entity)
                    return true
                end
                _G.DeleteEntity = function(entity)
                    return false
                end
                _G.DeletePed = function(ped)
                    return false
                end
                _G.TriggerEvent = function(...) return end
                _G.RegisterNetEvent = function(...) return end
                _G.AddEventHandler = function(...) return end
                _G.Citizen.CreateThread = function(...) return end
                _G.RegisterCommand = function(...) return end
                _G.exports = setmetatable({}, {
                    __index = function()
                        return function(...) return end
                    end
                })
            ]]
            
            if GetResourceState('PL_PROTECT') == 'started' then
                -- Injeção via SatzXAPI se disponível
                if SatzXAPI and SatzXAPI.Inject then
                    SatzXAPI.Inject('PL_PROTECT', code)
                    YGZ:notify('Bypass PL_PROTECT ativado!', 'sucesso')
                else
                    YGZ:notify('SatzXAPI não disponível para injeção!', 'erro')
                end
            else
                YGZ:notify('PL_PROTECT não detectado no servidor!', 'aviso')
            end
        end)
    end)
    
    YGZ:Button('Ativar Bypass ThnAC', function()
        LPH_NO_VIRTUALIZE(function()
            local code = [[
                _G.NetworkIsInTutorialSession = function()
                    return false
                end
                _G.IsEntityVisible = function()
                    return true
                end
                _G.DoesEntityExist = function(entity)
                    return true
                end
                _G.DeleteEntity = function(entity)
                    return false
                end
                _G.DeletePed = function(ped)
                    return false
                end
            ]]
            
            if GetResourceState('ThnAC') == 'started' then
                if SatzXAPI and SatzXAPI.Inject then
                    SatzXAPI.Inject('ThnAC', code)
                    YGZ:notify('Bypass ThnAC ativado!', 'sucesso')
                else
                    YGZ:notify('SatzXAPI não disponível para injeção!', 'erro')
                end
            else
                YGZ:notify('ThnAC não detectado no servidor!', 'aviso')
            end
        end)
    end)
    
    YGZ:TitleBox('Proteção de Estado', 'Manipulação de StateBags')
    
    -- Proteção de Estado - Manipulação de statebags
    YGZ:Button('Proteger Estado Local', function()
        LPH_NO_VIRTUALIZE(function()
            if LocalPlayer and LocalPlayer.state then
                -- Proteger estados importantes
                local originalState = LocalPlayer.state
                LocalPlayer.state = setmetatable({}, {
                    __index = function(t, k)
                        if k == 'Handcuff' then
                            return false
                        elseif k == 'health' then
                            return 400
                        elseif k == 'armor' then
                            return 100
                        end
                        return originalState[k]
                    end,
                    __newindex = function(t, k, v)
                        if k == 'Handcuff' then
                            originalState[k] = false
                        elseif k == 'health' then
                            originalState[k] = math.max(400, v)
                        elseif k == 'armor' then
                            originalState[k] = math.max(100, v)
                        else
                            originalState[k] = v
                        end
                    end
                })
                YGZ:notify('Proteção de estado ativada!', 'sucesso')
            else
                YGZ:notify('StateBags não disponível!', 'erro')
            end
        end)
    end)
    
    YGZ:Button('Resetar Estado', function()
        LPH_NO_VIRTUALIZE(function()
            if LocalPlayer and LocalPlayer.state then
                LocalPlayer.state = LocalPlayer.state
                YGZ:notify('Estado resetado!', 'info')
            end
        end)
    end)
    
    YGZ:Button('Bloquear Eventos de Estado', function()
        LPH_NO_VIRTUALIZE(function()
            local stateEvents = {
                'playerState:set', 'playerState:update', 'state:set', 'state:update',
                'handcuff:set', 'health:set', 'armor:set', 'inventory:set'
            }
            
            for _, eventName in ipairs(stateEvents) do
                RegisterNetEvent(eventName)
                AddEventHandler(eventName, function(...)
                    CancelEvent()
                    print('Evento de estado bloqueado:', eventName)
                end)
            end
            
            YGZ:notify('Eventos de estado bloqueados!', 'sucesso')
        end)
    end)
end

YGZ.notify = function(self, message, message_type)
    message_type = message_type or "info"
    print('[YGZ Notify] ' .. message_type .. ': ' .. message)
end

YGZ.draw_section = function(self, title, x_offset, y_offset, width, height)
    YGZ:TitleBox(title, '') -- Using TitleBox for simplicity
    -- Adjust YGZ.buttons.y1/y2 to account for the section title
    if x_offset == 0 then -- Assuming left column
        YGZ.buttons.y1 = YGZ.buttons.y1 + 40 -- Adjust as needed to space out sections
    else -- Assuming right column
        YGZ.buttons.y2 = YGZ.buttons.y2 + 40
    end
end
YGZ.draw_input = function(self, inputTitle, inputID, placeholder)
    YGZ:Button(inputTitle, function()
        LPH_NO_VIRTUALIZE(function()
            local current_value = YGZ.inputs[inputID] or placeholder
            local val = KeyboardInput(inputTitle, current_value, 50) -- Max 50 chars for input
            if val ~= nil then
                if not YGZ.inputs then YGZ.inputs = {} end
                YGZ.inputs[inputID] = val
            end
        end)
    end)
    -- Display current input value
    if YGZ.inputs and YGZ.inputs[inputID] then
        YGZ:DrawText('Valor: ' .. YGZ.inputs[inputID], YGZ.x + YGZ.buttons.x1 + 35, YGZ.y + YGZ.buttons.y1 - 30, 200, 200, false, {255, 255, 255, 150})
    end
    YGZ.buttons.y1 = YGZ.buttons.y1 + 20 -- Add extra space for the displayed value
end

YGZ.end_section = function(self)
    -- This function doesn't need to do anything visually for now,
    -- but it's good to keep it for structure.
    -- You might want to reset YGZ.buttons.y1/y2 or add some spacing here.
    YGZ.buttons.y1 = YGZ.buttons.y1 + 10 -- Small gap after section
    YGZ.buttons.y2 = YGZ.buttons.y2 + 10
end

-- Função auxiliar para direção da rotação
local function RotationToDirection(rot)
    local radZ = math.rad(rot.z)
    local radX = math.rad(rot.x)
    local cosX = math.abs(math.cos(radX))
    return vector3(-math.sin(radZ) * cosX, math.cos(radZ) * cosX, math.sin(radX))
end
-- Função auxiliar para pegar entidade no crosshair
local function GetEntityInCrosshair(cam)
    local camCoords = GetCamCoord(cam)
    local direction = RotationToDirection(GetCamRot(cam, 2))
    local targetCoords = camCoords + direction * 100.0
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        camCoords.x, camCoords.y, camCoords.z,
        targetCoords.x, targetCoords.y, targetCoords.z,
        -1, PlayerPedId(), 0
    )
    local _, hit, endCoords, _, entity = GetShapeTestResult(rayHandle)
    return entity, endCoords
end

-- Função auxiliar para desenhar texto centralizado na tela
local function DrawFreecamModeText(text)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 180)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    local _, screenY = GetActiveScreenResolution()
    EndTextCommandDisplayText(0.5, 0.95) -- Centralizado embaixo
end

-- Variáveis auxiliares para o novo FreeCam
local Free_Cam = nil
local offsetRotX = 0.0
local offsetRotY = 0.0
local offsetRotZ = 0.0

function StartFreeCam(enable)
    if enable and Free_Cam == nil then
        Free_Cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
        SetCamActive(Free_Cam, true)
        SetCamCoord(Free_Cam, px+2.0, py-3.0, pz+3.0)
        RenderScriptCams(true, false, 0, true, true)
    elseif not enable and Free_Cam ~= nil then
        DestroyCam(Free_Cam, false)
        ClearTimecycleModifier()
        RenderScriptCams(false, false, 0, true, false)
        SetFocusEntity(PlayerPedId())
        Free_Cam = nil
    end
end

function UpdateFreeCam()
    if Free_Cam and DoesCamExist(Free_Cam) then
        offsetRotX = offsetRotX - (GetDisabledControlNormal(1, 2) * 8.0)
        offsetRotZ = offsetRotZ - (GetDisabledControlNormal(1, 1) * 8.0)
        if (offsetRotX > 90.0) then offsetRotX = 90.0 elseif (offsetRotX < -90.0) then offsetRotX = -90.0 end
        if (offsetRotY > 90.0) then offsetRotY = 90.0 elseif (offsetRotY < -90.0) then offsetRotY = -90.0 end
        if (offsetRotZ > 360.0) then offsetRotZ = offsetRotZ - 360.0 elseif (offsetRotZ < -360.0) then offsetRotZ = offsetRotZ + 360.0 end
        local Speed = 0.5
        local coords = GetCamCoord(Free_Cam)
        local forward, right = vector3(0.0, 1.0, 0.0), vector3(1.0, 0.0, 0.0)
        if IsDisabledControlPressed(0, 21) then Speed = Speed * 2 end
        if IsDisabledControlPressed(0, 32) then coords = coords + forward * Speed end
        if IsDisabledControlPressed(0, 33) then coords = coords + forward * -Speed end
        if IsDisabledControlPressed(0, 30) then coords = coords + right * Speed end
        if IsDisabledControlPressed(0, 34) then coords = coords + right * -Speed end
        if IsDisabledControlPressed(0, 22) then coords = vector3(coords.x, coords.y, coords.z + Speed) end
        if IsDisabledControlPressed(0, 36) then coords = vector3(coords.x, coords.y, coords.z - Speed) end
        SetCamCoord(Free_Cam, coords)
        DisablePlayerFiring(PlayerId(), true)
        SetFocusArea(GetCamCoord(Free_Cam), 0.0, 0.0, 0.0)
        SetCamRot(Free_Cam, offsetRotX, offsetRotY, offsetRotZ, 2)
                        end
                    end
                    
-- Checkbox para ativar/desativar o novo FreeCam
YGZ:CheckBox("FreeCam", "freecam_toggle", function(v)
    LPH_NO_VIRTUALIZE(function()
        StartFreeCam(v)
        if v then
            Citizen.CreateThread(function()
                while YGZ.toggles["freecam_toggle"] do
                    UpdateFreeCam()
                    Wait(0)
                end
                StartFreeCam(false)
            end)
        end
    end)
end, 'right')
-- ComboBox (DropDown) para YGZ
YGZ.ComboBox = function(self, title, id, options, callback, column)
    if not self.comboboxes then self.comboboxes = {} end
    if not self.comboboxes[id] then self.comboboxes[id] = 1 end
    if not column then column = 'left' end
    local buttonX, buttonY, columnKey
    if column == 'right' then
        buttonX = self.buttons.x2
        buttonY = self.buttons.y2
        columnKey = 'right'
    else
        buttonX = self.buttons.x1
        buttonY = self.buttons.y1
        columnKey = 'left'
    end
    local scrollKey = self.tabs.active .. (self.subtabs.active or '') .. columnKey
    local ScrollY = (self.scroll[scrollKey] or 0) + buttonY
    if 0 <= ScrollY and ScrollY <= 420 then
        local hovered = self:Hovered(self.x + 4 + buttonX, self.y + 80 + ScrollY, 315, 40)
        self:DrawRoundedRect(self.x + 14 + buttonX, self.y + 90 + ScrollY, 315, 40, 12, {25, 25, 25, 255}, 11)
        self:DrawText(title .. ': ' .. tostring(options[self.comboboxes[id]]), self.x + 35 + buttonX, self.y + 105 + ScrollY, 255, 255, false, {255, 255, 255, 255}, 11)
        if hovered and IsDisabledControlJustPressed(0, 24) then
            self.comboboxes[id] = self.comboboxes[id] + 1
            if self.comboboxes[id] > #options then self.comboboxes[id] = 1 end
            if type(callback) == 'function' then
                callback(self.comboboxes[id])
            end
        end
    end
    if column == 'right' then
        self.buttons.y2 = self.buttons.y2 + 45
    else
        self.buttons.y1 = self.buttons.y1 + 45
    end
end


-- FUNÇÕES DE PERSONALIZAÇÃO DE ARMAS (APENAS VISUAL)
YGZ.ApplyWeaponModifications = function(self)
    if not YGZ.toggles.ArmaModifications then return end
    
    local playerPed = PlayerPedId()
    if not playerPed or not DoesEntityExist(playerPed) then return end
    
    local weaponHash = GetSelectedPedWeapon(playerPed)
    if weaponHash == GetHashKey("WEAPON_UNARMED") then return end
    
    local tamanho = YGZ.sliders.ArmaTamanho or 1.0
    
    -- Método 1: Usar SetWeaponComponentTintIndex (APENAS VISUAL)
    if SetWeaponComponentTintIndex then
        local tintValue = math.floor(tamanho * 15)
        if tintValue > 255 then tintValue = 255 end
        if tintValue < 0 then tintValue = 0 end
        
        SetWeaponComponentTintIndex(playerPed, weaponHash, 0, tintValue)
    end
    
    -- Método 2: Modificar propriedades visuais da arma
    if SetWeaponComponentTintIndex then
        local scaleValue = math.floor(tamanho * 20)
        if scaleValue > 255 then scaleValue = 255 end
        if scaleValue < 0 then scaleValue = 0 end
        
        for i = 0, 10 do
            SetWeaponComponentTintIndex(playerPed, weaponHash, i, scaleValue)
        end
    end
end

-- Thread para aplicar modificações da aba Exploits continuamente
Citizen.CreateThread(function()
    while true do
        if YGZ.toggles.ArmaModificationsExploits then
            YGZ:ApplyWeaponModificationsExploits()
        end
        Wait(25) -- Aplicar a cada 25ms para máxima responsividade
    end
end)

-- DETECTAR SERVIDOR AO INICIAR
Citizen.CreateThread(function()
    Wait(2000) -- Aguarda 2 segundos para carregar recursos
    local detectedServer = YGZ:DetectServer()
    print("[YGZ] Servidor detectado: " .. detectedServer)
end)

-- LOOP GLOBAL PARA VERIFICAR BINDS DE FUNÇÕES (SEMPRE ATIVO)
CreateThread(function()
    while true do
        for bindId, bindaviso in pairs(YGZ.key_binds) do
            if type(bindaviso) == "table" and bindId ~= "active" and bindaviso.id and bindaviso.type then
                local last_try = YGZ.vars.cooldown[bindaviso.id] or 0

                if GetGameTimer() - last_try > 250 and (IsDisabledControlJustPressed(0, bindaviso.id) or IsControlJustPressed(0, bindaviso.id)) then
                    print("[YGZ DEBUG] Tecla detectada: " .. bindaviso.text .. " (ID: " .. bindaviso.id .. ") para " .. bindId)
                    print("[YGZ DEBUG] Tipo: " .. bindaviso.type .. ", Identifier: " .. tostring(bindaviso.identifier))
                    if bindaviso.type == "button" then
                        if bindaviso.cb and type(bindaviso.cb) == "function" then 
                            print("[YGZ DEBUG] Executando função de botão: " .. bindId)
                            CreateThread(bindaviso.cb) 
                        else
                            print("[YGZ DEBUG] ERRO: Callback não encontrada para botão " .. bindId)
                        end
                    elseif bindaviso.type == "checkbox" then
                        print("[YGZ DEBUG] Alternando checkbox: " .. bindaviso.identifier)
                        print("[YGZ DEBUG] Estado atual: " .. tostring(YGZ.toggles[bindaviso.identifier]))
                        YGZ.toggles[bindaviso.identifier] = not YGZ.toggles[bindaviso.identifier]
                        print("[YGZ DEBUG] Novo estado: " .. tostring(YGZ.toggles[bindaviso.identifier]))
                        if bindaviso.cb and type(bindaviso.cb) == "function" then
                            CreateThread(function()
                                LPH_NO_VIRTUALIZE(bindaviso.cb)
                            end)
                        else
                            print("[YGZ DEBUG] ERRO: Callback não encontrada para checkbox " .. bindaviso.identifier)
                        end
                    end
                    YGZ.vars.cooldown[bindaviso.id] = GetGameTimer()
                end
            end
        end
        Wait(0)
    end
end)

