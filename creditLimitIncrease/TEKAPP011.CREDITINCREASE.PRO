[*****************************************************************************
 IMPORTANT NOTICE

 By downloading, installing, or otherwise using any tek-apps, software, documentation, or 
 other materials made available by TekChoice, LLC, through this repository, you acknowledge
 that you have read, understand, and agree to be bound by the End User License Agreement (the "EULA")
 included in these downloaded files as EULA.txt and made available at www.tekchoice.com/EULA.

 SPECFILENAME: TEKAPP011.CREDITINCREASE.PRO
 VERSION: 001
 COPYRIGHT: TekChoice, LLC 2020 © 

 Sections:      1. TekApp Procedures

                2. TekApp BASE Procedures

 Programmed:    TekChoice LLC

 Modified:      06.24.20 Original Source


********************************************************************************]

[ **********************************************************************
                          1. Micro-App Procedures

 *********************************************************************** ]

PROCEDURE readELAJson
 FILEOPEN("DATA","PS.CONFIG.ELAUSERS.json","READ",FNUMBER,FERROR)
 FILEREADLINE(FNUMBER,TXTLINE,FERROR)
 NUMOFCOLUMNS=5
 CURRENTR0W=0
 TEMPFLAG=FALSE
 FOUNDTABLE=FALSE
 WHILE FERROR="" AND TEMPFLAG=FALSE
  DO
   IF CHARACTERSEARCH(TXTLINE,"TableDescription") > 0 AND CHARACTERSEARCH(TXTLINE,"ELA USERS")>0 THEN FOUNDTABLE=TRUE

   IF FOUNDTABLE=TRUE THEN 
    DO
     POS=CHARACTERSEARCH(TXTLINE,":")
     IF POS > 0 THEN
      DO
        IF VALUE(SEGMENT(TXTLINE,0,POS-1))>0 THEN
        DO
         [POPUPMESSAGE(0,SEGMENT(TXTLINE,POS+1,LENGTH(TXTLINE)))]
         TABLEDATA(CURRENTR0W,VALUE(SEGMENT(TXTLINE,0,POS-1)))=SEGMENT(TXTLINE,POS+1,LENGTH(TXTLINE))
         IF VALUE(SEGMENT(TXTLINE,0,POS-1))=NUMOFCOLUMNS THEN CURRENTR0W=CURRENTR0W+1
        END
      END
     IF CHARACTERSEARCH(TXTLINE,"TableDescription") > 0 AND CHARACTERSEARCH(TXTLINE,"ELA USERS")=0 THEN TEMPFLAG=TRUE
    END
   FILEREADLINE(FNUMBER,TXTLINE,FERROR)
  END
 FILECLOSE(FNUMBER,FERROR)
END[readELAJson]

PROCEDURE validateAccess
 TEMPFLAG=FALSE
 
 FOR J=1 TO CURRENTR0W-1
  DO
    IF FORMAT("9999",VALUE(TABLEDATA(J,1)))=FORMAT("9999",SYSUSERNUMBER) AND (FORMAT("9",VALUE(TABLEDATA(J,5)))="1" OR FORMAT("9",VALUE(TABLEDATA(J,5)))="2") [APPROVAL TIER] THEN TEMPFLAG=TRUE
  END
 IF TEMPFLAG=FALSE THEN
  DO
    POPUPMESSAGE(0,"Access Denied")
    TERMINATE
  END
END[validateUser]

PROCEDURE TekSetNameHtmlVars
 TEMPTEXT=RequesterObj(ObjNameLongName)
 CALL capitalizeFirstLetter
 HtmlVars(HtmlLongName,HtmlFieldValue)=TEMPTEXT
 HtmlVars(HtmlStreet,HtmlFieldValue)=RequesterObj(ObjNameStreet)
 HtmlVars(HtmlExtraAddress,HtmlFieldValue)=RequesterObj(ObjNameExtraAddress)
 HtmlVars(HtmlCity,HtmlFieldValue)=RequesterObj(ObjNameCity)
 HtmlVars(HtmlState,HtmlFieldValue)=RequesterObj(ObjNameState)
 HtmlVars(HtmlZipCode,HtmlFieldValue)=RequesterObj(ObjNameZipCode)
 HtmlVars(HtmlFirst,HtmlFieldValue)=RequesterObj(ObjNameFirst)
 HtmlVars(HtmlLast,HtmlFieldValue)=RequesterObj(ObjNameLast)
 HtmlVars(HtmlMiddle,HtmlFieldValue)=RequesterObj(ObjNameMiddle)
 HtmlVars(HtmlMobilePhone,HtmlFieldValue)=RequesterObj(ObjNameMobilePhone)
 HtmlVars(HtmlEmail,HtmlFieldValue)=RequesterObj(ObjNameEmail)
 HtmlVars(HtmlNameLocator,HtmlFieldValue)=RequesterObj(ObjNameLocator)
 HtmlVars(HtmlNameLevel,HtmlFieldValue)=RequesterObj(ObjNameLevel)
END[TekSetNameHtmlVars]

PROCEDURE getCreditCardSel
 TEMPFLAG=FALSE
 FOR EACH CARD WITH ((CARD:TYPE>=20 AND CARD:TYPE<=29) AND (CARD:EXPIRATIONDATE='--/--/--' OR CARD:EXPIRATIONDATE>SYSTEMDATE))
  DO
   LoanID=""
   FOR EACH CARD ACCESS WITH (CARD ACCESS:ACCESSTYPE=3 AND CARD ACCESS:IDTYPE=1)
    DO
      LoanID=CARD ACCESS:ID
    END
   IF LoanID<>"" THEN
    DO
     HTMLVIEWLINE("<a href='#' class='btn txt-large' ")
     HTMLVIEWLINE(btnCustomCSS)
     HTMLVIEWLINE("onclick='UserSelectionNext("+Q+"HtmlLoanID"+Q+","+Q+LoanID+Q+");return false;' >")
     HTMLVIEWLINE(SEGMENT(CARD:NUMBER,1,4)+"-"+SEGMENT(CARD:NUMBER,5,8)+"-"+SEGMENT(CARD:NUMBER,9,12)+"-"+SEGMENT(CARD:NUMBER,13,16)+" ")
     HTMLVIEWLINE("Loan ID: " +LoanID+ "</a><br/><br/>")
    END
  END
END[getCreditCardSel]

PROCEDURE getLoanSelectedBtns
 HTMLVIEWLINE("<a href='#' class='btn txt-large' ")
 HTMLVIEWLINE("onclick='UserSelectionNext("+Q+"HtmlResquestStatus"+Q+","+Q+"viewReport"+Q+");return false;' >")
 HTMLVIEWLINE("View Credit Report</a>&nbsp;&nbsp;")
 HTMLVIEWLINE("<a href='#' class='btn txt-large' ")
 HTMLVIEWLINE("onclick='UserSelectionNext("+Q+"HtmlResquestStatus"+Q+","+Q+"getCreditReport"+Q+");return false;' >")
 HTMLVIEWLINE("Pull Credit Report</a>")
 HTMLVIEWLINE("<br/><br/>")
 HTMLVIEWLINE("<a href='#' class='btn txt-large' ")
 HTMLVIEWLINE("onclick='UserSelectionNext("+Q+"HtmlResquestStatus"+Q+","+Q+"CollectionSummary"+Q+");return false;' >")
 HTMLVIEWLINE("Collection Summary</a>")
 HTMLVIEWLINE("<br/><br/>")
 HTMLVIEWLINE("<a href='#' class='btn txt-large' ")
 HTMLVIEWLINE("onclick='UserSelectionNext("+Q+"HtmlResquestStatus"+Q+","+Q+"Approved"+Q+");return false;' >")
 HTMLVIEWLINE("Approved</a>&nbsp;&nbsp;")
 HTMLVIEWLINE("<a href='#' class='btn txt-large' ")
 HTMLVIEWLINE("onclick='UserSelectionNext("+Q+"HtmlResquestStatus"+Q+","+Q+"Denied"+Q+");return false;' >")
 HTMLVIEWLINE("Denied</a>")
 HTMLVIEWLINE("<br/><br/>")
END[getLoanSelectedBtns]

PROCEDURE getMostRecentLoanApp
 LAApplicationDate='--/--/--'
 FOR EACH LOANAPP WITH (LOANAPP:EXPIRATIONDATE='--/--/--' OR LOANAPP:EXPIRATIONDATE>SYSTEMDATE)
  DO
   IF LAApplicationDate<LOANAPP:APPLICATIONDATE THEN
    DO
      LAApplicationDate=LOANAPP:APPLICATIONDATE
      LAApplicationID=LOANAPP:ID
    END
  END
END[getMostRecentLoanApp]

PROCEDURE getDataOverview
 CALL getLoanAppData
 CALL getLoanData
END[getDataOverview]

PROCEDURE getLoanData
 FOR EACH LOAN WITH LOAN:ID=HtmlVars(HtmlLoanID,HtmlFieldValue)
  DO
   HtmlVars(HtmlOriginalCreditScore,HtmlFieldValue)=FORMAT("9999",LOAN:CREDITSCORE)
   HtmlVars(HtmlLoanSelected,HtmlFieldValue)=LOAN:ID + " " + LOAN:DESCRIPTION 
   TEMPMONEY=LOAN:CREDITLIMIT
   CALL TekProFormatMoney
   HtmlVars(HtmlCurrentCreditLimit,HtmlFieldValue)=TEMPTEXT
  END

 FOR EACH TRACKING WITH TRACKING:TYPE=31
  DO
   HtmlVars(HtmlRecentCreditScore,HtmlFieldValue)=FORMAT("9999",TRACKING:USERCODE1)
  END
END[getLoanData]

PROCEDURE getLoanAppData
 CALL getMostRecentLoanApp
 FOR EACH LOANAPP WITH LOANAPP:ID=LAApplicationID
  DO
   HtmlVars(HtmlLADate,HtmlFieldValue)=FORMAT(DATEFORMAT,LOANAPP:APPLICATIONDATE)
   HtmlVars(HtmlLACreditScore,HtmlFieldValue)=FORMAT("9999",LOANAPP:CREDITSCORE)
   TEMPMONEY=LOANAPP:GROSSMONTHLYPAY1
   CALL TekProFormatMoney
   HtmlVars(HtmlLAIncome,HtmlFieldValue)=TEMPTEXT
   HtmlVars(HtmlLADebtRatio1,HtmlFieldValue)=FORMAT(RATEFORMAT,LOANAPP:DEBTRATIO:1)
   HtmlVars(HtmlLADebtRatio2,HtmlFieldValue)=FORMAT(RATEFORMAT,LOANAPP:DEBTRATIO:2)
   HtmlVars(HtmlLADebtRatio3,HtmlFieldValue)=FORMAT(RATEFORMAT,LOANAPP:DEBTRATIO:3)
   HtmlVars(HtmlLAProposedUER,HtmlFieldValue)=FORMAT(RATEFORMAT,LOANAPP:USERRATE1)
  END[FOR EACH LOANAPP]
END[getLoanAppData]

PROCEDURE TekProProcessApproval
 CALL TekProClearConfirmation
 ConfirmationItem=0
 ConfirmationCounter=0
 ConfirmationLabel(ConfirmationItem)="Credit Limit Request has been Approved"
 ConfirmationTxt(ConfirmationItem,0)="Increased Credit Limit"
 ConfirmationTxt(ConfirmationItem,1)="Updated Gross Monthly Pay"
 ConfirmationTxt(ConfirmationItem,2)="Created Loan Note"
 CALL updateCreditLimit
 IF ConfirmationCode(ConfirmationItem,ConfirmationCounter-1)=TRUE THEN CALL updateGrossMonthlyPay 
 IF ConfirmationCode(ConfirmationItem,ConfirmationCounter-1)=TRUE THEN CALL createLoanNote
END[TekProProcessApproval]

PROCEDURE TekProProcessDenied
 CALL TekProClearConfirmation
 ConfirmationItem=0
 ConfirmationCounter=0
 ConfirmationLabel(ConfirmationItem)="Credit Limit Request has been Denied"
 ConfirmationTxt(ConfirmationItem,0)="Updated Gross Monthly Pay"
 ConfirmationTxt(ConfirmationItem,1)="Created Loan Note"
 CALL updateGrossMonthlyPay 
 IF ConfirmationCode(ConfirmationItem,ConfirmationCounter-1)=TRUE THEN CALL createLoanNote
END[TekProProcessDenied]

PROCEDURE updateCreditLimit
 CALL getLoanData
 FMPERFORM REVISE LOAN HtmlVars(HtmlLoanID,HtmlFieldValue)(0,1,ERRORTEXT)
  DO
    SET CREDITLIMIT TO MONEY(VALUE(HtmlVars(HtmlNewLimit,HtmlFieldValue)))
  END
 CALL CheckConfirmationError
END[updateCreditLimit]

PROCEDURE updateGrossMonthlyPay 
 IF HtmlVars(HtmlNameLevel,HtmlFieldValue)="A" THEN
  DO
   FMPERFORM REVISE NAME LOC VALUE(HtmlVars(HtmlNameLocator,HtmlFieldValue)) (0,1,ERRORTEXT)
    DO
      SET CURRGROSSMONTHPAY TO MONEY(VALUE(HtmlVars(HtmlGrossMonthlyPay,HtmlFieldValue)))
    END
   CALL CheckConfirmationError
  END

 IF HtmlVars(HtmlNameLevel,HtmlFieldValue)="L" THEN
  DO
   FMPERFORM REVISE LOAN HtmlVars(HtmlLoanID,HtmlFieldValue) NAME LOC VALUE(HtmlVars(HtmlNameLocator,HtmlFieldValue)) (0,1,ERRORTEXT)
    DO
      SET CURRGROSSMONTHPAY TO MONEY(VALUE(HtmlVars(HtmlGrossMonthlyPay,HtmlFieldValue)))
    END
   CALL CheckConfirmationError
  END
END[updateGrossMonthlyPay]

PROCEDURE createLoanNote 
 FMPERFORM CREATE LOAN HtmlVars(HtmlLoanID,HtmlFieldValue) NOTE LOC BEFOREFIRST (0,0,ERRORTEXT)
  DO
     SET TEXT:1 TO "Credit Limit Increase By User " + FORMAT("9999",SYSUSERNUMBER)
     SET TEXT:2 TO HtmlVars(HtmlLoanSelected,HtmlFieldLabel)+": "+ HtmlVars(HtmlLoanSelected,HtmlFieldValue)
     SET TEXT:3 TO HtmlVars(HtmlOriginalCreditScore,HtmlFieldLabel)+": "+ HtmlVars(HtmlOriginalCreditScore,HtmlFieldValue)
     SET TEXT:4 TO HtmlVars(HtmlRecentCreditScore,HtmlFieldLabel)+": "+ HtmlVars(HtmlRecentCreditScore,HtmlFieldValue)
     SET TEXT:5 TO HtmlVars(HtmlNewAnnualIncome,HtmlFieldLabel)+": "+ HtmlVars(HtmlNewAnnualIncome,HtmlFieldValue)
     SET TEXT:6 TO HtmlVars(HtmlLADate,HtmlFieldLabel)+": "+ HtmlVars(HtmlLADate,HtmlFieldValue)
     SET TEXT:7 TO HtmlVars(HtmlLACreditScore,HtmlFieldLabel)+": "+ HtmlVars(HtmlLACreditScore,HtmlFieldValue)
     SET TEXT:8 TO HtmlVars(HtmlLAIncome,HtmlFieldLabel)+": "+ HtmlVars(HtmlLAIncome,HtmlFieldValue)
     SET TEXT:9 TO HtmlVars(HtmlLADebtRatio1,HtmlFieldLabel)+": "+ HtmlVars(HtmlLADebtRatio1,HtmlFieldValue)
     SET TEXT:10 TO HtmlVars(HtmlLADebtRatio2,HtmlFieldLabel)+": "+ HtmlVars(HtmlLADebtRatio2,HtmlFieldValue)
     SET TEXT:11 TO HtmlVars(HtmlLADebtRatio3,HtmlFieldLabel)+": "+ HtmlVars(HtmlLADebtRatio3,HtmlFieldValue)
     SET TEXT:12 TO HtmlVars(HtmlLAProposedUER,HtmlFieldLabel)+": "+ HtmlVars(HtmlLAProposedUER,HtmlFieldValue)
     SET TEXT:13 TO HtmlVars(HtmlResquestStatus,HtmlFieldLabel)+": "+ HtmlVars(HtmlResquestStatus,HtmlFieldValue)
     SET TEXT:14 TO HtmlVars(HtmlNewLimit,HtmlFieldLabel)+": "+ HtmlVars(HtmlNewLimit,HtmlFieldValue)
     SET TEXT:15 TO HtmlVars(HtmlAccountNoteTxt1,HtmlFieldValue)
     SET TEXT:16 TO HtmlVars(HtmlAccountNoteTxt2,HtmlFieldValue)
     SET TEXT:17 TO HtmlVars(HtmlAccountNoteTxt3,HtmlFieldValue)
     SET TEXT:18 TO HtmlVars(HtmlAccountNoteTxt4,HtmlFieldValue)
     SET TEXT:19 TO HtmlVars(HtmlAccountNoteTxt5,HtmlFieldValue)
  END
  CALL CheckConfirmationError
END[createLoanNote]


[ **********************************************************************
              2. TekApp BASE Procedures

 *********************************************************************** ]

PROCEDURE TekProWebSetupApp
 CurrentApp(CurrentUserNum,1)=FORMAT("9999",SYSUSERNUMBER)
 CurrentApp(CurrentUserName,1)=FORMAT("9999",SYSUSERNUMBER)+" "+SYSUSERNAME(SYSUSERNUMBER)
 CurrentApp(CurrentSYM,1)=FORMAT("999",SYSSYMDIRECTORY)
 CurrentApp(CurrentConsole,1)=FORMAT("9999",SYSCONSOLENUM)
 CurrentApp(CurrentBranch,1)=FORMAT("9999",GETDATANUMBER(GETCONSOLEBRANCH,SYSCONSOLENUM))
 CALL setTekFiles
 CALL TekProAddRequestAppLog
END[TekProWebSetupApp]

[ *** START Name Obj ***************************************] 
PROCEDURE TekSetSymXNameObj
 CALL TekProClearNameObj
 FOR EACH NAME WITH (NAME:SSN=SymXSSN AND NameObj(ObjNameSSN)="")
  DO
   CALL TekProSetAcctName
  END
 FOR EACH SHARE WITH SHARE:CLOSEDATE='--/--/--'
  DO
   FOR EACH SHARE NAME WITH (SHARE NAME:SSN=SymXSSN AND NameObj(ObjNameSSN)="")
    DO
     CALL TekProSetShareName
    END
  END
 FOR EACH LOAN WITH LOAN:CLOSEDATE='--/--/--'
  DO
   FOR EACH LOAN NAME WITH (LOAN NAME:SSN=SymXSSN AND NameObj(ObjNameSSN)="")
    DO
     CALL TekProSetLoanName
    END
  END
 CALL TekProAddNameList
 HtmlVars(RequesterLocator,HtmlFieldValue)=NameObj(ObjNameLocator)
 CALL TekSetNameToRequester
END[TekSetSymXNameObj]

PROCEDURE TekSetNameToRequester
 FOR Jx=0 TO NameListMax
  DO
   IF HtmlVars(RequesterLocator,HtmlFieldValue)=NameList(Jx,ObjNameLocator) THEN
    DO
     FOR J=0 TO NameListMaxFields
      DO
        RequesterObj(J)=NameList(Jx,J)
      END
     Jx=NameListMax
    END
  END
END[TekSetNameToRequester]

PROCEDURE TekProClearNameObj
 FOR J=0 TO NameListMaxFields
  DO 
    NameObj(J)=""
  END
END[TekProClearNameObj]

PROCEDURE TekProClearRequesterObj
 FOR J=0 TO NameListMaxFields
  DO 
    RequesterObj(J)=""
  END
END[TekProClearRequesterObj]

PROCEDURE TekProClearNameList
 FOR J=0 TO NameListMax
  DO
   FOR Jx=0 TO NameListMaxFields
    DO
      NameList(J,Jx)=""
    END
  END
END[TekProClearNameList]

PROCEDURE TekProSeekNameList
 NameListFound=FALSE
 FOR J=0 TO NameListMax
  DO
    IF TEMPTEXT=NameList(J,ObjNameSSN) THEN NameListFound=TRUE
  END
END[TekProSeekNameList]

PROCEDURE TekProGetNextNameListPos
 FOR J=0 TO NameListMax
  DO
    IF NameList(J,0)="" THEN
     DO
       NameListPos=J
       J=NameListMax
     END
  END
END[TekProGetNextNameListPos]

PROCEDURE TekProAddNameList
 TEMPTEXT=NameObj(ObjNameSSN)
 CALL TekProSeekNameList
 IF NameListFound=FALSE THEN
  DO
   CALL TekProGetNextNameListPos
   FOR J=0 TO NameListMaxFields
    DO
     NameList(NameListPos,J)=NameObj(J)
    END
  END
END[TekProAddNameList]

PROCEDURE TekProSetAcctName
 CALL TekProClearNameObj
 NameObj(ObjNameLocator)=FORMAT("9999999999",NAME:LOCATOR)
 NameObj(ObjNameSSN)=NAME:SSN
 NameObj(ObjNameLongName)=NAME:LONGNAME
 NameObj(ObjNameLast)=NAME:LAST
 NameObj(ObjNameFirst)=NAME:FIRST
 NameObj(ObjNameMiddle)=NAME:MIDDLE
 NameObj(ObjNameEmployer)=NAME:EMPLOYERNAME
 NameObj(ObjNameStreet)=NAME:STREET
 NameObj(ObjNameExtraAddress)=NAME:EXTRAADDRESS
 NameObj(ObjNameCity)=NAME:CITY
 NameObj(ObjNameState)=NAME:STATE
 NameObj(ObjNameZipCode)=NAME:ZIPCODE
 NameObj(ObjNameMobilePhone)=NAME:MOBILEPHONE
 NameObj(ObjNameHomePhone)=NAME:HOMEPHONE
 NameObj(ObjNameWorkPhone)=NAME:WORKPHONE
 NameObj(ObjNameEmail)=NAME:EMAIL
 NameObj(ObjNameAltEmail)=NAME:ALTEMAIL
 NameObj(ObjNameType)=FORMAT("99",NAME:TYPE) +" "+NameTypeOptions(NAME:TYPE)
 NameObj(ObjNameLevel)="A"
END[TekProSetAcctName]

PROCEDURE TekProSetShareName
 CALL TekProClearNameObj
 NameObj(ObjNameLocator)=FORMAT("9999999999",SHARE NAME:LOCATOR)
 NameObj(ObjNameSSN)=SHARE NAME:SSN
 NameObj(ObjNameLongName)=SHARE NAME:LONGNAME
 NameObj(ObjNameLast)=SHARE NAME:LAST
 NameObj(ObjNameFirst)=SHARE NAME:FIRST
 NameObj(ObjNameMiddle)=SHARE NAME:MIDDLE
 NameObj(ObjNameEmployer)=SHARE NAME:EMPLOYERNAME
 NameObj(ObjNameStreet)=SHARE NAME:STREET
 NameObj(ObjNameExtraAddress)=SHARE NAME:EXTRAADDRESS
 NameObj(ObjNameCity)=SHARE NAME:CITY
 NameObj(ObjNameState)=SHARE NAME:STATE
 NameObj(ObjNameZipCode)=SHARE NAME:ZIPCODE
 NameObj(ObjNameMobilePhone)=SHARE NAME:MOBILEPHONE
 NameObj(ObjNameHomePhone)=SHARE NAME:HOMEPHONE
 NameObj(ObjNameWorkPhone)=SHARE NAME:WORKPHONE
 NameObj(ObjNameEmail)=SHARE NAME:EMAIL
 NameObj(ObjNameAltEmail)=SHARE NAME:ALTEMAIL
 NameObj(ObjNameType)=FORMAT("99",SHARE NAME:TYPE) +" Share Name "+NameTypeOptions(SHARE NAME:TYPE)
 NameObj(ObjNameLevel)="S"
END[TekProSetShareName]

PROCEDURE TekProSetLoanName
 CALL TekProClearNameObj
 NameObj(ObjNameLocator)=FORMAT("9999999999",LOAN NAME:LOCATOR)
 NameObj(ObjNameSSN)=LOAN NAME:SSN
 NameObj(ObjNameLongName)=LOAN NAME:LONGNAME
 NameObj(ObjNameLast)=LOAN NAME:LAST
 NameObj(ObjNameFirst)=LOAN NAME:FIRST
 NameObj(ObjNameMiddle)=LOAN NAME:MIDDLE
 NameObj(ObjNameEmployer)=LOAN NAME:EMPLOYERNAME
 NameObj(ObjNameStreet)=LOAN NAME:STREET
 NameObj(ObjNameExtraAddress)=LOAN NAME:EXTRAADDRESS
 NameObj(ObjNameCity)=LOAN NAME:CITY
 NameObj(ObjNameState)=LOAN NAME:STATE
 NameObj(ObjNameZipCode)=LOAN NAME:ZIPCODE
 NameObj(ObjNameMobilePhone)=LOAN NAME:MOBILEPHONE
 NameObj(ObjNameHomePhone)=LOAN NAME:HOMEPHONE
 NameObj(ObjNameWorkPhone)=LOAN NAME:WORKPHONE
 NameObj(ObjNameEmail)=LOAN NAME:EMAIL
 NameObj(ObjNameAltEmail)=LOAN NAME:ALTEMAIL
 NameObj(ObjNameType)=FORMAT("99",LOAN NAME:TYPE) +" Loan Name "+NameTypeOptions(LOAN NAME:TYPE)
 NameObj(ObjNameLevel)="L"
END[TekProSetLoanName]

PROCEDURE TekProDisplayHtmlNameList
 CALL TekProGetNextNameListPos
 FOR J=0 TO NameListPos-1
  DO
    HTMLVIEWLINE("<option value='"+NameList(J,ObjNameLocator)+"'")
    IF RequesterObj(ObjNameLocator)=NameList(J,ObjNameLocator) OR RequesterObj(ObjNameLocator)="Other" THEN  HTMLVIEWLINE(" selected")
    HTMLVIEWLINE(">" +NameList(J,ObjNameLongName)+ "</option>")
  END
END[TekProDisplayHtmlNameList]

[ ******************** Temp Files ***************************************] 

PROCEDURE setTekFiles
 TekErrorLogFile="TekApp.Error.Log"
 TekTranLogFile="TekApp.Tran.Log"
 TekTranRequestLogFile="TekApp.Request.Log"
END[setTekFiles]

PROCEDURE TekProCreateTempFile
 TekTempFileName=FORMAT("999",SYSSYMDIRECTORY)+FORMAT("9999",SYSCONSOLENUM)+FORMAT("9999",SYSUSERNUMBER)+FORMAT("999999",SYSTEMDATE)
 IF HtmlVars(HtmlTrackEndTime,HtmlFieldValue)<>"" THEN
   TekTempFileName=TekTempFileName+SEGMENT(HtmlVars(HtmlTrackEndTime,HtmlFieldValue),1,2)+SEGMENT(HtmlVars(HtmlTrackEndTime,HtmlFieldValue),4,5)+SEGMENT(HtmlVars(HtmlTrackEndTime,HtmlFieldValue),7,8)
 ELSE
   TekTempFileName=TekTempFileName+SEGMENT(HtmlVars(HtmlTrackStartTime,HtmlFieldValue),1,2)+SEGMENT(HtmlVars(HtmlTrackStartTime,HtmlFieldValue),4,5)+SEGMENT(HtmlVars(HtmlTrackStartTime,HtmlFieldValue),7,8)
 FILEOPEN("LETTER",TekTempFileName,"APPEND",FNUMBER,FERROR)
 FILEDELETE("LETTER",TekTempFileName,FERROR)
 FILEOPEN("LETTER",TekTempFileName,"APPEND",FNUMBER,FERROR)
 CALL TekProWriteTempFileData
 FILECLOSE(FNUMBER,FERROR)
END[TekProCreateTempFile]

PROCEDURE TekProWriteTempFileData
 FOR J=1 TO CurrentAppMax
  DO
    IF CurrentApp(J,0)<> "" THEN FILEWRITELINE(FNUMBER,CurrentApp(J,0)+"|"+CurrentApp(J,1),FERROR)
  END
 FOR J=1 TO HtmlVarsMax
  DO
    IF HtmlVars(J,HtmlFieldID)<>"" THEN FILEWRITELINE(FNUMBER,HtmlVars(J,HtmlFieldID)+"|"+HtmlVars(J,HtmlFieldValue),FERROR)
  END
END[TekProWriteTempFileData]

PROCEDURE TekProReadTempFileData
 FILEOPEN("LETTER",TekTempFileName,"READ",FNUMBER,FERROR)
 IF FERROR="" THEN
  DO
   FILEREADLINE(FNUMBER,TXTLINE,FERROR)
   WHILE FERROR=""
    DO
     POS=CHARACTERSEARCH(TXTLINE,"|")
     TXTLINEVALUE=SEGMENT(TXTLINE,POS+1,LENGTH(TXTLINE))
     TXTLINE=SEGMENT(TXTLINE,1,POS-1)
     FOR J=1 TO CurrentAppMax
      DO
       IF CurrentApp(J,0)=TXTLINE THEN CurrentApp(J,1)=TXTLINEVALUE
      END
     FOR J=1 TO HtmlVarsMax
      DO
       IF HtmlVars(J,HtmlFieldID)=TXTLINE THEN HtmlVars(J,HtmlFieldValue)=TXTLINEVALUE
      END
     FILEREADLINE(FNUMBER,TXTLINE,FERROR)
    END
   FILECLOSE(FNUMBER,FERROR)
  END[FERROR<>""]
END[TekProReadTempFileData]

PROCEDURE TekProDeleteTempFileData
 FILEDELETE("LETTER",TekTempFileName,FERROR)
END[TekProDeleteTempFileData]

PROCEDURE TekProAddTranLog
 IF TekAppTranLog=TRUE THEN
  DO
    FILEOPEN("LETTER",TekTranLogFile,"APPEND",FNUMBER,FERROR)
    FILEWRITE(FNUMBER,FORMAT(DATEFORMAT,SYSTEMDATE)+ "|",FERROR)
    FILEWRITE(FNUMBER,STARTTIME+ "|",FERROR)
    FILEWRITE(FNUMBER,ENDTIME+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentAppChannel,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentAppName,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentSYM,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentBranch,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentConsole,1)+ "|",FERROR)   
    FILEWRITE(FNUMBER,CurrentApp(CurrentUserNum,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentUserName,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,ACCOUNT:NUMBER,FERROR)
    FILEWRITELINE(FNUMBER,"",FERROR)
    FILECLOSE(FNUMBER,FERROR) 
  END       
END

PROCEDURE TekProAddRequestAppLog
 IF TekAppTranLog=TRUE THEN
  DO
    FILEOPEN("LETTER",TekTranRequestLogFile,"APPEND",FNUMBER,FERROR)
    FILEWRITE(FNUMBER,FORMAT(DATEFORMAT,SYSTEMDATE)+ "|",FERROR)
    FILEWRITE(FNUMBER,STARTTIME+ "|",FERROR)
    FILEWRITE(FNUMBER,ENDTIME+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentAppChannel,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentAppName,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentSYM,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentBranch,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentConsole,1)+ "|",FERROR)   
    FILEWRITE(FNUMBER,CurrentApp(CurrentUserNum,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,CurrentApp(CurrentUserName,1)+ "|",FERROR)
    FILEWRITE(FNUMBER,ACCOUNT:NUMBER,FERROR)
    FILEWRITELINE(FNUMBER,"",FERROR)
    FILECLOSE(FNUMBER,FERROR) 
  END       
END

[ ***** DocuSign ***************]

PROCEDURE SaveDocuSignResponse
 FILEOPEN("LETTER",TekDocuSignLogFile,"APPEND",FNUMBER,FERROR)
 FILEWRITELINE(FNUMBER,FORMAT(DATEFORMAT,SYSTEMDATE)+ "|" + SEGMENT(DocuSignEnvID,1,36)+ "|" +TekTempFileName+ "|" +CurrentApp(CurrentAppName,1),FERROR)
 FILECLOSE(FNUMBER,FERROR)
END[SaveDocuSignResponse]

[ *************** Clear Functions ****************** ]
PROCEDURE TekProClearConfirmation
 FOR J=0 TO ConfirmationItemMax
  DO
   ConfirmationLabel(J)=""
   FOR Jx=0 TO ConfirmationCounterMax
    DO
      ConfirmationCode(J,Jx)=FALSE
      ConfirmationTxt(J,Jx)=""      
    END
  END
END[TekProClearConfirmation]

PROCEDURE ClearHtmlVars
 FOR J=11 TO HtmlVarsMax
  DO
   HtmlVars(J,HtmlFieldValue)=""
  END
END[ClearHtmlVars]

[ **** Loan Procedures **** ]
PROCEDURE TekProGetLoanDescription
 FOR EACH LOAN WITH LOAN:ID=TEMPTEXT1
  DO
    TEMPTEXT2=LOAN:DESCRIPTION
  END
END[TekProGetLoanDescription]

PROCEDURE FINDAVAILABLELNID
 FOR J=1 TO 99
  DO
    LoanAvailableIDFlag=FALSE
    FOR EACH LOAN
     DO
      IF VALUE(LOAN:ID)=J THEN LoanAvailableIDFlag=TRUE
     END
    IF LoanAvailableIDFlag=FALSE THEN 
     DO
      LoanAvailableID=J
      J=99
     END
  END
END[FINDLNID]

PROCEDURE TekProDisplayLoanOption
 IF CurrentApp(CurrentAppStep,1)="SymXchange" THEN
  DO
    PRINT "r||" +"L"+LOAN:ID+ " " +LOAN:DESCRIPTION+"|S" +LOAN:ID + "|"
    NEWLINE
  END
 ELSE
  DO
    IF HtmlVars(HtmlTxtFieldName,HtmlFieldValue)="L"+LOAN:ID THEN 
      HTMLVIEWLINE("<option value='L" +LOAN:ID+ "' Selected >")
    ELSE
      HTMLVIEWLINE("<option value='L" +LOAN:ID+ "' >")
    HTMLVIEWLINE("L"+LOAN:ID+ " " +LOAN:DESCRIPTION+ "</option>")
  END
END

[ **** Share Procedures **** ]
PROCEDURE TekProGetShareDescription
 FOR EACH SHARE WITH SHARE:ID=TEMPTEXT1
  DO
    TEMPTEXT2=SHARE:DESCRIPTION
  END
END[TekProGetShareDescription]

PROCEDURE GetTmpFirstShareID
 TmpFirstShareID=""
 FOR EACH SHARE WITH (SHARE:CLOSEDATE='--/--/--' AND SHARE:CHARGEOFFDATE='--/--/--')
  DO
    TmpFirstShareID=SHARE:ID
  END
 UNTIL TmpFirstShareID<>""
END[GetTmpFirstShareID]

PROCEDURE TekProDisplayShareOption
 IF CurrentApp(CurrentAppStep,1)="SymXchange" THEN
  DO
    PRINT "r||" +"S"+SHARE:ID+ " " +SHARE:DESCRIPTION+"|S" +SHARE:ID + "|"
    NEWLINE
  END
 ELSE
  DO
   IF HtmlVars(HtmlTxtFieldName,HtmlFieldValue)="S"+SHARE:ID THEN 
    HTMLVIEWLINE("<option value='S" +SHARE:ID+ "' Selected >")
   ELSE
    HTMLVIEWLINE("<option value='S" +SHARE:ID+ "' >")
   HTMLVIEWLINE("S"+SHARE:ID+ " " +SHARE:DESCRIPTION+ "</option>")
  END
END

[ ***************** List Items ***************** ]
PROCEDURE AddListItem
 FOR J=0 TO MaxListItem
  DO
    IF ListItemArray(J)="" THEN 
     DO
      ListItemArray(J)=HtmlVars(ListItem,HtmlFieldValue)
      J=MaxListItem
      HtmlVars(ListItem,HtmlFieldValue)=""
     END
  END
 IF HtmlVars(ListItem,HtmlFieldValue)<>"" THEN POPUPMESSAGE(0,"Max Number of records selected: " + FORMAT("99",MaxListItem))
 HtmlVars(ListItemAction,HtmlFieldValue)=""
END[AddListItem]

PROCEDURE RemoveListItem
 FOR J=0 TO MaxListItem
  DO
    IF ListItemArray(J)=HtmlVars(ListItem,HtmlFieldValue) THEN ListItemArray(J)="" 
  END
 HtmlVars(ListItem,HtmlFieldValue)=""
 HtmlVars(ListItemAction,HtmlFieldValue)=""
END[RemoveListItem]

PROCEDURE ClearListItemArray
 FOR J=0 TO MaxListItem
  DO
    ListItemArray(J)="" 
  END
END[ClearListItemArray]

PROCEDURE GetListItemCounter
 ListItemCounter=0
 FOR J=0 TO MaxListItem
  DO
    IF ListItemArray(J)<>"" THEN ListItemCounter=ListItemCounter+1
  END
END[GetListItemCounter]

PROCEDURE CheckConfirmationError
 IF ERRORTEXT<>"" THEN
  CALL TekProLogError
 ELSE
  ConfirmationCode(ConfirmationItem,ConfirmationCounter)=TRUE
 ConfirmationCounter=ConfirmationCounter+1
END[CheckConfirmationError]

PROCEDURE xDisplayConfirmationV2
 FOR J=0 TO ConfirmationItem 
  DO
   PRINT "h|ConfirmationList|1|" + ConfirmationLabel(J)
   NEWLINE
   FOR Jx=0 TO ConfirmationCounterMax 
    DO
     IF ConfirmationTxt(J,Jx)<>"" THEN
      DO
       PRINT "r|" +FORMAT("9",ConfirmationCode(J,Jx)) +"|" +ConfirmationTxt(J,Jx)+ "||"
       NEWLINE
      END
    END[FOR Jx=0]
   PRINT "New SymX Record"
   NEWLINE
  END[FOR J=0]
END[xDisplayConfirmationV2]

PROCEDURE TekProLogConfirmationError
 FOR J=0 TO ConfirmationItem 
  DO
   FILEWRITELINE(FNUMBER,"ConfirmationLabel" +FORMAT("99",J)+ "|"+ConfirmationLabel(J),FERROR)
   FOR Jx=0 TO ConfirmationCounterMax 
    DO
     IF ConfirmationTxt(J,Jx)<>"" THEN
      DO
       IF ConfirmationCode(J,Jx)=FALSE THEN
        TEMPTEXT1=" -FAILED"
       ELSE
        TEMPTEXT1=" -PASSED"
       FILEWRITELINE(FNUMBER,"ConfirmationStep" +FORMAT("99",J)+FORMAT("99",Jx)+ "|"+ConfirmationTxt(J,Jx)+TEMPTEXT1,FERROR)
      END
    END[FOR Jx=0]
  END[FOR J=0]
END[TekProLogConfirmationError]

PROCEDURE TekProLogError
 FILEOPEN("LETTER",TekErrorLogFile,"APPEND",FNUMBER,FERROR)
 FILEWRITELINE(FNUMBER,FORMAT(DATEFORMAT,SYSTEMDATE)+ " " + ERRORTEXT,FERROR)
 CALL TekProWriteTempFileData
 CALL TekProLogConfirmationError
 FILEWRITELINE(FNUMBER,"********************************************************************************",FERROR)
 FILECLOSE(FNUMBER,FERROR)
 IF CurrentApp(CurrentAppStep,1)<>"SymXchange" THEN POPUPMESSAGE(0,ERRORTEXT)
END[TekProLogError]

[ ***************** Formatting *********************** ]
PROCEDURE TekProFormatMoney
 TEMPTEXT=FORMAT(MONEYFORMAT,TEMPMONEY)
 CALL TekProRemoveBlanks
END[TekProFormatMoney]

PROCEDURE TekProRemoveBlanks
 TEMPTEXT1=TEMPTEXT
 Jx=LENGTH(TEMPTEXT1)
 TEMPTEXT=""
 FOR J=0 TO Jx
  DO
   IF SEGMENT(TEMPTEXT1,J,J)<>" " THEN TEMPTEXT=TEMPTEXT+SEGMENT(TEMPTEXT1,J,J)
  END
END[TekProRemoveBlanks]

PROCEDURE TekProAddLeadingZeros
 J=LENGTH(TEMPTEXT)
 FOR Jx=1 TO TEMPNUM-J
  DO
    TEMPTEXT="0"+TEMPTEXT
  END
END[TekProAddLeadingZeros]

PROCEDURE TekProRemoveLeadingZeros
 J=LENGTH(TEMPTEXT)
 IF SEGMENT(TEMPTEXT,1,1)="0" AND J>0 THEN
  DO
   FOR Jx=1 TO J
    DO
      IF SEGMENT(TEMPTEXT,Jx,Jx)<>"0" THEN
       DO
        IF Jx<J THEN TEMPTEXT=SEGMENT(TEMPTEXT,Jx,J)
        IF Jx=J THEN TEMPTEXT=SEGMENT(TEMPTEXT,J,J)
        Jx=J
       END
      ELSE
       IF Jx=J THEN TEMPTEXT="0"
    END
  END
END[TekProRemoveLeadingZeros]

PROCEDURE TekProReplace
 POS=CHARACTERSEARCH(TEMPTEXT,TEMPTEXT1)
 IF POS=0 THEN
  TEMPTEXT=TEMPTEXT2+SEGMENT(TEMPTEXT,LENGTH(TEMPTEXT1)+1,LENGTH(TEMPTEXT))
 ELSE
  TEMPTEXT=SEGMENT(TEMPTEXT,0,POS-1)+TEMPTEXT2+SEGMENT(TEMPTEXT,POS+LENGTH(TEMPTEXT1),LENGTH(TEMPTEXT))
END[TekProReplace]

PROCEDURE TekProGetOnlyNumbers
 TEMPTEXT1=TEMPTEXT
 J=LENGTH(TEMPTEXT1)
 TEMPTEXT=""
 FOR Jx=0 TO J
  DO
   IF CHARACTERSEARCH("0123456789",SEGMENT(TEMPTEXT1,Jx,Jx))>0 THEN
    TEMPTEXT=TEMPTEXT+SEGMENT(TEMPTEXT1,Jx,Jx)
  END
END[TekProGetOnlyNumbers] 

PROCEDURE getSPELLMONTH
 IF MONTH(TEMPDATE)=1 THEN SPELLMONTH="January"
 IF MONTH(TEMPDATE)=2 THEN SPELLMONTH="February"
 IF MONTH(TEMPDATE)=3 THEN SPELLMONTH="March"
 IF MONTH(TEMPDATE)=4 THEN SPELLMONTH="April"
 IF MONTH(TEMPDATE)=5 THEN SPELLMONTH="May"
 IF MONTH(TEMPDATE)=6 THEN SPELLMONTH="June"
 IF MONTH(TEMPDATE)=7 THEN SPELLMONTH="July"
 IF MONTH(TEMPDATE)=8 THEN SPELLMONTH="August"
 IF MONTH(TEMPDATE)=9 THEN SPELLMONTH="September"
 IF MONTH(TEMPDATE)=10 THEN SPELLMONTH="October"
 IF MONTH(TEMPDATE)=11 THEN SPELLMONTH="November"
 IF MONTH(TEMPDATE)=12 THEN SPELLMONTH="December"
END[getSPELLMONTH]

[ ***************** Help Functions *********************** ]

PROCEDURE getLastDayOfMonthFlag
 LastDayOfMonthFlag=FALSE
 IF (DAY(TEMPDATE)=28 OR DAY(TEMPDATE)=29 OR DAY(TEMPDATE)=30 OR DAY(TEMPDATE)=31) THEN
  DO
    IF MONTH(TEMPDATE)=1 OR
       MONTH(TEMPDATE)=3 OR
       MONTH(TEMPDATE)=5 OR
       MONTH(TEMPDATE)=7 OR
       MONTH(TEMPDATE)=8 OR
       MONTH(TEMPDATE)=10 OR
       MONTH(TEMPDATE)=12 THEN
      DO
       IF MONTH(TEMPDATE)=31 THEN LastDayOfMonthFlag=TRUE
      END
    ELSE IF MONTH(TEMPDATE)=4 OR
            MONTH(TEMPDATE)=6 OR
            MONTH(TEMPDATE)=9 OR
            MONTH(TEMPDATE)=11 THEN
           DO
            IF MONTH(TEMPDATE)=30 THEN LastDayOfMonthFlag=TRUE         
           END
         ELSE IF INT(YEAR(TEMPDATE)/4)=YEAR(TEMPDATE)/4 THEN [IF FEB AND LEAP YEAR]
               DO
                IF MONTH(TEMPDATE)=29 THEN LastDayOfMonthFlag=TRUE 
               END
              ELSE
               DO
                IF MONTH(TEMPDATE)=28 THEN LastDayOfMonthFlag=TRUE
               END
  END[(DAY(TEMPDATE)=28 OR DAY(TEMPDATE)=29 OR DAY(TEMPDATE)=30 OR DAY(TEMPDATE)=31)]
END[getLastDayOfMonthFlag]

PROCEDURE getNextBusinessDay
 TEMPFLAG=TRUE
 FOR J = 1 TO 300
  DO
    HolidayArray(J) = GETDATADATE(GETPARAMREGCCHOLIDAY, 0, J)
  END
 NextBusinessDay= SYSTEMDATE
 WHILE (TEMPFLAG=TRUE)
  DO
   NextBusinessDay= NextBusinessDay+ 1
   WeekDayFlag = FALSE
   HolidayFlag = FALSE
   IF DAYOFWEEK(NextBusinessDay) = 0 OR   [ SUNDAY=0, SATURDAY=6 ]
      DAYOFWEEK(NextBusinessDay) = 6 THEN WeekDayFlag=TRUE

   IF WeekDayFlag=FALSE THEN
    DO
     FOR J = 1 TO 300
      DO
       IF NextBusinessDay=HolidayArray(I) THEN HolidayFlag=TRUE
      END
    END[WeekDayFlag=FALSE]
   IF WeekDayFlag=FALSE AND HolidayFlag=FALSE THEN TEMPFLAG=FALSE
  END[WHILE]
END[getNextBusinessDay]

PROCEDURE capitalizeFirstLetter
 TEMPNUM=LENGTH(TEMPTEXT)
 TEMPFLAG=TRUE
 TEMPTEXT1=""
 TEMPTEXT=LOWERCASE(TEMPTEXT)
 FOR J=1 TO TEMPNUM
  DO
   IF TEMPFLAG=TRUE THEN
    DO
     TEMPTEXT1=TEMPTEXT1+UPPERCASE(SEGMENT(TEMPTEXT,J,J))
     TEMPFLAG=FALSE
    END
   ELSE
    DO
     TEMPTEXT1=TEMPTEXT1+SEGMENT(TEMPTEXT,J,J)
    END
   IF SEGMENT(TEMPTEXT,J,J)=" " THEN TEMPFLAG=TRUE
  END
 TEMPTEXT=TEMPTEXT1
END[capitalizeFirstLetter]



