Scriptname TattoosOfSkyrimQuestScript extends Quest  

Faction Property ForswornFaction auto
Faction Property BanditFaction auto
Faction Property VampireFaction auto
Faction Property VampireThrallFaction auto
Faction Property WarlockFaction auto

Race Property HighElfRace auto
Race Property ArgonianRace auto
Race Property WoodElfRace auto
Race Property BretonRace auto
Race Property DarkElfRace auto
Race Property ImperialRace auto
Race Property KhajiitRace auto
Race Property NordRace auto
Race Property OrcRace auto
Race Property RedguardRace auto

int tattoosMap
int colorsArray

Bool BusyLoading = True

Event OnInit()
  If IsRunning()
    ; Perform init for this game load
    LoadData()
  Else
    ; Start the quest (first time mod is installed)
    Start()
  EndIf
EndEvent

Function LoadData()
  BusyLoading = True

  If PapyrusUtil.GetVersion() != PapyrusUtil.GetScriptVersion()
    Debug.TraceAndBox("Detected an incorrect PapyrusUtil installation. Make sure that no mod overwrites any PapyrusUtil files. Simply Knock and Campfire are common examples: let PapyrusUtil overwrite their files!")
  ElseIf PapyrusUtil.GetVersion() < 33
    Debug.TraceAndBox("Tattoos of Skyrim requires at least version 3.3 of PapyrusUtil to be installed!")
  EndIf

  PopulateTattoos("Data/SKSE/Plugins/TattoosOfSkyrim")
  PopulateColors(MCM.GetModSettingString("TattoosOfSkyrim", "sColors:"))

  BusyLoading = False
EndFunction

Bool Function FinishedLoading()
  return !BusyLoading
EndFunction

int Function GetOverlaysView(Actor akActor, int sex)
  int view = JArray.object()

  String[] factionCdd = new String[2]
  factionCdd[0] = "AnyFaction"
  If akActor.IsInFaction(ForswornFaction)
    factionCdd[1] = "Forsworn"
  ElseIf akActor.IsInFaction(BanditFaction)
    factionCdd[1] = "Bandit"
  ElseIf akActor.IsInFaction(VampireFaction)
    factionCdd[1] = "Vampire"
  ElseIf akActor.IsInFaction(VampireThrallFaction)
    factionCdd[1] = "VampireThrall"
  ElseIf akActor.IsInFaction(WarlockFaction)
    factionCdd[1] = "Warlock"
  Else
    Faction[] akFactions = akActor.GetFactions(0, 127)
    If akFactions.Length > 0
      factionCdd[1] = akFactions[0].GetName()
    Else
      factionCdd[1] = "Other"
    EndIf
  EndIf

  String[] sexCdd = new String[2]
  sexCdd[0] = "AnySex"
  If sex == 1
    sexCdd[1] = "Female"
  ElseIf sex == 0
    sexCdd[1] = "Male"
  Else
    sexCdd[1] = "Other"
  EndIf 

  String[] raceCdd = new String[2]
  raceCdd[0] = "AnyRace"
  Race actorRace = akActor.GetRace()
  If actorRace == HighElfRace
    raceCdd[1] = "HighElf"
  ElseIf actorRace == ArgonianRace
    raceCdd[1] = "Argonian"
  ElseIf actorRace == WoodElfRace
    raceCdd[1] = "WoodElf"
  ElseIf actorRace == BretonRace
    raceCdd[1] = "Breton"
  ElseIf actorRace == DarkElfRace
    raceCdd[1] = "DarkElf"
  ElseIf actorRace == ImperialRace
    raceCdd[1] = "Imperial"
  ElseIf actorRace == KhajiitRace
    raceCdd[1] = "Khajiit"
  ElseIf actorRace == NordRace
    raceCdd[1] = "Nord"
  ElseIf actorRace == OrcRace
    raceCdd[1] = "Orc"
  ElseIf actorRace == RedguardRace
    raceCdd[1] = "Redguard"
  Else
    raceCdd[1] = actorRace.GetName()
  EndIf

  int j = 0
  While j < factionCdd.Length
    int k = 0
    While k < sexCdd.Length
      int l = 0
      While l < raceCdd.Length
        String mapKey = factionCdd[j] + "." + sexCdd[k] + "." + raceCdd[l]
        int array = JMap.getObj(tattoosMap, mapKey)
        If array != 0
          JArray.addObj(view, array)
        EndIf
        l += 1
      EndWhile
      k += 1
    EndWhile
    j += 1
  EndWhile

  return view
EndFunction

int Function GetRandomColor()
  int count = JArray.count(colorsArray)
  If count > 0
    return JArray.getInt(colorsArray, Utility.RandomInt(0, count - 1))
  Else
    return -1
  EndIf
EndFunction

Function PopulateTattoos(String dir)
  tattoosMap = JValue.releaseAndRetain(tattoosMap, JMap.object(), "tattoosMap")

  String[] jsonFiles = MiscUtil.FilesInFolder(dir, extension = "json")
  int fileIndex = 0
  While fileIndex < jsonFiles.Length
    int json = JValue.readFromFile(dir + "/" + jsonFiles[fileIndex])

    String factionStr = JValue.solveStr(json, ".faction")
    String[] factions = StringUtil.Split(factionStr, "|")
    If factions.Length == 0
      factions = new String[1]
      factions[0] = "AnyFaction"
    EndIf

    int body = JMap.getObj(json, "Body")
    int i = 0
    While i < factions.Length
      String[] sexes = JMap.allKeysPArray(body)
      int j = 0
      While j < sexes.Length
        int sex = JMap.getObj(body, sexes[j])
        String[] races = JMap.allKeysPArray(sex)
        int k = 0
        While k < races.Length
          int res = JMap.getObj(sex, races[k])
          ParseAndPopulateTattoos(res, factions[fileIndex] + "." + sexes[j] + "." + races[k])
          k += 1
        EndWhile
        j += 1
      EndWhile
      i += 1
    EndWhile

    JValue.release(json)
    fileIndex += 1
  EndWhile
EndFunction

Function ParseAndPopulateTattoos(int res, String mapKey)
  int resLen = JArray.count(res)

  If resLen > 0
    int array = JMap.getObj(tattoosMap, mapKey)
    If array == 0
      array = JArray.object()
      JMap.setObj(tattoosMap, mapKey, array)
    EndIf

    int i = 0
    while i < resLen 
      JArray.addStr(array, JArray.getStr(res, i))
      i += 1
    EndWhile
  EndIf
EndFunction

Function PopulateColors(String colors)
  String[] splits = StringUtil.Split(colors, "|")
  colorsArray = JValue.releaseAndRetain(colorsArray, JArray.objectWithSize(splits.Length), "colorsArray")

  int i = 0
  While i < splits.Length
    JArray.setInt(colorsArray, i, PO3_SKSEFunctions.StringToInt(splits[i]))
    i += 1
  EndWhile
EndFunction
