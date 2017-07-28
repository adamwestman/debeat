# DeBeat
Sound Library for the Defold Engine

Try the [HTML5 Demo](https://adamwestman.github.io/Debeat/)

# Usage
1. Add latest zip URL as a [dependency](http://www.defold.com/manuals/libraries/#_setting_up_library_dependencies) in your Defold project: `https://github.com/adamwestman/debeat/archive/master.zip`

2. Add the mixer.go, located in `debeat/go/mixer.go`, to your bootstrap collection.

3. Create a track by adding a sound component and setting it to "Loop"

4. Create a script and require the mixer module: `local mixer = require("debeat.mixer")`

5. Start the track by passing it's url to mixer.play: `mixer.play(msg.url("#track"))` with an optional table for gain etc.

# Documentation

## Mixer

Interface for controlling tracks and sound groups, enabling smooth transitions of gain values.

**Requires mixer.go to be added**

* mixer.play(url, [config]) -- start playing a track.
* mixer.stop(url, [config]) -- stop playing a track.
* mixer.set_gain(url, gain, [config]) -- change gain on a playing track.
* mixer.set_group_gain(hash, gain, [config])  -- change gain on a known group.
* mixer.refresh_groups()  -- refresh known sound groups, in case a collectionproxy loaded new ones.
* local boolean = mixer.is_ready() -- verify that the mixer.go has been initalized.

url is expected to point at a sound component. msg.url("#comp")

gain is expected to be a number between 0-1.

group is expected to be a hash matching a known sound group.

**play config**
* delay [number] time in seconds until the fade will begin, defaults to 0
* attack [number] time in seconds the fade in will take, defaults to 0.1
* easing [go.EASING_X] curve the gain value will fade in using, defaults to go.EASING_LINEAR
* gain [number 0-1] gain value the sound will fade up to, defaults to 1

**stop config**
* delay [number] time in seconds until the fade will begin, defaults to 0
* decay [number] time in seconds the fade out will take, defaults to 0.1
* easing [go.EASING_X] curve the gain value will fade out using, defaults to go.EASING_LINEAR

**set_gain config**
* delay [number] time in seconds until the fade will begin, defaults to 0
* duration [number] time in seconds the change will take, defaults to 0.01
* easing [go.EASING_X] curve the gain value will fade using, defaults to go.EASING_LINEAR

## Queue

Interface for controlling sfx in categories, playing them in order or disorder.

* local instance = queue.create(hash, [config])
* instance.add(url)
* instance.play(url, [delay_seconds], [gain])
* instance.stop()

url is expected to point at a sound component. msg.url("#comp")

delay_seconds [number] time in seconds until the sound will be played.

gain is expected to be a number between 0-1, defaults to 1.

**create config**
* gating [number] time in seconds required between instance.play, defaults to 0.1
* behaviour [queue.TYPE_X] constant representing the behaviour of the queue, defaults to TYPE_SEQUENCE.
* repeat_offset [integer] value between 1 and number of added sounds, preventing repeat of a sound until that many others have played.

### Script based
Queues can also be setup using a specific Game Object and script setup. The queue id will match that of the Game Object and the amount of sounds specified in the coresponding property will be expected as sound components named "sound1", "sound2" etc.

**available queues** Where each script matches on of the available queue behaviours
* debeat/queues/random.script *plays sound in shuffled order*
* debeat/queues/sequence.script *plays sounds in order, then repeats*

![alt text](https://github.com/adamwestman/debeat/blob/master/queue_setup.png "Queue objects")

## Event

The event system aims to separate audio controll from logic, enabling zero or multiple *event handlers* to react on trigger. With this approach teams can litter their code with events and later on add and tweak the audio using scripts alone.

* event.trigger(hash|string)
* event(hash|string) *for short*

**available handlers**
* play_mixed.script *play a sound using the mixer.*
* play_queue.script *play a sound selected by a specific queue.*
* play_sound.script *play a sound.*
* reset_queue.script *reset the play-order for a specific queue.*
* set_group_gain.script *change the gain value of a group.*
* set_mixed_gain.script *change the gain value of sound currently played by the mixer.*
* stop_mixed.script *stop a sound currently played by the mixer.*
* stop_queue.script *stop all sounds played by a specific queue.*

For all scripts the property *Event Name* will be compared with triggered events and if a match is found they will react.

![alt text](https://github.com/adamwestman/debeat/blob/master/queue_event.png "Queue event")

**common params**
* Event Name			: The event which the listener will be attached to. Should match something triggered by events in the game.
* Queue Name			: Should match the id of a Queue. For scripts this will be the game-object ID.
* Sound						: Which sound component to invoke. Should be a url relative or absolute.
* Gain 						: A value between 0-1 at which the sound will be played.
* Gain Variation	: A range of extra random variation to the gain. *can be negative*
* Delay						: Time in seconds to wait after the event has fired, before performing the action.
* Attack					: Time in seconds to perform fade-in of the sound.
* Decay						: Time in seconds to perform fade-out of the sound.
* Easing					: One of the Defold provided Easing values to use when fading. See [debeat.util.easing](debeat/util/easing.lua) for options.

# Examples

**collection setup**

![alt text](https://github.com/adamwestman/debeat/blob/master/simple_integration.png "Simple Integration")


**coded**
```lua
	local mixer = require("debeat.mixer")
	local queue = require("debeat.queue")

	function init(self)
		msg.post(".", "acquire_input_focus")

		self.sfx_btn = queue.create(hash("btn"), {gating=0.3, behaviour=queue.TYPE_RANDOM, repeat_offset=2})
		self.sfx_btn.add(msg.url("/sounds#sfx_btn1"))
		self.sfx_btn.add(msg.url("/sounds#sfx_btn2"))
		self.sfx_btn.add(msg.url("/sounds#sfx_btn3"))
	end

	function on_input(self, action_id, action)
		if action_id == hash("sfx") and action.released then
			self.sfx_btn.play()

		elseif action_id == hash("play") and action.released then
			mixer.play(msg.url("/sounds#track_ingame"))
		elseif action_id == hash("stop") and action.released then
			mixer.stop(msg.url("/sounds#track_ingame"))
		elseif action_id == hash("drop") and action.released then
			mixer.set_gain(msg.url("/sounds#track_ingame"), 0.5)

		elseif action_id == hash("mute") and action.released then
			mixer.set_group_gain(hash("master"), 0)
		elseif action_id == hash("unmute") and action.released then
			mixer.set_group_gain(hash("master"), 1)

		end
	end
```

**event driven**

```lua
local event = require("debeat.event")

local button = require("examples.templates.button")

function init(self)
	msg.post(".", "acquire_input_focus")

	event.add_listener("block", function()
		print("Block happened")
	end)
end

function on_input(self, action_id, action)
	-- Trigger events
	if button.on_input("event_start", action_id, action) then
		event("game_start")
		return true
	elseif button.on_input("event_end", action_id, action) then
		event("game_end")
		return true
	elseif button.on_input("attack", action_id, action) then
		event("attack")
		return true
	elseif button.on_input("block", action_id, action) then
		event("block")
		return true

	end
end
```
