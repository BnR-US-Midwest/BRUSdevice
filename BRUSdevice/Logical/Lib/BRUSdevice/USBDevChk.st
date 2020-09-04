
(* Checks for and links to USB devices at runtime and creates a file device. *)
FUNCTION_BLOCK USBDevChk
	
	// Initialization routine
	IF Enable AND NOT(IS.stat.initDone) THEN
		// check parameters
		IF Parameters.AutoLink AND Parameters.AutoLinkInterval < T#2s THEN
			Info.Status	:= 'WARN: AutoLinkInvterval must be >2s';
			Info.StatusID	:= usbdevERR_AUTOLINK_PARAM;
		ELSE
			// load in device pars
			IF brsstrcmp(ADR(Parameters.DeviceName), ADR(IS.par.emptyStr)) = 0 THEN
				IS.par.devName	:= 'USBDEV1';
			ELSE
				IS.par.devName	:= Parameters.DeviceName;
			END_IF
			IS.par.user.AutoLinkInterval	:= Parameters.AutoLinkInterval;
			IS.par.user.AutoLink			:= Parameters.AutoLink;
			// go to run mode
			IS.stat.initDone	:= TRUE;
			Info.Status			:= 'Init OK';
			Info.StatusID		:= usbdevERR_OK;
			IS.par.node			:= 0;
		END_IF
	// Cyclic operation
	ELSIF IS.stat.initDone THEN
		
		// read in commands (edge sensitive)
		IS.cmd.link		:= Link AND NOT IS.old.link;
		IS.cmd.autoLink	:= IS.fb.autoLink.Q;

		// state machine
		CASE IS.step OF
			USB_IDLE:
				IF IS.cmd.link OR IS.cmd.autoLink THEN
					IS.step				:= USB_NODE_LIST;
					Info.StatusID		:= usbdevERR_OK;
					IS.par.node			:= 0;
					Info.StatusID		:= 0;
					IS.cmd.link			:= FALSE;
					IS.cmd.autoLink		:= FALSE;
				ELSIF (Eject OR NOT(Enable)) AND Ready THEN
					Info.Status			:= 'USB Ejecting...';
					IS.step				:= USB_UNLINK;
				ELSIF NOT Enable THEN
					IS.stat.initDone	:= FALSE;
				END_IF
			
			USB_NODE_LIST:
				IS.fb.UsbNodeListGet.enable						:= TRUE;
				IS.fb.UsbNodeListGet.bufferSize					:= SIZEOF(IS.par.nodeList);
				IS.fb.UsbNodeListGet.filterInterfaceClass		:= asusb_CLASS_MASS_STORAGE;
				IS.fb.UsbNodeListGet.filterInterfaceSubClass	:= 0;
				IS.fb.UsbNodeListGet.pBuffer					:= ADR(IS.par.nodeList);
			
				IF IS.fb.UsbNodeListGet.listNodes > 0 AND IS.fb.UsbNodeListGet.status = ERR_OK THEN
					IS.step						:= USB_NODE_GET;
					IS.fb.UsbNodeListGet.enable	:= FALSE;
				ELSIF IS.fb.nodeSearchTimeout.Q OR IS.fb.UsbNodeListGet.status = asusbERR_USB_NOTFOUND THEN
					IS.step						:= USB_IDLE;
					IS.fb.UsbNodeListGet.enable	:= FALSE;
					Info.Status					:= 'WARN: No USB device found!';
					Info.StatusID				:= usbdevERR_NO_USB_FOUND;
				ELSIF IS.fb.UsbNodeListGet.status = ERR_FUB_ENABLE_FALSE OR IS.fb.UsbNodeListGet.status = ERR_FUB_BUSY THEN
					// do nothing
				ELSE
					IS.step						:= USB_ERROR;
					IS.fb.UsbNodeListGet.enable	:= FALSE;
				END_IF
			
			USB_NODE_GET:
				IS.fb.UsbNodeGet.enable		:= TRUE;
				IS.fb.UsbNodeGet.bufferSize	:= SIZEOF(IS.par.nodeInfo);
				IS.fb.UsbNodeGet.nodeId		:= IS.par.nodeList[IS.par.node];
				IS.fb.UsbNodeGet.pBuffer	:= ADR(IS.par.nodeInfo);
			
				IF IS.fb.UsbNodeGet.status = ERR_OK THEN
					IS.step					:= USB_LINK;
					IS.fb.UsbNodeGet.enable	:= FALSE;
					
					IS.par.parStrFull		:= '/DEVICE=';
					brsstrcat(ADR(IS.par.parStrFull), ADR(IS.par.nodeInfo.ifName));
				ELSIF IS.fb.nodeSearchTimeout.Q OR IS.fb.UsbNodeListGet.status = asusbERR_USB_NOTFOUND THEN
					IS.step					:= USB_IDLE;
					IS.fb.UsbNodeGet.enable	:= FALSE;
					Info.Status				:= 'WARN: No USB device found!';
					Info.StatusID			:= usbdevERR_NO_USB_FOUND;
				ELSIF IS.fb.UsbNodeGet.status = ERR_FUB_ENABLE_FALSE OR IS.fb.UsbNodeGet.status = ERR_FUB_BUSY THEN
					// do nothing
				ELSE
					IS.step					:= USB_ERROR;
					IS.fb.UsbNodeGet.enable	:= FALSE;
				END_IF
			
			USB_LINK:			
				IS.fb.devLink.pParam	:= ADR(IS.par.parStrFull); // string of device pars (see help)
				IS.fb.devLink.pDevice	:= ADR(IS.par.devName); // name of the created device
				IS.fb.devLink.enable	:= TRUE;
			
				IF IS.fb.devLink.status = ERR_FUB_BUSY OR IS.fb.devLink.status = ERR_FUB_ENABLE_FALSE THEN
					// do nothing, stay in state
				ELSIF IS.fb.devLink.status = ERR_OK THEN
					// success, move to grab mem info
					IS.step					:= USB_MEMINFO;
					IS.par.handle			:= IS.fb.devLink.handle;
					IS.fb.devLink.enable	:= FALSE;
					Info.Status				:= 'USB Device Linked';
				ELSE
					Info.Status				:= 'ERR: Error connecting to device!';
					IS.step					:= USB_ERROR;
					IS.fb.devLink.enable	:= FALSE;
				END_IF
			
			USB_MEMINFO:
				IF IS.fb.DevMemInfo.status = ERR_OK THEN
					IS.step				:= USB_LINKED;
					Info.DiskSizeBytes	:= IS.fb.DevMemInfo.memsize;
					Info.FreeMemBytes	:= IS.fb.DevMemInfo.freemem;
					
					IF IS.fb.DevMemInfo.freemem = 0 THEN
						IS.par.node	:= IS.par.node + 1;
						IS.step		:= USB_UNLINK;
					END_IF					
				ELSIF IS.fb.DevMemInfo.status <> ERR_FUB_BUSY AND IS.fb.DevMemInfo.status <> ERR_FUB_ENABLE_FALSE THEN
					IS.step			:= USB_ERROR;
					Info.Status		:= 'ERR: Error reading device memory information';
				END_IF
			
			USB_LINKED:
				// wait to be unlinked
				IF Eject OR (NOT Enable) THEN
					IS.step	:= USB_UNLINK;
				END_IF
			
			USB_UNLINK:
				IS.fb.devUnlink.handle	:= IS.par.handle;
				IS.fb.devUnlink.enable	:= TRUE;
			
				IF IS.fb.devUnlink.status = ERR_FUB_BUSY OR IS.fb.devUnlink.status = ERR_FUB_ENABLE_FALSE THEN
					// do nothing, stay in state
				ELSIF IS.fb.devUnlink.status = ERR_OK THEN
					// success, move on
					IF NOT Eject AND IS.par.node < usbdevMAX_NODES AND IS.par.nodeList[IS.par.node] <> 0 THEN
						IS.step				:= USB_NODE_GET;
					ELSIF IS.par.node >= usbdevMAX_NODES OR IS.par.nodeList[IS.par.node] = 0 THEN
						IS.step				:= USB_IDLE;
						Info.Status			:= 'No suitable USB detected!';
						Info.StatusID		:= usbdevERR_NO_USB_FOUND;
						IS.par.node			:= 0;
					ELSE
						IS.step				:= USB_IDLE;
						Info.Status			:= 'USB Device Ejected';
					END_IF
					IS.fb.devUnlink.enable	:= FALSE;
					Info.DiskSizeBytes		:= 0;
					Info.FreeMemBytes		:= 0;
					
					// de-init the function block if disabled
					IF NOT Enable THEN
						IS.stat.initDone	:= FALSE;
					END_IF
				ELSE
					Info.Status				:= 'ERR: Error unlinking device!';
					IS.step					:= USB_ERROR;
					IS.fb.devUnlink.enable	:= FALSE;
				END_IF
			
			USB_ERROR:			
				IF ErrorReset THEN
					IS.fb.devLink.enable		:= FALSE;
					IS.fb.devUnlink.enable		:= FALSE;
					IS.fb.UsbNodeGet.enable		:= FALSE;
					IS.fb.UsbNodeListGet.enable	:= FALSE;
					IS.step						:= USB_IDLE;
					Info.Status					:= 'Reset OK';
					IS.par.node					:= 0;
					Info.StatusID				:= usbdevERR_OK;
				ELSIF NOT Enable THEN
					IS.stat.initDone			:= FALSE;
				END_IF
	
		END_CASE;
		
		// call device related functions
		IS.fb.devLink();
		IS.fb.devUnlink();
		IS.fb.UsbNodeGet();
		IS.fb.UsbNodeListGet();
		
		// call timers
		IS.fb.autoLink(IN := IS.par.user.AutoLink  AND IS.step = USB_IDLE AND NOT(Eject) AND Enable, PT := IS.par.user.AutoLinkInterval);
		IS.fb.nodeSearchTimeout(IN := ((IS.step = USB_NODE_GET OR IS.step = USB_NODE_LIST) AND Enable), PT := T#5s);
		
		// check for update commands
		IF Update AND NOT IS.old.update THEN
			IS.stat.initDone		:= FALSE;
			
			// if a device is already connected, the Update command should also update the amount of available memory
			IF IS.step = USB_LINKED THEN
				IS.step	:= USB_MEMINFO;
			END_IF		
		END_IF
		
		// gather information about the device when requested
		IS.fb.DevMemInfo.enable		:= (IS.step = USB_MEMINFO);
		IS.fb.DevMemInfo.pDevice	:= ADR(IS.par.devName);
		IS.fb.DevMemInfo();
	END_IF

	// FUNCTION BLOCK DISABLED AND EJECTED
	IF NOT(Enable) AND NOT(IS.stat.initDone) THEN
		IS.step				:= USB_IDLE;
		Info.State			:= IS.step;
		Error				:= FALSE;
		IS.par.node			:= 0;
		Info.DiskSizeBytes	:= 0;
		Info.FreeMemBytes	:= 0;
		Info.StatusID		:= usbdevERR_OK;
		Info.Status			:= 'Function block disabled';
	END_IF
	
	// set edge detection variables
	IS.old.eject	:= Eject;
	IS.old.link		:= Link;
	IS.old.enable	:= Enable;
	IS.old.update	:= Update;
	
	// set function outputs
	Info.State		:= IS.step;
	Active			:= IS.stat.initDone;
	Error			:= IS.step = USB_ERROR;
	Ready			:= IS.step = USB_LINKED;
	
END_FUNCTION_BLOCK
