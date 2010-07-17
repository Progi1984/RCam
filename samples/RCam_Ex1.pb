IncludeFile "RCam_Res.pb"
IncludeFile "RCam_Inc.pb"

	RCam_Init()
	
	If OpenWindow(0, 0, 0, 600, 260, "RootsCam", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		If CreateGadgetList(WindowID(0))
			WebCam = RCam_Gadget(#PB_Any, 10, 10, 320, 240)
			ButtonGadget(1, 340,010, 120, 30, "Start")
			ButtonGadget(2, 470,010, 120, 30, "Stop")
			DisableGadget(1,#False)
			DisableGadget(2,#True)
		EndIf
	EndIf
	
	RCam_Connect(WebCam,0)
	RCam_EnablePreviewMode(WebCam, #True)
	
	RCam_SetCaptureFilename(WebCam, "RCamTmp.avi")
	RCam_SetAudioCapture(WebCam)
  Repeat
    Event  = WindowEvent()
    Gadget = EventGadget()
    Menu   = EventMenu()
    Select Event
      Case #PB_Event_Gadget
        Select Gadget
        	Case 1
						RCam_StartCapture(WebCam)
						DisableGadget(1,#True)
						DisableGadget(2,#False)
        	Case 2
        		RCam_StopCapture(WebCam)
						DisableGadget(1,#False)
						DisableGadget(2,#True)
        EndSelect
    EndSelect
  Until Event=#PB_Event_CloseWindow
	
	RCam_Disconnect(WebCam)
	RCamFreeGadget(WebCam)
	RCam_End()
	End

; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 18
; Folding = -
; EnableCompileCount = 4
; EnableBuildCount = 0