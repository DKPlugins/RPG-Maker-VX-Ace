=begin
Название: Древо Навыков
Автор: DK (Денис Кузнецов) (http://vk.com/id8137201)
Группа ВК: http://vk.com/rpgmakervxaceandmv
Версия: 2.02 Финальная версия
Релиз от: 19.11.15
Все файлы, используемые в скрипте, должны быть в папке Graphics/Skill_Tree_System/

Что нового в этой версии:
- Небольшие иправления

Благодарность: Kian Ni за помощь с реализацией графической составляющей

	Инструкция по вызовам скриптов:
	Вы можете не указывать actor_id в следующих случаях:
	1. Вы играете за одно персонажа и указали это в настройках
	2. Вы хотите вызвать скрипт для первого персонажа в партии

	Вызовите скрипт, чтобы открыть Древо Навыков для персонажа (ID из Базы данных)
	Персонаж должен быть в партии
	open_skill_tree_system(actor_id)

	Вызовите, чтобы добавить персонажу (ID из Базы данных) очки навыка
	Персонаж должен быть в партии, чтобы очки добавились
	add_skill_point(actor_id, skill_point)

	Вызовите, чтобы установить определенное количество очков навыков
	Персонаж должен быть в партии
	skill_point - количество очков навыков
	set_skill_point(skill_point, actor_id)

	Вызовите, чтобы узнать количество очков навыков у персонажа
	Персонаж должен быть в партии
	get_skill_point(actor_id)

	Добавить навык в Древо Навыков (в конец уровня):
	class_id - ID класса из Базы Данных
	layer - уровень
	skill_id - ID навыка из Базы Данных или Кастомных навыков
	y - координата навыка на древе
	push_skill_in_skill_tree(class_id, layer, skill_id, y)

	Вставить навык в Древо Навыков:
	index - индекс навыка (не ID), после которого нужно вставить навык
	paste_skill_in_skill_tree(class_id, layer, index, skill_id, y)

	Заменить навык в Древе Навыков:
	replace_skill_in_skill_tree(class_id, layer, index, skill_id, y)

	Удалить навык из Древа Навыков:
	remove_skill_from_skill_tree(class_id, layer, index)

	Для справки о совместимости с другими скриптами:
	В данном скрипте переписаны/дополнены стандартные классы

	### class RPG::Skill ###

	Новые методы:
	initialize(id)
	skill_tree_system_preset
	custom_skill?

	### class Game_Actor ###

	Новые методы:
	actor_learned_all_skills?

	Дополненные методы:
	setup(actor_id)
	change_class(class_id, keep_exp = false)

	Переписанные методы:
	init_skills
	level_up
	learn_skill(skill_id)
	forget_skill(skill_id)
	skill_learn?(skill)

	### Game_Interpreter ###

	Новые методы

	### Window_MenuCommand ###

	Дополненные методы:
	add_main_commands

	### Scene_Menu ###

	Новые методы:
	open_skill_tree_system

	Дополненные методы:
	create_command_window
	on_personal_ok

	### module DataManager ###
	
	Дополненные методы:
	create_game_objects
	setup_battle_test
	make_save_contents
	extract_save_contents(contents)

=end

module Skill_Tree_System_Settings
	
	# Обложка для оформления всех окон древа навыков
	# Файл должен находиться в папке Graphics/Skill_Tree_System/
	# SKILL_TREE_SYSTEM_WINDOWSKIN = "" чтобы не использовать
	SKILL_TREE_SYSTEM_WINDOWSKIN = ""
	
	# Индивидуальные настройки для каждого окна древа навыков
	# SKILL_TREE_SYSTEM_WINDOW_PRESET = { } чтобы у всех окон использовать стандартные настройки
	# 4 вида окна: :description, :tree, :info, :confirm
	# Параметры:
	# Настройка шрифта
	# У окна :description можно настроить следующие типы шрифтов: 
	# :name_font (Шрифт названия навыка)
	# :other_font (Шрифт для остального текста)
	# :description_font (Шрифт для описания навыка)
	# У окна :tree есть только name_font
	# У окна :info есть только name_font
	# У окна :confirm есть:
	# :title_font (Шрифт названия навыка)
	# :table_font (Шрифт текста "Параметры" и "Требования")
	# :other_font (Шрифт названий параметров)
	# :value_font (Шрифт значений параметров)
	# Внимание! В :value_font нельзя указать цвет_текста
	# Внимание! Цвет текста в скобках требований берется из окна :info
	# Инструкция:
	# :тип_шрифта => ["Название_Шрифта", жирный_текст (true/false), курсив (true/false), номер_цвета (Номер цвета, как при использовании в сообщениях)]
	# Настройка тона окна
	#	:tone => Tone.new(R, G, B)
	# Использовать измененный стиль окна
	# :modify => true/false
	# Прозрачность окна
	# :opacity => [Общая_прозрачность_окна, прозрачность_текста, прозрачность_фона]
	# У окна :confirm есть также дополнительный параметр :line_color => номер_цвета (Цвет линий)
	# Инструкция:
	# Можно не указывать некоторые параметры или целое окно целиком (будут настройки по умолчанию)
	# :окно => { :параметр => значение, :параметр => значение и т.д. } 
	SKILL_TREE_SYSTEM_WINDOW_PRESET = {
		:description => { :name_font => ["Times New Roman", false, true, -1], :other_font => [-1, false, true, 6], :description_font => [-1, false, true],
			:tone => Tone.new(0, 0, 0), :modify => true, :opacity => [-1, -1, 155] },
		
		:tree => { :name_font => ["Times New Roman", false, true, 6], :tone => Tone.new(0, 0, 0), :modify => true },
		
		:info => { :name_font => [-1, false, true, 16], :tone => Tone.new(0, 0, 0), :modify => true},
		
		:confirm => { :title_font => [-1, true, false, 8], :table_font => [-1, true, false, 17], :other_font => [-1, true, false, 0], :value_font => [-1, false, true], :line_color => 5,
			:tone => Tone.new(0, 0, 0), :modify => true }
	}
	
	# Настройка курсора
	# SKILL_TREE_SYSTEM_CURSOR_SETTINGS = { } чтобы использовать стандартные настройки
	# :graphic => "имя_графики" в папке Graphics/Skill_Tree_System/
	# :graphic => -1 или "" (использовать курсор из обложки окна windowskin)
	# :animation => номер_анимации (от 0 до 5 включительно, 0 - выключить)
	# Значения прозрачности в диапазоне от 0 до 255 включительно
	# :opacity => прозрачность (если используется анимация 1, то никак не влияет)
	# :opacity => -1 (чтобы использовать стандартное значение)
	# :dx => смещение (изменить координату X курсора относительно верхнего левого угла навыка)
	# :dy => смещение (изменить координату Y курсора относительно верхнего левого угла навыка)
	SKILL_TREE_SYSTEM_CURSOR_SETTINGS = {
		:graphic => "cursor5",
		:animation => 2,
		:opacity => -1,
		:dx => 0,
		:dy => -24
	}
	
	# Общие настройки фона навыков
	# Здесь настраивается фон для всех навыков, которые не имеют индивидуальных настроек фона
	# Фон навыка делится на 3 типа, исходя из состояния навыка
	# Состояния навыка: навык изучен, навык можно изучить, навык нельзя изучить
	# Для каждого состояния указывается фон навыка (либо значение цвета, либо имя графики)
	# Для значения цвета используется цвет текста, как в сообщениях
	# :graphic => [ "имя графики" или номер цвета для каждого состояния ]
	# -1 чтобы использовать стандартную прозрачность для каждого состояния
	# :opacity => [ прозрачность для каждого состояния ]
	SKILL_TREE_SYSTEM_BACKGROUND_SETTINGS = {
		:graphic => [3, 14, 1],
		:opacity => [-1, -1, -1]
	}
	
	# Индивидуальные настройки фона для каждого навыка
	# -1 чтобы использовать для определенного состояния общие настройки (только для графики)
	# номер навыка => { :graphic => [ "имя графики" или номер цвета для каждого состояния],
	# :opacity => [ прозрачность для каждого состояния ] }
	SKILL_TREE_SYSTEM_SKILL_BACKGROUND = {
		4 => { :graphic => [4, "background_orange", -1], :opacity => [-1, -1, -1] }
	}
	
	# Настройка соединяющих линий
	# Для значения цвета используется цвет текста, как в сообщениях
	# :graphic => [ "имя графики" или номер цвета для каждого состояния ]
	# :opacity => [ прозрачность для каждого состояния ]
	SKILL_TREE_SYSTEM_LINE_SETTINGS = {
		:graphic => [11, 14, 10],
		:opacity => [-1, -1, -1]
	}
	
	# Используете ли Вы TP у навыков ?
	# Влияет на отображение TP в окне информации о навыке
	# true - да, false - нет
	SKILL_TREE_SYSTEM_SKILL_TP = true
	
	# Использовать только одного персонажа ?
	# Укажите ID персонажа из Базы Данных
	# -1 чтобы не использовать
	SKILL_TREE_SYSTEM_SINGLE_PLAYER = 1
	
	# Использовать переключение персонажей в древе навыков ?
	# Если используется несколько персонажей
	# true - да, false - нет
	SKILL_TREE_SYSTEM_ACTOR_CHANGE = true
	
	# Когда Вы запускаете тест битвы в программе, то персонаж автоматически изучает все навыки своего класса
	# Какие параметры навыков игнорировать при тесте битвы ?
	# Внимание! Если навык меняет класс персонажа, то все равно будут выучены все навыки первоначального класса!
	# Можно игнорировать все дополнения навыков (список параметров см. ниже)
	# SKILL_TREE_SYSTEM_BATTLE_TEST_IGNORE = [] чтобы ничего не игнорировать
	# SKILL_TREE_SYSTEM_BATTLE_TEST_IGNORE = [ :параметр, :параметр и т.д. ]
	SKILL_TREE_SYSTEM_BATTLE_TEST_IGNORE = [
		#~ :mmp,
		#~ :actor_recover,
		#~ :actor_add_state,
		#~ :actor_remove_state,
		#~ :actor_name,
		#~ :actor_graphic,
		#~ :actor_change_class
	]
	
	# Сколько очков навыков у каждого персонажа на первом уровне ?
	# Если уровень персонажа больше 1, то у него будет следующее количество очков:
	# SKILL_TREE_SYSTEM_ACTOR_SKILL_POINT + (уровень - 1) * SKILL_TREE_SYSTEM_LEVEL_SKILL_POINT
	SKILL_TREE_SYSTEM_ACTOR_SKILL_POINT = 10
	
	# Количество очков, которое дается за новый уровень
	SKILL_TREE_SYSTEM_LEVEL_SKILL_POINT = 1
	
	# Название команды вызова скрипта в меню
	# "" чтобы не использовать
	SKILL_TREE_SYSTEM_MENU_COMMAND = "Древо умений"
	
	# Переключатель для отключения команды в меню
	# Переключатель включен = команда доступна
	# -1 чтобы не использовать (команда всегда доступна)
	SKILL_TREE_SYSTEM_SWITCH_ENABLE = -1
	
	# Не увеличивать очки навыков, если персонаж уже выучил все навыки для своего класса?
	# true - да, false - нет
	SKILL_TREE_SYSTEM_POINT_LVL_LIMIT = true
	
	# Настройка фона для классов
	# Файлы должны находиться в папке Graphics/Skill_Tree_System/
	# Разрешение 544 х 416 (Полный экран игры)
	# номер_класса => "имя_файла"
	SKILL_TREE_SYSTEM_BACKGROUND = {
		#~ 1 => "warrior",
		#~ 4 => "dark"
	}
	
	# Использовать в качестве фона карту игры ?
	# Будет использоваться, если не настроен фон для класса
	# true - да, false - нет
	SKILL_TREE_SYSTEM_MAP_BACKGROUND = true
	
	# Отображать статус навыка в окне древа навыков ?
	# Активный (стандартные навыки) и Пассивный (кастомные навыки)
	SKILL_TREE_SYSTEM_SKILL_STATUS = true
	
	# Таблица дополнения стандартных навыков
	# номер_навыка => { :параметры }
	# Параметры:
	# :mhp => значение (Изменить максимальное HP)
	# :mmp => значение (Изменить максимальное MP)
	# :atk => значение (Изменить атаку)
	# :def => значение (Изменить защиту)
	# :mat => значение (Изменить магическую атаку)
	# :mdf => значение (Изменить магическую защиту)
	# :agi => значение (Изменить проворство)
	# :luk => значение (Изменить удачу)
	# :sp_cost => значение (Стоимость навыка в очках)
	# :mp_cost => значение (Стоимость навыка в MP героя)
	# :gold_cost => значение (Стоимость навыка в золоте партии)
	# :actor_lvl => значение (Требуемый уровень персонажа для изучения навыка)
	# :actor_recover => true/false (Полное восстановление персонажа (снимает ранее наложенные состояния))
	# :actor_add_state => [значение, значение и т.д.] (Номера состояний для добавления)
	# :actor_remove_state => [значение, значение и т.д.] (Номера состояний для снятия)
	# :actor_name => "Новое_Имя_Персонажа" (Изменить имя персонажа)
	# :actor_graphic => ["Имя_Чарсета", Индекс_Чара, "Имя_Графики_Лица", Индекс_Графики_Лица] (Изменить графику персонажа)
	# :actor_change_class => значение (Изменить класс персонажа)
	# Инструкция:
	# Можно не указывать некоторые параметры
	# номер_навыка => { :параметр => значение, :параметр => значение и т. д. }
	SKILL_TREE_SYSTEM_BASE_SKILLS = {
		3 => { :mhp => 20, :mmp => -2, :gold_cost => 5000, :actor_lvl => 5 },
		6 => { :mp_cost => 53 }
	}
	
	# Таблица своих (кастомных) навыков
	# Кастомные навыки не отображаются в списке навыков персонажа (Пассивные навыки)
	# Навыки в этой таблице (обязательно!) должны иметь отрицательный номер
	# Параметры:
	# :name => "Название_Навыка" (Название навыка)
	# :icon_index => значение (Номер иконки)
	# :description => "Описание" (Описание навыка)
	# :type => значение или "Название" (Тип навыка (значение будет браться из Базы Типов Классов или свое название))
	# + все параметры из таблицы выше
	# Инструкция:
	# Можно не указывать некоторые параметры
	# отрицательный_номер_навыка => { :параметр => значение, :параметр => значение и т. д. }
	SKILL_TREE_SYSTEM_CUSTOM_SKILLS = {
		-1 => { :name => "Вампир", :icon_index => 12, :description => "Станьте вампиром и измените свой облик",
			:type => "Превращение", :mhp => 2000, :mmp => 500, :atk => 100, :actor_name => "Темный Лорд",
			:actor_graphic => ["Monster1", 7, "Monster1", 4], 
			:actor_recover => true, :actor_add_state => [2, 14], :actor_change_class => 5,
			:sp_cost => 2, :mp_cost => 50, :gold_cost => 250, :actor_lvl => 3 },
		
		-2 => { :name => "Усиление HP", :icon_index => 32, :description => "Увеличьте HP Вампира на 1000", :type => "Усиление", 
			:mhp => 1000, :actor_lvl => 3 },
		
		-3 => { :name => "Человек", :icon_index => 12, :description => "Вернись в человеческий облик",
			:type => "Превращение", :mhp => -2000, :mmp => -500, :atk => -100, :actor_name => "Форд",
			:actor_recover => true, :actor_change_class => 4, :mp_cost => 50, :gold_cost => 1000, :actor_lvl => 5 },
		
		-4 => { :name => "Усиление MP", :icon_index => 33, :description => "Увеличьте HP Вампира на 250", :type => "Усиление",
			:mmp => 250, :actor_lvl => 4 },
		
		-5 => { :name => "Усиление Атаки", :icon_index => 34, :description => "Увеличьте Атаку Вампира на 50", :type => "Усиление",
			:atk => 50, :actor_lvl => 5 },
		
		-6 => { :name => "Восстановление", :icon_index => 112, :description => "Восстановите своего персонажа", :type => "Восстановление",
			:actor_recover => true }
	}
	
	# Таблица настройки нескольких уровней для навыков
	# номер_навыка => [ номера_навыков ]
	SKILL_TREE_SYSTEM_SKILL_LVL = {
		#~ -2 => [5, 6]
	}
	
	# Таблица для построения древа. Одна строка соответствует одному классу в Базе Данных
	# Прописывайте отрицательные номера навыков, чтобы использовать кастомные навыки из таблицы выше
	# номер класса (ID) => [ [номер_навыка, номер_навыка], [номер_навыка] и т.д. ]
	SKILL_TREE_SYSTEM_SKILL_CLASSES = {
		1 => [ [3], [4], [5], [6], [7, 8, 9, 10, 11] ],
		2 => [ [13, 14, 4, 5], [15, 16], [17], [18], [19], [20], [21], [-1] ],
		4 => [ [-1, 4], [5, 7] ],
		5 => [ [4, -3], [-2] ]
	}
	
	# Настройка вертикального расположение Древа
	# Укажите номера классов (ID), которые должны отображаться в вертикальном виде
	SKILL_TREE_SYSTEM_VERTICAL_TREES = [ 2, 4 ]
	
	# Таблица расположения навыков на Древе
	# Количество значений должно соответствовать количеству навыков на Древе
	# Каждая единица соответствует 16 пикселям
	# номер класса => [ [значение, значение], [значение] и т.д. ]
	SKILL_TREE_SYSTEM_SKILL_POSITION = {
		1 => [ [7], [6], [8], [4], [1, 3, 5, 7, 9] ],
		2 => [ [2, 6, 9, 12], [3, 9], [5], [4], [7], [3], [5], [7] ],
		4 => [ [1, 9], [3, 5] ],
		5 => [ [3, 5], [5] ]
	}
	
	# Таблица зависимостей навыков
	# номер навыка (зависимого) => [ номера навыков (родителей)]
	SKILL_TREE_SYSTEM_SKILL_REQUIRED = {
		-2 => [4],
		6 => [5],
		7 => [4, 6],
		8 => [6],
		9 => [6],
		10 => [6],
		11 => [6],
		12 => [6],
		15 => [ 13],
		16 => [4, 5, 14],
		17 => [15, 16],
		18 => [17],
		19 => [16],
		20 => [18, 19],
		21 => [20],
		-1 => [21]
	}
	
	# Таблица уровней, когда персонаж не получает очки
	# Чтобы не использовать: SKILL_TREE_SYSTEM_SKIP_LVL = {}
	# ID персонажа => [ уровни ]
	SKILL_TREE_SYSTEM_SKIP_LVL = {
		#~ 1 => [2, 3],
		#~ 2 => [3]
	}
	
	# Конец настройки скрипта!
	# ниже не трогать :)
	
end # module Skill_Tree_System_Settings

class Skill_Tree_System_Viewport < Viewport
	
	attr_accessor :skills
	attr_accessor :lines
	
	def initialize(x, y, width, height)
		super(x, y, width, height)
		@skills = []
		@lines = []
	end
	
end # class Skill_Tree_System_Viewport < Viewport

class Skill_Tree_System_Scene < Scene_Base
	
	include Skill_Tree_System_Settings
	
	def start
		super
		@actor = $game_party.menu_actor # текущий персонаж
		@can_update_skill_tree_window_movement = true # можно ли обновлять курсор окна древа
		@last_cursor_layer = 0 # сохранить уровень на древе
		@last_cursor_index = 0 # сохранить индекс на древе
		@viewport = Skill_Tree_System_Viewport.new(0, 138, 544, 230)
		return return_scene if !$imported["DenKyz_Skill_Tree_System"] || check_actor_class
		create_background
		create_all_window
	end
	
	def check_actor_class
		if !$SKILL_TREE_SYSTEM_SKILL_CLASSES.has_key?(@actor.class_id)
			msgbox("Для класса #{$data_classes[@actor.class_id].name} не существует Древа Навыков! Проверьте настройки скрипта!")
			return true
		end
		return false
	end
	
	def return_scene
		Audio.se_play("Audio/SE/Cancel2", 100)
		dispose_background
		@create_skill_tree_window.dispose_all if !@create_skill_tree_window.nil?
		super
	end
	
	def create_background
		dispose_background
		return if !SKILL_TREE_SYSTEM_BACKGROUND.has_key?(@actor.class_id) && !SKILL_TREE_SYSTEM_MAP_BACKGROUND
		@background = Sprite.new
		if SKILL_TREE_SYSTEM_BACKGROUND.has_key?(@actor.class_id)
			@background.bitmap = Bitmap.new("Graphics/Skill_Tree_System/" + SKILL_TREE_SYSTEM_BACKGROUND[@actor.class_id])
		else
			@background.bitmap = SceneManager.background_bitmap
		end
	end
	
	def dispose_background
		return if @background.nil?
		@background.dispose
		@background = nil
	end
	
	def create_all_window
		create_description_window
		create_skill_tree_window
		create_info_window
	end
	
	def create_description_window
		@create_description_window = Skill_Tree_System_Description_Window.new(@actor)
	end
	
	def create_skill_tree_window
		@create_skill_tree_window = Skill_Tree_System_Tree_Window.new(@viewport, @actor)
	end
	
	def create_info_window
		@create_info_window = Skill_Tree_System_Info_Window.new(@actor)
	end
	
	def create_confirm_window
		dispose_confirm_window
		skill_id = $SKILL_TREE_SYSTEM_SKILL_CLASSES[@actor.class_id][@create_skill_tree_window.cursor_layer][@create_skill_tree_window.cursor_index]
		skill = skill_id < 0 ? $Skill_Tree_System_Custom_Skills[skill_id] : $data_skills[skill_id]
		skill = Skill_Tree_System_Functions.get_skill_from_lvl(@actor, skill)
		@create_confirm_window = Skill_Tree_System_Confirm_Command_Window.new(@actor, skill)
		@create_confirm_window.set_handler(:cancel, method(:dispose_confirm_window))
		@create_confirm_window.set_handler(:learn_skill, method(:learn_skill))
		@create_description_window.hide_skill_info
		@last_cursor_layer = @create_skill_tree_window.cursor_layer
		@last_cursor_index = @create_skill_tree_window.cursor_index
		@create_skill_tree_window.dispose_all
		@can_update_skill_tree_window_movement = false
	end
	
	def dispose_confirm_window(ignore_setup_cursor = false)
		return if @create_confirm_window.nil?
		@create_confirm_window.dispose
		@create_confirm_window = nil
		if !ignore_setup_cursor # если нажали отмена, то возвращаем курсор
			@create_skill_tree_window.setup(@actor)
			@create_skill_tree_window.setup_cursor(@last_cursor_layer, @last_cursor_index)
		end
		update_skill_id
		@create_description_window.show_skill_info
		@can_update_skill_tree_window_movement = true
	end
	
	def learn_skill
		skill = @create_confirm_window.skill
		actor_change_class = Skill_Tree_System_Functions.learn_skill(@actor, skill) # поменял ли персонаж класс
		actor_change(actor_change_class)
		dispose_confirm_window(actor_change_class)
	end
	
	def next_actor
		@actor = $game_party.menu_actor_next
		actor_change
	end
	
	def prev_actor
		@actor = $game_party.menu_actor_prev
		actor_change
	end
	
	def actor_change(ignore_members_size = false)
		# если один персонаж, то ничего не меняем
		return if $game_party.members.size == 1 && !ignore_members_size
		return return_scene if check_actor_class
		create_background
		update_actor
		update_skill_id
	end
	
	def update_actor
		@create_description_window.actor = @actor
		@create_skill_tree_window.actor = @actor
		@create_info_window.actor = @actor
	end
	
	def update_skill_id 
		@create_description_window.skill_id = $SKILL_TREE_SYSTEM_SKILL_CLASSES[@actor.class_id][@create_skill_tree_window.cursor_layer][@create_skill_tree_window.cursor_index]
	end
	
	def update
		super
		return if !@can_update_skill_tree_window_movement
		case @create_skill_tree_window.movement
		when 5
			create_confirm_window
		when 6
			return_scene
		when 7
			next_actor if SKILL_TREE_SYSTEM_ACTOR_CHANGE && SKILL_TREE_SYSTEM_SINGLE_PLAYER == -1
		when 8
			prev_actor if SKILL_TREE_SYSTEM_ACTOR_CHANGE && SKILL_TREE_SYSTEM_SINGLE_PLAYER == -1
		when 9
		else
			update_skill_id
			@create_skill_tree_window.draw_skill_info
			Audio.se_play("Audio/SE/Cursor2", 100)
		end
	end
	
end # class Game_Skill_Tree < Scene_Base

class RPG::Skill < RPG::UsableItem
	
	include Skill_Tree_System_Settings
	
	attr_reader :skill_tree_system_preset
	
	def initialize(id)
		self.id = id
		preset = skill_tree_system_preset
		self.name = ""
		self.name = preset[:name] if preset[:name]
		self.icon_index = 0
		self.icon_index = preset[:icon_index] if preset[:icon_index]
		self.description = ""
		self.description = preset[:description] if preset[:description]
		self.stype_id = ""
		self.stype_id = preset[:type] if preset[:type]
	end
	
	def skill_tree_system_preset
		return custom_skill? ? SKILL_TREE_SYSTEM_CUSTOM_SKILLS[self.id] : SKILL_TREE_SYSTEM_BASE_SKILLS[self.id]
	end
	
	def custom_skill?
		return self.id < 0
	end
	
end # class RPG::Skill < RPG::UsableItem

class Skill_Tree_System_Skill_Line_Class
	
	include Skill_Tree_System_Settings
	
	def initialize(x, y, length, angle, actor, child_skill, viewport)
		@x = x
		@y = y
		@length = length
		@angle = angle
		@actor = actor
		@child_skill = Skill_Tree_System_Functions.get_skill_from_lvl(actor, child_skill)
		@child_skill_learn_state = Skill_Tree_System_Functions.get_skill_learn_state(@actor, @child_skill)
		@viewport = viewport
		create_line
	end
	
	def get_line_color
		path = "Graphics/System/Window"
		path = "Graphics/Skill_Tree_System" + SKILL_TREE_SYSTEM_WINDOWSKIN if SKILL_TREE_SYSTEM_WINDOWSKIN != ""
		windowskin = Bitmap.new(path)
		n = SKILL_TREE_SYSTEM_LINE_SETTINGS[:graphic][@child_skill_learn_state - 1]
		color = windowskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
		windowskin.dispose
		return color
	end
	
	def get_line_bitmap
		graphic = SKILL_TREE_SYSTEM_LINE_SETTINGS[:graphic][@child_skill_learn_state - 1]
		if graphic.is_a?(String)
			bitmap = Bitmap.new("Graphics/Skill_Tree_System/" + graphic)
		else
			height = 2
			height = 3 if @angle.to_i == -90 # при вертикальном Древе и прямой линии спрайт получался тоньше, чем у кривой линии
			bitmap = Bitmap.new(@length, height)
			bitmap.fill_rect(Rect.new(0, 0, @length, height), get_line_color)
		end
		return bitmap
	end
	
	def get_line_opacity
		opacity = SKILL_TREE_SYSTEM_LINE_SETTINGS[:opacity][@child_skill_learn_state - 1]
		return @sprite_line.opacity if opacity.nil? || opacity == -1
		return opacity
	end
	
	def create_line
		dispose_line
		@sprite_line = Sprite.new(@viewport)
		@sprite_line.bitmap = get_line_bitmap
		@sprite_line.x = @x
		@sprite_line.y = @y
		@sprite_line.angle = @angle
		@sprite_line.opacity = get_line_opacity
	end
	
	def dispose_line
		return if @sprite_line.nil?
		@sprite_line.dispose
		@sprite_line = nil
	end
	
end # class Skill_Tree_System_Skill_Line_Class

class Skill_Tree_System_Skill_Class
	
	include Skill_Tree_System_Settings
	
	attr_accessor :skill
	
	def initialize(x, y, actor, skill, viewport)
		@x = x
		@y = y
		@actor = actor
		@skill = Skill_Tree_System_Functions.get_skill_from_lvl(actor, skill)
		@skill_learn_state = Skill_Tree_System_Functions.get_skill_learn_state(@actor, @skill)
		@viewport = viewport
		create_skill_background
		create_skill_icon
	end
	
	def get_background_color
		path = "Graphics/System/Window"
		path = "Graphics/Skill_Tree_System" + SKILL_TREE_SYSTEM_WINDOWSKIN if SKILL_TREE_SYSTEM_WINDOWSKIN != ""
		windowskin = Bitmap.new(path)
		n = nil
		n = SKILL_TREE_SYSTEM_SKILL_BACKGROUND[@skill.id][:graphic][@skill_learn_state - 1] if SKILL_TREE_SYSTEM_SKILL_BACKGROUND.has_key?(@skill.id)
		n = SKILL_TREE_SYSTEM_BACKGROUND_SETTINGS[:graphic][@skill_learn_state - 1] if n.nil? || n == -1
		color = windowskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
		windowskin.dispose
		return color
	end
	
	def get_background_bitmap
		graphic = nil
		graphic = SKILL_TREE_SYSTEM_SKILL_BACKGROUND[@skill.id][:graphic][@skill_learn_state - 1] if SKILL_TREE_SYSTEM_SKILL_BACKGROUND.has_key?(@skill.id)
		graphic = SKILL_TREE_SYSTEM_BACKGROUND_SETTINGS[:graphic][@skill_learn_state - 1] if graphic.nil? || graphic == -1
		if graphic.is_a?(String)
			bitmap = Bitmap.new("Graphics/Skill_Tree_System/" + graphic)
		else
			bitmap = Bitmap.new(32, 32)
			bitmap.fill_rect(Rect.new(0, 0, 32, 32), get_background_color)
		end
		return bitmap
	end
	
	def get_background_opacity
		if SKILL_TREE_SYSTEM_SKILL_BACKGROUND.has_key?(@skill.id)
			opacity = SKILL_TREE_SYSTEM_SKILL_BACKGROUND[@skill.id][:opacity][@skill_learn_state - 1]
		else
			opacity = SKILL_TREE_SYSTEM_BACKGROUND_SETTINGS[:opacity][@skill_learn_state - 1]
		end
		return @sprite_background.opacity if opacity.nil? || opacity == -1
		return opacity
	end
	
	def create_skill_background
		dispose_skill_background
		@sprite_background = Sprite.new(@viewport)
		@sprite_background.bitmap = get_background_bitmap
		@sprite_background.x = @x
		@sprite_background.y = @y
		@sprite_background.opacity = get_background_opacity
	end
	
	def create_skill_icon
		dispose_skill_icon
		@sprite_icon = Sprite.new(@viewport)
		@sprite_icon.bitmap = Bitmap.new("Graphics/System/Iconset")
		rect = Rect.new(@skill.icon_index % 16 * 24, @skill.icon_index / 16 * 24, 24, 24)
		@sprite_icon.src_rect.set(rect)
		@sprite_icon.x = @x + 4
		@sprite_icon.y = @y + 4
		@sprite_icon.opacity = 175 if @skill_learn_state != 1
	end
	
	def dispose_skill_background
		return if @sprite_background.nil?
		@sprite_background.dispose
		@sprite_background = nil
	end
	
	def dispose_skill_icon
		return if @sprite_icon.nil?
		@sprite_icon.dispose
		@sprite_icon = nil
	end
	
	def dispose_all
		dispose_skill_background
		dispose_skill_icon
	end
	
end # class Skill_Tree_System_Skill_Class

class Skill_Tree_System_Description_Window < Window_Base
	
	include Skill_Tree_System_Settings
	
	def initialize(actor)
		@actor = actor
		skill_id = $SKILL_TREE_SYSTEM_SKILL_CLASSES[@actor.class_id][0][0]
		@skill = skill_id < 0 ? $Skill_Tree_System_Custom_Skills[skill_id] : $data_skills[skill_id]
		super(0, 0, Graphics.width, 96)
		Skill_Tree_System_Functions.window_setup(self, SKILL_TREE_SYSTEM_WINDOW_PRESET[:description])
		draw_skill_info
	end
	
	def actor=(actor)
		@actor = actor
		draw_skill_info
	end
	
	def skill_id=(skill_id)
		return if @skill.id == skill_id
		@skill = skill_id < 0 ? $Skill_Tree_System_Custom_Skills[skill_id] : $data_skills[skill_id]
		draw_skill_info
	end
	
	def show_skill_info
		draw_skill_info
	end
	
	def hide_skill_info
		contents.clear
	end
	
	def reset_font_settings(font = :description_font)
		return Skill_Tree_System_Functions.reset_font_settings(self, nil) if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:description)
		Skill_Tree_System_Functions.reset_font_settings(self, SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][font])
	end
	
	def name_color
		return 24 if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:description)
		if SKILL_TREE_SYSTEM_WINDOW_PRESET[:description].has_key?(:name_font)
			if !SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][:name_font][3].nil?
				return SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][:name_font][3] if SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][:name_font][3] != -1
			end
		end
		return 24
	end
	
	def other_color
		return 0 if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:description)
		if SKILL_TREE_SYSTEM_WINDOW_PRESET[:description].has_key?(:other_font)
			if !SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][:other_font][3].nil?
				return SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][:other_font][3] if SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][:other_font][3] != -1
			end
		end
		return 0
	end
	
	def description_color
		return 0 if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:description)
		if SKILL_TREE_SYSTEM_WINDOW_PRESET[:description].has_key?(:description_font)
			if !SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][:description_font][3].nil?
				return SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][:description_font][3] if SKILL_TREE_SYSTEM_WINDOW_PRESET[:description][:description_font][3] != -1
			end
		end
		return 0
	end
	
	def draw_skill_info
		contents.clear
		skill = Skill_Tree_System_Functions.get_skill_from_lvl(@actor, @skill)
		reset_font_settings(:name_font)
		change_color(text_color(name_color))
		draw_text(0, 0, contents_width, line_height, skill.name, 1)
		reset_font_settings(:other_font)
		change_color(text_color(other_color))
		if skill.id > 0
			skill_type = $data_system.skill_types[skill.stype_id]
		else
			skill_type = skill.stype_id if skill.stype_id.is_a?(String)
			skill_type = $data_system.skill_types[skill.stype_id] if skill.stype_id.is_a?(Integer)
		end
		if skill_type != ""
			draw_text(0, 0, contents_width, line_height, skill_type)
		end
		skill_lvl = Skill_Tree_System_Functions.get_skill_lvl(@actor, @skill)
		skill_max_lvl = Skill_Tree_System_Functions.get_skill_max_lvl(@skill)
		if skill_lvl < skill_max_lvl
			draw_text(0, 0, contents_width, line_height, "Уровень: " + skill_lvl.to_s + "/" + skill_max_lvl.to_s, 2) if skill_lvl > 0
		else
			draw_text(0, 0, contents_width, line_height, "Изучено", 2) if @actor.skill_learn?(@skill)
		end
		contents.fill_rect(0, line_height, contents_width, 1, normal_color)
		change_color(text_color(description_color))
		draw_text_ex(0, line_height, skill.description)
	end
	
	def update
	end
	
end # class Skill_Tree_System_Description_Window < Window_Base

class Skill_Tree_System_Tree_Window < Window_Base
	
	include Skill_Tree_System_Settings
	
	attr_reader 	:cursor_layer
	attr_reader 	:cursor_index
	
	def initialize(viewport, actor)
		super(0, line_height * 4, Graphics.width, Graphics.height - line_height * 6)
		Skill_Tree_System_Functions.window_setup(self, SKILL_TREE_SYSTEM_WINDOW_PRESET[:tree])
		@viewport = viewport
		@viewport.z = 200
		setup(actor)
	end
	
	def reset_font_settings
		return Skill_Tree_System_Functions.reset_font_settings(self, nil) if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:tree)
		Skill_Tree_System_Functions.reset_font_settings(self, SKILL_TREE_SYSTEM_WINDOW_PRESET[:tree][:name_font])
	end
	
	def setup(actor)
		dispose_all
		@actor = actor
		@sprite_cursor = nil
		@skill_class = $SKILL_TREE_SYSTEM_SKILL_CLASSES[@actor.class_id] # массив навыков для класса
		@vertical_tree = SKILL_TREE_SYSTEM_VERTICAL_TREES.include?(@actor.class_id)
		setup_cursor_variable(0, 0)
		create_skill_tree
		create_skill_cursor
		draw_skill_info
	end
	
	def actor=(actor)
		setup(actor)
	end
	
	def setup_cursor_variable(layer, index)
		@cursor_layer = layer # уровень курсора на Древе
		@cursor_index = index # индекс курсора на Древе
	end
	
	def setup_cursor(layer, index)
		setup_cursor_variable(layer, index)
		update_cursor_position
	end
	
	def get_x(cursor_layer, cursor_index)
		if @vertical_tree
			return 16 * $SKILL_TREE_SYSTEM_SKILL_POSITION[@actor.class_id][cursor_layer][cursor_index]
		else
			return 16 + 94 * cursor_layer
		end
	end
	
	def get_y(cursor_layer, cursor_index)
		if @vertical_tree
			return 8 + 90 * cursor_layer
		else
			return 16 * $SKILL_TREE_SYSTEM_SKILL_POSITION[@actor.class_id][cursor_layer][cursor_index]
		end
	end
	
	def create_skill_tree
		cursor_layer = 0
		cursor_index = 0
		@skill_class.each do |index|
			index.each do |id|
				skill = id < 0 ? $Skill_Tree_System_Custom_Skills[id] : $data_skills[id]
				skill = Skill_Tree_System_Functions.get_skill_from_lvl(@actor, skill)
				skill_x = get_x(cursor_layer, cursor_index)
				skill_y = get_y(cursor_layer, cursor_index)
				@viewport.skills.push(Skill_Tree_System_Skill_Class.new(skill_x, skill_y, @actor, skill, @viewport))
				cursor_index += 1
			end
			cursor_index = 0
			cursor_layer += 1
		end
		create_lines
	end
	
	def create_lines
		cur_lay = 0
		cur_ind = 0
		@skill_class.each do |class_mas|
			class_mas.each do |index|
				skill = index < 0 ? $Skill_Tree_System_Custom_Skills[index] : $data_skills[index]
				child_skills = get_child_skills(skill) # находим все дочернии навыки
				child_skills.each do |child_id| # создаем связи родительского навыка с дочерними
					child_cur_lay, child_cur_ind = get_layer_index(child_id) # координаты уровня и индекса дочернего навыка
					create_line(cur_lay, cur_ind, child_cur_lay, child_cur_ind, child_id)
				end
				cur_ind += 1
			end
			cur_lay += 1
			cur_ind = 0
			return if cur_lay == @skill_class.size
		end
	end
	
	# находим дочерние навыки, находя у навыков зависимости и поиск в них id родительского навыка
	def get_child_skills(sk)
		mas = []
		@skill_class.each do |class_mas|
			class_mas.each do |index|
				next if index == sk.id
				skill = index < 0 ? $Skill_Tree_System_Custom_Skills[index] : $data_skills[index]
				needed = Skill_Tree_System_Functions.get_needed_skills(@actor, skill)
				next if needed == []
				mas.push(index) if needed.include?(sk.id)
			end
		end
		return mas
	end
	
	# находим координаты навыка (уровень, индекс) по id на древе
	def get_layer_index(skill_id)
		cur_lay = 0
		cur_ind = 0
		@skill_class.each do |class_mas|
			class_mas.each do |index|
				return cur_lay, cur_ind if index == skill_id
				cur_ind += 1
			end
			cur_lay += 1
			cur_ind = 0
		end
	end
	
	# добавляем новую линию
	def create_line(cur_lay, cur_ind, child_cur_lay, child_cur_ind, child_skill_id)
		if @vertical_tree
			x = get_x(cur_lay, cur_ind) + 16
			y = get_y(cur_lay, cur_ind) + 32
		else
			x = get_x(cur_lay, cur_ind) + 32 # + 32 - конец спрайта
			y = get_y(cur_lay, cur_ind) + 16 # + 16 - середина фона навыка (32 х 32)
		end
		length, angle = get_line_angle(cur_lay, cur_ind, child_cur_lay, child_cur_ind)
		skill = child_skill_id < 0 ? $Skill_Tree_System_Custom_Skills[child_skill_id] : $data_skills[child_skill_id]
		@viewport.lines.push(Skill_Tree_System_Skill_Line_Class.new(x, y, length, angle,  @actor, skill, @viewport))
	end
	
	# считаем угол для линии с помощью теоремы Пифагора
	def get_line_angle(last_cur_lay, last_cur_ind, cur_lay, cur_ind)
		if @vertical_tree
			a = get_x(cur_lay, cur_ind) - get_x(last_cur_lay, last_cur_ind)
			b = get_y(cur_lay, cur_ind) - (get_y(last_cur_lay, last_cur_ind) + 32)
		else
			a = get_x(cur_lay, cur_ind) - (get_x(last_cur_lay, last_cur_ind) + 32)
			b = get_y(cur_lay, cur_ind) - get_y(last_cur_lay, last_cur_ind)
		end
		c = Math.sqrt(a * a + b * b)
		if @vertical_tree
			angle = (180 / Math::PI) * Math.acos(a / c)
		else
			angle = (180 / Math::PI) * Math.asin(b / c)
		end
		return [c.to_i, -angle]
	end
	
	def dispose_skill_tree
		@viewport.skills.each do |index|
			index.dispose_all
		end
	end
	
	def dispose_lines
		@viewport.lines.each do |line|
			line.dispose_line
		end
	end
	
	def create_skill_cursor
		@sprite_cursor_update_animation = true # обновление анимации (true - удаление от навыка, false - приближение к навыку)
		@sprite_cursor_update_animation_count = 0 # счетчик для анимации курсора
		dispose_skill_cursor
		@sprite_cursor = Sprite.new
		@sprite_cursor.z = @viewport.z
		if SKILL_TREE_SYSTEM_CURSOR_SETTINGS == {} || SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:graphic] == "" || SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:graphic] == -1
			@sprite_cursor.bitmap = self.windowskin
			rect = Rect.new(64, 64, 32, 32)
			@sprite_cursor.src_rect.set(rect)
		else
			@sprite_cursor.bitmap = Bitmap.new("Graphics/Skill_Tree_System/" + SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:graphic])
		end
		if SKILL_TREE_SYSTEM_CURSOR_SETTINGS.has_key?(:opacity)
			@sprite_cursor.opacity = SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:opacity] if SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:opacity] != -1
		end
		update_cursor_position
	end
	
	def dispose_skill_cursor
		return if @sprite_cursor.nil?
		@sprite_cursor.dispose
		@sprite_cursor = nil
	end
	
	def name_color
		return 0 if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:tree)
		if SKILL_TREE_SYSTEM_WINDOW_PRESET[:tree].has_key?(:name_font)
			if !SKILL_TREE_SYSTEM_WINDOW_PRESET[:tree][:name_font][3].nil?
				return SKILL_TREE_SYSTEM_WINDOW_PRESET[:tree][:name_font][3] if SKILL_TREE_SYSTEM_WINDOW_PRESET[:tree][:name_font][3] != -1
			end
		end
		return 0
	end
	
	def draw_skill_info
		contents.clear
		change_color(text_color(name_color))
		draw_text(0, 0, contents_width, line_height, $data_classes[@actor.class_id].name)
		if SKILL_TREE_SYSTEM_SKILL_STATUS
			skill_id = $SKILL_TREE_SYSTEM_SKILL_CLASSES[@actor.class_id][cursor_layer][cursor_index]
			draw_text(0, 0, contents_width, line_height, skill_id > 0 ? "Активный" : "Пассивный", 2)
		end
		contents.fill_rect(0, line_height, contents_width, 1, text_color(0))
	end
	
	def update
		update_cursor_animation
	end
	
	def update_cursor_animation
		return if @sprite_cursor.nil?
		if SKILL_TREE_SYSTEM_CURSOR_SETTINGS != {}
			return if SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:animation] < 1 || SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:animation] > 5
			return if Graphics.frame_count % 2 == 0 && SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:animation] > 1
			animation = SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:animation]
		else
			animation = 1
		end
		case animation
		when 1
			return @sprite_cursor.opacity = [7 * Graphics.frame_count % 255, 50].max
		when 2
			dx = 0
			dy = 1
			dy = -1 if @sprite_cursor_update_animation
		when 3
			dx = -1
			dx = 1 if @sprite_cursor_update_animation
			dy = 0
		when 4
			dx = 0
			dy = -1
			dy = 1 if @sprite_cursor_update_animation
		when 5
			dx = 1
			dx = -1 if @sprite_cursor_update_animation
			dy = 0
		end
		@sprite_cursor.x += dx
		@sprite_cursor.y += dy
		if @sprite_cursor_update_animation
			@sprite_cursor_update_animation_count += 1
			return @sprite_cursor_update_animation = false if @sprite_cursor_update_animation_count == 5
		else
			@sprite_cursor_update_animation_count -= 1
			return @sprite_cursor_update_animation = true if @sprite_cursor_update_animation_count == 0
		end
	end
	
	def movement
		return up     if Input.repeat?(:UP)
		return down   if Input.repeat?(:DOWN)
		return left   if Input.repeat?(:LEFT)
		return right  if Input.repeat?(:RIGHT)
		return ok     if Input.trigger?(:C)
		return cancel if Input.trigger?(:B)
		return 7 			if Input.trigger?(:R)
		return 8 			if Input.trigger?(:L)
		return 9
	end
	
	def update_cursor_position
		@sprite_cursor_update_animation = true # обновление анимации (true - удаление от навыка, false - приближение к навыку)
		@sprite_cursor_update_animation_count = 0 # счетчик для анимации курсора
		@sprite_cursor.x = get_x(@cursor_layer, @cursor_index) % 564
		@sprite_cursor.y = 138 + get_y(@cursor_layer, @cursor_index) % 270
		dx = SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:dx]
		dy = SKILL_TREE_SYSTEM_CURSOR_SETTINGS[:dy]
		@sprite_cursor.x += dx if dx.is_a?(Integer)
		@sprite_cursor.y += dy if dy.is_a?(Integer)
		if @vertical_tree
			@viewport.oy = 270 * (@cursor_layer / 3)
		else
			@viewport.ox = 564 * (@cursor_layer / 6)
		end
	end
	
	def up
		if @vertical_tree
			last_cursor = @cursor_layer
			@cursor_layer -= 1
			@cursor_layer = @cursor_layer % @skill_class.size
			@cursor_index = @skill_class[@cursor_layer].size - 1 if @skill_class[@cursor_layer].size <= @cursor_index
		else
			return 1 if @skill_class[@cursor_layer].size == 1
			@cursor_index -= 1
			@cursor_index = @cursor_index % @skill_class[@cursor_layer].size
		end
		update_cursor_position
		return 1
	end
	
	def down
		if @vertical_tree
			last_cursor = @cursor_layer
			@cursor_layer += 1
			@cursor_layer = @cursor_layer % @skill_class.size
			@cursor_index = @skill_class[@cursor_layer].size - 1 if @cursor_index >= @skill_class[@cursor_layer].size
		else
			return 2 if @skill_class[@cursor_layer].size == 1
			@cursor_index += 1
			@cursor_index = @cursor_index % @skill_class[@cursor_layer].size
		end
		update_cursor_position
		return 2
	end
	
	def left
		if @vertical_tree
			return 3 if @skill_class[@cursor_layer].size == 1
			@cursor_index -= 1
			@cursor_index = @cursor_index % @skill_class[@cursor_layer].size
		else
			last_cursor = @cursor_layer
			@cursor_layer -= 1
			@cursor_layer = @cursor_layer % @skill_class.size
			@cursor_index = @skill_class[@cursor_layer].size - 1 if @skill_class[@cursor_layer].size <= @cursor_index
		end
		update_cursor_position
		return 3
	end
	
	def right
		if @vertical_tree
			return 4 if @skill_class[@cursor_layer].size == 1
			@cursor_index += 1
			@cursor_index = @cursor_index % @skill_class[@cursor_layer].size
		else
			last_cursor = @cursor_layer
			@cursor_layer += 1
			@cursor_layer = @cursor_layer % @skill_class.size
			@cursor_index = @skill_class[@cursor_layer].size - 1 if @cursor_index >= @skill_class[@cursor_layer].size
		end
		update_cursor_position
		return 4
	end
	
	def ok
		Sound.play_ok
		return 5
	end
	
	def cancel
		dispose_all
		return 6
	end
	
	def dispose_all
		contents.clear
		dispose_skill_tree
		dispose_skill_cursor
		dispose_lines
		@viewport.skills = []
		@viewport.lines = []
	end
	
end # class Skill_Tree_System_Tree_Window < Window_Base

class Skill_Tree_System_Info_Window < Window_Base
	
	include Skill_Tree_System_Settings
	
	def initialize(actor)
		@actor = actor
		super(0, Graphics.height - line_height * 2, Graphics.width, line_height * 2)
		Skill_Tree_System_Functions.window_setup(self, SKILL_TREE_SYSTEM_WINDOW_PRESET[:info])
		draw_info
	end
	
	def actor=(actor)
		@actor = actor
		draw_info
	end
	
	def reset_font_settings
		return Skill_Tree_System_Functions.reset_font_settings(self, nil) if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:info)
		Skill_Tree_System_Functions.reset_font_settings(self, SKILL_TREE_SYSTEM_WINDOW_PRESET[:info][:name_font])
	end
	
	def name_color
		return 16 if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:info)
		if SKILL_TREE_SYSTEM_WINDOW_PRESET[:info].has_key?(:name_font)
			if !SKILL_TREE_SYSTEM_WINDOW_PRESET[:info][:name_font][3].nil?
				return SKILL_TREE_SYSTEM_WINDOW_PRESET[:info][:name_font][3] if SKILL_TREE_SYSTEM_WINDOW_PRESET[:info][:name_font][3] != -1
			end
		end
		return 16
	end
	
	def draw_info
		contents.clear
		draw_text_ex(0, 0, "\\c[#{name_color}]Свободные очки: \\c[0]" + @actor.skill_point.to_s)
		change_color(text_color(name_color))
		draw_text(0, 0, contents_width, line_height, @actor.name, 2)
	end
	
	def update
		return if @last_skill_point == @actor.skill_point && @last_actor_name == @actor.name
		@last_skill_point = @actor.skill_point
		@last_actor_name = @actor.name
		draw_info
	end
	
end # class Skill_Tree_System_Info_Window < Window_Base

class Skill_Tree_System_Confirm_Command_Window < Window_Command
	
	include Skill_Tree_System_Settings
	
	attr_reader :skill
	
	def initialize(actor, skill)
		@actor = actor
		@skill = skill
		@skill_learn_state = Skill_Tree_System_Functions.get_skill_learn_state(@actor, @skill)
		super(0, 0)
		Skill_Tree_System_Functions.window_setup(self, SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm])
		draw_table
	end
	
	def alignment
		1
	end
	
	def update_tone
		return if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:confirm)
		Skill_Tree_System_Functions.tone_setup(self, SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm])
	end
	
	def window_width
		Graphics.width
	end
	
	def window_height
		Graphics.height - line_height * 2
	end
	
	def param_color(param)
		change_color(text_color(2)) if param < 0
		change_color(text_color(8)) if param == 0
		change_color(text_color(24)) if param > 0
	end
	
	def param_text(param)
		return "+" if param > 0
		return ""
	end
	
	def reset_font_settings(font)
		return Skill_Tree_System_Functions.reset_font_settings(self, nil) if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:confirm)
		Skill_Tree_System_Functions.reset_font_settings(self, SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm][font])
	end
	
	def draw_text_ex(x, y, text)
		text = convert_escape_characters(text)
		pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
		process_character(text.slice!(0, 1), text, pos) until text.empty?
	end
	
	def color(font, default_color)
		return default_color if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:confirm)
		if SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm].has_key?(font)
			if !SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm][font][3].nil?
				return SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm][font][3] if SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm][font][3] != -1
			end
		end
		return default_color
	end
	
	def line_color
		return normal_color if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:confirm)
		if SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm].has_key?(:line_color)
			return text_color(SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm][:line_color]) if SKILL_TREE_SYSTEM_WINDOW_PRESET[:confirm][:line_color] != -1
		end
		return normal_color
	end
	
	def actor_param_color
		return 16 if !SKILL_TREE_SYSTEM_WINDOW_PRESET.has_key?(:info)
		if SKILL_TREE_SYSTEM_WINDOW_PRESET[:info].has_key?(:name_font)
			if !SKILL_TREE_SYSTEM_WINDOW_PRESET[:info][:name_font][3].nil?
				return SKILL_TREE_SYSTEM_WINDOW_PRESET[:info][:name_font][3] if SKILL_TREE_SYSTEM_WINDOW_PRESET[:info][:name_font][3] != -1
			end
		end
		return 16
	end
	
	def draw_table
		draw_window_title
		draw_table_titles
		draw_lines
		draw_left_column
		draw_right_column
	end
	
	def draw_window_title
		reset_font_settings(:title_font)
		if @actor.skill_learn?(@skill)
			change_color(text_color(color(:title_font, 24)))
			draw_text(0, 0, contents_width, line_height, @skill.name, 1)
		else
			text_width = text_size("Изучить " + @skill.name + " ?").width
			draw_text_ex((contents_width - text_width) / 2, 0, "\\c[0]Изучить \\c[#{color(:title_font, 24)}]" + @skill.name + " \\c[0]?")
		end
	end
	
	def draw_table_titles
		reset_font_settings(:table_font)
		change_color(text_color(color(:table_font, 21)))
		draw_text(0, line_height, contents_width, line_height, "Параметры", 1)
		change_color(text_color(color(:table_font, 21)))
		y = line_height * 7
		y += line_height if @skill.id > 0
		draw_text(0, y, contents_width, line_height, "Требования", 1)
	end
	
	def draw_lines
		y = line_height
		contents.fill_rect(0, y, contents_width, 1, line_color)
		y += line_height
		contents.fill_rect(0, y, contents_width, 1, line_color)
		contents.fill_rect((contents_width - 12) / 2, line_height * 2, 1, line_height * 4, line_color)
		y += line_height * 4
		contents.fill_rect(0, y, contents_width, 1, line_color)
		if @skill.id > 0
			contents.fill_rect(0, line_height * 7, contents_width, 1, line_color)
			contents.fill_rect((contents_width - 12) / 2, y, 1, line_height, line_color) if SKILL_TREE_SYSTEM_SKILL_TP
			y += line_height
		end
		contents.fill_rect((contents_width - 12) / 2, y, 1, line_height, line_color)
		y += line_height
		contents.fill_rect(0, y, contents_width, 1, line_color)
		y += line_height
		contents.fill_rect(0, y, contents_width, 1, line_color)
		height = 1
		height = 2 if Skill_Tree_System_Functions.get_mp_cost(@skill) > 0 || Skill_Tree_System_Functions.get_gold_cost(@skill) > 0
		contents.fill_rect((contents_width - 12) / 2, y, 1, line_height * height, line_color)
		y += line_height * height
		contents.fill_rect(0, y, contents_width, 1, line_color)
	end
	
	def draw_left_column
		draw_left_column_text
		draw_left_column_value
	end
	
	def draw_left_column_text
		reset_font_settings(:other_font)
		x = 0
		y = line_height * 2
		params = [0, 2, 4, 6]
		params.each do |index|
			draw_text_ex(x, y, "\\c[#{color(:other_font, 21)}]" + $data_system.terms.params[index] + ": \\c[0]")
			y += line_height
		end
		if @skill.id > 0
			draw_text_ex(x, y, "\\c[#{color(:other_font, 21)}]Использование MP:")
			y += line_height
		end
		change_color(text_color(24))
		draw_text(x, y, contents_width, line_height, "Cостояния: ")
		y += line_height * 2
		draw_text_ex(x, y, "\\c[#{color(:other_font, 21)}]Уровень:")
		if Skill_Tree_System_Functions.get_mp_cost(@skill) > 0 || Skill_Tree_System_Functions.get_gold_cost(@skill) > 0
			y += line_height
			draw_text_ex(x, y, "\\c[#{color(:other_font, 21)}]MP:")
		end
	end
	
	def draw_left_column_value
		reset_font_settings(:value_font)
		x = 0
		y = line_height * 2
		params = [Skill_Tree_System_Functions.get_skill_parameter(@skill, :mhp), Skill_Tree_System_Functions.get_skill_parameter(@skill, :atk), Skill_Tree_System_Functions.get_skill_parameter(@skill, :mat), Skill_Tree_System_Functions.get_skill_parameter(@skill, :agi)]
		params.each do |value|
			param_color(value)
			draw_text(x, y, contents_width / 2 - 12, line_height, param_text(value) + value.to_s, 2)
			y += line_height
		end
		if @skill.id > 0
			if SKILL_TREE_SYSTEM_SKILL_TP
				mp_cost = skill.mp_cost
				mp_color = 8
				mp_color = 4 if mp_cost > 0
				change_color(text_color(mp_color))
				draw_text(x, y, contents_width / 2 - 12, line_height, mp_cost.to_s, 2)
			end
			y += line_height
		end
		actor_add_state = Skill_Tree_System_Functions.get_actor_states(@skill, :actor_add_state).reverse
		if actor_add_state != []
			i = 1
			actor_add_state.each do |index|
				draw_icon($data_states[index].icon_index, (contents_width - 12) / 2 - 24 * i, y)
				i += 1
			end
		else
			change_color(text_color(8))
			draw_text(x, y, contents_width / 2 - 12, line_height, "Нет", 2)
		end
		y += line_height * 2
		skill_lvl = Skill_Tree_System_Functions.get_actor_lvl(@skill)
		skill_lvl_color = 24
		skill_lvl_color = 2 if !Skill_Tree_System_Functions.lvl_comparsion(@actor, @skill)
		change_color(text_color(skill_lvl_color))
		text_width = text_size(" " + skill_lvl.to_s + " (" + @actor.level.to_s + ")").width
		draw_text_ex(x + (contents_width - 12) / 2 - text_width, y, skill_lvl.to_s + " \\c[0](\\c[#{actor_param_color}]" + @actor.level.to_s + "\\c[0])")
		mp_cost = Skill_Tree_System_Functions.get_mp_cost(@skill)
		if mp_cost > 0 || Skill_Tree_System_Functions.get_gold_cost(@skill) > 0
			y += line_height
			mp_color = 24
			mp_color = 2 if !Skill_Tree_System_Functions.mp_cost_comparsion(@actor, @skill)
			mp_color = 8 if mp_cost == 0
			change_color(text_color(mp_color))
			text_width = text_size(" " + mp_cost.to_s + (mp_cost > 0 ? " (" + @actor.mp.to_s + ")" : "")).width
			draw_text_ex(x + (contents_width - 12) / 2 - text_width, y, mp_cost.to_s + (mp_cost > 0 ? " \\c[0](\\c[#{actor_param_color}]" + @actor.mp.to_s + "\\c[0])" : ""))
		end	
	end
	
	def draw_right_column
		draw_right_column_text
		draw_right_column_value
	end
	
	def draw_right_column_text
		reset_font_settings(:other_font)
		x = contents_width / 2
		y = line_height * 2
		params = [1, 3, 5, 7]
		params.each do |index|
			draw_text_ex(x, y, "\\c[#{color(:other_font, 21)}]" + $data_system.terms.params[index] + ": \\c[0]")
			y += line_height
		end
		if @skill.id > 0
			draw_text_ex(x, y, "\\c[#{color(:other_font, 21)}]Использование TP:") if SKILL_TREE_SYSTEM_SKILL_TP
			y += line_height
		end
		change_color(text_color(2))
		draw_text(x, y, contents_width / 2, line_height, "Cостояния: ")
		y += line_height * 2
		draw_text_ex(x, y, "\\c[#{color(:other_font, 21)}]Очки навыков:")
		if Skill_Tree_System_Functions.get_gold_cost(@skill) > 0 || Skill_Tree_System_Functions.get_mp_cost(@skill) > 0
			y += line_height
			draw_text_ex(x, y, "\\c[#{color(:other_font, 21)}]" + Vocab::currency_unit)
		end
	end
	
	def draw_right_column_value
		reset_font_settings(:value_font)
		x = contents_width / 2
		y = line_height * 2
		params = [Skill_Tree_System_Functions.get_skill_parameter(@skill, :mmp), Skill_Tree_System_Functions.get_skill_parameter(@skill, :def), Skill_Tree_System_Functions.get_skill_parameter(@skill, :mdf), Skill_Tree_System_Functions.get_skill_parameter(@skill, :luk)]
		params.each do |value|
			param_color(value)
			draw_text(x, y, contents_width / 2, line_height, param_text(value) + value.to_s, 2)
			y += line_height
		end
		if @skill.id > 0
			if SKILL_TREE_SYSTEM_SKILL_TP
				tp_cost = skill.tp_cost
				tp_color = 8
				tp_color = 2 if tp_cost > 0
				change_color(text_color(tp_color))
				draw_text(x, y, contents_width / 2, line_height, tp_cost.to_s, 2)
			else
				mp_cost = skill.mp_cost
				mp_color = 8
				mp_color = 4 if mp_cost > 0
				change_color(text_color(mp_color))
				draw_text(x, y, contents_width / 2, line_height, mp_cost.to_s, 2)
			end
			y += line_height
		end
		actor_remove_state = Skill_Tree_System_Functions.get_actor_states(@skill, :actor_remove_state).reverse
		if actor_remove_state != []
			i = 1
			actor_remove_state.each do |index|
				draw_icon($data_states[index].icon_index, contents_width - 24 * i, y)
				i += 1
			end
		else
			change_color(text_color(8))
			draw_text(x, y, contents_width / 2, line_height, "Нет", 2)
		end
		y += line_height * 2
		sp_cost = Skill_Tree_System_Functions.get_sp_cost(@skill)
		sp_color = 24
		sp_color = 2 if !Skill_Tree_System_Functions.sp_cost_comparsion(@actor, @skill)
		sp_color = 8 if sp_cost == 0
		change_color(text_color(sp_color))
		text_width = text_size(sp_cost.to_s + (sp_cost > 0 ? " (" + @actor.skill_point.to_s + ")" : "")).width + 2 # + 2 чтобы курсив влез
		draw_text_ex(x + contents_width / 2 - text_width, y, sp_cost.to_s + (sp_cost > 0 ? " \\c[0](\\c[#{actor_param_color}]" + @actor.skill_point.to_s + "\\c[0])" : ""))
		gold_cost = Skill_Tree_System_Functions.get_gold_cost(@skill)
		if gold_cost > 0 || Skill_Tree_System_Functions.get_mp_cost(@skill) > 0
			y += line_height
			gold_color = 24
			gold_color = 2 if !Skill_Tree_System_Functions.gold_cost_comparsion(@skill)
			gold_color = 8 if gold_cost == 0
			change_color(text_color(gold_color))
			text_width = text_size(gold_cost.to_s + (gold_cost > 0 ? " (" + $game_party.gold.to_s + ")" : "")).width + 2 # + 2 чтобы курсив влез
			draw_text_ex(x + contents_width / 2 - text_width, y, gold_cost.to_s + (gold_cost > 0 ? " \\c[0](\\c[#{actor_param_color}]" + $game_party.gold.to_s + "\\c[0])" : ""))
		end	
	end
	
	def item_rect(index)
		rect = Rect.new
		rect.width = item_width / 2
		rect.height = item_height
		rect.x = index * item_width / 2
		rect.y = contents_height - item_height
		rect
	end
	
	def make_command_list
		add_command("Отменить", :cancel)
		text = "Изучить"
		enable = true
		if @skill_learn_state == 1
			text = "Изучено"
			enable = false
		elsif @skill_learn_state == 3
			enable = false
		end
		add_command(text, :learn_skill, enable)
	end
	
	def cursor_left(wrap = false)
		if index < item_max - col_max || (wrap && col_max == 1)
			select((index + col_max) % item_max)
		end
	end
	
	def cursor_right(wrap = false)
		if index >= col_max || (wrap && col_max == 1)
			select((index - col_max + item_max) % item_max)
		end
	end
	
	def cursor_up(wrap = false)
	end
	
	def cursor_down(wrap = false)
	end
	
end # class Skill_Tree_System_Confirm_Command_Window < Window_Command

$imported = {} if $imported.nil?
$imported["DenKyz_Skill_Tree_System"] = true

class Skill_Tree_System_Functions
	
	include Skill_Tree_System_Settings
	
	# установка настроек для окна
	def self.window_setup(window, preset)
		window.windowskin = Bitmap.new("Graphics/Skill_Tree_System/" + SKILL_TREE_SYSTEM_WINDOWSKIN) if SKILL_TREE_SYSTEM_WINDOWSKIN != ""
		return if preset.nil?
		tone_setup(window, preset)
		if preset.has_key?(:modify)
			modify_skin(window) if preset[:modify]
		end
		if preset.has_key?(:opacity)
			opacity = preset[:opacity]
			window.opacity = opacity[0] if opacity[0] != -1
			window.contents_opacity = opacity[1] if opacity[1] != -1
			window.back_opacity = opacity[2] if opacity[2] != -1
		end
	end
	
	# установка настроек шрифта в окне
	def self.reset_font_settings(window, preset)
		preset = default_font if preset.nil?
		preset = default_font if preset == []
		window.contents.font.name = preset[0] if preset[0] != -1
		window.contents.font.bold = preset[1] if preset[1] != -1
		window.contents.font.italic = preset[2] if preset[2] != -1
	end
	
	# стандартный шрифт
	def self.default_font
		return [Font.default_name, Font.default_bold, Font.default_italic]
	end
	
	# установка тона окна
	def self.tone_setup(window, preset)
		return if preset.nil?
		if preset.has_key?(:tone)
			window.tone = preset[:tone] if preset[:tone] != -1
		end
	end
	
	# модификация окна
	def self.modify_skin(window)
		dup_skin = window.windowskin.dup
		dup_skin.clear_rect(64,  0, 64, 64)
		window.windowskin = dup_skin
	end
	
	# найти персонажа в партии по ID из БД
	def self.get_actor_from_id(actor_id)
		actor_id = SKILL_TREE_SYSTEM_SINGLE_PLAYER if SKILL_TREE_SYSTEM_SINGLE_PLAYER != -1
		actor = nil
		$game_party.members.each do |index|
			actor = index if index.actor_id == actor_id
		end
		return actor
	end
	
	# получить параметр навыка (mhp, mmp и т. д.)
	def self.get_skill_parameter(skill, parameter)
		preset = skill.skill_tree_system_preset
		return 0 if preset.nil?
		return preset[parameter] if preset.has_key?(parameter)
		return 0
	end
	
	# получить состояния навыка
	def self.get_actor_states(skill, parameter)
		preset = skill.skill_tree_system_preset
		return [] if preset.nil?
		return preset[parameter] if preset.has_key?(parameter)
		return []
	end
	
	# требуемый уровень персонажа для изучения навыка
	def self.get_actor_lvl(skill)
		preset = skill.skill_tree_system_preset
		return 1 if preset.nil?
		return preset[:actor_lvl] if preset.has_key?(:actor_lvl)
		return 1
	end
	
	# текущий уровень навыка
	def self.get_skill_lvl(actor, skill)
		return 0 if !SKILL_TREE_SYSTEM_SKILL_LVL.has_key?(skill.id)
		lvl = 0
		lvl = 1 if actor.skill_learn?(skill)
		SKILL_TREE_SYSTEM_SKILL_LVL[skill.id].each do |index|
			skill = index < 0 ? $Skill_Tree_System_Custom_Skills[index] : $data_skills[index]
			if actor.skill_learn?(skill)
				lvl += 1
			else
				return lvl
			end
		end
		return lvl
	end
	
	# максимальный уровень навыка
	def self.get_skill_max_lvl(skill)
		return 0 if !SKILL_TREE_SYSTEM_SKILL_LVL.has_key?(skill.id)
		return SKILL_TREE_SYSTEM_SKILL_LVL[skill.id].size + 1
	end
	
	# если у навыка есть уровни, то получить навык уровня
	def self.get_skill_from_lvl(actor, skill)
		skill_lvl = get_skill_lvl(actor, skill)
		if skill_lvl > 0
			if skill_lvl == get_skill_max_lvl(skill) # если все уровни навыка изучены, то возвращаем последний уровень
				skill_id = SKILL_TREE_SYSTEM_SKILL_LVL[skill.id][-1]
			else
				skill_id = SKILL_TREE_SYSTEM_SKILL_LVL[skill.id][skill_lvl - 1]
			end
			skill = skill_id < 0 ? $Skill_Tree_System_Custom_Skills[skill_id] : $data_skills[skill_id]
		end
		return skill
	end
	
	# количество очков, требуемых для изучения навыка
	def self.get_sp_cost(skill)
		preset = skill.skill_tree_system_preset
		return (get_mp_cost(skill) > 0 || get_gold_cost(skill) > 0 ? 0 : 1) if preset.nil?
		return preset[:sp_cost] if preset.has_key?(:sp_cost)
		return (get_mp_cost(skill) > 0 || get_gold_cost(skill) > 0 ? 0 : 1)
	end
	
	# сколько mp стоит навык
	def self.get_mp_cost(skill)
		preset = skill.skill_tree_system_preset
		return 0 if preset.nil?
		return preset[:mp_cost] if preset.has_key?(:mp_cost)
		return 0
	end
	
	# сколько золота стоит навык
	def self.get_gold_cost(skill)
		preset = skill.skill_tree_system_preset
		return 0 if preset.nil?
		return preset[:gold_cost] if preset.has_key?(:gold_cost)
		return 0
	end
	
	# сравнение уровня персонажа и минимального уровня навыка
	def self.lvl_comparsion(actor, skill)
		return actor.level >= get_actor_lvl(skill)
	end
	
	# хватает ли sp для изучения навыка
	def self.sp_cost_comparsion(actor, skill)
		return actor.skill_point >= get_sp_cost(skill)
	end
	
	# хватает ли mp для изучения навыка
	def self.mp_cost_comparsion(actor, skill)
		return actor.mp >= get_mp_cost(skill)
	end
	
	# хватает ли gold для	изучения навыка
	def self.gold_cost_comparsion(skill)
		return $game_party.gold >= get_gold_cost(skill)
	end
	
	# изучить навык
	def self.learn_skill(actor, skill)
		confirm_cost(actor, skill)
		actor.learn_skill(skill.id)
		return learn_skill_parameters(actor, skill.skill_tree_system_preset)
	end
	
	# отнять у персонажа требования к изучению навыка (sp, mp, gold)
	def self.confirm_cost(actor, skill)
		actor.skill_point -= get_sp_cost(skill)
		actor.mp -= get_mp_cost(skill)
		$game_party.lose_gold(get_gold_cost(skill))
	end
	
	# изменить характеристики персонажа
	def self.learn_skill_parameters(actor, preset, battle_test = nil)
		return if preset.nil?
		if !battle_test.nil?
			return if battle_test.size == 14
			preset[:mhp] = nil if battle_test.include?(:mhp)
			preset[:mmp] = nil if battle_test.include?(:mmp)
			preset[:atk] = nil if battle_test.include?(:atk)
			preset[:def] = nil if battle_test.include?(:def)
			preset[:mat] = nil if battle_test.include?(:mat)
			preset[:mdf] = nil if battle_test.include?(:mdf)
			preset[:agi] = nil if battle_test.include?(:agi)
			preset[:luk] = nil if battle_test.include?(:luk)
			preset[:actor_recover] = nil if battle_test.include?(:actor_recover)
			preset[:actor_add_state] = nil if battle_test.include?(:actor_add_state)
			preset[:actor_remove_state] = nil if battle_test.include?(:actor_remove_state)
			preset[:actor_name] = nil if battle_test.include?(:actor_name)
			preset[:actor_graphic] = nil if battle_test.include?(:actor_graphic)
			preset[:actor_change_class] = nil if battle_test.include?(:actor_change_class)
		end
		actor.add_param(0, preset[:mhp]) if preset[:mhp]
		actor.add_param(1, preset[:mmp]) if preset[:mmp]
		actor.add_param(2, preset[:atk]) if preset[:atk]
		actor.add_param(3, preset[:def]) if preset[:def]
		actor.add_param(4, preset[:mat]) if preset[:mat]
		actor.add_param(5, preset[:mdf]) if preset[:mdf]
		actor.add_param(6, preset[:agi]) if preset[:agi]
		actor.add_param(7, preset[:luk]) if preset[:luk]
		actor_add_state = preset[:actor_add_state]
		actor_remove_state = preset[:actor_remove_state]
		actor_name = preset[:actor_name]
		actor_graphic = preset[:actor_graphic]
		actor_change_class = preset[:actor_change_class]
		actor.recover_all if preset[:actor_recover]
		if !actor_add_state.nil?
			actor_add_state.each do |index|
				actor.add_state(index)
			end
		end
		if !actor_remove_state.nil?
			actor_remove_state.each do |index|
				actor.remove_state(index)
			end
		end
		actor.name = actor_name if actor_name
		if actor_graphic
			actor.set_graphic(actor_graphic[0], actor_graphic[1], actor_graphic[2], actor_graphic[3])
			$game_player.refresh
		end
		actor.change_class(actor_change_class, true) if actor_change_class
		return true if actor_change_class
		return false
	end
	
	# индексы класса в базе данных, к которому относится навык
	def self.get_skill_classes(skill_id)
		classes = []
		classes_keys = $SKILL_TREE_SYSTEM_SKILL_CLASSES.keys
		i = 0
		$SKILL_TREE_SYSTEM_SKILL_CLASSES.each do |class_mas|
			class_mas[1].each do |index|
				classes.push(classes_keys[i]) if index.include?(skill_id)
			end
			i += 1
		end
		return classes
	end
	
	# массив индексов дочернего навыка в базе данных, который нужен, чтобы изучить родительский
	def self.get_needed_skills(actor, skill)
		needed = []
		skill_id = skill.id
		if SKILL_TREE_SYSTEM_SKILL_REQUIRED.has_key?(skill_id)
			SKILL_TREE_SYSTEM_SKILL_REQUIRED[skill_id].each do |index|
				needed.push(index) if get_skill_classes(index).include?(actor.class_id)
			end
		end
		return needed	
	end
	
	# может ли персонаж выучить навык
	def self.get_can_learn_skill(actor, skill)
		return false if actor.skill_learn?(skill)
		return false if !lvl_comparsion(actor, skill)
		return false if !sp_cost_comparsion(actor, skill)
		return false if !mp_cost_comparsion(actor, skill)
		return false if !gold_cost_comparsion(skill)
		needed = get_needed_skills(actor, skill)
		return true if needed == []
		needed.each do |index|
			if index < 0
				return false if !actor.skill_learn?($Skill_Tree_System_Custom_Skills[index])
			else
				return false if !actor.skill_learn?($data_skills[index])
			end
		end
		return true
	end
	
	# состояние навыка (1 - изучено, 2 - можно выучить, 3 - нельзя выучить)
	def self.get_skill_learn_state(actor, skill)
		return 1 if actor.skill_learn?(skill)
		return 2 if get_can_learn_skill(actor, skill)
		return 3
	end
	
	# открыть Древо Навыков
	def self.open_skill_tree_system(actor)
		return if actor.nil?
		$game_party.menu_actor = actor
		SceneManager.call(Skill_Tree_System_Scene)
	end
	
end # class Skill_Tree_System_Functions

class Game_Actor < Game_Battler
	
	include Skill_Tree_System_Settings
	
	attr_accessor :skill_point 		# добавлено
	attr_reader		:actor_id 			# в оригинале нет
	attr_reader		:custom_skills 	# в оригинале нет
	
	# метод дополнен
	alias denis_kyznetsov_skill_tree_system_game_actor_setup setup
	def setup(actor_id)
		denis_kyznetsov_skill_tree_system_game_actor_setup(actor_id)
		@skill_point = SKILL_TREE_SYSTEM_ACTOR_SKILL_POINT + (@level - 1) * SKILL_TREE_SYSTEM_LEVEL_SKILL_POINT
		if SKILL_TREE_SYSTEM_SKIP_LVL.has_key?(actor_id)
			SKILL_TREE_SYSTEM_SKIP_LVL[actor_id].each do |index|
				@skill_point -= SKILL_TREE_SYSTEM_LEVEL_SKILL_POINT if index <= @level
			end
		end
	end
	
	# метод дополнен
	alias denis_kyznetsov_skill_tree_system_game_actor_change_class change_class
	def change_class(class_id, keep_exp = false)
		denis_kyznetsov_skill_tree_system_game_actor_change_class(class_id, keep_exp)
		init_skills
		@skill_point = 0 if !keep_exp
	end
	
	# метод переписан
	def level_up
		@level += 1
		if SKILL_TREE_SYSTEM_SKIP_LVL.has_key?(actor_id)
			@skill_point += SKILL_TREE_SYSTEM_LEVEL_SKILL_POINT if !SKILL_TREE_SYSTEM_SKIP_LVL[actor_id].include?(@level) && !(SKILL_TREE_SYSTEM_POINT_LVL_LIMIT && actor_learned_all_skills?)
		else
			@skill_point += SKILL_TREE_SYSTEM_LEVEL_SKILL_POINT if !(SKILL_TREE_SYSTEM_POINT_LVL_LIMIT && actor_learned_all_skills?)
		end
	end
	
	# новый метод - выучил ли персонаж все навыки для класса ?
	def actor_learned_all_skills?
		skills = []
		$SKILL_TREE_SYSTEM_SKILL_CLASSES[@class_id].each do |skill_mas|
			skill_mas.each do |skill_id|
				skills.push(skill_id)
			end
		end
		minus_mas = skills - (@skills + @custom_skills)
		return minus_mas.empty?
	end
	
	# метод переписан
	def init_skills
		@skills = []
		@custom_skills = []
	end
	
	# метод переписан
	def learn_skill(skill_id)
		if skill_id > 0
			unless skill_learn?($data_skills[skill_id])
				@skills.push(skill_id)
				@skills.sort!
			end
		else
			unless skill_learn?($Skill_Tree_System_Custom_Skills[skill_id])
				@custom_skills.push(skill_id)
				@custom_skills.sort!
			end
		end
	end
	
	# метод переписан
	def forget_skill(skill_id)
		if skill_id > 0
			@skills.delete(skill_id)
		else
			@custom_skills.delete(skill_id)
		end
	end
	
	# метод переписан
	def skill_learn?(skill)
		if skill.id > 0
			skill.is_a?(RPG::Skill) && @skills.include?(skill.id)
		else
			skill.is_a?(RPG::Skill) && @custom_skills.include?(skill.id)
		end
	end
	
end # class Game_Actor < Game_Battler

class Game_Interpreter
	
	include Skill_Tree_System_Settings
	
	def open_skill_tree_system(actor_id = $game_party.members[0].actor_id)
		Skill_Tree_System_Functions.open_skill_tree_system(Skill_Tree_System_Functions.get_actor_from_id(actor_id))
	end
	
	def add_skill_point(skill_point, actor_id = $game_party.members[0].actor_id)
		actor = Skill_Tree_System_Functions.get_actor_from_id(actor_id)
		return if actor.nil?
		actor.skill_point += skill_point
	end
	
	def set_skill_point(skill_point, actor_id = $game_party.members[0].actor_id)
		actor = Skill_Tree_System_Functions.get_actor_from_id(actor_id)
		return if actor.nil?
		actor.skill_point = skill_point
	end
	
	def get_skill_point(actor_id = $game_party.members[0].actor_id)
		actor = Skill_Tree_System_Functions.get_actor_from_id(actor_id)
		return if actor.nil?
		return actor.skill_point
	end
	
	def push_skill_in_skill_tree(class_id, layer, skill_id, y)
		return if check_change_skill_tree(class_id, layer, index)
		$SKILL_TREE_SYSTEM_SKILL_CLASSES[class_id][layer].push(skill_id)
		$SKILL_TREE_SYSTEM_SKILL_POSITION[class_id][layer].push(y)
	end
	
	def paste_skill_in_skill_tree(class_id, layer, index, skill_id, y)
		return if check_change_skill_tree(class_id, layer, index)
		$SKILL_TREE_SYSTEM_SKILL_CLASSES[class_id][layer].insert(index, skill_id)
		$SKILL_TREE_SYSTEM_SKILL_POSITION[class_id][layer].insert(index, y)
	end
	
	def replace_skill_in_skill_tree(class_id, layer, index, skill_id, y)
		return if check_change_skill_tree(class_id, layer, index)
		$SKILL_TREE_SYSTEM_SKILL_CLASSES[class_id][layer][index] = skill_id
		$SKILL_TREE_SYSTEM_SKILL_POSITION[class_id][layer][index] = y
	end
	
	def remove_skill_from_skill_tree(class_id, layer, index)
		return if check_change_skill_tree(class_id, layer, index)
		$SKILL_TREE_SYSTEM_SKILL_CLASSES[class_id][layer][index] = nil
		$SKILL_TREE_SYSTEM_SKILL_CLASSES[class_id][layer].compact!
		$SKILL_TREE_SYSTEM_SKILL_POSITION[class_id][layer][index] = nil
		$SKILL_TREE_SYSTEM_SKILL_POSITION[class_id][layer].compact!
	end
	
	def check_change_skill_tree(class_id, layer, index = 0)
		return true if !$SKILL_TREE_SYSTEM_SKILL_CLASSES.has_key?(class_id)
		return true if !$SKILL_TREE_SYSTEM_SKILL_POSITION.has_key?(class_id)
		return true if layer >= $SKILL_TREE_SYSTEM_SKILL_CLASSES[class_id].size
		return true if index > $SKILL_TREE_SYSTEM_SKILL_CLASSES[class_id][layer].size
		return false
	end
	
end # class Game_Interpreter

class Window_MenuCommand < Window_Command
	
	include Skill_Tree_System_Settings
	
	alias denis_kyznetsov_skill_tree_system_windw_menucommand_add_main_commands add_main_commands
	def add_main_commands
		denis_kyznetsov_skill_tree_system_windw_menucommand_add_main_commands
		if SKILL_TREE_SYSTEM_MENU_COMMAND != "" && SKILL_TREE_SYSTEM_MENU_COMMAND != -1
			add_command(SKILL_TREE_SYSTEM_MENU_COMMAND, :skill_tree_system, SKILL_TREE_SYSTEM_SWITCH_ENABLE == -1 ? true : $game_switches[SKILL_TREE_SYSTEM_SWITCH_ENABLE])
		end
	end
	
end # class Window_MenuCommand < Window_Command

class Scene_Menu < Scene_MenuBase
	
	include Skill_Tree_System_Settings
	
	alias denis_kyznetsov_skill_tree_system_scene_menu_create_command_window create_command_window
	def create_command_window
		denis_kyznetsov_skill_tree_system_scene_menu_create_command_window
		@command_window.set_handler(:skill_tree_system, method(:command_personal))
		@command_window.set_handler(:skill_tree_system, method(:open_skill_tree_system)) if SKILL_TREE_SYSTEM_SINGLE_PLAYER != -1
	end
	
	def open_skill_tree_system
		Skill_Tree_System_Functions.open_skill_tree_system(Skill_Tree_System_Functions.get_actor_from_id(SKILL_TREE_SYSTEM_SINGLE_PLAYER))
	end
	
	alias denis_kyznetsov_skill_tree_system_scene_menu_on_personal_ok on_personal_ok
	def on_personal_ok
		denis_kyznetsov_skill_tree_system_scene_menu_on_personal_ok
		SceneManager.call(Skill_Tree_System_Scene) if @command_window.current_symbol == :skill_tree_system
	end
	
end # class Scene_Menu < Scene_MenuBase

module DataManager
	
	include Skill_Tree_System_Settings
	
	class << self
		alias denis_kyznetsov_skill_tree_system_data_manager_create_game_objects create_game_objects
		alias denis_kyznetsov_skill_tree_system_data_manager_setup_battle_test setup_battle_test
		alias denis_kyznetsov_skill_tree_system_data_manager_make_save_contents make_save_contents
		alias denis_kyznetsov_skill_tree_system_data_manager_extract_save_contents extract_save_contents
	end
	
	def self.create_game_objects
		denis_kyznetsov_skill_tree_system_data_manager_create_game_objects
		$SKILL_TREE_SYSTEM_SKILL_CLASSES = SKILL_TREE_SYSTEM_SKILL_CLASSES # древо навыков изменяется
		$SKILL_TREE_SYSTEM_SKILL_POSITION = SKILL_TREE_SYSTEM_SKILL_POSITION # древо навыков изменяется
		$Skill_Tree_System_Custom_Skills = {}
		SKILL_TREE_SYSTEM_CUSTOM_SKILLS.each do |index|
			$Skill_Tree_System_Custom_Skills[index[0]] = RPG::Skill.new(index[0])
		end
	end
	
	def self.setup_battle_test
		denis_kyznetsov_skill_tree_system_data_manager_setup_battle_test
		$game_party.members.each do |actor|
			actor_class_id = actor.class_id
			if $SKILL_TREE_SYSTEM_SKILL_CLASSES.has_key?(actor_class_id)
				$SKILL_TREE_SYSTEM_SKILL_CLASSES[actor_class_id].each do |class_skills|
					class_skills.each do |skill_id|
						actor.learn_skill(skill_id)
						preset = skill_id < 0 ? SKILL_TREE_SYSTEM_CUSTOM_SKILLS[skill_id] : SKILL_TREE_SYSTEM_BASE_SKILLS[skill_id]
						Skill_Tree_System_Functions.learn_skill_parameters(actor, preset, SKILL_TREE_SYSTEM_BATTLE_TEST_IGNORE)
					end
				end
			end
		end
	end
	
	def self.make_save_contents
		contents = denis_kyznetsov_skill_tree_system_data_manager_make_save_contents
		contents[:SKILL_TREE_SYSTEM_SKILL_CLASSES] = $SKILL_TREE_SYSTEM_SKILL_CLASSES
		contents[:SKILL_TREE_SYSTEM_SKILL_POSITION] = $SKILL_TREE_SYSTEM_SKILL_POSITION
		contents
	end
	
	def self.extract_save_contents(contents)
		denis_kyznetsov_skill_tree_system_data_manager_extract_save_contents(contents)
		$SKILL_TREE_SYSTEM_SKILL_CLASSES = contents[:SKILL_TREE_SYSTEM_SKILL_CLASSES]
		$SKILL_TREE_SYSTEM_SKILL_POSITION = contents[:SKILL_TREE_SYSTEM_SKILL_POSITION]
	end
	
end # module DataManager