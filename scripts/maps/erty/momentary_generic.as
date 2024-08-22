namespace MomentaryGeneric
{

/**
* momentary_generic is an entity that displays a model and allows
* momentary_rot_buttons to manage bone controllers of said model.
*
* Works in conjunction with momentary_generic_master which
* must be targetted by the momentary_rot_buttons (to prevent them from linking).
* This master entity also determines which bone controller will be managed.
*
* @author Erty
*/
class CMomentaryGeneric : ScriptBaseAnimating
{
    array<float> volumes(8, 0.0);
    array<int> noisesMoving(8, 0);
    array<bool> noisesMovingLoop(8, false);
    array<int> noisesArrived(8, 0);
    array<string> s_noisesMoving(8, "");
    array<string> s_noisesArrived(8, "");
    
    array<float> prevSets(8, 0.0);
    array<bool> isMoving(8, false);
    array<bool> isPlayingSound(8, false);

    array<Vector2D> controllers_minmax(8, Vector2D(0.0, 90.0));

    bool KeyValue(const string& in szKey, const string& in szValue)
    {
        for (uint i = 0; i < 8; i++)
        {
            if (szKey == "volume_" + formatUInt(i)) { volumes[i] = atof(szValue); return true; }
            else if (szKey == "movesnd_" + formatUInt(i)) { noisesMoving[i] = atoi(szValue); return true; }
            else if (szKey == "noise_" + formatUInt(i) + "m") { s_noisesMoving[i] = szValue; return true; }
            else if (szKey == "movesnd_loop_" + formatUInt(i)) { noisesMovingLoop[i] = atoi(szValue) != 0; return true; }
            else if (szKey == "stopsnd_" + formatUInt(i)) { noisesArrived[i] = atoi(szValue); return true; }
            else if (szKey == "noise_" + formatUInt(i) + "s") { s_noisesArrived[i] = szValue; return true; }
            else if (szKey == "controller" + formatUInt(i) + "_min") { controllers_minmax[i].x = atof(szValue); return true; }
            else if (szKey == "controller" + formatUInt(i) + "_max") { controllers_minmax[i].y = atof(szValue); return true; }
        }

        return BaseClass.KeyValue(szKey, szValue);
    }

    void Precache()
    {
        
        if (string(self.pev.model).Length() > 0)
        {
            g_Game.PrecacheModel(self.pev.model);
        }

        for (uint i = 0; i < 8; i++)
        {
            if (s_noisesMoving[i].Length() == 0)
            {
                switch(noisesMoving[i])
                {
                    case 1: s_noisesMoving[i] = "plats/bigmove1.wav"; break;
                    case 2: s_noisesMoving[i] = "plats/bigmove2.wav"; break;
                    case 3: s_noisesMoving[i] = "plats/elevmove1.wav"; break;
                    case 4: s_noisesMoving[i] = "plats/elevmove2.wav"; break;
                    case 5: s_noisesMoving[i] = "plats/elevmove3.wav"; break;
                    case 6: s_noisesMoving[i] = "plats/freightmove1.wav"; break;
                    case 7: s_noisesMoving[i] = "plats/freightmove2.wav"; break;
                    case 8: s_noisesMoving[i] = "plats/heavymove1.wav"; break;
                    case 9: s_noisesMoving[i] = "plats/rackmove1.wav"; break;
                    case 10: s_noisesMoving[i] = "plats/railmove1.wav"; break;
                    case 11: s_noisesMoving[i] = "plats/squeekmove1.wav"; break;
                    case 12: s_noisesMoving[i] = "plats/talkmove1.wav"; break;
                    case 13: s_noisesMoving[i] = "plats/talkmove2.wav"; break;
                    default: s_noisesMoving[i] = "common/null.wav";
                }
            }
            g_SoundSystem.PrecacheSound(s_noisesMoving[i]);

            
            if (s_noisesArrived[i].Length() == 0)
            {
                switch(noisesArrived[i])
                {
                    case 1: s_noisesArrived[i] = "plats/bigstop1.wav"; break;
                    case 2: s_noisesArrived[i] = "plats/bigstop2.wav"; break;
                    case 3: s_noisesArrived[i] = "plats/freightstop1.wav"; break;
                    case 4: s_noisesArrived[i] = "plats/heavystop2.wav"; break;
                    case 5: s_noisesArrived[i] = "plats/rackstop1.wav"; break;
                    case 6: s_noisesArrived[i] = "plats/railstop1.wav"; break;
                    case 7: s_noisesArrived[i] = "plats/squeekstop1.wav"; break;
                    case 8: s_noisesArrived[i] = "plats/talkstop1.wav"; break;
                    default: s_noisesArrived[i] = "common/null.wav";
                }
            }
            g_SoundSystem.PrecacheSound(s_noisesArrived[i]);
        }
    }

    void MoveThink()
    {
        bool allStopped = true;

        for (uint i = 0; i < 8; i++)
        {
            if (isMoving[i])
            {
                if (!isPlayingSound[i])
                {
                    if (noisesMovingLoop[i])
                    {
                        g_SoundSystem.EmitSound(self.edict(), CHAN_STATIC, s_noisesMoving[i], volumes[i], ATTN_NORM);
                    }
                    else
                    {
                        g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, s_noisesMoving[i], volumes[i], ATTN_NORM, SND_FORCE_SINGLE);
                    }
                    isPlayingSound[i] = true;
                }
                
                allStopped = false;
            }
            else
            {
                if (isPlayingSound[i])
                {
                    g_SoundSystem.StopSound(self.edict(), CHAN_STATIC, s_noisesMoving[i]);

                    g_SoundSystem.EmitSound(self.edict(), CHAN_WEAPON, s_noisesArrived[i], volumes[i], ATTN_NORM);
                }
                
                isPlayingSound[i] = false;
            }

            isMoving[i] = false;
        }

        if (allStopped) self.pev.nextthink = 0;
        else self.pev.nextthink = g_Engine.time + 0.1;
    }

    void Spawn()
    {
        Precache();

        for (uint i = 0; i < 8; i++)
        {
            if (volumes[i] > 1.0) volumes[i] = 1.0;
            else if (volumes[i] < 0.0) volumes[i] = 0.0;
        }

        self.pev.solid = SOLID_NOT;
        self.pev.movetype = MOVETYPE_NONE;

        g_EntityFuncs.SetModel(self, pev.model);
        g_EntityFuncs.SetOrigin(self, self.pev.origin);

        // Initialize all controllers to minimum value
        for (uint i = 0; i < 8; i++)
        {
            self.SetBoneController(i, controllers_minmax[i].x);
        }

        SetThink(ThinkFunction(this.MoveThink));
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        if (useType == USE_SET)
        {
            if (self.pev.nextthink == 0) self.pev.nextthink = g_Engine.time + 0.1;
            
            int controller = int(pCaller.pev.frags);

            if (prevSets[controller] == value) isMoving[controller] = false;
            else isMoving[controller] = true;
            prevSets[controller] == value;

            float min = controllers_minmax[controller].x;
            float max = controllers_minmax[controller].y;

            self.SetBoneController(controller, min + (max - min) * value);
        }
    }
}


class CMomentaryGenericMaster : ScriptBaseEntity
{
    void Spawn()
    {
        self.Precache();
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;
        self.pev.effects |= EF_NODRAW;
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        if (useType == USE_SET)
        {
            g_EntityFuncs.FireTargets(self.pev.target, pActivator, self, USE_SET, value);
        }
    }
}


void Register()
{
    g_CustomEntityFuncs.RegisterCustomEntity("MomentaryGeneric::CMomentaryGeneric", "momentary_generic");
    g_CustomEntityFuncs.RegisterCustomEntity("MomentaryGeneric::CMomentaryGenericMaster", "momentary_generic_master");
}

}
