  ; Macros for double quotes
  Macro DQuote
    "
  EndMacro
  ; Define the ImportLib
  CompilerSelect #PB_Compiler_Thread
    CompilerCase #False ;{ THREADSAFE : OFF
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_Linux         : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers/objectmanager.a"
        CompilerCase #PB_OS_Windows   : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers\ObjectManager.lib"
      CompilerEndSelect
    ;}
    CompilerCase #True ;{ THREADSAFE : ON
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_Linux         : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers/objectmanagerthread.a"
        CompilerCase #PB_OS_Windows   : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers\ObjectManagerThread.lib"
      CompilerEndSelect
    ;}
  CompilerEndSelect
  ; Macro ImportFunction
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Linux ;{
      Macro ImportFunction(Name, Param)
        DQuote#Name#DQuote
      EndMacro
    ;}
    CompilerCase #PB_OS_Windows ;{
      Macro ImportFunction(Name, Param)
        DQuote _#Name@Param#DQuote
      EndMacro
    ;}
  CompilerEndSelect
  ; Import the ObjectManager library
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Linux : ImportC #Power_ObjectManagerLib
    CompilerCase #PB_OS_Windows : Import #Power_ObjectManagerLib
  CompilerEndSelect
    Object_GetOrAllocateID(Objects, Object.l) As ImportFunction(PB_Object_GetOrAllocateID, 8)
    Object_GetObject(Objects, Object.l) As ImportFunction(PB_Object_GetObject,8)
    Object_IsObject(Objects, Object.l) As ImportFunction(PB_Object_IsObject,8)
    Object_EnumerateAll(Objects, ObjectEnumerateAllCallback, *VoidData) As ImportFunction(PB_Object_EnumerateAll,12)
    Object_EnumerateStart(Objects) As ImportFunction(PB_Object_EnumerateStart,4)
    Object_EnumerateNext(Objects, *object.Long) As ImportFunction(PB_Object_EnumerateNext,8)
    Object_EnumerateAbort(Objects) As ImportFunction(PB_Object_EnumerateAbort,4)
    Object_FreeID(Objects, Object.l) As ImportFunction(PB_Object_FreeID,8)
    Object_Init(StructureSize.l, IncrementStep.l, ObjectFreeFunction) As ImportFunction(PB_Object_Init,12)
    Object_GetThreadMemory(MemoryID.l) As ImportFunction(PB_Object_GetThreadMemory,4)
    Object_InitThreadMemory(Size.l, InitFunction, EndFunction) As ImportFunction(PB_Object_InitThreadMemory,12)
  EndImport

Procedure GetGadgetParent()
  !EXTRN _PB_Object_GetThreadMemory@4
  !EXTRN _PB_Gadget_Globals
  !MOV   Eax,[_PB_Gadget_Globals]
  !push  eax
  !call  _PB_Object_GetThreadMemory@4
  !MOV   Eax,[Eax]
  ProcedureReturn
  ;CreateGadgetList(0)
EndProcedure

ProcedureDLL RCam_FreeGadget(ID.l)
  Global RCamObjects	.l
  Protected *RCam.S_RCam
  If ID <> #PB_Any And RCAM_IS(ID)
    *RCam 				= RCAM_ID(ID)
  EndIf
  If *RCam
	  DestroyWindow_(*RCam\hWnd)
    RCAM_FREE			(ID)
  EndIf
  ProcedureReturn #True
EndProcedure
ProcedureDLL RCam_Init()
	Global RCam_Dll		.l
	Global RCamObjects	.l
	RCam_Dll 		= OpenLibrary(#PB_Any, "avicap32.dll")
	RCamObjects = RCAM_INITIALIZE(@RCam_FreeGadget()) 
EndProcedure
ProcedureDLL RCam_End()
	CloseLibrary(RCam_Dll)
EndProcedure

ProcedureDLL RCam_Gadget(Gadget.l, x.l, y.l, Width.l, Height.l)
	Protected RCam_Address.l
	Protected *RCam.S_RCam
	If RCAM_IS(Gadget) = 0
		*RCam 				= RCAM_NEW(Gadget)
		RCam_Address 	= GetFunction(RCam_Dll, "capCreateCaptureWindowA")
		*RCam\hWnd		= CallFunctionFast(RCam_Address, @"CaptureWindow", #WS_CHILD | #WS_VISIBLE, x, y, Width, Height, WindowID(0),Gadget)
		*RCam\x				=	x
		*RCam\y				= y
		*RCam\width		= Width
		*RCam\height	= Height
		ProcedureReturn *RCam
	Else
		ProcedureReturn #False
	EndIf
EndProcedure
ProcedureDLL RCam_GadgetID(ID.l)
	Protected *RCam.S_RCam = RCAM_ID(ID)
	ProcedureReturn *RCam\hWnd
EndProcedure
ProcedureDLL RCam_GadgetX(ID.l)
  Protected *RCam.S_RCam
  *RCam = RCAM_ID(ID)
  ProcedureReturn *RCam\x
EndProcedure
ProcedureDLL RCam_GadgetY(ID.l)
  Protected *RCam.S_RCam
  *RCam = RCAM_ID(ID)
  ProcedureReturn *RCam\y
EndProcedure
ProcedureDLL RCam_GadgetHeight(ID.l)
  Protected *RCam.S_RCam
  *RCam = RCAM_ID(ID)
  ProcedureReturn *RCam\height
EndProcedure
ProcedureDLL RCam_GadgetWidth(ID.l)
  Protected *RCam.S_RCam
  *RCam = RCAM_ID(ID)
  ProcedureReturn *RCam\width
EndProcedure
ProcedureDLL RCam_ResizeGadget(ID.l, x.l, y.l, Width.l, Height.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
	*RCam\x				=	x
	*RCam\y				= y
	*RCam\width		= Width
	*RCam\height	= Height
  ProcedureReturn SetWindowPos_(*RCam\hWnd, #HWND_BOTTOM, x, y, Width, Height, #SWP_NOMOVE | #SWP_NOZORDER)
EndProcedure
ProcedureDLL.l RCam_SetGadgetData(ID.l, Value.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_USER_DATA, 0, Value)
EndProcedure
ProcedureDLL.l RCam_GetGadgetData(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_GET_USER_DATA, 0, 0)
EndProcedure


ProcedureDLL.l RCam_GetDriverID(Index.l)
	Protected RCam_Address.l
	Protected DriverName.s	=	Space(256)
	Protected DriverDesc.s	=	Space(256)
	RCam_Address 	= GetFunction(RCam_Dll, "capGetDriverDescriptionA")
	If CallFunctionFast(RCam_Address, Index, @DriverName, 256, @DriverDesc, 256)
		ProcedureReturn Index
	Else
		ProcedureReturn -1
	EndIf
EndProcedure
ProcedureDLL.s RCam_GetDriverName(Index.l)
	Protected RCam_Address.l
	Protected DriverName.s	=	Space(256)
	Protected DriverDesc.s	=	Space(256)
	RCam_Address 	= GetFunction(RCam_Dll, "capGetDriverDescriptionA")
	If CallFunctionFast(RCam_Address, Index, @DriverName, 256, @DriverDesc, 256)
		ProcedureReturn DriverName
	Else
		ProcedureReturn ""
	EndIf
EndProcedure
ProcedureDLL.s RCam_GetDriverDescription(Index.l)
	Protected RCam_Address.l
	Protected DriverName.s	=	Space(256)
	Protected DriverDesc.s	=	Space(256)
	RCam_Address 	= GetFunction(RCam_Dll, "capGetDriverDescriptionA")
	If CallFunctionFast(RCam_Address, Index, @DriverName, 256, @DriverDesc, 256)
		ProcedureReturn DriverDesc
	Else
		ProcedureReturn ""
	EndIf
EndProcedure

ProcedureDLL.l RCam_Connect(ID.l, DriverID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_CONNECT, DriverID, 0)
EndProcedure
;@todo : Moebius 1.5 (, PreviewFrameRate.l = 15 => , PreviewFrameRate.l)
ProcedureDLL.l RCam_EnablePreviewMode(ID.l, PreviewMode.l, PreviewFrameRate.l)
  Protected *RCam.S_RCam
  Protected hPreview.l
  *RCam = RCAM_ID(ID)
  If PreviewMode = #True
  	hPreview 	=	SendMessage_(*RCam\hWnd, #WM_CAP_SET_PREVIEW, PreviewMode, 0)
  							SendMessage_(*RCam\hWnd, #WM_CAP_SET_PREVIEWRATE, PreviewFrameRate, 0)
  	ProcedureReturn hPreview
  Else
  	ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_PREVIEW, Bool, 0)
  EndIf
EndProcedure
ProcedureDLL.l RCam_SetScaleMode(ID.l, Bool.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*Rcam\hWnd, #WM_CAP_SET_SCALE,	Bool, 0)
EndProcedure
ProcedureDLL.l RCam_SetOverlay(ID.l, Bool.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_OVERLAY, Bool, 0)
EndProcedure
ProcedureDLL.l RCam_Disconnect(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  SendMessage_(*RCam\hWnd, #WM_CAP_STOP, 0, 0)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_DISCONNECT, 0, 0)
EndProcedure


ProcedureDLL.l RCam_VideoCompressionRequester(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DLG_VIDEOCOMPRESSION, 0, 0)
EndProcedure

ProcedureDLL.l RCam_VideoDisplayRequester(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DLG_VIDEODISPLAY, 0, 0)
EndProcedure
ProcedureDLL.l RCam_VDR_Has(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  Protected Caps.CAPDRIVERCAPS
	SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_GET_CAPS, SizeOf (CAPDRIVERCAPS), @Caps)
	ProcedureReturn Caps\fHasDlgVideoDisplay
EndProcedure

ProcedureDLL.l RCam_VideoFormatRequester(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DLG_VIDEOFORMAT, 0, 0)
EndProcedure
ProcedureDLL.l RCam_VFR_Has(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  Protected Caps.CAPDRIVERCAPS
	SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_GET_CAPS, SizeOf (CAPDRIVERCAPS), @Caps)
	ProcedureReturn Caps\fHasDlgVideoFormat
EndProcedure
ProcedureDLL.l RCam_VFR_GetWidth(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  Protected s.CAPSTATUS 
  If SendMessage_(*RCam\hWnd, #WM_CAP_GET_STATUS, SizeOf(CAPSTATUS), @s) = #True
		ProcedureReturn s\uiImageWidth
	Else
		ProcedureReturn -1
	EndIf
EndProcedure
ProcedureDLL.l RCam_VFR_GetHeight(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  Protected s.CAPSTATUS 
  If SendMessage_(*RCam\hWnd, #WM_CAP_GET_STATUS, SizeOf(CAPSTATUS), @s) = #True
		ProcedureReturn s\uiImageHeight
	Else
		ProcedureReturn -1
	EndIf
EndProcedure

ProcedureDLL.l RCam_VideoSourceRequester(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DLG_VIDEOSOURCE, 0, 0)
EndProcedure
ProcedureDLL.l RCam_VSR_Has(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  Protected Caps.CAPDRIVERCAPS
	SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_GET_CAPS, SizeOf (CAPDRIVERCAPS), @Caps)
	ProcedureReturn Caps\fHasDlgVideoSource
EndProcedure

ProcedureDLL.l RCam_Snapshot(ID.l, Filename.s)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  SendMessage_(*RCam\hWnd, #WM_CAP_GRAB_FRAME, 0, 0)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_FILE_SAVEDIBA, 0, Filename)
EndProcedure

; Capture
ProcedureDLL.l RCam_SetCaptureFilename(ID.l, Filename.s)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  *RCam\Filename	=	Filename
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_FILE_SET_CAPTURE_FILE, 0, @Filename)
EndProcedure
;@todo : Moebius 1.5 (, Type.l = #WAVE_FORMAT_PCM, NbChannels = 2, SampleRate = 11025, AverageDataTransferRate = 22050, BlockAlignment = 2, BitsPerSample = 8)
ProcedureDLL.l RCam_SetAudioCapture(ID.l, Type.l, NbChannels, SampleRate, AverageDataTransferRate, BlockAlignment, BitsPerSample)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  Protected wfex.WAVEFORMATEX
	With wfex
		\wFormatTag 			= Type 										; #WAVE_FORMAT_PCM;
		\nChannels 				= NbChannels 							; 2
		\nSamplesPerSec 	= SampleRate							; 11025 Hz
		\nAvgBytesPerSec 	= AverageDataTransferRate ; 22050bps
		\nBlockAlign 			= BlockAlignment					;	2
		\wBitsPerSample 	= BitsPerSample						;	8
		\cbSize 					= 0
	EndWith
	ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_AUDIOFORMAT, SizeOf(WAVEFORMATEX), @wfex)
EndProcedure
ProcedureDLL.l RCam_StartCapture(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SEQUENCE, 0, 0)
EndProcedure
ProcedureDLL.l RCam_StopCapture(ID.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  SendMessage_(*RCam\hWnd, #WM_CAP_STOP, 0, 0)
	ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_FILE_SAVEAS, 0, @*RCam\Filename)
EndProcedure
; ProcedureDLL.l RCam_Tmp(ID.l)
;   Protected *RCam.S_RCam = RCAM_ID(ID)
;   Protected s.CAPTUREPARMS 
;   SendMessage_(*RCam\hWnd, #WM_CAP_GET_SEQUENCE_SETUP, SizeOf(CAPTUREPARMS), @s)
;   Debug s\fMakeUserHitOKToCapture; 
;   s\fMakeUserHitOKToCapture	=	#True
;   SendMessage_(*RCam\hWnd, #WM_CAP_SET_SEQUENCE_SETUP, SizeOf(CAPTUREPARMS), @s)
;   ProcedureReturn 
; EndProcedure
; Callback
ProcedureDLL.l RCam_SetCallBackError(ID.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_ERROR, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackFrame(ID.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_FRAME, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackStatus(ID.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_STATUS, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackVideoStream(ID.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_VIDEOSTREAM, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackWaveStream(ID.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_WAVESTREAM, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackYield(ID.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(ID)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_YIELD, 0, Callback)
EndProcedure


; ProcedureDLL.l RCam_(ID.l)
;   Protected *RCam.S_RCam = RCAM_ID(ID)
;   ProcedureReturn SendMessage_(*RCam\hWnd, , , 0)
; EndProcedure
