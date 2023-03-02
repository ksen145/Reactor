dict1 = {"1":"a", "2":"b"}
dict2 = dict1
dict1["1"] = "c"
print(dict1)
print(dict2)
# добавит новый элемент в конец каждого словаря

counter = 0

def increment():
   counter += 1

increment() 
#Выдаст ошибку переменной counter

