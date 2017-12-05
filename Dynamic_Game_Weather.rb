=begin
###############################################################################
#                                                                             #
#          				   		  	  Динамическая Погода     	      	   	          #
#                                                                             #
###############################################################################

Автор: Денис Кузнецов (http://vk.com/id8137201)
Версия: 1.2
Релиз от: 21.10.15
Зависимость: Game Time (Время/Дата) by Denis Kyznetsov (версия 6.0)
Зависимость: Game Weather (Погода) by Denis Kyznetsov (версия 3.0)
Установка: разместить ниже Game Time (Время/Дата)

Инструкция:

Чтобы на определенной карте отключить динамическую погоду, используйте заметку карты
<No Dynamic Weather>

=end

module Game_Time_Dynamic_Weather_Settings
	
	# Использовать Динамическую Погоду ? true - да, false - нет
	GAME_TIME_DYNAMIC_WEATHER_ENABLE = true
	
	# Какое максимальное количество часов идет Динамическая Погода ?
	# Минимум 1, Максимум 6
	GAME_TIME_DYNAMIC_WEATHER_HOUR = 3
	
	# Настройка Динамической Погоды для каждой графики
	# :type и :power - параметры из скрипта Погода (Game Weather)
	# :month - необязательный параметр, который можно не указывать (если не указан, то участвуют все месяцы)
	# :month - указывает в какие месяцы погода может быть (нумерация с 0)
	# :chance - вероятность появления погоды от 0 до 100 (обшая вероятность)
	# :chance будет использоваться, если не указаны настройки в таблице GAME_TIME_DYNAMIC_WEAHTER_MONTH_SETTINGS)
	# "Имя_Графики" => { :type => тип_погоды, :power => сила_погоды, :month => [месяцы], :chance => вероятность_погоды }
	GAME_TIME_DYNAMIC_WEATHER_SETTINGS = {
		"Rain" => { :type => 1, :power => 10, :chance => 20 },
		"Snow" => { :type => 0, :power => 10, :month => [0, 1, 11, 12], :chance => 10 }
	}
	
	# Настройка вероятности Динамической Погоды для каждого месяца и для каждой графики
	# номер_месяца => { "имя_графики" => вероятность и т. д. }
	GAME_TIME_DYNAMIC_WEAHTER_MONTH_SETTINGS = {
		0 => { "Rain" => 5, "Snow" => 30 } # Январь
	}
	
	# ниже не трогать :)
	
end # module Game_Time_Dynamic_Weather_Settings

class Game_Time_Dynamic_Weather
	
	include Game_Time_Dynamic_Weather_Settings, Game_Time_Settings
	
	attr_reader :stop_dynamic_weather_on_map
	
	def initialize
		@stop_dynamic_weather_on_map = false # блокировка динамической погоды на карте
		@dynamic_weather_active = false # идет ли динамическая погода
		@dynamic_weather_start_time_count = 0 # счетчик времени для отсчета минут, чтобы проверять включение погоды
		@dynamic_weather_stop_time_count = 0 # счетчик времени для отсчеты минут, чтобы проверить выключение погоды
		@dynamic_weather_start_range = GAME_TIME_MINUTES_IN_HOUR # кол-во минут перед первой проверкой включения времени
	end
	
	def stop_dynamic_weather_on_map=(setup)
		@stop_dynamic_weather_on_map = setup
		stop_dynamic_weather if setup
	end
	
	def update_time_count
		if @dynamic_weather_active
			@dynamic_weather_stop_time_count += 1
			stop_dynamic_weather if @dynamic_weather_stop_time_count >= @dynamic_weather_stop_time
		else
			@dynamic_weather_start_time_count += 1
			check_start_dynamic_weather if @dynamic_weather_start_time_count >= @dynamic_weather_start_range
		end
	end
	
	def check_start_dynamic_weather
		@dynamic_weather_start_range = [rand(GAME_TIME_MINUTES_IN_HOUR * [rand(13), 3].max), GAME_TIME_MINUTES_IN_HOUR].max
		chance = rand(101)
		month = $Game_Time.month
		GAME_TIME_DYNAMIC_WEATHER_SETTINGS.each do |index|
			if index[1].has_key?(:month)
				next if !index[1][:month].include?(month)
			end
			if GAME_TIME_DYNAMIC_WEAHTER_MONTH_SETTINGS.has_key?(month)
				if GAME_TIME_DYNAMIC_WEAHTER_MONTH_SETTINGS[month].has_key?(index[0])
					next if chance > GAME_TIME_DYNAMIC_WEAHTER_MONTH_SETTINGS[month][index[0]]
					return start_dynamic_weather(index)
				end
			else
				return start_dynamic_weather(index) if chance <= index[1][:chance]
			end
		end
		@dynamic_weather_start_time_count = 0
	end
	
	def start_dynamic_weather(index)
		@dynamic_weather_active = true
		@dynamic_weather_start_time_count = 0
		@dynamic_weather_stop_time_count = 0
		@dynamic_weather_stop_time = [[rand(GAME_TIME_DYNAMIC_WEATHER_HOUR + 1), 1].max, 6].min * GAME_TIME_MINUTES_IN_HOUR + rand(GAME_TIME_MINUTES_IN_HOUR)
		$Game_Weather.start_weather(index[1][:type], index[1][:power], index[0], true)
	end
	
	def stop_dynamic_weather
		$Game_Weather.stop_all_weather
		@dynamic_weather_active = false
		@dynamic_weather_start_time_count = 0
		@dynamic_weather_stop_time_count = 0
		@dynamic_weather_stop_time = 0
	end
	
end # class Game_Time_Dynamic_Weather

class Game_Map
	
	alias denis_kyznetsov_game_time_dynamic_weather_game_map_setup setup
	def setup(map_id)
		denis_kyznetsov_game_time_dynamic_weather_game_map_setup(map_id)
		return if $Game_Time_Dynamic_Weather.nil?
		$Game_Time_Dynamic_Weather.stop_dynamic_weather_on_map = @map.note.include?("<No Dynamic Weather>")
	end
	
end # class Game_Map

class Game_Time
	
	alias denis_kyznetsov_game_time_dynamic_weather_game_time_add_min add_min
	def add_min(n = 1)
		$Game_Time_Dynamic_Weather.update_time_count if SceneManager.scene.is_a?(Scene_Map)
		denis_kyznetsov_game_time_dynamic_weather_game_time_add_min(n)
	end
	
end # class Game_Time

$imported = {} if $imported.nil?
$imported["DenKyz_Game_Time_Dynamic_Weather"] = true

module DataManager
	
	include Game_Time_Dynamic_Weather_Settings
	
	class << self
		alias denis_kyznetsov_game_time_dynamic_weather_data_manager_create_game_objects create_game_objects
		alias denis_kyznetsov_game_time_dynamic_weather_data_manager_setup_new_game setup_new_game
	end
	
	def self.create_game_objects
		denis_kyznetsov_game_time_dynamic_weather_data_manager_create_game_objects
		$Game_Time_Dynamic_Weather = Game_Time_Dynamic_Weather.new
	end
	
	def self.setup_new_game
		check_denkyz_scripts if GAME_TIME_DYNAMIC_WEATHER_ENABLE
		denis_kyznetsov_game_time_dynamic_weather_data_manager_setup_new_game
	end
	
	def self.check_denkyz_scripts
		if !$imported["DenKyz_Game_Time"]
			msgbox("Ошибка! Отсутствует скрипт Game Time (Время/Дата)")
			exit
		end
		if !$imported["DenKyz_Game_Weather"]
			msgbox("Ошибка! Отсутствует скрипт Game Weather (Погода)")
			exit
		end
	end
	
end # module DataManager