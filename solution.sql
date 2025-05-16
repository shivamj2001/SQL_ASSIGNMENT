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



-- TASK 2: ENQUIRY CONVERSION MAPPING (QUALIFY ALTERNATIVE)


/*
 * APPROACH:
 * 1. Find all valid transaction-enquiry pairs (same user, within 30 days)
 * 2. For each transaction, keep only the earliest qualifying enquiry
 * 3. Group transactions by their linked enquiry
 * 4. Format output with arrays
 */


-- First CTE: Find all potential transaction-enquiry matches
WITH potential_pairs AS (
    SELECT 
        t.txn_id,
        t.user_id,
        t.date AS txn_date,
        e.enquiry_id,
        e.date AS enquiry_date,
        -- Row Number assigned for enquiries by date for each transaction
        ROW_NUMBER() OVER (
            PARTITION BY t.txn_id  -- Group by transaction
            ORDER BY e.date        -- Sort enquiries by date
        ) AS row_num
    FROM txns t
    JOIN enquiries e ON 
        t.user_id = e.user_id AND          -- Same user
        e.date <= t.date AND               -- Enquiry before transaction
        e.date >= t.date - INTERVAL 30 DAY -- Within 30 day window
),

-- Second CTE: Filter to keep only earliest enquiry per transaction
valid_pairs AS (
    SELECT 
        txn_id,
        enquiry_id
    FROM potential_pairs
    WHERE row_num = 1  -- Only keep the first (earliest) enquiry
),

-- Third CTE: Group transactions by their linked enquiry
enquiry_mapping AS (
    SELECT 
        e.enquiry_id,
        e.date,
        e.user_id,
        -- Aggregate all transaction IDs into an array (ARRAY_AGG function that takes a set of values and returns them as a single array)
        ARRAY_AGG(vp.txn_id) AS txn_ids
    FROM enquiries e
    -- LEFT JOIN preserves enquiries with no transactions
    LEFT JOIN valid_pairs vp ON e.enquiry_id = vp.enquiry_id
    GROUP BY e.enquiry_id, e.date, e.user_id      -- Group by each unique enquiry so we can aggregate all linked transactions per enquiry
)

-- Final output with formatted arrays (Same as Expected schema)
SELECT 
    enquiry_id,
    date,
    user_id,
    -- Convert NULL to empty array for unconverted enquiries
    COALESCE(txn_ids, []) AS txn_ids
FROM enquiry_mapping
ORDER BY user_id, date;
