; Test to see if BrivGemFarm addon is available.
if(IsObject(IC_BrivGemFarm_Component))
{
    IC_BrivGemFarm_HybridTurboStacking_Functions.InjectAddon()
    global g_HybridTurboStacking := new IC_BrivGemFarm_HybridTurboStacking_Component
    global g_HybridTurboStackingGui := new IC_BrivGemFarm_HybridTurboStacking_GUI
    g_HybridTurboStacking.Init()
}
else
{
    GuiControl, ICScriptHub:Text, BGFHTS_StatusText, WARNING: This addon needs IC_BrivGemFarm enabled.
    return
}

/*  IC_BrivGemFarm_HybridTurboStacking_Component

    Class that manages the GUI for HybridTurboStacking.
    Starts automatically on script launch and waits for Briv Gem Farm to be started,
    then stops/starts every time buttons on the main Briv Gem Farm window are clicked.
*/
Class IC_BrivGemFarm_HybridTurboStacking_Component
{
    static MAX_MELF_FORECAST_ROWS := 1000

    Settings := ""
    TimerFunction := ObjBindMethod(this, "UpdateStatus")
    Forecast := ""

    Init()
    {
        g_HybridTurboStackingGui.Init()
        ; Read settings
        this.LoadSettings()
        ; Update loop
        g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(this, "Start"))
        g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(this, "Stop"))
        this.Start()
    }

    ; Load saved or default settings.
    LoadSettings()
    {
        needSave := false
        default := this.GetNewSettings()
        this.Settings := settings := g_SF.LoadObjectFromJSON(IC_BrivGemFarm_HybridTurboStacking_Functions.SettingsPath)
        if (!IsObject(settings))
        {
            this.Settings := settings := default
            needSave := true
        }
        else
        {
            ; Delete extra settings
            for k, v in settings
            {
                if (!default.HasKey(k))
                {
                    settings.Delete(k)
                    needSave := true
                }
            }
            ; Add missing settings
            for k, v in default
            {
                if (!settings.HasKey(k) || settings[k] == "")
                {
                    settings[k] := default[k]
                    needSave := true
                }
            }
        }
        if (needSave)
            this.SaveSettings()
        ; Set the state of GUI buttons with saved settings.
        g_HybridTurboStackingGui.UpdateGUISettings(settings)
    }

    ; Returns an object with default values for all settings.
    GetNewSettings()
    {
        settings := {}
        settings.Enabled := false
        settings.CompleteOnlineStackZone := true
        settings.WardenUltThreshold := 50
        settings.Multirun := false
        settings.MultirunTargetStacks := g_BrivUserSettings[ "TargetStacks" ]
        settings.MultirunDelayOffline := true
        settings.100Melf := false
        settings.MelfMinStackZone := g_BrivUserSettings[ "StackZone" ] + 1
        last := IC_BrivGemFarm_HybridTurboStacking_Functions.GetLastSafeStackZone()
        settings.MelfMaxStackZone := last != "" ? last : 1949
        settings.PreferredBrivStackZones := 544790277504495
        return settings
    }

    UpdateSetting(setting, value)
    {
        this.Settings[setting] := value
    }

    ; Save settings.
    SaveSettings()
    {
        settings := this.Settings
        settings.PreferredBrivStackZones := this.GetPreferredBrivStackZones()
        g_SF.WriteObjectToJSON(IC_BrivGemFarm_HybridTurboStacking_Functions.SettingsPath, settings)
        GuiControl, ICScriptHub:Text, BGFHTS_StatusText, Settings saved
        ; Apply settings to BrivGemFarm
        try ; avoid thrown errors when comobject is not available.
        {
            SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
            SharedRunData.BGFHTS_UpdateSettingsFromFile()
        }
        catch
        {
            GuiControl, ICScriptHub:Text, BGFHTS_StatusText, Waiting for Gem Farm to start
        }
        this.UpdateMelfForecast(true)
    }

    Start()
    {
        fncToCallOnTimer := this.TimerFunction
        SetTimer, %fncToCallOnTimer%, 1000, 0
    }

    Stop()
    {
        fncToCallOnTimer := this.TimerFunction
        SetTimer, %fncToCallOnTimer%, Off
        GuiControl, ICScriptHub:Text, BGFHTS_StatusText, Not Running
        GuiControl, ICScriptHub:Hide, BGFHTS_StatusWarning
    }

    ; GUI update loop.
    UpdateStatus()
    {
        try ; avoid thrown errors when comobject is not available.
        {
            SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
            if (SharedRunData.BGFHTS_Running == "")
            {
                this.Stop()
                GuiControl, ICScriptHub:Show, BGFHTS_StatusWarning
                str := "BrivGemFarm HybridTurboStacking addon was loaded after Briv Gem Farm started.`n"
                MsgBox, % str . "If you want it enabled, press Stop/Start to retry."
            }
            else if (SharedRunData.BGFHTS_Running)
            {
                data := {}
                data.CurrentRunEffects := SharedRunData.BGFHTS_CurrentRunEffects
                data.CurrentRunStackRange := SharedRunData.BGFHTS_CurrentRunStackRange
                data.PreviousStackZone := SharedRunData.BGFHTS_PreviousStackZone
                g_HybridTurboStackingGui.UpdateGUI(data)
                GuiControl, ICScriptHub:Text, BGFHTS_StatusText, Running
            }
            else
                GuiControl, ICScriptHub:Text, BGFHTS_StatusText, Disabled
        }
        catch
        {
            GuiControl, ICScriptHub:Text, BGFHTS_StatusText, Waiting for Gem Farm to start
        }
        this.UpdateMelfForecast()
    }

    UpdateMelfForecast(updateRange := false)
    {
        resets := IC_BrivGemFarm_HybridTurboStacking_Functions.ReadResets()
        if (resets == "")
            return
        g_HybridTurboStackingGui.UpdateResets(resets)
        if (!g_HybridTurboStackingGui.AllowForecastUpdate)
            return
        forecast := (this.Forecast == "" || updateRange) ? [] : this.Forecast
        minIndex := forecast[1][1] == "" ? 0 : forecast[1][1]
        ; Don't update when it is not needeed.
        difference := resets - minIndex
        if (difference == 0 && minIndex != 0)
            return
        if (minIndex > 0)
        {
            ; Delete values before current reset.
            Loop, % difference
                forecast.RemoveAt(1)
        }
        ; Update remaining values.
        newValues := []
        maxRows := this.MAX_MELF_FORECAST_ROWS
        firstReset := minIndex == 0 ? resets : resets + maxRows - 1
        Loop, % Min(maxRows, difference)
        {
            reset := firstReset + A_Index - 1
            row := IC_BrivGemFarm_HybridTurboStacking_Melf.GetAllEffects(reset)
            row.InsertAt(1, reset)
            newValues.Push(row)
        }
        forecast.Push(newValues*)
        this.Forecast := forecast
        minZone := this.settings.MelfMinStackZone
        maxZone := this.settings.MelfMaxStackZone
        success := 0
        Loop, % maxRows
        {
            reset := resets + A_Index - 1
            if (IC_BrivGemFarm_HybridTurboStacking_Melf.GetFirstSpawnMoreEffectRange(reset, minZone, maxZone))
                ++success
        }
        g_HybridTurboStackingGui.UpdateForecast(newValues, minZone, maxZone, success)
    }

    ; Read the state of the mod50 checkboxes for Preferred Briv Stack Zones.
    ; Parameters: - toArray:bool - If true, returns an array, else returns a bitfield.
    GetPreferredBrivStackZones(toArray := false)
    {
        rootControlID := "BGFHTS_BrivStack_Mod_50_"
        array := []
        value := 0
        Loop, 50
        {
            GuiControlGet, isChecked, ICScriptHub:, %rootControlID%%A_Index%
            array.Push(isChecked)
            if (isChecked)
                value += 2 ** (A_Index - 1)
        }
        return toArray ? array : value
    }
}