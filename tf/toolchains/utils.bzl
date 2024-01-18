def get_sha256sum(shasums, file):
    lines = shasums.splitlines()
    for line in lines:
        if not line.endswith(file):
            continue
        return line.split(" ")[0].strip()

    return None
