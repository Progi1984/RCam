	If OpenWindow(0, 0, 0, 600, 260, "RootsCam", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		WebCam = RCam_Gadget(#PB_Any, 10, 10, 320, 240)
		ButtonGadget(1, 340,010, 120, 30, "Video > Compression")
		ButtonGadget(2, 470,010, 120, 30, "Video > Display")
		ButtonGadget(3, 340,050, 120, 30, "Video > Format")
		ButtonGadget(4, 470,050, 120, 30, "Video > Source")
		ButtonGadget(5, 340,090, 120, 30, "Snapshot")
		ButtonGadget(6, 470,090, 120, 30, "Resize")
	EndIf
	
	For Inc_a = 0 To 9
		If RCam_GetDriverID(Inc_a) <> -1
			Debug RCam_GetDriverID(Inc_a)
			Debug RCam_GetDriverName(Inc_a)
			Debug RCam_GetDriverDescription(Inc_a)
		EndIf
	Next
	
	RCam_Connect(WebCam,0)
	RCam_EnablePreviewMode(WebCam, #True, 15)
	If RCam_VDR_Has(WebCam)=#False	:DisableGadget(2, #True):EndIf
	If RCam_VFR_Has(WebCam)=#False	:DisableGadget(3, #True):EndIf
	If RCam_VSR_Has(WebCam)=#False	:DisableGadget(4, #True):EndIf
  Repeat
    Event  = WindowEvent()
    Gadget = EventGadget()
    Menu   = EventMenu()
    Select Event
      Case #PB_Event_Gadget
        Select Gadget
        	Case 1
        		Debug RCam_VideoCompressionRequester(WebCam)
        	Case 2
        		Debug RCam_VideoDisplayRequester(WebCam)
        	Case 3
        		If RCam_VideoFormatRequester(WebCam) = #True
        			Debug RCam_VFR_GetWidth(WebCam)
        			Debug RCam_VFR_GetHeight(WebCam)
        		EndIf
        	Case 4
        		Debug RCam_VideoSourceRequester(WebCam)
        	Case 5
        		RCam_Snapshot(Webcam, "C:\RCam.jpg")
        	Case 6
        		RCam_ResizeGadget(Webcam, 10, 10, 150, 150)
        EndSelect
    EndSelect
  Until Event=#PB_Event_CloseWindow
	
	RCam_Disconnect(WebCam)
	RCam_FreeGadget(WebCam)
	End
