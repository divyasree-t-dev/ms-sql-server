
# Day 7 – Set 2: Bank Loan Portfolio

## Join Selection Note

**Database:** SQL Server 2025  
**NoSQL Database:** MongoDB 8.0

## 1. Overview

The Bank Loan Portfolio assignment focuses on analyzing
loans, customers, branches, repayments and guarantors.

SQL JOIN operations and subqueries are used to retrieve
related information from multiple tables.

MongoDB `$lookup` operations are used to combine documents
from different collections.

## 2. SQL Join Selection

### 2.1 INNER JOIN (Equi Join)

**Used in:** Query 1

INNER JOIN retrieves only records that have matching values
in both tables.

It is used to combine loan records with customer and branch
details.

**Reason for Selection:**
Only loans with valid matching customer and branch records
are required in the report.

### 2.2 SELF JOIN

**Used in:** Query 4

A self join joins a table with itself using different aliases.

It is used to identify customers who act as both guarantors
and borrowers.

**Reason for Selection:**
The same Customers table represents two different roles:
guarantor and borrower.

### 2.3 LEFT JOIN

**Used in:** Query 5

LEFT JOIN returns all records from the left table and matching
records from the right table.

It is used to identify branches without any loans.

**Reason for Selection:**
All branches must appear in the result, including branches
that have no matching loan records.

## 3. Subquery Selection

### 3.1 Uncorrelated Subquery

**Used in:** Query 6

An uncorrelated subquery executes independently of the
outer query.

It calculates the average total loan exposure across customers.

The outer query identifies customers whose loan exposure
exceeds that average.

### 3.2 Correlated Subquery

**Used in:** Query 7

A correlated subquery depends on values from the outer query.

It compares each customer's total loan exposure with the
average exposure of customers in the same branch.

### 3.3 EXISTS

**Used in:** Query 8

EXISTS checks whether a subquery returns at least one record.

It verifies whether a customer has at least one loan.

### 3.4 NOT EXISTS

**Used in:** Query 8

NOT EXISTS checks whether a subquery returns no records.

It identifies customers who have loans but no repayments
within the last 60 days.

### 3.5 Nested Subquery

**Used in:** Query 9

A nested subquery contains another subquery inside it.

It calculates the maximum loan amount for each branch
and then calculates the average of those maximum values.

The outer query identifies branches whose highest loan
amount exceeds the bank-wide average.

### 3.6 ANY Operator

**Used in:** Query 10

ANY compares a value with at least one value returned
by a subquery.

It identifies loans whose amount is greater than at least
one loan amount in Branch 1.

### 3.7 ALL Operator

**Used in:** Query 10

ALL compares a value with every value returned by a subquery.

It identifies loans whose amount is greater than every
loan amount in Branch 1.

## 4. MongoDB Join Selection

### 4.1 $lookup with Customers

**Used in:** Pipeline 1

The `$lookup` stage combines loan documents with customer
documents using CustomerID.

`$unwind` converts the matching customer array into
individual documents.

### 4.2 Multiple $lookup Operations

**Used in:** Pipeline 2

Multiple `$lookup` stages combine loans with both customer
and repayment collections.

This provides customer information, repayment details,
total repayment amount and repayment count.

### 4.3 $lookup with Pipeline

**Used in:** Pipeline 3

The pipeline-based `$lookup` retrieves repayment records
for each loan.

`$sort` arranges repayments by date in descending order.

`$limit` selects only the latest repayment.

This helps identify the most recent repayment associated
with each loan.

## 5. Join Selection Summary

| Operation | Purpose |
|-----------|---------|
| INNER JOIN | Retrieve matching records |
| SELF JOIN | Compare different roles in the same table |
| LEFT JOIN | Include unmatched branch records |
| EXISTS | Check whether related records exist |
| NOT EXISTS | Find records without matching records |
| Correlated Subquery | Compare values within the same branch |
| Uncorrelated Subquery | Compare against an overall average |
| ANY | Compare with at least one value |
| ALL | Compare with every value |
| Nested Subquery | Perform multi-level aggregation |
| $lookup | Combine MongoDB collections |

## 6. Conclusion

The assignment demonstrates advanced SQL querying techniques
and MongoDB aggregation pipelines.

SQL joins and subqueries help analyze loan portfolios,
customer exposure, overdue installments and repayment activity.

MongoDB `$lookup` provides equivalent document-level
relationships across collections.

These techniques help banking institutions generate useful
reports and support credit risk analysis.
