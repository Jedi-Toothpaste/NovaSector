GLOBAL_LIST_EMPTY(cargo_marks)

/obj/item/cargo_teleporter
	name = "cargo teleporter"
	desc = "An item that can set down a set number of markers, allowing them to teleport items within a tile to the set markers."
	icon = 'modular_nova/modules/cargo_items/icons/cargo_teleporter.dmi'
	icon_state = "cargo_tele"
	///the list of markers spawned by this item
	var/list/marker_children = list()
	///which marker it is currently on
	var/obj/effect/decal/cleanable/cargo_mark/selected_mark

	COOLDOWN_DECLARE(use_cooldown)

/obj/item/cargo_teleporter/examine(mob/user)
	. = ..()
	. += span_notice("Attack itself to set down the markers!")
	. += span_notice("ALT-CLICK to open options for removing markers or setting markers!")

/obj/item/cargo_teleporter/Destroy()
	if(length(marker_children))
		for(var/obj/effect/decal/cleanable/cargo_mark/destroy_children in marker_children)
			destroy_children.parent_item = null
			qdel(destroy_children)

	return ..()

/obj/item/cargo_teleporter/attack_self(mob/user, modifiers)
	if(length(marker_children) >= 3)
		to_chat(user, span_warning("You may only have three spawned markers from [src]!"))
		return

	to_chat(user, span_notice("You place a cargo marker below your feet."))
	var/obj/effect/decal/cleanable/cargo_mark/spawned_marker = new /obj/effect/decal/cleanable/cargo_mark(get_turf(src))
	playsound(src, 'sound/machines/click.ogg', 50)
	spawned_marker.parent_item = src
	marker_children += spawned_marker

/obj/item/cargo_teleporter/click_alt(mob/user)
	var/option_selection = tgui_input_list(user, "What would you like to do?", "Cargo Teleporter Options", list("Remove all markers", "Set default marker"))
	if(isnull(option_selection))
		return CLICK_ACTION_BLOCKING

	if(option_selection == "Remove all markers")
		if(length(marker_children))
			for(var/obj/effect/decal/cleanable/cargo_mark/destroy_children in marker_children)
				qdel(destroy_children)

		return CLICK_ACTION_SUCCESS

	if(option_selection == "Set default marker")
		var/cargo_mark_selection = tgui_input_list(user, "Select which cargo mark to teleport the items to?", "Cargo Mark Selection", GLOB.cargo_marks)
		if(isnull(cargo_mark_selection))
			return CLICK_ACTION_BLOCKING

		selected_mark = cargo_mark_selection
		to_chat(user, span_notice("You have selected [selected_mark] as the default mark. ALT-CLICK to open up the options to change the selection."))
		return CLICK_ACTION_SUCCESS

/obj/item/cargo_teleporter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_warning("[src] is still on cooldown!"))
		return ITEM_INTERACT_BLOCKING

	if(isnull(selected_mark))
		var/choice = tgui_input_list(user, "Select which cargo mark to teleport the items to?", "Cargo Mark Selection", GLOB.cargo_marks)
		if(isnull(choice))
			return ITEM_INTERACT_BLOCKING

		selected_mark = choice
		to_chat(user, span_notice("You have selected [selected_mark] as the default mark. ALT-CLICK to open up the options to change the selection."))

	if(get_dist(user, interacting_with) > 1)
		return ITEM_INTERACT_BLOCKING

	var/turf/moving_turf = get_turf(selected_mark)
	var/turf/target_turf = get_turf(interacting_with)
	for(var/check_content in target_turf.contents)
		if(isobserver(check_content))
			continue

		if(!ismovable(check_content))
			continue

		var/atom/movable/movable_content = check_content
		if(isliving(movable_content))
			continue

		if(length(movable_content.get_all_contents_type(/mob/living)))
			continue

		if(movable_content.anchored)
			continue

		do_teleport(movable_content, moving_turf, asoundout = 'sound/effects/magic/Disable_Tech.ogg')

	new /obj/effect/decal/cleanable/ash(target_turf)
	COOLDOWN_START(src, use_cooldown, 8 SECONDS)
	return ITEM_INTERACT_SUCCESS

/datum/design/cargo_teleporter
	name = "Cargo Teleporter"
	desc = "A wonderful item that can set markers and teleport things to those markers."
	id = "cargotele"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/cargo_teleporter
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/uranium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_CARGO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/obj/effect/decal/cleanable/cargo_mark
	name = "cargo mark"
	desc = "A mark left behind by a cargo teleporter, which allows targeted teleportation. Can be removed by the cargo teleporter."
	icon = 'modular_nova/modules/cargo_items/icons/cargo_teleporter.dmi'
	icon_state = "marker"
	///the reference to the item that spawned the cargo mark
	var/obj/item/cargo_teleporter/parent_item

	light_range = 3
	light_color = COLOR_VIVID_YELLOW

/obj/effect/decal/cleanable/cargo_mark/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/cargo_teleporter))
		to_chat(user, span_notice("You remove [src] using [attacking_item]."))
		playsound(src, 'sound/machines/click.ogg', 50)
		qdel(src)
		return

	return ..()

/obj/effect/decal/cleanable/cargo_mark/Destroy()
	if(parent_item)
		parent_item.marker_children -= src

	GLOB.cargo_marks -= src
	return ..()

/obj/effect/decal/cleanable/cargo_mark/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	var/area/src_area = get_area(src)
	name = "[src_area.name] ([rand(100000,999999)])"
	GLOB.cargo_marks += src
