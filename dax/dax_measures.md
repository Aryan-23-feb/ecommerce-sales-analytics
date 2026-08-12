# DAX Measures

## Total Revenue

```DAX
Total Revenue =
CALCULATE(
    SUMX(
        order_details,
        RELATED(products[price])
            * order_details[quantity]
            * (1 - order_details[discount])
    ),
    orders[order_status] = "Delivered",
    products[Price_Status] = "Valid",
    order_details[Quantity_Status] = "Valid",
    order_details[Discount_Status] = "Valid"
)

## Total Profit

Total Profit =
CALCULATE(
    SUMX(
        order_details,
        (
            RELATED(products[price])
                * (1 - order_details[discount])
                - RELATED(products[cost])
        )
        * order_details[quantity]
    ),
    orders[order_status] = "Delivered",
    products[Price_Status] = "Valid",
    products[Cost_Status] = "Valid",
    order_details[Quantity_Status] = "Valid",
    order_details[Discount_Status] = "Valid"
)

## Average Order Value

Average Order Value =
VAR ValidOrders =
    CALCULATE(
        DISTINCTCOUNT(order_details[order_id]),
        orders[order_status] = "Delivered",
        products[Price_Status] = "Valid",
        order_details[Quantity_Status] = "Valid",
        order_details[Discount_Status] = "Valid"
    )
RETURN
DIVIDE([Total Revenue], ValidOrders)

## Profit Margin %

Profit Margin % =
DIVIDE(
    [Total Profit],
    [Total Revenue],
    0
)

## Total Orders

Total Orders =
DISTINCTCOUNT(orders[order_id])

