
	If OpenWindow(0, 0, 0, 600, 260, "RootsCam", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		WebCam = RCam_Gadget(#PB_Any, 10, 10, 320, 240)
		ButtonGadget(1, 340,010, 120, 30, "Start")
		ButtonGadget(2, 470,010, 120, 30, "Stop")
		DisableGadget(1,#False)
		DisableGadget(2,#True)
	EndIf
	
	RCam_Connect(WebCam,0)
	RCam_EnablePreviewMode(WebCam, #True, 15)
	
	RCam_SetCaptureFilename(WebCam, "RCamTmp.avi")
	RCam_SetAudioCapture(WebCam, #WAVE_FORMAT_PCM, 2, 11025, 22050, 2, 8)
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
	RCam_FreeGadget(WebCam)
	End
