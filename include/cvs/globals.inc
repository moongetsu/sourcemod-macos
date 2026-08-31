#if defined _cvs_globals_included
    #endinput
#endif
#define _cvs_globals_included

#define PLUGIN_VERSION "1.1.0"

char      g_sMapcyclePath[PLATFORM_MAX_PATH] = "mapcycle.txt";
ArrayList g_hMapList;

void SanitizeVoteArg(char[] str, int maxlen = 0)
{
    #pragma unused maxlen
    int len = strlen(str);
    for (int i = 0; i < len; i++)
    {
        if (str[i] == ';' || str[i] == '\n' || str[i] == '\r' || str[i] == '"' || str[i] == '&' || str[i] == '|')
        {
            str[i] = '\0';
            break;
        }
    }
    TrimString(str);
}

void ExecuteCallVote(int client, const char[] voteType, const char[] arg = "")
{
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client))
    {
        return;
    }

    char sSafeArg[PLATFORM_MAX_PATH];
    strcopy(sSafeArg, sizeof(sSafeArg), arg);
    SanitizeVoteArg(sSafeArg, sizeof(sSafeArg));

    char sCmd[256];
    if (sSafeArg[0] != '\0')
    {
        Format(sCmd, sizeof(sCmd), "callvote %s %s", voteType, sSafeArg);
    }
    else
    {
        Format(sCmd, sizeof(sCmd), "callvote %s", voteType);
    }

    ClientCommand(client, sCmd);
}
