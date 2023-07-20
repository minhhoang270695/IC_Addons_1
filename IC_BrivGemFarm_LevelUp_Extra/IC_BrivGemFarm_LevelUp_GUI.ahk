SM_CXVSCROLL := 2
CBN_DROPDOWN := 7
CBN_SELENDCANCEL := 10
WM_COMMAND := 0x0111
CB_DELETESTRING := 0x0144
CB_GETCOUNT := 0x146
CB_GETCURSEL := 0x147
CB_GETDROPPEDCONTROLRECT := 0x0152
CB_SETITEMHEIGHT := 0x0153
CB_GETDROPPEDSTATE := 0x0157
CB_SETDROPPEDWIDTH := 0x0160
CB_GETCOMBOBOXINFO := 0x0164

GUIFunctions.AddTab("BrivGF LevelUp")
; Add GUI fields to this addon's tab.
Gui, ICScriptHub:Tab, BrivGF LevelUp

GUIFunctions.UseThemeTextColor("HeaderTextColor", 700)
Gui, ICScriptHub:Add, Text, Section vBrivGemFarmLevelUpStatus, Status:
Gui, ICScriptHub:Add, Text, x+5 w170 vBrivGemFarmLevelUpStatusText, Not Running

GUIFunctions.UseThemeTextColor("WarningTextColor", 700)
Gui, ICScriptHub:Add, Text, xs ys+15 w500 vBrivGemFarmLevelUpStatusWarning,
GUIFunctions.UseThemeTextColor() ; WARNING: Addon was loaded too late. Stop/start Gem Farm to resume.

; Create minLevel, maxLevel, order buttons/edits
xSection := ySection := 10
Gui, ICScriptHub:Font, w700
wMinMaxSettingsGroup := 465
wGroup := wMinMaxSettingsGroup - 2 * xSection
Gui, ICScriptHub:Add, GroupBox, Section xs w%wMinMaxSettingsGroup% h670 vMinMaxSettingsGroup, BrivGemFarm LevelUp Settings
Gui, ICScriptHub:Font, w400
yTitleSpacing := 2 * ySection
Gui, ICScriptHub:Add, Text, xs+%xSection% ys+%yTitleSpacing%, Seat
Gui, ICScriptHub:Add, Text, x+51, Name
Gui, ICScriptHub:Add, Text, x+64 vMinLevelText, MinLevel
Gui, ICScriptHub:Add, Text, x+31 vMaxLevelText, MaxLevel
leftAlign := 12
xSpacing := 15
ySpacing := 10
Loop, 12
{
    AddSeat(xSpacing, ySpacing, A_Index)
}
; Add settings for the next seat
AddSeat(xSpacing, ySpacing, seat)
{
    global
    Gui, ICScriptHub:Add, Text, Center xs+%leftAlign% y+%ySpacing% w15, % seat
    GUIFunctions.UseThemeTextColor("InputBoxTextColor")
    Gui, ICScriptHub:Add, DropDownList , vDDL_BrivGemFarmLevelUpName_%seat% gBrivGemFarm_LevelUp_Name x+%xSpacing% y+-16 w111
    Gui, ICScriptHub:Add, ComboBox, Limit6 hwndHBrivGemFarmLevelUpMinLevel_%seat% vCombo_BrivGemFarmLevelUpMinLevel_%seat% gBrivGemFarm_LevelUp_MinMax_Clamp x+%xSpacing% w60
    Gui, ICScriptHub:Add, ComboBox, Limit6 hwndHBrivGemFarmLevelUpMaxLevel_%seat% vCombo_BrivGemFarmLevelUpMaxLevel_%seat% gBrivGemFarm_LevelUp_MinMax_Clamp x+%xSpacing% w60
    GUIFunctions.UseThemeTextColor()
}

Gui, ICScriptHub:Add, Text, xs+%xSection% y+%yTitleSpacing% vLoadFormationText, Formation
Gui, ICScriptHub:Add, DropDownList, x+10 y+-17 w35 AltSubmit Disabled hwndBrivGemFarm_LevelUp_LoadFormation vBrivGemFarm_LevelUp_LoadFormation gBrivGemFarm_LevelUp_LoadFormation, Q||W|E
PostMessage, CB_SETITEMHEIGHT, -1, 17,, ahk_id %BrivGemFarm_LevelUp_LoadFormation%
Gui, ICScriptHub:Add, CheckBox, x+%xSpacing% y+-17 vBrivGemFarm_LevelUp_ShowSpoilers gBrivGemFarm_LevelUp_ShowSpoilers, Show spoilers
GUIFunctions.UseThemeTextColor("ErrorTextColor", 700)
Gui, ICScriptHub:Add, Text, x+%xSpacing% w220 vBrivGemFarm_LevelUp_NoFormationText,
GUIFunctions.UseThemeTextColor()

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, Section xs+%xSection% y+%yTitleSpacing% w%wGroup% h50 vDefaultSettingsGroup, Default Settings
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Button, xs+%leftAlign% yp+20 Disabled vBrivGemFarm_LevelUp_Default gBrivGemFarm_LevelUp_Default, Load default settings
Gui, ICScriptHub:Add, Text, x+%xSpacing% yp+5 w100 vBrivGemFarm_LevelUp_SettingsStatusText, % "No settings."
Gui, ICScriptHub:Add, Button, xp yp-5 Hidden vBrivGemFarm_LevelUp_Save gBrivGemFarm_LevelUp_Save, Save
Gui, ICScriptHub:Add, Button, x+%xSpacing% Hidden vBrivGemFarm_LevelUp_Changes gBrivGemFarm_LevelUp_Changes, Show unsaved changes
Gui, ICScriptHub:Add, Button, x+%xSpacing% Hidden vBrivGemFarm_LevelUp_Undo gBrivGemFarm_LevelUp_Undo, Undo
Gui, ICScriptHub:Add, Text, xs+%leftAlign% y+%ySpacing% vDefaultMinLevelText, Default min level:
Gui, ICScriptHub:Add, Radio, x+5 vBrivGemFarm_LevelUp_MinRadio0 gBrivGemFarm_LevelUp_MinDefault, 0
Gui, ICScriptHub:Add, Radio, x+1 vBrivGemFarm_LevelUp_MinRadio1 gBrivGemFarm_LevelUp_MinDefault, 1
Gui, ICScriptHub:Add, Text, x+5 vDefaultMaxLevelText, |   Default max level:
Gui, ICScriptHub:Add, Radio, x+5 vBrivGemFarm_LevelUp_MaxRadio1 gBrivGemFarm_LevelUp_MaxDefault, 1
Gui, ICScriptHub:Add, Radio, x+1 vBrivGemFarm_LevelUp_MaxRadioLast gBrivGemFarm_LevelUp_MaxDefault, Last upgrade
GuiControlGet, pos, ICScriptHub:Pos, DefaultMinLevelText
GuiControlGet, posS, ICScriptHub:Pos, DefaultSettingsGroup
newHeight := posY + posH - posSY + ySection
GuiControl, ICScriptHub:Move, DefaultSettingsGroup, h%newHeight%

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, Section xs y+%yTitleSpacing% w%wGroup% h50 vMinSettingsGroup, Min Settings
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, CheckBox, xs+%leftAlign% yp+20 vBrivGemFarm_LevelUp_ForceBrivShandie gBrivGemFarm_LevelUp_ForceBrivShandie, Level up Briv/Shandie to MinLevel first
Gui, ICScriptHub:Add, CheckBox, x+%xSpacing% vBrivGemFarm_LevelUp_SkipMinDashWait gBrivGemFarm_LevelUp_SkipMinDashWait, Skip DashWait after Min Leveling
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs+%leftAlign% y+%ySpacing% w50 Limit2 vBrivGemFarm_LevelUp_MaxSimultaneousInputs gBrivGemFarm_LevelUp_MaxSimultaneousInputs
GUIFunctions.UseThemeTextColor()
Gui, ICScriptHub:Add, Text, x+5 y+-18 vBrivGemFarm_LevelUp_MaxSimultaneousInputsText, Maximum simultaneous F keys inputs during MinLevel
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs+%leftAlign% y+%ySpacing% w50 Limit5 vBrivGemFarm_LevelUp_MinLevelTimeout gBrivGemFarm_LevelUp_MinLevelTimeout
GUIFunctions.UseThemeTextColor()
Gui, ICScriptHub:Add, Text, x+5 y+-18 vBrivGemFarm_LevelUp_MinLevelTimeoutText, MinLevel timeout (ms)
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, ComboBox, xs+%leftAlign% y+%ySpacing% w50 Limit5 hwndHBrivGemFarmLevelUpBrivMinLevelStacking vCombo_BrivGemFarmLevelUpBrivMinLevelStacking gBrivGemFarm_LevelUp_MinMax_Clamp
GUIFunctions.UseThemeTextColor()
Gui, ICScriptHub:Add, Text, x+5 y+-18 vBrivGemFarm_LevelUp_BrivMinLevelStackingText, Briv MinLevel before stacking
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs+%leftAlign% y+%ySpacing% w50 Limit4 vBrivGemFarm_LevelUp_BrivMinLevelArea gBrivGemFarm_LevelUp_BrivMinLevelArea
GUIFunctions.UseThemeTextColor()
Gui, ICScriptHub:Add, Text, x+5 y+-18 vBrivGemFarm_LevelUp_BrivMinLevelAreaText, Minimum area to reach before leveling Briv
GuiControlGet, pos, ICScriptHub:Pos, BrivGemFarm_LevelUp_BrivMinLevelArea
GuiControlGet, posS, ICScriptHub:Pos, MinSettingsGroup
newHeight := posY + posH - posSY + ySection
GuiControl, ICScriptHub:Move, MinSettingsGroup, h%newHeight%

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, Section xs y+%yTitleSpacing% w%wGroup% h50 vFailRunRecoverySettingsGroup, Fail Run Recovery Settings
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, CheckBox, xs+%leftAlign% yp+20 vBrivGemFarm_LevelUp_LevelToSoftCapFailedConversion gBrivGemFarm_LevelUp_LevelToSoftCapFailedConversion, Level champions to soft cap after failed conversion
Gui, ICScriptHub:Add, CheckBox, x+%xSpacing% vBrivGemFarm_LevelUp_LevelToSoftCapFailedConversionBriv gBrivGemFarm_LevelUp_LevelToSoftCapFailedConversionBriv, Briv included
GuiControlGet, pos, ICScriptHub:Pos, BrivGemFarm_LevelUp_LevelToSoftCapFailedConversionBriv
GuiControlGet, posS, ICScriptHub:Pos, FailRunRecoverySettingsGroup
newHeight := posY + posH - posSY + ySection
GuiControl, ICScriptHub:Move, FailRunRecoverySettingsGroup, h%newHeight%

GuiControlGet, posS, ICScriptHub:Pos, MinMaxSettingsGroup
newHeight := posY + posH - posSY + yTitleSpacing + 1
GuiControl, ICScriptHub:Move, MinMaxSettingsGroup, h%newHeight%

yLoadDefinitionsSpacing := 2 * yTitleSpacing
Gui, ICScriptHub:Add, Button, xs-%xSection% y+%yLoadDefinitionsSpacing% Disabled vBrivGemFarm_LevelUp_LoadDefinitions gBrivGemFarm_LevelUp_LoadDefinitions, Load Definitions
Gui, ICScriptHub:Add, Text, x+10 y+-18 w450 R3 vBrivGemFarm_LevelUp_DefinitionsStatus, % "No definitions."

; Temp settings ListView
Gui, IC_BrivGemFarm_LevelUp_TempSettings:New, -MaximizeBox -Resize
GUIFunctions.LoadTheme("IC_BrivGemFarm_LevelUp_TempSettings")
GUIFunctions.UseThemeBackgroundColor()
GUIFunctions.UseThemeTextColor()
Gui IC_BrivGemFarm_LevelUp_TempSettings:Add, GroupBox, w330 h310, BrivGemFarm LevelUp Settings
Gui IC_BrivGemFarm_LevelUp_TempSettings:Add, ListView, xp+15 yp+24 w300 h270 NoSortHdr vBrivTempSettingsID , Setting|Current|New
GUIFunctions.UseThemeListViewBackgroundColor("BrivTempSettingsID")
GUIFunctions.LoadTheme()

OnMessage(WM_COMMAND, "CheckComboStatus")
OnMessage(0x200, Func("CheckComboStatus"))

; Checks performed on combo mouseover / selection cancel
CheckComboStatus(W)
{
    IC_BrivGemFarm_LevelUp_GUI.CheckComboStatus(W)
}

; Switch names
BrivGemFarm_LevelUp_Name()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_Name()
}

; Input upgrade level when selected from DDL, then verify that min/max level inputs are in 0-999999 range
BrivGemFarm_LevelUp_MinMax_Clamp()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_MinMax_Clamp()
}

; Load formation to the GUI
BrivGemFarm_LevelUp_LoadFormation()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_LoadFormation()
}

; Spoilers
BrivGemFarm_LevelUp_ShowSpoilers()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_ShowSpoilers()
}

; Default settings button
BrivGemFarm_LevelUp_Default()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_Default()
}

; Save settings button
BrivGemFarm_LevelUp_Save()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_Save()
}

; TempsSettings changes
BrivGemFarm_LevelUp_Changes()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_Changes()
}

; Undo temp settings button
BrivGemFarm_LevelUp_Undo()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_Undo()
}

BrivGemFarm_LevelUp_MinDefault()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_MinDefault()
}

BrivGemFarm_LevelUp_MaxDefault()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_MaxDefault()
}

; Force Briv/Shandie MinLevel
BrivGemFarm_LevelUp_ForceBrivShandie()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_ForceBrivShandie()
}

; Skip early Dashwait
BrivGemFarm_LevelUp_SkipMinDashWait()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_SkipMinDashWait()
}

; Maximum number of simultaneous F keys inputs during MinLevel
BrivGemFarm_LevelUp_MaxSimultaneousInputs()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_MaxSimultaneousInputs()
}

; Maximum number of simultaneous F keys inputs during MinLevel
BrivGemFarm_LevelUp_MinLevelTimeout()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_MinLevelTimeout()
}

; BrivMinLevelArea
BrivGemFarm_LevelUp_BrivMinLevelArea()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_BrivMinLevelArea()
}

; Level champions to soft cap after a failed conversion to reach stack zone faster
BrivGemFarm_LevelUp_LevelToSoftCapFailedConversion()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_LevelToSoftCapFailedConversion()
}

; Level champions to soft cap after a failed conversion to reach stack zone faster (Briv is excluded, desireable for early stacking)
BrivGemFarm_LevelUp_LevelToSoftCapFailedConversionBriv()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_LevelToSoftCapFailedConversionBriv()
}

; Load new definitions
BrivGemFarm_LevelUp_LoadDefinitions()
{
    IC_BrivGemFarm_LevelUp_GUI.BrivGemFarm_LevelUp_LoadDefinitions()
}

Class IC_BrivGemFarm_LevelUp_GUI
{
    ; Switch names
    BrivGemFarm_LevelUp_Name()
    {
        global
        Gui, ICScriptHub:Submit, NoHide
        local name := % %A_GuiControl%
        local heroData := g_HeroDefines.HeroDataByName[name]
        IC_BrivGemFarm_LevelUp_Seat.Seats[heroData.seat_id].UpdateMinMaxLevels(name)
    }

    ; Input upgrade level when selected from DDL, then verify that min/max level inputs are in 0-999999 range
    BrivGemFarm_LevelUp_MinMax_Clamp()
    {
        global
        local beforeSubmit := % %A_GuiControl%
        Gui, ICScriptHub:Submit, NoHide
        local value := % %A_GuiControl%
        local clamped := value
        Loop, Parse, clamped, :, " "
        {
            clamped := A_LoopField
            break
        }
        if clamped is not digit
        {
            GuiControl, ICScriptHub:Text, %A_GuiControl%, % beforeSubmit
            Gui, ICScriptHub:Submit, NoHide
            return
        }
        if (clamped != value)
            GuiControl, ICScriptHub:Text, %A_GuiControl%, % clamped
        local split := StrSplit(A_GuiControl, "_")
        local heroId := IC_BrivGemFarm_LevelUp_Seat.Seats[split[3]].GetCurrentHeroData().id
        Switch split[2]
        {
            Case "BrivGemFarmLevelUpMinLevel":
                g_BrivGemFarm_LevelUp.TempSettings.AddSetting(["BrivGemFarm_LevelUp_Settings", "minLevels", heroId], clamped)
            Case "BrivGemFarmLevelUpMaxLevel":
                g_BrivGemFarm_LevelUp.TempSettings.AddSetting(["BrivGemFarm_LevelUp_Settings", "maxLevels", heroId], clamped)
            Case "BrivGemFarmLevelUpBrivMinLevelStacking":
                g_BrivGemFarm_LevelUp.TempSettings.AddSetting("BrivMinLevelStacking", clamped)
            Default:
                return
        }
    }

    ; Load formation to the GUI
    BrivGemFarm_LevelUp_LoadFormation()
    {
        global
        Gui, ICScriptHub:Submit, NoHide
        GuiControl, ICScriptHub:Disable, BrivGemFarm_LevelUp_LoadFormation
        Sleep, 20
        g_BrivGemFarm_LevelUp.LoadFormation(%A_GuiControl%)
        GuiControl, ICScriptHub:Enable, BrivGemFarm_LevelUp_LoadFormation
    }

    ; Spoilers
    BrivGemFarm_LevelUp_ShowSpoilers()
    {
        global
        Gui, ICScriptHub:Submit, NoHide
        local showSpoilers := BrivGemFarm_LevelUp_ShowSpoilers
        g_BrivGemFarm_LevelUp.TempSettings.AddSetting("ShowSpoilers", showSpoilers)
        g_BrivGemFarm_LevelUp.ToggleSpoilers(showSpoilers) ; Effect is immediate
    }

    ; Default settings button
    BrivGemFarm_LevelUp_Default()
    {
        global
        MsgBox, 4, , Restore Default settings?, 10
        IfMsgBox, No
            Return
        IfMsgBox, Timeout
            Return
        GuiControl, ICScriptHub:Disable, BrivGemFarm_LevelUp_Default
        g_BrivGemFarm_LevelUp.LoadSettings(true)
        GuiControl, ICScriptHub:Enable, BrivGemFarm_LevelUp_Default
    }

    ; Save settings button
    BrivGemFarm_LevelUp_Save()
    {
        global
        MsgBox, 4, , Save and apply changes?, 10
        IfMsgBox, No
            Return
        IfMsgBox, Timeout
            Return
        Gui, IC_BrivGemFarm_LevelUp_TempSettings:Hide
        Gui, ICScriptHub:Submit, NoHide
        g_BrivGemFarm_LevelUp.SaveSettings(true)
    }

    ; TempsSettings changes
    BrivGemFarm_LevelUp_Changes()
    {
        global
        g_BrivGemFarm_LevelUp.TempSettings.ReloadTempSettingsDisplay()
        Gui, IC_BrivGemFarm_LevelUp_TempSettings:Show
    }

    ; Undo temp settings button
    BrivGemFarm_LevelUp_Undo()
    {
        global
        MsgBox, 4, , Undo all changes?, 10
        IfMsgBox, No
            Return
        IfMsgBox, Timeout
            Return
        g_BrivGemFarm_LevelUp.UndoTempSettings()
        Gui, IC_BrivGemFarm_LevelUp_TempSettings:Hide
    }

    BrivGemFarm_LevelUp_MinDefault()
    {
        global
        Gui, ICScriptHub:Submit, NoHide
        g_BrivGemFarm_LevelUp.TempSettings.AddSetting("DefaultMinLevel", BrivGemFarm_LevelUp_MinRadio0 ? 0 : 1)
        g_BrivGemFarm_LevelUp.FillMissingDefaultSettings()
    }

    BrivGemFarm_LevelUp_MaxDefault()
    {
        global
        Gui, ICScriptHub:Submit, NoHide
        g_BrivGemFarm_LevelUp.TempSettings.AddSetting("DefaultMaxLevel", BrivGemFarm_LevelUp_MaxRadio1 ? 1 : "Last")
        g_BrivGemFarm_LevelUp.FillMissingDefaultSettings()
    }

    ; Force Briv/Shandie MinLevel
    BrivGemFarm_LevelUp_ForceBrivShandie()
    {
        global
        Gui, ICScriptHub:Submit, NoHide
        g_BrivGemFarm_LevelUp.TempSettings.AddSetting("ForceBrivShandie", BrivGemFarm_LevelUp_ForceBrivShandie)
    }

    ; Skip early Dashwait
    BrivGemFarm_LevelUp_SkipMinDashWait()
    {
        global
        Gui, ICScriptHub:Submit, NoHide
        g_BrivGemFarm_LevelUp.TempSettings.AddSetting("SkipMinDashWait", BrivGemFarm_LevelUp_SkipMinDashWait)
    }

    ; Maximum number of simultaneous F keys inputs during MinLevel
    BrivGemFarm_LevelUp_MaxSimultaneousInputs()
    {
        global
        local beforeSubmit := BrivGemFarm_LevelUp_MaxSimultaneousInputs
        Gui, ICScriptHub:Submit, NoHide
        local maxSimultaneousInputs := BrivGemFarm_LevelUp_MaxSimultaneousInputs
        if maxSimultaneousInputs is not digit
        {
            GuiControl, ICScriptHub:Text, BrivGemFarm_LevelUp_MaxSimultaneousInputs, % beforeSubmit
            return
        }
        else if (maxSimultaneousInputs < 1)
        {
            maxSimultaneousInputs := 1
            GuiControl, ICScriptHub:Text, BrivGemFarm_LevelUp_MaxSimultaneousInputs, % maxSimultaneousInputs
        }
        g_BrivGemFarm_LevelUp.TempSettings.AddSetting("MaxSimultaneousInputs", maxSimultaneousInputs)
    }

    ; Maximum number of simultaneous F keys inputs during MinLevel
    BrivGemFarm_LevelUp_MinLevelTimeout()
    {
        global
        local beforeSubmit := BrivGemFarm_LevelUp_MinLevelTimeout
        Gui, ICScriptHub:Submit, NoHide
        local minLevelTimeout := BrivGemFarm_LevelUp_MinLevelTimeout
        if minLevelTimeout is not digit
            GuiControl, ICScriptHub:Text, BrivGemFarm_LevelUp_MinLevelTimeout, % beforeSubmit
        else
            g_BrivGemFarm_LevelUp.TempSettings.AddSetting("MinLevelTimeout", minLevelTimeout)
    }

    ; BrivMinLevelArea
    BrivGemFarm_LevelUp_BrivMinLevelArea()
    {
        global
        local beforeSubmit := BrivGemFarm_LevelUp_BrivMinLevelArea
        Gui, ICScriptHub:Submit, NoHide
        local brivMinLevelArea := BrivGemFarm_LevelUp_BrivMinLevelArea
        if brivMinLevelArea is not digit
        {
            GuiControl, ICScriptHub:Text, BrivGemFarm_LevelUp_BrivMinLevelArea, % beforeSubmit
            return
        }
        else if (brivMinLevelArea < 1)
        {
            brivMinLevelArea := 1
            GuiControl, ICScriptHub:Text, BrivGemFarm_LevelUp_BrivMinLevelArea, % brivMinLevelArea
        }
        g_BrivGemFarm_LevelUp.TempSettings.AddSetting("BrivMinLevelArea", brivMinLevelArea)
    }

    ; Level champions to soft cap after a failed conversion to reach stack zone faster
    BrivGemFarm_LevelUp_LevelToSoftCapFailedConversion()
    {
        global
        Gui, ICScriptHub:Submit, NoHide
        g_BrivGemFarm_LevelUp.TempSettings.AddSetting("LevelToSoftCapFailedConversion", BrivGemFarm_LevelUp_LevelToSoftCapFailedConversion)
    }

    ; Level champions to soft cap after a failed conversion to reach stack zone faster (Briv is excluded, desireable for early stacking)
    BrivGemFarm_LevelUp_LevelToSoftCapFailedConversionBriv()
    {
        global
        Gui, ICScriptHub:Submit, NoHide
        g_BrivGemFarm_LevelUp.TempSettings.AddSetting("LevelToSoftCapFailedConversionBriv", BrivGemFarm_LevelUp_LevelToSoftCapFailedConversionBriv)
    }

    ; Load new definitions
    BrivGemFarm_LevelUp_LoadDefinitions()
    {
        global
        GuiControl, ICScriptHub:Disable, BrivGemFarm_LevelUp_LoadDefinitions
        g_DefinesLoader.Start(false, true)
    }

    ; Checks performed on combo mouseover / selection cancel
    CheckComboStatus(W)
    {
        global
        local arr := this.GetCurrentlyDroppedCombo()
        if (local seat_ID := arr[1])
        {
            if ((W >> 16) & 0xFFFF == CBN_SELENDCANCEL) ; Refresh min/max values after a ComboBox sends a selection cancel event to the parent tab
            {
                ToolTip
                if (seat_ID == 58)
                {
                    local ctrlH := arr[2], k := "BrivMinLevelStacking"
                    local brivMinLevelStacking := g_BrivGemFarm_LevelUp.TempSettings.TempSettings.HasKey(k) ? g_BrivGemFarm_LevelUp.TempSettings.TempSettings[k] : g_BrivGemFarm_LevelUp.Settings[k]
                    SendMessage, CB_GETCOUNT, 0, 0,, ahk_id %ctrlH%
                    local count := Errorlevel
                    GuiControl, ICScriptHub:, Combo_BrivGemFarmLevelUpBrivMinLevelStacking, % brivMinLevelStacking ; Add item
                    GuiControl, ICScriptHub:Text, Combo_BrivGemFarmLevelUpBrivMinLevelStacking, % brivMinLevelStacking ; so only the level is kept in edit
                    PostMessage, CB_DELETESTRING, count, 0,, ahk_id %ctrlH% ; Remove item
                }
                else
                {
                    local choice := % DDL_BrivGemFarmLevelUpName_%seat_ID%
                    if (choice == g_HeroDefines.HeroDataByID[58].name) ; After %choice%, ErrorLevel is set to 1 for an unknown reason
                        GuiControl, ICScriptHub:ChooseString, DDL_BrivGemFarmLevelUpName_5, % "|" . choice
                    else
                        GuiControl, ICScriptHub:ChooseString, %choice%, % "|" . choice
                }
            }
            else if (this.MouseOverComboBoxList(ctrlH := arr[2])) ; Show current selection as tooltip
            {
                OnMessage(0x200, "CheckControlForToolTip",0)
                func := ObjBindMethod(this, "RemoveToolTip")
                SetTimer, %func%, -500
                SendMessage, CB_GETCURSEL, 0, 0,, ahk_id %ctrlH%
                local currentSel := ErrorLevel ; 0 based
                heroData := IC_BrivGemFarm_LevelUp_Seat.Seats[(seat_ID == 58 ? 5 : seat_ID)].GetCurrentHeroData()
                ToolTip, % IC_BrivGemFarm_LevelUp_Functions.WrapText(heroData.UpgradeDescriptionFromIndex(currentSel + 1))
                SetTimer, HideToolTip, Delete
                OnMessage(0x200, "CheckControlForToolTip")
            }
        }
    }

    ; Remove comboBox toolip when not hovering
    RemoveToolTip()
    {
        arr := this.GetCurrentlyDroppedCombo()
        MouseGetPos,,,, VarControl ; CheckControlForToolTip()
        if (!VarControl AND !(arr[1] AND this.MouseOverComboBoxList(arr[2])))
            ToolTip
    }

    ; Returns an array containing the corresponding seatID / control Hwnd of the currently dropped combo
    GetCurrentlyDroppedCombo()
    {
        global
        GuiControlGet, CurrentTab,, ModronTabControl, Tab
        if (CurrentTab != "BrivGF LevelUp")
            return
        Loop, 12
        {
            local ctrlHwnd := HBrivGemFarmLevelUpMinLevel_%A_Index%
            SendMessage, CB_GETDROPPEDSTATE, 0, 0,, ahk_id %ctrlHwnd%
            if (Errorlevel)
                return [A_Index, ctrlHwnd]
            ctrlHwnd := HBrivGemFarmLevelUpMaxLevel_%A_Index%
            SendMessage, CB_GETDROPPEDSTATE, 0, 0,, ahk_id %ctrlHwnd%
            if (Errorlevel)
                return [A_Index, ctrlHwnd]
        }
        ctrlHwnd := HBrivGemFarmLevelUpBrivMinLevelStacking
        SendMessage, CB_GETDROPPEDSTATE, 0, 0,, ahk_id %ctrlHwnd%
        if (Errorlevel)
            return [58, ctrlHwnd]
    }

    ; Returns true if the mouse is within the rectangle of a combobox's item list
    MouseOverComboBoxList(controlID)
    {
        global
        SysGet, scrollW, %SM_CXVSCROLL% ; Scrollbar width
        VarSetCapacity(COMBOBOXINFO, size := 40 + A_PtrSize*3, 0)
        NumPut(size, COMBOBOXINFO)
        SendMessage, CB_GETCOMBOBOXINFO,, &COMBOBOXINFO,, ahk_id %controlID%
        local yMaxEdit := NumGet(COMBOBOXINFO, 16, "Int") ; Combo edit height
        VarSetCapacity(RECT, 16, 0)
        NumPut(16, RECT)
        SendMessage, CB_GETDROPPEDCONTROLRECT,, &RECT,, ahk_id %controlID% ; Full combo rect
        local xMin := NumGet(RECT, 0, "Int")
        local yMin := NumGet(RECT, 4, "Int") + yMaxEdit
        local xMax := NumGet(RECT, 8, "Int") - scrollW
        local yMax := NumGet(RECT, 12, "Int")
        local height := yMax - yMin
        local monitor := IC_BrivGemFarm_LevelUp_Functions.GetMonitor(controlID)
        SysGet, monitorCoords, Monitor, %monitor%
        if (height >= monitorCoordsBottom) ; List bigger than screen height
        {
            yMin := 0
            yMax := monitorCoordsBottom
        }
        else if (yMax > monitorCoordsBottom) ; List opens upwards instead of downwards
        {
            yMax := yMin - yMaxEdit
            yMin := yMax - height
        }
        CoordMode, Mouse, Screen
        MouseGetPos, xPos, yPos
        CoordMode, Mouse, Client
        return (xMin <= xPos) AND (xPos <= xMax) AND (yMin <= yPos) AND (yPos <= yMax)
    }
}