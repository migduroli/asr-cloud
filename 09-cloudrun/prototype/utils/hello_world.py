"""
This module is just a hello world module template.
This documentation will also be exported to html using `sphinx`.
"""

from datetime import datetime


def say_hello(name: str = None) -> str:
    """
    Returns a hello message
    """
    if not name:
        return "Hello, World"
    else:
        return f"Hello, {str.upper(name)}: {datetime.now()}"


def main() -> None:
    """
    Prints a very friendly message.
    """
    print(say_hello())
