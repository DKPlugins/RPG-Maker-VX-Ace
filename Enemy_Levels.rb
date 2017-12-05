=begin
###############################################################################
#                                                                             #
#          						    Уровни Врагов (Enemy Levels)	  			   	          #
#                                                                             #
###############################################################################

Автор: DK (Денис Кузнецов) (http://vk.com/id8137201)
Группа ВК: http://vk.com/rpgmakervxaceandmv
Версия: 1.2 Финальная версия
Релиз от: 30.10.15
Первый релиз: 27.08.15

Что нового:
-Исправлены ошибки

Инструкция:

Установить уровень врага:
enemy_id - ID врага из Базы Данных
level - уровень врага

	set_enemy_level(enemy_id, level)

Получить уровень врага:
	get_enemy_level(enemy_id)

=end

module Enemy_Levels_Settings
	
	# Если Вы указали настройки для врага в ENEMY_LEVELS, то ENEMY_BASIC_LEVELS не будет применено к нему!
	
	# Настройка уровней всех врагов
	# параметры: :mhp (жизни), :mmp (мана), :atk (атака), :def (защита), :mat (маг. атака)
	# :mdf (маг. защита), :agi (проворство), :luk (удача), :exp (опыт), :gold (золото)
	# :name (имя врага), :graphic (название графики)
	# :actions (действия), :drop_items (награда за победу)
	# Чтобы указать процентное увеличение параметра, укажите его в ковычках ""
	# Процентное увеличение не работает для опыта и золота!
	# Пример: "20" - значение будет увеличено на 20% от значения Базы Данных
	# -1 чтобы оставить один из параметров без изменений (будет значение из Базы Данных)
	# :name => Имя врага в ковычках
	# :graphic => Название графики в ковычках
	# :actions => [номера действий из таблицы ENEMY_LEVELS_ACTIONS]
	# :drop_items => [номера наград из таблицы ENEMY_LEVELS_DROP_ITEMS]
	# уровень => { параметр => значение и т.д. }
	ENEMY_BASIC_LEVELS = {
		1 => { :mhp => 1, :mmp => 400, :atk => 10, :def => 1, :mat => 10, :mdf => 10, :agi => 10, :luk => 10, 
			:exp => 11, :gold => '100', :name => "Оса", :graphic => "God", 
			:actions => [1], :drop_items => [1, 2] }
	}
	
	# Настройка уровней отдельных врагов
	# номер_врага (ID из Базы Данных) => { уровень => { параметр => значение и т.д. } }
	ENEMY_LEVELS = {
		
	}
	
	# Настройка действий врага
	# :id => ID навыка из Базы Данных
	# :type => тип условия
	# 1 - Всегда
	# 2 - Ход №
	# 3 - HP
	# 4 - MP
	# 5 - Состояние
	# 6 - Ур. партии
	# 7 - Переключатель
	# :param1 => условие1
	# :param2 => условие2
	# Для типа 1 (Всегда): :param1 => 0 и :param2 => 0
	# Для типа 2 (Ход №): :param1 => Ход1 и :param2 => Ход2
	# Для типа 3 (HP): :param1 => Процент1 и :param2 => Процент2 (Проценты в пределах 0 - 1) Пример: 0.35 (35% HP)
	# Для типа 4 (MP): :param1 => Процент1 и :param2 => Процент2 (Проценты в пределах 0 - 1) Пример: 0.1 (10% MP)
	# Для типа 5 (Состояние): :param1 => ID состояния и :param2 => 0
	# Для типа 6 (Ур. партии): :param1 => Уровень партии и :param2 => 0
	# Дли типа 7 (Переключатель): :param1 => ID переключателя и :param2 => 0
	# :priority => приоритет действия
	# номер => { :id => значение, :type => значение, :param1 => значение, :param2 => значение, :priority => значение }
	ENEMY_LEVELS_ACTIONS = {
		1 => { :id => 2, :type => 0, :param1 => 0, :param2 => 0, :priority => 6 }
	}
	
	# Настройка награды за победу
	# :type => тип награды
	# 1 - вещь
	# 2 - оружие
	# 3 - броня
	# :id => ID предмета из Базы Данных
	# :chance => шанс добычи (1 / chance)
	# номер => { :type => значение, :id => значение, :chance => значение }
	ENEMY_LEVELS_DROP_ITEMS = {
		1 => { :type => 1, :id => 1, :chance => 1 },
		2 => { :type => 2, :id => 2, :chance => 2 }
	}
	
	# Отображать уровень в имени врага ?
	ENEMY_LEVELS_SHOW_LEVEL = true
	
end # module Enemy_Levels_Settings

class Enemy_Levels_Functions
	
	include Enemy_Levels_Settings
	
	# Получить врага
	def self.get_enemy(enemy_id)
		enemy_lvl = get_enemy_lvl(enemy_id)
		if $Enemy_Levels_Enemies.has_key?(enemy_id)
			return $Enemy_Levels_Enemies[enemy_id][0] if $Enemy_Levels_Enemies[enemy_id][1] == enemy_lvl
		end
		enemy = Marshal.load(Marshal.dump($data_enemies[enemy_id])) # чтобы не использовать объект из Базы Данных
		enemy.name = get_enemy_name(enemy_id)
		if !check_enemy_levels_settings(enemy_id)
			$Enemy_Levels_Enemies[enemy_id] = [enemy, enemy_lvl]
			return enemy
		end
		enemy_preset = get_enemy_preset(enemy_id)
		params = [:mhp, :mmp, :atk, :def, :mat, :mdf, :agi, :luk]
		for i in 0..7
			value = enemy_preset[params[i]]
			enemy.params[i] = get_value(value) if check_standard_value(value)
		end
		enemy.exp = get_enemy_exp(enemy_id)
		enemy.gold = get_enemy_gold(enemy_id)
		enemy.drop_items = get_enemy_drop_items(enemy_id)
		enemy.actions = get_enemy_actions(enemy_id)
		enemy.battler_name = get_enemy_graphic(enemy_id)
		$Enemy_Levels_Enemies[enemy_id] = [enemy, enemy_lvl]
		return enemy
	end
	
	# Получить настройки для врага (общие или индивидуальные)
	def self.get_enemy_preset(enemy_id)
		enemy_lvl = get_enemy_lvl(enemy_id)
		return ENEMY_LEVELS[enemy_id][enemy_lvl] if check_enemy_levels(enemy_id)
		return ENEMY_BASIC_LEVELS[enemy_lvl]
	end
	
	# Проверить наличие индивидуальных настроек для врага
	def self.check_enemy_levels(enemy_id)
		enemy_lvl = get_enemy_lvl(enemy_id)
		return false if !ENEMY_LEVELS.has_key?(enemy_id)
		return false if ENEMY_LEVELS[enemy_id] == {}
		return false if !ENEMY_LEVELS[enemy_id].has_key?(enemy_lvl)
		return false if ENEMY_LEVELS[enemy_id][enemy_lvl] == {}
		return true
	end
	
	# Проверить наличие общих настроек для врага
	def self.check_enemy_basic_levels(enemy_id)
		enemy_lvl = get_enemy_lvl(enemy_id)
		return false if !ENEMY_BASIC_LEVELS.has_key?(enemy_lvl)
		return false if ENEMY_BASIC_LEVELS[enemy_lvl] == {}
		return true
	end
	
	# Проверить общих и индивидуальных настроек
	def self.check_enemy_levels_settings(enemy_id)
		return false if !check_enemy_levels(enemy_id) && !check_enemy_basic_levels(enemy_id)
		return true
	end
	
	# Проверка значения
	def self.check_standard_value(value)
		return false if value.nil?
		return false if value == ""
		return false if value == -1
		return true
	end
	
	# Получить уровень врага
	def self.get_enemy_lvl(enemy_id)
		if !$Enemy_Levels.has_key?(enemy_id)
			$Enemy_Levels[enemy_id] = 1
		end
		return $Enemy_Levels[enemy_id]
	end
	
	# Получить текст уровня врага
	def self.get_enemy_lvl_name(enemy_id)
		return "" if !ENEMY_LEVELS_SHOW_LEVEL
		return " Ур. " + get_enemy_lvl(enemy_id).to_s + " "
	end
	
	# Получить имя врага
	def self.get_enemy_name(enemy_id)
		enemy = $data_enemies[enemy_id]
		lvl = get_enemy_lvl_name(enemy_id)
		return enemy.name + lvl if !check_enemy_levels_settings(enemy_id)
		enemy_preset = get_enemy_preset(enemy_id)
		if enemy_preset.has_key?(:name)
			name = enemy_preset[:name]
			name = enemy.name if !check_standard_value(name)
		end
		return name + lvl
	end
	
	# Получить графику врага
	def self.get_enemy_graphic(enemy_id)
		enemy = $data_enemies[enemy_id]
		return enemy.battler_name if !check_enemy_levels_settings(enemy_id)
		enemy_preset = get_enemy_preset(enemy_id)
		if enemy_preset.has_key?(:graphic)
			graphic = enemy_preset[:graphic]
			return graphic if check_standard_value(graphic)
		end
		return enemy.battler_name
	end
	
	# Получить действия врага
	def self.get_enemy_actions(enemy_id)
		enemy = $data_enemies[enemy_id]
		return enemy.actions if !check_enemy_levels_settings(enemy_id)
		actions = []
		enemy_preset = get_enemy_preset(enemy_id)
		return enemy.actions if !enemy_preset.has_key?(:actions)
		enemy_preset[:actions].each do |value|
			next if !check_standard_value(value)
			next if !ENEMY_LEVELS_ACTIONS.has_key?(value)
			action = ENEMY_LEVELS_ACTIONS[value]
			actions.push(RPG::Enemy::Action.new)
			actions[-1].skill_id = action[:id]
			actions[-1].condition_type = action[:type]
			actions[-1].condition_param1 = action[:param1]
			actions[-1].condition_param2 = action[:param2]
			actions[-1].rating = action[:priority]
		end
		return actions
	end
	
	# Получить награды за победу
	def self.get_enemy_drop_items(enemy_id)
		enemy = $data_enemies[enemy_id]
		return enemy.drop_items if !check_enemy_levels_settings(enemy_id)
		drop_items = []
		enemy_preset = get_enemy_preset(enemy_id)
		return enemy.drop_items if !enemy_preset.has_key?(:drop_items)
		enemy_preset[:drop_items].each do |value|
			next if !check_standard_value(value)
			next if !ENEMY_LEVELS_DROP_ITEMS.has_key?(value)
			drop_item = ENEMY_LEVELS_DROP_ITEMS[value]
			drop_items.push(RPG::Enemy::DropItem.new)
			drop_items[-1].kind = drop_item[:type]
			drop_items[-1].data_id = drop_item[:id]
			drop_items[-1].denominator = drop_item[:chance]
		end
		return drop_items
	end
	
	# Получить значение
	def self.get_value(value, basic_value = nil)
		return value if value.is_a?(Integer)
		return (basic_value * ((100 + value.to_i).to_f / 100)).to_i if value.is_a?(String)
	end
	
	# Получить опыт врага
	def self.get_enemy_exp(enemy_id)
		enemy = $data_enemies[enemy_id]
		enemy_preset = get_enemy_preset(enemy_id)
		if enemy_preset.has_key?(:exp)
			return get_value(enemy_preset[:exp], enemy.exp)
		else
			return enemy.exp
		end
	end
	
	# Получить золото врага
	def self.get_enemy_gold(enemy_id)
		enemy = $data_enemies[enemy_id]
		enemy_preset = get_enemy_preset(enemy_id)
		if enemy_preset.has_key?(:gold)
			return get_value(enemy_preset[:gold], enemy.gold)
		else
			return enemy.gold
		end
	end
	
end # class Enemy_Levels_Functions

$imported = {} if $imported.nil?
$imported["DenKyz_Enemy_Levels"] = true

class Game_Enemy < Game_Battler
	
	alias denis_kyznetsov_enemy_levels_game_enemy_initialize initialize
	def initialize(index, enemy_id)
		denis_kyznetsov_enemy_levels_game_enemy_initialize(index, enemy_id)
		@original_name = enemy.name
		@battler_name = enemy.battler_name
	end
	
	def enemy
		Enemy_Levels_Functions.get_enemy(@enemy_id)
	end
	
end # class Game_Enemy < Game_Battler

class Game_Interpreter
	
	def set_enemy_level(enemy_id, level)
		$Enemy_Levels[enemy_id] = level
	end
	
	def get_enemy_level(enemy_id)
		return Enemy_Levels_Functions.get_enemy_lvl(enemy_id)
	end
	
end # class Game_Interpreter

module DataManager
	
	class << self
		alias denis_kyznetsov_enemy_levels_data_manager_create_game_objects create_game_objects
		alias denis_kyznetsov_enemy_levels_data_manager_make_save_contents make_save_contents
		alias denis_kyznetsov_enemy_levels_data_manager_extract_save_contents extract_save_contents
	end
	
	def self.create_game_objects
		denis_kyznetsov_enemy_levels_data_manager_create_game_objects
		$Enemy_Levels_Enemies = {}
		$Enemy_Levels = {}
	end
	
	def self.make_save_contents
		contents = denis_kyznetsov_enemy_levels_data_manager_make_save_contents
		contents[:Enemy_Levels] = $Enemy_Levels
		contents
	end
	
	def self.extract_save_contents(contents)
		denis_kyznetsov_enemy_levels_data_manager_extract_save_contents(contents)
		$Enemy_Levels = contents[:Enemy_Levels]
	end
	
end # module DataManager