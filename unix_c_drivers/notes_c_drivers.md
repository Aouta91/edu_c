

# книги
- Роберт love system progamming
- understanding linux cernel daniel bovet |(смотреть на рутрекере) - самое фудаментальное 
- linux cernel module programming guide (github) burain salzman pomerantz 
	- https://gist.github.com/akinazuki/6d2fbab82b8e1e2164678c662a1e0ed0#introduction
	- перевод https://habr.com/ru/companies/ruvds/news/691836/
- про модули ядра https://habr.com/ru/companies/ruvds/articles/681880/
- elixir - документация по исходникам ядра
- lor.linux.org - форум для помощи
# В чем отличие ?
user-program
kernel-program
В том что UP только пользуется syscall, а kP может их создавать.
У кода модулей свой `linux kernel coding style`.

Пользовательские программы  взаимодейстив через IPC
1) управление процессом
2) управление памятью
3) управление файловыми системами (есть иллюзорные (виртуальные) файловые системы)
4) управление устройстввми как реальными и виртуальными /dev/null /dev/random
5) управление сетью


Микроядро 1, 2 (быстро загружается , мало весит) Windows CE
Моноядро 1,2,3,4,5

Темы:
1. платформо-зависимый код 
2. динамическая память 
3. типы файловых систем
4. Обращения к устройствам

# Day 1 (платформо-зависимый код)

> [!WARNING]
> Сбоку модулей ядра стоит выполнять в отдельном сборочном окружении, например, виртуалке или 

docker-контейнере
## Подготовка сборочного окружения
Установка необходимых пакетов
```sh
sudo apt install -y gcc \
build-essential \
libncurses6 \
libncurses-dev \
flex \
bison
```
Проверяем имя системы: 
```sh
uname -r
```

Установка исходников 
```sh
sodo apt install linux-source-6.8.0
```
Переходим в директорию для исходников ядра и распаковываем исходники:
```sh
cd /usr/src
sudo tar -xvf ./linux-source-6.8.0.tar.bz2 
cd /usr/src/linux-source-6.8.0
```


### Библиотеки
При написании кода ядра можно использовать только C lang. Стандартные `include`- инструкции не работают. Нужно использовать специальные заголовочные библиотеки:
```cpp
#include <linux/...h>
```
В директории `/usr/src` есть папка с исходниками (заголовочными файлами)

Можно использовать только реинтерабельные функции (т.е. функции вызов которых при обращении к одному и тому же ресурсу не приводт к проблемам в системе). Код должен быть рассчитан на многопоточность. В ядре поток и процесс одно и тоже.


Сделать принт модуля ядра с лог:
```cpp
printk()
```
Посмотртеть принты от модуля ядра можно следующим образом:
```sh
journalxtl
#or
tail -f /var/log/kern.log
```

# Загрузка, выгрузка и диагностика модулей
Модули ядра имеют расщирение `*.ko` и загружаются в систему слудующим образом:
```sh
sudo insmod ./hello.ko
```
Выгрузка модуля:
```sh
sudo rmmod ./hello.ko
```
Просмотр объектника
```sh
nm 
```
Проверка символов ядра:
```sh
cat /proc/kallsyms | grep prink
```
### Сборка содулей
Выделяют следующие памяти 
- register
- static
- extern

Также необходимо пользоваться функциями `volatile`.
Для исключения проблем с компиляцией лучше пользоваться лицензией GPL:
```cpp
MODULE_LICENSE("GPL");
```
Вывести сообщение ядра в терминал:
```cpp
printk()
```
- errno constats - константы если возникла какая нить ошибка в модуле ядра (  в случае успеха 0). В пользовательском коде наоборот
```cpp
return -EIO
```
Макросы `__init` и `__exit` обозначают функции , которые вызываются при создании модуля и при выходе из него 

```cpp 
printk(KERN_ALLERT "......");
```
Прочитать про макросы объявления констант 
```cpp
module_param()
```
Функции обратного вызова
```cpp
//callback
module_param_cd()
```
 
### Задча 1.1 
Сгенерировать в модуле ядра случайное число , вывести его , диапазон для генерации передать в качестве параметра 
### задача 1.2
При изменении параметров нужно перегенерировать число
### задача 1.3
Передать в модуль массив чисел целого значения заданного размера.
Вычислить сумму элементов массива. Печатаем в лог и выгружаем модуль 
Проверять выход за диапозон не нужно 
### Задача 1.4
Найти функцию, которая позволяет писать из пространства ядра в пространство пользователя

# Day2 Работа с символами ядра
Посмотреть символы ядры
```sh 
cat /proc/kallsyms
```
Именовать модули и сомволы стоит делать как можно сложнее (прибавлять имена модулей и т.д)
```
hello1 hello1_print()
hello2 hello2_print()
```
- как сделать функцию модулем в ядре?
```cpp
EXPORT_SYMBOL(myalert);
```

Модули ядра выполняются ядром в цикле последовательно раз за разом:

![Иллюстрация по вызову модулей ядра](./cicle.png)
- обязательно писать `const` при объявлении функций и переменных чтобы сразу отлавливать конфликты

- иснпетировние сивола 
```sh
cat /proc/kallsyms | grep mysymbol
```

Команды по работе с модулями 
```sh
insmod
rmmod
modinfo
lsmod
depmod # построение дерева зависимостей моделей 
modprobe

```
В линуксе имеются три типа устройств
1) символьные - работают с потоками данных. Удобно передавать как структуры, так и тексты
	-  radio
2) блочные устройства `/dev`. Ссылки на описание работы с устройвами. Позволяет передавать данные блоками
3) сетевые интерфейсы

Большая часть задача может быть решена через символьные устройства. Большая часть сетевых соединений -это потокозависимые процессы. Драйвер сетевого устройства нужен для обработки сетевых пакетов. 

Связь между устройствами осуществляется через директорию `dev`.
```sh
ls /dev
- l - символическое устройство
- c- блочное устрово
- 
```
- Старший номер устройства- это способ связать файл с реализаций доступа к этому устройству. Для хранения номеров устройство в линуксе имееся специальный `dev_t`. `major`  привязывает реализацию логики. `minor`  используется для точного определения устройства в системе. В современной системе довольно много старших номеров. Младших номеров  может быть 32к.
- В системе много виртуальных терминалов `tty` под разные задачи.
- Под конкретную задачу выбирается старший номер устройства.
- младшие номера можно генерировать 
- компьютер берет случайные числа из энтропии `/dev/urandom` и `/dev/random`
- Основные операции по доступу к устройству 
```sh 
open()
close()

read()
write()
```
- `struct file` описывает что происходит на уровне ядра и нельзя использовать у пользователя . Это тип данных , которые описывает что такое тип файлов на уровне операционной системы 
- `struct inode*` дает гораздо больше информации чем `struct file*`
- ononblock ?
- `try_module_get()` `module_put()` ? не дает просто так выгружать модули из системы 
- **mknod** - создает новый узел файловой стсемы
- TODO: elixir THIS_MODULE
## задача 2.1
Превратить генератор случайных чисел в символ ядра
## задача 2.2
Заполнить массив случайными числами, посчитать сумму, вывести в лог.
## задача 2.3

Создать новое устройство с новым мажорным номером. 


# Day3 
- Модули могу писать в /proc некоторую информацию 
- - редактировать proc из пользоватльеского пространсва редактировать нельзя
## задача 3.1
Устройство radio должно иметь 3 файла. Устройства 0 и 1 должны только передавать. Записывать в устройство 1 нельзя- должно выдаваться собщение о запрете. В устройство 2 можно только записывать. Других устройств быть не должно  (выдавать einval).

## задача 3.2
Добавить длинный текст в модуль, убедиться что оно принимается через cat. Нужна пользовательская программа , которая читает данные из модуля по 64 кб (желательно с помощью fopen, fclose). (radio текст подлинее )


Сообщение переданное в radio_2 должны получить через radio_0 или radio_1.


# Day 4  (Адресация памяти в ядре )
**Какие типы адресов бывают ?**
	- **виртуальные** адреса приложений (используемые пользовательскими программами ). 
		  - свое адресное пространство (статическая или динамическая )
		  - чужая память  
	- **физические** адреса , которые используются процессором при выделении память
	- **адреса шин** (периферийных шин )
	- **логические** адреса ядра (логические адрес равен физическому ). Соответсвуют страницам памяти (+/- страница). Как правило они 4кБ.
	- **виртуальные** адреса ядра
![Иллюстрация к организации памяти](./memory.png)
**kmaloc** и **vmalloc** (выделение логических и виртуальных адресов в ядре). **vmalloc**- плохая практика, т.к. выделяет память динамически. Адреса будут раскиданы по физической и долго выделяются. **kmalloc** имеет ограничение на объем памяти 

> Пространство ядра - память закрепленное за ядром . Новый модуль увеличивает объем используемой ядром память. Пространство ядра должно быть непрерывно физически (или логически)

## high memory and hi memory
Пользовательские приложения могут использовать любые области памать.
Логическая память ядра бывает только в нижней памяти. Виртуальная память ядра может находится как в верхней памяти , так и в нижней. 
> Модуль ядра и ядро должно быть размещено в нижней памяти

Есть еще swap, который находится над hi memory.


todo INSERT IMAGE

Как выглядит память?
TODO: вставить картинку
**Ошибка сегментаци.** Пример: программа обратилась к области другой программы. 
Позже появилось понятие **селектора** - автоматики , которая сама определяет , в какой сегмент памяти мы попали при смещении памяти . Селектор распределят страницы по приложениям.

Есть макрос `PAGE_SIZE`~4кБ, который определяет размер страниц.
virt_to_page()
page_address()

kmap()
kunmap() - позволяют получить виртуальный адрес для отображения страницы в системе (аналог mmap).
## kmalloc
глобально есть два режима работы:
- **`GFP_KERNEL`** - используется по умолчанию в большинстве выделений. Выделяет модуль в нижней части памяти. В случае недостатка памяти, процесс можно поместить в стан. Нельзя использовать в модулях, которые не могут спать. 
- **`GFP_ATOMIC`** - для приложений , которые не могу спать. Если памяти нет, то будет выдана ошибка. 
Чтобы **`GFP_ATOMIC`** не крашил модуль, в ядре зарезервирована память для таких выделений.

`__GFP_DMA` ? 
`__GFP_HIGHUSER`
`GFP_NOIO` -запрещает во время выделения памяти любые операции
`GFP_NOFS` - запрет на любые операции с файловой системы во время выделения. Используется для работы с дисками .


`kfree()` - высвобождает память ,выделенную kmalloc(). 
`kzalloc()` - заполняет память нулями.
`kcalloc()` - заполняет память определенными символами
`vzalloc()` - заполняет динамическую память нулями.
## TIPS 
 - На DPDK  в теории можно писать real time приложения 
- Можно ли получить доступ в чужую память? нет. Только через shared memory
	

## потоки в ядре

Классификация потоков по соотношениям
- 1:N
- M:N
- M:1
POSIX pthread позволяют организовать легковесные процессы, которые делят адресное пространство с породившим его процессом. При этом linux даст каждому из потоков свое ID.
С точки зрения ядра это все будут процессы, только  с урезанным функционалом.
TODO: Лидер сессии ?

`spinlock` - взаимные исключения устройства (некий `mutex`). Это битовый флаг в свойствах потока или процесса. Если блокировка доступна, то идет попытка установить блокирующий бит и заблокировать ресурс. Если он уже заблокирован, то в цикле проверяем что блокировка снята. Т.к. они постоянно работают , то они являются предпочтительным механизмом управления потоками. 
> Программист, использующий `spinlock`, должен гарантировать, что потоки спать не будут, иначе из состояния сна уже не выйти.

При работе spinlock обработчики прерываний отключаются, т.к. можно повесить систему на совсем.

- spilock_t
- spin_lock_init()
- spin_lock()
- spin_unlock()

## задача 4.1
Определить минимальный и максимальный объем памяти , выделяемый при **kmaloc** и **vmalloc**

# 4.2 
Сделать пользовательский клиент для примера mapdemo из примера 11

## задача 4.3
Необходимо запрограммировать модуль, представляющий из себя устройство:
Раз в заданный интервал времени, устройство должно генерировать заданное количество случайных чисел. Надо реализовать работу с эти модулем таким образом , чтобы пользователь могу работать с этими данными . 
Должна быть пользовательская программа.


Новый набор должен генерироваться раз в секунду.


## задача 4.4 tictak

В модуле создается два потока с разными потоками. Один поток печатает в лог tic, второй tak. Необходимо обеспечить синхронизацию.
# day 5

## Example sblkdev


- `blk-mq` -  multi queue block device
> В ядре 5 был полостью убраны интерфейсы работы со старыми блочными устройствами.

Раньше работа с блочными устройствами осуществлялась через очереди обращений к устройствам. Ее убрали потому что она долго работала по принципу запрос/ответ. 

С блочными устройствами работа осуществляется по блокам памяти . Диск разбивается на блоки , а файлы являются списками блоков.

## задача 5.1
Сделать блочную файловую систему

Просмотр девайсов в linux^
```sh
cat /proc/devices
```

## задача 5.2
За круглым столом сидят 5 китайских философов  . Между китайцами лежат палочики для риса . на столе стоят тарелки с рисом . Каждый философ может либо придаваться философии, а может есть . Есть рис можно только с двумя палками.
## задача 5.3
это задача 5.2, но рис представлен стеком в тарелке. За один раз можно съесть только одну единицу стека, а потом высвобождать палку.   Между подходами к еде философ может ожидать.
# Questions
- как мониторить потребляемые ресурсы от модуля 
- разные типы ошибок типа -EIO, -EAGAIN в питоне
- как оформить устройство в /dev и нацепить модуль?
- valgrind для отладки
- символы функций в файлах
- состояния процессов в pthread
- планировщик kthread 