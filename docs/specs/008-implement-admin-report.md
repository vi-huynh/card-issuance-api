## As Admin

### 8. Generate reports by brand and client
**Requirements**
- Admin can generate a report scoped to a brand: e.g., number of products, cards issued, total sales volume, cancellations, within a date range.
- Admin can generate a report scoped to a client: e.g., cards issued, total spend, cancellations, payout amount (based on `payout_rate`), within a date range.
- Reports support export CSV or on-screen viewing, at minimum on-screen with filterable date range.

**Scenarios**
- Given an admin selects a brand and a date range, when they generate a report, then it shows total products, cards issued, total transaction volume, and cancellations for that brand in the period.
- Given an admin selects a client and a date range, when they generate a report, then it shows total cards issued, total spend, cancellations, and computed payout for that client in the period.
- Given no data exists for the selected brand/client/date range, when the report is generated, then it displays a zero-value/empty report rather than an error.
- Given an admin exports a report, when the export completes, then the downloaded file matches the on-screen totals.