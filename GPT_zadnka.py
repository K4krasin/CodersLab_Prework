# 1. Napisz program, który będzie obliczał średnią arytmetyczną z listy liczb.
from idlelib.configdialog import is_int
from idlelib.iomenu import encoding
from random import choice

list = [3.5,57,23,6,23,6,23,62,365]
#print(dir(list))

def avg_from_list(numbers):
    sum_list = 0
    for i in numbers:
        sum_list = sum_list + i
    return print(sum_list / len(numbers))

def check_numbers_in_list(list):
    int_list = []
    for i in list:
        if isinstance(i, int):
            int_list.append(i)
        else:
            continue
    return int_list

try:
    avg_from_list(list)
except TypeError:
    try:
        new_list = check_numbers_in_list(list)
        avg_from_list(new_list)
    except ZeroDivisionError:
        print('Pusta lista (albo same stringi)')
except ZeroDivisionError:
    print('Pusta lista (albo same stringi)')

# na za chwilę
# spróbować stworzyć listę i sprawdzić ją pod kątem intów. jeśli nie będą to inty to wywalić i z tego wyliczyć średnią.


# 2. Stwórz funkcję, która przyjmuje listę słów i zwraca słowo o największej liczbie samogłosek.

#stworzę sobie plik aby było inaczej



def samo_word(list):
    samogloski = ['a', 'ą', 'e', 'ę', 'i', 'o', 'ó', 'u', 'y']
    max_samog = 0
    for k in list:
        word = k
        word = word.lower()
        act_samog = 0
        for i in word:
            for l in samogloski:
                if l in i:
                    act_samog += 1
                    if act_samog > max_samog:
                        max_samog = act_samog
                        longest_w = word
    #print(max_samog)
    print(longest_w)




# 4. Zaimplementuj prosty kalkulator, który będzie obsługiwał dodawanie, odejmowanie, mnożenie i dzielenie, z wykorzystaniem funkcji.

def numbers():
    while True:
        a = input('Podaj liczbę: ')
        b = input('Podaj 2 licznę: ')
        try:
            a = float(a)
            b = float(b)
            break
        except:
            'podaj liczbę'
    return a, b

def dodawanie(l1,l2):
    return l1 + l2

def odejmowanie(l1,l2):
    return l1 - l2

def mnozenie(l1,l2):
    return l1 * l2

def dzielenie(l1, l2):
    return l1/l2

def dzialanie():
    print('Wybierz działanie które chcesz zrobić:\nDodawanie - D\nOdejmowanie - O\nMnożenie - M\nDzielenie - Dz')
    dzial = input()
    dzial = dzial.lower()
    return dzial

def kalkulator():
    liczby = numbers()
    wybor = dzialanie()
    l1 = liczby[0]
    l2 = liczby[1]
    if wybor == 'd':
        wynik = dodawanie(l1,l2)
    elif wybor == 'o':
        wynik = odejmowanie(l1,l2)
    elif wybor == 'm':
        wynik = mnozenie(l1,l2)
    elif wybor == 'dz':
        wynik = dzielenie(l1,l2)
    else:
        print('brak odpowieniego dzialania')
    return wynik

#print(kalkulator())


# **Program do zarządzania listą zakupów** - Stwórz prosty program,
# który pozwoli użytkownikowi dodawać, usuwać i wyświetlać produkty na liście zakupów.

def add_shopping_list():
    shop_list = []
    while True:
        products = input('Podaj produkt do kupienia. Jeśli wpisałeś już wszystkie wpisz "koniec"')
        products = products.lower()
        if products == 'koniec':
            break
        else:
            shop_list.append(products)
    return shop_list

#my_shop_list = add_shopping_list()
#print(my_shop_list)

def del_shopping_list(shopping_list):
    del_product = input('Podaj produkt do usunięcia: ')
    del_product = del_product.lower()
    if del_product in shopping_list:
        shopping_list.remove(del_product)
        print('Usunięto produkt ', del_product)
    else:
        print('Nie ma takiego produktu')
    return shopping_list

#my_shop_list = del_shopping_list(my_shop_list)
#print(my_shop_list)




#  **Generator hasła** - Napisz program,
#  który będzie generował losowe hasła dla użytkowników. Możesz dodać różne kryteria bezpieczeństwa, jak długość hasła czy obecność znaków specjalnych.


import random
import string

letters = string.ascii_letters
number = string.digits
characters = string.punctuation
password = ['l','n','c']
password = choice(password)


new_password = []


def password_generator():
    new_password = []
    for i in range(10):
        password = ['l', 'n', 'c']
        password = choice(password)
        if password == 'l':
            symbol = choice(letters)
            new_password.append(symbol)
        elif password == 'n':
            symbol = choice(number)
            new_password.append(symbol)
        else:
            symbol = choice(characters)
            new_password.append(symbol)

    return ''.join(new_password)

#print(password_generator())

# 2. Stwórz skrypt, który pyta użytkownika o imię i zapisuje każde nowe imię do pliku tekstowego,
# jeśli jeszcze się tam nie znajduje.

def add_new_name():
    with open('All names.txt', 'r',encoding='utf-8') as rd_file:
        names_in_file = rd_file.read().splitlines()
        name = input('input name: ')
        name = name.lower()
        low_name = name[1:]
        first_letter = name[0].upper()
        name = first_letter + low_name
        count_names = 0
        for i in names_in_file:
            print(i)
            if i == name:
                count_names += 1
                break
        print(f'ilość imienia: {count_names}')
        if count_names != 0:
            print('imie istnieje')
        else:
            print('xrfesaf')
            with open('All names.txt', 'a', encoding='utf-8') as wr_file:
                wr_file.writelines(f'\n{name}')
