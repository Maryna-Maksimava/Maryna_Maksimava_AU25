# from collections import Counter
import os
import random
from idlelib.multicall import r
from pathlib import Path
from random import choice
from random import seed
from typing import List, Union

import requests
from requests.exceptions import RequestException
from requests.exceptions import ConnectionError
# from gensim.utils import simple_preprocess


S5_PATH = Path(os.path.realpath(__file__)).parent

PATH_TO_NAMES = S5_PATH / "names.txt"
PATH_TO_SURNAMES = S5_PATH / "last_names.txt"
PATH_TO_OUTPUT = S5_PATH / "sorted_names_and_surnames.txt"
PATH_TO_TEXT = S5_PATH / "random_text.txt"
PATH_TO_STOP_WORDS = S5_PATH / "stop_words.txt"


def task_1():
    random.seed(1)
    with open(PATH_TO_NAMES, "r", encoding="utf-8") as names:
        name_lines=[]
        for line in names:
            name_lines.append(line.strip().lower())

    with open(PATH_TO_SURNAMES, "r", encoding="utf-8") as surnames:
        surname_lines=[]
        for line in surnames:
            surname_lines.append(line.strip().lower())

    name_lines=sorted(name_lines)
    with open(PATH_TO_OUTPUT, mode="w", encoding="utf-8") as output:
        for name in name_lines:
            output.write(f"{name} {random.choice(surname_lines)}\n")





def task_2(top_k: int):
    with open(PATH_TO_STOP_WORDS, "r", encoding="utf-8") as f:
        stop_words = []
        for line in f:
            word = line.strip().lower()
            if word:
                stop_words.append(word)

    with open(PATH_TO_TEXT, "r", encoding="utf-8") as f:
        text = f.read().lower()

    words = []
    current_word = ""

    for char in text:
        if char.isalpha():
            current_word += char
        else:
            if current_word:
                words.append(current_word)
                current_word = ""
    if current_word:
        words.append(current_word)

    filtered_words = []
    for word in words:
        if word not in stop_words:
            filtered_words.append(word)

    freq = {}
    for word in filtered_words:
        if word in freq:
            freq[word] += 1
        else:
            freq[word] = 1

    sorted_words = sorted(freq.items(), key=lambda x: x[1], reverse=True)

    return sorted_words[:top_k]


def task_3(url: str):
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response
    except RequestException:
        raise RequestException


def task_4(data: List[Union[int, str, float]]):
    total = 0

    for item in data:
        try:
            total += item
        except TypeError:
            total += float(item)

    return total



def task_5():
    try:
        a, b = input().split()
        a = float(a)
        b = float(b)

        if b == 0:
            print("Can't divide by zero")
        else:
            print(a / b)

    except ValueError:
        print("Entered value is wrong")
