#if defined _cvs_kick_vote_included
    #endinput
#endif
#define _cvs_kick_vote_included

void RegisterKickVote()
{
    char sDesc[128];
    Format(sDesc, sizeof(sDesc), "%T", "CmdVoteKickDesc", LANG_SERVER);
    RegConsoleCmd("sm_vkick", Command_VoteKick, sDesc);
}

public Action Command_VoteKick(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    Menu menu = new Menu(MenuHandler_VoteKick);
    char sTitle[128];
    Format(sTitle, sizeof(sTitle), "%T", "MenuKickTitle", client);
    menu.SetTitle(sTitle);

    int count = 0;
    char sName[MAX_NAME_LENGTH];
    char sUserId[16];
    char sDisplay[MAX_NAME_LENGTH + 16];

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && i != client)
        {
            if (!CheckCommandAccess(client, "sm_kick", ADMFLAG_KICK) && CheckCommandAccess(i, "sm_kick", ADMFLAG_GENERIC))
            {
                continue;
            }

            int userId = GetClientUserId(i);
            GetClientName(i, sName, sizeof(sName));

            Format(sUserId, sizeof(sUserId), "%d", userId);
            Format(sDisplay, sizeof(sDisplay), "%s [#%d]", sName, userId);

            menu.AddItem(sUserId, sDisplay);
            count++;
        }
    }

    if (count == 0)
    {
        char sEmpty[64];
        Format(sEmpty, sizeof(sEmpty), "%T", "NoPlayersFound", client);
        menu.AddItem("", sEmpty, ITEMDRAW_DISABLED);
    }

    menu.ExitButton = true;
    menu.Display(client, 30);
    return Plugin_Handled;
}

public int MenuHandler_VoteKick(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        int client = param1;
        if (!IsClientInGame(client)) return 0;

        char sUserId[16];
        menu.GetItem(param2, sUserId, sizeof(sUserId));

        int targetUserId = StringToInt(sUserId);
        int targetClient = GetClientOfUserId(targetUserId);

        if (targetClient > 0 && IsClientInGame(targetClient))
        {
            char sArg[16];
            Format(sArg, sizeof(sArg), "%d", targetUserId);
            ExecuteCallVote(client, "kick", sArg);
        }
        else
        {
            CPrintToChat(client, "%T %T", "Prefix", client, "PlayerDisconnected", client);
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
    return 0;
}
