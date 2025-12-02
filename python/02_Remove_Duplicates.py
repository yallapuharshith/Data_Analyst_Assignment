def unique_string(s):
    result = ""
    for ch in s:
        if ch not in result:
            result += ch
    return result

print(unique_string("programming"))  # "progamin"
