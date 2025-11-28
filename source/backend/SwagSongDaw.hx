package backend;

/**
 * The DAW (Digital Audio Workstation) used to make the song
 * 
 * Anga Dash Reborn currently supports:
 * 
 * - `FL` or `FRUITYLOOPS` (FL (Fruity Loops) Studio)
 * - `LMMS` (LMMS (The DAW ***I*** use))
 * - `GARAGEBAND` (GarageBand)
 * - `ABLETON` (Ableton Live)
 * - `BOSCACEOIL` (Bosca Ceoil)
 * - `FAMITRACKER` (FamiTracker)
 * - `FAMISTUDIO` (FamiStudio)
 * - `FURNACE` or `FURNACETRACKER` (Funace)
 * - `REAPER` or `REA` (Reaper)
 * - `UNKNOWN` or `OTHER` (None of the above)
 */
enum SwagSongDaw
{
	/**
	 * FL (Fruity Loops) Studio
	 */
	FL;

	/**
	 * FL (Fruity Loops) Studio
	 */
	FRUITYLOOPS;

	/**
	 * LMMS (The DAW ***I*** use)
	 */
	LMMS;

	/**
	 * GarageBand
	 */
	GARAGEBAND;

	/**
	 * Ableton Live
	 */
	ABLETON;

	/**
	 * Bosca Ceoil
	 */
	BOSCACEOIL;

	/**
	 * FamiTracker
	 */
	FAMITRACKER;

	/**
	 * FamiStudio
	 */
	FAMISTUDIO;

	/**
	 * Furnace
	 */
	FURNACE;

	/**
	 * Furnace
	 */
	FURNACETRACKER;

	/**
	 * Reaper
	 */
	REAPER;

	/**
	 * Reaper
	 */
	REA;

	/**
	 * None
	 */
	UNKNOWN;

	/**
	 * None
	 */
	OTHER;
}
