;- Macros
;{
	Macro RCAM_ID(RWebcam)
	  Object_GetObject(RCamObjects, RWebcam)
	EndMacro
	Macro RCAM_IS(RWebcam)
	  Object_IsObject(RCamObjects, RWebcam) 
	EndMacro
	Macro RCAM_NEW(RWebcam)
	  Object_GetOrAllocateID(RCamObjects, RWebcam)
	EndMacro
	Macro RCAM_FREE(RWebcam)
	  If RWebcam <> #PB_Any And RCAM_IS(RWebcam) > 0
	    Object_FreeID(RCamObjects, RWebcam)
	  EndIf
	EndMacro
	Macro RCAM_INITIALIZE(hCloseFunction)
	  Object_Init(SizeOf(S_RCam), 1, hCloseFunction)
	EndMacro
;}

;- Structures
;{
	Structure S_RCam
		hWnd			.l
		x					.l
		y					.l
		width			.l
		height		.l
		Filename	.s
	EndStructure
	Structure HPALETTE
	  dummy.l 											; no info about it :(
	EndStructure
	Structure CAPDRIVERCAPS
	    wDeviceIndex.l ;               // Driver index in system.ini
	    fHasOverlay.l ;                // Can device overlay?
	    fHasDlgVideoSource.l ;         // Has Video source dlg?
	    fHasDlgVideoFormat.l ;         // Has Format dlg?
	    fHasDlgVideoDisplay.l ;        // Has External out dlg?
	    fCaptureInitialized.l ;        // Driver ready to capture?
	    fDriverSuppliesPalettes.l ;    // Can driver make palettes?
	    hVideoIn.l ;                   // Driver In channel
	    hVideoOut.l ;                  // Driver Out channel
	    hVideoExtIn.l ;                // Driver Ext In channel
	    hVideoExtOut.l ;               // Driver Ext Out channel
	EndStructure
	Structure CAPINFOCHUNK
	    fccInfoID.l                       ;// Chunk ID, "ICOP" for copyright
	    lpData.l                          ;// pointer to data
	    cbData.l                          ;// size of lpData
	EndStructure
	Structure CAPSTATUS
	    uiImageWidth.l                    ;// Width of the image
	    uiImageHeight.l                   ;// Height of the image
	    fLiveWindow.l                     ;// Now Previewing video?
	    fOverlayWindow.l                  ;// Now Overlaying video?
	    fScale.l                          ;// Scale image to client?
	    ptScroll.POINT                    ;// Scroll position
	    fUsingDefaultPalette.l            ;// Using default driver palette?
	    fAudioHardware.l                  ;// Audio hardware present?
	    fCapFileExists.l                  ;// Does capture file exist?
	    dwCurrentVideoFrame.l             ;// # of video frames cap;td
	    dwCurrentVideoFramesDropped.l     ;// # of video frames dropped
	    dwCurrentWaveSamples.l            ;// # of wave samples cap;td
	    dwCurrentTimeElapsedMS.l          ;// Elapsed capture duration
	    hPalCurrent.l                     ;// Current palette in use
	    fCapturingNow.l                   ;// Capture in progress?
	    dwReturn.l                        ;// Error value after any operation
	    wNumVideoAllocated.l              ;// Actual number of video buffers
	    wNumAudioAllocated.l              ;// Actual number of audio buffers
	EndStructure
	Structure CAPTUREPARMS
	    dwRequestMicroSecPerFrame.l       ;// Requested capture rate
	    fMakeUserHitOKToCapture.l         ;// Show "Hit OK to cap" dlg?
	    wPercentDropForError.l            ;// Give error msg if >  (10%)
	    fYield.l                          ;// Capture via background task?
	    dwIndexSize.l                     ;// Max index size in frames  (32K)
	    wChunkGranularity.l               ;// Junk chunk granularity  (2K)
	    fUsingDOSMemory.l                 ;// Use DOS buffers?
	    wNumVideoRequested.l              ;// # video buffers, If 0, autocalc
	    fCaptureAudio.l                   ;// Capture audio?
	    wNumAudioRequested.l              ;// # audio buffers, If 0, autocalc
	    vKeyAbort.l                       ;// Virtual key causing abort
	    fAbortLeftMouse.l                 ;// Abort on left mouse?
	    fAbortRightMouse.l                ;// Abort on right mouse?
	    fLimitEnabled.l                   ;// Use wTimeLimit?
	    wTimeLimit.l                      ;// Seconds to capture
	    fMCIControl.l                     ;// Use MCI video source?
	    fStepMCIDevice.l                  ;// Step MCI device?
	    dwMCIStartTime.l                  ;// Time to start in MS
	    dwMCIStopTime.l                   ;// Time to stop in MS
	    fStepCaptureAt2x.l                ;// Perform spatial averaging 2x
	    wStepCaptureAverageFrames.l       ;// Temporal average n Frames
	    dwAudioBufferSize.l               ;// Size of audio bufs  (0 = default)
	    fDisableWriteCache.l              ;// Attempt to disable write cache
	EndStructure
	Structure VIDEOHDR
	    lpData.l ;// address of video buffer
	    dwBufferLength.l ;// size, in bytes, of the Data buffer
	    dwBytesUsed.l ;// see below
	    dwTimeCaptured.l ;// see below
	    dwUser.l ;// user-specific data
	    dwFlags.l ;// see below
	    dwReserved.l[3] ;// reserved; do not use}
	EndStructure
; 	Structure WAVEFORMATEX
; 	 	wFormatTag.w
; 	 	nChannels.w
; 	 	nSamplesPerSec.l
; 	 	nAvgBytesPerSec.l
; 	 	nBlockAlign.w
; 	 	wBitsPerSample.w
; 		cbSize.w
;  EndStructure
;}

;- Constantes
;{
	;{ #WM_CAP_
		#WM_CAP_START 										= #WM_USER
		#WM_CAP_GET_CAPSTREAMPTR 					= #WM_CAP_START + 1
		#WM_CAP_SET_CALLBACK_ERROR 			  = #WM_CAP_START + 2
		#WM_CAP_SET_CALLBACK_STATUS 			= #WM_CAP_START + 3
		#WM_CAP_SET_CALLBACK_YIELD 				= #WM_CAP_START + 4
		#WM_CAP_SET_CALLBACK_FRAME 				= #WM_CAP_START + 5
		#WM_CAP_SET_CALLBACK_VIDEOSTREAM 	= #WM_CAP_START + 6
		#WM_CAP_SET_CALLBACK_WAVESTREAM 	= #WM_CAP_START + 7
		#WM_CAP_GET_USER_DATA 						= #WM_CAP_START + 8
		#WM_CAP_SET_USER_DATA 						= #WM_CAP_START + 9
		#WM_CAP_DRIVER_CONNECT		 				= #WM_CAP_START + 10
		#WM_CAP_DRIVER_DISCONNECT 				= #WM_CAP_START + 11
		#WM_CAP_DRIVER_GET_NAME 					= #WM_CAP_START + 12
		#WM_CAP_DRIVER_GET_VERSION 				= #WM_CAP_START + 13
		#WM_CAP_DRIVER_GET_CAPS					 	= #WM_CAP_START + 14
		#WM_CAP_FILE_SET_CAPTURE_FILE			= #WM_CAP_START + 20
		#WM_CAP_FILE_GET_CAPTURE_FILE 		= #WM_CAP_START + 21
		#WM_CAP_FILE_ALLOCATE 						= #WM_CAP_START + 22
		#WM_CAP_FILE_SAVEAS 							= #WM_CAP_START + 23
		#WM_CAP_FILE_SET_INFOCHUNK 				= #WM_CAP_START + 24
		#WM_CAP_FILE_SAVEDIBA 						= #WM_CAP_START + 25
		#WM_CAP_EDIT_COPY 								= #WM_CAP_START + 30
		#WM_CAP_SET_AUDIOFORMAT 					= #WM_CAP_START + 35
		#WM_CAP_GET_AUDIOFORMAT 					= #WM_CAP_START + 36
		#WM_CAP_DLG_VIDEOFORMAT 					= #WM_CAP_START + 41
		#WM_CAP_DLG_VIDEOSOURCE 					= #WM_CAP_START + 42
		#WM_CAP_DLG_VIDEODISPLAY 					= #WM_CAP_START + 43
		#WM_CAP_GET_VIDEOFORMAT 					= #WM_CAP_START + 44
		#WM_CAP_SET_VIDEOFORMAT 					= #WM_CAP_START + 45
		#WM_CAP_DLG_VIDEOCOMPRESSION 			= #WM_CAP_START + 46
		#WM_CAP_SET_PREVIEW		 						= #WM_CAP_START + 50
		#WM_CAP_SET_OVERLAY 							= #WM_CAP_START + 51
		#WM_CAP_SET_PREVIEWRATE		 				= #WM_CAP_START + 52
		#WM_CAP_SET_SCALE 								= #WM_CAP_START + 53
		#WM_CAP_GET_STATUS 								= #WM_CAP_START + 54
		#WM_CAP_SET_SCROLL 								= #WM_CAP_START + 55
		#WM_CAP_GRAB_FRAME 								= #WM_CAP_START + 60
		#WM_CAP_GRAB_FRAME_NOSTOP 				= #WM_CAP_START + 61
		#WM_CAP_SEQUENCE 									= #WM_CAP_START + 62
		#WM_CAP_SEQUENCE_NOFILE 					= #WM_CAP_START + 63
		#WM_CAP_SET_SEQUENCE_SETUP		 		= #WM_CAP_START + 64
		#WM_CAP_GET_SEQUENCE_SETUP 				= #WM_CAP_START + 65
		#WM_CAP_SET_MCI_DEVICE 						= #WM_CAP_START + 66
		#WM_CAP_GET_MCI_DEVICE 						= #WM_CAP_START + 67
		#WM_CAP_STOP 											= #WM_CAP_START + 68
		#WM_CAP_ABORT 										= #WM_CAP_START + 69
		#WM_CAP_SINGLE_FRAME_OPEN       	= #WM_CAP_START + 70
		#WM_CAP_SINGLE_FRAME_CLOSE 				= #WM_CAP_START + 71
		#WM_CAP_SINGLE_FRAME 							= #WM_CAP_START + 72
		#WM_CAP_PAL_OPEN 									= #WM_CAP_START + 80
		#WM_CAP_PAL_SAVE 									= #WM_CAP_START + 81
		#WM_CAP_PAL_PASTE 								= #WM_CAP_START + 82
		#WM_CAP_PAL_AUTOCREATE 						= #WM_CAP_START + 83
		#WM_CAP_PAL_MANUALCREATE 					= #WM_CAP_START + 84
		#WM_CAP_SET_CALLBACK_CAPCONTROL 	= #WM_CAP_START + 85
		;#WM_CAP_END 											= #WM_CAP_SET_CALLBACK_CAPCONTROL
	;}
	;{ #WAVE_FORMAT_
		; WAVE form wFormatTag IDs 
		#WAVE_FORMAT_UNKNOWN                    = $0000 ; Microsoft Corporation 
		#WAVE_FORMAT_ADPCM                      = $0002 ; Microsoft Corporation 
		#WAVE_FORMAT_IEEE_FLOAT                 = $0003 ; Microsoft Corporation 
		#WAVE_FORMAT_VSELP                      = $0004 ; Compaq Computer Corp. 
		#WAVE_FORMAT_IBM_CVSD                   = $0005 ; IBM Corporation 
		#WAVE_FORMAT_ALAW                       = $0006 ; Microsoft Corporation 
		#WAVE_FORMAT_MULAW                      = $0007 ; Microsoft Corporation 
		#WAVE_FORMAT_DTS                        = $0008 ; Microsoft Corporation 
		#WAVE_FORMAT_DRM                        = $0009 ; Microsoft Corporation 
		#WAVE_FORMAT_OKI_ADPCM                  = $0010 ; OKI 
		#WAVE_FORMAT_DVI_ADPCM                  = $0011 ; Intel Corporation 
		#WAVE_FORMAT_IMA_ADPCM                  = #WAVE_FORMAT_DVI_ADPCM ;  Intel Corporation 
		#WAVE_FORMAT_MEDIASPACE_ADPCM           = $0012 ; Videologic 
		#WAVE_FORMAT_SIERRA_ADPCM               = $0013 ; Sierra Semiconductor Corp 
		#WAVE_FORMAT_G723_ADPCM                 = $0014 ; Antex Electronics Corporation 
		#WAVE_FORMAT_DIGISTD                    = $0015 ; DSP Solutions, Inc. 
		#WAVE_FORMAT_DIGIFIX                    = $0016 ; DSP Solutions, Inc. 
		#WAVE_FORMAT_DIALOGIC_OKI_ADPCM         = $0017 ; Dialogic Corporation 
		#WAVE_FORMAT_MEDIAVISION_ADPCM          = $0018 ; Media Vision, Inc. 
		#WAVE_FORMAT_CU_CODEC                   = $0019 ; Hewlett-Packard Company 
		#WAVE_FORMAT_YAMAHA_ADPCM               = $0020 ; Yamaha Corporation of America 
		#WAVE_FORMAT_SONARC                     = $0021 ; Speech Compression 
		#WAVE_FORMAT_DSPGROUP_TRUESPEECH        = $0022 ; DSP Group, Inc 
		#WAVE_FORMAT_ECHOSC1                    = $0023 ; Echo Speech Corporation 
		#WAVE_FORMAT_AUDIOFILE_AF36             = $0024 ; Virtual Music, Inc. 
		#WAVE_FORMAT_APTX                       = $0025 ; Audio Processing Technology 
		#WAVE_FORMAT_AUDIOFILE_AF10             = $0026 ; Virtual Music, Inc. 
		#WAVE_FORMAT_PROSODY_1612               = $0027 ; Aculab plc 
		#WAVE_FORMAT_LRC                        = $0028 ; Merging Technologies S.A. 
		#WAVE_FORMAT_DOLBY_AC2                  = $0030 ; Dolby Laboratories 
		#WAVE_FORMAT_GSM610                     = $0031 ; Microsoft Corporation 
		#WAVE_FORMAT_MSNAUDIO                   = $0032 ; Microsoft Corporation 
		#WAVE_FORMAT_ANTEX_ADPCME               = $0033 ; Antex Electronics Corporation 
		#WAVE_FORMAT_CONTROL_RES_VQLPC          = $0034 ; Control Resources Limited 
		#WAVE_FORMAT_DIGIREAL                   = $0035 ; DSP Solutions, Inc. 
		#WAVE_FORMAT_DIGIADPCM                  = $0036 ; DSP Solutions, Inc. 
		#WAVE_FORMAT_CONTROL_RES_CR10           = $0037 ; Control Resources Limited 
		#WAVE_FORMAT_NMS_VBXADPCM               = $0038 ; Natural MicroSystems 
		#WAVE_FORMAT_CS_IMAADPCM                = $0039 ; Crystal Semiconductor IMA ADPCM 
		#WAVE_FORMAT_ECHOSC3                    = $003A ; Echo Speech Corporation 
		#WAVE_FORMAT_ROCKWELL_ADPCM             = $003B ; Rockwell International 
		#WAVE_FORMAT_ROCKWELL_DIGITALK          = $003C ; Rockwell International 
		#WAVE_FORMAT_XEBEC                      = $003D ; Xebec Multimedia Solutions Limited 
		#WAVE_FORMAT_G721_ADPCM                 = $0040 ; Antex Electronics Corporation 
		#WAVE_FORMAT_G728_CELP                  = $0041 ; Antex Electronics Corporation 
		#WAVE_FORMAT_MSG723                     = $0042 ; Microsoft Corporation 
		#WAVE_FORMAT_MPEG                       = $0050 ; Microsoft Corporation 
		#WAVE_FORMAT_RT24                       = $0052 ; InSoft, Inc. 
		#WAVE_FORMAT_PAC                        = $0053 ; InSoft, Inc. 
		#WAVE_FORMAT_MPEGLAYER3                 = $0055 ; ISO/MPEG Layer3 Format Tag 
		#WAVE_FORMAT_LUCENT_G723                = $0059 ; Lucent Technologies 
		#WAVE_FORMAT_CIRRUS                     = $0060 ; Cirrus Logic 
		#WAVE_FORMAT_ESPCM                      = $0061 ; ESS Technology 
		#WAVE_FORMAT_VOXWARE                    = $0062 ; Voxware Inc 
		#WAVE_FORMAT_CANOPUS_ATRAC              = $0063 ; Canopus, co., Ltd. 
		#WAVE_FORMAT_G726_ADPCM                 = $0064 ; APICOM 
		#WAVE_FORMAT_G722_ADPCM                 = $0065 ; APICOM 
		#WAVE_FORMAT_DSAT_DISPLAY               = $0067 ; Microsoft Corporation 
		#WAVE_FORMAT_VOXWARE_BYTE_ALIGNED       = $0069 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_AC8                = $0070 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_AC10               = $0071 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_AC16               = $0072 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_AC20               = $0073 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_RT24               = $0074 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_RT29               = $0075 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_RT29HW             = $0076 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_VR12               = $0077 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_VR18               = $0078 ; Voxware Inc 
		#WAVE_FORMAT_VOXWARE_TQ40               = $0079 ; Voxware Inc 
		#WAVE_FORMAT_SOFTSOUND                  = $0080 ; Softsound, Ltd. 
		#WAVE_FORMAT_VOXWARE_TQ60               = $0081 ; Voxware Inc 
		#WAVE_FORMAT_MSRT24                     = $0082 ; Microsoft Corporation 
		#WAVE_FORMAT_G729A                      = $0083 ; AT&T Labs, Inc. 
		#WAVE_FORMAT_MVI_MVI2                   = $0084 ; Motion Pixels 
		#WAVE_FORMAT_DF_G726                    = $0085 ; DataFusion Systems (Pty) (Ltd) 
		#WAVE_FORMAT_DF_GSM610                  = $0086 ; DataFusion Systems (Pty) (Ltd) 
		#WAVE_FORMAT_ISIAUDIO                   = $0088 ; Iterated Systems, Inc. 
		#WAVE_FORMAT_ONLIVE                     = $0089 ; OnLive! Technologies, Inc. 
		#WAVE_FORMAT_SBC24                      = $0091 ; Siemens Business Communications Sys 
		#WAVE_FORMAT_DOLBY_AC3_SPDIF            = $0092 ; Sonic Foundry 
		#WAVE_FORMAT_MEDIASONIC_G723            = $0093 ; MediaSonic 
		#WAVE_FORMAT_PROSODY_8KBPS              = $0094 ; Aculab plc 
		#WAVE_FORMAT_ZYXEL_ADPCM                = $0097 ; ZyXEL Communications, Inc. 
		#WAVE_FORMAT_PHILIPS_LPCBB              = $0098 ; Philips Speech Processing 
		#WAVE_FORMAT_PACKED                     = $0099 ; Studer Professional Audio AG 
		#WAVE_FORMAT_MALDEN_PHONYTALK           = $00A0 ; Malden Electronics Ltd. 
		#WAVE_FORMAT_RHETOREX_ADPCM             = $0100 ; Rhetorex Inc. 
		#WAVE_FORMAT_IRAT                       = $0101 ; BeCubed Software Inc. 
		#WAVE_FORMAT_VIVO_G723                  = $0111 ; Vivo Software 
		#WAVE_FORMAT_VIVO_SIREN                 = $0112 ; Vivo Software 
		#WAVE_FORMAT_DIGITAL_G723               = $0123 ; Digital Equipment Corporation 
		#WAVE_FORMAT_SANYO_LD_ADPCM             = $0125 ; Sanyo Electric Co., Ltd. 
		#WAVE_FORMAT_SIPROLAB_ACEPLNET          = $0130 ; Sipro Lab Telecom Inc. 
		#WAVE_FORMAT_SIPROLAB_ACELP4800         = $0131 ; Sipro Lab Telecom Inc. 
		#WAVE_FORMAT_SIPROLAB_ACELP8V3          = $0132 ; Sipro Lab Telecom Inc. 
		#WAVE_FORMAT_SIPROLAB_G729              = $0133 ; Sipro Lab Telecom Inc. 
		#WAVE_FORMAT_SIPROLAB_G729A             = $0134 ; Sipro Lab Telecom Inc. 
		#WAVE_FORMAT_SIPROLAB_KELVIN            = $0135 ; Sipro Lab Telecom Inc. 
		#WAVE_FORMAT_G726ADPCM                  = $0140 ; Dictaphone Corporation 
		#WAVE_FORMAT_QUALCOMM_PUREVOICE         = $0150 ; Qualcomm, Inc. 
		#WAVE_FORMAT_QUALCOMM_HALFRATE          = $0151 ; Qualcomm, Inc. 
		#WAVE_FORMAT_TUBGSM                     = $0155 ; Ring Zero Systems, Inc. 
		#WAVE_FORMAT_MSAUDIO1                   = $0160 ; Microsoft Corporation 
		#WAVE_FORMAT_UNISYS_NAP_ADPCM           = $0170 ; Unisys Corp. 
		#WAVE_FORMAT_UNISYS_NAP_ULAW            = $0171 ; Unisys Corp. 
		#WAVE_FORMAT_UNISYS_NAP_ALAW            = $0172 ; Unisys Corp. 
		#WAVE_FORMAT_UNISYS_NAP_16K             = $0173 ; Unisys Corp. 
		#WAVE_FORMAT_CREATIVE_ADPCM             = $0200 ; Creative Labs, Inc 
		#WAVE_FORMAT_CREATIVE_FASTSPEECH8       = $0202 ; Creative Labs, Inc 
		#WAVE_FORMAT_CREATIVE_FASTSPEECH10      = $0203 ; Creative Labs, Inc 
		#WAVE_FORMAT_UHER_ADPCM                 = $0210 ; UHER informatic GmbH 
		#WAVE_FORMAT_QUARTERDECK                = $0220 ; Quarterdeck Corporation 
		#WAVE_FORMAT_ILINK_VC                   = $0230 ; I-link Worldwide 
		#WAVE_FORMAT_RAW_SPORT                  = $0240 ; Aureal Semiconductor 
		#WAVE_FORMAT_ESST_AC3                   = $0241 ; ESS Technology, Inc. 
		#WAVE_FORMAT_IPI_HSX                    = $0250 ; Interactive Products, Inc. 
		#WAVE_FORMAT_IPI_RPELP                  = $0251 ; Interactive Products, Inc. 
		#WAVE_FORMAT_CS2                        = $0260 ; Consistent Software 
		#WAVE_FORMAT_SONY_SCX                   = $0270 ; Sony Corp. 
		#WAVE_FORMAT_FM_TOWNS_SND               = $0300 ; Fujitsu Corp. 
		#WAVE_FORMAT_BTV_DIGITAL                = $0400 ; Brooktree Corporation 
		#WAVE_FORMAT_QDESIGN_MUSIC              = $0450 ; QDesign Corporation 
		#WAVE_FORMAT_VME_VMPCM                  = $0680 ; AT&T Labs, Inc. 
		#WAVE_FORMAT_TPC                        = $0681 ; AT&T Labs, Inc. 
		#WAVE_FORMAT_OLIGSM                     = $1000 ; Ing C. Olivetti & C., S.p.A. 
		#WAVE_FORMAT_OLIADPCM                   = $1001 ; Ing C. Olivetti & C., S.p.A. 
		#WAVE_FORMAT_OLICELP                    = $1002 ; Ing C. Olivetti & C., S.p.A. 
		#WAVE_FORMAT_OLISBC                     = $1003 ; Ing C. Olivetti & C., S.p.A. 
		#WAVE_FORMAT_OLIOPR                     = $1004 ; Ing C. Olivetti & C., S.p.A. 
		#WAVE_FORMAT_LH_CODEC                   = $1100 ; Lernout & Hauspie 
		#WAVE_FORMAT_NORRIS                     = $1400 ; Norris Communications, Inc. 
		#WAVE_FORMAT_SOUNDSPACE_MUSICOMPRESS    = $1500 ; AT&T Labs, Inc. 
		#WAVE_FORMAT_DVM                        = $2000 ; FAST Multimedia AG 
		#WAVE_FORMAT_EXTENSIBLE                 = $FFFE ; Microsoft 
	;}
	;{ #IDS_CAP_					; C:\Program Files\Microsoft SDK\include\Vfw.h
		#IDS_CAP_BEGIN               						=	300
		#IDS_CAP_END                 						=	301
		#IDS_CAP_INFO                						=	401
		#IDS_CAP_DRIVER_ERROR										=	418		; Driver specific error message 
		#IDS_CAP_STAT_LIVE_MODE      						=	500
	;}
;}



; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 130
; FirstLine = 30
; Folding = BBM-
; EnableXP
; EnableCompileCount = 2
; EnableBuildCount = 0