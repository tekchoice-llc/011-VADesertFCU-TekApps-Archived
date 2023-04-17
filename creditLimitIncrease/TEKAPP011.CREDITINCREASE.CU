[*****************************************************************************
 IMPORTANT NOTICE

 By downloading, installing, or otherwise using any tek-apps, software, documentation, or 
 other materials made available by TekChoice, LLC, through this repository, you acknowledge
 that you have read, understand, and agree to be bound by the End User License Agreement (the "EULA")
 included in these downloaded files as EULA.txt and made available at www.tekchoice.com/EULA.

 SPECFILENAME: TEKAPP011.CREDITINCREASE.CU
 VERSION: 001
 COPYRIGHT: TekChoice, LLC 2020 © 

 Sections:      1. SET Credit Union TekApp Variables

                2. Custom Credit Union TekApp Business Rules
                   Update procedure accordingly between Start and End
                   ** Start -Update **
                   CU custom code
                   ** End -Update **  
             
 Programmed:    TekChoice LLC

 Modified:      06.24.20 Original Source


********************************************************************************]

[ **********************************************************************
               1. SET Credit Union TekApp Variables

 *********************************************************************** ]
PROCEDURE setCrediUnionVars

[ *** Access Security Group Validation *** ]
[ *** Set validateSGFlag to TRUE if Access Security Group Validation is enforce otherwise FALSE *** ]
 validateSGFlag=FALSE
 UserNotAllowTxT="Access Denied"

[ *** Credit Report Msg *** ]
 CreditReportPullTxtYes="a new credit report was pulled"
 CreditReportPullTxtNo="a credit report was not pulled"
 HtmlVars(HtmlCreditReportPullTxt,HtmlFieldValue)=CreditReportPullTxtNo

[ *** Forms **** ]
 HasPDFForms=FALSE
 ApprovalPDFForm="PDF.CreditLimitIncrease"
 DeniedPDFForm="PDF.TEKLBVA086.742"

[ *** Workflow field labels **** ]
 HtmlVars(HtmlOriginalCreditScore,HtmlFieldLabel)="Original Credit Score"
 HtmlVars(HtmlRecentCreditScore,HtmlFieldLabel)="Most Recent Credit Score"
 HtmlVars(HtmlNewAnnualIncome,HtmlFieldLabel)="New Annual Income"
 HtmlVars(HtmlGrossMonthlyPay,HtmlFieldLabel)="Gross Monthly Pay"
 HtmlVars(HtmlLADate,HtmlFieldLabel)="Date of Last Application"
 HtmlVars(HtmlLACreditScore,HtmlFieldLabel)="Application Credit Score"
 HtmlVars(HtmlLAIncome,HtmlFieldLabel)="Income" 
 HtmlVars(HtmlLADebtRatio1,HtmlFieldLabel)="Debt Ratio"
 HtmlVars(HtmlLADebtRatio2,HtmlFieldLabel)="Proposed Debt Ratio" 
 HtmlVars(HtmlLADebtRatio3,HtmlFieldLabel)="UER"
 HtmlVars(HtmlLAProposedUER,HtmlFieldLabel)="Proposed UER"
 HtmlVars(HtmlLoanID,HtmlFieldLabel)="Select a Credit Card"
 HtmlVars(HtmlCurrentCreditLimit,HtmlFieldLabel)="Current Credit Limit"

 HtmlVars(HtmlStreet,HtmlFieldLabel)="Street"
 HtmlVars(HtmlExtraAddress,HtmlFieldLabel)="Extra Address"
 HtmlVars(HtmlCity,HtmlFieldLabel)="City"
 HtmlVars(HtmlState,HtmlFieldLabel)="State"
 HtmlVars(HtmlZipCode,HtmlFieldLabel)="Zip Code"

 HtmlVars(HtmlFirst,HtmlFieldLabel)="First"
 HtmlVars(HtmlLast,HtmlFieldLabel)="Last"
 HtmlVars(HtmlMiddle,HtmlFieldLabel)="Middle"
 HtmlVars(HtmlMobilePhone,HtmlFieldLabel)="Mobile Phone"
 HtmlVars(HtmlEmail,HtmlFieldLabel)="Email"

 HtmlVars(HtmlNewLimit,HtmlFieldLabel)="New Limit"
 HtmlVars(HtmlLoanSelected,HtmlFieldLabel)="Loan" 
 HtmlVars(HtmlResquestStatus,HtmlFieldLabel)="Status"
 HtmlVars(HtmlAccountNoteTxt1,HtmlFieldLabel)="Text Line 1"
 HtmlVars(HtmlAccountNoteTxt2,HtmlFieldLabel)="Text Line 2"
 HtmlVars(HtmlAccountNoteTxt3,HtmlFieldLabel)="Text Line 3"
 HtmlVars(HtmlAccountNoteTxt4,HtmlFieldLabel)="Text Line 4"
 HtmlVars(HtmlAccountNoteTxt5,HtmlFieldLabel)="Text Line 5"
 HtmlVars(RequesterLocator,HtmlFieldLabel)="Requester"

[********************************************************************************** 
   PDF CU Procedure Path
   Example(s)
     TekAppPDFProcedure="http://www.mywebsite.com/myAppProcedure.pdf"
     TekAppPDFProcedure="file://///server/path/myAppProcedure.pdf"
*********************************************************************************** ] 
 TekAppPDFProcedure="AppProcedure.pdf"

[ *** Set to TRUE/FALSE to enable/disable logging *** ]
 TekAppTranLog=TRUE

END[setCrediUnionVars]

[ **********************************************************************
              2. Custom Credit Union TekApp Business Rules

 *********************************************************************** ]

PROCEDURE getAccountNames
 CALL TekProClearNameList

[ ** START -Update Selection Criteria according CU Business Rules **]
 FOR EACH NAME WITH (NAME:TYPE=0) AND NAME:EXPIRATIONDATE='--/--/--'
[ ** END -Update Selection Criteria according CU Business Rules **]  
  DO
    CALL TekProSetAcctName
    CALL TekProAddNameList
  END

 FOR EACH LOAN WITH LOAN:ID=HtmlVars(HtmlLoanID,HtmlFieldValue)
  DO
   FOR EACH LOAN NAME WITH LOAN NAME:TYPE=1
    DO
     CALL TekProSetLoanName
     CALL TekProAddNameList
    END
  END

 CALL TekProDisplayHtmlNameList
END[getAccountNames]

PROCEDURE validateSG
 [ *** Validate Episys Security Group *** ]
 validateSGFlag=FALSE
 
 IF GETDATANUMBER(GETUSERPRIVILEGEGROUP,SYSUSERNUMBER,2)=1 OR
    GETDATANUMBER(GETUSERPRIVILEGEGROUP,SYSUSERNUMBER,50)=1 THEN validateSGFlag=TRUE

 IF validateSGFlag=FALSE THEN
  DO
   POPUPMESSAGE(0,UserNotAllowTxT)
   TERMINATE
  END
END[validateSG]
