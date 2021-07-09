
PROGRAM _INIT

	//Declare all device parameters (You can use a variable of structure type 'CIFSDevChkPar_typ'
	
	//Declare whatever name you want
	CIFSDevChk_0.Parameters.DeviceName := 'jack';
	
	//State the domain name of the device (For my computer it was as shown below
	CIFSDevChk_0.Parameters.ServerDomain := 'BRGLOBAL';
	
	//Ip address of the ethernet port / IP address of the connection
	CIFSDevChk_0.Parameters.ServerIP := '192.168.145.88';
	
	//Password of the other device (I used my computer password
	CIFSDevChk_0.Parameters.ServerPw := 'Jacflo242424!';
	
	//Name of the user
	CIFSDevChk_0.Parameters.ServerUser := 'floodj';
	
	//Name of the folder / location
	CIFSDevChk_0.Parameters.ShareName := 'CIFSdevicetest';
	
END_PROGRAM

PROGRAM _CYCLIC
	//Enable the function block
	CIFSDevChk_0.Enable 	:= enableBOOL;
	
	//Enable the attempt to link
	CIFSDevChk_0.Link 		:= linkBOOL;
	
	//Eject the device
	CIFSDevChk_0.Eject 		:= ejectBOOL;
	
	//Reset a function block error
	CIFSDevChk_0.ErrorReset	:= resetBOOL;
	
	//Update the parameters
	CIFSDevChk_0.Update 	:= updateBOOL;
	
	
	
	//    OUTPUTS      //
	IF CIFSDevChk_0.Active THEN
		
		//Function block initialized correctly
	
	END_IF
	
	
	IF CIFSDevChk_0.Ready THEN
		
		//Function block has connected to a device
		
	END_IF
	
	//Info and error contain information about the function block and if it has an error respectively
	
	
	//Execute function block
	CIFSDevChk_0();
	
	
END_PROGRAM

PROGRAM _EXIT
	
	CIFSDevChk_0(Enable := FALSE);
	 
END_PROGRAM

