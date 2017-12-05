=begin
###############################################################################
#                                                                             #
#          						    	 Game Time (Время/Дата)  	  				   	          #
#                                                                             #
###############################################################################

Автор: Денис Кузнецов (http://vk.com/id8137201)
Группа ВК: https://vk.com/scriptsrpgmakervxace
Версия: 6.01 Финальная версия
Релиз от: 16.10.15
Существует дополнение: Game Time Settings

Что нового в этой версии:
- Немного изменены вызовы скрипта
- Добавлены операции над временем
- Множественные исправления и улучшения

############# ИНСТРУКЦИЯ #######################################################

  Чтобы установить новую дату, воспользуйтесь скриптом:
  set_game_time(sec, min, hour, day, dayweek, month, year)
  sec - секунды
  min - минуты
  hour - час
  day - день
  dayweek - день недели
  month - месяц
  year - год
  Пример: set_game_time(0, 15, 10, 3, 2, 3, 479)
  
  Чтобы получить текущую дату используйте:
  $Game_Time.sec
	sec, min, hour, day, dayweek, month, year

	Чтобы сохранить текущее время или загрузить ранее сохраненное время, используйте:
	save_game_time
	load_game_time

  Чтобы добавить время, используйте скрипт:
  change_game_time(:min, 5) - добавит 5 минут
  change_game_time(:hour, -10) - удалит 10 часов
  Возможно: :sec, :min, :hour, :day, :month, :year

	Чтобы принудительно показать / скрыть окно времени, воспользуйтесь
	game_time_window_visible(flag)
	где flag может быть или true, или false (показать / скрыть)

	Чтобы включить / отлючить переключение переключателя в дневном диапозоне, используйте
	setup_use_khas_day_light(flag)
	где flag может быть или true, или false (вкл / выкл)

	Чтобы изменить скорость времени, вызовите скрипт:
	speed может быть от 1 до 120
	change_game_time_speed(speed)
	
	Чтобы остановить обновление времени:
	stop_update_game_time

	Чтобы узнать остановлено ли время:
	Вернет true, если время обновляется, иначе false
	game_time_update?

	Чтобы возобновить обновление времени:
	continue_update_game_time
	
	Чтобы установить час статического освещения на карте:
	hour - час
	set_game_time_static_light_hour(hour)

	Чтобы на определенной карте остановить обновление времени, 
		пропишите в заметках карты: <No Game Time Update>

	Чтобы на определенной карте выставить освещение определенного часа, 
	используйте заметки карты: <Light Hour = N>
	где N - нужный час

	### ДЛЯ БОЛЕЕ ОПЫТНЫХ ПОЛЬЗОВАТЕЛЕЙ И РАЗРАБОТЧИКОВ ###

	класс Game_Time поддерживает создание следующих экземпляров:
	1. Без параметров (будет создано время на основе настроек скрипта)
	Пример: $Game_Time = Game_Time.new

	2. С параметром в виде другого времени (объект класса Game_Time)
	Пример: $Saved_Game_Time = Game_Time.new($Game_Time)

	3. С параметрами в виде чисел времени и даты (7 параметров - sec, min, hour, day, dayweek, month, year)
	Пример: time = Game_Time.new(0, 15, 10, 3, 2, 3, 479)

	для класса Game_Time определены следующие операции:
	Больше >
	Вернет true, если время слева больше времени справа
	Пример: $Game_Time > $Saved_Game_Time

	Меньше <
	Вернет true, если время слева меньше времени справа
	Пример: $Game_Time < $Saved_Game_Time

	Больше и/или равно >=
	Вернет true, если время слева больше и/или равно времени справа
	Пример: $Game_Time >= $Saved_Game_Time

	Меньше и/или равно <=
	Вернет true, если время слева меньше и/или равно времени справа
	Пример: $Game_Time <= $Saved_Game_Time

	Операции сравнения == нет, но есть 2 метода сравнения:
	equals_without_seconds(time) - сравнение без секунд
	Вернет true, если все параметры кроме секунд равны
	Пример: $Game_Time.equals_without_seconds($Saved_Game_Time)

	equals_with_seconds(time) - сравнение с секундами
	Вернет true, если все параметры вместе с секундами равны
	Пример: $Game_Time.equals_with_seconds($Saved_Game_Time)

=end

############# НАCТРОЙКА ########################################################

module Game_Date_Settings
	
	# Название дней недели
	GAME_TIME_DAYS_WEEK = [ "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье" ]
	
	# Название месяцев
	GAME_TIME_MONTHS = [ "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", 
		"Сентябрь", "Октябрь", "Ноябрь", "Декабрь" ]
	
	# Формативный вывод месяцев
	GAME_TIME_FORMAT_MONTHS = [ "Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", 
		"Сентября", "Октября", "Ноября", "Декабря" ]
	
end # module Game_Date_Settings

module Game_Time_Settings
	
	include Game_Date_Settings
	
	#----- Начало настройки дня и ночи ---------------------------------------------	
	# Использовать смену дня и ночи (оттенки экрана) ? true - да, false - нет
	GAME_TIME_LIGHT_TINT = true
	
	# Использовать стандартную смену дня и ночи ? true - да, false - нет
	# Встроенная в скрипт функция
	# Если используете эту опцию, то установите GAME_TIME_KHAS_LIGHT = false и GAME_TIME_VICTOR_LIGHT = false
	GAME_TIME_DEFAULT_LIGHT = false	
	
	# Использовать Khas Light Effects ? true - да, false - нет
	# Требуется Khas Light Effects
	GAME_TIME_KHAS_LIGHT = true
	
	# Использовать Victor Light Effects ? true - да, false - нет
	# Требуется Victor Light Effects
	GAME_TIME_VICTOR_LIGHT = false
	
	# Использовать автоматическое переключение переключателя в диапазоне времени ?
	# Только если вы используете Khas Light Effect
	# Динамическая смена дня и ночи сама контролирует переключатель, если он используется
	$GAME_TIME_USE_KHAS_DAY_LIGHT = true
	# Номер переключателя, который будет выключаться внутри диапазона времени
	# Если вы используете $GAME_TIME_USE_KHAS_DAY_LIGHT
	# Чтобы не использовать установите -1
	GAME_TIME_KHAS_LIGHT_SWITCH = 3
	# Диапазон времени, когда переключатель выключен
	# Если вы используете $GAME_TIME_USE_KHAS_DAY_LIGHT
	GAME_TIME_KHAS_DAY_LIGHT = [8, 19]
	
	# Использовать динамическую смену дня и ночи ?
	GAME_TIME_DYNAMIC_LIGHT = false
	
	# Использовать оттенки экрана в битвах ? true - да, false - нет
	GAME_TIME_LIGHT_IN_BATTLE = true
	
	# Настройка оттенков экрана для каждого часа.
	# Если используете GAME_TIME_DYNAMIC_LIGHT, то эта настройка ничего не даст.
	# Я подбирал оптимальные настройки для Khas Light Effect
	# Диапазон значений: 0-255
	# [ Color.new(RED, GREEN, BLUE, ALPHA) ]
	GAME_TIME_TINTS = [ Color.new(30, 0, 40, 165), 	# => 0 час
		Color.new(20, 0, 30, 165), 		 			# => 1 час
		Color.new(20, 0, 30, 155), 		 			# => 2 час
		Color.new(10, 0, 30, 145), 		 			# => 3 час
		Color.new(10, 0, 20, 125), 		 			# => 4 час
		Color.new(0, 0, 20, 125), 		   		# => 5 час
		Color.new(75, 20, 20, 115), 		 		# => 6 час
		Color.new(100, 30, 10,105),    			# => 7 час
		Color.new(75, 20, 10, 85), 		 			# => 8 час
		Color.new(0, 0, 0, 55), 				 		# => 9 час
		Color.new(0, 0, 0, 30), 				 		# => 10 час
		Color.new(0, 0, 0, 10), 				 		# => 11 час
		Color.new(0, 0, 0, 0), 				 			# => 12 час
		Color.new(0, 0, 0, 0), 				 			# => 13 час
		Color.new(0, 0, 0, 0), 				 			# => 14 час
		Color.new(0, 0, 0, 5), 				 			# => 15 час
		Color.new(0, 0, 0, 15), 				 		# => 16 час
		Color.new(0, 0, 10, 45), 			 			# => 17 час
		Color.new(75, 20, 20, 85), 		 			# => 18 час
		Color.new(100, 40, 30, 105),  	 		# => 19 час
		Color.new(75, 20, 40, 125), 		 		# => 20 час
		Color.new(10, 0, 45, 140), 		 			# => 21 час
		Color.new(20, 0, 45, 145), 		 			# => 22 час
		Color.new(20, 0, 50, 160) ]		 			# => 23 час
	
	#----- Конец настройки дня и ночи ----------------------------------------------
	
	#----- Начало настройки времени ------------------------------------------------
	
	# Использовать время и дату с компьютера ? true - да, false - нет
	# Обновляется постоянно
	GAME_TIME_REAL_TIME = false
	
	# Настройка начала игры! Если не используете реальное время.
	GAME_TIME_START_SECONDS 	= 0 # Секунды
	GAME_TIME_START_MINUTES 	= 33 # Минуты
	GAME_TIME_START_HOUR  		= 15 # Час
	GAME_TIME_START_DAY   		= 15 # День
	GAME_TIME_START_DAYWEEK 	= 4 # День недели (0 - Понедельник, 6 - Воскресенье)
	GAME_TIME_START_MONTH 		= 9 # Месяц (0 - январь, 11 - декабрь)
	GAME_TIME_START_YEAR 			= 2015 # Год
	
	# Количество секунд в одной минуте (минимум 1)
	GAME_TIME_SECONDS_IN_MINUTE = 10
	# Количество минут в одном часе (минимум 1)
	GAME_TIME_MINUTES_IN_HOUR = 60
	# Количество часов в одном дне (минимум 1)
	GAME_TIME_HOURS_IN_DAY = 24
	
	# Количество дней в каждом месяце
	GAME_TIME_DAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	# Обновлять время в меню ? true - да, false - нет
	GAME_TIME_UPDATE_TIME_IN_MENU = false
	
	# Использовать обновление времени в битве ? true - да, false - нет
	GAME_TIME_UPDATE_TIME_IN_BATTLE = false
	
	# Остановить время, если на экране сообщение ? true - да, false - нет
	GAME_TIME_STOP_TIME_IN_MESSAGE = true
	
	# Скорость времени
	# (Минимум - 1, Максимум - 120)
	# Чем меньше цифра, тем быстрее идет время
	GAME_TIME_SPEED = 1
	
	# Отображать секунды в часах ? true - да, false - нет
	GAME_TIME_WINDOW_SECONDS = false
	
	# Частота обновления ":" в отображении времени (30 - оптимально)
	# -1 чтобы не использовать
	GAME_TIME_BLINK_SPEED = 30
	
	# Настройка часов на карте игры
	# GAME_TIME_MAP_CLOCK = {} чтобы не отображать часы в игре
	# :x => значение (координата х) (требуется обязательно)
	# :y => значение (координата у) (требуется обязательно)
	# :width => значение (ширина окна) (требуется обязательно)
	# :height => значение (высота окна) (требуется обязательно)
	# :windowskin => "имя_файла" (обложка окна из папки Graphics/System)
	# :modify => true/false (измененный вид окна)
	# :opacity => [значение, значение, значение] (прозрачность окна, прозрачность текста, прозрачность фона)
	# :z => значение (глубина окна)
	# :tone => Tone.new(Red, Green, Blue) (тон окна)
	# :font => ["имя_шрифта", true/false (жирный текст), true/false (курсив)]
	# :custom_clock_date => [ "параметры" ]
	# Параметры:
	# День, День недели, Месяц(число), Месяц(название), Год
	# Также возможны свои параметры
	# :custom_clock_time => [ "параметры" ]
	# Параметры:
	# Час, Двоеточие, Минуты, Секунды
	# Также возможны свои параметры
	# Можно указывать только требующиеся настройки (размеры окна)
	# -1 для значений, чтобы использовать стандартное значение (кроме размеров окна)
	GAME_TIME_MAP_CLOCK = {
		:x => Graphics.width - 192,
		:y => Graphics.height - 72,
		:width => 192,
		:height => 72,
		:windowskin => "",
		:modify => true,
		:opacity => [-1, -1, -1],
		:z => -1,
		:tone => Tone.new(0, 0, 0),
		:font => [-1, false, false],
		:custom_clock_date => [],
		:custom_clock_time => []
	}
	
	# Настройка часов в меню игры
	# Внимание! Если Вы не используете обновление времени в меню
	# Вместо "Двоеточие" в custom_clock_time укажите ":"
	# GAME_TIME_MENU_CLOCK = {} чтобы не отображать часы в меню
	GAME_TIME_MENU_CLOCK = {
		:x => 0,
		:y => 264,
		:width => 160,
		:height => 48,
		:z => -1,
		:opacity => [],
		:windowskin => "",
		:tone => Tone.new(0, 0, 0),
		:font => [-1, false, true],
		:custom_clock_date => [], #["День", " ", "Месяц(название)", " ", "Год"],
		:custom_clock_time => ["Час", ":", "Минуты"]
	}
	
	# Настройка часов в битве
	# Внимание! Если Вы не используете обновление времени в битве
	# Вместо "Двоеточие" в custom_clock_time укажите ":"
	# GAME_TIME_BATTLE_CLOCK = {} чтобы не отображать часы в битве
	GAME_TIME_BATTLE_CLOCK = {
		#~ :x => 0,
		#~ :y => 0,
		#~ :width => 192,
		#~ :height => 72,
		#~ :z => -1,
		#~ :opacity => [],
		#~ :windowskin => "",
		#~ :tone => Tone.new(0, 0, 0),
		#~ :font => [],
		#~ :custom_clock_date => [],
		#~ :custom_clock_time => []
	}
	
	# Символ кнопки для отображения / скрытия окна времени
	# -1 чтобы не использовать
	GAME_TIME_WINDOW_BUTTON = :Z
	
	# Показывать окно времени в начале игры ? true - да, false - нет
	$GAME_TIME_SHOW_WINDOW = true
	
	############# КОНЕЦ НАСТРОЙКИ ################################################
	
end # module Game_Time_Settings

class Game_Time_Functions
	
	include Game_Time_Settings
	
	def self.game_time_create_objects # создание объектов
		$Game_Time = Game_Time.new
		$Game_Time_Tint = Game_Time_Tint.new
		$Saved_Game_Time = Game_Time.new($Game_Time)
	end
	
	def self.setup_use_khas_day_light(setup)
		return if !GAME_TIME_KHAS_LIGHT
		$GAME_TIME_USE_KHAS_DAY_LIGHT = setup
	end
	
	def self.setup_khas_light_switch(setup) # устанавливаем переключателю значение
		return if !GAME_TIME_KHAS_LIGHT || GAME_TIME_KHAS_LIGHT_SWITCH == -1
		$game_switches[GAME_TIME_KHAS_LIGHT_SWITCH] = setup
	end
	
	def self.check_khas_light_switch(hour)
		setup = false
		setup = true if hour < GAME_TIME_KHAS_DAY_LIGHT[0] || hour > GAME_TIME_KHAS_DAY_LIGHT[1]
		setup_khas_light_switch(setup)
	end
	
end # class Game_Time_Functions

class Game_Time
	
	include Game_Time_Settings
	
	attr_reader :sec
	attr_reader :min
	attr_reader :hour
	attr_reader :day
	attr_reader :dayweek
	attr_reader :month
	attr_reader :year
	attr_reader :time_count
	attr_reader :time_speed
	attr_accessor :time_update
	
	def initialize(*args)
		set_time(GAME_TIME_START_SECONDS, GAME_TIME_START_MINUTES, GAME_TIME_START_HOUR, GAME_TIME_START_DAY, GAME_TIME_START_DAYWEEK, GAME_TIME_START_MONTH, GAME_TIME_START_YEAR) if args.empty?
		set_time(args[0].sec, args[0].min, args[0].hour, args[0].day, args[0].dayweek, args[0].month, args[0].year) if args.size == 1 && args[0].is_a?(Game_Time)
		set_time(args[0], args[1], args[2], args[3], args[4], args[5], args[6]) if args.size == 7
		@time_speed = [[1, GAME_TIME_SPEED].max, 120].min
		@time_update = true
	end
	
	def time_speed=(speed)
		@time_speed = [[1, speed].max, 120].min
	end
	
	def update
		return if !@time_update
		return real_time if GAME_TIME_REAL_TIME
		return if $game_message.busy? && GAME_TIME_STOP_TIME_IN_MESSAGE
		@time_count += 1
		return unless @time_count % @time_speed == 0
		return add_sec(1)
	end
	
	def >(time) # время слева больше времени справа
		return true if @year > time.year
		return true if @year == time.year && @month > time.month
		return true if @year == time.year && @month == time.month && @day > time.day
		return true if @year == time.year && @month == time.month && @day == time.day && @hour > time.hour
		return true if @year == time.year && @month == time.month && @day == time.day && @hour == time.hour && @min > time.min
		return @year == time.year && @month == time.month && @day == time.day && @hour == time.hour && @min == time.min && @sec > time.sec
	end
	
	def <(time) # время слева меньше времени справа
		return true if @year < time.year
		return true if @year == time.year && @month < time.month
		return true if @year == time.year && @month == time.month && @day < time.day
		return true if @year == time.year && @month == time.month && @day == time.day && @hour < time.hour
		return true if @year == time.year && @month == time.month && @day == time.day && @hour == time.hour && @min < time.min
		return @year == time.year && @month == time.month && @day == time.day && @hour == time.hour && @min == time.min && @sec < time.sec
	end
	
	def >=(time) # не меньше
		return !(self < time)
	end
	
	def <=(time) # не больше
		return !(self > time)
	end
	
	def equals_without_seconds(time)
		return @year == time.year && @month == time.month && @day == time.day && @hour == time.hour && @min == time.min
	end
	
	def equals_with_seconds(time)
		return equals_without_seconds(time) && @sec == time.sec
	end
	
	def set_time(sec, min, hour, day, dayweek, month, year)
		@sec = sec
		@min = min
		@hour = hour
		@day = day
		@dayweek = dayweek
		@month = month
		@year = year
		@time_count = 0
	end
	
	def change_time(type, value)
		text = "add_"
		text = "rem_" if value < 0
		value.abs.times do eval(text + type.to_s + "(1)") end
	end
	
	def enable_update_dynamic_tints
		return if !GAME_TIME_LIGHT_TINT || !GAME_TIME_DYNAMIC_LIGHT
		$Game_Time_Tint.update_dynamic_tints = true
	end
	
	def real_time # время с компьютера
		@sec = Time.now.sec
		@min = Time.now.min
		@hour = Time.now.hour
		if @day != Time.now.day
			@day = Time.now.day
			enable_update_dynamic_tints
		end
		@dayweek = Time.now.wday
		if @month != Time.now.month - 1
			@month = Time.now.month - 1
			enable_update_dynamic_tints
		end
		@year = Time.now.year
	end
	
	def add_sec(n = 1)
		@sec += n
		return unless @sec == GAME_TIME_SECONDS_IN_MINUTE
		@sec = 0
		add_min(1)
	end
	
	def add_min(n = 1)
		@min += n
		return unless @min == GAME_TIME_MINUTES_IN_HOUR
		@min = 0
		add_hour(1)
	end
	
	def add_hour(n = 1)
		@hour += n
		return unless @hour == GAME_TIME_HOURS_IN_DAY
		@hour = 0
		add_day(1)
	end
	
	def add_day(n = 1)
		@day += n
		@dayweek += n
		@dayweek = 0 if @dayweek == GAME_TIME_DAYS_WEEK.size
		enable_update_dynamic_tints
		return unless @day == GAME_TIME_DAYS[@month] + 1
		@day = 1
		add_month(1)
	end
	
	def add_month(n = 1)
		@month += n
		enable_update_dynamic_tints
		return unless @month == GAME_TIME_MONTHS.size
		@month = 0
		add_year(1)
	end
	
	def add_year(n = 1)
		@year += n
	end
	
	def rem_sec(n = 1)
		@sec -= n
		return unless @sec == -1
		@sec = GAME_TIME_SECONDS_IN_MINUTE - 1
		rem_min(1)
	end
	
	def rem_min(n = 1)
		@min -= n
		return unless @min == -1
		@min = GAME_TIME_MINUTES_IN_HOUR - 1
		rem_hour(1)
	end
	
	def rem_hour(n = 1)
		@hour -= n
		return unless @hour == -1
		@hour = GAME_TIME_HOURS_IN_DAY - 1
		rem_day(1)
	end
	
	def rem_day(n = 1)
		@day -= n
		@dayweek -= n
		@dayweek = GAME_TIME_DAYS_WEEK.size - 1 if @dayweek == -1
		enable_update_dynamic_tints
		return unless @day == 0
		@day = GAME_TIME_DAYS[@month - 1]
		rem_month(1)
	end
	
	def rem_month(n = 1)
		@month -= n
		enable_update_dynamic_tints
		return unless @month == -1
		@month = GAME_TIME_MONTHS.size - 1
		rem_year(1)
	end
	
	def rem_year(n = 1)
		@year -= n
	end
	
end # class Game_Time

class Game_Time_Tint < Sprite_Base
	
	include Game_Time_Settings
	
	attr_reader :static_light_hour
	
	def initialize
		super
		self.bitmap = Bitmap.new(Graphics.width, Graphics.height) if GAME_TIME_DEFAULT_LIGHT
		self.z = 1
		self.visible = false
		@update_dynamic_tints = GAME_TIME_DYNAMIC_LIGHT
		@static_light_hour = -1
		update
	end
	
	def update_dynamic_tints=(setup)
		@update_dynamic_tints = setup
		update if setup
	end
	
	def static_light_hour=(hour)
		@static_light_hour = hour
		update
	end
	
	def update
		return if !GAME_TIME_LIGHT_TINT
		return if @now_min == $Game_Time.min && @static_light_hour == -1
		return use_default_light if GAME_TIME_DEFAULT_LIGHT
		return use_khas_light if GAME_TIME_KHAS_LIGHT
		return use_victor if GAME_TIME_VICTOR_LIGHT
	end
	
	def settings
		self.visible = false
		@now_min = $Game_Time.min
		@hour = $Game_Time.hour
		if @static_light_hour != -1
			@now_min = GAME_TIME_MINUTES_IN_HOUR / 2
			@hour = @static_light_hour
		end
		Game_Time_Functions.check_khas_light_switch(@hour) if $GAME_TIME_USE_KHAS_DAY_LIGHT
		return setup_dynamic_light_tints if GAME_TIME_DYNAMIC_LIGHT
		@now_hour = GAME_TIME_TINTS[@hour]
		@next_hour = GAME_TIME_TINTS[(@hour + 1) % GAME_TIME_HOURS_IN_DAY]
	end
	
	def use_default_light
		settings
		tint = get_tint
		tint[0] /= 2
		tint[2] *= 0.9
		tint[3] *= 1.2
		tint[3] = [255, [0, tint[3]].max].min
		self.visible = true
		self.bitmap.clear
		self.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(tint[0], tint[1], tint[2], tint[3]))
	end
	
	def use_khas_light
		settings
		tint = get_tint
		begin
			$game_map.effect_surface.change_color(1, tint[0], tint[1], tint[2], tint[3])
		rescue
		end
	end
	
	def use_victor
		settings
		tint = get_tint
		tint[0] /= 2
		tint[2] *= 0.9
		tint[3] *= 1.2
		tint[3] = [255, [0, tint[3]].max].min
		$game_map.screen.shade.show if !$game_map.screen.shade.visible
		$game_map.screen.shade.change_color(tint[0], tint[1], tint[2], 0)
		$game_map.screen.shade.change_opacity(tint[3], 0)
	end
	
	def get_tint
		r = [255, [0, @now_hour.red.to_f + (@next_hour.red.to_f - @now_hour.red.to_f) / 60 * @now_min].max].min
		g = [255, [0, @now_hour.green.to_f + (@next_hour.green.to_f - @now_hour.green.to_f) / 60 * @now_min].max].min
		b = [255, [0, @now_hour.blue.to_f + (@next_hour.blue.to_f - @now_hour.blue.to_f) / 60 * @now_min].max].min
		a = [255, [0, @now_hour.alpha.to_f + (@next_hour.alpha.to_f - @now_hour.alpha.to_f) / 60 * @now_min].max].min
		return [r, g, b, a]
	end
	
	def red(hour, month) # здесь творится магия программирования :)
		tint = [
			[0, 0, 0, 0, 0, 10, 20, 60, 100, 70, 20, 10, 0, 0, 20, 40, 100, 80, 50, 20, 10, 0, 0, 0],
			[0, 0, 0, 0, 10, 20, 30, 75, 100, 60, 20, 10, 0, 0, 10, 20, 40, 100, 80, 50, 20, 10, 0, 0],
			[0, 0, 0, 10, 20, 30, 75, 100, 60, 20, 10, 0, 0, 0, 10, 20, 30, 50, 100, 80, 60, 30, 10, 0],
			[0, 10, 20, 30, 50, 80, 100, 60, 20, 10, 0, 0, 0, 0, 0, 10, 20, 30, 50, 100, 80, 60, 30, 10],
			[10, 20, 30, 50, 80, 100, 60, 20, 10, 5, 0, 0, 0, 0, 0, 0, 10, 15, 30, 50, 100, 80, 60, 30],
			[20, 40, 60, 80, 100, 60, 45, 30, 15, 10, 0, 0, 0, 0, 0, 0, 10, 15, 30, 50, 80, 100, 80, 60],
			[10, 30, 50, 75, 100, 75, 50, 30, 15, 10, 0, 0, 0, 0, 0, 0, 10, 15, 30, 50, 80, 100, 80, 60],
			[10, 20, 45, 60, 80, 100, 60, 35, 15, 10, 0, 0, 0, 0, 0, 10, 15, 30, 50, 75, 100, 75, 50, 20],
			[0, 10, 20, 30, 40, 60, 100, 80, 45, 30, 15, 10, 0, 0, 0, 10, 30, 50, 80, 100, 70, 50, 20, 0],
			[0, 0, 10, 20, 30, 45, 75, 100, 80, 60, 40, 20, 0, 10, 30, 45, 80, 100, 80, 60, 40, 20, 0, 0],
			[0, 0, 10, 20, 30, 50, 70, 100, 80, 60, 30, 20, 10, 20, 40, 75, 100, 80, 60, 40, 20, 10, 0, 0],
			[0, 0, 0, 10, 20, 30, 50, 70, 100, 70, 50, 20, 0, 10, 30, 60, 100, 75, 40, 20, 10, 0, 0, 0]]
		return tint[month][hour]
	end
	
	def green(hour, month)
		tint = [
			[0, 0, 0, 0, 0, 5, 10, 20, 30, 20, 10, 0, 0, 0, 10, 15, 25, 15, 10, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 5, 10, 20, 30, 20, 10, 0, 0, 0, 10, 15, 20, 25, 15, 10, 0, 0, 0, 0],
			[0, 0, 0, 0, 5, 10, 20, 30, 20, 10, 0, 0, 0, 0, 0, 5, 10, 25, 10, 5, 0, 0, 0, 0],
			[0, 0, 0, 0, 5, 10, 30, 20, 10, 5, 0, 0, 0, 0, 0, 0, 0, 10, 15, 30, 15, 10, 0, 0],
			[0, 0, 0, 10, 15, 30, 15, 10, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 15, 25, 15, 10, 0],
			[0, 0, 10, 20, 30, 20, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 15, 30, 15, 0],
			[0, 0, 10, 15, 30, 15, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30, 15, 0],
			[0, 0, 0, 10, 20, 30, 15, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30, 20, 10, 0],
			[0, 0, 0, 0, 10, 20, 30, 15, 10, 0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30, 15, 10, 0, 0],
			[0, 0, 0, 0, 0, 10, 15, 30, 10, 0, 0, 0, 0, 0, 0, 5, 15, 25, 15, 10, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 10, 20, 30, 20, 10, 0, 0, 0, 0, 10, 20, 30, 20, 10, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 10, 15, 30, 15, 10, 0, 0, 0, 10, 15, 30, 15, 10, 0, 0, 0, 0, 0]]
		return tint[month][hour]
	end
	
	def blue(hour, month)
		tint = [ 
			[10, 15, 20, 25, 30, 45, 30, 20, 10, 0, 0, 0, 0, 0, 0, 15, 20, 55, 45, 30, 20, 10, 0, 0],
			[10, 15, 20, 25, 30, 40, 20, 15, 10, 0, 0, 0, 0, 0, 0, 0, 15, 20, 55, 45, 30, 20, 10, 0],
			[10, 15, 25, 30, 40, 30, 20, 15, 10, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30, 50, 45, 40, 35, 20],
			[15, 20, 20, 35, 45, 25, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 15, 25, 35, 50, 40, 35, 20],
			[15, 20, 35, 45, 25, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 35, 55, 40, 30],
			[15, 30, 50, 35, 20, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30, 50, 30],
			[15, 30, 50, 30, 20, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30, 50, 25],
			[10, 15, 30, 50, 20, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 35, 50, 35, 20],
			[10, 15, 25, 35, 50, 30, 20, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30, 55, 35, 20, 15],
			[10, 15, 20, 25, 35, 50, 30, 20, 10, 0, 0, 0, 0, 0, 0, 10, 20, 35, 55, 40, 30, 20, 15, 10],
			[10, 10, 15, 20, 35, 55, 35, 20, 10, 0, 0, 0, 0, 10, 20, 30, 40, 55, 35, 20, 15, 15, 10, 10],
			[10, 15, 20, 25, 35, 55, 35, 20, 10, 0, 0, 0, 0, 10, 20, 30, 45, 60, 40, 30, 20, 15, 15, 10]]
		return tint[month][hour]
	end
	
	def alpha(hour, month)
		tint = [
			[175, 170, 160, 160, 150, 150, 145, 140, 120, 90, 55, 20, 10, 10, 10, 15, 25, 75, 105, 135, 155, 160, 165, 180],
			[170, 165, 155, 150, 140, 130, 130, 125, 110, 80, 50, 20, 10, 10, 10, 15, 25, 70, 95, 125, 140, 150, 160, 175],
			[165, 160, 150, 135, 130, 110, 115, 110, 90, 70, 45, 20, 10, 10, 10, 10, 20, 60, 80, 105, 120, 135, 150, 160],
			[160, 150, 140, 120, 120, 100, 90, 85, 70, 60, 40, 15, 10, 10, 10, 10, 20, 40, 60, 85, 100, 120, 135, 150],
			[155, 140, 130, 110, 105, 85, 75, 70, 50, 45, 35, 15, 10, 10, 10, 10, 10, 20, 40, 70, 85, 110, 125, 140],
			[150, 130, 120, 100, 90, 70, 55, 50, 40, 30, 35, 10, 10, 10, 10, 10, 10, 15, 25, 55, 65, 100, 105, 130],
			[145, 120, 110, 110, 100, 80, 70, 65, 55, 40, 35, 10, 10, 10, 10, 10, 10, 25, 40, 70, 80, 110, 125, 140],
			[150, 130, 120, 120, 110, 100, 85, 80, 70, 50, 40, 15, 10, 10, 10, 10, 10, 40, 60, 80, 100, 120, 130, 140],
			[155, 140, 130, 130, 120, 110, 100, 95, 85, 60, 45, 15, 10, 10, 10, 10, 10, 50, 70, 90, 115, 130, 140, 150],
			[160, 150, 140, 140, 130, 120, 115, 110, 100, 70, 50, 20, 10, 10, 10, 10, 15, 60, 80, 100, 130, 140, 150, 155],
			[165, 160, 150, 150, 140, 130, 130, 125, 110, 80, 55, 20, 10, 10, 10, 15, 20, 70, 90, 115, 145, 150, 155, 160],
			[170, 170, 160, 160, 150, 150, 145, 140, 120, 90, 60, 25, 10, 10, 10, 15, 25, 75, 105, 135, 155, 160, 165, 170]]
		return tint[month][hour]
	end
	
	def setup_dynamic_light_tints
		return dynamic_light_settings if !@update_dynamic_tints
		@tint = []
		minus = 7 # сколько вычитать из значения для рандома
		no_zero = 6 + minus * 1.5 # сколько прибавить в рандоме
		month = $Game_Time.month
		for i in 0..23
			@tint[i] = Color.new(red(i, month) - minus + rand(no_zero), green(i, month) - minus + rand(no_zero), blue(i, month) - minus + rand(no_zero), alpha(i, month) - minus + rand(no_zero))
		end
		@update_dynamic_tints = false
		return dynamic_light_settings
	end
	
	def dynamic_light_settings
		Game_Time_Functions.setup_use_khas_day_light(false) # отключаем работу диапазона времени для переключателя
		setup = false
		setup = true if @tint[@hour].alpha > 100 
		Game_Time_Functions.setup_khas_light_switch(setup) # включить переключатель, если уже темно
		@now_hour = @tint[@hour]
		@next_hour = @tint[(@hour + 1) % GAME_TIME_HOURS_IN_DAY]
	end
	
end # class Game_Time_Tint < Sprite_Base

class Game_Time_Window < Window_Base
	
	include Game_Time_Settings
	
	def initialize(preset = nil)
		return if preset.nil?
		@preset = preset # настройки окна
		super(@preset[:x], @preset[:y], @preset[:width], @preset[:height])
		window_setup
	end
	
	def window_setup
		if @preset[:windowskin]
			self.windowskin = Cache.system(@preset[:windowskin]) if @preset[:windowskin] != "" && @preset[:windowskin] != -1
		end
		modify if @preset[:modify]
		if @preset[:tone]
			self.tone = @preset[:tone] if @preset[:tone] != -1
		end
		if @preset[:opacity]
			if @preset[:opacity] != []
				self.opactiy = @preset[:opacity][0] if @preset[:opacity][0] != -1
				self.back_opacity = @preset[:opacity][1] if @preset[:opacity][1] != -1
				self.contents_opacity = @preset[:opacity][2] if @preset[:opacity][2] != -1
			end
		end
		if @preset[:z]
			self.z = @preset[:z] if @preset[:z] != -1
		end
		if @preset[:font]
			if @preset[:font] != []
				contents.font.name = @preset[:font][0] if @preset[:font][0] != -1
				contents.font.bold = @preset[:font][1] if @preset[:font][1] != -1
				contents.font.italic = @preset[:font][2] if @preset[:font][2] != -1
			end
		end
		@use_custom_clock = false
		@use_custom_clock = true if @preset[:custom_clock_date] != [] || @preset[:custom_clock_time] != []
		@custom_clock_date = @preset[:custom_clock_date]
		@custom_clock_time = @preset[:custom_clock_time]
	end
	
	def modify
		dup_skin = self.windowskin.dup
		dup_skin.clear_rect(64,  0, 64, 64)
		self.windowskin = dup_skin
	end
	
	def get_date # дата
		date = ($Game_Time.day.to_s + " " + GAME_TIME_FORMAT_MONTHS[$Game_Time.month] + " " + $Game_Time.year.to_s)
		return date if !@use_custom_clock
		return date if @custom_clock_date.nil?
		date = ""
		@custom_clock_date.each do |index|
			case index
			when "День"
				date += $Game_Time.day.to_s
			when "День недели"
				date += GAME_TIME_DAYS_WEEK[$Game_Time.month]
			when "Месяц(число)"
				date += $Game_Time.month.to_s
			when "Месяц(название)"
				date += GAME_TIME_FORMAT_MONTHS[$Game_Time.month]
			when "Год"
				date += $Game_Time.year.to_s
			else
				date += index.to_s
			end
		end
		return date 
	end
	
	def get_seconds
		return $Game_Time.sec < 10 ? "0" + $Game_Time.sec.to_s : $Game_Time.sec.to_s
	end
	
	def get_minutes
		return $Game_Time.min < 10 ? "0" + $Game_Time.min.to_s : $Game_Time.min.to_s
	end
	
	def get_hours
		return $Game_Time.hour < 10 ? "0" + $Game_Time.hour.to_s : $Game_Time.hour.to_s
	end
	
	def get_blink # мигающее двоеточие
		return ":" if !$Game_Time.time_update
		return ":" if $Game_Time.time_count % GAME_TIME_BLINK_SPEED >= GAME_TIME_BLINK_SPEED / 2
		return " "		
	end
	
	def get_time # время
		time = get_hours + (GAME_TIME_BLINK_SPEED != -1 ? get_blink : ":") + get_minutes + (GAME_TIME_WINDOW_SECONDS ? ((GAME_TIME_BLINK_SPEED != -1 ? get_blink : ":") + get_seconds) : "")
		return time if !@use_custom_clock
		return time if @custom_clock_time.nil?
		time = ""
		@custom_clock_time.each do |index|
			case index
			when "Час"
				time += get_hours
			when "Двоеточие"
				time += GAME_TIME_BLINK_SPEED != -1 ? get_blink : ":"
			when "Минуты"
				time += get_minutes
			when "Секунды"
				time += GAME_TIME_WINDOW_SECONDS ? get_seconds : ""
			else
				time += index.to_s
			end
		end
		return time
	end
	
	def update
		if (@now_sec != $Game_Time.sec && GAME_TIME_WINDOW_SECONDS) || @now_min != $Game_Time.min || GAME_TIME_BLINK_SPEED != -1 || @now_hour != $Game_Time.hour || @now_day != $Game_Time.day || @now_month != $Game_Time.month || @now_year != $Game_Time.year
			setup_variables
			contents.clear
			date = get_date
			time = get_time
			if date != "" && time != ""
				draw_text(0, 0, contents_width, contents_height - line_height, date, 1)
				draw_text(0, 0, contents_width, contents_height + line_height, time, 1)
			end
			draw_text(0, 0, contents_width, contents_height, date, 1) if time == "" && date != ""
			draw_text(0, 0, contents_width, contents_height, time, 1) if time != "" && date == ""
		end
	end
	
	def setup_variables
		@now_sec = $Game_Time.sec
		@now_min = $Game_Time.min
		@now_hour = $Game_Time.hour
		@now_day = $Game_Time.day
		@now_month = $Game_Time.month
		@now_year = $Game_Time.year
	end
	
end # class Game_Time_Window < Window_Base

class Scene_Map < Scene_Base
	
	include Game_Time_Settings
	
	alias denis_kyznetsov_game_time_scene_map_create_all_windows create_all_windows
	def create_all_windows
		denis_kyznetsov_game_time_scene_map_create_all_windows
		create_game_time_window if $GAME_TIME_SHOW_WINDOW
	end
	
	def create_game_time_window
		dispose_game_time_window
		return if GAME_TIME_MAP_CLOCK == {}
		@create_game_time_window = Game_Time_Window.new(GAME_TIME_MAP_CLOCK)
	end
	
	def dispose_game_time_window
		return if @create_game_time_window.nil?
		@create_game_time_window.dispose
		@create_game_time_window = nil
	end
	
	def game_time_window_visible(flag)
		if flag
			create_game_time_window
		else
			dispose_game_time_window
		end
		$GAME_TIME_SHOW_WINDOW = flag
	end
	
	alias denis_kyznetsov_game_time_scene_map_update update
	def update
		$Game_Time.update
		$Game_Time_Tint.update
		denis_kyznetsov_game_time_scene_map_update
		return if GAME_TIME_WINDOW_BUTTON.is_a?(Integer)
		game_time_window_visible(!$GAME_TIME_SHOW_WINDOW) if Input.trigger?(GAME_TIME_WINDOW_BUTTON)
	end
	
end # Scene_Map < Scene_Base

class Scene_Menu < Scene_MenuBase
	
	include Game_Time_Settings
	
	alias denis_kyznetsov_game_time_scn_menu_start start
	def start
		denis_kyznetsov_game_time_scn_menu_start
		create_game_time_window
	end
	
	def create_game_time_window
		return if GAME_TIME_MENU_CLOCK == {}
		@create_game_time_window = Game_Time_Window.new(GAME_TIME_MENU_CLOCK)
	end
	
	alias denis_kyznetsov_game_time_scene_menu_update update
	def update
		$Game_Time.update if GAME_TIME_UPDATE_TIME_IN_MENU
		denis_kyznetsov_game_time_scene_menu_update
	end
	
end # Scene_Menu < Scene_MenuBase

class Scene_Battle < Scene_Base
	
	include Game_Time_Settings
	
	alias denis_kyznetsov_game_time_scene_battle_start start
	def start
		denis_kyznetsov_game_time_scene_battle_start
		create_game_time_window
	end
	
	def create_game_time_window
		return if GAME_TIME_BATTLE_CLOCK == {}
		@create_game_time_window = Game_Time_Window.new(GAME_TIME_BATTLE_CLOCK)
	end
	
	alias denis_kyznetsov_game_time_scene_battle_update update
	def update
		$Game_Time.update if GAME_TIME_UPDATE_TIME_IN_BATTLE
		$Game_Time_Tint.update if GAME_TIME_LIGHT_IN_BATTLE
		denis_kyznetsov_game_time_scene_battle_update
	end
	
end # class Scene_Battle < Scene_Base

$imported = {} if $imported.nil?
$imported["DenKyz_Game_Time"] = true

class Game_Map
	
	alias denis_kyznetsov_game_time_game_map_setup setup
	def setup(map_id)
		denis_kyznetsov_game_time_game_map_setup(map_id)
		return if $Game_Time.nil?
		$Game_Time.time_update = !@map.note.include?("<No Game Time Update>")
		return if $Game_Time_Tint.nil?
		if @map.note =~ /<[\s]*Light[\w\s]*Hour[\s]*=[\s]*([\d]+)[\s]*>/i
			$Game_Time_Tint.static_light_hour = $1.to_i
		else
			$Game_Time_Tint.static_light_hour = -1
		end
	end
	
end # class Game_Map

class Game_Interpreter
	
	def save_game_time # сохранить текущее время
		$Saved_Game_Time = Game_Time.new($Game_Time)
	end
	
	def load_game_time # загрузить другое время
		$Game_Time = Game_Time.new($Saved_Game_Time)
	end
	
	def game_time_window_visible(flag) # пок / скр все окна
		SceneManager.scene.game_time_window_visible(flag)
	end
	
	def set_game_time(sec, min, hour, day, dayweek, month, year) # установить дату
		$Game_Time.set_time(sec, min, hour, day, dayweek, month, year)
	end
	
	def change_game_time(type, value) # изменить дату
		$Game_Time.change_time(type, value)
	end
	
	def setup_use_khas_day_light(setup) #вкл / выкл диапазон переключения света
		Game_Time_Functions.setup_use_khas_day_light(setup)
	end
	
	def change_game_time_speed(speed)
		$Game_Time.time_speed = speed
	end
	
	def stop_update_game_time
		$Game_Time.time_update = false
	end
	
	def continue_update_game_time
		$Game_Time.time_update = true
	end
	
	def set_game_time_static_light_hour(hour)
		$Game_Time_Tint.static_light_hour = hour
	end
	
	def game_time_update?
		return $Game_Time.time_update
	end
	
end # class Game_Interpreter

module DataManager
	
	class << self
		alias denis_kyznetsov_game_time_data_manager_create_game_objects create_game_objects
		alias denis_kyznetsov_game_time_data_manager_make_save_contents make_save_contents
		alias denis_kyznetsov_game_time_data_manager_extract_save_contents extract_save_contents
	end
	
	def self.create_game_objects
		denis_kyznetsov_game_time_data_manager_create_game_objects
		Game_Time_Functions.game_time_create_objects
	end
	
	def self.make_save_contents
		contents = denis_kyznetsov_game_time_data_manager_make_save_contents
		contents[:Game_Time] = $Game_Time
		contents[:Game_Time_time_update] = $Game_Time.time_update
		contents[:Game_Time_time_speed] = $Game_Time.time_speed
		contents[:Game_Time_Tint_static_light_hour] = $Game_Time_Tint.static_light_hour
		contents[:Saved_Game_Time] = $Saved_Game_Time
		contents[:GAME_TIME_USE_KHAS_DAY_LIGHT] = $GAME_TIME_USE_KHAS_DAY_LIGHT
		contents[:GAME_TIME_SHOW_WINDOW] = $GAME_TIME_SHOW_WINDOW
		contents
	end
	
	def self.extract_save_contents(contents)
		denis_kyznetsov_game_time_data_manager_extract_save_contents(contents)
		$Game_Time = contents[:Game_Time]
		$Game_Time.time_update = contents[:Game_Time_time_update]
		$Game_Time.time_speed = contents[:Game_Time_time_speed]
		$Game_Time_Tint.static_light_hour = contents[:Game_Time_Tint_static_light_hour]
		$Saved_Game_Time = contents[:Saved_Game_Time]
		$GAME_TIME_USE_KHAS_DAY_LIGHT = contents[:GAME_TIME_USE_KHAS_DAY_LIGHT]
		$GAME_TIME_SHOW_WINDOW = contents[:GAME_TIME_SHOW_WINDOW]
	end
	
end # module DataManager