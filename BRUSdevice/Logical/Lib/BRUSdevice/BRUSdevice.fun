
FUNCTION_BLOCK CIFSDevChk (*Checks for and links to USB devices in runtime. Creates a file device for USB flash memory.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enables the function. Falling edge will eject any connected devices.*) (* *) (*#PAR*)
		Parameters : CIFSDevChkPar_typ; (*Set of parameters to configure the function block operation*) (* *) (*#PAR*)
		Link : BOOL; (*Command to attempt to link to the USB device*) (* *) (*#CMD*)
		Eject : BOOL; (*Command to un-link (eject) the USB device. When the function is disabled, the device is automatically ejected.*) (* *) (*#CMD*)
		ErrorReset : BOOL; (*Positive edge attempts to reset errors.*) (* *) (*#CMD*)
		Update : BOOL; (*Positive edge re-initializes all of the values in the Parameters structure.*) (* *) (*#CMD*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Is set high when the function block initializes successfully*) (* *) (*#PAR*)
		Ready : BOOL; (*High signal on Ready indicates that a USB mass storage device has been identified and successfully linked to*) (* *) (*#PAR*)
		Error : BOOL; (*When high, indicates that an error has occured. Check Info structure for more information.*) (* *) (*#PAR*)
		Info : CIFSDevChkInfo_typ; (*Structure containing addition information about the operation of the function block.*) (* *) (*#PAR*)
	END_VAR
	VAR
		IS : zzCIFSInternalStruct_typ; (* *) (* *) (*#OMIT*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK USBDevChk (*Checks for and links to USB devices in runtime. Creates a file device for USB flash memory.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enables the function. Falling edge will eject any connected devices.*) (* *) (*#PAR*)
		Parameters : USBDevChkPar_typ; (*Set of parameters to configure the function block operation*) (* *) (*#PAR*)
		Link : BOOL; (*Command to attempt to link to the USB device*) (* *) (*#CMD*)
		Eject : BOOL; (*Command to un-link (eject) the USB device. When the function is disabled, the device is automatically ejected.*) (* *) (*#CMD*)
		ErrorReset : BOOL; (*Positive edge attempts to reset errors.*) (* *) (*#CMD*)
		Update : BOOL; (*Positive edge re-initializes all of the values in the Parameters structure.*) (* *) (*#CMD*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Is set high when the function block initializes successfully*) (* *) (*#PAR*)
		Ready : BOOL; (*High signal on Ready indicates that a USB mass storage device has been identified and successfully linked to*) (* *) (*#PAR*)
		Error : BOOL; (*When high, indicates that an error has occured. Check Info structure for more information.*) (* *) (*#PAR*)
		Info : USBDevChkInfo_typ; (*Structure containing addition information about the operation of the function block.*) (* *) (*#PAR*)
	END_VAR
	VAR
		IS : zzUSBInternalStruct_typ; (* *) (* *) (*#OMIT*)
	END_VAR
END_FUNCTION_BLOCK
