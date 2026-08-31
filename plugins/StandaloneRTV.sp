#include <sourcemod>
#include <sdktools>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

float            g_fPercentage                      = 0.60;
float            g_fCooldown                        = 300.0;
char             g_sMapcyclePath[PLATFORM_MAX_PATH] = "mapcycle.txt";
bool             g_bLogging                         = true;
bool             g_bUseSMMap                        = false;
int              g_iVoteDuration                    = 20;

ArrayList        g_hMapList;
char             g_sVoteMap[PLATFORM_MAX_PATH];
float            g_fNextVoteTime    = 0.0;
bool             g_bNextRoundChange = false;
char             g_sNextMap[PLATFORM_MAX_PATH];
char             g_sLogFile[PLATFORM_MAX_PATH];
char             g_sSettingsPath[PLATFORM_MAX_PATH];

public Plugin myinfo =
{
    name        = "Map Vote (RTV)",
    author      = "moongetsu",
    description = "Standalone map vote system.",
    version     = "1.2",
    url         = "https://github.com/moongetsu"
};

public void OnPluginStart()
{
    LoadTranslations("standalone_rtv.phrases");
    LoadTranslations("common.phrases");

    BuildPath(Path_SM, g_sSettingsPath, sizeof(g_sSettingsPath), "configs/moon/standalone_rtv.cfg");
    BuildPath(Path_SM, g_sLogFile, sizeof(g_sLogFile), "logs/rtv_votes.log");

    LoadConfig();
    CheckForConflicts();

    RegConsoleCmd("sm_rtv", Command_RTV, "Opens the map selection menu.");
    RegAdminCmd("sm_rtvadmin", Command_AdminMenu, ADMFLAG_CHANGEMAP, "Opens the RTV admin menu.");

    AddCommandListener(Listener_Say, "say");
    AddCommandListener(Listener_Say, "say_team");

    HookEvent("round_start", Event_RoundStart);

    g_hMapList = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
}

void CheckForConflicts()
{
    char sConflicts[256] = "";
    if (FindPluginByFile("nextmap.smx") != null) Format(sConflicts, sizeof(sConflicts), "%s nextmap.smx", sConflicts);
    if (FindPluginByFile("mapchooser.smx") != null) Format(sConflicts, sizeof(sConflicts), "%s mapchooser.smx", sConflicts);
    if (FindPluginByFile("rockthevote.smx") != null || FindPluginByFile("rtv.smx") != null) Format(sConflicts, sizeof(sConflicts), "%s rtv.smx", sConflicts);
    if (FindPluginByFile("nominations.smx") != null || FindPluginByFile("nominate.smx") != null) Format(sConflicts, sizeof(sConflicts), "%s nominations.smx", sConflicts);

    if (sConflicts[0] != '\0')
    {
        LogError(" [WARNING] StandaloneRTV detected conflicting plugins: [%s ]", sConflicts);
        LogError(" [WARNING] To avoid issues, please DISABLE these plugins in plugins/disabled!");
        LogMessage("[WARNING] StandaloneRTV conflict detected with standard map plugins. Check error logs!");
    }
}

void LoadConfig()
{
    float fPercentageTmp = 0.60;
    float fCooldownTmp   = 300.0;
    char  sCycleTmp[PLATFORM_MAX_PATH];
    strcopy(sCycleTmp, sizeof(sCycleTmp), "mapcycle.txt");
    bool      bLoggingTmp  = true;
    bool      bUseSMMapTmp = true;
    int       iDurationTmp = 20;

    KeyValues kv           = new KeyValues("RTV_Settings");
    bool      bExists      = kv.ImportFromFile(g_sSettingsPath);
    int       iVer         = kv.GetNum("version", 0);

    if (bExists)
    {
        fPercentageTmp = kv.GetFloat("percentage", fPercentageTmp);
        fCooldownTmp   = kv.GetFloat("cooldown", fCooldownTmp);
        kv.GetString("mapcycle", sCycleTmp, sizeof(sCycleTmp), sCycleTmp);
        bLoggingTmp  = kv.GetNum("logging", bLoggingTmp ? 1 : 0) != 0;
        bUseSMMapTmp = kv.GetNum("use_sm_map", bUseSMMapTmp ? 1 : 0) != 0;
        iDurationTmp = kv.GetNum("vote_duration", iDurationTmp);
    }

    g_fPercentage = fPercentageTmp;
    g_fCooldown   = fCooldownTmp;
    strcopy(g_sMapcyclePath, sizeof(g_sMapcyclePath), sCycleTmp);
    g_bLogging      = bLoggingTmp;
    g_bUseSMMap     = bUseSMMapTmp;
    g_iVoteDuration = iDurationTmp;

    if (!bExists || iVer < 11)
    {
        File hFile = OpenFile(g_sSettingsPath, "w");
        if (hFile != null)
        {
            hFile.WriteLine("\"RTV_Settings\"");
            hFile.WriteLine("{");
            hFile.WriteLine("	\"version\"		\"11\"");
            hFile.WriteLine("");
            hFile.WriteLine("	// Percentage of players required to pass the vote (0.0 to 1.0)");
            hFile.WriteLine("	\"percentage\"	\"%.2f\"", g_fPercentage);
            hFile.WriteLine("");
            hFile.WriteLine("	// Cooldown in seconds between votes");
            hFile.WriteLine("	\"cooldown\"		\"%.1f\"", g_fCooldown);
            hFile.WriteLine("");
            hFile.WriteLine("	// Path to the mapcycle file to list maps from");
            hFile.WriteLine("	\"mapcycle\"		\"%s\"", g_sMapcyclePath);
            hFile.WriteLine("");
            hFile.WriteLine("	// Enable or disable vote logging (1 = ON, 0 = OFF)");
            hFile.WriteLine("	\"logging\"		\"%d\"", g_bLogging ? 1 : 0);
            hFile.WriteLine("");
            hFile.WriteLine("	// Use 'sm_map' instead of 'changelevel' (1 = sm_map, 0 = changelevel)");
            hFile.WriteLine("	\"use_sm_map\"	\"%d\"", g_bUseSMMap ? 1 : 0);
            hFile.WriteLine("");
            hFile.WriteLine("	// How long the vote menu stays on screen (seconds)");
            hFile.WriteLine("	\"vote_duration\"	\"%d\"", g_iVoteDuration);
            hFile.WriteLine("}");
            delete hFile;
            LogMessage("[RTV] Config file updated/created with latest settings.");
        }
    }

    delete kv;
    LogMessage("Config loaded (Percentage: %.2f, Cooldown: %.0f, Cycle: %s, Logs: %d)",
               g_fPercentage, g_fCooldown, g_sMapcyclePath, g_bLogging);
}

public void OnMapStart()
{
    g_bNextRoundChange = false;
    g_sNextMap[0]      = '\0';
    LoadConfig();
    LoadMapCycle();
}

void LoadMapCycle()
{
    g_hMapList.Clear();
    File hFile = OpenFile(g_sMapcyclePath, "r");
    if (hFile == null)
    {
        LogError("Could not open mapcycle file: %s", g_sMapcyclePath);
        return;
    }
    char sBuffer[PLATFORM_MAX_PATH];
    while (hFile.ReadLine(sBuffer, sizeof(sBuffer)))
    {
        TrimString(sBuffer);
        if (sBuffer[0] != '\0')
        {
            if (IsMapValid(sBuffer))
            {
                g_hMapList.PushString(sBuffer);
            }
            else
            {
                LogMessage("[RTV] Skipping invalid map: %s", sBuffer);
            }
        }
    }
    delete hFile;
}

public Action Command_RTV(int client, int args)
{
    if (client <= 0) return Plugin_Handled;

    if (g_bNextRoundChange)
    {
        CPrintToChat(client, "%T %T", "Prefix", client, "AlreadyPending", client, g_sNextMap);
        return Plugin_Handled;
    }

    if (IsVoteInProgress())
    {
        CPrintToChat(client, "%T %T", "Prefix", client, "VoteInProgress", client);
        return Plugin_Handled;
    }

    if (GetEngineTime() < g_fNextVoteTime)
    {
        CPrintToChat(client, "%T %T", "Prefix", client, "CooldownMessage", client, g_fNextVoteTime - GetEngineTime());
        return Plugin_Handled;
    }

    ShowMapMenu(client);
    return Plugin_Handled;
}

public Action Command_AdminMenu(int client, int args)
{
    if (client <= 0) return Plugin_Handled;
    ShowAdminRTVMenu(client);
    return Plugin_Handled;
}

public Action Listener_Say(int client, const char[] command, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Continue;

    char sText[32];
    GetCmdArg(1, sText, sizeof(sText));

    if (StrEqual(sText, "rtv", false))
    {
        return Command_RTV(client, 0);
    }

    return Plugin_Continue;
}

void ShowMapMenu(int client)
{
    Menu menu = new Menu(MenuHandler_MapList);
    char sTitle[128], sCurrentMap[PLATFORM_MAX_PATH];
    Format(sTitle, sizeof(sTitle), "%T", "MenuTitle", client);
    menu.SetTitle(sTitle);

    GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));
    int  count = 0;
    char sMap[PLATFORM_MAX_PATH];
    for (int i = 0; i < g_hMapList.Length; i++)
    {
        g_hMapList.GetString(i, sMap, sizeof(sMap));
        if (StrEqual(sMap, sCurrentMap, false)) continue;
        menu.AddItem(sMap, sMap);
        count++;
    }

    if (count == 0) menu.AddItem("", "No other maps", ITEMDRAW_DISABLED);

    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_MapList(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char sInfo[PLATFORM_MAX_PATH];
        menu.GetItem(param2, sInfo, sizeof(sInfo));
        StartMapVote(param1, sInfo);
    }
    else if (action == MenuAction_End) delete menu;
}

void StartMapVote(int initiator, char[] mapName)
{
    if (IsVoteInProgress())
    {
        CPrintToChat(initiator, "%T %T", "Prefix", initiator, "VoteInProgress", initiator);
        return;
    }

    if (GetEngineTime() < g_fNextVoteTime)
    {
        CPrintToChat(initiator, "%T %T", "Prefix", initiator, "CooldownMessage", initiator, g_fNextVoteTime - GetEngineTime());
        return;
    }
    if (g_bNextRoundChange)
    {
        CPrintToChat(initiator, "%T %T", "Prefix", initiator, "AlreadyPending", initiator, g_sNextMap);
        return;
    }

    strcopy(g_sVoteMap, sizeof(g_sVoteMap), mapName);
    Menu voteMenu = new Menu(MenuHandler_Vote);
    char sTitle[128], sYes[32], sNo[32];
    Format(sTitle, sizeof(sTitle), "%T", "VoteTitle", LANG_SERVER, mapName);
    voteMenu.SetTitle(sTitle);
    Format(sYes, sizeof(sYes), "%T", "OptionYes", LANG_SERVER);
    Format(sNo, sizeof(sNo), "%T", "OptionNo", LANG_SERVER);
    voteMenu.AddItem("yes", sYes);
    voteMenu.AddItem("no", sNo);
    voteMenu.ExitButton = false;
    voteMenu.DisplayVoteToAll(g_iVoteDuration);
    CPrintToChatAll("%T %T", "Prefix", LANG_SERVER, "VoteStarted", LANG_SERVER, initiator, mapName);
    if (g_bLogging) LogToFileEx(g_sLogFile, "Player %N started vote for %s", initiator, mapName);
}

public int MenuHandler_Vote(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_VoteEnd)
    {
        int yesVotes       = 0;
        int totalVotesCast = 0;
        int winVotes, totalVotes;

        GetMenuVoteInfo(param2, winVotes, totalVotes);
        totalVotesCast = totalVotes;

        if (param1 == 0) yesVotes = winVotes;
        else if (param1 == 1) yesVotes = totalVotesCast - winVotes;
        else if (param1 == -1) yesVotes = 0;

        int totalPlayers = 0;
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && !IsFakeClient(i)) totalPlayers++;
        }

        float percentage = (g_fPercentage > 0.0) ? g_fPercentage : 0.60;
        int   needed     = RoundToCeil(float(totalPlayers) * percentage);
        if (needed < 1) needed = 1;

        bool passed = (yesVotes >= needed);

        if (passed)
        {
            if (GameRules_GetProp("m_bWarmupPeriod") != 0)
            {
                CPrintToChatAll("%T %T", "Prefix", LANG_SERVER, "VotePassedWarmup", LANG_SERVER);
            }
            else
            {
                CPrintToChatAll("%T %T", "Prefix", LANG_SERVER, "VotePassed", LANG_SERVER, yesVotes, totalPlayers);
            }

            g_bNextRoundChange = true;
            strcopy(g_sNextMap, sizeof(g_sNextMap), g_sVoteMap);
        }
        else
        {
            CPrintToChatAll("%T %T", "Prefix", LANG_SERVER, "VoteFailed", LANG_SERVER, yesVotes, totalPlayers, needed);
            g_fNextVoteTime = GetEngineTime() + g_fCooldown;
        }

        if (g_bLogging) LogToFileEx(g_sLogFile, "Vote %s for %s (%d/%d, Needed: %d)", (passed ? "passed" : "failed"), g_sVoteMap, yesVotes, totalPlayers, needed);
    }
    else if (action == MenuAction_End) delete menu;
}

void ShowAdminRTVMenu(int client)
{
    Menu menu = new Menu(Handler_AdminRTV);

    char sStatus[64], sTitle[512];
    if (g_bNextRoundChange)
    {
        Format(sStatus, sizeof(sStatus), "%T", "StatusScheduled", client, g_sNextMap);
    }
    else if (GetEngineTime() < g_fNextVoteTime)
    {
        Format(sStatus, sizeof(sStatus), "%T", "StatusCooldown", client, RoundToFloor(g_fNextVoteTime - GetEngineTime()));
    }
    else
    {
        Format(sStatus, sizeof(sStatus), "%T", "StatusReady", client);
    }

    Format(sTitle, sizeof(sTitle), "%T\n \nStatus: %s\n%T: %.0f%%\n%T: %.0fs\n%T: %ds\nCycle: %s\n%T: %s\n%T: %s\n ",
           "AdminMenuTitle", client,
           sStatus,
           "PercentageLabel", client, g_fPercentage * 100.0,
           "CooldownLabel", client, g_fCooldown,
           "DurationLabel", client, g_iVoteDuration,
           g_sMapcyclePath,
           "LoggingLabel", client, (g_bLogging ? "ON" : "OFF"),
           "UseSMMapLabel", client, (g_bUseSMMap ? "ON" : "OFF"));

    menu.SetTitle(sTitle);

    char sBuff[128];
    Format(sBuff, sizeof(sBuff), "%T", "ResetCooldown", client);
    menu.AddItem("reset_cooldown", sBuff);

    Format(sBuff, sizeof(sBuff), "%T", "CancelChange", client);
    menu.AddItem("cancel_change", sBuff);

    Format(sBuff, sizeof(sBuff), "%T", "ReloadSettings", client);
    menu.AddItem("reload_config", sBuff);

    menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_AdminRTV(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char info[32];
        menu.GetItem(param2, info, sizeof(info));
        if (StrEqual(info, "reset_cooldown"))
        {
            g_fNextVoteTime = 0.0;
            CPrintToChat(param1, "%T %T", "Prefix", param1, "MsgCooldownReset", param1);
        }
        else if (StrEqual(info, "cancel_change"))
        {
            g_bNextRoundChange = false;
            CPrintToChat(param1, "%T %T", "Prefix", param1, "MsgChangeCancelled", param1);
        }
        else if (StrEqual(info, "reload_config"))
        {
            LoadConfig();
            LoadMapCycle();
            CPrintToChat(param1, "%T %T", "Prefix", param1, "MsgSettingsReloaded", param1);
        }
        ShowAdminRTVMenu(param1);
    }

    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bNextRoundChange)
    {
        CPrintToChatAll("%T %T", "Prefix", LANG_SERVER, "ChangingNow", LANG_SERVER, g_sNextMap);

        if (g_bUseSMMap)
        {
            ServerCommand("sm_map %s", g_sNextMap);
        }
        else
        {
            ServerCommand("changelevel %s", g_sNextMap);
        }
    }
}