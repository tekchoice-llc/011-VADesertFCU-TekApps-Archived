[*****************************************************************************
 IMPORTANT NOTICE

 By downloading, installing, or otherwise using any tek-apps, software, documentation, or 
 other materials made available by TekChoice, LLC, through this repository, you acknowledge
 that you have read, understand, and agree to be bound by the End User License Agreement (the "EULA")
 included in these downloaded files as EULA.txt and made available at www.tekchoice.com/EULA.

 SPECFILENAME: TEKAPP011.STOPPYMT.CU
 VERSION: 001
 COPYRIGHT: TekChoice, LLC 2021 © 

 Version:       001   

 Sections:      1. SET Credit Union TekApp Variables

                2. Custom Credit Union TekApp Business Rules
                   Update procedure accordingly between Start and End
                   ** Start -Update **
                   CU custom code
                   ** End -Update **  
             
 Programmed:    TekChoice LLC

 Modified:      05.15.21 Original Source


********************************************************************************]

[ **********************************************************************
               1. SET Credit Union TekApp Variables

 *********************************************************************** ]
PROCEDURE setCrediUnionVars
 
 ValidateShareHoldProcessed=TRUE

[ *** Fee *** ]
 TransactionFee="$30.00"
 StopGLFee=101
 StopComment="Stop ACH Fee"

[*** Hold Dates ***]
 VerbalDate=SYSTEMDATE+14
 InPersonDate=DATEOFFSET(SYSTEMDATE,6,0)

[*** Hold Type ***]
 StopDraft="3"
 StopDraftVerbal="7"
 StopACH="6"
 StopACHVerbal="8"

[ *** Field Labels *** ]
 HtmlVars(InPersonRequestFlag,HtmlFieldLabel)="<b class='txt-xlarge' >Is member's physically present?</b>"
 HtmlVars(StopShareID,HtmlFieldLabel)="Share"
 HtmlVars(StopShareIDFee,HtmlFieldLabel)="Share Fee"
 HtmlVars(StopReason,HtmlFieldLabel)="Reason"
 HtmlVars(StopReason,HtmlFieldSize)="300"
 HtmlVars(StopPayableTo,HtmlFieldLabel)="Payable To"
 HtmlVars(StopPayableTo,HtmlFieldMaxLength)="16"
 HtmlVars(StopPayableTo,HtmlFieldSize)="200"
 HtmlVars(StopCheckNumber,HtmlFieldLabel)="Start Check Number"
 HtmlVars(StopCheckNumberEnd,HtmlFieldLabel)="End Check Number (if applicable)"
 HtmlVars(StopAmount,HtmlFieldValue)="$0.00"
 HtmlVars(StopAmount,HtmlFieldLabel)="Amount ($0.00 if not known)"
 HtmlVars(StopACHDebitCredit,HtmlFieldLabel)="Debit/Credit"
 HtmlVars(StopFee,HtmlFieldLabel)="Actual Fee"
 HtmlVars(RequesterLocator,HtmlFieldLabel)="<b class='txt-xlarge' >Requester</b>"
 HtmlVars(RequesterLongName,HtmlFieldLabel)="Requester"
 HtmlVars(RequesterStreet,HtmlFieldLabel)="Street"
 HtmlVars(RequesterExtraAddress,HtmlFieldLabel)="Extra Address"
 HtmlVars(RequesterCity,HtmlFieldLabel)="City"
 HtmlVars(RequesterState,HtmlFieldLabel)="State"
 HtmlVars(RequesterZip,HtmlFieldLabel)="Zip"
 HtmlVars(RequesterSSN,HtmlFieldLabel)="SSN"

 ConfirmLabelTxt="Stop Payment "
 CreateStopPymtHoldTxt="Created Share Hold"
 TransferStopPymtFeeTxt="Processed Fee"
 updateStopPymtHoldTxt="Updated Hold"
 StopPymtFeeTxt="Stop Payment Fee"

[ *** PDF Form ***]
 PDFForm="PDF.STOP.PAY2.759"

[ *** Security Groups and Limits by User "ALL" for all Group ****]
 EpisysSG(1,SGNumber)="ALL"
 EpisysSG(1,SGLimit)="1000.00"

[********************************************************************************** 
   PDF CU Procedure Path
   Example(s)
     TekAppPDFProcedure="http://www.mywebsite.com/myAppProcedure.pdf"
     TekAppPDFProcedure="file://///server/path/myAppProcedure.pdf"
*********************************************************************************** ] 
 TekAppPDFProcedure="AppProcedure.pdf"

[ *** Set to TRUE/FALSE to enable/disable logging *** ]
 TekAppTranLog=FALSE

[ *** CU Files *** ]
 TekMainCSS="TekMainCSS.v02"
 TekMainJS="TekMainJS.v02"
 TekMainCUVars="TEKAPP011.MAIN.CU.SET"

END[setCrediUnionVars]

[ **********************************************************************
              2. Custom Credit Union TekApp Business Rules

 *********************************************************************** ]

PROCEDURE GetSelectShareLoanOptions
[ ** Start -Update Selection Criteria according CU Business Rules **]
 FOR EACH SHARE WITH SHARE:CLOSEDATE='--/--/--'
[ ** End -Update Selection Criteria according CU Business Rules **]
  DO
   CALL TekProDisplayShareOption
  END
[ ** Start -Update Selection Criteria according CU Business Rules **]
 FOR EACH LOAN WITH LOAN:CLOSEDATE='--/--/--'
[ ** End -Update Selection Criteria according CU Business Rules **]
  DO
   CALL TekProDisplayLoanOption
  END
END[GetSelectShareLoanOptions]

PROCEDURE getAccountNames
 CALL TekProClearNameList

[ ** START -Update Selection Criteria according CU Business Rules **]
 FOR EACH NAME WITH (NAME:TYPE=0 OR NAME:TYPE=1) AND NAME:EXPIRATIONDATE='--/--/--'
[ ** END -Update Selection Criteria according CU Business Rules **]  
  DO
    CALL TekProSetAcctName
    CALL TekProAddNameList
  END

 FOR EACH LOAN WITH (LOAN:CLOSEDATE='--/--/--')
  DO
[ ** START -Update Selection Criteria according CU Business Rules **]
    FOR EACH LOAN NAME WITH (LOAN NAME:TYPE=0 OR LOAN NAME:TYPE=1) AND LOAN NAME:EXPIRATIONDATE='--/--/--'
[ ** END -Update Selection Criteria according CU Business Rules **]  
     DO
       CALL TekProSetLoanName
       CALL TekProAddNameList
     END
  END

 CALL TekProDisplayHtmlNameList
END[getAccountNames]

PROCEDURE getInPersonRequestFlag
 InPersonRequestFlag=TRUE
 IF FORMAT("9999",GETDATANUMBER(GETCONSOLEBRANCH,SYSCONSOLENUM)) = "0012" [** CALL CENTER REQUEST]
    THEN InPersonRequestFlag=FALSE
END[getInPersonRequestFlag]

PROCEDURE GetSelectShareOptions
 ValNameInAcct=TRUE
 IF ValNameInAcct=TRUE THEN CALL TekProGetNameInAcctLevel

[ ** START -Update Selection Criteria according CU Business Rules **]
 FOR EACH SHARE WITH SHARE:CLOSEDATE='--/--/--'    
[ ** END -Update Selection Criteria according CU Business Rules **]                  
  DO
    IF ValNameInAcct=FALSE OR NameInAcctLevel=TRUE THEN 
      CALL TekProDisplayShareOption
    ELSE
      DO
        FOR EACH SHARE NAME WITH SHARE NAME:SSN=HtmlVars(RequesterSSN,HtmlFieldValue)
         DO
           CALL TekProDisplayShareOption
         END
      END
  END
END

PROCEDURE GetSelectShareFeeOptions
 ValNameInAcct=TRUE
 IF ValNameInAcct=TRUE THEN CALL TekProGetNameInAcctLevel

[ ** START -Update Selection Criteria according CU Business Rules **]
 FOR EACH SHARE WITH (SHARE:SHARECODE=1 OR SHARE:SHARECODE=0) AND SHARE:IRSCODE=0 
                      AND SHARE:CLOSEDATE='--/--/--'
[ ** END -Update Selection Criteria according CU Business Rules **]  
                      AND SHARE:AVAILABLEBALANCE>=MONEY(VALUE(HtmlVars(StopFee,HtmlFieldValue))) 
  DO
    IF ValNameInAcct=FALSE OR NameInAcctLevel=TRUE THEN 
      CALL TekProDisplayShareOption
    ELSE
      DO
        FOR EACH SHARE NAME WITH SHARE NAME:SSN=HtmlVars(RequesterSSN,HtmlFieldValue)
         DO
           CALL TekProDisplayShareOption
         END
      END
  END
END


[ ** End -Update Selection Criteria according CU Business Rules **]
