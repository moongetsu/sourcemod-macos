#if defined _cvs_game_votes_included
    #endinput
#endif
#define _cvs_game_votes_included

void RegisterGameVotes()
{
    char sDesc[128];

    Format(sDesc, sizeof(sDesc), "%T", "CmdRestartGameDesc", LANG_SERVER);
    RegConsoleCmd("sm_restartgame", Command_RestartGame, sDesc);
    RegConsoleCmd("sm_rg", Command_RestartGame, sDesc);

    Format(sDesc, sizeof(sDesc), "%T", "CmdSwapTeamsDesc", LANG_SERVER);
    RegConsoleCmd("sm_swapteams", Command_SwapTeams, sDesc);
    RegConsoleCmd("sm_swapt", Command_SwapTeams, sDesc);

    Format(sDesc, sizeof(sDesc), "%T", "CmdTimeoutDesc", LANG_SERVER);
    RegConsoleCmd("sm_timeout", Command_Timeout, sDesc);
    RegConsoleCmd("sm_to", Command_Timeout, sDesc);

    Format(sDesc, sizeof(sDesc), "%T", "CmdScrambleTeamsDesc", LANG_SERVER);
    RegConsoleCmd("sm_scrambleteams", Command_ScrambleTeams, sDesc);
    RegConsoleCmd("sm_scramblet", Command_ScrambleTeams, sDesc);
}

public Action Command_RestartGame(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;
    ExecuteCallVote(client, "restartgame");
    return Plugin_Handled;
}

public Action Command_SwapTeams(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;
    ExecuteCallVote(client, "swapteams");
    return Plugin_Handled;
}

public Action Command_Timeout(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    ConVar cvarTimeout = FindConVar("mp_team_timeout_max");
    if (cvarTimeout != null && cvarTimeout.IntValue <= 0)
    {
        CPrintToChat(client, "%T %T", "Prefix", client, "TimeoutDisabled", client);
        return Plugin_Handled;
    }

    ExecuteCallVote(client, "starttimeout");
    return Plugin_Handled;
}

public Action Command_ScrambleTeams(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;
    ExecuteCallVote(client, "scrambleteams");
    return Plugin_Handled;
}
