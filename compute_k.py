# Helper functions to check correctness of the assembly code.

import math

ITERATIONS = 30

def compute_arctan_table():
    arctan_table = []
    for i in range(ITERATIONS):
        arctan_table.append(int(math.degrees(math.atan(2 ** (-i))) * 2**31 / 180))
    return arctan_table

def from_BAM(angle_BAM):
    angle_deg = angle_BAM * 180 / 2**31
    print(f"{angle_BAM} (BAM) = {angle_deg:.3f}° or {math.radians(angle_deg):.3f} radians.")

def to_BAM(angle_deg):
    return angle_deg * 2**31 / 180

def to_q2_29(num=1):
    # print(f"{num} shifted by 29: {num << 29}")
    return int(num * (1 << 29))

def from_q2_29(num=1):
    # wagi = [2**i for i in range(-29, 2, 1)]
    # result = 0
    # for i, weight in enumerate(wagi):
    #     if num & (1 << i):
    #         result += weight
    # alternative
    result = float(num) / 536870912.0
    print(f"{num} shifted back by 29: {result}")
    return result

def print_artan_table():
    arctan_table = compute_arctan_table()
    print("Arctan Table:")
    for i, value in enumerate(arctan_table):
        print(f"arctan(2^-{i}) = {value}")

def check_sine_cosine(degrees: int):
    sin = math.sin(math.radians(degrees))
    cos = math.cos(math.radians(degrees))
    print(f"cos {degrees}° \t{cos}\t{to_q2_29(cos)}")
    print(f"sin {degrees}° \t{sin}\t{to_q2_29(sin)}")
    print("-------------------------------------")

if __name__ == "__main__":
    check_sine_cosine(45)
    check_sine_cosine(60)
    check_sine_cosine(90)
    check_sine_cosine(99)
    check_sine_cosine(99.7)
    check_sine_cosine(100)
    check_sine_cosine(180)
    check_sine_cosine(270)
    check_sine_cosine(360)
    check_sine_cosine(361)
    print(from_q2_29(-536872977))
