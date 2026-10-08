import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta
from pathlib import Path

# --------------------------------------------------
# Configuration
# --------------------------------------------------

fake = Faker("en_IN")
Faker.seed(42)
np.random.seed(42)
random.seed(42)

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
DATA_DIR.mkdir(exist_ok=True)

NUM_CUSTOMERS = 10_000
NUM_PRODUCTS = 500
NUM_ORDERS = 30_000

START_DATE = datetime(2024, 1, 1)
END_DATE = datetime(2025, 12, 31)


locations = {
    "Maharashtra": [
        "Mumbai", "Pune", "Nagpur", "Nashik", "Aurangabad"
    ],
    "Karnataka": [
        "Bengaluru", "Mysuru", "Mangaluru", "Hubballi"
    ],
    "Delhi": [
        "New Delhi"
    ],
    "Tamil Nadu": [
        "Chennai", "Coimbatore", "Madurai", "Salem"
    ],
    "Gujarat": [
        "Ahmedabad", "Surat", "Vadodara", "Rajkot"
    ],
    "Telangana": [
        "Hyderabad", "Warangal"
    ],
    "West Bengal": [
        "Kolkata", "Durgapur"
    ],
    "Uttar Pradesh": [
        "Lucknow", "Kanpur", "Noida", "Agra", "Varanasi"
    ],
    "Rajasthan": [
        "Jaipur", "Jodhpur", "Udaipur"
    ],
    "Kerala": [
        "Kochi", "Thiruvananthapuram", "Kozhikode"
    ]
}

# --------------------------------------------------
# 1. Generate Customers
# --------------------------------------------------

print("Generating customers...")

customer_rows = []

all_states = list(locations.keys())

for customer_id in range(1, NUM_CUSTOMERS + 1):

    state = random.choice(all_states)
    city = random.choice(locations[state])

    signup_date = fake.date_between(
        start_date="-3y",
        end_date="-30d"
    )

    customer_rows.append({
        "customer_id": customer_id,
        "customer_name": fake.name(),
        "email": fake.email(),
        "gender": random.choice(["Male", "Female", "Other"]),
        "age": random.randint(18, 65),
        "city": city,
        "state": state,
        "signup_date": signup_date
    })

customers = pd.DataFrame(customer_rows)

customers.to_csv(
    DATA_DIR / "customers.csv",
    index=False
)



print("Generating products...")

product_categories = {
    "Electronics": [
        "Smartphone",
        "Laptop",
        "Tablet",
        "Headphones",
        "Smartwatch",
        "Bluetooth Speaker"
    ],
    "Home & Kitchen": [
        "Mixer",
        "Cookware",
        "Bedsheet",
        "Furniture",
        "Kitchen Appliance",
        "Storage"
    ],
    "Fashion": [
        "T-Shirt",
        "Jeans",
        "Shoes",
        "Dress",
        "Jacket",
        "Accessories"
    ],
    "Beauty": [
        "Skincare",
        "Makeup",
        "Haircare",
        "Perfume"
    ],
    "Sports": [
        "Cricket Equipment",
        "Fitness Equipment",
        "Running Shoes",
        "Sportswear"
    ],
    "Books": [
        "Fiction",
        "Non-Fiction",
        "Technical",
        "Academic"
    ]
}

product_rows = []

product_id = 1

for category, subcategories in product_categories.items():

    for _ in range(
        NUM_PRODUCTS // len(product_categories)
    ):

        subcategory = random.choice(subcategories)

        product_name = f"{fake.word().title()} {subcategory}"

        cost_price = round(
            random.uniform(200, 15000),
            2
        )

        selling_price = round(
            cost_price * random.uniform(1.15, 1.60),
            2
        )

        product_rows.append({
            "product_id": product_id,
            "product_name": product_name,
            "category": category,
            "subcategory": subcategory,
            "cost_price": cost_price,
            "selling_price": selling_price
        })

        product_id += 1

products = pd.DataFrame(product_rows)

products.to_csv(
    DATA_DIR / "products.csv",
    index=False
)


print("Generating orders...")

order_rows = []

statuses = [
    "Delivered",
    "Delivered",
    "Delivered",
    "Delivered",
    "Shipped",
    "Processing",
    "Cancelled",
    "Returned"
]

payment_methods = [
    "UPI",
    "Credit Card",
    "Debit Card",
    "Net Banking",
    "Cash on Delivery",
    "Wallet"
]

customer_ids = customers["customer_id"].tolist()

for order_id in range(1, NUM_ORDERS + 1):

    customer_id = random.choice(customer_ids)

    order_date = fake.date_time_between(
        start_date=START_DATE,
        end_date=END_DATE
    )

    status = random.choice(statuses)

    payment_method = random.choice(
        payment_methods
    )

    shipping_days = random.randint(2, 8)

    delivery_date = (
        order_date + timedelta(days=shipping_days)
        if status == "Delivered"
        else None
    )

    order_rows.append({
        "order_id": order_id,
        "customer_id": customer_id,
        "order_date": order_date,
        "status": status,
        "payment_method": payment_method,
        "shipping_days": shipping_days,
        "delivery_date": delivery_date
    })

orders = pd.DataFrame(order_rows)

orders.to_csv(
    DATA_DIR / "orders.csv",
    index=False
)


print("Generating order items...")

order_item_rows = []

for order_id in range(1, NUM_ORDERS + 1):

    number_of_products = random.randint(1, 4)

    selected_products = random.sample(
        products["product_id"].tolist(),
        number_of_products
    )

    for product_id in selected_products:

        product = products[
            products["product_id"] == product_id
        ].iloc[0]

        quantity = random.randint(1, 3)

        discount = random.choice([
            0,
            5,
            10,
            15,
            20,
            25
        ])

        unit_price = product["selling_price"]

        discount_amount = (
            unit_price * discount / 100
        )

        final_price = (
            unit_price - discount_amount
        )

        revenue = final_price * quantity

        cost = product["cost_price"] * quantity

        profit = revenue - cost

        order_item_rows.append({
            "order_item_id": len(order_item_rows) + 1,
            "order_id": order_id,
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": round(unit_price, 2),
            "discount_percent": discount,
            "revenue": round(revenue, 2),
            "profit": round(profit, 2)
        })

order_items = pd.DataFrame(order_item_rows)

order_items.to_csv(
    DATA_DIR / "order_items.csv",
    index=False
)

print("\nData generation completed!")
print("--------------------------------")
print(f"Customers    : {len(customers):,}")
print(f"Products     : {len(products):,}")
print(f"Orders       : {len(orders):,}")
print(f"Order Items  : {len(order_items):,}")
print("--------------------------------")

print("\nFiles created:")

for file in DATA_DIR.glob("*.csv"):
    print(f"  ✓ {file.name}")

print("\nDataset location:")
print(DATA_DIR)
