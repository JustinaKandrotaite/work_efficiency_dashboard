CREATE OR ALTER VIEW vw_monthly_income_summary AS
SELECT 
    FORMAT(TRY_CAST(wh.shift_date AS DATE), 'yyyy-MM') AS year_month,
    
    -- 1. Išdirbtos valandos
    SUM(wh.hours_worked) AS total_hours_worked,
    
    -- 2. Bazinė alga (iki 2025-11-01 -> 7.00 €, nuo 2025-11-01 -> 7.50 €)
    ROUND(SUM(
        wh.hours_worked * CASE 
            WHEN TRY_CAST(wh.shift_date AS DATE) < '2025-11-01' THEN 7.00 
            ELSE 7.50 
        END
    ), 2) AS total_base_salary,
    
    -- 3. Grynieji arbatpinigiai
    ROUND(SUM(ISNULL(cs.cash_tips_amount, 0)), 2) AS total_cash_tips,
    
    -- 4. Arbatpinigiai kortele (po mokesčių)
    ROUND(SUM(ISNULL(cd.card_tips_net, 0)), 2) AS total_card_tips_net,
    
    -- 5. Visos pajamos iš viso (Alga + Gryni + Kortelė po mokesčių)
    ROUND(SUM(
        (wh.hours_worked * CASE 
            WHEN TRY_CAST(wh.shift_date AS DATE) < '2025-11-01' THEN 7.00 
            ELSE 7.50 
        END) 
        + ISNULL(cs.cash_tips_amount, 0) 
        + ISNULL(cd.card_tips_net, 0)
    ), 2) AS total_monthly_income,
    
    -- 6. Tikrasis efektyvusis valandinis įkainis
    ROUND(
        SUM(
            (wh.hours_worked * CASE 
                WHEN TRY_CAST(wh.shift_date AS DATE) < '2025-11-01' THEN 7.00 
                ELSE 7.50 
            END) 
            + ISNULL(cs.cash_tips_amount, 0) 
            + ISNULL(cd.card_tips_net, 0)
        ) / NULLIF(SUM(wh.hours_worked), 0)
    , 2) AS effective_hourly_rate

FROM worked_hours wh
LEFT JOIN cash_tips cs ON wh.shift_id = cs.shift_id
LEFT JOIN card_tips cd ON wh.shift_id = cd.shift_id
GROUP BY FORMAT(TRY_CAST(wh.shift_date AS DATE), 'yyyy-MM')
SELECT * FROM vw_monthly_income_summary