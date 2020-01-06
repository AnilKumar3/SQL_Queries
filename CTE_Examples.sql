  -----Showing commulative AdjustmentAmt over AdjustmentID. There are 4 options available here.
  select 
  AdjustmentID, 
  [RemittanceAdviceId],
  AdjustmentAmt,
  SUM(AdjustmentAmt) OVER (order by AdjustmentID) running_total 
  FROM [Aprecon].[dbo].[Adjustment] (nolock)
  where RemittanceAdviceId is not Null

  ---Coalesce function used for comma delimited list
  
  Declare @commaDelimterLst varchar(4000)
  SELECT @commaDelimterLst=COALESCE (@commaDelimterLst+', ','') +CAST (InvoiceID as varchar(4000)) 
  FROM [Aprecon].[dbo].[Adjustment] (nolock)
  PRINT @commaDelimterLst

  --- Recursive Common Table Expression (CTE)

  ;with dates ([Date]) as (
	Select DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()),5) as [Date] --- Anchor member means first member of recurrsive
	union all
	Select dateadd(day,1,[Date])    --- Recursive member
	from  dates
	where [Date] < EOMONTH(GETDATE())     --- untill end of endof month clause
	)
SELECT [Date]
FROM dates
option (maxrecursion 32767)    ---   An incorrectly composed recursive CTE may cause an infinite loop, this option will help to stop after 32767 iterations. 


---CTE Examples

;With CTE_adjustment (AdjustmentID, AdjustmentAmt, AdjustmentReasonName) 
As (
	select AdjustmentID, AdjustmentAmt, AR.AdjustmentReasonName from [dbo].[Adjustment] A
	inner join [dbo].[AdjustmentReason] AR
	on A.AdjustmentReasonID=AR.AdjustmentReasonID
	)
Select AdjustmentAmt, AdjustmentReasonName from CTE_adjustment



----With 2 CTE
;With CTE_adjustment (AdjustmentReasonID, AdjustmentAmt, AdjustmentReasonName) 
As (
	select A.AdjustmentReasonID, AdjustmentAmt, AR.AdjustmentReasonName from [dbo].[Adjustment] A
	inner join [dbo].[AdjustmentReason] AR
	on A.AdjustmentReasonID=AR.AdjustmentReasonID
	),
CTE_Reason (AdjustmentReasonID, AdjustmentBy, AdjustmentReasonName) 
As (
	select AR.AdjustmentReasonID, ARPC.APRUpdateBy, AR.AdjustmentReasonName from [dbo].[AdjustmentReason] AR
	inner join [dbo].[AdjustmentReasonProductCategory] ARPC
	on AR.AdjustmentReasonID=ARPC.AdjustmentReasonID
)
Select ca.AdjustmentAmt, cr.AdjustmentReasonName 
from CTE_adjustment ca
inner join CTE_Reason cr
on ca.AdjustmentReasonID=cr.AdjustmentReasonID

