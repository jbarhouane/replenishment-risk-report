# Lead-Time Adjusted Replenishment Risk Report

This SQL Server project uses synthetic retail sales, inventory, product, store, and vendor data to identify active store/SKU combinations at risk of stockouts or replenishment shortages.

The report compares current available inventory, defined as on-hand plus on-order quantity, against prior-year demand for the same selling window. The demand window is adjusted by vendor lead time so the report can flag products that may not be replenished in time to meet expected demand.

## Skills Demonstrated

- SQL Server
- Common Table Expressions
- Date logic
- Joins and aggregation
- Inventory and replenishment analysis
- Exception reporting
- Handling missing or invalid vendor lead time data
- Store/SKU-level operational reporting