/obj/item/pinpointer/detonator_remote
	name = "Explosive Detonator Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "A GPS remote designed for the linking, management and detonation of explosive ordinance."
	icon_state = "detonator_remote-off"
	item_state = "electronic"
	is_syndicate = TRUE
	w_class = W_CLASS_SMALL
	var/list/obj/item/remote_explosive/explosives_list = null
	hudarrow_color = "#ad1400"

	New()
		..()
		src.explosives_list = list()

	disposing()
		for (var/obj/item/remote_explosive/explosive in src.explosives_list)
			explosive.attempt_unlink(remote = src, disposing = TRUE)
		..()

	attack_self(mob/user)
		..()

	attackby(obj/item/W, mob/user, params)
		if (istype(W, /obj/item/remote_explosive))
			var/obj/item/remote_explosive/explosive = W
			src.update_explosives(user, explosive)

	update_arrow(var/dist)
		if(dist == 0)
			src.icon_state = "detonator_remote-direct"
		else
			src.icon_state = "detonator_remote"

	turn_off()
		..()
		src.target = null
		src.icon_state = "detonator_remote-off"

	proc/update_explosives(mob/user, obj/item/remote_explosive/explosive)
		if (explosive.active)
			// TODO: Add boutput & sound to warn to run the fuck away
			return

		if (explosive.can_link() && explosive.attempt_link(user, src))
			src.register_explosive(user, explosive)
		else if (explosive.can_unlink())
			if (explosive.attempt_unlink(user, src))
				src.unregister_explosive(user, explosive)
			else
				// TODO: Add boutput saying the bomb is linked to a different remote
				boutput(user, "<span class='alert'>The remote reports [explosive] is linked to a different remote.</span>", "remoteunlink")
		else
			boutput(user, "<span class='alert'>The remote reports an error linking [explosive].</span>", "remoteerror")
		// TODO: Add boutput saying the ran into an error

	proc/register_explosive(mob/user, obj/item/remote_explosive/explosive)
		// TODO: Add boutput saying the link was successful
		boutput(user, "<span class='notice'>You link [explosive]'s receiver to the remote.</span>", "remotelink")
		src.explosives_list += explosive

	proc/unregister_explosive(mob/user, obj/item/remote_explosive/explosive, var/disposing = FALSE)
		// TODO: Add boutput saying the unlink was successful
		if (disposing)
			boutput(user, "<span class='notice'>The remote reports that a [explosive]'s signal has been lost.</span>", "remoteunlink")
		boutput(user, "<span class='notice'>You unlink [explosive]'s receiver to the remote.</span>", "remoteunlink")
		src.explosives_list -= explosive
		if (src.active && explosive == src.target)
			src.turn_off()

