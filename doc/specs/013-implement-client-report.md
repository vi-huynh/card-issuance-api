## As Client 

### 13. Generate report for spending and cancellations
**Requirements**
- Client can generate a report scoped to their own account: total cards issued, total spend, total cancellations, within a date range.
- Client cannot view other clients' report data.

**Scenarios**
- Given a client selects a date range, when they generate their report, then it shows their total spend, cards issued, and cancellations for that period only.
- Given a client has no activity in the selected date range, when they generate the report, then it shows zero values rather than an error.
- Given a client requests a report, when the data is compiled, then only cards where `cards.client_id` matches the authenticated client are included.