## As Client 

### 13. Generate report for spending and cancellations
**Requirements**
- Client can generate a report scoped to their own account: total cards, total card issued, total cancelled, within a date range.
- Client cannot view other clients' report data.
- Metric report per group: 
  - Card count(total, issued, cancelled)
  - Total issue amount (sum(amout))
  - Total current_balance 
  - Total redeemed (amout - current_balance)

**Scenarios**
- Given a client selects a date range, when they generate their report, then it shows their total cards issued, and cancelled for that period only.
- Given a client has no activity in the selected date range, when they generate the report, then it shows zero values rather than an error.
- Given a client requests a report, when the data is compiled, then only cards where `cards.client_id` matches the authenticated client are included.