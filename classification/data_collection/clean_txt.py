from datetime import datetime


def rewrite_file(input, output):
    with open(input, "r") as input_f:
        with open(output, "w") as output_f:
            output_f.write("")

def unix_to_datetime(unix):
    print(datetime.fromtimestamp(unix).strftime('%Y-%m-%d %H:%M:%S'))


unix_to_datetime(1712471231)
unix_to_datetime(1712471482)


