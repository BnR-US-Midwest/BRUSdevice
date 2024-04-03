
(* Links to CIFS devices at runtime and creates a file device. *)
FUNCTION_BLOCK CIFSDevChk
	
	// Initialization routine
	IF Enable AND NOT(IS.stat.initDone) THEN
		// check parameters
		IF FALSE THEN
			(*possible parameter checking*)
		ELSE
			// make par string
			IS.par.parStrFull := '/SIP=';
			brsstrcat(ADR(IS.par.parStrFull), ADR(Parameters.ServerIP));
					
			brsstrcat(ADR(IS.par.parStrFull), ADR(' /PROTOCOL=cifs'));
					
			IF brsstrcmp(ADR(Parameters.ServerDomain), ADR('')) = 0 THEN
				// Do not add the domain tag
			ELSE
				brsstrcat(ADR(IS.par.parStrFull), ADR(' /DOMAIN='));
				brsstrcat(ADR(IS.par.parStrFull), ADR(Parameters.ServerDomain));
			END_IF
					
			brsstrcat(ADR(IS.par.parStrFull), ADR(' /SHARE='));
			brsstrcat(ADR(IS.par.parStrFull), ADR(Parameters.ShareName));
	
			brsstrcat(ADR(IS.par.parStrFull), ADR(' /USER='));
			brsstrcat(ADR(IS.par.parStrFull), ADR(Parameters.ServerUser));
					
			brsstrcat(ADR(IS.par.parStrFull), ADR(' /PASSWORD='));
			brsstrcat(ADR(IS.par.parStrFull), ADR(Parameters.ServerPw));

			// load in device pars
			IF brsstrcmp(ADR(Parameters.DeviceName), ADR(IS.par.emptyStr)) = 0 THEN
				IS.par.devName	:= 'CIFSDEV1';
			ELSE
				IS.par.devName	:= Parameters.DeviceName;
			END_IF

			// go to run mode
			IS.stat.initDone	:= TRUE;
			Info.Status			:= 'Init OK';
			Info.StatusID		:= cifsdevERR_OK;
		END_IF
	// Cyclic operation
	ELSIF IS.stat.initDone THEN
		
		// read in commands (edge sensitive)
		IS.cmd.link := Link AND NOT(IS.old.link);

		// state machine
		CASE IS.step OF
			CIFS_IDLE:
				IF IS.cmd.link THEN
					IS.step				:= CIFS_LINK;
					Info.StatusID		:= cifsdevERR_OK;
					Info.StatusID		:= 0;
					IS.cmd.link			:= FALSE;
				ELSIF (Eject OR NOT(Enable)) AND Ready THEN
					Info.Status			:= 'Disconnecting...';
					IS.step				:= CIFS_UNLINK;
				ELSIF NOT Enable THEN
					IS.stat.initDone	:= FALSE;
				END_IF
			
			CIFS_LINK:			
				IS.fb.devLink.pParam	:= ADR(IS.par.parStrFull); // string of device pars (see help)
				IS.fb.devLink.pDevice	:= ADR(IS.par.devName); // name of the created device
				IS.fb.devLink.enable	:= TRUE;
			
				IF Eject THEN
					Info.Status				:= 'ERR: Connection attempt aborted!';
					IS.step					:= CIFS_IDLE;
					IS.fb.devLink.enable	:= FALSE;
				ELSIF IS.fb.devLink.status = ERR_FUB_BUSY OR IS.fb.devLink.status = ERR_FUB_ENABLE_FALSE THEN
					// do nothing, stay in state
				ELSIF IS.fb.devLink.status = ERR_OK THEN
					// success, move to grab mem info
					IS.step					:= CIFS_LINKED;
					IS.par.handle			:= IS.fb.devLink.handle;
					IS.fb.devLink.enable	:= FALSE;
					Info.Status				:= 'CIFS Share Connected';

				ELSE
					Info.fileIOStatus		:= FileIoGetSysError();
					Info.Status				:= 'ERR: Error connecting to device!';
					IS.step					:= CIFS_ERROR;
					IS.fb.devLink.enable	:= FALSE;
				END_IF
			
			CIFS_LINKED:
				// wait to be unlinked
				IF Eject OR (NOT Enable) THEN
					IS.step	:= CIFS_UNLINK;
				END_IF
			
			CIFS_UNLINK:
				IS.fb.devUnlink.handle	:= IS.par.handle;
				IS.fb.devUnlink.enable	:= TRUE;
			
				IF IS.fb.devUnlink.status = ERR_FUB_BUSY OR IS.fb.devUnlink.status = ERR_FUB_ENABLE_FALSE THEN
					// do nothing, stay in state
				ELSIF IS.fb.devUnlink.status = ERR_OK THEN
					// success, move on
					IS.step				:= CIFS_IDLE;
					Info.Status			:= 'Disconnected';
					
					IS.fb.devUnlink.enable	:= FALSE;
					
					// de-init the function block if disabled
					IF NOT Enable THEN
						IS.stat.initDone	:= FALSE;
					END_IF
				ELSE
					Info.Status				:= 'ERR: Error in disconnecting!';
					IS.step					:= CIFS_ERROR;
					IS.fb.devUnlink.enable	:= FALSE;
				END_IF
			
			CIFS_ERROR:			
				IF ErrorReset THEN
					IS.fb.devLink.enable		:= FALSE;
					IS.fb.devUnlink.enable		:= FALSE;
					IS.step						:= CIFS_IDLE;
					Info.Status					:= 'Reset OK';
					Info.StatusID				:= cifsdevERR_OK;
				ELSIF NOT Enable THEN
					IS.stat.initDone			:= FALSE;
				END_IF
	
		END_CASE;
		
		// call device related functions
		IS.fb.devLink();
		IS.fb.devUnlink();
				
		// check for update commands
		IF Update AND NOT IS.old.update THEN
			IS.stat.initDone		:= FALSE;
		END_IF
	END_IF
	
	// FUNCTION BLOCK DISABLED AND EJECTED
	IF NOT(Enable) AND NOT(IS.stat.initDone) THEN
		IS.step				:= CIFS_IDLE;
		Info.State			:= IS.step;
		Error				:= FALSE;
		Info.StatusID		:= cifsdevERR_OK;
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
	Error			:= IS.step = CIFS_ERROR;
	Ready			:= IS.step = CIFS_LINKED;
	
END_FUNCTION_BLOCK
