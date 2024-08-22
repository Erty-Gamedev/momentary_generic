# momentary_generic

A pair of custom entities that allows using *momentary_rot_button*
entities to manage the bone controllers of a model.

### momentary_generic

This is the entity used to display the model and configure
parameters such as controller ranges and sounds played during
and after use.

The controller min/max values configures the range of bone controller.<br>
For linear controller this is the relative distances in game units
along the bone's controller axis from the bone's rest position.<br>
For rotational controller this is the angles in degrees of rotation around
the bone's controller axis.

### momentary_generic_master

As *momentary_rot_button* entities will link if sharing the same target,
this entity will be used to get around that.

A *momentary_rot_button* will target this entity, which in turn targets
the *momentary_generic* and tells which bone controller it will manage.

## Using in your map

Make sure to place *momentary_generic.as* in */svencoop_addon/scripts/maps/erty*
and load *momentary_generic.fgd* in your level editor.

Then simply create a *trigger_script* in your map with the **Script to load** (*m_iszScriptFile*) key set to `erty/momentary_generic`.

Now you will be able to place *momentary_generic* and *momentary_generic_master*
entities in your map.
