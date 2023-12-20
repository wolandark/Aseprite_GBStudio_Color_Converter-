numColors = 1
colors = {}
-- paletteColors = nil

paletteColors = {
    Color(7, 24, 33),    -- #071821
    Color(48, 104, 80),  -- #306850
    Color(134, 192, 108),-- #86c06c
    Color(224, 248, 207) -- #e0f8cf
}
uniqueColor = {}

function updateColorPickerUI ()
    if dlg then dlg:close() end
    
    dlg = getDialogue()
end

function applyPaletteReduction ()
    app.transaction(
        function()
            local sprite = app.site.sprite
        
            if not sprite then
                print("No active sprite.")
                return
            end
            
            for _, frame in ipairs(sprite.frames) do
                for _, layer in ipairs(sprite.layers) do
                    local cel = layer:cel(frame)
                    if cel then
                        local image = cel.image
                        if image.colorMode == ColorMode.RGB then
                            for it in image:pixels() do
                                local pixelValue = it() -- get pixel
                                
                                if app.pixelColor.rgbaA(pixelValue) > 0 then --if not a blank pixel
                                    local closestColor = paletteColors[1]
                                    local minDelta = calcColorDelta(pixelValue, closestColor)
                                    
                                    for i = 2, #paletteColors do
                                        local delta = calcColorDelta(pixelValue, paletteColors[i])
                                        if delta < minDelta then
                                            minDelta = delta
                                            closestColor = paletteColors[i]
                                        end
                                    end
                                    
                                    closestColor.alpha = app.pixelColor.rgbaA(pixelValue)
                                    image:drawPixel(it.x, it.y, closestColor) -- set pixel
                                end
                            end
                        else
                            print("Error: Image color mode is not RGB.")
                        end
                    end
                end
            end
        end
    )
    dlg:close()
end

function getDialogue ()
    local dlg = Dialog { title = "GB Palette" }
    if paletteColors then
        for i, value in ipairs(paletteColors) do
            dlg:color {
                id = "clr"..i,
                label = "Color "..i..":",
                color = value
            }
        end 
    else
        for i=1, numColors do
            dlg:color {
                id = "clr"..i,
                label = "Color "..i..":",
                color = Color(0xffff7f00)
            }
        end
    end
    

    dlg:combobox{ 
        id="colorType",
        label="Color Map Method",
        option="RGB",
        options={ "LAB", "RGB" }, 
    }

    dlg:button{
        id = "apply",
        text = "Apply",
        focus = true,
        onclick = function ()
            applyPaletteReduction()
        end
    }

    dlg:button {
        id = "cancel",
        text = "Cancel",
        onclick = function()
            dlg:close()
        end
    }


    dlg:button {
        id = "useSecondPalette",
        text = "BG",
        onclick = function ()
            if not paletteColors or #paletteColors == 0 then
                print("Please load the palette first.")
                return
            end
            
            local reversePalette = {}
            for i = #paletteColors, 1, -1 do
                table.insert(reversePalette, paletteColors[i])
            end

            paletteColors = reversePalette
            updateColorPickerUI()
        end
    }


dlg:button {
        id = "useSecondPalette",
        text = "Reversed BG",
        onclick = function ()
            if not paletteColors or #paletteColors == 0 then
                print("Please load the palette first.")
                return
            end
            
            local reversePalette = {}
            for i = #paletteColors, 1, -1 do
                table.insert(reversePalette, paletteColors[i])
            end

            paletteColors = reversePalette
            updateColorPickerUI()
        end
    }

    dlg:button {
        id = "useThirdPalette",
        text = "Sprite Palette",
        onclick = function ()
            paletteColors = {
                Color(7, 24, 33),      -- #071821
                Color(134, 192, 108),  -- #86c06c
                Color(224, 248, 207),  -- #e0f8cf
                Color(101, 255, 0)     -- #65ff00
            }
            updateColorPickerUI()
        end
    }

    dlg:button {
        id = "useReversedThirdPalette",
        text = "Reversed Sprite Palette",
        onclick = function ()
            local reversePalette = {
                Color(7, 24, 33),      -- #071821
                Color(134, 192, 108),  -- #86c06c
                Color(224, 248, 207),  -- #e0f8cf
                Color(101, 255, 0)     -- #65ff00
            }
            local reversed = {}
            for i = #reversePalette, 1, -1 do
                table.insert(reversed, reversePalette[i])
            end
            paletteColors = reversed
            updateColorPickerUI()
        end
    }

    dlg:show { wait = false }
    return dlg
end


function RGBtoXYZ(rgb)
    local r = rgb.red / 255
    local g = rgb.green / 255
    local b = rgb.blue / 255

    -- Applying gamma correction
    r = (r > 0.04045) and (( (r + 0.055) / 1.055) ^ 2.4) or (r / 12.92)
    g = (g > 0.04045) and (( (g + 0.055) / 1.055) ^ 2.4) or (g / 12.92)
    b = (b > 0.04045) and (( (b + 0.055) / 1.055) ^ 2.4) or (b / 12.92)

    -- sRGB D65 illuminant
    local x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
    local y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
    local z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041

    return x, y, z
end

-- Helper function to convert XYZ to LAB
function XYZtoLab(x, y, z)
    local epsilon = 0.008856
    local kappa = 903.3
    local xn, yn, zn = 0.950456, 1.0, 1.088754

    local fX = (x > epsilon) and (x ^ (1 / 3)) or ((kappa * x + 16) / 116)
    local fY = (y > epsilon) and (y ^ (1 / 3)) or ((kappa * y + 16) / 116)
    local fZ = (z > epsilon) and (z ^ (1 / 3)) or ((kappa * z + 16) / 116)

    local L = (116 * fY) - 16
    local a = 500 * (fX - fY)
    local b = 200 * (fY - fZ)

    return L, a, b
end

-- Main function to convert RGB to Lab
function RGBtoLab(rgb)
    local x, y, z = RGBtoXYZ(rgb)
    return XYZtoLab(x, y, z)
end

-- Function to calculate LAB delta
function calcColorDelta(pixel, color)
    if(dlg.data["colorType"]) == "LAB" then
        -- Convert pixel color to LAB
        pixelColor = Color(
            app.pixelColor.rgbaR(pixel),
            app.pixelColor.rgbaG(pixel),
            app.pixelColor.rgbaB(pixel)
        )

        pixelL, pixelA, pixelB = RGBtoLab(pixelColor)
        targetL, targetA, targetB = RGBtoLab(color)

        deltaL = targetL - pixelL
        deltaA = targetA - pixelA
        deltaB = targetB - pixelB

        totalDelta = math.sqrt(deltaL^2 + deltaA^2 + deltaB^2)

    else --RGB Calc
        totalDelta = math.sqrt((app.pixelColor.rgbaR(pixel) - color.red)^2
        + (app.pixelColor.rgbaB(pixel) - color.blue)^2
        + (app.pixelColor.rgbaG(pixel) - color.green)^2)
    end

    return totalDelta
end

function importPaletteColors (palette)
    numColors = 0
    paletteColors = {}
    for i=1, #palette-1 do
        currColor = palette:getColor(i)
        if currColor.alpha ~= 0 then
            numColors = numColors + 1
            paletteColors[i] = currColor
        end
    end
    
    updateColorPickerUI()
end

updateColorPickerUI()
