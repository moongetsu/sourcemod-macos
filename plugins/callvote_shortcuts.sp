#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

#include <cvs/globals>
#include <cvs/game_votes>
#include <cvs/map_votes>
#include <cvs/kick_vote>
#include <cvs/listeners>

public Plugin myinfo =
{
    name        = "CallVote Shortcuts",
    author      = "moongetsu",
    description = "Chat shortcuts and menus for CS:GO votes",
    version     = PLUGIN_VERSION,
    url         = "https://github.com/moongetsu"
};

public void OnPluginStart()
{
    LoadTranslations("callvote_shortcuts.phrases");
    LoadTranslations("common.phrases");

    g_hMapList = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

    RegisterGameVotes();
    RegisterMapVotes();
    RegisterKickVote();
    RegisterListeners();
}

public void OnMapStart()
{
    LoadMapCycle();
}
