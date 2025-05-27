Scriptname TattoosOfSkyrimQuestScript extends Quest  

Race Property raceAltmer auto
Race Property raceArgonian auto
Race Property raceBosmer auto
Race Property raceBreton auto
Race Property raceDunmer auto
Race Property raceImperial auto
Race Property raceKhajiit auto
Race Property raceNord auto
Race Property raceOrc auto
Race Property raceRedguard auto

int tattoosMap

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

  Populate("Data/SKSE/Plugins/TattoosOfSkyrim")

  BusyLoading = False
EndFunction

Bool Function FinishedLoading()
  return !BusyLoading
EndFunction

int Function GetOverlaysView(String type, Actor akActor, bool isFemale)
  int view = JArray.object()

  String[] currentType = new String[2]
  currentType[0] = ""
  currentType[1] = type

  String[] currentSex = new String[2]
  currentSex[0] = "AnySex"
  If isFemale
    currentSex[1] = "Female"
  Else
    currentSex[1] = "Male"
  EndIf 

  String[] currentRace = new String[2]
  currentRace[0] = "AnyRace"
  Race actorRace = akActor.GetRace()
  If actorRace == raceAltmer
    currentRace[1] = "Altmer"
  ElseIf actorRace == raceArgonian
    currentRace[1] = "Argonian"
  ElseIf actorRace == raceBosmer
    currentRace[1] = "Bosmer"
  ElseIf actorRace == raceBreton
    currentRace[1] = "Breton"
  ElseIf actorRace == raceDunmer
    currentRace[1] = "Dunmer"
  ElseIf actorRace == raceImperial
    currentRace[1] = "Imperial"
  ElseIf actorRace == raceKhajiit
    currentRace[1] = "Khajiit"
  ElseIf actorRace == raceNord
    currentRace[1] = "Nord"
  ElseIf actorRace == raceOrc
    currentRace[1] = "Orc"
  ElseIf actorRace == raceRedguard
    currentRace[1] = "Redguard"
  EndIf

  int j = 0
  While j < currentType.Length
    int k = 0
    While k < currentSex.Length
      int l = 0
      While l < currentRace.Length
        String mapKey = currentType[j] + "." + currentSex[k] + "." + currentRace[l]
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

Function Populate(String dir)
  tattoosMap = JValue.releaseAndRetain(tattoosMap, JMap.object(), "tattoosMap")

  ; String[] types = new String[4]
  ; types[0] = ""
  ; types[1] = "Forsworn"
  ; types[2] = "Bandit"
  ; types[3] = "Warlock"

  String[] sexs = new String[3]
  sexs[0] = "AnySex"
  sexs[1] = "Male"
  sexs[2] = "Female"

  String[] races = new String[12]
  races[0] = "AnyRace"
  races[1] = "Altmer"
  races[2] = "Argonian"
  races[3] = "Bosmer"
  races[4] = "Breton"
  races[5] = "Dunmer"
  races[6] = "Imperial"
  races[7] = "Khajiit"
  races[8] = "Nord"
  races[9] = "Orc"
  races[10] = "Redguard"
  races[11] = "Mage"

  String[] jsonFiles = MiscUtil.FilesInFolder(dir, extension = "json")

  int i = 0
  While i < jsonFiles.Length
    int json = JValue.readFromFile(dir + "/" + jsonFiles[i])
    String type = JValue.solveStr(json, ".type")

    int j = 0
    While j < sexs.Length
      int k = 0
      While k < races.Length
        String mapKey = type + "." + sexs[j] + "." + races[k]
        ParseJsonAndPopulate(json, mapKey, ".Body." + sexs[j] + "." + races[k])
        k += 1
      EndWhile
      j += 1
    EndWhile

    JValue.release(json)
    i += 1
  EndWhile
EndFunction

String[] Function ParseJsonAndPopulate(int json, String mapKey, String path)
  int res = JValue.solveObj(json, path)
  int resLen = JArray.count(res)

  If resLen > 0
    int array = JMap.getObj(tattoosMap, mapKey)
    If array == 0
      array = JArray.object()
      JMap.setObj(tattoosMap, mapKey, array)
    EndIf

    int i = 0
    while i < resLen
      String overlay = JArray.getStr(res, i)
      String[] splits = StringUtil.Split(overlay, "|")
      If MiscUtil.FileExists("Data/" + splits[splits.Length - 1])
        JArray.addStr(array, overlay)
      EndIf
      i += 1
    EndWhile
  EndIf
EndFunction
