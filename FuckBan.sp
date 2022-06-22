#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <materialadmin>
#include <cstrike>

#pragma tabsize 4

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

char czCockMsg[][] = {
	"Ко-Ко-Ко",
	"Я петушара"
}

char czDefaultModelPlayer[MAXPLAYERS+1][PLATFORM_MAX_PATH];

public void OnPluginStart()
{
    HookEvent("player_hurt", Event_PlayerHurt);
	AddCommandListener(SayCB,"say");
	AddCommandListener(SayCB,"say_team");

    RegAdminCmd("helloban", CMD_FuckBan, ADMFLAG_ROOT);
}

public void OnClientDisconnectPre(client)
{
	if(bBanTimer[client])
	{
		CreateTimer(0.0, BanTimerCallBack, client);
	}
}

public void OnMapStart()
{
	PrecacheSound("*/FuckBan/CockSndDir/cockChat.mp3")
}

public Action CMD_FuckBan(int client, int args)
{
    Menu hMenu = CreateMenu(MenuCallBack);
    hMenu.SetTitle("Выбор игрока");
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
            hMenu2.SetTitle("Выбор наказания");
            hMenu2.AddItem("item1","Weapon Dick Action");
            hMenu2.AddItem("item2","Dick Model");
            hMenu2.AddItem("item3","Cock Chat");
            hMenu2.AddItem("item4","Cock Sound");
            hMenu2.AddItem("item5","Disable Damage");
            hMenu2.AddItem("item6","Mutual Damage");
            hMenu2.AddItem("item7","Ban Timer");
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
            hMenu.GetItem(iItem, buffer, sizeof(buffer))
            switch(iItem)
            {
                case 0:
                {
                    WeaponDickAction(target);
                }
                case 1:
                {
                    DickModel(target);
                }
                case 2:
                {
                    CockChat(target);
                }
                case 3:
                {
                    CockSound(target);
                }
                case 4:
                {
                    DisableDamage(target);
                }
                case 5:
                {
                    MutualDamage(target);
                }
                case 6:
                {
                    BanTimer(target);
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

DelWeaponOfIndex(client, index_weapon)
{
    RemovePlayerItem(client, index_weapon);
    AcceptEntityInput(index_weapon, "Kill");
}

bool DickModel(client)
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

bool CockChat(client)
{
	if(bCockCh[client])
	{
		bCockCh[client] = false;
	}
	else bCockCh[client] = true;
}

bool CockSound(client)
{
	if(bCockSnd[client])
	{
		bCockSnd[client] = false;
	}
	else bCockSnd[client] = true;
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
	if(bMtlDmg[client] && buttons & IN_ATTACK)
	{
		int iclH = GetEntProp(client, Prop_Send, "m_iHealth");
		if(iclH!=0) SetEntProp(client, Prop_Send, "m_iHealth", iclH-1);
		else ForcePlayerSuicide(client);
	}
}

bool DisableDamage(client)
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

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	return Plugin_Stop;
}

bool MutualDamage(client)
{
	if(bMtlDmg[client])
	{
		bMtlDmg[client] = false;
	}
	else bMtlDmg[client] = true;
}

bool BanTimer(client)
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
		ghTimer[client] = CreateTimer(2.0, BanTimerCallBack, client);
	}
}

public Action BanTimerCallBack(Handle hTimer, client)
{
	if(ghTimer[client] != INVALID_HANDLE)
	{
		MABanPlayer(0, client, MA_BAN_STEAM, 1, "?Cheater?")
		KillTimer(ghTimer[client]);
		ghTimer[client] = null;
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
		SetEntProp(ent, Prop_Send, "m_iHealth", 100);
	}
	return Plugin_Continue;
}
