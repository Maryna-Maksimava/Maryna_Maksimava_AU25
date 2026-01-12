from typing import List


def task_1(array: List[int], target: int) -> List[int]:
    used=set()
    for x in array:
        if target - x in used:
            return [x, target - x]
        used.add(x)
    return []


def task_2(number: int) -> int:
    dict = {}
    i=0
    result=0
    negative=number<0
    number=abs(number)
    while number!=0:
        dict[i]=number%10
        number=number//10
        i+=1
    for key in dict:
        result+=dict[key]*10**(i-key-1)
    if negative:
        return 0-result
    return result


def task_3(array: List[int]) -> int:
    for i, x in enumerate(array):
        for j in range(i):
            if x == array[j]:
                return x
    return -1


def task_4(string: str) -> int:
    values = {
        'I': 1,
        'V': 5,
        'X': 10,
        'L': 50,
        'C': 100,
        'D': 500,
        'M': 1000
    }

    total = 0

    for i in range(len(string) - 1):
        if values[string[i]] < values[string[i + 1]]:
            total -= values[string[i]]
        else:
            total += values[string[i]]

    total += values[string[-1]]
    return total


def task_5(array: List[int]) -> int:
    ans=array[0]
    for x in array:
        if x<ans:
            ans=x
    return ans
