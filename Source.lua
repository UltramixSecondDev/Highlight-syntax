-- Highlight
local highlight = Instance.new("TextLabel", scroll)
highlight.Size = codeBox.Size
highlight.Position = codeBox.Position
highlight.BackgroundTransparency = 1
highlight.TextXAlignment = Enum.TextXAlignment.Left
highlight.TextYAlignment = Enum.TextYAlignment.Top
highlight.Font = codeBox.Font
highlight.TextSize = codeBox.TextSize
highlight.RichText = true
highlight.TextColor3 = Color3.new(1,1,1)
highlight.ZIndex = 1
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
    return str:gsub("&","&"):gsub("<","<"):gsub(">",">")
end

-- Función de resaltado completa (Strings mejorados)
local function aplicarColores(texto)
    local resultado = ""
    local pos = 1
    while pos <= #texto do
        local char = texto:sub(pos,pos)
        local nextTwo = texto:sub(pos,pos+1)

        -- Comentarios
        if nextTwo == "--" then
            local fin = texto:find("\n", pos) or #texto
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
                resultado ..= escaparHTML(texto:sub(pos))
                pos = #texto+1
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
    return resultado
end
