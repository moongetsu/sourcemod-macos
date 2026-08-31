#if defined _cvs_listeners_included
    #endinput
#endif
#define _cvs_listeners_included

void RegisterListeners()
{
    AddCommandListener(Listener_Say, "say");
    AddCommandListener(Listener_Say, "say_team");
}

public Action Listener_Say(int client, const char[] command, int args)
{
    if (client <= 0 || !IsClientInGame(client))
    {
        return Plugin_Continue;
    }

    char sText[192];
    GetCmdArgString(sText, sizeof(sText));
    StripQuotes(sText);
    TrimString(sText);

    if (sText[0] == '!' || sText[0] == '/')
    {
        char sArgs[2][PLATFORM_MAX_PATH];
        int numArgs = ExplodeString(sText[1], " ", sArgs, 2, PLATFORM_MAX_PATH);
        char sCmd[64];
        strcopy(sCmd, sizeof(sCmd), sArgs[0]);
        TrimString(sCmd);

        if (StrEqual(sCmd, "restartgame", false) || StrEqual(sCmd, "rg", false))
        {
            return Command_RestartGame(client, 0);
        }
        else if (StrEqual(sCmd, "swapteams", false) || StrEqual(sCmd, "swapt", false))
        {
            return Command_SwapTeams(client, 0);
        }
        else if (StrEqual(sCmd, "timeout", false) || StrEqual(sCmd, "to", false))
        {
            return Command_Timeout(client, 0);
        }
        else if (StrEqual(sCmd, "scrambleteams", false) || StrEqual(sCmd, "scramblet", false))
        {
            return Command_ScrambleTeams(client, 0);
        }
        else if (StrEqual(sCmd, "nextmap", false) || StrEqual(sCmd, "nextm", false) || StrEqual(sCmd, "nominate", false))
        {
            if (numArgs > 1 && sArgs[1][0] != '\0')
            {
                SanitizeVoteArg(sArgs[1], sizeof(sArgs[]));
                if (!IsMapValid(sArgs[1]))
                {
                    CPrintToChat(client, "%T %T", "Prefix", client, "MapNotFound", client, sArgs[1]);
                    return Plugin_Handled;
                }
                ExecuteCallVote(client, "nextlevel", sArgs[1]);
                return Plugin_Handled;
            }
            return Command_NextMap(client, 0);
        }
        else if (StrEqual(sCmd, "changemap", false) || StrEqual(sCmd, "changem", false) || StrEqual(sCmd, "rtv", false))
        {
            if (numArgs > 1 && sArgs[1][0] != '\0')
            {
                SanitizeVoteArg(sArgs[1], sizeof(sArgs[]));
                if (!IsMapValid(sArgs[1]))
                {
                    CPrintToChat(client, "%T %T", "Prefix", client, "MapNotFound", client, sArgs[1]);
                    return Plugin_Handled;
                }
                ExecuteCallVote(client, "changelevel", sArgs[1]);
                return Plugin_Handled;
            }
            return Command_ChangeMap(client, 0);
        }
        else if (StrEqual(sCmd, "vkick", false))
        {
            return Command_VoteKick(client, 0);
        }
    }
    else if (StrEqual(sText, "restartgame", false) || StrEqual(sText, "rg", false) || StrEqual(sText, "rtv", false) || StrEqual(sText, "nominate", false))
    {
        if (StrEqual(sText, "restartgame", false) || StrEqual(sText, "rg", false))
        {
            return Command_RestartGame(client, 0);
        }
        else if (StrEqual(sText, "rtv", false))
        {
            return Command_ChangeMap(client, 0);
        }
        else if (StrEqual(sText, "nominate", false))
        {
            return Command_NextMap(client, 0);
        }
    }

    return Plugin_Continue;
}
