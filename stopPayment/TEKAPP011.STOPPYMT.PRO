[*****************************************************************************
 IMPORTANT NOTICE

 By downloading, installing, or otherwise using any tek-apps, software, documentation, or 
 other materials made available by TekChoice, LLC, through this repository, you acknowledge
 that you have read, understand, and agree to be bound by the End User License Agreement (the "EULA")
 included in these downloaded files as EULA.txt and made available at www.tekchoice.com/EULA.

 SPECFILENAME: TEKAPP011.STOPPYMT.PRO
 VERSION: 001
 COPYRIGHT: TekChoice, LLC 2021 © 

 Version:       001   

 Sections:      1. TekApp Procedures

 Programmed:    TekChoice LLC

 Modified:      05.15.21 Original Source



********************************************************************************]

[ **********************************************************************
                          1. Tek-App Procedures

 *********************************************************************** ]

PROCEDURE TekProCreateStopReasonOption
 FOR I=1 TO StopReasonOptions
  DO
   IF HtmlVars(HtmlTxtFieldName,HtmlFieldValue)=StopReasonOption(I) THEN 
     HTMLVIEWLINE("<option value='" +StopReasonOption(I)+ "' Selected >")
   ELSE
     HTMLVIEWLINE("<option value='" +StopReasonOption(I)+ "' >")
   HTMLVIEWLINE(StopReasonOption(I)+ "</option>")    
  END
END[TekProCreateStopReasonOption]

PROCEDURE TekProCreateDebitCreditOption
 FOR I=1 TO DebitCreditOptions
  DO
   IF HtmlVars(HtmlTxtFieldName,HtmlFieldValue)=DebitCreditOption(I) THEN 
     HTMLVIEWLINE("<option value='" +DebitCreditOption(I)+ "' Selected >")
   ELSE
     HTMLVIEWLINE("<option value='" +DebitCreditOption(I)+ "' >")
   HTMLVIEWLINE(DebitCreditOption(I)+ "</option>")    
  END
END[TekProCreateDebitCreditOption]

PROCEDURE TekProValDraft
 TEMPNUM=0
 IF ValidateShareHoldProcessed=TRUE THEN
  DO
   FOR EACH SHARE WITH SHARE:ID=SEGMENT(HtmlVars(StopShareID,HtmlFieldValue),2,LENGTH(HtmlVars(StopShareID,HtmlFieldValue)))
    DO
      IF HtmlVars(StopCheckNumberEnd,HtmlFieldValue)="" THEN
       DO
         FOR EACH SHARE TRANSACTION WITH SHARE TRANSACTION:DRAFTNUMBER=HtmlVars(StopCheckNumber,HtmlFieldValue)
          DO
           POPUPMESSAGE(0,"Check Number: " +SHARE TRANSACTION:DRAFTNUMBER+ " has been processed")
           WebSubmitBtn=REFRESHFORM 
          END
         FOR EACH SHARE HOLD WITH (SHARE HOLD:TYPE=VALUE(StopDraft) OR SHARE HOLD:TYPE=VALUE(StopDraftVerbal)) AND 
                                   SHARE HOLD:REFERENCE1=HtmlVars(StopCheckNumber,HtmlFieldValue) AND
                                   WebSubmitBtn<>REFRESHFORM
          DO
           POPUPMESSAGE(0,"Check Number: " +SHARE HOLD:REFERENCE1+ " has been processed")
           WebSubmitBtn=REFRESHFORM 
          END
       END
      ELSE
       DO
         FOR EACH SHARE TRANSACTION WITH VALUE(SHARE TRANSACTION:DRAFTNUMBER)>=VALUE(HtmlVars(StopCheckNumber,HtmlFieldValue)) AND
                                         VALUE(SHARE TRANSACTION:DRAFTNUMBER)<=VALUE(HtmlVars(StopCheckNumberEnd,HtmlFieldValue))
          DO
           IF TEMPNUM<3 THEN
            DO
             POPUPMESSAGE(0,"Check Number: " +SHARE TRANSACTION:DRAFTNUMBER+ " has been processed")
             TEMPNUM=TEMPNUM+1
            END
           WebSubmitBtn=REFRESHFORM 
          END
         FOR EACH SHARE HOLD WITH VALUE(SHARE HOLD:REFERENCE1)>=VALUE(HtmlVars(StopCheckNumber,HtmlFieldValue)) AND
                                  VALUE(SHARE HOLD:REFERENCE1)<=VALUE(HtmlVars(StopCheckNumberEnd,HtmlFieldValue)) AND
                                  (SHARE HOLD:TYPE=VALUE(StopDraft) OR SHARE HOLD:TYPE=VALUE(StopDraftVerbal)) AND WebSubmitBtn<>REFRESHFORM
          DO
           IF TEMPNUM<3 THEN
            DO
             POPUPMESSAGE(0,"Check Number: " +SHARE HOLD:REFERENCE1+ " has been processed")
             TEMPNUM=TEMPNUM+1
            END
           WebSubmitBtn=REFRESHFORM 
          END
         FOR EACH SHARE HOLD WITH VALUE(SHARE HOLD:REFERENCE2)>=VALUE(HtmlVars(StopCheckNumber,HtmlFieldValue)) AND
                                  VALUE(SHARE HOLD:REFERENCE2)<=VALUE(HtmlVars(StopCheckNumberEnd,HtmlFieldValue)) AND
                                  (SHARE HOLD:TYPE=VALUE(StopDraft) OR SHARE HOLD:TYPE=VALUE(StopDraftVerbal)) 
          DO
           IF TEMPNUM<3 THEN
            DO
             POPUPMESSAGE(0,"Check Number: " +SHARE HOLD:REFERENCE2+ " has been processed")
             TEMPNUM=TEMPNUM+1
            END
           WebSubmitBtn=REFRESHFORM 
          END
       END
    END
 END[IF]
END[TekProValDraft]

PROCEDURE ESCAPESINGLEQUOTE
 IF CHARACTERSEARCH(TEMPTEXT,"'")>0 THEN
  DO
    TEMPTEXT=SEGMENT(TEMPTEXT,0,CHARACTERSEARCH(TEMPTEXT,"'")-1)+"\"+SEGMENT(TEMPTEXT,CHARACTERSEARCH(TEMPTEXT,"'"),LENGTH(TEMPTEXT))
  END
END

PROCEDURE PrintTransactionHeader
 PRINTHEADER=FALSE
 HTMLVIEWLINE("<tr>")
 HTMLVIEWLINE("<td class='StepBorderOn'><b>Share ID</b></td>")
 HTMLVIEWLINE("<td class='StepBorderOn'><b>Post Date</b></td>")
 HTMLVIEWLINE("<td class='StepBorderOn MoneyCss'><b>Amount</b></td>")
 HTMLVIEWLINE("<td class='StepBorderOn' align='left' ><b>Payee</b></td>")
 HTMLVIEWLINE("<td class='StepBorderOn'>&nbsp;</td>")
 HTMLVIEWLINE("</tr>")
END[PrintTransactionHeader]

PROCEDURE GetStopPymtHistoryCounter
 StopPymtHistoryCounter=0
 FOR EACH SHARE WITH SHARE:CLOSEDATE='--/--/--'
  DO
    FOR EACH SHARE HOLD WITH (SHARE HOLD:TYPE=VALUE(StopACHVerbal) AND SHARE HOLD:EXPIRATIONDATE>SYSTEMDATE)
     DO
      StopPymtHistoryCounter=StopPymtHistoryCounter+1
     END
  END
END[GetStopPymtHistoryCounter]

PROCEDURE ProcessStopPymt
 CALL TekProClearConfirmation
 IF HtmlVars(VerbalStopPymtLoc,HtmlFieldValue)<>"1" THEN 
  CALL ProcessUpdateStopPymt
 ELSE
  DO
   ConfirmationItem=0
   TEMPTEXT1=SEGMENT(HtmlVars(StopShareID,HtmlFieldValue),2,LENGTH(HtmlVars(StopShareID,HtmlFieldValue)))
   CALL TekProGetShareDescription
   ConfirmationLabel(ConfirmationItem)=ConfirmLabelTxt +TEMPTEXT1 + " " +TEMPTEXT2
   ConfirmationTxt(ConfirmationItem,0)=CreateStopPymtHoldTxt
   ConfirmationTxt(ConfirmationItem,1)=TransferStopPymtFeeTxt
   CALL CreateStopPymtHold
   IF ConfirmationCode(ConfirmationItem,ConfirmationCounter-1)=TRUE THEN CALL TransferStopPymtFee
  END
END[ProcessStopDraft]

PROCEDURE ProcessUpdateStopPymt
 [CALL loadUpdateStopPymtData]
 ConfirmationItem=0
 TEMPTEXT1=SEGMENT(HtmlVars(StopShareID,HtmlFieldValue),2,LENGTH(HtmlVars(StopShareID,HtmlFieldValue)))
 CALL TekProGetShareDescription
 ConfirmationLabel(ConfirmationItem)=ConfirmLabelTxt +TEMPTEXT1 + " " +TEMPTEXT2
 ConfirmationTxt(ConfirmationItem,0)=updateStopPymtHoldTxt
 CALL UpdateStopPymtHold
END[ProcessStopDraft]

PROCEDURE loadUpdateStopPymtData
 FOR EACH SHARE WITH SHARE:CLOSEDATE='--/--/--' 
  DO
   FOR EACH SHARE HOLD WITH (SHARE HOLD:LOCATOR=VALUE(HtmlVars(VerbalStopPymtLoc,HtmlFieldValue)))
    DO
      HtmlVars(StopShareID,HtmlFieldValue)=SHARE:ID
      HtmlVars(StopPayableTo,HtmlFieldValue)=SHARE HOLD:PAYEENAME
      HtmlVars(StopAmount,HtmlFieldValue)=FORMAT(MoneyFormat,SHARE HOLD:AMOUNT)
      HtmlVars(StopNote,HtmlFieldValue)="Converting Verbal to Signed Hold"
      HtmlVars(StopHoldType,HtmlFieldValue)=FORMAT("99",SHARE HOLD:TYPE)
    	  
      IF SHARE HOLD:TYPE=VALUE(StopACHVerbal) THEN HtmlVars(StopACHFrequency,HtmlFieldValue)=SHARE HOLD:REFERENCE4
      
      IF VALUE(HtmlVars(StopHoldType,HtmlFieldValue))=VALUE(StopDraftVerbal) THEN 
       DO
	   HtmlVars(StopHoldType,HtmlFieldValue)=StopDraft
       END
	ELSE IF VALUE(HtmlVars(StopHoldType,HtmlFieldValue))=VALUE(StopACHVerbal) THEN 
	  DO
         HtmlVars(StopHoldType,HtmlFieldValue)=StopACH
	  END
    END
  END
END[loadUpdateStopPymtData]

PROCEDURE TransferStopPymtFee
 IF MONEY(VALUE(HtmlVars(StopFee,HtmlFieldValue)))>$0.00 THEN
  DO
   TRANPERFORM WF (0,SEQ1,SEQ2,CHECKINGACCTCODE,CHECKNUMBER,ERRORTEXT)
    DO
     SET AMOUNT TO MONEY(VALUE(HtmlVars(StopFee,HtmlFieldValue)))
     SET FMACCT TO ACCOUNT:NUMBER
     SET FMID   TO SEGMENT(HtmlVars(StopShareIDFee,HtmlFieldValue),2,LENGTH(HtmlVars(StopShareIDFee,HtmlFieldValue)))
     SET FMTYPE TO "S"
     SET GLCODE TO StopGLFee
     SET COMMENT:1 TO StopPymtFeeTxt 
   END
   CALL CheckConfirmationError
  END
 ELSE
  DO
   ConfirmationTxt(ConfirmationItem,1)="Waived " +TransferStopPymtFeeTxt
   ERRORTEXT=""
   CALL CheckConfirmationError
  END 
END[TransferStopPymtFee]

PROCEDURE CreateStopPymtHold
 SPACHRecurringStop=0
 IF HtmlVars(StopPymtType,HtmlFieldValue)="1" THEN
  DO [*** STOP ACH ***]
   IF (HtmlVars(StopACHFrequency,HtmlFieldValue)="1" OR HtmlVars(StopACHFrequency,HtmlFieldValue)="4") THEN SPACHRecurringStop=1 

   IF LENGTH(HtmlVars(StopPayableTo,HtmlFieldValue)) > 16 THEN 
     HtmlVars(StopPayableTo,HtmlFieldValue)=SEGMENT(HtmlVars(StopPayableTo,HtmlFieldValue),1,16)

   IF LENGTH(HtmlVars(StopReason,HtmlFieldValue)) > 40 THEN 
     HtmlVars(StopReason,HtmlFieldValue)=SEGMENT(HtmlVars(StopReason,HtmlFieldValue),1,40)

   FMPERFORM CREATE SHARE SEGMENT(HtmlVars(StopShareID,HtmlFieldValue),2,LENGTH(HtmlVars(StopShareID,HtmlFieldValue))) HOLD LOC -1 (0,1,ERRORTEXT)
    DO
     SET TYPE TO VALUE(HtmlVars(StopHoldType,HtmlFieldValue))
     SET ACHRECURRINGSTOP TO SPACHRecurringStop
     SET EXPIRATIONDATE TO DATEVALUE(HtmlVars(StopExpDate,HtmlFieldValue))
     SET REFERENCE2 TO UPPERCASE(HtmlVars(StopACHDebitCredit,HtmlFieldValue))
     SET REFERENCE3 TO UPPERCASE(HtmlVars(StopReason,HtmlFieldValue))
     SET REFERENCE4 TO HtmlVars(StopACHFrequency,HtmlFieldValue)
     SET AMOUNT TO MONEY(VALUE(HtmlVars(StopAmount,HtmlFieldValue)))
     SET PAYEENAME TO UPPERCASE(HtmlVars(StopPayableTo,HtmlFieldValue))
    END
   CALL CheckConfirmationError
  END
 ELSE 
  DO [*** STOP DRAFT ***]
   FMPERFORM CREATE SHARE SEGMENT(HtmlVars(StopShareID,HtmlFieldValue),2,LENGTH(HtmlVars(StopShareID,HtmlFieldValue))) HOLD LOC -1 (0,1,ERRORTEXT)
    DO
     SET TYPE TO VALUE(HtmlVars(StopHoldType,HtmlFieldValue))
     SET ACHRECURRINGSTOP TO SPACHRecurringStop
     SET EXPIRATIONDATE TO DATEVALUE(HtmlVars(StopExpDate,HtmlFieldValue))
     SET REFERENCE1 TO HtmlVars(StopCheckNumber,HtmlFieldValue)
     SET REFERENCE2 TO HtmlVars(StopCheckNumberEnd,HtmlFieldValue)
     SET AMOUNT TO MONEY(VALUE(HtmlVars(StopAmount,HtmlFieldValue)))
     SET PAYEENAME TO UPPERCASE(HtmlVars(StopPayableTo,HtmlFieldValue))
     SET STOPPAYCODE TO VALUE(SEGMENT(HtmlVars(StopReason,HtmlFieldValue),1,2))
    END
   CALL CheckConfirmationError
  END
END[CreateStopPymtHold]

PROCEDURE UpdateStopPymtHold
 [POPUPMESSAGE(0,FORMAT("99/99/9999",DATEVALUE(HtmlVars(StopExpDate,HtmlFieldValue))))]
 [POPUPMESSAGE(0,HTMLVARS(STOPHOLDTYPE,HTMLFIELDVALUE))]
 FMPERFORM REVISE SHARE SEGMENT(HtmlVars(StopShareID,HtmlFieldValue),2,LENGTH(HtmlVars(StopShareID,HtmlFieldValue)))
                  HOLD LOC VALUE(HtmlVars(VerbalStopPymtLoc,HtmlFieldValue)) (0,1,ERRORTEXT)
  DO
    SET TYPE TO VALUE(HtmlVars(StopHoldType,HtmlFieldValue))
    SET EXPIRATIONDATE TO DATEVALUE(HtmlVars(StopExpDate,HtmlFieldValue))
  END
 CALL CheckConfirmationError
END[UpdateStopPymtHold]

PROCEDURE TekProGetNameInAcctLevel
 NameInAcctLevel=FALSE
 FOR EACH NAME WITH (NAME:TYPE=0 OR NAME:TYPE=1) AND NAME:EXPIRATIONDATE='--/--/--' AND
                    FORMAT("9999999999",NAME:LOCATOR)=HtmlVars(RequesterLocator,HtmlFieldValue)
  DO
   NameInAcctLevel=TRUE
  END
END[TekProGetNameInAcctLevel]

PROCEDURE getRequesterData
 HtmlVars(RequesterLongName,HtmlFieldValue)=RequesterObj(ObjNameLongName)
 HtmlVars(RequesterStreet,HtmlFieldValue)=RequesterObj(ObjNameStreet)
 HtmlVars(RequesterExtraAddress,HtmlFieldValue)=RequesterObj(ObjNameExtraAddress)
 HtmlVars(RequesterCity,HtmlFieldValue)=RequesterObj(ObjNameCity)
 HtmlVars(RequesterState,HtmlFieldValue)=RequesterObj(ObjNameState)
 HtmlVars(RequesterZip,HtmlFieldValue)=RequesterObj(ObjNameZipCode)
 HtmlVars(RequesterSSN,HtmlFieldValue)=RequesterObj(ObjNameSSN)
 HtmlVars(RequesterPhone,HtmlFieldValue)=RequesterObj(ObjNameMobilePhone)
END[getRequesterData]

PROCEDURE DocuSignCustomFields 

 [*** Envelope ***]
 HTMLVIEWLINE("<input type='hidden' name='DocuSignEnvelopeSubject' value='Envelope Subject' />")  

 [*** pdf to use ***]
 HTMLVIEWLINE("<input type='hidden' name='DocuDocuments' value='STOPPYMT' />")

 [*** custom fields ***]
 [HTMLVIEWLINE("<input type='hidden' name='AccountNumber' value='"+ACCOUNT:NUMBER+"' />")]
 HTMLVIEWLINE("<input type='hidden' name='CheckNumbers' ")
 IF HtmlVars(StopCheckNumberEnd,HtmlFieldValue)<>"" then
  HTMLVIEWLINE("value='"+HtmlVars(StopCheckNumber,HtmlFieldValue)+"-"+HtmlVars(StopCheckNumberEnd,HtmlFieldValue)+"'")
 ELSE
 HTMLVIEWLINE("value='"+HtmlVars(StopCheckNumber,HtmlFieldValue)+"'")
 HTMLVIEWLINE("/>")
 HTMLVIEWLINE("<input type='hidden' name='ShareID' value='"+HtmlVars(StopShareId,HtmlFieldValue)+"' />")
 HTMLVIEWLINE("<input type='hidden' name='OriginalcoName' value='"+HtmlVars(StopPayableTo,HtmlFieldValue)+"' />")
 
 IF HtmlVars(StopAmount,HtmlFieldValue)<>"$0.00" THEN
  DO
   HTMLVIEWLINE("<input type='hidden' name='TransAmount' value='"+HtmlVars(StopAmount,HtmlFieldValue)+"' />")
   HTMLVIEWLINE("<input type='hidden' name='aa' value='' />")
  END
 ELSE
  DO
   HTMLVIEWLINE("<input type='hidden' name='TransAmount' value='' />")
   HTMLVIEWLINE("<input type='hidden' name='aa' value='X' />")
  END

 IF UPPERCASE(HtmlVars(StopACHFrequency,HtmlFieldValue))="1" THEN
  DO
    HTMLVIEWLINE("<input type='hidden' name='SPa' value='X' />")
    HTMLVIEWLINE("<input type='hidden' name='SPb' value='_' />")
    HTMLVIEWLINE("<input type='hidden' name='SPc' value='_' />")
  END
 ELSE IF UPPERCASE(HtmlVars(StopACHFrequency,HtmlFieldValue))="2" THEN
  DO
    HTMLVIEWLINE("<input type='hidden' name='SPa' value='_' />")
    HTMLVIEWLINE("<input type='hidden' name='SPb' value='X' />")
    HTMLVIEWLINE("<input type='hidden' name='SPc' value='_' />")
  END
 ELSE IF UPPERCASE(HtmlVars(StopACHFrequency,HtmlFieldValue))="3" THEN
  DO
    HTMLVIEWLINE("<input type='hidden' name='SPa' value='_' />")
    HTMLVIEWLINE("<input type='hidden' name='SPb' value='_' />")
    HTMLVIEWLINE("<input type='hidden' name='SPc' value='X' />")
  END
END[DocuSignCustomFields]
