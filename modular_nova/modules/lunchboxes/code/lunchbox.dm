/obj/item/storage/lunchbox
	name = "lunchbox"
	desc = "A small metal box for portable luncheon action."
	icon = 'modular_nova/modules/lunchboxes/icons/lunchbox.dmi'
	icon_state = "lunchbox_metal"
	drop_sound = 'sound/items/handling/toolbox/toolbox_drop.ogg'
	pickup_sound =  'sound/items/handling/toolbox/toolbox_pickup.ogg'
	inhand_icon_state = null
	//generates the list for all the designs
	var/list/lunchbox_designs = list()
	//specifies which sprite we have active
	var/design_choice = "Metal"

/obj/item/storage/lunchbox/examine(mob/living/user)
	. = ..()
	. += span_notice("You could apply a new design with a pen!")

/obj/item/storage/lunchbox/Initialize(mapload)
	. = ..()
	lunchbox_designs = sort_list(list(
		"Metal" = image(icon = src.icon, icon_state = "lunchbox_metal"),
		"Nanotrasen" = image(icon = src.icon, icon_state = "lunchbox_nanotrasen"),
		"Hearts" = image(icon = src.icon, icon_state = "lunchbox_hearts"),
		"Rainbow" = image(icon = src.icon, icon_state = "lunchbox_rainbow"),
		"Cat" = image(icon = src.icon, icon_state = "lunchbox_cat")
		))
	update_appearance()

/obj/item/storage/lunchbox/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, design_choice))
		update_appearance()



/obj/item/storage/lunchbox/update_desc(updates)
	switch(design_choice)
		if("None")
			desc = "A small metal box for portable luncheon action."
		if("Nanotrasen")
			desc = "A standard Nanotrasen metal lunchbox."
		if("Hearts")
			desc = "A metal lunchbox in a beautiful pink, adorned with cutesy hearts."
		if("Rainbow")
			desc = "A lunchbox as colourful as the rainbow. Because it has one on it."
		if("Cat")
			desc = "A metal lunchbox with a beautiful cat adorning it."
	return ..()

/obj/item/storage/lunchbox/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(IS_WRITING_UTENSIL(tool))
		var/choice = show_radial_menu(user, src , lunchbox_designs, custom_check = CALLBACK(src, PROC_REF(check_menu), user, tool), radius = 36, require_near = TRUE)
		if(!choice || choice == design_choice)
			return ITEM_INTERACT_BLOCKING
		design_choice = choice
		balloon_alert(user, "modified")
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	else
		return ITEM_INTERACT_BLOCKING

/obj/item/storage/lunchbox/proc/check_menu(mob/user, obj/item/pen/P)
	if(!istype(user))
		return FALSE
	if(user.incapacitated)
		return FALSE
	else
		return TRUE
/*/obj/item/storage/lunchbox(mob/living/user, list/modifiers)
	. = ..()
	var/choice = show_radial_menu(user, src , lunchbox_designs , custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!choice || choice == design_choice)
		return ITEM_INTERACT_BLOCKING
	design_choice = choice
	balloon_alert(user, "modified")
	update_appearance()
	return ITEM_INTERACT_SUCCESS
/datum/storage/lunchbox
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = 4
	set_holdable(/obj/item/food/)
*/
