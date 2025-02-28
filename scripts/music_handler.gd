extends Node

## TAKES STRING AS SONG NAME, PLAYS SONG
func play(song : String) -> void:
	match song:
		"BitTragedy":
			if !$BitTragedy.playing:
				$SwarmingOnslaught.stop()
				$BitTragedy.play()
				$SquareDreams.stop()
				$PixelizedFields.stop()
		"SquareDreams":
			if !$SquareDreams.playing:
				$SwarmingOnslaught.stop()
				$BitTragedy.stop()
				$SquareDreams.play()
				$PixelizedFields.stop()
		"SwarmingOnslaught":
			if !$SwarmingOnslaught.playing:
				$SwarmingOnslaught.play()
				$BitTragedy.stop()
				$SquareDreams.stop()
				$PixelizedFields.stop()
		"PixelizedFields":
			if !$PixelizedFields.playing:
				$SwarmingOnslaught.stop()
				$BitTragedy.stop()
				$SquareDreams.stop()
				$PixelizedFields.play()
		_:
			$SwarmingOnslaught.stop()
			$BitTragedy.stop()
			$SquareDreams.stop()
			$PixelizedFields.stop()
