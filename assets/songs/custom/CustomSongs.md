# Adding Custom Songs

As I learned form the original, the NG API is a waste of time! So you'll need to add songs in yourself. Here's a guide:

## For Newgrounds

1. Go to [Newgrounds](https://www.newgrounds.com)
2. Find the song you're looking for
3. If downloadable, download it otherwise repeat step 2 and come back
4. Create a folder named as the song ID in `assets/songs/custom/newgrounds`
5. Drop the song in the folder you just created
6. Name the song file `song.ogg`
7. Convert to OGG
8. Create a `metadata.json` (more on that later)
9. Profit! You're done!

## For SoundCloud

1. Go to [SoundCloud](https://soundcloud.com/discover)
2. Find the song you're looking for
3. Copy link
4. Go to the unofficial [Soundcloud Downloader To Mp3 Tool](https://soundcloudtool.com/)
5. Paste the copied link
6. Click Download MP3 Track
7. Convert to OGG
8. Create a folder named as the song ID in `assets/songs/custom/soundcloud`
9. Drop in the song in the folder you just created
10. Name the song file `song.ogg`
11. Create a `metadata.json` (more on that later)
12. Profit! You're done!

## For none of the above

### Online

1. Go to wherever your song is (ex. Incompletech, YouTube...)
2. Find the song
3. Download it (somehow)
4. If type isn't OGG, convert to OGG
5. Create a folder named as the song title in `assets/songs/custom/neither`
6. Drop in that folder
7. Name the song file `song.ogg`
8. Create a `metadata.json` (more on that later)
9. Profit! You're done!

### On Your PC

1. Go to where your song is in your computer
2. If type isn't OGG, convert
3. Create a folder named as the song title in `assets/songs/custom/neither`
4. Copy and paste to the folder you just created
5. Name the song file `song.ogg`
6. Create a `metadata.json` (more on that later)
7. Profit! You're done!

## Metadata

Anga Dash can't read file metadata. So you'll need to use a JavaScript Object Notation (JSON) file. Here are example metadatas for RESONATING RACE by KingSammelot:

A:

```json
{
    "name": "RESONATING RACE (Huzzah!)",
    "composer": "KingSammelot",
    "daw": "FL"
}
```

B:

```json
{
    "name": "RESONATING RACE (Huzzah!)",
    "composers": ["KingSammelot", "Verizon"],
    "daw": "FL"
}
```

C:

```json
{
    "name": "RESONATING RACE (Huzzah!)",
    "composers": {
        "mainArtists": ["KingSammelot"],
        "consultants": ["Verizon"]
    },
    "daw": "FL"
}
```

Let me explain what each field is.

### Metadata Fields

#### `"name"`

The title of the song. In the examples provided, it's "RESONATING RACE (Huzzah!)".

#### `"composers"`

A list of the people behind the song

2 cases:

- If provided as an array (like in example B), the game will credit the people behind the song, but not their part in it
- If provided as a structure (like in example C), the game will credit the people behind the song, this time, **including** their part in it. (Doesn't work / not handled **_yet_**)

##### `"composer"`. The predecessor to the `"composers"` field

**The person** behind the song (See examlpe A). Will be ignored if `"composers"` is provided

#### `"daw"`

The Digital Audio Workstation (DAW) the song was made in. Can be (with quotes):

- `"FL"` or `"FRUITYLOOPS"` (FL (Fruity Loops) Studio)
- `"LMMS"` (LMMS (The DAW **_I_** use))
- `"GARAGEBAND"` (GarageBand)
- `"ABLETON"` (Ableton Live)
- `"BOSCACEOIL"` (Bosca Ceoil (The Blue Album Included))
- `"FAMITRACKER"` (FamiTracker)
- `"FAMISTUDIO"` (FamiStudio)
- `"FURNACE"` or `"FURNACETRACKER"` (Funace)
- `"REAPER"` or `"REA"` (Reaper)
- `"UNKNOWN"` or `"OTHER"` (None of the above)

### Creating Metadata with the _Metadata Editor_

#### Debug Mode (with `lime test windows --debug` on source)

1. Play a level
2. Press 8
3. You're in the **_Metadata Editor_**

It should look like this:

![AD_MetaEdit](AD_MetaEdit.png)

#### Release Mode (Not ready yet)
