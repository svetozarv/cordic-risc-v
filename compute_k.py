import math

ITERATIONS = 30

def compute_arctan_table():
    arctan_table = []
    for i in range(ITERATIONS):
        arctan_table.append(int(math.degrees(math.atan(2 ** (-i))) * 2**31 / 180))
    return arctan_table

def to_q2_29(num=1):
    print(f"{num} shifted by 29: {num << 29}")

if __name__ == "__main__":
    to_q2_29(2)
    # arctan_table = compute_arctan_table()
    # print("Arctan Table:")
    # for i, value in enumerate(arctan_table):
    #     print(f"arctan(2^-{i}) = {value}")
