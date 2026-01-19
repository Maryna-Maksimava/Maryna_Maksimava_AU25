# from collections import defaultdict as dd
# from itertools import product
from typing import Any, Dict, List, Tuple

from sympy.parsing.sympy_parser import null


def task_1(data_1: Dict[str, int], data_2: Dict[str, int]):
    for key in data_1:
        if key not in data_2:
            data_2[key] = data_1[key]
        else :
            data_2[key] = data_1[key]+data_2[key]
    return data_2


def task_2():
    x=1
    dict = {}
    while x<=15:
        dict[x]=x*x
        x+=1
    return dict




def task_3(data: Dict[Any, List[str]]):
    result = [""]

    for letters in data.values():
        new_result = []
        for prefix in result:
            for ch in letters:
                new_result.append(prefix + ch)
        result = new_result

    return result



def task_4(data: Dict[str, int]):
    result=[]
    maxkey = ""
    for _ in range(min(3,len(data))):
        maxi = None
        maxkey = None
        for key in data:
            if maxi is None or data[key]>maxi:
                maxi = data[key]
                maxkey = key
        result.append(maxkey)
        data.pop(maxkey)

    return result



def task_5(data: List[Tuple[Any, Any]]) -> Dict[str, List[int]]:
    result={}
    for key, value in data:
        if key not in result:
            result[key] = []
        result[key].append(value)

    return result


def task_6(data: List[Any]):
    return list(set(data))


def task_7(words: [List[str]]) -> str:
    substr = words[0]

    while len(substr)>0:
        match = True
        for word in words:
            if word[0:len(substr)]!=substr:
                match=False
                break
        if match:
            return substr
        substr = substr[:len(substr)-1]
    return ""



def task_8(haystack: str, needle: str) -> int:
    len1 = len(needle)
    len2 = len(haystack)
    for i in range(0,len2-len1+1):
        if haystack[i:i+len1] == needle:
            return i
    return -1

