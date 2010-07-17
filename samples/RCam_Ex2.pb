; Thanks DarkDragon
Procedure CB_Frame(hWnd.l, *lpVHdr.VIDEOHDR)
	Protected Inc_a.l
  For Inc_a = 0 To *lpVHdr\dwBufferLength-1
    Color = PeekB(*lpVHdr\lpData + Inc_a)
    PokeB(*lpVHdr\lpData + Inc_a, RGB(Blue(Color), Green(Color), Red(Color)))
  Next
EndProcedure
Procedure CB_Status(hWnd.l, nID.l, lpStatusText.l)
	Select nID
		Case #IDS_CAP_BEGIN
			Debug nID
		Case #IDS_CAP_END
			Debug nID
		Case #IDS_CAP_INFO
			Debug "CB_Status	>	#IDS_CAP_INFO	>	" + PeekS(lpStatusText)
		Case #IDS_CAP_STAT_LIVE_MODE
			Debug "CB_Status	>	#IDS_CAP_STAT_LIVE_MODE	>	" + PeekS(lpStatusText)
	EndSelect
EndProcedure
Procedure CB_Error(hWnd.l, nErrID.l, lpErrorText.l)
  Select nErrID 
  	Case #IDS_CAP_DRIVER_ERROR
  		Debug "CB_Error	>	#IDS_CAP_DRIVER_ERROR	>	" + PeekS(lpErrorText)
  	Default
  		Debug "CB_Error	>	" + Str(nId) + "	>	Unspecified capture device error (" + Str(nId) + ")"
  EndSelect
EndProcedure
Procedure CB_VideoStream(hWnd.l, *lpVHdr.VIDEOHDR)
EndProcedure
Procedure CB_WaveStream(hWnd.l, *lpWHdr.WAVEHDR)
EndProcedure
Procedure CB_Yield(hWnd.l)
	EndProcedure

	
	If OpenWindow(0, 0, 0, 600, 260, "RootsCam", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		WebCam = RCam_Gadget(#PB_Any, 10, 10, 320, 240)
		ButtonGadget(01, 340,010, 120, 30, "CB_Frame = Proc")
		ButtonGadget(02, 470,010, 120, 30, "CB_Frame = 0")
		ButtonGadget(03, 340,050, 120, 30, "CB_Status = Proc")
		ButtonGadget(04, 470,050, 120, 30, "CB_Status = 0")
		ButtonGadget(05, 340,090, 120, 30, "CB_Error = Proc")
		ButtonGadget(06, 470,090, 120, 30, "CB_Error = 0")
		ButtonGadget(07, 340,130, 120, 30, "CB_VideoStream = Proc")
		ButtonGadget(08, 470,130, 120, 30, "CB_VideoStream = 0")
		ButtonGadget(09, 340,170, 120, 30, "CB_WaveStream = Proc")
		ButtonGadget(10, 470,170, 120, 30, "CB_WaveStream = 0")
		ButtonGadget(11, 340,210, 120, 30, "CB_Yield = Proc")
		ButtonGadget(12, 470,210, 120, 30, "CB_Yield = 0")
	EndIf
	RCam_SetCallBackStatus(WebCam, @CB_Status())
	RCam_Connect(WebCam,0)
	RCam_EnablePreviewMode(WebCam, #True, 15)
  Repeat
    Event  = WindowEvent()
    Gadget = EventGadget()
    Menu   = EventMenu()
    Select Event
      Case #PB_Event_Gadget
        Select Gadget
        	Case 01
						RCam_SetCallBackFrame(WebCam, @CB_Frame())
        	Case 02
        		RCam_SetCallBackFrame(WebCam, 0)
        	Case 03
        		RCam_SetCallBackStatus(WebCam, @CB_Status())
        	Case 04
        		RCam_SetCallBackStatus(WebCam, 0)
        	Case 05
        		RCam_SetCallBackError(WebCam, @CB_Error())
        	Case 06
        		RCam_SetCallBackError(WebCam, 0)
        	Case 07
        		RCam_SetCallBackError(WebCam, @CB_VideoStream())
        	Case 08
        		RCam_SetCallBackError(WebCam, 0)
        	Case 09
        		RCam_SetCallBackError(WebCam, @CB_WaveStream())
        	Case 10
        		RCam_SetCallBackError(WebCam, 0)
        	Case 11
        		RCam_SetCallBackError(WebCam, @CB_Yield())
        	Case 12
        		RCam_SetCallBackError(WebCam, 0)
        EndSelect
    EndSelect
  Until Event=#PB_Event_CloseWindow
	
	RCam_Disconnect(WebCam)
	RCam_FreeGadget(WebCam)
	End