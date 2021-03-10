#include <sourcemod>
#include <sdktools>
#include <zombiereloaded>
#include <cstrike>

public Plugin myinfo =
{
    name = "ZR warm up",
    author = "Gunslinger",
    description = "Make warm up round work perfectly on CS:GO",
    version = "1.0",
    url = ""
};

public void OnPluginStart()
{
    EngineVersion engine = GetEngineVersion();
    if (engine != Engine_CSGO)
        SetFailState("Only work for CS:GO!");
}

public void OnMapStart()
{
    ConVar dowarmup = FindConVar("mp_do_warmup_period");
    if (dowarmup.BoolValue)
    {
        ConVar warmuptime = FindConVar("mp_warmuptime");
        CreateTimer(warmuptime.FloatValue, EndWarmUp, _, TIMER_FLAG_NO_MAPCHANGE);
        delete warmuptime;
    }
    delete dowarmup;
}

public Action EndWarmUp(Handle timer)
{
    // End warm up
    ServerCommand("mp_warmup_end");
    ServerCommand("mp_restartgame 1");
    return Plugin_Stop;
}

public Action ZR_OnClientInfect(int &client, int &attacker, bool &motherInfect, bool &respawnOverride, bool &respawn)
{
    // Warm up no infection
    return IsWarmUp() ? Plugin_Handled : Plugin_Continue;
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
    // Warm up not end round
    if (IsWarmUp() && reason != CSRoundEnd_GameStart)
        return Plugin_Handled;
    return Plugin_Continue;
}

bool IsWarmUp()
{
    return GameRules_GetProp("m_bWarmupPeriod") == 1
}