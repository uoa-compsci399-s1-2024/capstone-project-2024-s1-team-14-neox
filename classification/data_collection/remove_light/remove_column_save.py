import glob
import pandas as pd
import numpy as np
files = glob.glob("*.csv")
print(files)
for filename in files:
    
    df = pd.read_csv(filename, index_col=None)
    if "out" in filename:
        df["target"] = 1
    else:
        df["target"] = 0
    print(filename)
    print(df.head())
    # df.to_csv("parsed/" +filename.split(".")[0] + ".csv", index=False)