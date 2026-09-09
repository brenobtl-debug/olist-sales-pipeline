import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import create_engine

DB_USER = 'root'
DB_PASSWORD = 'password_here'
DB_HOST = 'localhost'
DB_PORT = '3306'
DB_NAME = 'olist_db'

connection_url = f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(connection_url)

query = """
SELECT 
    DATE_FORMAT(orders.order_purchase_timestamp, '%Y-%m') AS order_period,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    ROUND(SUM(order_items.price), 2) AS product_revenue,
    ROUND(SUM(order_items.freight_value), 2) AS total_freight,
    ROUND(SUM(order_items.price + order_items.freight_value), 2) AS total_revenue,
    ROUND(SUM(order_items.price + order_items.freight_value) / COUNT(DISTINCT orders.order_id), 2) AS average_ticket
FROM orders
JOIN order_items 
    ON orders.order_id = order_items.order_id
WHERE orders.order_status = 'delivered'
GROUP BY DATE_FORMAT(orders.order_purchase_timestamp, '%Y-%m')
ORDER BY order_period ASC;
"""

df = pd.read_sql(query, con=engine)
df = pd.read_sql(query, con=engine)
df = df[(df["order_period"] >= "2017-01") & (df["order_period"] <= "2018-08")]


plt.figure(figsize=(10, 5))
plt.plot(df["order_period"], df["total_revenue"], marker="o", color="blue")
plt.title("Monthly Revenue — Olist (2017 to 2018)")
plt.xlabel("Month")
plt.ylabel("Total Revenue (R$)")
plt.xticks(rotation=45)
plt.grid(True)
plt.tight_layout()


plt.savefig("monthly_metrics.png")
plt.show()