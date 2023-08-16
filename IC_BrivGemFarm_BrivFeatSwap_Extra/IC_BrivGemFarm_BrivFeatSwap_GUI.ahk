GUIFunctions.AddTab("Briv Feat Swap")

; Add GUI fields to this addon's tab.
Gui, ICScriptHub:Tab, Briv Feat Swap

GUIFunctions.UseThemeTextColor("HeaderTextColor", 700)
Gui, ICScriptHub:Add, Text, Section vBGFBFS_Status, Status:
Gui, ICScriptHub:Add, Text, x+5 w170 vBGFBFS_StatusText, Not Running
GUIFunctions.UseThemeTextColor("WarningTextColor", 700)

Gui, ICScriptHub:Add, Text, xs ys+20 Hidden vBGFBFS_StatusWarning, WARNING: Addon was loaded too late. Stop/start Gem Farm to resume.
GUIFunctions.UseThemeTextColor()

; Validates inputs for targetQ/E and stack setup controls.
; Returns: - int:input or str:"RETURN" if input is invalid.
BGFBFS_ValidateInput(min := 0, max := 1)
{
    global
    local beforeSubmit := % %A_GuiControl%
    GuiControlGet, input,, %A_GuiControl%
    if input is not digit
    {
        onlyDigits := RegExReplace(beforeSubmit, "[^\d]+")
        GuiControl, ICScriptHub:Text, %A_GuiControl%, % onlyDigits
        return "RETURN"
    }
    if input not between %min% and %max%
    {
        input := input < min ? min : max
        GuiControl, ICScriptHub:Text, %A_GuiControl%, % input
    }
    if (LTrim(input, 0) == beforeSubmit && (input . " ") != (beforeSubmit . " "))
    {
        input := LTrim(beforeSubmit, "0")
        GuiControl, ICScriptHub:Text, %A_GuiControl%, % input
    }
    Gui, ICScriptHub:Submit, NoHide
    return input
}

BrivGemFarm_BrivFeatSwap_Target()
{
    global
    if (g_BrivFeatSwap.GetPresetName() != "")
        BGFBFS_ValidateInput(%A_GuiControl%, %A_GuiControl%)
    else if ((value := BGFBFS_ValidateInput(0, 999)) != "RETURN")
        g_BrivFeatSwap.UpdatePath()
}

BrivGemFarm_BrivFeatSwap_Save()
{
    global
    Gui, ICScriptHub:Submit, NoHide
    GuiControl, ICScriptHub: Disable, BrivGemFarm_BrivFeatSwap_Save
    g_BrivFeatSwap.Save(BrivGemFarm_BrivFeatSwap_TargetQ, BrivGemFarm_BrivFeatSwap_TargetE)
    GuiControl, ICScriptHub: Enable, BrivGemFarm_BrivFeatSwap_Save
}

BGFBFS_Preset()
{
    global
    Gui, ICScriptHub:Submit, NoHide
    local value := % %A_GuiControl%
    g_BrivFeatSwap.LoadPreset(value)
}

BGFBFS_ResetArea()
{
    global
    if ((value := BGFBFS_ValidateInput(1, 99999)) != "RETURN")
        g_BrivFeatSwap.UpdatePath(value)
}

BGFBFS_BrivMetalbornArea()
{
    global
    if ((value := BGFBFS_ValidateInput(1, 99999)) == "RETURN")
        return
    GuiControlGet, value, ICScriptHub:, BGFBFS_ResetArea
    g_BrivFeatSwap.UpdatePath(value)
}

BGFBFS_StacksRequired()
{
    global
    if ((value := BGFBFS_ValidateInput(0, 999999999999999)) != "RETURN")
        g_BrivFeatSwap.UpdateResetAreaFromStacks(value)
}

; Disable mod50 checkboxes when a preset has been selected.
BGFBFS_Mod50CheckBoxes()
{
    global
    if (g_BrivFeatSwap.GetPresetName() == "")
        return
    local beforeSubmit := % %A_GuiControl%
    GuiControl, ICScriptHub:, %A_GuiControl%, % beforeSubmit
    Gui, ICScriptHub:Submit, NoHide
}

Class IC_BrivGemFarm_BrivFeatSwap_GUI
{
    LeftAlign := 20
    XSection := 10
    YSection := 10
    XSpacing := 10
    YSpacing := 10
    YTitleSpacing := 20

    SetupGroups()
    {
        global
        local xSpacing := this.XSpacing
        local yTitleSpacing := this.YTitleSpacing
        Gui, ICScriptHub:Add, Button, xs y+%yTitleSpacing% vBrivGemFarm_BrivFeatSwap_Save gBrivGemFarm_BrivFeatSwap_Save, Save
        Gui, ICScriptHub:Font, w700
        Gui, ICScriptHub:Add, Text, Section xs y+%yTitleSpacing% vBGFBFS_PresetText, Presets:
        Gui, ICScriptHub:Font, w400
        Gui, ICScriptHub:Add, DropDownList, x+%xSpacing% yp-3 w100 vBGFBFS_Preset gBGFBFS_Preset
        GUIFunctions.UseThemeTextColor("WarningTextColor", 700)
        Gui, ICScriptHub:Add, Text, x+27 ys w270 vBGFBFS_PresetWarningText
        GUIFunctions.UseThemeTextColor()
        this.SetupSkipSetupGroup()
        this.SetupStacksSetupGroup()
        this.SetupPreferredBrivJumpZonesGroup()
        this.SetupBGFLUGroup()
    }

    SetupSkipSetupGroup()
    {
        global
        local leftAlign := this.LeftAlign
        local xSection := this.XSection
        local xSpacing := this.XSpacing
        local ySpacing := this.YSpacing
        local yTitleSpacing := this.YTitleSpacing
        Gui, ICScriptHub:Font, w700
        Gui, ICScriptHub:Add, GroupBox, Section xs vBGFBFS_SkipSetup, Skip setup
        Gui, ICScriptHub:Font, w400
        Gui, ICScriptHub:Add, Text, xs+%xSection% ys+%yTitleSpacing% w125 vBGFBFS_DetectedText, Briv skip:
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapReads xs+%xSection% y+%ySpacing% w30, Reads
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapTarget x+15 w30, Target
        GuiControlGet, pos, ICScriptHub:Pos, BrivFeatSwapTarget
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapQText xs+%xSection% y+%ySpacing% w15, Q:
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapQValue x+%xSpacing% w20
        GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        Gui, ICScriptHub:Add, Edit, x%posX% y+-16 h19 w33 Limit3 vBrivGemFarm_BrivFeatSwap_TargetQ gBrivGemFarm_BrivFeatSwap_Target, 0
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapWText xs+%xSection% y+%ySpacing% w15, W:
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapWValue x+%xSpacing% w20
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapEText xs+%xSection% y+%ySpacing% w15, E:
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapEValue x+%xSpacing% w20
        GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        Gui, ICScriptHub:Add, Edit, x%posX% y+-16 h19 w33 Limit3 vBrivGemFarm_BrivFeatSwap_TargetE gBrivGemFarm_BrivFeatSwap_Target, 0
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapsMadeThisRunText xs+%xSection% y+%ySpacing%, SwapsMadeThisRun:
        Gui, ICScriptHub:Add, Text, vBrivFeatSwapsMadeThisRunValue x+%xSpacing% w40
        ; Resize
        GuiControlGet, posG, ICScriptHub:Pos, BGFBFS_SkipSetup
        GuiControlGet, pos, ICScriptHub:Pos, BrivFeatSwapsMadeThisRunValue
        local newHeight := posY + posH - posGY + this.YSection
        local newWidth := posX + posW - posGX + this.XSection
        GuiControl, ICScriptHub:Move, BGFBFS_SkipSetup, h%newHeight% w%newWidth%
        GuiControlGet, posG, ICScriptHub:Pos, BGFBFS_SkipSetup
        GuiControlGet, pos, ICScriptHub:Pos, BGFBFS_Preset
        newWidth := posGX + posGW - posX
        GuiControl, ICScriptHub:Move, BGFBFS_Preset, w%newWidth%
    }

    SetupStacksSetupGroup()
    {
        global
        local xSection := this.XSection
        local xSpacing := this.XSpacing
        local ySpacing := this.YSpacing
        local yTitleSpacing := this.YTitleSpacing
        GuiControlGet, posG, ICScriptHub:Pos, BGFBFS_SkipSetup
        local nextPos := posGX + posGW + xSection
        Gui, ICScriptHub:Font, w700
        Gui, ICScriptHub:Add, GroupBox, Section x%nextPos% y%posGY% vBGFBFS_StacksSetup, Stacks Calculator
        Gui, ICScriptHub:Font, w400
        GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        Gui, ICScriptHub:Add, ComboBox, xs+%xSection% ys+%yTitleSpacing% w60 Limit5 vBGFBFS_ResetArea gBGFBFS_ResetArea
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Text, vBGFBFS_ResetAreaText x+5 yp+4, Reset area (Modron reset: Game closed)
        GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        Gui, ICScriptHub:Add, Edit, xs+%xSection% y+%ySpacing% w60 Limit5 vBGFBFS_BrivMetalbornArea gBGFBFS_BrivMetalbornArea, 1
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Text, vBGFBFS_BrivMetalbornAreaText x+5 yp+4, Briv Metalborn area
        GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        Gui, ICScriptHub:Add, Edit, xs+%xSection% y+%ySpacing% w100 Limit15 vBGFBFS_StacksRequired gBGFBFS_StacksRequired, 0
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Text, vBGFBFS_StacksRequiredText x+5 yp+4, Stacks required
        Gui, ICScriptHub:Add, Text, vBGFBFS_JumpsText xs+%xSection% y+%yTitleSpacing% w260
        Gui, ICScriptHub:Add, Text, vBGFBFS_WalksText xs+%xSection% y+%ySpacing% w260
        ; Resize
        GuiControlGet, posG2, ICScriptHub:Pos, BGFBFS_StacksSetup
        GuiControlGet, pos, ICScriptHub:Pos, BGFBFS_ResetAreaText
        local newWidth := posX + posW - posG2X + this.XSection
        GuiControl, ICScriptHub:Move, BGFBFS_StacksSetup, h%posGH% w%newWidth%
    }

    SetupPreferredBrivJumpZonesGroup()
    {
        global
        local leftAlign := this.LeftAlign
        local xSpacing := this.XSpacing
        local ySpacing := this.YSpacing
        local yTitleSpacing := this.YTitleSpacing
        GuiControlGet, posG, ICScriptHub:Pos, BGFBFS_SkipSetup
        local nextPos := posGY + posGH + ySpacing
        Gui, ICScriptHub:Font, w700
        Gui, ICScriptHub:Add, GroupBox, Section x%posGX% y%nextPos% vBGFBFS_PreferredBrivJumpZones, Preferred Briv Jump Zones
        Gui, ICScriptHub:Font, w400
        GuiControlGet, pos, ICScriptHub:Pos, BGFBFS_PreferredBrivJumpZones
        this.BuildModTable(posX + this.XSection, posY)
        ; Resize
        GuiControlGet, posG, ICScriptHub:Pos, BGFBFS_PreferredBrivJumpZones
        GuiControlGet, pos, ICScriptHub:Pos, BGFBFS_CopyPasteBGFAS_Mod_50_50
        local newHeight := posY + posH - posGY + this.YSection
        local newWidth := posX + posW - posGX + this.XSection
        GuiControl, ICScriptHub:Move, BGFBFS_PreferredBrivJumpZones, h%newHeight% w%newWidth%
    }

    SetupBGFLUGroup()
    {
        global
        local xSpacing := this.XSpacing
        local ySpacing := this.YSpacing
        local yTitleSpacing := this.YTitleSpacing
        Gui, ICScriptHub:Font, w700
        Gui, ICScriptHub:Add, GroupBox, Section xs y+%yTitleSpacing% vBGFBFS_BGFLU, BrivGemFarm LevelUp
        Gui, ICScriptHub:Font, w400
        ; Link to LevelUp addon
        Gui, ICScriptHub:Add, Text, Hidden xp yp vBGFBFS_GetLevelUpAddonText, % "Use "
        GUIFunctions.UseThemeTextColor("SpecialTextColor1")
        local link := "https://github.com/imp444/IC_Addons/tree/main/IC_BrivGemFarm_LevelUp_Extra"
        Gui, ICScriptHub:Add, Link, Hidden x+0 vBGFBFS_GetLevelUpAddonLink hwndBGFBFS_GetLevelUpAddonLink, <a href="%link%">LevelUp</a>
        this.LinkUseDefaultColor(BGFBFS_GetLevelUpAddonLink)
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Text, Hidden x+0 vBGFBFS_GetLevelUpAddonText2, % " addon to walk z1-4."
        ; BrivMinLevelArea
        GUIFunctions.UseThemeTextColor("InputBoxTextColor")
        Gui, ICScriptHub:Add, Edit, -Background Disabled xs+%xSpacing% ys+%yTitleSpacing% w50 Limit4 vBGFBFS_BrivMinLevelArea, 1
        GUIFunctions.UseThemeTextColor()
        Gui, ICScriptHub:Add, Text, x+5 yp+4 vBGFBFS_BrivMinLevelAreaText, Minimum area to reach before leveling Briv
        ; Resize
        GuiControlGet, posG, ICScriptHub:Pos, BGFBFS_BGFLU
        GuiControlGet, posG2, ICScriptHub:Pos, BGFBFS_PreferredBrivJumpZones
        GuiControlGet, pos, ICScriptHub:Pos, BGFBFS_BrivMinLevelArea
        local newHeight := posY + posH - posGY + this.YSection
        GuiControl, ICScriptHub:Move, BGFBFS_BGFLU, h%newHeight% w%posG2W%
    }

    ; https://www.autohotkey.com/boards/viewtopic.php?t=37894
    LinkUseDefaultColor(hLink, Use := True)
    {
       VarSetCapacity(LITEM, 4278, 0)            ; 16 + (MAX_LINKID_TEXT * 2) + (L_MAX_URL_LENGTH * 2)
       NumPut(0x03, LITEM, "UInt")               ; LIF_ITEMINDEX (0x01) | LIF_STATE (0x02)
       NumPut(Use ? 0x10 : 0, LITEM, 8, "UInt")  ; ? LIS_DEFAULTCOLORS : 0
       NumPut(0x10, LITEM, 12, "UInt")           ; LIS_DEFAULTCOLORS
       While DllCall("SendMessage", "Ptr", hLink, "UInt", 0x0702, "Ptr", 0, "Ptr", &LITEM, "UInt") ; LM_SETITEM
          NumPut(A_Index, LITEM, 4, "Int")
       GuiControl, +Redraw, %hLink%
    }

    ; Builds one set of checkboxes for PreferredBrivJumpZones (e.g. Mod5 and associated checks)
    BuildModTable(xLoc, yLoc)
    {
        leftAlign := xLoc
        Loop, 50
        {
            if(Mod(A_Index, 10) != 1)
                xLoc += 35
            else
            {
                xLoc := leftAlign
                yLoc += 20
            }
            this.AddControlCheckbox(xLoc, yLoc, A_Index)
        }
    }

    AddControlCheckbox(xLoc, yLoc, loopCount)
    {
        global
        Gui, ICScriptHub:Add, Checkbox, vBGFBFS_CopyPasteBGFAS_Mod_50_%loopCount% Checked x%xLoc% y%yLoc% gBGFBFS_Mod50CheckBoxes, % loopCount
    }
}