Declare.l RCamFreeGadget(Id.l)
Import "C:\Program Files\PureBasic\Compilers\ObjectManager.lib"
  Object_GetOrAllocateID (Objects, Object.l) As "_PB_Object_GetOrAllocateID@8"
  Object_GetObject       (Objects, Object.l) As "_PB_Object_GetObject@8"
  Object_IsObject        (Objects, Object.l) As "_PB_Object_IsObject@8"
  Object_EnumerateAll    (Objects, ObjectEnumerateAllCallback, *VoidData) As "_PB_Object_EnumerateAll@12"
  Object_EnumerateStart  (Objects) As "_PB_Object_EnumerateStart@4"
  Object_EnumerateNext   (Objects, *object.Long) As "_PB_Object_EnumerateNext@8"
  Object_EnumerateAbort  (Objects) As "_PB_Object_EnumerateAbort@4"
  Object_FreeID          (Objects, Object.l) As "_PB_Object_FreeID@8"
  Object_Init            (StructureSize.l, IncrementStep.l, ObjectFreeFunction) As "_PB_Object_Init@12"
  Object_GetThreadMemory (MemoryID.l) As "_PB_Object_GetThreadMemory@4"
  Object_InitThreadMemory(Size.l, InitFunction, EndFunction) As "_PB_Object_InitThreadMemory@12"
EndImport

Procedure GetGadgetParent()
  !EXTRN _PB_Object_GetThreadMemory@4
  !EXTRN _PB_Gadget_Globals
  !MOV   Eax,[_PB_Gadget_Globals]
  !push  eax
  !call  _PB_Object_GetThreadMemory@4
  !MOV   Eax,[Eax]
  ProcedureReturn
  CreateGadgetList(0)
EndProcedure

ProcedureDLL RCam_Init()
	Global RCam_Dll		.l
	Global RCamObjects	.l
	RCam_Dll 		= OpenLibrary(#PB_Any, "avicap32.dll")
	RCamObjects = RCAM_INITIALIZE(@RCamFreeGadget()) 
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
		*RCam\hWnd		= CallFunctionFast(RCam_Address, "CaptureWindow", #WS_CHILD | #WS_VISIBLE, x, y, Width, Height, WindowID(0),Gadget)
		*RCam\x				=	x
		*RCam\y				= y
		*RCam\width		= Width
		*RCam\height	= Height
		ProcedureReturn *RCam
	Else
		ProcedureReturn #False
	EndIf
EndProcedure
ProcedureDLL RCam_GadgetID(Id.l)
	Protected *RCam.S_RCam = RCAM_ID(Id)
	ProcedureReturn *RCam\hWnd
EndProcedure
ProcedureDLL RCam_GadgetX(Id.l)
  Protected *RCam.S_RCam
  *RCam = RCAM_ID(Id)
  ProcedureReturn *RCam\x
EndProcedure
ProcedureDLL RCam_GadgetY(Id.l)
  Protected *RCam.S_RCam
  *RCam = RCAM_ID(Id)
  ProcedureReturn *RCam\y
EndProcedure
ProcedureDLL RCam_GadgetHeight(Id.l)
  Protected *RCam.S_RCam
  *RCam = RCAM_ID(Id)
  ProcedureReturn *RCam\height
EndProcedure
ProcedureDLL RCam_GadgetWidth(Id.l)
  Protected *RCam.S_RCam
  *RCam = RCAM_ID(Id)
  ProcedureReturn *RCam\width
EndProcedure
ProcedureDLL RCamFreeGadget(Id.l)
  Protected *RCam.S_RCam
  If Id <> #PB_Any And RCAM_IS(Id)
    *RCam 				= RCAM_ID(Id)
  EndIf
  If *RCam
	  DestroyWindow_(*RCam\hWnd)
    RCAM_FREE			(Id)
  EndIf
  ProcedureReturn #True
EndProcedure
ProcedureDLL RCam_ResizeGadget(Id.l, x.l, y.l, Width.l, Height.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
	*RCam\x				=	x
	*RCam\y				= y
	*RCam\width		= Width
	*RCam\height	= Height
  ProcedureReturn SetWindowPos_(*RCam\hWnd, #HWND_BOTTOM, x, y, Width, Height, #SWP_NOMOVE | #SWP_NOZORDER)
EndProcedure
ProcedureDLL.l RCam_SetGadgetData(Id.l, Value.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_USER_DATA, 0, Value)
EndProcedure
ProcedureDLL.l RCam_GetGadgetData(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_GET_USER_DATA, 0, 0)
EndProcedure


ProcedureDLL.l RCam_GetDriverId(Index.l)
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

ProcedureDLL.l RCam_Connect(Id.l, DriverID.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_CONNECT, DriverID, 0)
EndProcedure
ProcedureDLL.l RCam_EnablePreviewMode(Id.l, PreviewMode.l, PreviewFrameRate.l = 15)
  Protected *RCam.S_RCam
  Protected hPreview.l
  *RCam = RCAM_ID(Id)
  If PreviewMode = #True
  	hPreview 	=	SendMessage_(*RCam\hWnd, #WM_CAP_SET_PREVIEW, PreviewMode, 0)
  							SendMessage_(*RCam\hWnd, #WM_CAP_SET_PREVIEWRATE, PreviewFrameRate, 0)
  	ProcedureReturn hPreview
  Else
  	ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_PREVIEW, Bool, 0)
  EndIf
EndProcedure
ProcedureDLL.l RCam_SetScaleMode(Id.l, Bool.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*Rcam\hWnd, #WM_CAP_SET_SCALE,	Bool, 0)
EndProcedure
ProcedureDLL.l RCam_SetOverlay(Id.l, Bool.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_OVERLAY, Bool, 0)
EndProcedure
ProcedureDLL.l RCam_Disconnect(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  SendMessage_(*RCam\hWnd, #WM_CAP_STOP, 0, 0)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_DISCONNECT, 0, 0)
EndProcedure


ProcedureDLL.l RCam_VideoCompressionRequester(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DLG_VIDEOCOMPRESSION, 0, 0)
EndProcedure

ProcedureDLL.l RCam_VideoDisplayRequester(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DLG_VIDEODISPLAY, 0, 0)
EndProcedure
ProcedureDLL.l RCam_VDR_Has(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  Protected Caps.CAPDRIVERCAPS
	SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_GET_CAPS, SizeOf (CAPDRIVERCAPS), @Caps)
	ProcedureReturn Caps\fHasDlgVideoDisplay
EndProcedure

ProcedureDLL.l RCam_VideoFormatRequester(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DLG_VIDEOFORMAT, 0, 0)
EndProcedure
ProcedureDLL.l RCam_VFR_Has(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  Protected Caps.CAPDRIVERCAPS
	SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_GET_CAPS, SizeOf (CAPDRIVERCAPS), @Caps)
	ProcedureReturn Caps\fHasDlgVideoFormat
EndProcedure
ProcedureDLL.l RCam_VFR_GetWidth(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  Protected s.CAPSTATUS 
  If SendMessage_(*RCam\hWnd, #WM_CAP_GET_STATUS, SizeOf(CAPSTATUS), @s) = #True
		ProcedureReturn s\uiImageWidth
	Else
		ProcedureReturn -1
	EndIf
EndProcedure
ProcedureDLL.l RCam_VFR_GetHeight(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  Protected s.CAPSTATUS 
  If SendMessage_(*RCam\hWnd, #WM_CAP_GET_STATUS, SizeOf(CAPSTATUS), @s) = #True
		ProcedureReturn s\uiImageHeight
	Else
		ProcedureReturn -1
	EndIf
EndProcedure

ProcedureDLL.l RCam_VideoSourceRequester(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_DLG_VIDEOSOURCE, 0, 0)
EndProcedure
ProcedureDLL.l RCam_VSR_Has(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  Protected Caps.CAPDRIVERCAPS
	SendMessage_(*RCam\hWnd, #WM_CAP_DRIVER_GET_CAPS, SizeOf (CAPDRIVERCAPS), @Caps)
	ProcedureReturn Caps\fHasDlgVideoSource
EndProcedure

ProcedureDLL.l RCam_Snapshot(Id.l, Filename.s)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  SendMessage_(*RCam\hWnd, #WM_CAP_GRAB_FRAME, 0, 0)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_FILE_SAVEDIBA, 0, Filename)
EndProcedure

; Capture
ProcedureDLL.l RCam_SetCaptureFilename(Id.l, Filename.s)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  *RCam\Filename	=	Filename
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_FILE_SET_CAPTURE_FILE, 0, @Filename)
EndProcedure
ProcedureDLL.l RCam_SetAudioCapture(Id.l, Type.l = #WAVE_FORMAT_PCM, NbChannels = 2, SampleRate = 11025, AverageDataTransferRate = 22050, BlockAlignment = 2, BitsPerSample = 8)
  Protected *RCam.S_RCam = RCAM_ID(Id)
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
ProcedureDLL.l RCam_StartCapture(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SEQUENCE, 0, 0)
EndProcedure
ProcedureDLL.l RCam_StopCapture(Id.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  SendMessage_(*RCam\hWnd, #WM_CAP_STOP, 0, 0)
	ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_FILE_SAVEAS, 0, @*RCam\Filename)
EndProcedure
; ProcedureDLL.l RCam_Tmp(Id.l)
;   Protected *RCam.S_RCam = RCAM_ID(Id)
;   Protected s.CAPTUREPARMS 
;   SendMessage_(*RCam\hWnd, #WM_CAP_GET_SEQUENCE_SETUP, SizeOf(CAPTUREPARMS), @s)
;   Debug s\fMakeUserHitOKToCapture; 
;   s\fMakeUserHitOKToCapture	=	#True
;   SendMessage_(*RCam\hWnd, #WM_CAP_SET_SEQUENCE_SETUP, SizeOf(CAPTUREPARMS), @s)
;   ProcedureReturn 
; EndProcedure
; Callback
ProcedureDLL.l RCam_SetCallBackError(Id.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_ERROR, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackFrame(Id.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_FRAME, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackStatus(Id.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_STATUS, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackVideoStream(Id.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_VIDEOSTREAM, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackWaveStream(Id.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_WAVESTREAM, 0, Callback)
EndProcedure
ProcedureDLL.l RCam_SetCallBackYield(Id.l, Callback.l)
  Protected *RCam.S_RCam = RCAM_ID(Id)
  ProcedureReturn SendMessage_(*RCam\hWnd, #WM_CAP_SET_CALLBACK_YIELD, 0, Callback)
EndProcedure


; ProcedureDLL.l RCam_(Id.l)
;   Protected *RCam.S_RCam = RCAM_ID(Id)
;   ProcedureReturn SendMessage_(*RCam\hWnd, , , 0)
; EndProcedure

; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 155
; Folding = AAAAAAAAw
; EnableXP