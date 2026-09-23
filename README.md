# SQL-Data-Cleaning-Project
End-to-end data cleaning pipeline for public layoffs data using MySQL and Databricks — transforming raw, messy records into clean, business-ready datasets for analysis.

# Layoffs Data Cleaning Pipeline

This project takes publicly available layoffs data and transforms it into a clean, analysis-ready dataset using MySQL and a Databricks notebook.

What it does:

Ingests raw layoffs data (duplicates, inconsistent formatting, nulls, and other real-world data quality issues included)
Cleans and standardizes the dataset — removing duplicates, handling missing/null values, fixing data types and formatting
Produces a business-ready table suitable for downstream analysis or reporting

Tech stack: MySQL, Databricks (Notebook), SQL

Why this project: Built as part of my transition from QA/testing into Data Engineering, focused on practicing real-world ETL/data cleaning workflows — handling nulls, duplicates, and inconsistent data, similar to what you'd encounter in production pipelines.

A couple of things that would make this even stronger if you want to add them:

Specific cleaning steps you did (e.g., "removed exact duplicates using ROW_NUMBER() + CTE", "standardized company/industry names", "converted date strings to DATE type") — recruiters and reviewers love seeing concrete technical detail, not just "cleaned the data"
Dataset source/size (e.g., "based on the public Layoffs 2022 dataset from Kaggle, ~2000 rows")
A before/after snapshot or screenshot in the README
