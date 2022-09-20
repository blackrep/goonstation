/obj/item/remote_explosive
	name = "pipe bomb"
	desc = "An improvised explosive made primarily out of two pipes." // cogwerks - changed the name
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "remote_explosive-unlinked"
	var/timer = 5 SECONDS
	var/strength = 32

	ex_act(severity)
		src.blowthefuckup(strength, TRUE)
		. = ..()

	attackby(obj/item/W, mob/user, params)
		if (istype(W, /obj/item/pinpointer/detonator_remote))
			var/obj/item/pinpointer/detonator_remote/remote = W
			remote.update_receivers(src)
