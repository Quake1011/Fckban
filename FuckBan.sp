#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <csgo_colors>
#tryinclude <multicolors>


#pragma tabsize 4

#define BanReason "?Cheater?"

int iTmpViol;

bool 
	bWeapDick[MAXPLAYERS+1],
	bDickMdl[MAXPLAYERS+1],
	bCockCh[MAXPLAYERS+1],
	bCockSnd[MAXPLAYERS+1],
	bDisDmg[MAXPLAYERS+1],
	bMtlDmg[MAXPLAYERS+1],
	bBanTimer[MAXPLAYERS+1]

Handle ghTimer[MAXPLAYERS+1];

int iDoneDmg[MAXPLAYERS+1];

int iBanTime;
float fBeforeBan;

char czCockMsg[][] = {
	"Ко-Ко-Ко",
	"Я петушара"
}

char czDefaultModelPlayer[MAXPLAYERS+1][PLATFORM_MAX_PATH];


public Plugin myinfo = {
	name = "FuckBan", 
	author = "Quake1011", 
	description = "For fun", 
	version = "1.4", 
	url = "https://github.com/Quake1011" 
}

public void OnPluginStart()
{
	ConVar hCvar;
	
    HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("weapon_fire", Event_WeaponFire);
	AddCommandListener(SayCB,"say");
	AddCommandListener(SayCB,"say_team");

    RegAdminCmd("helloban", CMD_FuckBan, ADMFLAG_ROOT);

	HookConVarChange((hCvar = CreateConVar("fb_BanTime", "1.0", "Time of ban timer(minutes)", FCVAR_NOTIFY,true,0.0)), OnConvarChangedBT);
	iBanTime = hCvar.IntValue;

	HookConVarChange((hCvar = CreateConVar("fb_BeforeBanTime", "1.0", "Waiting N - count minutes before ban", FCVAR_NOTIFY,true,0.0)), OnConvarChangedPBT);
	fBeforeBan = hCvar.FloatValue;

	AutoExecConfig(true, "fuckban");

	LoadTranslations("fuckban.phrases.txt")
}

public void OnConvarChangedBT(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	iBanTime = hCvar.IntValue;
}

public void OnConvarChangedPBT(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	fBeforeBan = hCvar.FloatValue;
}

public void OnClientDisconnectPre(client)
{
	if(bBanTimer[client])
	{
		CreateTimer(0.0, BanTimerCallBack, client);
	}
	bWeapDick[client]=false;
	bDickMdl[client]=false;
	bCockCh[client]=false;
	bCockSnd[client]=false;
	bDisDmg[client]=false;
	bMtlDmg[client]=false;
}

public void OnMapStart()
{
	PrecacheSound("*/FuckBan/CockSndDir/cockChat.mp3")
}

public Action CMD_FuckBan(int client, int args)
{
	char buffers[64];
    Menu hMenu = CreateMenu(MenuCallBack);
	Format(buffers, sizeof(buffers), "%t", "Select_player")
    hMenu.SetTitle(buffers);
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i))
        {       
            char str[16], buffer[64];
            int index = i;
            IntToString(index, str, sizeof(str));
            FormatEx(buffer, sizeof(buffer), "(%i) %N", index, index)
            hMenu.AddItem(str, buffer)
        }
    }
    hMenu.Display(client, 0);
    hMenu.ExitBackButton = true;
    hMenu.ExitButton = true;
}

public int MenuCallBack(Menu hMenu, MenuAction action, int iClient, int iItem)
{
    char buffer[64];
	char czPh[128];
    switch(action)
    {
        case MenuAction_End:
        {
            delete hMenu;
        }
        case MenuAction_Select:
        {
            hMenu.GetItem(iItem, buffer, sizeof(buffer))
            iTmpViol = StringToInt(buffer);
            Menu hMenu2 = CreateMenu(MenuCallBack2);

			Format(czPh, sizeof(czPh), "%t", "Select_of_punish")
            hMenu2.SetTitle(czPh);

			Format(czPh, sizeof(czPh), "%t [%s]", "Weapon_dick_action", bWeapDick[iTmpViol] ? "-" : "+")
            hMenu2.AddItem("item1",czPh);

			Format(czPh, sizeof(czPh), "%t [%s]", "Dick_mdl", bDickMdl[iTmpViol] ? "-" : "+")			
            hMenu2.AddItem("item2",czPh);

			Format(czPh, sizeof(czPh), "%t [%s]", "Cock_chat", bCockCh[iTmpViol] ? "-" : "+")
            hMenu2.AddItem("item3",czPh);

			Format(czPh, sizeof(czPh), "%t [%s]", "Cock_sound", bCockSnd[iTmpViol] ? "-" : "+")
            hMenu2.AddItem("item4",czPh);

			Format(czPh, sizeof(czPh), "%t [%s]", "Disable_dmg", bDisDmg[iTmpViol] ? "-" : "+")
            hMenu2.AddItem("item5",czPh);

			Format(czPh, sizeof(czPh), "%t [%s]", "Mutual_dmg", bMtlDmg[iTmpViol] ? "-" : "+")
            hMenu2.AddItem("item6",czPh);

			Format(czPh, sizeof(czPh), "%t [%s]", "Ban_timer", bBanTimer[iTmpViol] ? "-" : "+")
            hMenu2.AddItem("item7",czPh);

            hMenu2.Display(iClient, 0);
            hMenu2.ExitBackButton = true;
            hMenu2.ExitButton = true;
        }
    }
}

public int MenuCallBack2(Menu hMenu, MenuAction action, int iClient, int iItem)
{
    char buffer[64];
    int target = iTmpViol
    switch(action)
    {
        case MenuAction_End:
        {
            delete hMenu;
            iTmpViol = 0;
        }
        case MenuAction_Select:
        {
			char lnPhr[256];
            hMenu.GetItem(iItem, buffer, sizeof(buffer));
            switch(iItem)
            {
                case 0:
                {
					Format(lnPhr, sizeof(lnPhr), "%t", "fc_WD");
                    WeaponDickAction(target);
					if(GetEngineVersion()==Engine_CSGO) CGOPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bWeapDick[target] ? "Off":"On", target, lnPhr);
					#if defined _morecolors_included
					else if(GetEngineVersion()==Engine_CSS) CPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bWeapDick[target] ? "Off":"On", target, lnPhr);
					#endif
					else PrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bWeapDick[target] ? "Off":"On", target, lnPhr);
                }
                case 1:
                {
					Format(lnPhr, sizeof(lnPhr), "%t", "fc_DM");
                    DickModel(target);
					if(GetEngineVersion()==Engine_CSGO) CGOPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bDickMdl[target] ? "Off":"On", target, lnPhr);
					#if defined _morecolors_included
					else if(GetEngineVersion()==Engine_CSS) CPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bDickMdl[target] ? "Off":"On", target, lnPhr);
					#endif
					else PrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bDickMdl[target] ? "Off":"On", target, lnPhr);
                }
                case 2:
                {
					Format(lnPhr, sizeof(lnPhr), "%t", "fc_CC");
                    CockChat(target);
					if(GetEngineVersion()==Engine_CSGO) CGOPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bCockCh[target] ? "Off":"On", target, lnPhr);
					#if defined _morecolors_included
					else if(GetEngineVersion()==Engine_CSS) CPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bCockCh[target] ? "Off":"On", target, lnPhr);
					#endif
					else PrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bCockCh[target] ? "Off":"On", target, lnPhr);
                }
                case 3:
                {
					Format(lnPhr, sizeof(lnPhr), "%t", "fc_CS");
                    CockSound(target);
					if(GetEngineVersion()==Engine_CSGO) CGOPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bCockSnd[target] ? "Off":"On", target, lnPhr);
					#if defined _morecolors_included
					else if(GetEngineVersion()==Engine_CSS) CPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bCockSnd[target] ? "Off":"On", target, lnPhr);
					#endif
					else PrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bCockSnd[target] ? "Off":"On", target, lnPhr);
                }
                case 4:
                {
					Format(lnPhr, sizeof(lnPhr), "%t", "fc_DD");
                    DisableDamage(target);
					if(GetEngineVersion()==Engine_CSGO) CGOPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bDisDmg[target] ? "Off":"On", target, lnPhr);
					#if defined _morecolors_included
					else if(GetEngineVersion()==Engine_CSS) CPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bDisDmg[target] ? "Off":"On", target, lnPhr);
					#endif
					else PrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bDisDmg[target] ? "Off":"On", target, lnPhr);
                }
                case 5:
                {
					Format(lnPhr, sizeof(lnPhr), "%t", "fc_MD");
                    MutualDamage(target);
					if(GetEngineVersion()==Engine_CSGO) CGOPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bMtlDmg[target] ? "Off":"On", target, lnPhr);
					#if defined _morecolors_included
					else if(GetEngineVersion()==Engine_CSS) CPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bMtlDmg[target] ? "Off":"On", target, lnPhr);
					#endif
					else PrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bMtlDmg[target] ? "Off":"On", target, lnPhr);
                }
                case 6:
                {
					Format(lnPhr, sizeof(lnPhr), "%t", "fc_BT");
                    BanTimer(target);
					if(GetEngineVersion()==Engine_CSGO) CGOPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bBanTimer[target] ? "Off":"On", target, lnPhr);
					#if defined _morecolors_included
					else if(GetEngineVersion()==Engine_CSS) CPrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bBanTimer[target] ? "Off":"On", target, lnPhr);
					#endif
					else PrintToChat(iClient, "%t %t %s", "SetFuncToPlayer", bBanTimer[target] ? "Off":"On", target, lnPhr);
                }
            }
        }
    }
}

public Action SayCB(int client, const char[] command, int argc)
{
	if(bCockCh[client])
	{
		char cockchBuff[256], buffer[256];
		FormatEx(cockchBuff, sizeof(cockchBuff), "%s", czCockMsg[GetRandomInt(0,1)]);
		FormatEx(buffer, sizeof(buffer), "%N: ",client);
		StrCat(buffer, sizeof(buffer), cockchBuff)
		PrintToChatAll(buffer);
		return Plugin_Handled
	}
	return Plugin_Continue
}


DelWeaponOfIndex(client, index_weapon)
{
    RemovePlayerItem(client, index_weapon);
    AcceptEntityInput(index_weapon, "Kill");
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	buttons = GetClientButtons(client)
	float fClientOrig[3];
	GetClientAbsOrigin(client, fClientOrig);
	if(client && IsClientInGame(client))
	{
		if(bCockSnd[client])
		{
			if(buttons & IN_USE || buttons & IN_DUCK )
			{
				EmitSoundToAll("*/FuckBan/CockSndDir/cockChat.mp3", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, _, fClientOrig, _, true, 5.0);
			}
		}
	}
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	return Plugin_Stop;
}

public Action BanTimerCallBack(Handle hTimer, client)
{
	if(ghTimer[client] != INVALID_HANDLE)
	{
		char buffer[256], auth[32];
		GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
		FormatEx(buffer, sizeof(buffer), "sm_ban %s %i %s",auth, iBanTime, BanReason)
		ServerCommand(buffer);
		KillTimer(ghTimer[client]);
		ghTimer[client] = INVALID_HANDLE;
		bBanTimer[client]=false;
	}
}

public Action Event_PlayerHurt(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{
	int iAttacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	int ent = GetClientOfUserId(hEvent.GetInt("userid"));
	if(bDisDmg[iAttacker])
	{
		SDKHook(ent, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	if(bMtlDmg[iAttacker])
	{
		iDoneDmg[iAttacker] = hEvent.GetInt("dmg_health");
	}
	return Plugin_Continue;
}

public Action Event_WeaponFire(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if(bMtlDmg[client])
	{
		int iclH = GetEntProp(client, Prop_Send, "m_iHealth");
		if(iclH > 0) SetEntProp(client, Prop_Send, "m_iHealth", iclH - iDoneDmg[client]);
		else ForcePlayerSuicide(client);
	}
	return Plugin_Continue;
}

bool WeaponDickAction(client)
{
	if(!IsFakeClient(client) &&  IsClientInGame(client) && bWeapDick[client] != true)
	{
		for (int slot = 0; slot < 6; slot++)
		{
			int index;
			if ((index = GetPlayerWeaponSlot(client, slot)) >= 0)
			{
				if (index != -1)
				{
					DelWeaponOfIndex(client, index);
				}
			}
		}
		GivePlayerItem(client,"weapon_knife");
		bWeapDick[client] = true;
	}
}

void MutualDamage(client)
{
	if(bMtlDmg[client])
	{
		bMtlDmg[client] = false;
	}
	else bMtlDmg[client] = true;
}

void BanTimer(client)
{
	if(bBanTimer[client])
	{
		bBanTimer[client] = false;
		KillTimer(ghTimer[client]);
		ghTimer[client] = null;
	}
	else 
	{	
		bBanTimer[client] = true;
		ghTimer[client] = CreateTimer(fBeforeBan, BanTimerCallBack, client);
	}
}

void DisableDamage(client)
{
	if(bDisDmg[client])
	{
		bDisDmg[client] = false;
	}
	else 
	{
		bDisDmg[client] = true;
	}
}

void CockChat(client)
{
	if(bCockCh[client])
	{
		bCockCh[client] = false;
	}
	else bCockCh[client] = true;
}

void CockSound(client)
{
	if(bCockSnd[client])
	{
		bCockSnd[client] = false;
	}
	else bCockSnd[client] = true;
}

void DickModel(client)
{
	GetClientModel(client, czDefaultModelPlayer[client], sizeof(czDefaultModelPlayer));
	if(!IsFakeClient(client) && IsClientInGame(client))
	{
		if(!bDickMdl[client])
		{
			SetEntityModel(client,"models/player/custom_player/kaesar/chickenleet/chickenleet.mdl");
			bDickMdl[client] = true;
		}
		else
		{
			SetEntityModel(client,czDefaultModelPlayer[client])
		}
	}
}
