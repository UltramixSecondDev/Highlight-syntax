-- Syntax Highlighting Universal para Roblox
-- Compatible con cualquier TextBox/TextLabel
-- Respeta espacios y saltos de línea

local function crearHighlight(targetTextBox)
    assert(targetTextBox:IsA("TextBox") or targetTextBox:IsA("TextLabel"), "El objetivo debe ser TextBox o TextLabel")

    -- TextLabel de resaltado
    local highlight = Instance.new("TextLabel", targetTextBox.Parent)
    highlight.Size = targetTextBox.Size
    highlight.Position = targetTextBox.Position
    highlight.BackgroundTransparency = 1
    highlight.TextXAlignment = Enum.TextXAlignment.Left
    highlight.TextYAlignment = Enum.TextYAlignment.Top
    highlight.Font = targetTextBox.Font
    highlight.TextSize = targetTextBox.TextSize
    highlight.RichText = true
    highlight.TextColor3 = Color3.new(1,1,1)
    highlight.ZIndex = targetTextBox.ZIndex - 1
    highlight.Text = ""

    -- Diccionarios
    local palabrasReservadas = {["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,
        ["end"]=true,["false"]=true,["for"]=true,["function"]=true,["if"]=true,
        ["in"]=true,["local"]=true,["nil"]=true,["not"]=true,["or"]=true,
        ["repeat"]=true,["return"]=true,["then"]=true,["true"]=true,["until"]=true,["while"]=true}

    local funcionesGlobales = {["print"]=true,["warn"]=true,["error"]=true,
        ["wait"]=true,["spawn"]=true,["pcall"]=true,["xpcall"]=true,
        ["loadstring"]=true,["type"]=true,["typeof"]=true,
        ["pairs"]=true,["ipairs"]=true}

    local objetosRoblox = {["game"]=true,["workspace"]=true,["script"]=true,["Instance"]=true,["Vector3"]=true,["Color3"]=true,["CFrame"]=true}

    local metodosRoblox = {["FindFirstChild"]=true,["WaitForChild"]=true,["Clone"]=true,["Destroy"]=true,["new"]=true,["IsA"]=true,["GetService"]=true}

    -- Escape HTML
    local function escaparHTML(str)
        str = str:gsub("&","&amp;")
        str = str:gsub("<","&lt;")
        str = str:gsub(">","&gt;")
        return str
    end

    -- Función de resaltado
    local function aplicarColores(texto)
        local resultado = ""
        local pos = 1
        while pos <= #texto do
            local char = texto:sub(pos,pos)
            local nextTwo = texto:sub(pos,pos+1)

            -- Comentarios
            if nextTwo == "--" then
                local fin = texto:find("\n", pos) or (#texto+1)
                resultado ..= '<font color="#666666">'..escaparHTML(texto:sub(pos, fin-1))..'</font>'
                pos = fin

            -- Strings dobles y simples
            elseif char == '"' or char == "'" then
                local quote = char
                local fin = pos+1
                while fin <= #texto do
                    if texto:sub(fin,fin) == quote and texto:sub(fin-1,fin-1) ~= '\\' then break end
                    fin += 1
                end
                resultado ..= '<font color="#ADF195">'..escaparHTML(texto:sub(pos,fin))..'</font>'
                pos = fin+1

            -- Strings multilinea [[...]]
            elseif nextTwo == '[[' then
                local fin = texto:find(']]', pos+2) or #texto
                resultado ..= '<font color="#ADF195">'..escaparHTML(texto:sub(pos,fin+1))..'</font>'
                pos = fin+2

            -- Números
            elseif char:match('%d') then
                local numero = texto:match('^%d+%.?%d*', pos)
                resultado ..= '<font color="#FFC600">'..numero..'</font>'
                pos += #numero

            -- Palabras y símbolos
            else
                local palabra, simbolos = texto:match("([_%a][_%w]*)([^_%w]*)", pos)
                if not palabra then
                    resultado ..= escaparHTML(texto:sub(pos,pos))
                    pos += 1
                else
                    local palabraEsc = escaparHTML(palabra)
                    local simbolosEsc = escaparHTML(simbolos or "")

                    if texto:sub(pos-1,pos-1) == "." then
                        resultado ..= '<font color="#61A1F1">'..palabraEsc..'</font>'
                    elseif palabrasReservadas[palabra] then
                        resultado ..= '<font color="#F86D7C">'..palabraEsc..'</font>'
                    elseif funcionesGlobales[palabra] or metodosRoblox[palabra] then
                        resultado ..= '<font color="#FDFBAC">'..palabraEsc..'</font>'
                    elseif objetosRoblox[palabra] then
                        resultado ..= '<font color="#84D6F7">'..palabraEsc..'</font>'
                    else
                        resultado ..= palabraEsc
                    end

                    resultado ..= simbolosEsc
                    pos += #palabra + #simbolos
                end
            end
        end

        -- Reemplaza saltos de línea y espacios por HTML para mantener el formato
        resultado = resultado:gsub("\n","<br>")
        resultado = resultado:gsub(" ","&nbsp;")
        return resultado
    end

    -- Función para actualizar resaltado en vivo
    local function actualizarHighlight()
        highlight.Text = aplicarColores(targetTextBox.Text)
    end

    -- Conectar eventos
    targetTextBox:GetPropertyChangedSignal("Text"):Connect(actualizarHighlight)
    targetTextBox:GetPropertyChangedSignal("TextSize"):Connect(function() highlight.TextSize = targetTextBox.TextSize end)
    targetTextBox:GetPropertyChangedSignal("Font"):Connect(function() highlight.Font = targetTextBox.Font end)
    targetTextBox:GetPropertyChangedSignal("Size"):Connect(function() highlight.Size = targetTextBox.Size end)
    targetTextBox:GetPropertyChangedSignal("Position"):Connect(function() highlight.Position = targetTextBox.Position end)

    -- Inicializar
    actualizarHighlight()
    return highlight
end

return crearHighlight
