# Cursor vs Set-Based Processing – Comparison Note

## Objective
To compare cursor-based and set-based approaches for identifying policies with lapsed premiums, updating their status, and recording audit information.

## 1. Cursor-Based Processing

- Processes records one at a time.
- Uses `DECLARE CURSOR`, `OPEN`, `FETCH`, and `CLOSE`.
- Updates each eligible policy individually.
- Inserts an audit record for every updated policy.
- Suitable for operations requiring individual row-level processing.

## 2. Set-Based Processing

- Processes multiple records in a single SQL statement.
- Uses the `UPDATE` statement with filtering conditions.
- Uses the `OUTPUT` clause to capture updated records.
- Inserts audit records for all updated policies.
- Reduces repetitive processing and improves efficiency.

## 3. Comparison

| Criteria | Cursor-Based | Set-Based |
|---|---|---|
| Processing | Row by row | Multiple rows |
| Execution | Sequential | Single operation |
| Performance | Generally slower | Generally faster |
| Code complexity | Higher | Lower |
| Resource usage | More overhead | Less overhead |
| Audit logging | Individual inserts | Bulk insert |
| Maintainability | More complex | Easier |

## 4. Conclusion

Set-based processing is generally preferred for handling large volumes of records because it reduces execution overhead and improves performance.

Cursor-based processing is useful when individual record handling is necessary.

For the insurance premium processing scenario, the set-based approach is more efficient for updating multiple lapsed policies, while both approaches provide audit logging and maintain data consistency.