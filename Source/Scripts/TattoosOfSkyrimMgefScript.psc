Scriptname TattoosOfSkyrimMgefScript extends ActiveMagicEffect  

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NiOverride functions
;
;bool Function HasNodeOverride(ObjectReference ref, bool isFemale, string node, int key, int index) native global
;
; Return the stored override, returns default (nil) values if the override D.N.E
;float Function GetNodeOverrideFloat(ObjectReference ref, bool isFemale, string node, int key, int index) native global
;int Function GetNodeOverrideInt(ObjectReference ref, bool isFemale, string node, int key, int index) native global
;bool Function GetNodeOverrideBool(ObjectReference ref, bool isFemale, string node, int key, int index) native global
;string Function GetNodeOverrideString(ObjectReference ref, bool isFemale, string node, int key, int index) native global
;TextureSet Function GetNodeOverrideTextureSet(ObjectReference ref, bool isFemale, string node, int key, int index) native global
;
;Function AddNodeOverrideFloat(ObjectReference ref, bool isFemale, string node, int key, int index, float value, bool persist) native global
;Function AddNodeOverrideInt(ObjectReference ref, bool isFemale, string node, int key, int index, int value, bool persist) native global
;Function AddNodeOverrideBool(ObjectReference ref, bool isFemale, string node, int key, int index, bool value, bool persist) native global
;Function AddNodeOverrideString(ObjectReference ref, bool isFemale, string node, int key, int index, string value, bool persist) native global
;Function AddNodeOverrideTextureSet(ObjectReference ref, bool isFemale, string node, int key, int index, TextureSet value, bool persist) native global
;
;
; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Index: seems to be always 0 for strings/textures, -1 for anything else?
;
;
; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Valid keys
; ID - TYPE - Name
; 0 - int - ShaderEmissiveColor
; 1 - float - ShaderEmissiveMultiple
; 2 - float - ShaderGlossiness
; 3 - float - ShaderSpecularStrength
; 4 - float - ShaderLightingEffect1
; 5 - float - ShaderLightingEffect2
; 6 - TextureSet - ShaderTextureSet
; 7 - int - ShaderTintColor
; 8 - float - ShaderAlpha
; 9 - string - ShaderTexture (index 0-8)
; 20 - float - ControllerStartStop (-1.0 for stop, anything else indicates start time)
; 21 - float - ControllerStartTime
; 22 - float - ControllerStopTime
; 23 - float - ControllerFrequency
; 24 - float - ControllerPhase
;
;
;
; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Format for node strings:
;
; "<Area> [Ovl<slot>]"
;
; where <Area> is one of: {Body, Face, Feet, Hands}
; and slot is a 0-based index




; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; PROPERTIES
; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

String Property npcType auto
TattoosOfSkyrimQuestScript Property tosQuestScript auto
TattoosOfSkyrimMCM Property tosMCMScript auto


; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; CONSTANTS
; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

int KEY_SHADER_TINT_COLOR = 7
int KEY_SHADER_ALPHA = 8
int KEY_SHADER_TEXTURE = 9

string DEFAULT_OVERLAY = "Actors\\Character\\Overlays\\Default.dds"

string AREA_BODY = "Body"
;string AREA_FACE = "Face"
;string AREA_FEET = "Feet"
;string AREA_HANDS = "Hands"

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; CODE
; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If !Roll(tosMCMScript.globalProb)
		return
	EndIf

	int safetyBound = 100
	While !tosQuestScript.FinishedLoading() && safetyBound > 0
		Utility.Wait(0.25)
		safetyBound = safetyBound - 1
	EndWhile

	If !tosQuestScript.FinishedLoading()
		Debug.Trace("Tattoos of Skyrim could not apply overlays due to quest failing to load.")
		return
	EndIf

  ApplyMultipleOverlays(akTarget)

  If !NiOverride.HasOverlays(akTarget)
    NiOverride.AddOverlays(akTarget)
  EndIf

	FinaliseOverlays(akTarget)
EndEvent

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function ApplyMultipleOverlays(Actor akTarget)
  ActorBase targetBase = akTarget.GetLeveledActorBase()
  bool isFemale = targetBase.GetSex() as bool

  int overlaysView = tosQuestScript.GetOverlaysView(npcType, akTarget, isFemale)

  int counter = 0
  int slot = tosMCMScript.slot
  While counter < tosMCMScript.maxTattoos
    If counter == 0 || Roll(tosMCMScript.multipleTattooProb)
      slot = GetEmptySlot(akTarget, isFemale, AREA_BODY, slot)
      If slot < 0
        JValue.release(overlaysView)
        return
      EndIf
      ApplyRandomOverlay(akTarget, overlaysView, isFemale, slot)
    EndIf
    slot += 1
    counter += 1
  EndWhile

  JValue.release(overlaysView)
EndFunction

Function ApplyRandomOverlay(Actor akTarget, int overlaysView, bool isFemale, int slot)
  String overlay = ChooseRandomlyIn(overlaysView)
	If overlay == ""
		return
	EndIf

	int color = Utility.RandomInt(0, 16777215)

	ApplyOverlay(akTarget, isFemale, AREA_BODY, slot, overlay, color, tosMCMScript.opacity)
EndFunction

Function ApplyOverlay(Actor akActor, bool isFemale, string area, int slot, string texture, int color, float alpha)
  string node  = area + " [ovl" + slot + "]"
	NiOverride.AddNodeOverrideString(akActor, isFemale, node, KEY_SHADER_TEXTURE, 0, texture, persist=true)
	NiOverride.AddNodeOverrideInt(akActor, isFemale, node, KEY_SHADER_TINT_COLOR, -1, color, persist=true)
	NiOverride.AddNodeOverrideFloat(akActor, isFemale, node, KEY_SHADER_ALPHA, -1, alpha, persist=true)
EndFunction

Function FinaliseOverlays(Actor akActor)
	NiOverride.ApplyNodeOverrides(akActor)
  akActor.QueueNiNodeUpdate()
EndFunction

String Function ChooseRandomlyIn(int view)
  int totalLength = 0
  int i = 0
  While i < JArray.count(view)
    totalLength += JArray.count(JArray.getObj(view, i))
    i += 1
  EndWhile
  If totalLength <= 0
    return ""
  EndIf

  int randId = Utility.RandomInt(0, totalLength - 1)

  i = 0
  While i < JArray.count(view)
    int array = JArray.getObj(view, i)
    int len = JArray.count(array)
    If randId < len
      
      return JArray.getStr(array, randId)
    EndIf
    randId -= len
    i += 1
  EndWhile

  return ""
EndFunction

Int Function GetEmptySlot(Actor akTarget, Bool Gender, String Area, int init = 0)
	Int i = init
	Int NumSlots = NiOverride.GetNumBodyOverlays()
	String TexPath

	While i < NumSlots
		TexPath = NiOverride.GetNodeOverrideString(akTarget, Gender, Area + " [ovl" + i + "]", 9, 0)
		If TexPath == "" || TexPath == DEFAULT_OVERLAY
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1
EndFunction

bool Function Roll(float chance)
  If chance == 0.0
    return false
  ElseIf chance == 1.0
    return true
  Else
    return Utility.RandomFloat(0, 0.99999) <= chance
  EndIf
EndFunction
