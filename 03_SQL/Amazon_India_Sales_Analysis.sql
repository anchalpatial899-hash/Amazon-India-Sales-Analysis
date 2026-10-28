USE amazon_india_sales;
SELECT *
FROM amazon_sales
LIMIT 10;

SELECT
    Order_ID,
    Date,
    Product_Category,
    Product_Name,
    Total_Sales_INR
FROM amazon_sales
LIMIT 10;

# Which individual orders have the highest sales value?
SELECT
    Order_ID,
    Product_Category,
    Product_Name,
    Total_Sales_INR
FROM amazon_sales
ORDER BY Total_Sales_INR DESC
LIMIT 10;

# Which product categories generate the most sales?
SELECT
    Product_Category,
    SUM(Total_Sales_INR) AS Total_Sales
FROM amazon_sales
GROUP BY Product_Category
ORDER BY Total_Sales DESC;

# How many orders does each product category have?
SELECT
    Product_Category,
    COUNT(Order_ID) AS Total_Orders
FROM amazon_sales
GROUP BY Product_Category
ORDER BY Total_Orders DESC;

# What is the average sales value per order in each category?
SELECT
    Product_Category,
    ROUND(AVG(Total_Sales_INR), 2) AS Average_Order_Value
FROM amazon_sales
GROUP BY Product_Category
ORDER BY Average_Order_Value DESC;

# How many orders were returned?
SELECT
    COUNT(*) AS Returned_Orders
FROM amazon_sales
WHERE Delivery_Status = 'Returned';

# How much sales came from successfully delivered orders?
SELECT
    ROUND(SUM(Total_Sales_INR), 2) AS Delivered_Sales
FROM amazon_sales
WHERE Delivery_Status = 'Delivered';

# How can we classify individual orders into low, medium, and high-value orders?
SELECT
    Order_ID,
    Total_Sales_INR,
    CASE
        WHEN Total_Sales_INR < 50000 THEN 'Low Value'
        WHEN Total_Sales_INR < 100000 THEN 'Medium Value'
        ELSE 'High Value'
    END AS Order_Value_Category
FROM amazon_sales
LIMIT 20;

# How many orders fall into each order-value category?
SELECT
    CASE
        WHEN Total_Sales_INR < 50000 THEN 'Low Value'
        WHEN Total_Sales_INR < 100000 THEN 'Medium Value'
        ELSE 'High Value'
    END AS Order_Value_Category,
    COUNT(*) AS Number_of_Orders
FROM amazon_sales
GROUP BY Order_Value_Category
ORDER BY Number_of_Orders DESC;

# What is the distribution of delivered, pending, and returned orders?
SELECT
    Delivery_Status,
    COUNT(*) AS Total_Orders,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM amazon_sales),
        2
    ) AS Percentage
FROM amazon_sales
GROUP BY Delivery_Status
ORDER BY Total_Orders DESC;

#How did sales change month by month during 2025?
SELECT
    MONTH(Date) AS Month_Number,
    MONTHNAME(Date) AS Month_Name,
    ROUND(SUM(Total_Sales_INR), 2) AS Total_Sales
FROM amazon_sales
GROUP BY
    MONTH(Date),
    MONTHNAME(Date)
ORDER BY Month_Number;


# Which individual orders have sales higher than the overall average order value?
SELECT
    Order_ID,
    Product_Name,
    Total_Sales_INR
FROM amazon_sales
WHERE Total_Sales_INR > (
    SELECT AVG(Total_Sales_INR)
    FROM amazon_sales
)
ORDER BY Total_Sales_INR DESC;

#Which product categories generate more sales than the average category sales?
SELECT
    Product_Category,
    ROUND(SUM(Total_Sales_INR), 2) AS Category_Sales
FROM amazon_sales
GROUP BY Product_Category
HAVING SUM(Total_Sales_INR) > (
    SELECT AVG(Category_Total)
    FROM (
        SELECT SUM(Total_Sales_INR) AS Category_Total
        FROM amazon_sales
        GROUP BY Product_Category
    ) AS Category_Sales
)
ORDER BY Category_Sales DESC;

# Using a CTE to summarize category sales
WITH Category_Sales AS (
    SELECT
        Product_Category,
        SUM(Total_Sales_INR) AS Total_Sales
    FROM amazon_sales
    GROUP BY Product_Category
)
SELECT
    Product_Category,
    ROUND(Total_Sales, 2) AS Total_Sales
FROM Category_Sales
ORDER BY Total_Sales DESC;


# Rank products by sales
SELECT
    Product_Name,
    SUM(Total_Sales_INR) AS Total_Sales,
    RANK() OVER (ORDER BY SUM(Total_Sales_INR) DESC) AS Sales_Rank
FROM amazon_sales
GROUP BY Product_Name
ORDER BY Sales_Rank;

# Rank products within each category
SELECT
    Product_Category,
    Product_Name,
    SUM(Total_Sales_INR) AS Total_Sales,
    RANK() OVER (
        PARTITION BY Product_Category
        ORDER BY SUM(Total_Sales_INR) DESC
    ) AS Category_Rank
FROM amazon_sales
GROUP BY Product_Category, Product_Name
ORDER BY Product_Category, Category_Rank;

# Running monthly sales total
WITH Monthly_Sales AS (
    SELECT
        MONTH(Date) AS Month_Number,
        MONTHNAME(Date) AS Month_Name,
        SUM(Total_Sales_INR) AS Monthly_Sales
    FROM amazon_sales
    GROUP BY MONTH(Date), MONTHNAME(Date)
)
SELECT
    Month_Number,
    Month_Name,
    ROUND(Monthly_Sales, 2) AS Monthly_Sales,
    ROUND(
        SUM(Monthly_Sales) OVER (
            ORDER BY Month_Number
        ),
        2
    ) AS Running_Total_Sales
FROM Monthly_Sales
ORDER BY Month_Number;


#Which products generate the most revenue?
SELECT
    Product_Name,
    ROUND(SUM(Total_Sales_INR), 2) AS Total_Sales
FROM amazon_sales
GROUP BY Product_Name
ORDER BY Total_Sales DESC
LIMIT 5;

#Which states contribute the most sales?
SELECT
    State,
    ROUND(SUM(Total_Sales_INR), 2) AS Total_Sales
FROM amazon_sales
GROUP BY State
ORDER BY Total_Sales DESC
LIMIT 5;

#Which states have relatively high return rates?
SELECT
    State,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN Delivery_Status = 'Returned' THEN 1
            ELSE 0
        END
    ) AS Returned_Orders,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status = 'Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Return_Rate_Percentage
FROM amazon_sales
GROUP BY State
ORDER BY Return_Rate_Percentage DESC;

# Which product categories have better customer ratings?
SELECT
    Product_Category,
    ROUND(AVG(Review_Rating), 2) AS Average_Rating,
    COUNT(*) AS Total_Reviews
FROM amazon_sales
GROUP BY Product_Category
ORDER BY Average_Rating DESC;

#How frequently are customers purchasing?
SELECT
    Customer_ID,
    COUNT(Order_ID) AS Number_of_Orders,
    ROUND(SUM(Total_Sales_INR), 2) AS Customer_Sales
FROM amazon_sales
GROUP BY Customer_ID
ORDER BY Number_of_Orders DESC, Customer_Sales DESC
LIMIT 10;

# How much of the customer base makes repeat purchases?
WITH Customer_Orders AS (
    SELECT
        Customer_ID,
        COUNT(Order_ID) AS Number_of_Orders
    FROM amazon_sales
    GROUP BY Customer_ID
)
SELECT
    CASE
        WHEN Number_of_Orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS Customer_Type,
    COUNT(*) AS Number_of_Customers
FROM Customer_Orders
GROUP BY Customer_Type
ORDER BY Number_of_Customers DESC;

# How do the product categories compare across sales, orders, average order value, and ratings?
SELECT
    Product_Category,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Total_Sales_INR), 2) AS Total_Sales,
    ROUND(AVG(Total_Sales_INR), 2) AS Average_Order_Value,
    ROUND(AVG(Review_Rating), 2) AS Average_Rating
FROM amazon_sales
GROUP BY Product_Category
ORDER BY Total_Sales DESC;