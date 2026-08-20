CREATE OR ALTER VIEW vw_tips_distribution AS
SELECT 
    FORMAT(TRY_CAST(wh.shift_date AS DATE), 'yyyy-MM') AS year_month,
    
    -- Sumos
    ROUND(SUM(ISNULL(cs.cash_tips_amount, 0)), 2) AS total_cash_tips,
    ROUND(SUM(ISNULL(cd.card_tips_net, 0)), 2) AS total_card_tips_net,
    ROUND(SUM(ISNULL(cs.cash_tips_amount, 0) + ISNULL(cd.card_tips_net, 0)), 2) AS total_tips,
    
    -- Procentinė dalis (%)
    ROUND(
        SUM(ISNULL(cs.cash_tips_amount, 0)) * 100.0 / 
        NULLIF(SUM(ISNULL(cs.cash_tips_amount, 0) + ISNULL(cd.card_tips_net, 0)), 0)
    , 2) AS cash_tips_pct,
    
    ROUND(
        SUM(ISNULL(cd.card_tips_net, 0)) * 100.0 / 
        NULLIF(SUM(ISNULL(cs.cash_tips_amount, 0) + ISNULL(cd.card_tips_net, 0)), 0)
    , 2) AS card_tips_pct

FROM worked_hours wh
LEFT JOIN cash_tips cs ON wh.shift_id = cs.shift_id
LEFT JOIN card_tips cd ON wh.shift_id = cd.shift_id
GROUP BY FORMAT(TRY_CAST(wh.shift_date AS DATE), 'yyyy-MM');
GO
SELECT * FROM vw_tips_distribution ORDER BY year_month;