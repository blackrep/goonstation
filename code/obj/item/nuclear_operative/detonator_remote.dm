/obj/item/pinpointer/detonator_remote
	name = "Explosive Detonator Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "A GPS remote designed for the linking, management and detonation of explosive ordinance."
	icon_state = "detonator_remote-off"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	var/tracking_target = null
	var/frequency = FREQ_GPS
	var/net_id = null
	var/list/receiver_net_ids = list()

	New()
		..()
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, src.frequency)

	disposing()
		..()
		// TODO: Unlink the bombs if this gets destroyed

	attack_self(mob/user)
		return

	attackby(obj/item/W, mob/user, params)
		if (istype(W, /obj/item/remote_explosive))
			var/obj/item/remote_explosive/receiver = W
			src.update_receivers(receiver)

	update_arrow(var/dist)
		if(dist == 0)
			icon_state = "detonator_remote-direct"
		else
			icon_state = "detonator_remote"

	proc/update_receivers(obj/item/remote_explosive/receiver)
		receiver.icon_state = "remote_explosive-linked"
		return

	receive_signal(datum/signal/signal)
		return
