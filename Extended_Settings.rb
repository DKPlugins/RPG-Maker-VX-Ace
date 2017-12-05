=begin
###############################################################################
#                                                                             #
#          				Extended Settings (Расширенные настройки)  		              #
#                                                                             #
###############################################################################	
	
Author (Автор): Denis Kyznetsov (Денис Кузнецов) (http://vk.com/id8137201)
VK Group (Группа ВК): https://vk.com/scriptsrpgmakervxace
Version (Версия): 2.0
Release (Релиз от): 17.10.15

Plug and Play (Установи и Играй)

For developers (Для разработчиков):

To add your command, use (Чтобы добавить свою команду, используйте) -

$Extended_Settings_Command_List.push({ :command_name => string, :command_symbol => symbol, :method => symbol,
:enabled => boolean, :author = > string, :version => string, :date => string, :description => string})

command_name - Your command name in command list (Название вашей команды в списке)
command_symbol - command symbol for window set_handler (Символ команды для установки хендлера в окне)
method - Your processing method (Метод обработки нажатия команды)
enabled - Show your command in list (Отображать ли вашу команду в списке)
author - Author of script (Автор скрипта)
version - Current version (Текущая версия скрипта)
date - Date of update (Дата обновления)
description - Script description (Описание скрипта)

Next (затем)
Add your method to my Scene (Extended_Settings_Scene) (Добавьте свой метод в мою сцену)

Example (пример):

class Extended_Settings_Scene < Scene_Base
	
	def den_kyz_game_test_settings_method
		SceneManager.call(Game_Test_Settings_Scene)
	end
	
end

=end

module Extended_Settings
	
	# Language of script (Язык скрипта)
	# 1 - Russian (Русский), 2 - English (Английский)
	$EXTENDED_SETTINGS_LANGUAGE = 2
	
	# Language settings (Настройка языков)
	# :menu => Menu command name (Название команды в меню)
	# :author => Author (Автор)
	# :version => Version (Версия)
	# :date => Date (Дата)
	# :description => Description (Описание)
	# :no_description => No description (Описание отсутствует)
	# language_id => { :menu =>, :author =>, :version =>, :date =>,
	# 									:description =>, :no_description => }
	EXTENDED_SETTINGS_LANGUAGE_SETTINGS = {
		1 => { :menu => "Настройки", :author => "Автор",
			:version => "Версия", :date => "Дата", :description => "Описание",
			:no_description => "Описание отсутствует" },
		2 => { :menu => "Settings", :author => "Author",
			:version => "Version", :date => "Date", :description => "Description",
			:no_description => "No description" }
	}
	
	# Call button on map (Кнопка вызова на карте)
	# -1 for not using
	# -1 чтобы не использовать
	EXTENDED_SETTINGS_MAP_BUTTON = :R
	
	# Call button in battle (Кнопка вызова в бою)
	# -1 for not using
	# -1 чтобы не использовать
	EXTENDED_SETTINGS_BATTLE_BUTTON = :R
	
end # module Extended_Settings

$Extended_Settings_Command_List = []

class Window_MenuCommand < Window_Command
	
	include Extended_Settings
	
	alias denis_kyznetsov_extended_settings_wnd_menu_cmmd_add_original_commands add_original_commands
	def add_original_commands
		denis_kyznetsov_extended_settings_wnd_menu_cmmd_add_original_commands
		add_command(EXTENDED_SETTINGS_LANGUAGE_SETTINGS[$EXTENDED_SETTINGS_LANGUAGE][:menu], :den_kyz_extended_settings) if EXTENDED_SETTINGS_LANGUAGE_SETTINGS[$EXTENDED_SETTINGS_LANGUAGE][:menu] != ""
	end
	
end # class Window_MenuCommand < Window_Command

class Scene_Menu < Scene_MenuBase
	
	alias denis_kyznetsov_extended_settings_scene_menu_create_command_window  create_command_window
	def create_command_window
		denis_kyznetsov_extended_settings_scene_menu_create_command_window
		@command_window.set_handler(:den_kyz_extended_settings, method(:den_kyz_extended_settings))
	end
	
	def den_kyz_extended_settings
		SceneManager.call(Extended_Settings_Scene) 
	end
	
end # class Scene_Menu < Scene_MenuBase

class Scene_Map < Scene_Base
	
	include Extended_Settings
	
	alias denis_kyznetsov_extended_settings_scene_map_update update
	def update
		denis_kyznetsov_extended_settings_scene_map_update
		return if EXTENDED_SETTINGS_MAP_BUTTON.is_a?(Integer)
		SceneManager.call(Extended_Settings_Scene) if Input.trigger?(EXTENDED_SETTINGS_MAP_BUTTON)
	end
	
end # class Scene_Map < Scene_Base

class Scene_Battle < Scene_Base
	
	include Extended_Settings
	
	alias denis_kyznetsov_extended_settings_scene_battle_update update
	def update
		denis_kyznetsov_extended_settings_scene_battle_update
		return if EXTENDED_SETTINGS_BATTLE_BUTTON.is_a?(Integer)
		SceneManager.call(Extended_Settings_Scene) if Input.trigger?(EXTENDED_SETTINGS_BATTLE_BUTTON)
	end
	
end # class Scene_Battle < Scene_Base

class Extended_Settings_Scene < Scene_Base
	
	include Extended_Settings
	
	def start
		super
		create_name_window
		create_command_window
		create_info_window
	end
	
	def create_name_window
		@create_name_window = Extended_Settings_Name_Window.new
	end
	
	def create_command_window
		@create_command_window = Extended_Settings_Command_Window.new
		@create_command_window.set_handler(:cancel, method(:return_scene))
		$Extended_Settings_Command_List.each do |index|
			@create_command_window.set_handler(index[:command_symbol], method(index[:method])) if index[:enabled]
		end
	end
	
	def create_info_window
		@create_info_window = Extended_Settings_Info_Window.new(@create_command_window)
	end
	
end # class Extended_Settings_Scene < Scene_Base

class Extended_Settings_Name_Window < Window_Base
	
	def initialize
		super(0, 0, Graphics.width, line_height * 2)
		draw_text(0, 0, contents_width, line_height, Extended_Settings::EXTENDED_SETTINGS_LANGUAGE_SETTINGS[$EXTENDED_SETTINGS_LANGUAGE][:menu], 1)
	end
	
end # class Extended_Settings_Name_Window < Window_Base

class Extended_Settings_Command_Window < Window_Command
	
	def initialize
		super(0, line_height * 2)
		select(0)
	end
	
	def window_width
		Graphics.width / 3
	end
	
	def window_height
		Graphics.height - line_height * 2
	end
	
	def make_command_list
		$Extended_Settings_Command_List.each do |index|
			add_command(index[:command_name], index[:command_symbol]) if index[:enabled]
		end
	end
	
	# Return index from the list of settings list for the selected symbol 
	# Возвращает индекс из списка настроек по символу выбранной команды
	# Например, выбрана команда 2, но реальный индекс мб 40, потому что
	# отключены некоторые команды
	def current_index
		list = $Extended_Settings_Command_List
		list.each_index do |i|
			if list[i][:enabled]
				return i if list[i][:command_symbol] == current_symbol
			end
		end
	end
	
end # class Extended_Settings_Command_Window < Window_Command

class Extended_Settings_Info_Window < Window_Base
	
	include Extended_Settings
	
	def initialize(create_command_window)
		@create_command_window = create_command_window
		super(Graphics.width / 3, line_height * 2, Graphics.width * 2 / 3, Graphics.height - line_height * 2)
	end
	
	def update
		return if @create_command_window_last_index == @create_command_window.current_index
		@create_command_window_last_index = @create_command_window.current_index
		contents.clear
		return no_description_text if !@create_command_window_last_index.is_a?(Integer)
		extended_settings = $Extended_Settings_Command_List[@create_command_window_last_index]
		return no_description_text if !extended_settings[:enabled]
		y = 0
		if extended_settings[:author].to_s != ""
			text = EXTENDED_SETTINGS_LANGUAGE_SETTINGS[$EXTENDED_SETTINGS_LANGUAGE][:author]
			draw_text_ex(0, y, "\\c[14]#{text}:\\c[0] " + extended_settings[:author].to_s)
			y += 32
		end
		if extended_settings[:version].to_s != ""
			text = EXTENDED_SETTINGS_LANGUAGE_SETTINGS[$EXTENDED_SETTINGS_LANGUAGE][:version]
			draw_text_ex(0, y, "\\c[2]#{text}:\\c[0] " + extended_settings[:version].to_s)
			y += 32
		end
		if extended_settings[:date].to_s != ""
			text = EXTENDED_SETTINGS_LANGUAGE_SETTINGS[$EXTENDED_SETTINGS_LANGUAGE][:date]
			draw_text_ex(0, y, "\\c[3]#{text}:\\c[0] " + extended_settings[:date].to_s)
			y += 32
		end
		if extended_settings[:description] != ""
			y += 16
			text = EXTENDED_SETTINGS_LANGUAGE_SETTINGS[$EXTENDED_SETTINGS_LANGUAGE][:description]
			draw_text(0, y, contents_width, line_height, text, 1)
			y += 32
			draw_text_ex(0, y, extended_settings[:description])
			y += 32
		else
			text = EXTENDED_SETTINGS_LANGUAGE_SETTINGS[$EXTENDED_SETTINGS_LANGUAGE][:no_description]
			draw_text(0, y, contents_width, line_height, text, 1)
		end
	end
	
	def no_description_text
		text = EXTENDED_SETTINGS_LANGUAGE_SETTINGS[$EXTENDED_SETTINGS_LANGUAGE][:no_description]
		draw_text(0, 0, contents_height, contents_height, text, 1)
	end
	
end # class Extended_Settings_Info_Window < Window_Base

module DataManager
	
	class << self
		alias denis_kyznetsov_extended_settings_data_manager_make_save_contents make_save_contents
		alias denis_kyznetsov_extended_settings_data_manager_extract_save_contents extract_save_contents
	end
	
	def self.make_save_contents
		contents = denis_kyznetsov_extended_settings_data_manager_make_save_contents
		contents[:EXTENDED_SETTINGS_LANGUAGE] = $EXTENDED_SETTINGS_LANGUAGE
		contents
	end
	
	def self.extract_save_contents(contents)
		denis_kyznetsov_extended_settings_data_manager_extract_save_contents(contents)
		$EXTENDED_SETTINGS_LANGUAGE = contents[:EXTENDED_SETTINGS_LANGUAGE]
	end
	
end # module DataManager