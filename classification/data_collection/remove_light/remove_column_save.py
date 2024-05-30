import glob
import pandas as pd
import numpy as np
files = glob.glob("*.csv")
print(files)
for filename in files:
    df = pd.read_csv(filename)
    new_df = df.drop('light', axis=1)
    print(filename)
    print(new_df.head())
    new_df.to_csv("parsed/" +filename.split(".")[0] + ".csv", index=False)