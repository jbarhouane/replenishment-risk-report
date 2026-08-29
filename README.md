# Lead-Time Adjusted Replenishment Risk Report

This SQL Server and Power BI project uses synthetic retail sales, inventory, product, store, and vendor data to identify active store/SKU combinations at risk of stockouts or replenishment shortages.

The SQL logic compares current available inventory—defined as on-hand plus on-order quantity—against prior-year demand for the corresponding selling window. The demand window is extended by vendor lead time so the report can identify products that may not be replenished in time to meet expected demand.

The SQL output is loaded into Power BI and presented through an interactive operational dashboard for reviewing replenishment risk by store and product.

## Business Logic

For each active store/SKU combination, the report:

- Calculates available inventory as on-hand quantity plus on-order quantity.
- Calculates prior-year demand for the equivalent selling period.
- Extends the demand window by seven days plus vendor lead time.
- Replaces missing, zero, or invalid vendor lead times with a default lead time.
- Calculates a demand coverage ratio comparing available inventory with prior-year demand.
- Calculates projected shortage quantity.
- Classifies items as:
  - **Out of Stock** when on-hand quantity is zero or below.
  - **Replenishment Risk** when available inventory is below expected demand.

## Power BI Dashboard

The Power BI report provides an interactive view of the SQL-generated replenishment risk dataset.

### Dashboard Features

- KPI cards for:
  - Replenishment Risk
  - Demand Coverage
  - Projected Shortage Units
  - At-Risk Store/SKUs
  - Out-of-Stock Store/SKUs
- Store dropdown filtering
- Product ID search
- Risk status filtering
- Dynamic as-of date
- Store/SKU-level replenishment risk detail
- Top stores by replenishment risk
- Conditional formatting for:
  - Out-of-stock items
  - Replenishment-risk items
  - Projected shortages
  - Inventory availability
- Interactive filtering across dashboard visuals

## Skills Demonstrated

### SQL Server
- T-SQL
- Common Table Expressions (CTEs)
- Multi-table joins
- Aggregation
- Date and rolling-window logic
- NULL and invalid-value handling
- CASE expressions
- Inventory and replenishment analysis
- Exception reporting
- Store/SKU-level operational reporting

### Power BI
- SQL Server data integration
- DAX measures
- Calculated columns
- KPI development
- Interactive slicers and input filtering
- Conditional formatting
- Table and chart design
- Operational dashboard development
- Dynamic filter context

## Project Workflow

SQL Server  
↓  
Lead-time and prior-year demand calculations  
↓  
Store/SKU replenishment risk identification  
↓  
Power BI data model  
↓  
DAX measures and interactive reporting  
↓  
Operational replenishment risk dashboard

## Data

All data used in this project is synthetic and was created for portfolio and demonstration purposes. No production, employer, customer, or proprietary data is included.
