#if defined _cvs_map_votes_included
    #endinput
#endif
#define _cvs_map_votes_included

void RegisterMapVotes()
{
    char sDesc[128];

    Format(sDesc, sizeof(sDesc), "%T", "CmdNextMapDesc", LANG_SERVER);
    RegConsoleCmd("sm_nextmap", Command_NextMap, sDesc);
    RegConsoleCmd("sm_nextm", Command_NextMap, sDesc);
    RegConsoleCmd("sm_nominate", Command_NextMap, sDesc);

    Format(sDesc, sizeof(sDesc), "%T", "CmdChangeMapDesc", LANG_SERVER);
    RegConsoleCmd("sm_changemap", Command_ChangeMap, sDesc);
    RegConsoleCmd("sm_changem", Command_ChangeMap, sDesc);
    RegConsoleCmd("sm_rtv", Command_ChangeMap, sDesc);
}

void LoadMapCycle()
{
    g_hMapList.Clear();

    char sPaths[2][PLATFORM_MAX_PATH];
    strcopy(sPaths[0], sizeof(sPaths[]), g_sMapcyclePath);
    strcopy(sPaths[1], sizeof(sPaths[]), "maplist.txt");

    for (int p = 0; p < 2; p++)
    {
        if (FileExists(sPaths[p]))
        {
            File hFile = OpenFile(sPaths[p], "r");
            if (hFile != null)
            {
                char sBuffer[PLATFORM_MAX_PATH];
                while (hFile.ReadLine(sBuffer, sizeof(sBuffer)))
                {
                    TrimString(sBuffer);
                    if (sBuffer[0] != '\0' && sBuffer[0] != '/' && sBuffer[0] != ';')
                    {
                        if (IsMapValid(sBuffer) && g_hMapList.FindString(sBuffer) == -1)
                        {
                            g_hMapList.PushString(sBuffer);
                        }
                    }
                }
                delete hFile;

                if (g_hMapList.Length > 0)
                {
                    return;
                }
            }
        }
    }

    char defaultMaps[][] = {
        "de_dust2",
        "de_mirage",
        "de_inferno",
        "de_nuke",
        "de_overpass",
        "de_vertigo",
        "de_ancient",
        "de_anubis"
    };

    for (int i = 0; i < sizeof(defaultMaps); i++)
    {
        if (IsMapValid(defaultMaps[i]))
        {
            g_hMapList.PushString(defaultMaps[i]);
        }
    }
}

public Action Command_NextMap(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    if (args >= 1)
    {
        char sMap[PLATFORM_MAX_PATH];
        GetCmdArg(1, sMap, sizeof(sMap));
        SanitizeVoteArg(sMap, sizeof(sMap));

        if (!IsMapValid(sMap))
        {
            CPrintToChat(client, "%T %T", "Prefix", client, "MapNotFound", client, sMap);
            return Plugin_Handled;
        }

        ExecuteCallVote(client, "nextlevel", sMap);
        return Plugin_Handled;
    }

    ShowMapSelectionMenu(client, "nextlevel");
    return Plugin_Handled;
}

public Action Command_ChangeMap(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    if (args >= 1)
    {
        char sMap[PLATFORM_MAX_PATH];
        GetCmdArg(1, sMap, sizeof(sMap));
        SanitizeVoteArg(sMap, sizeof(sMap));

        if (!IsMapValid(sMap))
        {
            CPrintToChat(client, "%T %T", "Prefix", client, "MapNotFound", client, sMap);
            return Plugin_Handled;
        }

        ExecuteCallVote(client, "changelevel", sMap);
        return Plugin_Handled;
    }

    ShowMapSelectionMenu(client, "changelevel");
    return Plugin_Handled;
}

void ShowMapSelectionMenu(int client, const char[] voteType)
{
    Menu menu = new Menu(MenuHandler_MapSelection);

    char sTitle[128];
    if (StrEqual(voteType, "nextlevel"))
    {
        Format(sTitle, sizeof(sTitle), "%T", "MenuNextMapTitle", client);
    }
    else
    {
        Format(sTitle, sizeof(sTitle), "%T", "MenuChangeMapTitle", client);
    }
    menu.SetTitle(sTitle);

    char sCurrentMap[PLATFORM_MAX_PATH];
    GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));

    char sMap[PLATFORM_MAX_PATH];
    char sInfo[PLATFORM_MAX_PATH + 16];
    int count = 0;

    for (int i = 0; i < g_hMapList.Length; i++)
    {
        g_hMapList.GetString(i, sMap, sizeof(sMap));

        if (StrEqual(voteType, "changelevel") && StrEqual(sMap, sCurrentMap, false))
        {
            continue;
        }

        Format(sInfo, sizeof(sInfo), "%s|%s", voteType, sMap);
        menu.AddItem(sInfo, sMap);
        count++;
    }

    if (count == 0)
    {
        char sEmpty[64];
        Format(sEmpty, sizeof(sEmpty), "%T", "NoMapsFound", client);
        menu.AddItem("", sEmpty, ITEMDRAW_DISABLED);
    }

    menu.ExitButton = true;
    menu.Display(client, 30);
}

public int MenuHandler_MapSelection(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        int client = param1;
        if (!IsClientInGame(client)) return 0;

        char sInfo[PLATFORM_MAX_PATH + 16];
        menu.GetItem(param2, sInfo, sizeof(sInfo));

        char parts[2][PLATFORM_MAX_PATH];
        if (ExplodeString(sInfo, "|", parts, 2, PLATFORM_MAX_PATH) == 2)
        {
            if (IsMapValid(parts[1]))
            {
                ExecuteCallVote(client, parts[0], parts[1]);
            }
            else
            {
                CPrintToChat(client, "%T %T", "Prefix", client, "MapNotFound", client, parts[1]);
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
    return 0;
}
