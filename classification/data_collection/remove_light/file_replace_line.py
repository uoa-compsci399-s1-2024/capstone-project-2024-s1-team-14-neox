import pandas as pd
import numpy as np
import glob
files = glob.glob("*.csv")
print(files)
for filename in files:
    print(filename)
    f =  open(f'parsed/{filename.split(".")[0]}.csv', "w")
    with open(filename, "r") as input:
        lines = input.readlines()
        f.write(lines[0])
        for l in lines[1:]:
            if "out" in filename:
                f.write(l[:-2] + "1\n")
            else:
                f.write(l[:-2] + "0\n")

    f.close()