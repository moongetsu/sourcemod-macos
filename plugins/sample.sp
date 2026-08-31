#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
    name = "Sample Plugin",
    author = "Danut",
    description = "Test SourceMod plugin compiled on macOS",
    version = "1.0.0",
    url = ""
};

public void OnPluginStart()
{
    PrintToServer("Hello from SourceMod compiled on macOS!");
    RegConsoleCmd("sm_hello", Command_Hello, "Prints a greeting in chat");
}

public Action Command_Hello(int client, int args)
{
    if (client > 0 && IsClientInGame(client))
    {
        PrintToChat(client, "[SM] Hello from macOS compiled plugin!");
    }
    else
    {
        PrintToServer("[SM] Hello from console!");
    }
    return Plugin_Handled;
}
