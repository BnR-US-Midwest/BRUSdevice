
TYPE
	CIFSDevChkInfo_typ : 	STRUCT 
		Status : STRING[80]; (*Detail string for status of function block*)
		StatusID : CIFSDevChkStatusID_enum;
		State : CIFSDevChk_enum; (*Internal operating step of the function block*)
		fileIOStatus : UINT;
	END_STRUCT;
	CIFSDevChkPar_typ : 	STRUCT 
		DeviceName : STRING[80]; (*Optional device name. If left blank, the name of the created USB device will be 'USBDEV1'*)
		ServerDomain : STRING[80];
		ServerPw : STRING[80];
		ServerUser : STRING[80];
		ServerIP : STRING[80];
		ShareName : STRING[80];
	END_STRUCT;
	CIFSDevChkStatusID_enum : 
		(
		cifsdevERR_OK := 0, (*No errors*)
		cifsdevERR_AUTOLINK_PARAM := 10000,
		cifsdevERR_NO_USB_FOUND := 10001 (*Shown if a link was attempted, but no mass storage devices were found.*)
		);
	CIFSDevChk_enum : 
		(
		CIFS_IDLE,
		CIFS_LINK,
		CIFS_LINKED,
		CIFS_UNLINK,
		CIFS_ERROR
		);
	USBDevChkInfo_typ : 	STRUCT 
		Status : STRING[80]; (*Detail string for status of function block*)
		StatusID : USBDevChkStatusID_enum;
		State : USBDevChk_enum; (*Internal operating step of the function block*)
		DiskSizeBytes : UDINT; (*Total memory size of connected device in bytes*)
		FreeMemBytes : UDINT; (*Amount of memory available in bytes*)
	END_STRUCT;
	USBDevChkPar_typ : 	STRUCT 
		AutoLink : BOOL; (*When set high, function will try to link to a mass storage device at a set interval*)
		AutoLinkInterval : TIME; (*When autolink is enabled, how long between checks for devices*)
		DeviceName : STRING[80]; (*Optional device name. If left blank, the name of the created USB device will be 'USBDEV1'*)
	END_STRUCT;
	USBDevChkStatusID_enum : 
		(
		usbdevERR_OK := 0, (*No errors*)
		usbdevERR_AUTOLINK_PARAM := 10000,
		usbdevERR_NO_USB_FOUND := 10001 (*Shown if a link was attempted, but no mass storage devices were found.*)
		);
	USBDevChk_enum : 
		(
		USB_IDLE,
		USB_NODE_LIST,
		USB_NODE_GET,
		USB_LINK,
		USB_MEMINFO,
		USB_LINKED,
		USB_UNLINK,
		USB_ERROR
		);
	zzCIFSInternalStruct_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		step : CIFSDevChk_enum;
		cmd : zzCIFS_cmd_typ;
		par : zzCIFS_par_typ;
		stat : zzCIFS_stat_typ;
		fb : zzCIFS_fb_typ;
		old : zzCIFS_old;
	END_STRUCT;
	zzCIFS_cmd_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		link : BOOL;
	END_STRUCT;
	zzCIFS_fb_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		devLink : DevLink;
		devUnlink : DevUnlink;
		errorReset : TON;
		linkTimeout : TON;
	END_STRUCT;
	zzCIFS_old : 	STRUCT  (* *) (* *) (*#OMIT*)
		enable : BOOL;
		link : BOOL;
		eject : BOOL;
		update : BOOL;
	END_STRUCT;
	zzCIFS_par_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		devName : STRING[80] := 'USBDEV1';
		parStrFull : STRING[150] := '/DEVICE=';
		handle : UDINT;
		emptyStr : STRING[80] := '';
		user : CIFSDevChkPar_typ;
	END_STRUCT;
	zzCIFS_stat_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		ready : BOOL;
		initDone : BOOL;
	END_STRUCT;
	zzUSBInternalStruct_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		step : USBDevChk_enum;
		cmd : zzUSB_cmd_typ;
		par : zzUSB_par_typ;
		stat : zzUSB_stat_typ;
		fb : zzUSB_fb_typ;
		old : zzUSB_old;
	END_STRUCT;
	zzUSB_cmd_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		link : BOOL;
		autoLink : BOOL;
	END_STRUCT;
	zzUSB_fb_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		devLink : DevLink;
		devUnlink : DevUnlink;
		UsbNodeListGet : UsbNodeListGet;
		UsbNodeGet : UsbNodeGet;
		autoLink : TON;
		errorReset : TON;
		nodeSearchTimeout : TON;
		DevMemInfo : DevMemInfo;
	END_STRUCT;
	zzUSB_old : 	STRUCT  (* *) (* *) (*#OMIT*)
		enable : BOOL;
		link : BOOL;
		eject : BOOL;
		update : BOOL;
	END_STRUCT;
	zzUSB_par_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		devName : STRING[80] := 'USBDEV1';
		parStrFull : STRING[150] := '/DEVICE=';
		nodeList : ARRAY[0..3]OF UDINT;
		nodeInfo : usbNode_typ;
		handle : UDINT;
		emptyStr : STRING[80] := '';
		user : USBDevChkPar_typ;
		node : USINT;
	END_STRUCT;
	zzUSB_stat_typ : 	STRUCT  (* *) (* *) (*#OMIT*)
		ready : BOOL;
		initDone : BOOL;
	END_STRUCT;
END_TYPE
