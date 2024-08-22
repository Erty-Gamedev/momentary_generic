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

/**
  * Map initialisation handler.
  * @return void
  */
void MapInit()
{
    // g_Module.ScriptInfo.SetAuthor("Erty");
    g_CustomEntityFuncs.RegisterCustomEntity("momentary_generic", "momentary_generic");
    g_CustomEntityFuncs.RegisterCustomEntity("momentary_generic_master", "momentary_generic_master");
}

/**
  * Map activation handler.
  * @return void
  */
void MapActivate()
{
    g_Game.AlertMessage(at_console, "momentary_generic loaded.\n");
}

class momentary_generic : ScriptBaseAnimating
{
    float volume;
    int noiseMoving;
    bool noiseMovingLoop;
    int noiseArrived;
    float prevSet;
    bool isMoving;
    bool isPlayingSound;
    array<array<float>> controllers_minmax =
    {
        {0.0, 90.0}, // controller 0
        {0.0, 90.0}, // controller 1
        {0.0, 90.0}, // controller 2
        {0.0, 90.0}, // controller 3
        {0.0, 90.0}, // controller 4
        {0.0, 90.0}, // controller 5
        {0.0, 90.0}, // controller 6
        {0.0, 90.0}  // controller 7
    };

    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        if      (szKey == "volume")       volume           = atof(szValue);
        else if (szKey == "movesnd")      noiseMoving      = atoi(szValue);
        else if (szKey == "movesnd_loop") noiseMovingLoop =  atoi(szValue) != 0;
        else if (szKey == "stopsnd")      noiseArrived     = atoi(szValue);
        else if (szKey == "controller0_min") controllers_minmax[0][0] = atof(szValue);
        else if (szKey == "controller0_max") controllers_minmax[0][1] = atof(szValue);
        else if (szKey == "controller1_min") controllers_minmax[1][0] = atof(szValue);
        else if (szKey == "controller1_max") controllers_minmax[1][1] = atof(szValue);
        else if (szKey == "controller2_min") controllers_minmax[2][0] = atof(szValue);
        else if (szKey == "controller2_max") controllers_minmax[2][1] = atof(szValue);
        else if (szKey == "controller3_min") controllers_minmax[3][0] = atof(szValue);
        else if (szKey == "controller3_max") controllers_minmax[3][1] = atof(szValue);
        else if (szKey == "controller4_min") controllers_minmax[4][0] = atof(szValue);
        else if (szKey == "controller4_max") controllers_minmax[4][1] = atof(szValue);
        else if (szKey == "controller5_min") controllers_minmax[5][0] = atof(szValue);
        else if (szKey == "controller5_max") controllers_minmax[5][1] = atof(szValue);
        else if (szKey == "controller6_min") controllers_minmax[6][0] = atof(szValue);
        else if (szKey == "controller6_max") controllers_minmax[6][1] = atof(szValue);
        else if (szKey == "controller7_min") controllers_minmax[7][0] = atof(szValue);
        else if (szKey == "controller7_max") controllers_minmax[7][1] = atof(szValue);
        
        else return BaseClass.KeyValue(szKey, szValue);
        return true;
    }

    void Precache()
    {
        
        if (string(self.pev.model).Length() > 0)
        {
            g_Game.PrecacheModel(self.pev.model);
        }

        if (string(self.pev.noise).Length() == 0)
        {
            switch(noiseMoving)
            {
                case 1: self.pev.noise = "plats/bigmove1.wav"; break;
                case 2: self.pev.noise = "plats/bigmove2.wav"; break;
                case 3: self.pev.noise = "plats/elevmove1.wav"; break;
                case 4: self.pev.noise = "plats/elevmove2.wav"; break;
                case 5: self.pev.noise = "plats/elevmove3.wav"; break;
                case 6: self.pev.noise = "plats/freightmove1.wav"; break;
                case 7: self.pev.noise = "plats/freightmove2.wav"; break;
                case 8: self.pev.noise = "plats/heavymove1.wav"; break;
                case 9: self.pev.noise = "plats/rackmove1.wav"; break;
                case 10: self.pev.noise = "plats/railmove1.wav"; break;
                case 11: self.pev.noise = "plats/squeekmove1.wav"; break;
                case 12: self.pev.noise = "plats/talkmove1.wav"; break;
                case 13: self.pev.noise = "plats/talkmove2.wav"; break;
                default: self.pev.noise = "common/null.wav";
            }
        }
        g_SoundSystem.PrecacheSound(self.pev.noise);

        if (string(self.pev.noise1).Length() == 0)
        {
            switch(noiseArrived)
            {
                case 1: self.pev.noise1 = "plats/bigstop1.wav"; break;
                case 2: self.pev.noise1 = "plats/bigstop2.wav"; break;
                case 3: self.pev.noise1 = "plats/freightstop1.wav"; break;
                case 4: self.pev.noise1 = "plats/heavystop2.wav"; break;
                case 5: self.pev.noise1 = "plats/rackstop1.wav"; break;
                case 6: self.pev.noise1 = "plats/railstop1.wav"; break;
                case 7: self.pev.noise1 = "plats/squeekstop1.wav"; break;
                case 8: self.pev.noise1 = "plats/talkstop1.wav"; break;
                default: self.pev.noise1 = "common/null.wav";
            }
        }
        g_SoundSystem.PrecacheSound(self.pev.noise1);
    }

    void MoveThink()
    {
        if (isMoving)
        {
            if (!isPlayingSound)
            {
                if (noiseMovingLoop)
                {
                    g_SoundSystem.EmitSound(self.edict(), CHAN_STATIC, self.pev.noise, volume, ATTN_NORM);
                }
                else
                {
                    g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, self.pev.noise, volume, ATTN_NORM, SND_FORCE_SINGLE);
                }
                isPlayingSound = true;
            }
            
            self.pev.nextthink = g_Engine.time + 0.1;
        }
        else
        {
            if (isPlayingSound)
            {
                g_SoundSystem.StopSound(self.edict(), CHAN_STATIC, self.pev.noise);

                g_SoundSystem.EmitSound(self.edict(), CHAN_WEAPON, self.pev.noise1, volume, ATTN_NORM);
            }
            
            isPlayingSound = false;
            self.pev.nextthink = 0;
        }

        isMoving = false;
    }

    void Spawn()
    {
        Precache();

        if (volume > 10) volume = 10;
        else if (volume < 0) volume = 0;

        prevSet = 0.0;
        isMoving = false;
        isPlayingSound = false;

        self.pev.solid = SOLID_NOT;
        self.pev.movetype = MOVETYPE_NONE;

        g_EntityFuncs.SetModel(self, pev.model);
        g_EntityFuncs.SetOrigin(self, self.pev.origin);

        // Initialize all controllers to minimum value
        for (uint i = 0; i < 8; i++)
        {
            self.SetBoneController(i, controllers_minmax[i][0]);
        }

        SetThink(ThinkFunction(this.MoveThink));
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        if (useType == USE_SET)
        {
            if (self.pev.nextthink == 0) self.pev.nextthink = g_Engine.time + 0.1;
            
            if (prevSet == value) isMoving = false;
            else isMoving = true;
            prevSet = value;

            int controller = pCaller.pev.frags;
            float min = controllers_minmax[controller][0];
            float max = controllers_minmax[controller][1];

            self.SetBoneController(controller, min + (max - min) * value);
        }
    }
}


class momentary_generic_master : ScriptBaseEntity
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
