## As Admin

### 8. Generate reports by brand and client
**Requirements**
- Admins want to generate reports summarizing card issuance activity, grouped/filterable by Brand and Client, to understand volume, value, and status of issued cards across the platform.
- Metric report per group: 
  - Card count(total, issued, cancelled)
  - Total issue amount (sum(amout))
  - Total current_balance 
  - Total redeemed (amout - current_balance)
  
**Scenarios**
- Given an admin selects a brand and a date range, when they generate a report, then it shows card count (total, issued, cancelled), total issued amount, total current balance, and total redeemed for cards whose product belongs to that brand in the period.
- Given an admin selects a client and a date range, when they generate a report, then it shows card count (total, issued, cancelled), total issued amount, total current balance, and total redeemed for that client in the period.
- Given an admin selects both a brand and a client, when they generate a report, then the metrics are limited to cards for that client whose product belongs to that brand.
- Given a client sells products from multiple brands, when an admin generates a brand-scoped report, then only that client's cards whose product belongs to the selected brand are included in the totals.
- Given no cards exist for the selected brand/client/date range, when the report is generated, then all metrics display as zero rather than an error.
- Given an admin generates a report without selecting a date range, when the report is compiled, then it includes all cards to date (or the agreed default range, per requirement).