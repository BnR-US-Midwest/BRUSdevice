
PROGRAM _INIT

	//Declare all device parameters
	
	//Sets whether you want the function block to search for the link automatically by intervals
	USBDevChk_0.Parameters.AutoLink := TRUE;
	
	//Interval the autolink checks in (Must be larger than 2 sec
	USBDevChk_0.Parameters.AutoLinkInterval := T#3s;
	
	//Name of the device (Up the the user)
	USBDevChk_0.Parameters.DeviceName := 'jacksUSB';

END_PROGRAM

PROGRAM _CYCLIC
	//Enable the function block

	USBDevChk_0.Enable 		:= enableBOOL;
	
	//Enable the attempt to link
	USBDevChk_0.Link 		:= linkBOOL;
	
	//Eject the device
	USBDevChk_0.Eject 		:= ejectBOOL;
	
	//Reset a function block error
	USBDevChk_0.ErrorReset	:= resetBOOL;
	
	//Update the parameters
	USBDevChk_0.Update 		:= updateBOOL;
	
	
	
	//    OUTPUTS      //
	IF USBDevChk_0.Active THEN
		
		//Function block initialized correctly
	
	END_IF
	
	
	IF USBDevChk_0.Ready THEN
		
		//Function block has connected to a device
		
	END_IF
	
	//Info and error contain information about the function block and if it has an error respectively
	
	
	//Execute function block
	USBDevChk_0();
	
	
END_PROGRAM

PROGRAM _EXIT
	
	USBDevChk_0(Enable := FALSE);
	 
END_PROGRAM

