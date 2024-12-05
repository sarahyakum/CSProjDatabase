# CS 4485 Project Database

## Project Overview  
This repo contains all the necessary files to locally set up the database needed for the Student and Professor apps.

---
## 1. Project Structure

### Folders and Files

**SQL/**: 
- create.sql - Has SQL commands to create the tables for the database.
- create_views.sql - Has SQL commands to create the views for the database.
- stored_procedures.sql - Has commands to create the stored procedures for the database.
- load.sql - Has commands to populate the database with fake data.
- Views_Procedures_Descrip.md - Explains all of the views and the stored procedures that are initialized in create_views.sql and stored_procedures.sql, including the inputs and outputs for each.

**Data/**
- FakeDataLink - A link to an excel sheet with all of the fake data that has been loaded into the database broken down in an easy to read format.
- DataDescription.txt - A small description of some of the major patterns in the fake data to help with testing.

---
## 2. Getting Started

### Prerequisites  
- MySQL Server 
- Optional: MySQL Workbench (any editor works)

### Run the Project  
These instructions assume you have already downloaded and configured MySQL Server and your MySQL editor of choice.
You can either download the files and run them on your computer or copy and paste the file contents into your MySQL editor.
The scripts must be run in the following order:
- create.sql
- create_views.sql
- stored_procedures.sql
- load.sql
