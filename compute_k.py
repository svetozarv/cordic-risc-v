import math

ITERATIONS = 30

def compute_arctan_table():
    arctan_table = []
    for i in range(ITERATIONS):
        arctan_table.append(int(math.degrees(math.atan(2 ** (-i))) * 2**31 / 180))
    return arctan_table

def from_BAM(angle_BAM):
    angle_deg = angle_BAM * 180 / 2**31
    print(f"{angle_BAM} (BAM) = {angle_deg:.3f} degrees or {math.radians(angle_deg):.3f} radians.")

def to_q2_29(num=1):
    print(f"{num} shifted by 29: {num << 29}")

def from_q2_29(num=1):
    wagi = [2**i for i in range(-29, 2, 1)]
    result = 0
    for i, weight in enumerate(wagi):
        if num & (1 << i):
            result += weight
    # result = float(num) / 536870912.0 - alternative
    # print(f"{num} shifted back by 29: {result}")
    return result

def print_artan_table():
    arctan_table = compute_arctan_table()
    print("Arctan Table:")
    for i, value in enumerate(arctan_table):
        print(f"arctan(2^-{i}) = {value}")

if __name__ == "__main__":
    print()
    print(f"cosine of 464945629 (Q2.29) is {from_q2_29(464945629)}")
    print(f"sine of 268436490 (Q2.29) is {from_q2_29(268436490)}")
    print("--------------------------------------------")
    print(f"cosine of 379626512 (Q2.29) is {from_q2_29(379626512)}")
    print(f"sine of 379626526 (Q2.29) is {from_q2_29(379626526)}")
    print()
