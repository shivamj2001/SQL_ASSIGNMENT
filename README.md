# SQL Assignment Solution by Shivam Jaiswal



### Task 1: Counting Enquiries and Transactions

**My Thought Process:**
1. **Understanding Requirements**:
   - Need separate counts per user per day
   - Cannot use JOIN between tables
   - Must maintain clear structure accoding to expected schema

2. **Solution Design**:
   - Break into two separate counts (enquiries and transactions)
   - Use zero placeholders to maintain consistent columns
   - Combine vertically with UNION ALL
   - Aggregate the combined data

3. **Implementation Steps**:
   ```sql
   -- Step 1: Count enquiries (with txns=0 placeholder)
   -- Step 2: Count transactions (with enqs=0 placeholder)
   -- Step 3: Combine with UNION ALL
   -- Step 4: Sum counts by user and date
   ```

4. **Why This Works**:
   - UNION ALL preserves all records from both tables
   - Zero placeholders ensure correct column structure
   - Final aggregation merges the partial counts

### Task 1: Enquiry and Transaction Counts (Output)
![task1_output](Op_Task_1.png)



### Task 2: Enquiry Conversion Mapping

**My Thought Process:**
1. **Understanding Requirements**:
   - Link transactions to earliest qualifying enquiry
   - 30-day conversion window
   - Array output format

2. **Solution Design**:
   - Find all valid transaction-enquiry pairs (same user, within 30 days)
   - For each transaction, keep only the earliest qualifying enquiry.
   - Group transactions by their earliest linked enquiry.
   - Format with arrays

3. **Implementation Steps**:
   ```sql
   -- Step 1: Find all valid pairs (with row numbers)
   -- Step 2: Filter to row_num=1 (earliest enquiry)
   -- Step 3: Group transactions by enquiry
   -- Step 4: Format output with arrays
   ```

4. **Key Insights**:
   - Window functions to assaign row number that efficiently handle "earliest" requirement by assigning row number .
   - LEFT JOIN preserves unconverted enquiries
   - ARRAY_AGG creates the required output format


### Task 2: Enquiry Conversion Mapping (Output)
![task2_output](Op_Task_2.png)


## Assumptions

- All dates use `YYYY-MM-DD` format with no NULL values in the dataset
- enquiry_id and txn_id are both unique and non-NULL within their respective tables..
- The 30-day window includes the transaction date (Jan 1 - Jan 31 counts as 30 days)
- If a user has no enquiries on a date, `count_enqs` shows 0 and vice-versa.
- Task 2 links transactions only to the earliest qualifying enquiry.
- A transaction can only be linked to **one** enquiry( One to One relationship), but one enquiry can be linked to **multiple** transactions(One to Many relationship).
