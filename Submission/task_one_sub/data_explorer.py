# IMPORT REQUIRED PACKAGES

import pandas as pd
import numpy as np
from IPython.display import display, HTML

#------------------INPUT-------------------#

# INSERT FILENAME
# file_name = 'Tweets_Chatgpt_2023.csv'

#------------------------------------------#

def count_special_characters(df):
    special_characters = r'!?-\|:;#@()+-="{}[]*$%^&€£/~`'
    special_char_count = {}
    columns = df.columns

    for column in columns:
        special_char_count[column] = 0
        for value in df[column]:
            if any(char in special_characters for char in str(value)):
                special_char_count[column] += 1

    return [count for _, count in special_char_count.items()]


def count_rows_with_whitespace(df):
    counts = {}
    for column in df.columns:
        count = df[column].apply(lambda value: isinstance(value, str) and r'\s{2,}' in value).sum()
        counts[column] = count
    return counts.values()


def count_rows_with_breaks(df):
    counts = {}
    for column in df.columns:
        count = df[column].apply(lambda value: isinstance(value, str) and '\n' in value).sum()
        counts[column] = count
    return counts.values()


def format_numbers(value):
    if isinstance(value, (float, int)):
        return "{:,}".format(value)
    else:
        return value


# DATASET ANALYZER FUNCTION

def analyze_dataset(file_name):
    # Determine file format based on file extension
    file_extension = file_name.split('.')[-1].lower()

    # Read the data file
    if file_extension == 'csv':
        df = pd.read_csv(file_name)
    elif file_extension == 'xlsx':
        df = pd.read_excel(file_name)
    elif file_extension == 'json':
        df = pd.read_json(file_name)
    else:
        raise ValueError(f"Unsupported file format: {file_extension}. Only CSV, XLSX, and JSON files are supported.")

    # Get dataset information
    num_columns = len(df.columns)
    num_rows = len(df)
    duplicate_rows = (df.duplicated(keep=False)).sum()
    memory_usage = df.memory_usage().sum()

    # Create dataset table
    dataset_info = pd.DataFrame({
        'Total Columns': [num_columns],
        'Total Rows': [num_rows],
        'Duplicate Rows': [duplicate_rows],
        'Memory Usage': [memory_usage]
    })

    # Get column information
    columns = df.columns.tolist() # Column Names
    data_types = df.dtypes.tolist() # Datatypes
    null_counts = df.isnull().sum().tolist() # NULL count
    na_counts = df.isna().sum().tolist() # NA count

    numeric_columns = df.select_dtypes(include=np.number).columns
    mean_values = df[numeric_columns].mean().round(1).tolist() # Average
    max_values = df[numeric_columns].max().round(1).tolist() # Maximum
    min_values = df[numeric_columns].min().round(1).tolist() # Minimum

    unique_counts = df.nunique().tolist() # Unique values count

    # Create DataFrame with column information
    column_info = pd.DataFrame({
        'Column Name': columns,
        'Data Type': data_types,
        'Null Count': null_counts,
        'NA Count': na_counts,
        'Unique Count': unique_counts,
        'Mean': np.nan,
        'Max': np.nan,
        'Min': np.nan
    })

    # Append mean, max, and min for Numeric DataFrame columns
    column_info.loc[column_info['Column Name'].isin(numeric_columns), 'Mean'] = mean_values
    column_info.loc[column_info['Column Name'].isin(numeric_columns), 'Max'] = max_values
    column_info.loc[column_info['Column Name'].isin(numeric_columns), 'Min'] = min_values

    # Count rows with whitespace
    whitespace_count = count_rows_with_whitespace(df)

    # Count rows with special characters
    special_characters_count = count_special_characters(df)

    # Count rows with break lines
    break_line_count = count_rows_with_breaks(df)

    # Append additional columns to the DataFrame
    column_info['Special Characters Count'] = special_characters_count
    column_info['Whitespace Count'] = whitespace_count
    column_info['Break Line Count'] = break_line_count

    # Dataset views
    # head_table = df.head()
    # tail_table = df.tail()
    sample_table = df.sample(10)

    # Display Report of All Outputs
    display(HTML(f'<div style="text-align: center;"><h1 style="font-size: 22px; display: inline;">\nDATASET EXPLORED: </h1> <span style="font-size: 16px;">{file_name}</span></div>\n'))
    
    display(HTML('<h2 styple="font-size: 14px;">\n\nDATASET OVERVIEW:</h2>'))
    formatted_info = dataset_info.applymap(format_numbers)
    display(HTML(formatted_info.to_html(index=False)))

    display(HTML('<h2 styple="font-size: 14px;">\nDATASET SUMMARY:</h2>'))
    formatted_info = column_info.applymap(format_numbers)
    display(HTML(formatted_info.to_html(index=True)))
    
    # display(HTML('<h2 styple="font-size: 14px;">\nDATASET HEAD:</h2>'))
    # display(HTML(head_table.to_html(index=False)))
    # display(HTML('<h2 styple="font-size: 14px;">\n\nDATASET TAIL:</h2>'))
    # display(HTML(tail_table.to_html(index=False)))
    display(HTML('<h2 styple="font-size: 14px;">\n\nDATASET SAMPLE:</h2>'))
    display(HTML(sample_table.to_html(index=False)))


# EXECUTE DATASET ANALYZER FUNCTION

# analyze_dataset(file_name)

