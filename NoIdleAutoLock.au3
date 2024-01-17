#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=.\icon.ico
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIGdi.au3>
#include <WinAPI.au3>
#include <TrayConstants.au3>
#include <Array.au3>
#include "UDF/autostart.au3"
#include "UDF/stringToBoolean.au3"
; #include "UDF/_Dbug.au3"

#Region ### START Koda GUI section ###
$Form1_1 = GUICreate("No Idle Auto Lock", 595, 357, 220, 137)
$bPlayPause = GUICtrlCreateButton("Pausar", 8, 40, 107, 25)
$Label1 = GUICtrlCreateLabel("Status:", 8, 16, 37, 17)
$lStatus = GUICtrlCreateLabel("Rodando / Fora de Horario de Funcionamento / Pausado / Conteudo em Tela Cheia / Video em primeiro Plano", 48, 16, 200, 17)
GUICtrlSetBkColor(-1, 0x00FF00)
$bSaveSettings = GUICtrlCreateButton("Salvar Alterações", 436, 12, 150, 25)
$Group1 = GUICtrlCreateGroup("Horario de Funcionamento", 8, 80, 281, 265)
$Label2 = GUICtrlCreateLabel("Iniciar Em:", 16, 104, 53, 17)
$iWordTimeStartHour = GUICtrlCreateInput("07", 80, 104, 33, 21)
$iWordTimeStartMinute = GUICtrlCreateInput("00", 120, 104, 33, 21)
$iWordTimeEndMinute = GUICtrlCreateInput("00", 119, 133, 33, 21)
$iWordTimeEndHour = GUICtrlCreateInput("07", 79, 133, 33, 21)
$Label3 = GUICtrlCreateLabel("Finaliza Em:", 15, 133, 60, 17)
$cSegunda = GUICtrlCreateCheckbox("Segunda", 88, 168, 65, 17)
$cTerca = GUICtrlCreateCheckbox("Terca", 160, 168, 49, 17)
$cQuarta = GUICtrlCreateCheckbox("Quarta", 216, 168, 57, 17)
$cDomingo = GUICtrlCreateCheckbox("Domingo", 16, 168, 65, 17)
$cQuinta = GUICtrlCreateCheckbox("Quinta", 16, 200, 57, 17)
$cSexta = GUICtrlCreateCheckbox("Sexta", 88, 200, 65, 17)
$cSabado = GUICtrlCreateCheckbox("Sabado", 160, 200, 57, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Funcionalidades", 304, 80, 281, 265)
$cIgnoreFullScreenContent = GUICtrlCreateCheckbox("Funcionar enquato Tela cheia?", 312, 128, 241, 17)
$cIgnorePlayVideos = GUICtrlCreateCheckbox("Funcionar enquanto Video em primeiro Plano?", 312, 152, 233, 17)
$iAddVideoKeyword = GUICtrlCreateInput("Youtube", 312, 218, 185, 21)
$BAddVideokeyword = GUICtrlCreateButton("+", 504, 216, 35, 25)
$bRevVideoKeyWord = GUICtrlCreateButton("-", 544, 216, 35, 25)
$Label4 = GUICtrlCreateLabel("Intervalo entre checagens:", 312, 104, 131, 17)
$iMinutesDelay = GUICtrlCreateInput("2", 448, 102, 25, 21)
$Label5 = GUICtrlCreateLabel("Minutos", 480, 104, 41, 17)
$cOnlyMouseNotChagedPosition = GUICtrlCreateCheckbox("Functionar apenas quando o mouse não se mexer?", 312, 176, 265, 17)
$cStartup= GUICtrlCreateCheckbox("Iniciar junto do windows?", 312, 198, 265, 17)
$lVideoKeywords = GUICtrlCreateList("", 312, 240, 265, 97)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

#Region ### TraiIcons ###
Opt("TrayMenuMode", 3)

Global $TrayItem_Status = TrayCreateItem("Status: Executando")
TrayItemSetState($TrayItem_Status, $TRAY_CHECKED)
TrayCreateItem("")

Global $TrayItem_Settings = TrayCreateItem("Configurações") 
TrayCreateItem("") 

Local $TrayItem_PlayPause = TrayCreateItem("Pausar") 
Local $TrayItem_Exit = TrayCreateItem("Exit")

TraySetState($TRAY_ICONSTATE_SHOW)

#EndRegion


Const $W_SUNDAY = 1;
Const $W_MONDAY = 2;
Const $W_TUESDAY = 3;
Const $W_WEDNESDAY = 4;
Const $W_THURSDAY = 5;
Const $W_FRIDAY = 6;
Const $W_SATURDAY = 7;

Const $Green = 0x00FF00
Const $Red = 0xFF0000
Const $Executando = "Executando"
Const $Pausado = "Pausado"
Const $ForaDeHorario = "Fora de horario de funcionamento"
Const $EmTelaCheia = "Em tela cheia"
Const $ExecutandoVideo = "Executando video em primeiro plano"

Global $Status = "Executando"
Global $StatusColor = $Green
Global $ConfigFile = @ScriptDir & "\config.ini"
Global $hCursor[2], $oldCursor[2]
Global $Paused = False
Global $LastLoop = 0
Global $IdleTimeTimeout = True


Global $DefaultVideoKeywords = ["youtube", "video", "media", "netflix", "music", "song", "amazon", "disney", "vimeo", "stream", "play", "watch", "series", "episode", "channel", "prime", "hulu", "spotify", "movie", "show", "tv", "clip", "binge", "hd", "4k", "ultra", "streaming", "live", "concert", "sports", "vod", "entertainment"]
Global $DefaultWorkDay = [2, 3, 4, 5, 6] ; M, T, W, T, F
Global $DefaultWorkTime = [[7, 0], [18, 0]] ; 7:00h, 18:00h
Global $DefaultIgnoreFullScreenContent = False
Global $DefaultIgnoreAllowedTime = False
Global $DefaultIgnorePlayVideos = False
Global $DefaultMinutesDelay = 2
Global $DefaultOnlyMouseNotChangedPosition = true
Global $DefaultStartup = True

Global $VideoKeywords = $DefaultVideoKeywords
Global $WorkTime = $DefaultWorkTime
Global $WorkDay = $DefaultWorkDay
Global $IgnoreFullScreenContent = $DefaultIgnoreFullScreenContent
Global $IgnoreAllowedTime = $DefaultIgnoreAllowedTime
Global $IgnorePlayVideos = $DefaultIgnorePlayVideos
Global $MinutesDelay = $DefaultMinutesDelay
Global $OnlyMouseNotChangedPosition = $DefaultOnlyMouseNotChangedPosition
Global $Startup = $DefaultStartup
Global $IgnoreAll = False


main()

Func main()
	LoadConfigFile()

    While True
		HandlerInterfaceEvents(GUIGetMsg())
		HandlerTrayMenu(TrayGetMsg())
		
		HandlerIdleTime()
		
        If (CanMoveMouse()) Then
            MoveMouseSlightly()
        EndIf
    WEnd
EndFunc

Func LoadConfigFile()
    If FileExists($ConfigFile) Then
		$Startup = _StringToBoolean(Iniread($ConfigFile, "Settings", "Startup", $DefaultStartup))
		$MinutesDelay = Number(Iniread($ConfigFile, "Settings", "MinutesDelay", $DefaultMinutesDelay))
		
        $VideoKeywords = _ArrayFromString(Iniread($ConfigFile, "Settings", "VideoKeywords", _ArrayToString($DefaultVideoKeywords)))
		
        $WorkTime[0][0] =  Number(Iniread($ConfigFile, "Settings", "WorkTimeStartHour", $DefaultWorkTime[0][0]))
        $WorkTime[0][1] =  Number(Iniread($ConfigFile, "Settings", "WorkTimeStartMinute", $DefaultWorkTime[0][1]))
		$WorkTime[1][0] =  Number(Iniread($ConfigFile, "Settings", "WorkTimeEndHour", $DefaultWorkTime[1][0]))
        $WorkTime[1][1] =  Number(Iniread($ConfigFile, "Settings", "WorkTimeEndMinute", $DefaultWorkTime[1][1]))
		
        $WorkDay = _ArrayFromString(Iniread($ConfigFile, "Settings", "WorkDays", _ArrayToString($DefaultWorkDay)))
		$OnlyMouseNotChangedPosition = _StringToBoolean(Iniread($ConfigFile, "Settings", "OnlyMouseNotChangedPosition", $DefaultOnlyMouseNotChangedPosition))

        $IgnoreFullScreenContent = _StringToBoolean(Iniread($ConfigFile, "Ignore", "IgnoreFullScreenContent", $DefaultIgnoreFullScreenContent))
        $IgnoreAllowedTime = _StringToBoolean(Iniread($ConfigFile, "Ignore", "IgnoreAllowedTime", $DefaultIgnoreAllowedTime))
        $IgnorePlayVideos = _StringToBoolean(Iniread($ConfigFile, "Ignore", "IgnorePlayVideos", $DefaultIgnorePlayVideos))
		
		SyncGuiWithSettings()

		If ($Startup) Then
			_StartupRegistry_Uninstall()
			_StartupRegistry_Install()
		Else
			_StartupRegistry_Uninstall()
		EndIf
		
		ConsoleWrite("Configurações Carregadas" & @CRLF)
    EndIf
EndFunc

Func SaveConfigFile()
	ConsoleWrite("Configurações Salvas" & @CRLF)
	
    If FileExists($ConfigFile) Then
        FileDelete($ConfigFile)
    EndIf
	
	FileWrite($ConfigFile, "")
	
	IniWrite($ConfigFile, "Settings", "Startup", $Startup)
	
	IniWrite($ConfigFile, "Settings", "MinutesDelay", $MinutesDelay)

    IniWrite($ConfigFile, "Settings", "VideoKeywords", _ArrayToString($VideoKeywords))
    IniWrite($ConfigFile, "Settings", "WorkTimeStartHour", $WorkTime[0][0])
    IniWrite($ConfigFile, "Settings", "WorkTimeStartMinute",$WorkTime[0][1])
	IniWrite($ConfigFile, "Settings", "WorkTimeEndHour", $WorkTime[1][0])
    IniWrite($ConfigFile, "Settings", "WorkTimeEndMinute",$WorkTime[1][1])

    IniWrite($ConfigFile, "Settings", "WorkDays", _ArrayToString($WorkDay))
	IniWrite($ConfigFile, "Settings", "OnlyMouseNotChangedPosition", $OnlyMouseNotChangedPosition)

    IniWrite($ConfigFile, "Ignore", "IgnoreFullScreenContent", $IgnoreFullScreenContent)
    IniWrite($ConfigFile, "Ignore", "IgnoreAllowedTime", $IgnoreAllowedTime)
    IniWrite($ConfigFile, "Ignore", "IgnorePlayVideos", $IgnorePlayVideos)
	
	If ($Startup) Then
		_StartupRegistry_Uninstall()
		_StartupRegistry_Install()
	Else
		_StartupRegistry_Uninstall()
	EndIf
EndFunc

Func CanMoveMouse()
    If (Not $Paused And $IdleTimeTimeout And IsWithinAllowedTime() And Not IsWindowInFullScreenMode() And Not IsVideoPlaying() and MouseNotChangedPosition()) Then
        ConsoleWrite("Ação permitida: Movendo o mouse." & @CRLF)
        Return True
    EndIf

    Return False
EndFunc

Func MoveMouseSlightly()
    $hCursor = MouseGetPos()
	MouseMove($hCursor[0] - 1, $hCursor[1] - 1)
	ConsoleWrite("Movendo o mouse." & @CRLF)
	$oldCursor = $hCursor
EndFunc

Func IsWithinAllowedTime()
    If ($IgnoreAllowedTime) Then
        ConsoleWrite("Ignorando restrição de tempo." & @CRLF)
        Return True
    EndIf

    Local $DayOfWeek = @WDAY
    Local $CurrentTime = (@HOUR * 60 + @MIN)
    Local $StartTime = ($WorkTime[0][0] * 60) + $WorkTime[0][1]
    Local $EndTime = ($WorkTime[1][0] * 60) + $WorkTime[1][1]

    Local $IsAllowedDay = _ArraySearch($WorkDay, $DayOfWeek, 0, 0, 1, 1, 0) <> -1
    Local $IsAllowedTime = $CurrentTime >= $StartTime And $CurrentTime <= $EndTime

    If ($IsAllowedDay And $IsAllowedTime) Then
        ConsoleWrite("Ação permitida: Dentro do horário permitido." & @CRLF)
        Return True
    EndIf

    ConsoleWrite("Ação bloqueada: Fora do horário permitido." & @CRLF)
    Return False
EndFunc

Func IsWindowInFullScreenMode()
    If ($IgnoreFullScreenContent) Then
        ConsoleWrite("Ignorando conteúdo em tela cheia." & @CRLF)
        Return False
    EndIf

    Local $HForegroundWindow = WinGetHandle("[ACTIVE]")

    ; Obtém as dimensões da janela ativa
    Local $WinRect = WinGetPos($HForegroundWindow)

    ; Obtém as dimensões da área de trabalho
    Local $DesktopWidth = @DesktopWidth
    Local $DesktopHeight = @DesktopHeight

    ; Verifica se as dimensões da janela são iguais às dimensões da área de trabalho (fullscreen)
    If ($WinRect[2] = $DesktopWidth And $WinRect[3] = $DesktopHeight) Then
        ConsoleWrite("Ação bloqueada: Conteúdo em tela cheia." & @CRLF)
        Return True
    EndIf

    ConsoleWrite("Ação permitida: Não em tela cheia." & @CRLF)
    Return False
EndFunc

Func IsVideoPlaying()
    If ($IgnorePlayVideos) Then
        ConsoleWrite("Ignorando reprodução de vídeos." & @CRLF)
        Return False
    EndIf

    ; Obtém a handle da janela ativa
    Local $HForegroundWindow = WinGetHandle("[ACTIVE]")

    ; Obtém o texto do título da janela
    Local $WindowTitle = WinGetTitle($HForegroundWindow)

    ; Verifica se o título da janela contém alguma palavra-chave relacionada a vídeo
    If (_ArraySearch($VideoKeywords, $WindowTitle, 0, 0, 1, 1, 0) <> -1) Then
        ConsoleWrite("Ação bloqueada: Reproduzindo vídeo." & @CRLF)
        Return True
    EndIf

    ConsoleWrite("Ação permitida: Não reproduzindo vídeo." & @CRLF)
    Return False
EndFunc

Func MouseNotChangedPosition()
	If (Not $OnlyMouseNotChangedPosition) Then
		return true
	EndIf
	
	$hCursor = MouseGetPos()
    return ($hCursor[0] == $oldCursor[0] And $hCursor[1] == $oldCursor[1])
EndFunc

Func HandlerIdleTime()
	Local $Now = (@HOUR * 60  + @MIN) * 60 + @SEC
	
	If ($IdleTimeTimeout) Then
		$LastLoop = $Now
		$IdleTimeTimeout = false
	EndIf
	
	Local $NextLoop = $LastLoop + ($MinutesDelay * 60)
	If($Now >= $NextLoop) Then
		$IdleTimeTimeout = True
	EndIf
EndFunc

Func HandlerInterfaceEvents($GuiMsg)
	Switch $GuiMsg
		Case $GUI_EVENT_CLOSE
			FecharJanela()
		
		Case $GUI_EVENT_MINIMIZE
			SyncSettingsWithGui()
			SaveConfigFile()

		Case $bPlayPause
			TogglePause()

		Case $BAddVideokeyword
			AddVideoKeyword(GUICtrlRead($iAddVideoKeyword))

		Case $bRevVideoKeyWord
			RemoveVideoKeyword(GUICtrlRead($lVideoKeywords, 1))
			
		Case $bSaveSettings
			SyncSettingsWithGui()
			SaveConfigFile()
	EndSwitch
EndFunc

Func HandlerTrayMenu($TrayMsg)
	Switch $TrayMsg
        Case $TrayItem_Settings
            GUISetState(@SW_SHOW)
        Case $TrayItem_PlayPause
            TogglePause()
            If $Paused Then
                TrayItemSetText($TrayItem_PlayPause, "Resumir")
            Else
                TrayItemSetText($TrayItem_PlayPause, "Pausar")
            EndIf
        Case $TrayItem_Exit
            FecharJanela()
            Exit
    EndSwitch
EndFunc

Func FecharJanela()
	SyncSettingsWithGui()
	SaveConfigFile()
	GUISetState(@SW_HIDE)
EndFunc

Func SyncGuiWithSettings()
	SyncStatus()
	SyncPlayPause()
	
	GUICtrlSetData($iWordTimeStartHour, $WorkTime[0][0])
	GUICtrlSetData($iWordTimeStartMinute, $WorkTime[0][1])
	GUICtrlSetData($iWordTimeEndHour, $WorkTime[1][0])
	GUICtrlSetData($iWordTimeEndMinute, $WorkTime[1][1])
	
	GUICtrlSetState($cDomingo, (_ArraySearch($WorkDay, $W_SUNDAY, 0, 0, 1, 1, 0) <> -1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	GUICtrlSetState($cSegunda, (_ArraySearch($WorkDay, $W_MONDAY, 0, 0, 1, 1, 0) <> -1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	GUICtrlSetState($cTerca, (_ArraySearch($WorkDay, $W_TUESDAY , 0, 0, 1, 1, 0) <> -1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	GUICtrlSetState($cQuarta, (_ArraySearch($WorkDay, $W_WEDNESDAY, 0, 0, 1, 1, 0) <> -1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	GUICtrlSetState($cQuinta, (_ArraySearch($WorkDay, $W_THURSDAY, 0, 0, 1, 1, 0) <> -1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	GUICtrlSetState($cSexta, (_ArraySearch($WorkDay, $W_FRIDAY, 0, 0, 1, 1, 0) <> -1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	GUICtrlSetState($cSabado, (_ArraySearch($WorkDay, $W_SATURDAY, 0, 0, 1, 1, 0) <> -1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	
	GUICtrlSetData($iMinutesDelay, $MinutesDelay)
	
	GUICtrlSetState($cIgnoreFullScreenContent, ($IgnoreFullScreenContent ? $GUI_CHECKED : $GUI_UNCHECKED))
	GUICtrlSetState($cIgnorePlayVideos, ($IgnorePlayVideos ? $GUI_CHECKED : $GUI_UNCHECKED))
	GUICtrlSetState($cOnlyMouseNotChagedPosition, ($OnlyMouseNotChangedPosition  ? $GUI_CHECKED : $GUI_UNCHECKED))
	GUICtrlSetState($cStartup, ($Startup  ? $GUI_CHECKED : $GUI_UNCHECKED))
	
	GUICtrlSetData($lVideoKeywords, _ArrayToString($VideoKeywords))
EndFunc


Func SyncSettingsWithGui()
	$WorkTime[0][0] = Number(GUICtrlRead($iWordTimeStartHour))
	$WorkTime[0][1] = Number(GUICtrlRead($iWordTimeStartMinute))
	$WorkTime[1][0] = Number(GUICtrlRead($iWordTimeEndHour))
	$WorkTime[1][1] = Number(GUICtrlRead($iWordTimeEndMinute))
	
	ReDim $WorkDay[0]
	
	If (GUICtrlRead($cDomingo) == $GUI_CHECKED) Then
		_ArrayAdd($WorkDay, $W_SUNDAY)
	EndIf
	If (GUICtrlRead($cSegunda) == $GUI_CHECKED) Then
		_ArrayAdd($WorkDay, $W_MONDAY)
	EndIf
	If (GUICtrlRead($cTerca) == $GUI_CHECKED) Then
		_ArrayAdd($WorkDay, $W_TUESDAY)
	EndIf
	If (GUICtrlRead($cQuarta) == $GUI_CHECKED) Then
		_ArrayAdd($WorkDay, $W_WEDNESDAY)
	EndIf
	If (GUICtrlRead($cQuinta) == $GUI_CHECKED) Then
		_ArrayAdd($WorkDay, $W_THURSDAY)
	EndIf
	If (GUICtrlRead($cSexta) == $GUI_CHECKED) Then
		_ArrayAdd($WorkDay, $W_FRIDAY)
	EndIf
	If (GUICtrlRead($cSabado) == $GUI_CHECKED) Then
		_ArrayAdd($WorkDay, $W_SATURDAY)
	EndIf
	
	$MinutesDelay = Number(GUICtrlRead($iMinutesDelay))
	
	$IgnoreFullScreenContent = (GUICtrlRead($cIgnoreFullScreenContent)  == $GUI_CHECKED)
	$IgnorePlayVideos = (GUICtrlRead($cIgnorePlayVideos)  == $GUI_CHECKED)
	$OnlyMouseNotChangedPosition = (GUICtrlRead($cOnlyMouseNotChagedPosition)  == $GUI_CHECKED)
	$Startup = (GUICtrlRead($cStartup)  == $GUI_CHECKED)
EndFunc

Func AddVideoKeyword($keyword)
    If (_ArraySearch($VideoKeywords, $keyword) = -1 And $keyword <> "") Then
        _ArrayAdd($VideoKeywords, $keyword)
    EndIf
	GUICtrlSetData($lVideoKeywords, "")
    GUICtrlSetData($lVideoKeywords, _ArrayToString($VideoKeywords))
	
	GUICtrlSetData($iAddVideoKeyword, "")
EndFunc


Func RemoveVideoKeyword($keyword)
	$selectedIndex = _ArraySearch($VideoKeywords, $keyword, 0, 0, 1)
	ConsoleWrite("$selectedIndex: " & $selectedIndex & @CRLF)
	
    If ($selectedIndex <> -1) Then
		_ArrayDelete($VideoKeywords, $selectedIndex)
		GUICtrlSetData($lVideoKeywords, "")
		GUICtrlSetData($lVideoKeywords, _ArrayToString($VideoKeywords))
    EndIf
EndFunc


Func TogglePause()
	$Paused = Not $Paused
	SyncPlayPause()
	SyncStatus()
EndFunc


Func SyncStatus()
	If ($IgnoreAll) Then
		If ($Paused) Then
			$Status = "[Ignorando todas as travas]" & $Pausado
			$StatusColor = $Red
		Else
			$Status = "[Ignorando todas as travas]" & $Executando
			$StatusColor = $Green
		EndIf
		
	Else
		If ($Paused) Then
			$Status = $Pausado
			$StatusColor = $Red
			
		ElseIf (Not IsWithinAllowedTime()) Then
			$Status = $ForaDeHorario
			$StatusColor = $Red
		
		ElseIf (IsWindowInFullScreenMode()) Then
			$Status = $EmTelaCheia
			$StatusColor = $Red
			
		ElseIf (IsVideoPlaying()) Then
			$Status = $ExecutandoVideo
			$StatusColor = $Red
			
		Else
			$Status = $Executando
			$StatusColor = $Green
		EndIf
	EndIf
	
	GUICtrlSetData($lStatus, $Status)
	GUICtrlSetBkColor($lStatus, $StatusColor)
	TrayItemSetState($TrayItem_Status, ($StatusColor == $Green ? $TRAY_CHECKED : $TRAY_UNCHECKED))
EndFunc


Func SyncPlayPause()
	If ($Paused) Then
		GUICtrlSetData($bPlayPause, "Resumir")
	Else
		GUICtrlSetData($bPlayPause, "Pausar")
	EndIf
EndFunc