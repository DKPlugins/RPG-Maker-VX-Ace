=begin
###############################################################################
#                                                                             #
#            	 	Система погодных условий для RPG MAKER VX ACE   			        #
#                                                                             #
###############################################################################
 
Автор: Денис Кузнецов (http://vk.com/id8137201)
Группа ВК: https://vk.com/scriptsrpgmakervxace
Версия: 3.0
Релиз от: 22.07.15

Требуется набор графики в папке Graphics/Game_Weather
 
############# ИНСТРУКЦИЯ #######################################################
 
 Чтобы установить погоду используйте вызов скрипта: 
 
	start_weather(type, power, name, stop_all)
 
	где type - тип отображаемой погоды
	power - сила погоды (кол-во спрайтов также зависит от настройки ниже)
	name - имя графики (например, "Snow")
	stop_all - остановить всю погоду, чтобы на экране была только эта
	stop_all может быть или true, или false (остановить / не останавливать) 
 
	есть следующие типы (type) погоды:

	0 	- диагонально слева направо вниз (обычная скорость)
	1 	- вертикально сверху вниз (обычная скорость)
	2 	- диагонально справа налево вниз (обычная скорость)
	3 	- горизонтально налево (обычная скорость)
	4 	- диагонально справа налево вверх (обычная скорость)
	5 	- вертикально вверх (обычная скорость)
	6 	- диагонально справа налево вверх (обычная скорость)
	7 	- горизонтально направо (обычная скорость)
	8 	- диагонально слева направо вниз (быстрая скорость)
	9 	- вертикально сверху вниз (быстрая скорость)
	10 	- диагонально справа налево вниз (быстрая скорость)
	11 	- горизонтально налево (быстрая скорость)
	12	- диагонально справа налево вверх (быстрая скорость)
	13 	- вертикально вверх (быстрая скорость)
	14 	- диагонально справа налево вверх (быстрая скорость)
	15 	- горизонтально направо (быстрая скорость)
	16	- случайное
 
	Погоду можно ставить на паузу, снимать с паузы (продолжать) и останавливать
	для этого используйте скрипты:
 
	1. stop_all_weather - остановит всю погоду
 
	2. stop_weather(index) - остановит одну погоду с индексом. 
	По умолчанию index = 0. Нумерация всегда с 0.
 
	3. pause_all_weather и continue_all_weather поставят на паузу и продолжат все
	погодные условия соответственно
 
	4. pause_weather(index) - ставит на пазу одну погоду с номером.
 
	5. continue_weather(index) - продолжает одну погоду с номером.

	6. weather_exist?(type, name) - проверка на существование погоды (true или false)

	7. weather_amount - узнать количество погодных условий на экране (вернет -1, если какая-то ошибка)

	8. toggle_weather_in_battle - переключить использование погоды в битве

	9. setup_weather_in_battle(setup) - установить использование погоды в битве (true - вкл., false - выкл.)
 
=end

############# НАТРОЙКА #########################################################

module Game_Weather_Settings
	
	# Количество одновременных погодных условий
	$GAME_WEATHER_LIMIT = 2
	
	# Коэффициент силы. Влияет на количество спрайтов погоды
	$GAME_WEATHER_POWER = 15
	
	# Использовать погоду в битвах ? true/false (да/нет)
	$GAME_WEATHER_IN_BATTLE = false
	
	# Глубина погоды Z
	GAME_WEATHER_Z = 200
	
	# Пользовательские типы погоды. Нумерация при вызове скрипта начинается с 17.
	# [ Направление движения, инвертировать направление (true/false), скорость, вращение (true/false) ]
	
	# Направления движения.
	# 0 - диагонально слева направо вниз
	# 1 - вертикально сверху вниз
	# 2 - диагонально справа налево вниз
	# 3 - горизонтально налево
	
	# Скорость
	# false - обычная
	# true - быстрая
	
	GAME_WEATHER_CUSTOM_TYPES =
	[
		[0, false, false, true],
		[1, true, true, true],
		[2, false, false, true],
		[3, true, true, true]
	]
	
end # module Game_Weather_Settings

############# КОНЕЦ НАСТРОЙКИ ##################################################
############# НИЖЕ НЕ ТРОГАТЬ !!! ##############################################

module Cache
	
	def self.weather(filename)
		load_bitmap("Graphics/Game_Weather/", filename)
	end
	
end # module Cache

class Game_Weather_Functions
	
	include Game_Weather_Settings
	
	def self.weather_type_settings(type)
		case type
		when 0; 													return type_0
		when 1; 													return type_1
		when 2; 													return type_2
		when 3; 													return type_3
		when 4; 													return type_0(true)
		when 5; 													return type_1(true)
		when 6; 													return type_2(true)
		when 7; 													return type_3(true)
		when 8; 													return type_0(false, true)
		when 9; 													return type_1(false, true)
		when 10; 													return type_2(false, true)
		when 11; 													return type_3(false, true)
		when 12; 													return type_0(true, true)
		when 13; 													return type_1(true, true)
		when 14; 													return type_2(true, true)
		when 15; 													return type_3(true, true)
		when 16; 													return random
		when 17..17 + GAME_WEATHER_CUSTOM_TYPES.size; 	return custom_type(GAME_WEATHER_CUSTOM_TYPES[type - 17])
		end
	end
	
	def self.type_0(invert = false, fast = false)
		x = (rand(2) == 0 ? -rand(Graphics.width / 2) : Graphics.width + rand(Graphics.width / 2))
		y = (rand(2) == 0 ? -rand(Graphics.height / 2) : Graphics.height + rand(Graphics.height / 2))
		opacity = 1
		angle = 0
		zoom = (rand(100) + 50) / 100.0
		x_speed = [[rand(15), 5].max, 10].min
		x_speed *= -1 if invert
		x_speed *= 1.5 if fast
		y_speed = [[rand(15), 5].max, 10].min
		y_speed *= -1 if invert
		y_speed *= 1.2 if fast
		opacity_speed = [10, rand(15)].max
		opacity_speed = 20 if fast
		angle_speed = rand(3)
		angle_speed *= 2 if fast
		return x, y, opacity, angle, zoom, x_speed, y_speed, opacity_speed, angle_speed
	end
	
	def self.type_1(invert = false, fast = false)
		x = rand(Graphics.width)
		y = (rand(2) == 0 ? -rand(Graphics.height / 2) : Graphics.height + rand(Graphics.height / 2))
		opacity = 1
		angle = 0
		zoom = (rand(100) + 50) / 100.0
		x_speed = 0
		y_speed = [[rand(10) + 3, 5].max, 15].min + rand(10)
		y_speed *= -1 if invert
		y_speed *= 1.1 if fast
		opacity_speed = [10, rand(15)].max
		opacity_speed = 20 if fast
		angle_speed = 0
		return x, y, opacity, angle, zoom, x_speed, y_speed, opacity_speed, angle_speed
	end
	
	def self.type_2(invert = false, fast = false)
		x = (rand(2) == 0 ? -rand(Graphics.width / 2) : Graphics.width + rand(Graphics.width / 2))
		y = (rand(2) == 0 ? -rand(Graphics.height / 2) : Graphics.height + rand(Graphics.height / 2))
		opacity = 1
		angle = 0
		zoom = (rand(100) + 50) / 100.0
		x_speed = -[[rand(15), 5].max, 10].min
		x_speed *= -1 if invert
		x_speed *= 1.2 if fast
		y_speed = [[rand(15), 5].max, 10].min
		y_speed *= -1 if invert
		y_speed *= 1.2 if fast
		opacity_speed = [10, rand(15)].max
		angle_speed = rand(3)
		angle_speed *= 2 if fast
		return x, y, opacity, angle, zoom, x_speed, y_speed, opacity_speed, angle_speed
	end
	
	def self.type_3(invert = false, fast = false)
		x = (rand(2) == 0 ? -rand(Graphics.width / 2) : Graphics.width + rand(Graphics.width / 2))
		y = rand(Graphics.height)
		opacity = 1
		angle = rand(360)
		zoom = (rand(100) + 50) / 100.0
		x_speed = -[[rand(15), 5].max, 10].min
		x_speed *= -1 if invert
		x_speed *= 1.5 if fast
		y_speed = 0
		opacity_speed = [10, rand(15)].max
		angle_speed = rand(3)
		angle_speed *= 2 if fast
		return x, y, opacity, angle, zoom, x_speed, y_speed, opacity_speed, angle_speed
	end
	
	def self.random
		x = rand(Graphics.width)
		y = rand(Graphics.height)
		opacity = 1
		angle = rand(360)
		zoom = zoom = (rand(100) + 50) / 100.0
		x_speed = [[rand(7), 1].max, 10].min
		y_speed = [[rand(7), 1].max, 10].min
		x_speed *= -1 if rand(2) == 1
		y_speed *= -1 if rand(2) == 1
		opacity_speed = 10
		angle_speed = 0
		return x, y, opacity, angle, zoom, x_speed, y_speed, opacity_speed, angle_speed
	end
	
	def self.custom_type(custom)
		type = custom[0]
		invert = custom[1]
		fast = custom[2]
		settings = eval("type_#{type}(#{invert.to_s}, #{fast.to_s})")
		settings[-1] = rand(3) if custom[4]
		return settings
	end
	
end # class Game_Weather_Functions

$imported = {} if $imported.nil?
$imported["DenKyz_Game_Weather"] = true

class Game_Weather
	
	include Game_Weather_Settings
	
	attr_accessor :weather
	
	def initialize
		@viewport = Viewport.new
		@viewport.z = GAME_WEATHER_Z
		@weather = []
	end
	
	# Создаем новую погоду
	def start_weather(type, power, name, stop_all)
		stop_all_weather if stop_all
		stop_weather(0) if @weather.size == $GAME_WEATHER_LIMIT && !stop_all # останавливаем первую погоду, если лимит превышен
		@weather.push(Game_Weather_Weather.new(@viewport, type, power, name))
	end
	
	# Перезагружаем погоду
	def refresh
		return if @weather == []
		@weather.each do |index|
			index.refresh
		end
	end
	
	# Обновляем погоду
	def update
		return if @weather == []
		check_dispose
		@weather.each do |index|
			index.update
		end
	end
	
	# Удаляем спрайты погоды, но не убираем класс погоды
	def dispose_sprites
		return if @weather == []
		@weather.each do |index|
			index.dispose
		end
	end
	
	# Проверка на удаление погоды
	def check_dispose
		@weather.each do |index|
			return dispose_weather(index) if index.stop_state == 2
		end
	end
	
	# Остановка одной погоды
	def stop_weather(index)
		return if !index.is_a?(Integer) && index.nil?
		return if index.is_a?(Integer) && @weather[index].nil?
		if index.is_a?(Integer)
			@weather[index].stop
		else
			index.stop
		end
	end
	
	# Остановка всей погоды
	def stop_all_weather
		@weather.each do |index|
			stop_weather(index)
		end
	end
	
	# Пауза одной погоды
	def pause_weather(index)
		return if !index.is_a?(Integer) && index.nil?
		return if index.is_a?(Integer) && @weather[index].nil?
		if index.is_a?(Integer)
			@weather[index].pause
		else
			index.pause
		end
	end
	
	# Пауза всей погоды
	def pause_all_weather
		@weather.each do |index|
			pause_weather(index)
		end
	end
	
	# Продолжить одну погоду
	def continue_weather(index)
		return if !index.is_a?(Integer) && index.nil?
		return if index.is_a?(Integer) && @weather[index].nil?
		if index.is_a?(Integer)
			@weather[index].continue
		else
			index.continue
		end
	end
	
	# Продолжить всю погоду
	def continue_all_weather
		@weather.each do |index|
			continue_weather(index)
		end
	end
	
	# Проверка на существование погоды
	def weather_exist?(type, name)
		return false if @weather == []
		@weather.each do |index|
			return true if index.type == type && index.name == name
		end
		return false
	end
	
	# Удалить одну погоду
	def dispose_weather(index)
		return if index.nil?
		index = @weather.index(index)
		@weather[index].dispose
		@weather[index] = nil
		@weather.compact!
	end
	
	# Сохраняем погоду
	def make_save_contents
		content = []
		return content if @weather == []
		@weather.each do |index|
			content.push([index.type, index.power, index.name])
		end
		return content
	end
	
	# Загружаем погоду
	def extract_save_contents(content)
		stop_all_weather
		content.each do |index|
			start_weather(index[0], index[1], index[2], false)
		end
	end
	
end # class Game_Weather

class Game_Weather_Weather
	
	attr_accessor :type
	attr_reader :power
	attr_reader :name
	attr_reader :stop_state
	
	def initialize(viewport, type, power, name)
		@viewport = viewport
		@type = type
		@power = power
		@sprite_power = @power
		@sprite_power = 1 if @power < 1
		@sprite_power = [[@sprite_power * $GAME_WEATHER_POWER + rand(25), @sprite_power].max, 999].min
		@name = name
		@stop_state = 0 # 0 - ничего, 1 - затухание, 2 - можно удалить
		@sprites = []
		setup_weather
	end
	
	def setup_weather
		@sprite_power.times do
			@sprites.push(Game_Weather_Sprite.new(@viewport, @type, @name))
		end
	end
	
	def type=(type)
		@type = type
		@sprites.each do |index|
			index.type = @type
		end
	end
	
	def stop
		@stop_state = 1
		@sprites.each do |index|
			index.stop
		end
	end
	
	def pause
		stop
		@stop_state = 0
	end
	
	def continue
		@sprites.each do |index|
			index.continue
		end
	end
	
	# Проверка на удаление погоды (90% спрайтов имеют 0 прозрачность)
	def check_stop_state
		amount = 0
		@sprites.each do |index|
			amount += 1 if index.sprite.opacity == 0
		end
		@stop_state = 2 if amount >= @sprite_power * 0.9
	end
	
	def refresh
		@sprites.each do |index|
			index.refresh
		end
	end
	
	def update
		check_stop_state if @stop_state == 1
		return if @stop_state == 2
		@sprites.each do |index|
			index.update
		end
	end
	
	def dispose
		@sprites.each do |index|
			index.dispose
		end
	end
	
end # class Game_Weather_Weather

class Game_Weather_Sprite
	
	attr_reader :sprite
	
	def initialize(viewport, type, name)
		@viewport = viewport
		@type = type
		@name = name
		setup_sprite
		setup_position
		setup_variables
		save_sprite_position
	end
	
	def setup_sprite
		@sprite = Sprite.new(@viewport)
		@sprite.bitmap = Cache.weather(@name)
	end
	
	def setup_position
		@sprite_settings = Game_Weather_Functions.weather_type_settings(@type)
		@sprite.x = @sprite_settings[0]
		@sprite.y = @sprite_settings[1]
		@sprite.opacity = @sprite_settings[2]
		@sprite.angle = @sprite_settings[3]
		@sprite.zoom_x = @sprite_settings[4]
		@sprite.zoom_y = @sprite_settings[4]
	end
	
	def setup_variables
		@x_speed = @sprite_settings[5]
		@y_speed = @sprite_settings[6]
		@opacity_speed = @sprite_settings[7]
		@angle_speed = @sprite_settings[8]
	end
	
	def type=(type)
		@type = type
		@sprite_settings = Game_Weather_Functions.weather_type_settings(@type)
		setup_variables
	end
	
	def stop
		@opacity_speed = -10
	end
	
	def continue
		setup_position
		setup_variables
	end
	
	# Проверка позиции спрайта
	def check_position
		setup_position if @sprite.x > Graphics.width * 1.5 || @sprite.x < - Graphics.width / 2 || @sprite.y > Graphics.height * 1.5 || @sprite.y < - Graphics.height / 2
	end
	
	def refresh
		setup_sprite
		@sprite.x = @x_save
		@sprite.y = @y_save
		@sprite.opacity = @opacity_save
		@sprite.angle = @angle_save
		@sprite.zoom_x = @zoom_save
		@sprite.zoom_y = @zoom_save
	end
	
	def update
		@sprite.x += @x_speed
		@sprite.y += @y_speed
		@sprite.opacity += @opacity_speed
		@sprite.angle += @angle_speed
		check_position
	end
	
	def save_sprite_position
		@x_save = @sprite.x
		@y_save = @sprite.y
		@opacity_save = @sprite.opacity
		@angle_save = @sprite.angle
		@zoom_save = @sprite.zoom_x
	end
	
	def dispose
		return if @sprite.nil?
		save_sprite_position
		@sprite.dispose
		@sprite = nil
	end
	
end # class Game_Weather_Sprite

class Game_Interpreter
	
	def start_weather(type, power, name, stop_all = false)
		return if $Game_Weather.nil?
		$Game_Weather.start_weather(type, power, name, stop_all)
	end
	
	def stop_weather(index = 0)
		return if $Game_Weather.nil?
		$Game_Weather.stop_weather(index)
	end
	
	def stop_all_weather
		return if $Game_Weather.nil?
		$Game_Weather.stop_all_weather
	end
	
	def pause_weather(index = 0)
		return if $Game_Weather.nil?
		$Game_Weather.pause_weather(index)
	end
	
	def pause_all_weather
		return if $Game_Weather.nil?
		$Game_Weather.pause_all_weather
	end
	
	def continue_weather(index = 0)
		return if $Game_Weather.nil?
		$Game_Weather.continue_weather(index)
	end
	
	def continue_all_weather
		return if $Game_Weather.nil?
		$Game_Weather.continue_all_weather
	end
	
	def weather_exist?(type, name)
		return false if $Game_Weather.nil?
		$Game_Weather.weather_exist?(type, name)
	end
	
	def weather_amount
		return -1 if $Game_Weather.nil?
		return $Game_Weather.weather.size
	end
	
	def toggle_weather_in_battle
		$GAME_WEATHER_IN_BATTLE = !$GAME_WEATHER_IN_BATTLE
	end
	
	def setup_weather_in_battle(setup)
		$GAME_WEATHER_IN_BATTLE = setup
	end
	
end # class Game_Interpreter

class Spriteset_Map
	
	alias denis_kyznetsov_game_weather_spriteset_map_initialize initialize
	def initialize
		$Game_Weather.refresh if !$Game_Weather.nil?
		denis_kyznetsov_game_weather_spriteset_map_initialize	
	end
	
	alias denis_kyznetsov_game_weather_spriteset_map_dispose dispose
	def dispose
		$Game_Weather.dispose_sprites if !$Game_Weather.nil?
		denis_kyznetsov_game_weather_spriteset_map_dispose
	end
	
	alias denis_kyznetsov_game_weather_spriteset_map_update update
	def update
		$Game_Weather.update if !$Game_Weather.nil?
		denis_kyznetsov_game_weather_spriteset_map_update
	end
	
end # class Spriteset_Map

class Spriteset_Battle
	
	alias denis_kyznetsov_game_weather_spriteset_battle_initialize initialize
	def initialize
		$Game_Weather.refresh if !$Game_Weather.nil? && $GAME_WEATHER_IN_BATTLE
		denis_kyznetsov_game_weather_spriteset_battle_initialize
		
	end
	
	alias denis_kyznetsov_game_weather_spriteset_battle_dispose dispose
	def dispose
		$Game_Weather.dispose_sprites if !$Game_Weather.nil? && $GAME_WEATHER_IN_BATTLE
		denis_kyznetsov_game_weather_spriteset_battle_dispose
	end
	
	alias denis_kyznetsov_game_weather_spriteset_battle_update update
	def update
		$Game_Weather.update if !$Game_Weather.nil? && $GAME_WEATHER_IN_BATTLE
		denis_kyznetsov_game_weather_spriteset_battle_update
	end
	
end # class Spriteset_Battle

module DataManager
	
	class << self
		alias denis_kyznetsov_game_weather_data_manager_create_game_objects create_game_objects
		alias denis_kyznetsov_game_weather_data_manager_make_save_contents make_save_contents
		alias denis_kyznetsov_game_weather_data_manager_extract_save_contents extract_save_contents
	end
	
	def self.create_game_objects
		denis_kyznetsov_game_weather_data_manager_create_game_objects
		$Game_Weather = Game_Weather.new
	end
	
	def self.make_save_contents
		contents = denis_kyznetsov_game_weather_data_manager_make_save_contents
		contents[:Game_Weather_Content] = $Game_Weather.make_save_contents
		contents[:GAME_WEATHER_LIMIT] = $GAME_WEATHER_LIMIT
		contents[:GAME_WEATHER_POWER] = $GAME_WEATHER_POWER
		contents[:GAME_WEATHER_IN_BATTLE] = $GAME_WEATHER_IN_BATTLE
		contents
	end
	
	def self.extract_save_contents(contents)
		denis_kyznetsov_game_weather_data_manager_extract_save_contents(contents)
		$Game_Weather.extract_save_contents(contents[:Game_Weather_Content])
		$GAME_WEATHER_LIMIT = contents[:GAME_WEATHER_LIMIT]
		$GAME_WEATHER_POWER = contents[:GAME_WEATHER_POWER]
		$GAME_WEATHER_IN_BATTLE = contents[:GAME_WEATHER_IN_BATTLE]
	end
	
end # module DataManager