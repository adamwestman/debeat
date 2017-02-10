# debeat
Sound Library for the Defold Engine

## Mixer

Interface for controlling tracks and sound groups, enabling smooth transitions of gain values.

**Requires mixer.go to be added**

* mixer.play(url, [config])
* mixer.stop(url, [config])
* mixer.set_gain(url, gain, [config])
* mixer.set_group_gain(hash, gain, [config])


**play config**
* delay
* attack
* easing
* gain

**stop config**
* delay
* decay
* easing
* gain

**gain config**
* delay
* duration
* easing

## Queue

Interface for controlling sfx in categories, playing them in order or disorder.

* queue.create(id, [config])
* instance.add(url)
* instance.play(url, [delay_seconds], [gain])
* instance.stop()


**create config**
* gating
* behaviour
* min_offset


## Usage

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
	
