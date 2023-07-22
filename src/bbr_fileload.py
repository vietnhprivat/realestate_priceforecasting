import pandas as pd

# Your file path would go here
file_path = r"C:\Users\viet-intel\boligpriser\data\input\BBR.csv"

# Load the CSV file into a pandas DataFrame
df = pd.read_csv(file_path, low_memory=False)
df.head()
