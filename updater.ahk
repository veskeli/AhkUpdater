;//////////////[Main Script Settings]
KeepThisUpToDate := true
SeemlesUpdate := true ;Dont ask before update
ThisScriptTempFileLocation = ;if empty temp location is same as Updater
;//////////////[Updater settings]
FileToUpdate = 
NewFileUrl = ""
FileName = ""
FileVersionFile = ;Ini file containing version number in "update" Section and "version" key
FileVersionSection = "Updater"
FileVersionKey = "version"
VersionUrl = "" ;url file containing only version number
;TempFileLocation = ;if empty temp location is same as file to update folder
DeleteOldFile := true
;Error Settings
ShowErrorMsgbox := false
SaveErrorsToFile := false
ErrorFileLocation = 
;//////////////[Advanced settings] (BranchControl) Not working yet
UseAdvancedSettings := false
;AdvancedUpdaterSettingsLocation = 
;DeleteAdvancedUpdaterSettingsFileAfterRead := true
;____________________________________________________________
;Updater Made by veskeli
;\/\/\/\/\/\/\/\/[Main Script]\/\/\/\/\/\/\/\/
#SingleInstance, Force
#Persistent
#KeyHistory, 0
#MaxThreadsPerHotkey, 4
SetBatchLines, -1
ListLines, Off
SendMode Input
SetTitleMatchMode, 3
SetWorkingDir, %A_ScriptDir%
SplitPath, A_ScriptName, , , , GameScripts
;//////////////[Vars]///////////////
ThisScriptVersion = 0.3
AppVersion = 
SettingsFile := % A_ScriptDir . "\Settings.ini"
;//////////////[Globals]///////////////
global ThisScriptVersion
global SettingsFile
global KeepThisUpToDate
global ThisScriptTempFileLocation
global FileToUpdate
global NewFileUrl
global FileName
global FileVersionFile
global FileVersionKey
global VersionUrl
global DeleteOldFile
global ShowErrorMsgbox
global ErrorFileLocation
global UseAdvancedSettings
;____________________________________________________________
SettingsFile2 := % A_ScriptDir . "\Settings\Settings.ini"
IfExist %SettingsFile2%
    SettingsFile := % A_ScriptDir . "\Settings\Settings.ini"
IfExist, SettingsFile
{
    UpdateSettings()
}
else
{  
    ;TODO: Add error log
    ExitApp
}
IfExist %A_ScriptDir%\OldUpdater.ahk
{
    FileDelete, %A_ScriptDir%\OldUpdater.ahk
}
if(UseAdvancedSettings) ;//////////////[Advanced update]
{
    IfNotExist %AdvancedUpdaterSettingsLocation%
    {
        ;No Updater Advanced Settings
        ;TODO: Add error log
        ExitApp
    }
    iniread,version,%AppUpdaterSettingsFile%,Options,Version
    iniread,MainScriptFile,%AppUpdaterSettingsFile%,Options,ScriptFullPath
    iniread,MainScriptBranch,%AppUpdaterSettingsFile%,Options,Branch
    global version
    global MainScriptFile
    global MainScriptBranch
    if(DeleteAdvancedUpdaterSettingsFileAfterRead)
        FileDelete,%AppUpdaterSettingsFile%
    ;update 
}
else ;//////////////[Simple Update]
{
    SimpleUpdate()
}
if(KeepThisUpToDate)
    CheckForUpdaterUpdates()
ExitApp
;____________________________________________________________
;//////////////[Functions]///////////////
SimpleUpdate()
{
    ;Get Current Version
    if(FileVersionFile != "")
    {
        IfExist %FileVersionFile%
            iniread,AppVersion,%FileVersionFile%,%FileVersionSection%,%FileVersionKey%
    }
    else
    {
        return
        ;TODO: Add error log
    }
    ;Get New version
    if(VersionUrl != "")
    {
        FileNewVersion = GetNewVersionFromURL(VersionUrl)
    }
    else
    {
        return
        ;TODO: Add error log
    }
    if(FileNewVersion > FileVersionFile) ;if new version is available
    {
        ;Update Code
        UpdateText := % "New version is: " . FileNewVersion . "`nOld is: " . FileVersionFile .  "`nUpdate now?"
        MsgBox, 4,Update,%UpdateText% ;Ask user if we update
        IfMsgBox, Yes ;If user pressed yes
        {
            if(FileName != "")
            {
                ;Check That if script is running
                SetTitleMatchMode, 2
                DetectHiddenWindows, On
                If WinExist(FileName . " ahk_class AutoHotkey")
                {
                    ;Stop Script
                    WinClose
                }
            }
            SplashTextOn, 250,50,Downloading...,Downloading new version.`nVersion: %FileNewVersion%
            FileDelete, %FileToUpdate% ;Delete old file
            UrlDownloadToFile, %NewFileUrl%, %FileToUpdate%
            SplashTextOff
            loop
            {
                IfExist %FileToUpdate%
                {
                    Run, %FileToUpdate%
                    ExitApp
                }
            }
            ExitApp
        }
        else
        {
            ExitApp
        }
    }
    else 
    {
        return
    } 
}
CheckForUpdaterUpdates()
{
    DownloadLink := % "https://raw.githubusercontent.com/veskeli/AhkUpdater/main/version.txt"
    newversion := GetNewVersionFromURL(DownloadLink)
    if(newversion == "ERROR")
        ExitApp
    if(newversion > ThisScriptVersion)
    {
        if(SeemlesUpdate)
        {
            UpdateUpdater()
        }
        else
        {
            UpdateText := % "New updater version is: " . FileNewVersion . "`nOld is: " . FileVersionFile .  "`nUpdate now?"
            MsgBox, 4,Update,%UpdateText% ;Ask user if we update
            IfMsgBox, Yes ;If user pressed yes
                UpdateUpdater()
        }
    } 
}
UpdateUpdater()
{
    
    if(ThisScriptTempFileLocation == "")
    {
        FileMove, %A_ScriptFullPath%, %A_ScriptDir%\OldUpdater.ahk, 1
    }
    else
    {
        IfNotExist %ThisScriptTempFileLocation%
            FileCreateDir, %ThisScriptTempFileLocation%
        FileMove, %A_ScriptFullPath%, %ThisScriptTempFileLocation%\%A_ScriptName%.ahk, 1
    }
    DownloadLink := % "https://raw.githubusercontent.com/veskeli/AhkUpdater/main/updater.ahk"
    UrlDownloadToFile, %DownloadLink%, %A_ScriptFullPath%
    ExitApp
}
GetNewVersionFromURL(Link)
{
    T_NewVersion := ReadFileFromLink(VersionLink)
    if(T_NewVersion != "ERROR" and T_NewVersion != "" and T_NewVersion != "404: Not Found" and T_NewVersion != "500: Internal Server Error")
    {
        Return T_NewVersion
    }
    else
    {
        Return "ERROR"
    }
}
ReadFileFromLink(Link)
{
    try
    {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", Link, False)
        whr.Send()
        whr.WaitForResponse()
        TResponse := whr.ResponseText
    }
    Catch T_Error
    {
        return "ERROR"
    }
    return TResponse
}
UpdateSettings()
{
    iniread, KeepThisUpToDate,%SettingsFile%,Updater,KeepThisUpToDate
    iniread, SeemlesUpdate,%SettingsFile%,Updater,SeemlesUpdate
    iniread, ThisScriptTempFileLocation,%SettingsFile%,Updater,ThisScriptTempFileLocation
    iniread, FileToUpdate,%SettingsFile%,Updater,FileToUpdate
    iniread, NewFileUrl,%SettingsFile%,Updater,NewFileUrl
    iniread, VersionUrl,%SettingsFile%,Updater,VersionUrl
    iniread, DeleteOldFile,%SettingsFile%,Updater,DeleteOldFile
    iniread, ShowErrorMsgbox,%SettingsFile%,Updater,ShowErrorMsgbox
    iniread, ErrorFileLocation,%SettingsFile%,Updater,ErrorFileLocation
    iniread, UseAdvancedSettings,%SettingsFile%,Updater,UseAdvancedSettings
}