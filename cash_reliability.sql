CREATE OR ALTER VIEW vw_cash_estimation_reliability AS
SELECT 
    FORMAT(TRY_CAST(wh.shift_date AS DATE), 'yyyy-MM') AS year_month,
    
    -- Pamainų skaičius pagal tipą
    COUNT(cs.shift_id) AS total_shifts,
    SUM(CASE WHEN cs.is_estimated = 0 THEN 1 ELSE 0 END) AS exact_shifts_count,
    SUM(CASE WHEN cs.is_estimated = 1 THEN 1 ELSE 0 END) AS estimated_shifts_count,
    
    -- Tikslių ir spejamų grynųjų sumos
    ROUND(SUM(CASE WHEN cs.is_estimated = 0 THEN cs.cash_tips_amount ELSE 0 END), 2) AS exact_cash_amount,
    ROUND(SUM(CASE WHEN cs.is_estimated = 1 THEN cs.cash_tips_amount ELSE 0 END), 2) AS estimated_cash_amount,
    
    -- Spėjamų grynųjų dalis procentais (%)
    ROUND(
        SUM(CASE WHEN cs.is_estimated = 1 THEN cs.cash_tips_amount ELSE 0 END) * 100.0 / 
        NULLIF(SUM(cs.cash_tips_amount), 0)
    , 2) AS estimated_cash_pct,
    
    -- Bendra paklaida
    ROUND(SUM(ISNULL(cs.margin_of_error, 0)), 2) AS total_margin_of_error

FROM worked_hours wh
LEFT JOIN cash_tips cs ON wh.shift_id = cs.shift_id
GROUP BY FORMAT(TRY_CAST(wh.shift_date AS DATE), 'yyyy-MM');
GO
SELECT * FROM vw_cash_estimation_reliability ORDER BY year_month;