"""
This module is just a hello world module template.
This documentation will also be exported to html using `sphinx`.
"""

from random import uniform


def uniform_random_value(l_boundary: float, r_boundary: float) -> float:
    """
    Returns a random number according to uniform distribution
    """
    return uniform(l_boundary, r_boundary)

