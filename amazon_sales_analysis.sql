-- Category-wise sales performance
SELECT
    Product_Category,
    SUM(Total_Amount) AS Total_Sales
FROM amazon_india_sales
GROUP BY Product_Category
ORDER BY Total_Sales DESC;
