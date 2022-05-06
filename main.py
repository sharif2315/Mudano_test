import os
from dotenv import load_dotenv
from pathlib import Path
import requests
import pandas as pd
from sqlalchemy import create_engine

# Loading env variables
dotenv_path = Path('/.env')
load_dotenv(dotenv_path=dotenv_path)

USER = os.getenv('USER')
PASSWORD = os.getenv('PASSWORD')
PORT = os.getenv('PORT')
HOST = os.getenv('HOST')
DATABASE = os.getenv('DATABASE')
conn_string = f'postgresql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}?sslmode=require'

# using Flask to import Dataframe into db tables
engine = create_engine(conn_string)


# getting data from API in JSON format
def get_world_bank_country_data():
    df = None
    # iterating through each page of the results - 6 pages in total
    for page_num in range(6):
        api_url = f'https://api.worldbank.org/v2/country?format=json&page={page_num + 1}'
        json_data = requests.get(api_url).json()
        if df is None:
            df = pd.DataFrame.from_records(json_data[1])
        else:
            new_data_df = pd.DataFrame.from_records(json_data[1])
            frames = [df, new_data_df]
            df = pd.concat(frames)

    df = df.reset_index(drop=True)


    # updating the values of columns (region, adminregion, incomeLevel, lendingType) as they are in dict format
    for index, row in df.iterrows():
        row['region'] = row['region']['value']
        row['adminregion'] = row['adminregion']['value']
        row['incomeLevel'] = row['incomeLevel']['value']
        row['lendingType'] = row['lendingType']['value']

    # changing col data types
    df = df.astype({
        'id': 'string',
        'iso2Code': 'string',
        'name': 'string',
        'region': 'string',
        'adminregion': 'string',
        'incomeLevel': 'string',
        'lendingType': 'string',
        'capitalCity': 'string'
    })
    df['longitude'] = pd.to_numeric(df['longitude'], errors='coerce')
    df['latitude'] = pd.to_numeric(df['longitude'], errors='coerce')

    # Importing data from dataframe into a Database Table
    df.to_sql('world_bank_country_data_upd', engine, if_exists='replace')


# Getting GDP data
def get_gdp_data():
    # getting data from Excel file
    xl = pd.ExcelFile("GEPEXCEL.xlsx")
    sheet_names = xl.sheet_names
    df_xl = xl.parse(sheet_names[0])

    # renaming columns to remove whitespaces
    df_xl = df_xl.rename(
        columns={'Country Name': 'countryName', 'Country Code': 'countryCode', 'Indicator Name': 'indicatorName',
                 'Indicator Code': 'indicatorCode'})


    # changing col data types
    df_xl = df_xl.astype({
        'countryName': 'string',
        'countryCode': 'string',
        'indicatorName': 'string',
        'indicatorCode': 'string',
    })
    df_xl['2019'] = pd.to_numeric(df_xl['2019'], errors='coerce')
    df_xl['2020'] = pd.to_numeric(df_xl['2020'], errors='coerce')
    df_xl['2021'] = pd.to_numeric(df_xl['2021'], errors='coerce')
    df_xl['2022'] = pd.to_numeric(df_xl['2022'], errors='coerce')
    df_xl['2023'] = pd.to_numeric(df_xl['2023'], errors='coerce')

    # Importing data from dataframe into a Database Table
    df_xl.to_sql('gdp_data', engine, if_exists='replace')


if __name__ == '__main__':
    get_world_bank_country_data()
    get_gdp_data()
