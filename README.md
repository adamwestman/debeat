# debeat
Sound Library for the Defold Engine

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

* local instance = queue.create(id, [config])
* instance.add(url)
* instance.play(url, [delay_seconds], [gain])
* instance.stop()

url is expected to point at a sound component. msg.url("#comp")

delay_seconds [number] time in seconds until the sound will be played.

gain is expected to be a number between 0-1, defaults to 1.

**create config**
* gating [number] time in seconds required between instance.play, defaults to 0.1
* behaviour [queue.TYPE_X] constant representing the behaviour of the queue, defaults to TYPE_SEQUENCE.
* min_offset [integer] value between 1 and number of added sounds, preventing repeat of a sound until that many others have played.


# Examples

![alt text](https://github.com/adamwestman/debeat/blob/master/simple_integration.png "Simple Integration")


	local mixer = require("debeat.mixer")
	local queue = require("debeat.queue")
	
	function init(self)
		msg.post(".", "acquire_input_focus")
	
		self.sfx_btn = queue.create("btn", {gating=0.3, behaviour=queue.TYPE_RANDOM, min_offset=2})
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
	
