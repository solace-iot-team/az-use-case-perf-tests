import datetime

def to_date(text: str, pattern: str) -> datetime:
    return datetime.datetime.strptime(text, pattern)