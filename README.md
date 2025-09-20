E-Commerce Database Management System
Overview
A comprehensive relational database system designed for managing all aspects of an e-commerce platform. This system handles customer information, product catalog, orders, payments, inventory, and more with robust data integrity and relationships.

Database Schema
Core Tables
customers - Stores customer information and authentication details

addresses - Manages customer addresses (billing and shipping)

categories - Product categorization with hierarchical support

products - Complete product information with inventory tracking

orders - Main order information and status tracking

order_items - Individual items within each order

payments - Payment transaction records and status

reviews - Customer product reviews and ratings

Supporting Tables
product_images - Product image management

wishlist - Customer wishlist functionality

coupons - Discount and promotion system

order_coupons - Many-to-many relationship between orders and coupons

inventory_log - Comprehensive inventory change tracking

shipping_methods - Shipping options and pricing

order_shipments - Order shipment tracking and status
