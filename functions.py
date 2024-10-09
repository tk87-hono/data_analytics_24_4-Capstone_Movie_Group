import cpi
# cpi.update() # This line is only needed to update/download new inflation data takes a bit to run. Just use if needed


# def calculate_inflated_value_old(original_value, start_year):
#     # Calculate the slices
#     slice_a = ((original_value / 3 * 2) * 0.7)
#     slice_b = ((original_value / 3 * 2) * 0.3)
#     slice_c = original_value / 3
#     # Inflate each slice to the desired year (2023 in this case)
#     slice_a = cpi.inflate(slice_a, start_year, to=2023)
#     slice_b = cpi.inflate(slice_b, start_year + 1, to=2023)
#     slice_c = cpi.inflate(slice_c, start_year + 2, to=2023)
#     # Sum the slices to get the total inflated value
#     result = slice_a + slice_b + slice_c
#     return result

def calculate_inflated_value(original_value, start_year):
    return cpi.inflate(original_value,start_year)