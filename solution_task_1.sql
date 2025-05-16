/* 
 * SQL ASSIGNMENT SOLUTION by SHIVAM JAISWAL
 */


-- TASK 1: ENQUIRY AND TRANSACTION COUNTS (WITHOUT USING JOIN)


/*
 * APPROACH:
 * 1. Count enquiries and transactions separately
 * 2. Combine results with UNION ALL
 * 3. Aggregate the combined counts
 */


-- First CTE: Count enquiries per user per date
-- Adds count_txns=0 as placeholder for consistent structure
WITH enquiry_stats AS (
    SELECT 
        user_id,
        date,
        COUNT(*) AS count_enqs,  -- Actual count of enquiries
        0 AS count_txns          -- Placeholder (no transactions in this CTE but need to combine in next CTE)
    FROM enquiries
    GROUP BY user_id, date  -- Group by user and date
),

-- Second CTE: Count transactions per user per date
-- Adds count_enqs=0 as placeholder for consistent structure
txn_stats AS (
    SELECT 
        user_id,
        date,
        0 AS count_enqs,         -- Placeholder (no enquiries in this CTE)
        COUNT(*) AS count_txns   -- Actual count of transactions
    FROM txns
    GROUP BY user_id, date  -- Group by user and date
),

-- Third CTE: Combine both datasets vertically
-- UNION ALL preserves all rows from both tables
combined_stats AS (
    SELECT * FROM enquiry_stats
    UNION ALL     -- Not using UNION to avoid duplicate removal
    SELECT * FROM txn_stats
)

-- Final output: Sum the combined counts (Schema same as Expected)
SELECT 
    user_id,
    date,
    SUM(count_enqs) AS count_enqs,  -- Total enquiries per user/date
    SUM(count_txns) AS count_txns   -- Total transactions per user/date
FROM combined_stats
GROUP BY user_id, date  -- Regroup after combining
ORDER BY user_id, date; -- Sort for readability

