----------------------------------------------------------------------------------------------------
/*
	Project:		Lead-Time Adjusted Replenishment Risk Report
	Database:		PortfolioInventory
	
	Author:			Jessica Barhouane

	Create Date:	July 4th, 2026

	Purpose:		Identify active store/SKU combinations that may be at risk of stockouts or replenishment shortages.
					The report compares current available inventory against prior-year demand for the same selling window,
					adjusted by vendor lead time.
	
	Notes:
				  - Available quantity = on-hand quantity + on-order quantity.
				  - Prior-year demand uses the same date window from one year ago.
				  - The demand window extends 7 days plus vendor lead time to account for replenishment timing.
				  - Missing, zero, or invalid lead times are replaced with a default lead time.
				  - This project uses synthetic portfolio data.
*/
----------------------------------------------------------------------------------------------------
use PortfolioInventory;
----------------------------------------------------------------------------------------------------
declare @as_of_date date		= cast(getdate() as date);
declare @default_leadtime int	= 2;
----------------------------------------------------------------------------------------------------
/*
	CTE: product_leadtime
	Standardizes vendor lead time by product.
	If vendor lead time is missing or invalid, the report uses @default_leadtime.
*/
----------------------------------------------------------------------------------------------------
;with product_leadtime as (
	select
		  p.ProductID
		, case
			when isnull(v.DefaultLeadTimeDays, 0) <= 0 then @default_leadtime
			else v.DefaultLeadTimeDays
		 end as LeadTimeDays
		, case 
			when isnull(v.DefaultLeadTimeDays, 0) <= 0 then 1
			else 0
		  end as UsedDefaultLeadTime
	from masterdata.Products p 

	left join masterdata.Vendors v
		on p.VendorID = v.VendorID
)
----------------------------------------------------------------------------------------------------
/*
	CTE: sales_history
	Calculates prior-year demand for each store/SKU.
	The date window starts on the same date last year and includes the as-of date through 7 days plus 
	lead time. The end date is exclusive, so one day is added to include the final day in the window.
*/
----------------------------------------------------------------------------------------------------
, sales_history as (
	select
		  s.StoreID
		, o.ProductID
		, sum(o.Quantity)											as last_year_demand
		, pl.LeadTimeDays
		, pl.UsedDefaultLeadTime
	from sales.SalesOrderLines o

	inner join sales.SalesOrders s
		on o.SalesOrderID	= s.SalesOrderID

	inner join product_leadtime pl
		on o.ProductID = pl.ProductID

	where s.SaleDate >= dateadd(year, -1, @as_of_date) 
		and s.SaleDate < dateadd(
			  day
			, 7 + pl.LeadTimeDays + 1
			, dateadd(year, -1, @as_of_date)
		) 

	group by  s.StoreID
			, o.ProductID
			, pl.LeadTimeDays
			, pl.UsedDefaultLeadTime
)
----------------------------------------------------------------------------------------------------
/*
	Final Output:
	Returns active store/SKU combinations where:
		1. Available inventory is less than prior-year demand, or
		2. The product is currently out of stock.
*/
----------------------------------------------------------------------------------------------------
select 
	  s.StoreCode
	, concat(s.City, ', ', s.StateCode)			as store_location
	, p.SKU
	, p.ProductName
	, ib.OnHandQuantity
	, ib.OnOrderQuantity
	, ib.OnHandQuantity + ib.OnOrderQuantity	as available_quantity
	, sh.last_year_demand	
	, sh.LeadTimeDays
	, sh.UsedDefaultLeadTime
	, cast(
		(ib.OnHandQuantity + ib.OnOrderQuantity) * 1.0 
		/ nullif(sh.last_year_demand, 0)
	  as decimal(10,4))							as demand_coverage_ratio
	, sh.last_year_demand 
		- (ib.OnHandQuantity 
			+ ib.OnOrderQuantity)				as projected_shortage_qty
	, case
        when ib.OnHandQuantity <= 0	then 'OUT_OF_STOCK'
        when ib.OnHandQuantity + ib.OnOrderQuantity < sh.last_year_demand then 'REPLENISHMENT_RISK'
      end as risk_status
from inventory.InventoryBalances ib 

inner join masterdata.Products p	
	on  ib.ProductID	= p.ProductID

inner join masterdata.Stores s
	on  s.StoreID		= ib.StoreID

inner join sales_history sh
	on  ib.StoreID		= sh.StoreID
	and ib.ProductID	= sh.ProductID

where p.ProductStatus = 'ACTIVE'
	and s.IsActive = 1
	and (ib.OnHandQuantity + ib.OnOrderQuantity < sh.last_year_demand
		or ib.OnHandQuantity <= 0)

order by  projected_shortage_qty desc
		, StoreCode
		, p.SKU
----------------------------------------------------------------------------------------------------